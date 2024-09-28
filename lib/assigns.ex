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

  @doc  """
  Defines a `Phoenix.Component.assign/3` wrapper function for each of the names
  whether provided in a list or as a standalone atom.
  """
  @spec defassign( atom() | [ atom()]) :: Macro.output()
  defmacro defassign( name_or_names) do
    quote do
      def_assign( :def, unquote( name_or_names))
    end
  end

  @doc """
  Same as `defassign/1` but defines private wrapper function(s).
  """
  @spec defassignp( atom() | [ atom()]) :: Macro.output()
  defmacro defassignp( name_or_names) do
    quote do
      def_assign( :defp, unquote( name_or_names))
    end
  end

  @doc false
  @spec def_assign( :def | :defp, atom()) :: Macro.output()
  defmacro def_assign( kind, name_or_names)

  defmacro def_assign( kind, name) when kind in [ :def, :defp] and is_atom( name) do
    sanitized_name = Assigns.sanitize_name( name)
    var = Macro.var( name, nil)

    quote do
      unquote( kind)( unquote( :"assign_#{ sanitized_name}")( socket_or_assigns, unquote( var))) do
        Phoenix.Component.assign( socket_or_assigns, unquote( :"#{ name}"), unquote( var))
      end
    end
  end

  defmacro def_assign( kind, [ first | _] = names) when kind in [ :def, :defp] and is_atom( first) do
    for name <- names do
      quote do
        def_assign( unquote( kind), unquote( name))
      end
    end
  end

  @doc """
  Defines a `Phoenix.Component.assign_new/3` wrapper function for each of the
  names whether provided in a list or as a standalone atom.
  """
  @spec defassign_new( atom() | [ atom()]) :: Macro.output()
  defmacro defassign_new( name_or_names) do
    quote do
      def_assign_new( :def, unquote( name_or_names))
    end
  end

  @doc """
  Same as `defassign_new/1` but defines private wrapper function(s).
  """
  @spec defassign_newp( atom() | [ atom()]) :: Macro.output()
  defmacro defassign_newp( name_or_names) do
    quote do
      def_assign_new( :defp, unquote( name_or_names))
    end
  end

  @doc false
  @spec def_assign_new( :def | :defp, atom()) :: Macro.output()
  defmacro def_assign_new( kind, name_or_names)

  defmacro def_assign_new( kind, name) when kind in [ :def, :defp] and is_atom( name) do
    sanitized_name = Assigns.sanitize_name( name)

    quote do
      unquote( kind)( unquote( :"assign_new_#{ sanitized_name}")( socket_or_assigns, fun)) do
        Phoenix.Component.assign_new( socket_or_assigns, unquote( :"#{ name}"), fun)
      end
    end
  end

  defmacro def_assign_new( kind, [ first | _] = names) when is_atom( first) do
    for name <- names do
      quote do
        def_assign_new( unquote( kind), unquote( name))
      end
    end
  end

  @doc """
  Defines a `Phoenix.Component.update/3` wrapper function for each of the names
  whether provided in a list or as a standalone atom.
  """
  @spec defupdate( atom() | [ atom()]) :: Macro.output()
  defmacro defupdate( name_or_names) do
    quote do
      def_update( :def, unquote( name_or_names))
    end
  end

  @doc """
  Same as `defupdate/1` but defines private  wrapper function(s).
  """
  @spec defupdatep( atom() | [ atom()]) :: Macro.output()
  defmacro defupdatep( name_or_names) do
    quote do
      def_update( :defp, unquote( name_or_names))
    end
  end

  @doc false
  @spec def_update( :def | :defp, atom() | [ atom()]) :: Macro.output()
  defmacro def_update( kind, name_or_names)

  defmacro def_update( kind, name) when kind in [ :def, :defp] and is_atom( name) do
    sanitized_name = Assigns.sanitize_name( name)

    quote do
      unquote( kind)( unquote( :"update_#{ sanitized_name}")( socket_or_assigns, updater)) do
        Phoenix.Component.update( socket_or_assigns, unquote( :"#{ name}"), updater)
      end
    end
  end

  defmacro def_update( kind, [ first | _] = names) when is_atom( first) do
    for name <- names do
      quote do
        def_update( unquote( kind), unquote( name))
      end
    end
  end

  @doc false
  @spec sanitize_name( atom()) :: atom()
  def sanitize_name( name) when is_atom( name) do
    name
    |> Atom.to_string()
    |> String.trim_trailing( "?")
    |> String.to_atom()
  end
end
