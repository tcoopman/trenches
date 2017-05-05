defmodule Trenches.Web.GameChannel do
  use Phoenix.Channel

  alias Trenches.Game
  alias Trenches.PlayerRepo

  def join("game:" <> game_id, %{"player_id" => player_id}, socket) do
    case PlayerRepo.get(player_id) do
      {:ok, player} ->
        Game.subscribe(self())
        case Game.join(player) do
          {:error, message} ->
            {:error, message}
          :ok ->
            {:ok, socket}
        end
      :not_found ->
        {:error, "Player id not found"}
    end
  end

  def handle_in("start", _, socket) do
    case Game.start do
      :ok -> {:reply, :ok, socket}
      {:error, message} -> {:reply, {:error, message}, socket}
    end
  end

  def handle_in("new_unit", %{"type" => type, "id" => id}, socket) do
    Game.new_unit(id, type)
    {:reply, :ok, socket}
  end

  def handle_info({:tick, players}, socket) do
    broadcast socket, "tick", %{players: Map.values(players)}
    {:noreply, socket}
  end
end
