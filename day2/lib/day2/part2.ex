defmodule Day2.Part2 do
  alias Day2.GameSet
  import Assertions

  def get_lines do
    {:ok, data} = File.read("input2.txt") 
    data |> String.split("\n") |> Enum.filter(&(String.length(&1) > 0))
  end

  def extract_set([], str) do
    str
  end
  def extract_set(list_colors, str) when length(list_colors) > 0 do
    [num, color] = Regex.run(~r/(\d+) ([a-z]+)/, hd(list_colors), capture: :all_but_first)
    num = elem(Integer.parse(num), 0)
    str = case color do
      "red" -> %{str | red: num}
      "green" -> %{str | green: num}
      "blue" -> %{str | blue: num}
    end
    extract_set(tl(list_colors), str)
  end

  def process() do
    lines = get_lines()
    lines
      |> Enum.map(fn line ->
        [_, data] = Regex.run(~r/Game (\d+): (.+)/, line, capture: :all_but_first)
        data
      end)
      |> Enum.map(fn data ->
        sets = String.split(data, ";")
        sets = sets |> Enum.map(fn s ->
          list_colors = s |> String.split(",") |> Enum.map(&(String.trim(&1))) |> IO.inspect
          extract_set(list_colors, %GameSet{})
        end)
        sets
      end)
      |> Enum.map(fn sets ->
        sets |> Enum.reduce(%GameSet{ red: 0, green: 0, blue: 0 }, fn x, acc ->
          r = if x.red && x.red > acc.red, do: x.red, else: acc.red
          g = if x.green && x.green > acc.green, do: x.green, else: acc.green
          b = if x.blue && x.blue > acc.blue, do: x.blue, else: acc.blue
          assert!(r != nil)
          assert!(g != nil)
          assert!(b != nil)
          %GameSet{ red: r, green: g, blue: b }
        end)
      end)
      |> Enum.map(fn %GameSet{ red: r, green: g, blue: b } -> r * g * b end)
      |> Enum.sum
  end

  def main do
    result = process()
    IO.puts "Result = #{result}"
    {:ok, self()}
  end

  def child_spec(_args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :main, []},
      restart: :temporary,
    }
  end
end
