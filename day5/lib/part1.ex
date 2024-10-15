defmodule Day5.Part1 do
  alias Day5.{AssignmentMap, Range}

  def parse(file) do
    data = File.read!(file)  

    sections = data |> String.split("\n\n")

    [seeds | sections] = sections
    [seeds] = Regex.run(~r/seeds: (.+)/, seeds, capture: :all_but_first)
    seeds =
      seeds
      |> String.split(" ")
      |> Enum.map(& elem(Integer.parse(&1), 0))

    assignments = sections
      |> Enum.map(fn section ->
        lines = String.split(section, "\n")
        
        [hd | ranges] = lines
        
        [from, to] = Regex.run(~r/(.+)-to-(.+) map/, hd, capture: :all_but_first)
        ranges = ranges
          |> Enum.filter(& String.length(&1) > 0)
          |> Enum.map(fn range ->
            [to_start, from_start, length] = String.split(range, " ")
            %Range{ src_start: elem(Integer.parse(from_start), 0),
                    dest_start: elem(Integer.parse(to_start), 0),
                    length: elem(Integer.parse(length), 0) }
          end)

        %AssignmentMap{ from: from, to: to, ranges: ranges }
      end)

    assignments = assignments
      |> Enum.map(fn assignment ->
        { assignment.from, assignment }
      end)
      |> Enum.into(%{})
    
    {seeds, assignments} 
  end

  def trace_seed(data, category, assignments) do
    map = assignments[category] 
    if !map do
      data
    else
      next = AssignmentMap.get_mapping(map, data)   
      trace_seed(next, map.to, assignments)
    end
  end

  def process(file) do
    {seeds, assignments} = parse(file)
    IO.inspect(assignments)
    locations = seeds
      |> Enum.map(fn seed -> trace_seed(seed, "seed", assignments) end)
    IO.inspect(locations, charlists: :as_lists)
    Enum.min(locations)
  end

  def main() do
    result = process("input2.txt")
    IO.puts "Result = #{result}"
  end

  def start_link do
    main()

    {:ok, self()}
  end
end
