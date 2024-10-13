defmodule Day1.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts)
  end

  @impl true
  def init(_args) do
    children = [
      #{Day1.Part1, name: Day1.Part1}
      {Day1.Part2, name: Day1.Part2}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
