defmodule Day2.Application do
  use Application

  def start(_type, _args) do
    Day2.Supervisor.start_link(name: Day2.Supervisor)
  end
end
