defmodule Day3.Part1Test do
  use ExUnit.Case
  doctest Day3.Part1

  test "find numbers touching symbols across lines" do
    line1 = "418..*..57........125...141.........965..382..177.......*.....-.......390.....801....*.....&...659....406....912........614.448............."
    line2 = "....926...................*.#.........%.................517......*......%........%.301............$........*.......694......$......&........"
    data = [ Day3.Part1.parse_line(line1), Day3.Part1.parse_line(line2) ]

    ret = Day3.Part1.find_relevant_numbers(data, MapSet.new(), 1)
    assert ret == MapSet.new([ 
      %Day3.Number{ from: 4, to: 6, value: "926" },
      %Day3.Number{ value: "141", from: 24, to: 26 },
      %Day3.Number{ value: "965", from: 36, to: 38 },
      %Day3.Number{ value: "517", from: 56, to: 58 },
      %Day3.Number{ value: "390", from: 70, to: 72 },
      %Day3.Number{ value: "801", from: 78, to: 80 },
      %Day3.Number{ value: "301", from: 83, to: 85 },
      %Day3.Number{ value: "659", from: 95, to: 97 },
      %Day3.Number{ value: "448", from: 124, to: 126 },
    ])


    line1 = ".......&...625......*.........7*121...........494......=...8......*....@..............................*..........*......998*973.......$....."
    line2 = "....691............614...795..........152............120...........238..496...........................477..........................994......"
    data = [ Day3.Part1.parse_line(line1), Day3.Part1.parse_line(line2) ]

    ret = Day3.Part1.find_relevant_numbers(data, MapSet.new(), 1)
    assert ret == MapSet.new([ 
      %Day3.Number{ value: "691", from: 4, to: 6 },
      %Day3.Number{ value: "614", from: 19, to: 21 },
      %Day3.Number{ value: "7", from: 30, to: 30 },
      %Day3.Number{ value: "121", from: 32, to: 34 },
      %Day3.Number{ value: "120", from: 53, to: 55 },
      %Day3.Number{ value: "238", from: 67, to: 69 },
      %Day3.Number{ value: "496", from: 72, to: 74 },
      %Day3.Number{ value: "477", from: 102, to: 104 },
      %Day3.Number{ value: "998", from: 120, to: 122 },
      %Day3.Number{ value: "973", from: 124, to: 126 },
      %Day3.Number{ value: "994", from: 131, to: 133 },
    ])
  end
end
