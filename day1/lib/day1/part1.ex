defmodule Day1.Part1 do
  # defp next(sum, <<>>) do
  #   sum
  # end
  #
  # defp next(sum, <<?(, rest::binary>>) do
  #   next(sum + 1, rest)
  # end
  #
  # defp next(sum, <<?), rest::binary>>) do
  #   next(sum - 1, rest)
  # end
  #
  # def process() do
  #   file = File.open!("input.txt") 
  #   data = IO.read(file, :line)
  #   next(0, data) 
  # end

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

              first = do_string(line, [])
              second = do_string(String.reverse(line), [])

              10 * first + second
            end)
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
      id: Day1.Part1,
      start: {Day1.Part1, :main, []},
      restart: :temporary,
    }
  end

end
