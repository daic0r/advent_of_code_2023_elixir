defmodule Day4.Part1 do
  def parse(file) do
    {:ok, data} = File.read(file) 
    data 
      |> String.split("\n")
      |> Enum.filter(&(String.length(&1) > 0))
      |> Enum.map(& String.trim(&1))
      |> Enum.map(fn line ->
        Regex.run(~r/Card\s+\d+:\s+(.+)\s+\|\s+(.+)/, line, capture: :all_but_first)
      end)
      |> Enum.map(fn [ str_winning, str_mine ] ->
        winning = str_winning |> String.split(" ") |> Enum.filter(& String.length(&1) > 0) |> Enum.map(& elem(Integer.parse(&1), 0))
        mine = str_mine |> String.split(" ") |> Enum.filter(& String.length(&1) > 0) |> Enum.map(& elem(Integer.parse(&1), 0))
        { winning, mine }
      end)
      |> Enum.map(fn { winning, mine } ->
        winning_set = for num <- winning, into: MapSet.new(), do: num
        mine_set = for num <- mine, into: MapSet.new(), do: num
        { winning_set, mine_set }
      end)
      |> IO.inspect
  end

  def process(file) do
    cards = parse(file)    
    cards
      |> Enum.map(fn { winning_set, mine_set } ->
        sz = MapSet.intersection(winning_set, mine_set) |> MapSet.size
        if sz > 0 do
          trunc(:math.pow(2, sz-1))
        else
          0
        end
      end)
      |> Enum.sum
  end

  def start(_type, _args) do
    result = process("input2.txt")
    IO.puts "Result = #{result}"
    {:ok, self()}
  end
end
