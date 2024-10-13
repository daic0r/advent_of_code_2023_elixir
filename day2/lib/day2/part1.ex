defmodule Day2.Part1 do
  alias Day2.GameSet

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

  def set_possible?(set, available) do
    %GameSet{red: r, green: g, blue: b} = set
    %GameSet{red: avail_r, green: avail_g, blue: avail_b} = available
    ((r || 0) <= avail_r) and ((g || 0) <= avail_g) and ((b || 0) <= avail_b)
  end

  def process(available) do
    lines = get_lines()
    lines
      |> Enum.map(fn line ->
        [game_num, data] = Regex.run(~r/Game (\d+): (.+)/, line, capture: :all_but_first)
        game_num = elem(Integer.parse(game_num), 0)
        {game_num, data}
      end)
      |> Enum.map(fn {game_num, data} ->
        sets = String.split(data, ";")
        sets = sets |> Enum.map(fn s ->
          list_colors = s |> String.split(",") |> Enum.map(&(String.trim(&1))) |> IO.inspect
          extract_set(list_colors, %GameSet{})
        end)
        {game_num, sets} 
      end)
      |> Enum.map(fn {game_num, sets} ->
        all_possible = Enum.reduce(sets, true, fn x, acc -> set_possible?(x, available) and acc end)
        case all_possible do
          true -> game_num
          false -> 0
        end
      end)
      |> Enum.sum
  end

  def main do
    result = process(%GameSet{ red: 12, green: 13, blue: 14 })
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
