defmodule Trenches.Player do
  defstruct [:id, units: []]
end
defmodule Trenches.Game do
  use GenServer

  alias Trenches.Player

  def start_link() do
    GenServer.start_link(__MODULE__, %{unique_id: 0, players: []}, name: :game)
  end

  def join() do
    GenServer.call(:game, :join)
  end

  def new_unit(id, type) do

  end

  # server

  def handle_call(:join, _from, %{unique_id: id, players: players} = state) do
    if id < 2 do
      player = %Player{id: id}
    end
    state = %{unique_id: (id+1), players: ([player | players])}

    {:reply, id, state}
  end
end