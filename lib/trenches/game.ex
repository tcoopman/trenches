defmodule Trenches.Unit do
  alias __MODULE__
  defstruct [:type, position: 0]

  def move(%Unit{position: position, type: type} = unit) do
    case type do
      "soldier" -> 
        %{unit | position: position + 2}
      "tank" ->
        %{unit | position: position + 1}
    end
  end
end

defmodule Trenches.Player do
  alias __MODULE__
  alias Trenches.Unit

  defstruct [:id, units: []]

  def add_unit(%Player{units: units} = player, %Unit{} = unit) do
    %{player | units: [unit | units]}
  end

  def move_units(%Player{units: units} = player) do
    units = Enum.map(units, fn unit -> 
      Unit.move(unit)
    end)
    %{player | units: units}
  end
end

defmodule Trenches.Game do
  use GenServer

  alias Trenches.Player
  alias Trenches.Unit

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: :game)
  end

  def init(state) do
    state = %{unique_id: 0, players: %{}, subscribers: MapSet.new}
    schedule_work()
    {:ok, state}
  end

  def join() do
    GenServer.call(:game, :join)
  end

  def new_unit(id, type) do
    GenServer.call(:game, {:new_unit, id, type})
  end

  def subscribe(subscriber) do
    GenServer.call(:game, {:subscribe, subscriber})
  end

  # server

  def handle_call(:join, _from, %{unique_id: id, players: players} = state) do
    if id < 2 do
      player = %Player{id: id}
      players = Map.put(players, id, player)
    end
    state = %{state | unique_id: (id+1), players: players}

    {:reply, id, state}
  end

  def handle_call({:subscribe, subscriber}, _from, %{subscribers: subscribers} = state) do
    subscribers = MapSet.put(subscribers, subscriber)
    state = %{state | subscribers: subscribers}
    {:reply, state, state}
  end

  def handle_call({:new_unit, id, type}, _from, %{players: players} = state) do
    players = Map.update!(players, id, fn player -> 
      unit = %Unit{type: type}
      player = Player.add_unit(player, unit)
    end)
    state = %{state | players: players}
    send(self(), :tick)
    {:reply, players, state}
  end

  def handle_info(:tick, %{subscribers: subscribers, players: players} = state) do
    players = tick(players)
    Enum.each(subscribers, fn subscriber -> 
      send(subscriber, {:tick, players})
    end)
    state = %{state | players: players}
    schedule_work()
    {:noreply, state}
  end

  defp tick(players) do
    players
    |> Map.to_list
    |> Enum.map(fn {id, player} -> 
      {id, Player.move_units(player)}
    end)
    |> Map.new
  end

  defp schedule_work() do
    Process.send_after(self(), :tick, 500) # In 2 hours
  end
end