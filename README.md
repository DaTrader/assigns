# Assigns

Assigns is a library that enables abbreviation of Phoenix LiveView `assign/3`, `assign_new/3` and `update/3` wrapper 
function definitions.

## Installation

```elixir
def deps do
  [
    { :assigns, "~> 0.1.0"}
  ]
end
```

Import the `Assigns` module in every module where you use it:

```elixir
defmodule MyAppWeb.MyLiveView do
  use MyAppWeb, :live_view
  
  import Assigns # insert this here, or better yet into `MyAppWeb.html_helpers/0`
  
  # ..
end
```

## Docs

The docs can be found at [HexDocs](https://hexdocs.pm/assigns).

## Sample usage

```elixir
defmodule MyAppWeb.MyLiveView do
  use MyAppWeb, :live_view
  import Assigns
  
  # ..
  
  defassign_newp [ :foo, :baz]
  defassignp [ :foo, :bar, :baz, :just_mounted?]
  defupdatep :bar  
end
```

The snippet above is an equivalent of (expands into) the following:

```elixir
defmodule MyAppWeb.MyLiveView do
  use MyAppWeb, :live_view
  import Assigns
  
  # ..

  defp assign_new_foo( socket_or_assigns, fun) do
    assign_new( socket_or_assigns, :foo, fun)
  end
  
  defp assign_new_baz( socket_or_assigns, fun) do
    assign_new( socket_or_assigns, :baz, fun)
  end
  
  defp assign_foo( socket_or_assigns, foo) do
    assign( socket_or_assigns, :foo, foo)
  end
  
  defp assign_bar( socket_or_assigns, bar) do
    assign( socket_or_assigns, :bar, bar)    
  end
  
  defp assign_baz( socket_or_assigns, baz) do
    assign( socket_or_assigns, :baz, baz)
  end
  
  defp assign_just_mounted( socket_or_assigns, just_mounted?) do
    assign( socket_or_assigns, :just_mounted?, just_mounted?)
  end
  
  defp update_bar( socket_or_assigns, updater) do
    assign( socket_or_assigns, :bar, updater)
  end
end
```

## Formatting

The source code formatting in this library diverges from the standard formatting practice based on using `mix format`
in so much that there's a leading space character inserted before each initial argument / element with an intention to
improve the code readability (subject to the author's personal perception).
