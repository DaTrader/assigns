defmodule Assigns do
  @moduledoc """
  Helps abbreviate writing LiveView `assign/3`, `assign_new/3` and `update/3` wrapper functions.

  Ex:

  ```
  defassign :foo
  ```

  expands into

  ```
  def assign_foo( socket_or_assigns, foo) do
    assign( socket_or_assigns, :foo, foo)
  end
  ```

  while

  ```
  defassign [ :foo, :bar, :baz]
  ```

  expands into

  ```
  def assign_foo( socket_or_assigns, foo) do
    assign( socket_or_assigns, :foo, foo)
  end

  def assign_foo( socket_or_assigns, bar) do
    assign( socket_or_assigns, :bar, bar)
  end

  def assign_foo( socket_or_assigns, baz) do
    assign( socket_or_assigns, :baz, baz)
  end
  ```

  Similarly,

  ```
  defupdate [ :foo, :bar]
  ```

  expands into

  ```
  def update_foo( socket_or_assigns, updater) do
    assign( socket_or_assigns, :foo, updater)
  end

  def update_bar( socket_or_assigns, updater) do
    assign( socket_or_assigns, :bar, updater)
  end
  ```

  Boolean assigns are an exception in that the assign key is identical to the
  name, while the assign (or update) wrapper function name does not contain the
  question mark.

  Ex:

  ```
  defassign :connected?
  ```

  expands into:

  ```
  def assign_connected( socket_or_assigns, connected?) do
    assign( socket_or_assigns, :connected?, connected?)
  end
  ```
  """
  defmacro __using__( _env) do
    Module.register_attribute( __CALLER__.module, :_keys, accumulate: true)

    quote do
      import Assigns,
        only: [ defassign: 1, defassignp: 1, defassign_new: 1, defassign_newp: 1, defupdate: 1, defupdatep: 1]

      @before_compile Assigns
    end
  end

  # At this stage, just push the name(s) into an accumulating module
  # attribute.  We'll generate the actual code in the @before_compile hook
  # because it can resolve module attributes

  @doc  """
  Defines a `Phoenix.Component.assign/3` wrapper function for each of the names
  whether provided in a list or as a standalone atom.
  """
  @spec defassign( atom() | [ atom()]) :: :ok
  defmacro defassign( name_or_names) do
    Module.put_attribute( __CALLER__.module, :_keys, { :assign, :def, name_or_names})
  end

  @doc """
  Same as `defassign/1` but defines private wrapper function(s).
  """
  @spec defassignp( atom() | [ atom()]) :: :ok
  defmacro defassignp( name_or_names) do
    Module.put_attribute( __CALLER__.module, :_keys, { :assign, :defp, name_or_names})
  end

  @doc """
  Defines a `Phoenix.Component.assign_new/3` wrapper function for each of the
  names whether provided in a list or as a standalone atom.
  """
  @spec defassign_new( atom() | [ atom()]) :: Macro.output()
  defmacro defassign_new( name_or_names) do
    Module.put_attribute( __CALLER__.module, :_keys, { :assign_new, :def, name_or_names})
  end

  @doc """
  Same as `defassign_new/1` but defines private wrapper function(s).
  """
  @spec defassign_newp( atom() | [ atom()]) :: Macro.output()
  defmacro defassign_newp( name_or_names) do
    Module.put_attribute( __CALLER__.module, :_keys, { :assign_new, :defp, name_or_names})
  end

  @doc """
  Defines a `Phoenix.Component.update/3` wrapper function for each of the names
  whether provided in a list or as a standalone atom.
  """
  @spec defupdate( atom() | [ atom()]) :: Macro.output()
  defmacro defupdate( name_or_names) do
    Module.put_attribute( __CALLER__.module, :_keys, { :update, :def, name_or_names})
  end

  @doc """
  Same as `defupdate/1` but defines private  wrapper function(s).
  """
  @spec defupdatep( atom() | [ atom()]) :: Macro.output()
  defmacro defupdatep( name_or_names) do
    Module.put_attribute( __CALLER__.module, :_keys, { :update, :defp, name_or_names})
  end

  # Traverses collected `_keys` attributes and generates code for each.
  @doc false
  defmacro __before_compile__( _env) do
    __CALLER__.module
    |> Module.delete_attribute( :_keys)
    |> Assigns.resolve_and_flatten_keys( __CALLER__.module)
    |> Enum.reverse()
    |> Enum.into( [], &Assigns.expand_code/1)
  end

  @typep use_case() :: :assign | :assign_new | :update
  @typep kind() :: :def | :defp
  @typep key() :: { use_case(), kind(), atom()}

  @doc false
  @spec resolve_and_flatten_keys( list(), module()) :: [ key()]
  def resolve_and_flatten_keys( keys, caller) do
    Enum.map( keys, fn
      { use_case, kind, { :@, _, [ { module_attribute, _, _}]}} ->
        key_or_keys = Module.get_attribute( caller, module_attribute)
        expand_keys( use_case, kind, key_or_keys)

      { use_case, kind, key_or_keys} ->
        expand_keys( use_case, kind, key_or_keys)
    end)
    |> List.flatten()
  end

  @spec expand_keys( use_case(), kind(), atom() | [ atom()]) :: key() | [ key()]
  defp expand_keys( use_case, kind, name_or_names)

  defp expand_keys( use_case, kind, names) when is_list( names) do
    Enum.map( names, &{ use_case, kind, &1})
    |> Enum.reverse()
  end

  defp expand_keys( use_case, kind, name) when is_atom( name) do
    { use_case, kind, name}
  end

  # Generates function definitions
  @doc false
  @spec expand_code( key()) :: Macro.output()
  def expand_code( key)

  def expand_code( { :assign, kind, name}) do
    sanitized_name = Assigns.sanitize_name( name)
    var = Macro.var( name, nil)

    quote do
      unquote( kind)( unquote( :"assign_#{ sanitized_name}")( socket_or_assigns, unquote( var))) do
        Phoenix.Component.assign( socket_or_assigns, unquote( :"#{ name}"), unquote( var))
      end
    end
  end

  def expand_code( { :assign_new, kind, name}) do
    sanitized_name = Assigns.sanitize_name( name)

    quote do
      unquote( kind)( unquote( :"assign_new_#{ sanitized_name}")( socket_or_assigns, fun)) do
        Phoenix.Component.assign_new( socket_or_assigns, unquote( :"#{ name}"), fun)
      end
    end
  end

  def expand_code( { :update, kind, name}) do
    sanitized_name = Assigns.sanitize_name( name)

    quote do
      unquote( kind)( unquote( :"update_#{ sanitized_name}")( socket_or_assigns, updater)) do
        Phoenix.Component.update( socket_or_assigns, unquote( :"#{ name}"), updater)
      end
    end
  end

  # Trims a trailing `?` from the name atom if any.
  @doc false
  @spec sanitize_name( atom()) :: atom()
  def sanitize_name( name) when is_atom( name) do
    name
    |> Atom.to_string()
    |> String.trim_trailing( "?")
    |> String.to_atom()
  end
end
