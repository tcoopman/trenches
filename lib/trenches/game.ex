defmodule Trenches.Unit do
  alias __MODULE__
  defstruct [:type, position: 0, strength: 0, cost: 0, speed: 0]

  def new("soldier") do
    %Unit{type: :soldier, position: 0, strength: 100, cost: 300, speed: 2}
  end
  def new("tank") do
    %Unit{type: :tank, position: 0, strength: 500, cost: 500, speed: 1}
  end
  def new(_), do: :error

  def move(%Unit{position: position, speed: speed} = unit) do
    %{unit | position: position + speed}
  end
end

defmodule Trenches.Player do
  alias __MODULE__
  alias Trenches.Unit

  defstruct [:id, units: [], hitpoints: 100, money: 1000]

  def add_unit(%Player{units: units} = player, unit_type) do
    case Unit.new(unit_type) do
      %Unit{} = unit ->
        money_left_after_unit = player.money - unit.cost
        case money_left_after_unit < 0 do
          true -> player
          false ->
            %{player | units: [unit | units], money: money_left_after_unit}
        end
      :error -> 
        player
    end
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
    state = %{unique_id: 0, players: %{}, subscriber: nil}
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

  def handle_call({:subscribe, subscriber}, _from, state) do
    state = %{state | subscriber: subscriber}
    {:reply, state, state}
  end

  def handle_call({:new_unit, id, type}, _from, %{players: players} = state) do
    players = Map.update!(players, id, fn player -> 
      player = Player.add_unit(player, type)
    end)
    state = %{state | players: players}
    publish(state)
    {:reply, players, state}
  end

  def handle_info(:tick, %{subscriber: subscriber, players: players} = state) do
    players = tick(players)
    state = %{state | players: players}
    publish(state)
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
    Process.send_after(self(), :tick, 500)
  end

  defp publish(%{subscriber: subscriber, players: players} = state) do
    if subscriber != nil do
      send(subscriber, {:tick, players})
    end
  end
end