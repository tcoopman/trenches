defmodule Trenches.Game do
  use GenServer

  alias __MODULE__
  alias Trenches.GameLoop
  alias Trenches.Player
  alias Trenches.Unit

  defstruct [status: :not_started, players: %{}, subscriber: nil]

  def start_link(name) do
    GenServer.start_link(__MODULE__, %Game{}, name: name)
  end

  def join(pid, %Player{} = player) do
    GenServer.call(pid, {:join, player})
  end

  def start(pid) do
    GenServer.call(pid, :start)
  end

  def new_unit(pid, id, type) do
    GenServer.call(pid, {:new_unit, id, type})
  end

  def subscribe(pid, subscriber) do
    GenServer.call(pid, {:subscribe, subscriber})
  end

  # server

  def handle_call({:join, player}, _from, %Game{players: players} = state) do
    if Enum.count(players) < 2 do
      players = Map.put(players, player.id, player)
      state = %{state | players: players}
      {:reply, :ok, state}
    else
      {:reply, {:error, "maximum number of players reached"}, state}
    end
  end

  def handle_call(:start, _from, %Game{status: status, players: players} = state) do
    if Enum.count(players) < 2 do
      state = %{state | status: :started}
      schedule_tick
      {:reply, :ok, state}
    else
      {:reply, {:error, "Not enough players for a game"}, state}
    end
  end

  def handle_call({:subscribe, subscriber}, _from, state) do
    state = %{state | subscriber: subscriber}
    {:reply, state, state}
  end

  def handle_call({:new_unit, id, type}, _from, %Game{players: players} = state) do
    players = Map.update!(players, id, fn player -> 
      player = Player.add_unit(player, type)
    end)
    state = %{state | players: players}
    publish(state)
    {:reply, :ok, state}
  end

  def handle_info(:tick, %Game{subscriber: subscriber, players: players} = state) do
    players = GameLoop.tick(players)
    state = %{state | players: players}
    publish(state)
    schedule_tick()
    {:noreply, state}
  end

  defp schedule_tick() do
    Process.send_after(self(), :tick, 500)
  end

  defp publish(%Game{subscriber: subscriber, players: players} = state) do
    if subscriber != nil do
      send(subscriber, {:tick, players})
    end
  end
end