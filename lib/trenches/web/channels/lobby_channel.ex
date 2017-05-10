defmodule Trenches.Web.LobbyChannel do
  use Phoenix.Channel

  alias Trenches.PlayerRepo
  alias Trenches.Lobby

  def join("lobby", %{"player_id" => player_id}, socket) do
    with {:ok, player} <- PlayerRepo.get(player_id)
    do
      socket =assign(socket, :player_id, player_id)
      {:ok, socket}
    end
  end

  def handle_in("open_game", %{"game_name" => game_name}, socket) do
    player_id = socket.assigns[:player_id]
    with {:ok, player} <- PlayerRepo.get(player_id),
         :ok <- Lobby.open_game(game_name)
    do
      {:reply, :ok, socket}
    else
      {:error, reason} -> {:reply, {:error, reason}, socket}
      _ -> {:reply, {:error, "Unknown problem"}, socket}
    end

  end
end