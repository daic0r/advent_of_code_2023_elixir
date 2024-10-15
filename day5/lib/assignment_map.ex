defmodule Day5.AssignmentMap do
  defstruct [:from, :to, ranges: []]

  def get_mapping(this, src) do
    range = this.ranges
      |> Enum.find(fn range ->
        src >= range.src_start and src <= (range.src_start + range.length - 1)
      end)
    if range do
      range.dest_start + (src - range.src_start)
    else
      src
    end
  end
end
