defmodule Day3.Part1 do
  use Application
  alias Day3.Number
  alias Day3.Symbol

  defp read_lines(file) do
    {:ok, data} = File.read(file)
    data
    |> String.split("\n")
    |> Enum.filter(&(String.length(&1) > 0))
  end

  defp parse_graphemes(<<>>, %{ res: res }) do
    res 
  end
  
  defp parse_graphemes(<<ch::utf8, rest::binary>>, %{ number: number, res: res, idx: idx } = state) do
    case ch do
      ch when ch in ?0..?9 -> 
        if number == nil do
          parse_graphemes(rest, %{ state | number: %Number{ from: idx, value: <<ch>> }, idx: idx + 1 })
        else
          parse_graphemes(rest, 
            %{ state | 
              number: %Number{ number | value: number.value <> <<ch>> },
              idx: idx + 1})
        end
      ?. ->
        if number do
          parse_graphemes(rest, %{ state | number: nil, res: res ++ [%Number{ number | to: idx }], idx: idx + 1 })
        else
          parse_graphemes(rest, %{ state | idx: idx + 1 })
        end
      _ -> 
        if number do
          parse_graphemes(rest, %{ state | 
            number: nil,
            res: res ++ [%Number{ number | to: idx }, %Symbol{ col: idx }],
            idx: idx + 1
          })
        else
          parse_graphemes(rest, %{ state | number: nil, res: res ++ [%Symbol{ col: idx }], idx: idx + 1 })
        end
    end 
  end

  defp parse_line(line) do
    parse_graphemes(line, %{ number: nil, res: [], idx: 0 }) # |> IO.inspect
  end

  defp parse(lines) do
    lines 
    |> Enum.map(fn line ->
      parse_line(line)
    end)
  end

  defp is_symbol_adjacent(%Symbol{ col: col }, %Number{ from: from, to: to }) do
    col >= from && col <= to 
  end
  defp is_symbol_adjacent(%Number{ from: from, to: to }, %Symbol{ col: col }) do
    col >= from && col <= to 
  end
  defp is_symbol_adjacent(_arg1, _arg2) do
    false
  end

  defp find_relevant_numbers_inside_line(line) do
    line
    |> Enum.chunk_every(2, 1) 
    |> Enum.filter(fn
      [%Number{} = num, %Symbol{} = sym] -> is_symbol_adjacent(num, sym)
      [%Symbol{} = sym, %Number{} = num] -> is_symbol_adjacent(num, sym)
      _ -> false
    end)
    |> Enum.map(fn
      [%Number{} = num, %Symbol{}] -> num
      [%Symbol{}, %Number{} = num] -> num
    end)
    |> IO.inspect
  end

  defp find_relevant_numbers([line1 | [line2 | data]], ret) do
    ret = for num <- find_relevant_numbers_inside_line(line1), into: ret, do: num
    get_num_from_combo = fn 
        %Number{ from: from, to: to } = num, %Symbol{ col: col } ->
          if col >= from-1 && col <= to+1 do
            num
          end
        %Symbol{ col: col }, %Number{ from: from, to: to } = num ->
          if col >= from-1 && col <= to+1 do
            num
          end
        _, _ -> nil
    end
    ret = for i1 <- line1, i2 <- line2, (combo = get_num_from_combo.(i1, i2)) != nil, into: ret, do: combo
    find_relevant_numbers([line2 | data], ret)  
  end
  defp find_relevant_numbers([line1 | data], ret) do
    ret = for num <- find_relevant_numbers_inside_line(line1), into: ret, do: num
    find_relevant_numbers(data, ret)
  end
  defp find_relevant_numbers([], ret) do
    ret 
  end


  defp process(file) do
    lines = read_lines(file)
    data = parse(lines) 
    numbers = find_relevant_numbers(data, MapSet.new()) |> IO.inspect
    numbers |> Enum.reduce(0, fn x, acc -> acc + elem(Integer.parse(x.value), 0) end)
  end

  def start(_type, _args) do
    result = process("input.txt")
    IO.puts "Result = #{result}"
    {:ok, self()}
  end

end
