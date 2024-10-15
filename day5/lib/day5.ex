defmodule Day5 do
  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [
        %{id: Day5.Part1, start: {Day5.Part1, :start_link, []}}
      ],
      strategy: :one_for_one
    )
  end
end
