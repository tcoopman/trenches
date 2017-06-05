defmodule Trenches.GameServer do
  use GenServer

  alias Trenches.Game
  alias Trenches.Player
  
  def start_link(%Game{} = game) do
    GenServer.start_link(
      __MODULE__, 
      %{game: game, subscriber: nil}, 
      name: Trenches.service_name({__MODULE__, game.name})
    )
  end

  # Client

  def game(name), do: GenServer.call(name, :game)
  def join(name, player), do: GenServer.call(name, {:join, player})

  # Server

  def handle_call(:game, _from, %{game: game} = state), do: {:reply, game, state}
  
  def handle_call({:join, %Player{} = player}, _from, %{game: game} = state) do
    case Game.join(game, player) do
      {:ok, game} -> {:reply, :ok, %{state | game: game}}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

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