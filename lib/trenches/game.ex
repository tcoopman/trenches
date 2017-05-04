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
      state = %{state | unique_id: (id+1), players: players}
      {:reply, {:ok, id}, state}
    else
      {:reply, {:error, "maximum number of players reached"}, state}
    end
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