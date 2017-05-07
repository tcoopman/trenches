defmodule Trenches.Web.GameChannel do
  use Phoenix.Channel

  alias Trenches.Game
  alias Trenches.Lobby
  alias Trenches.PlayerRepo

  def join("game:" <> game_name, %{"player_id" => player_id}, socket) do
    with {:ok, game_id} <- Lobby.get(game_name),
         {:ok, player} <- PlayerRepo.get(player_id),
         :ok <- Game.join(game_id, player)
    do
      socket = assign(socket, :game_name, game_name)
      {:ok, socket}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, "Unknown problem"}
    end
  end

  def handle_in("start", _, socket) do
    game_name = socket.assigns[:game_name]
    with {:ok, game_id} <- Lobby.get(game_name),
         :ok <- Game.start(game_id)
    do
      {:reply, :ok, socket}
    else
      {:error, message} -> {:reply, {:error, message}, socket}
      _ -> {:reply, {:error, "Unknown problem"}, socket}
    end
  end

  def handle_in("new_unit", %{"type" => type, "id" => id}, socket) do
    game_name = socket.assigns[:game_name]
    with {:ok, game_id} <- Lobby.get(game_name),
         :ok <- Game.new_unit(game_id, id, type)
    do
      {:reply, :ok, socket}
    else
      {:error, message} -> {:reply, {:error, message}, socket}
      _ -> {:reply, {:error, "Unknown problem"}, socket}
    end
  end

  def handle_info({:tick, players}, socket) do
    broadcast socket, "tick", %{players: Map.values(players)}
    {:noreply, socket}
  end
end
