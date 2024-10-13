defmodule Day1.Part2 do

  defp numbers() do
    [ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
      "1", "2", "3", "4", "5", "6", "7", "8", "9" ]
  end

  defp number_to_int(num_str) do
    case num_str do
      "one" -> 1
      "two" -> 2
      "three" -> 3
      "four" -> 4
      "five" -> 5
      "six" -> 6
      "seven" -> 7
      "eight" -> 8
      "nine" -> 9
      "1" -> 1
      "2" -> 2
      "3" -> 3
      "4" -> 4
      "5" -> 5
      "6" -> 6
      "7" -> 7
      "8" -> 8
      "9" -> 9
    end  
  end

  def do_string(<<>>, _list) do
    nil
  end

  def do_string(<<ch::utf8, rest::binary>>, list) do
    case Integer.parse(<<ch>>) do
      {n, _} -> n
      :error -> do_string(rest, list)
    end
  end

  def process() do
    {:ok, data} = File.read("input.txt")
    nums = data 
            |> String.split("\n")
            |> Enum.filter(&(String.length(&1) > 0))
            |> Enum.map(fn line ->

              indices = Enum.map(numbers(), fn number ->
                case :binary.match(line, number) do
                  # Get start index 
                  {where, _} -> where
                  :nomatch -> nil
                end
              end)
              {_,min,_} = indices |> Enum.reduce({String.length(line),String.length(line),0}, fn (val,{num_idx, str_idx, i}) ->
                if val && val < num_idx do
                  {val, i, i+1}
                else
                  {num_idx,str_idx,i+1} 
                end
              end)
              {_,max,_} = indices |> Enum.reduce({-1,-1,0}, fn (val,{num_idx, str_idx, i}) ->
                if val && val > num_idx do
                  {val, i, i+1}
                else
                  {num_idx,str_idx,i+1} 
                end
              end)

              10 * number_to_int(Enum.at(numbers(), min)) + number_to_int(Enum.at(numbers(), max))
            end)
            |> IO.inspect
            |> Enum.sum
    nums
  end

  def main() do
    result = process()
    IO.puts result
    {:ok, self()}
  end

  def child_spec(_args) do
    %{
      id: Day1.Part2,
      start: {Day1.Part2, :main, []},
      restart: :temporary,
    }
  end

end
