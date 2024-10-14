defmodule Day3.Part2 do
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
  def parse_graphemes(<<>>, %{ number: number, res: res, idx: _idx }, _row) when number == nil do
    res 
  end
  def parse_graphemes(<<>>, %{ number: number, res: res, idx: idx }, _row) when number != nil do
    [ %Number{ number | to: idx-1 } | res ]
  end
  def parse_graphemes(<<ch::utf8, rest::binary>>, %{ number: number, res: res, idx: idx } = state, row) do
    case ch do
      ch when ch in ?0..?9 -> 
        if number == nil do
          parse_graphemes(rest, %{ state | number: %Number{ from: idx, value: <<ch>> }, idx: idx + 1 }, row)
        else
          parse_graphemes(rest, 
            %{ state | 
              number: %Number{ number | value: number.value <> <<ch>> },
              idx: idx + 1}, row)
        end
      ?. ->
        if number do
          parse_graphemes(rest, %{ state | number: nil, res: [%Number{ number | to: idx-1 } | res], idx: idx + 1 }, row)
        else
          parse_graphemes(rest, %{ state | idx: idx + 1 }, row)
        end
      ch -> 
        if number do
          parse_graphemes(rest, %{ state | 
            number: nil,
            res: [%Symbol{ col: idx, row: row, ch: <<ch>> }, %Number{ number | to: idx-1 } | res],
            idx: idx + 1
          }, row)
        else
          parse_graphemes(rest, %{ state | number: nil, res: [%Symbol{ col: idx, row: row, ch: <<ch>> } | res], idx: idx + 1 }, row)
        end
    end 
  end

  def parse_line(line, row) do
    parse_graphemes(line, %{ number: nil, res: [], idx: 0 }, row) # |> IO.inspect
  end

  def parse(lines) do
    lines 
    |> Enum.with_index(fn elem, idx ->
      parse_line(elem, idx)
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

  def merge_grouped_symbols(merged) do
    merged
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.map(fn 
        [] ->
          []
        [ hd | rest ] ->
          rest |> Enum.reduce(hd, fn x, acc -> %Symbol{ acc | numbers: MapSet.union(x.numbers, acc.numbers) } end)
    end)
    |> Enum.into(MapSet.new())
  end

  def find_relevant_symbols_inside_line(line) do
    line
    |> Enum.chunk_every(2, 1) 
    |> Enum.filter(fn
      [%Number{} = num, %Symbol{ ch: "*" } = sym] -> is_symbol_adjacent(num, sym)
      [%Symbol{ ch: "*" } = sym, %Number{} = num] -> is_symbol_adjacent(num, sym)
      _ -> false
    end)
    |> Enum.map(fn
      [%Number{} = num, %Symbol{} = sym] -> %Symbol{ sym | numbers: MapSet.put(sym.numbers, num) }
      [%Symbol{} = sym, %Number{} = num] -> %Symbol{ sym | numbers: MapSet.put(sym.numbers, num) }
    end)
    |> Enum.group_by(&(&1.col))
    |> merge_grouped_symbols()
    # |> IO.inspect
  end

  def find_relevant_numbers([line1 | [line2 | data]], ret, i) do
    ret = for num <- find_relevant_symbols_inside_line(line1), into: ret, do: num # |> IO.inspect
    get_symbol_from_combo = fn 
        %Number{ from: from, to: to } = num, %Symbol{ col: col, ch: "*" } = sym ->
          if col >= from-1 && col <= to+1 do
            %Symbol{ sym | numbers: MapSet.put(sym.numbers, num) }
          end
        %Symbol{ col: col, ch: "*" } = sym, %Number{ from: from, to: to } = num ->
          if col >= from-1 && col <= to+1 do
            %Symbol{ sym | numbers: MapSet.put(sym.numbers, num) }
          end
        _, _ -> nil
    end
    across_lines = for i1 <- line1, i2 <- line2, (combo = get_symbol_from_combo.(i1, i2)) != nil, into: MapSet.new(), do: combo # |> IO.inspect
    ret = MapSet.union(ret, across_lines)
      |> Enum.group_by(&({&1.col, &1.row}))
      |> merge_grouped_symbols()
    # IO.puts "------------------------------------------------------------\n"
    find_relevant_numbers([line2 | data], ret, i + 1)  
  end
  def find_relevant_numbers([line1 | data], ret, i) do
    ret = for num <- find_relevant_symbols_inside_line(line1), into: ret, do: num
    find_relevant_numbers(data, ret, i + 1)
  end
  def find_relevant_numbers([], ret, i) do
    ret 
    |> Enum.filter(fn %Symbol{ numbers: numbers } -> MapSet.size(numbers) === 2 end)
  end


  def process(file) do
    lines = read_lines(file)
    data = parse(lines)# |> IO.inspect
    gears = find_relevant_numbers(data, MapSet.new(), 1) |> IO.inspect
    result = gears
      |> Enum.map(fn sym ->
        Enum.reduce(sym.numbers, 1, fn x, acc -> acc * elem(Integer.parse(x.value), 0) end)
      end)
      |> Enum.sum
    result
  end

  def start(_type, _args) do
    result = process("input2.txt")
    IO.puts "Result = #{result}"
    {:ok, self()}
  end

end
