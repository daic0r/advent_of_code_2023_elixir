defmodule Day1.Application do
  use Application

  @impl true
  def start(_type, _args) do
    Day1.Supervisor.start_link(name: Day1.Supervisor)
  end

  

end
