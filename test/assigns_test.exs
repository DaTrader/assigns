defmodule AssignsTest do
  use ExUnit.Case
  doctest Assigns

  test "greets the world" do
    assert Assigns.hello() == :world
  end
end
