defmodule Trenches.Player do
  defstruct [:id, units: []]
end
defmodule Trenches.Game do
  use GenServer

  alias Trenches.Player

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: :game)
  end

  def init(state) do
    state = %{unique_id: 0, players: [], subscribers: MapSet.new}
    schedule_work()
    {:ok, state}
  end

  def join() do
    GenServer.call(:game, :join)
  end

  def new_unit(id, type) do

  end

  def subscribe(subscriber) do
    GenServer.call(:game, {:subscribe, subscriber})
  end

  # server

  def handle_call(:join, _from, %{unique_id: id, players: players} = state) do
    if id < 2 do
      player = %Player{id: id}
    end
    state = %{state | unique_id: (id+1), players: ([player | players])}

    {:reply, id, state}
  end

  def handle_call({:subscribe, subscriber}, _from, %{subscribers: subscribers} = state) do
    subscribers = MapSet.put(subscribers, subscriber)
    state = %{state | subscribers: subscribers}
    {:reply, state, state}
  end

  def handle_info(:tick, %{subscribers: subscribers, players: players} = state) do
    Enum.each(subscribers, fn subscriber -> 
      send(subscriber, {:tick, players})
    end)
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :tick, 500) # In 2 hours
  end
end