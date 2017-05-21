defmodule Trenches.GameServer do
  use GenServer

  alias Trenches.Game
  
  def start_link(%Game{} = game) do
    GenServer.start_link(
      __MODULE__, 
      %{game: game, subscriber: nil}, 
      name: Trenches.service_name({__MODULE__, game.name})
    )
  end

  def open?(name) do
    GenServer.call(name, :open?)
  end

  def name(name) do
    GenServer.call(name, :name)
  end

  def handle_call(:open?, _from, %{game: game} = state), do: {:reply, Game.open?(game), state}

  def handle_call(:name, _from, %{game: game} = state), do: {:reply, game.name, state}

  def handle_info(:tick, %{game: game} = state) do
    state = %{state | game: Game.tick(game)}

    publish(state)
    schedule_tick()
    {:noreply, state}
  end

  defp publish(%{subscriber: nil}), do: nil
  defp publish(%{game: game, subscriber: subscriber}), do: send(subscriber, {:tick, game})

  defp schedule_tick(), do: Process.send_after(self(), :tick, 500)
end