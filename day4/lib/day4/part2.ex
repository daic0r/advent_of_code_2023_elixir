defmodule Day4.Part2 do
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
  end

  def get_winning_numbers(cards) do
    winning_nums = 
      cards
        |> Enum.with_index(0)
        |> Enum.map(fn {{ winning_set, mine_set }, idx } ->
          {idx, MapSet.intersection(winning_set, mine_set) |> MapSet.size }
        end)
        |> Enum.into(%{})

    winning_nums
  end

  def follow_card(index, cards) do
    1 + 
      (
        Enum.to_list(index..index+cards[index])
          |> Enum.drop(1)
          |> Enum.map(& follow_card(&1, cards))
          |> Enum.sum
      )
  end

  def process(file) do
    cards = parse(file)    
    winning_nums = get_winning_numbers(cards)
    num_cards = for index <- Enum.to_list(0..map_size(winning_nums)-1), do: follow_card(index, winning_nums)
    num_cards |> Enum.sum
  end

  def start(_type, _args) do
    result = process("input2.txt")
    IO.puts "Result = #{result}"
    {:ok, self()}
  end
end
