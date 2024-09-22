defmodule GeminexTest do
  use ExUnit.Case

  doctest Geminex

  test "greets the world" do
    assert Geminex.hello() == :world
  end
end
