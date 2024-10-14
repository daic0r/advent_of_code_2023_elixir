defmodule Day3.Symbol do
  @enforce_keys [:col]
  defstruct [:col, :row, {:numbers, MapSet.new()}, :ch]
end
