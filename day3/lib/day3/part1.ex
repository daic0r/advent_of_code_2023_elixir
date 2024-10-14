defmodule Day3.Part1 do
  use Application
  alias Day3.Number
  alias Day3.Symbol

  def read_lines(file) do
    {:ok, data} = File.read(file)
    data
    |> String.split("\n")
    |> Enum.filter(&(String.length(&1) > 0))
  end

  # Behold, elements are added to res in reverse, so that we can prepend for 
  # efficiency
  def parse_graphemes(<<>>, %{ number: number, res: res, idx: _idx }) when number == nil do
    res 
  end
  def parse_graphemes(<<>>, %{ number: number, res: res, idx: idx }) when number != nil do
    [ %Number{ number | to: idx-1 } | res ]
  end
  def parse_graphemes(<<ch::utf8, rest::binary>>, %{ number: number, res: res, idx: idx } = state) do
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
          parse_graphemes(rest, %{ state | number: nil, res: [%Number{ number | to: idx-1 } | res], idx: idx + 1 })
        else
          parse_graphemes(rest, %{ state | idx: idx + 1 })
        end
      _ -> 
        if number do
          parse_graphemes(rest, %{ state | 
            number: nil,
            res: [%Symbol{ col: idx }, %Number{ number | to: idx-1 } | res],
            idx: idx + 1
          })
        else
          parse_graphemes(rest, %{ state | number: nil, res: [%Symbol{ col: idx } | res], idx: idx + 1 })
        end
    end 
  end

  def parse_line(line) do
    parse_graphemes(line, %{ number: nil, res: [], idx: 0 }) # |> IO.inspect
  end

  def parse(lines) do
    lines 
    |> Enum.map(fn line ->
      parse_line(line)
    end)
  end

  # def is_symbol_adjacent(%Symbol{ col: col }, %Number{ from: from, to: to }) do
  #   col === from-1 or col === to+1
  # end
  def is_symbol_adjacent(%Number{ from: from, to: to }, %Symbol{ col: col }) do
    col === from-1 or col === to+1
  end
  def is_symbol_adjacent(_arg1, _arg2) do
    false
  end

  def find_relevant_numbers_inside_line(line) do
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
    # |> IO.inspect
  end

  def find_relevant_numbers([line1 | [line2 | data]], ret, i) do
    ret = for num <- find_relevant_numbers_inside_line(line1), into: ret, do: num |> IO.inspect
    IO.puts "\n"
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
    ret = for i1 <- line1, i2 <- line2, (combo = get_num_from_combo.(i1, i2)) != nil, into: ret, do: combo |> IO.inspect
    IO.puts "------------------------------------------------------------\n"
    find_relevant_numbers([line2 | data], ret, i + 1)  
  end
  def find_relevant_numbers([line1 | data], ret, i) do
    ret = for num <- find_relevant_numbers_inside_line(line1), into: ret, do: num
    find_relevant_numbers(data, ret, i + 1)
  end
  def find_relevant_numbers([], ret, i) do
    ret 
  end


  def process(file) do
    lines = read_lines(file)
    data = parse(lines)# |> IO.inspect
    numbers = find_relevant_numbers(data, MapSet.new(), 1)# |> IO.inspect
    numbers |> Enum.reduce(0, fn x, acc -> acc + elem(Integer.parse(x.value), 0) end)
  end

  def start(_type, _args) do
    result = process("input2.txt")
    IO.puts "Result = #{result}"
    {:ok, self()}
  end

end
