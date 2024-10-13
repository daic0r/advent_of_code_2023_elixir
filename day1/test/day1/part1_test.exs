defmodule Day1.Part1Test do
  use ExUnit.Case
  doctest Day1.Part1

  test "greets the world" do
    assert Day1.Part1.hello() == :world
  end
end
