defmodule Trenches.Web.LobbyChannel do
  use Phoenix.Channel

  alias Trenches.PlayerRepo
  alias Trenches.Lobby

  def join("lobby", _params, socket) do
    games = Lobby.all_open_games
    {:ok, %{games: games}, socket}
  end

  def handle_in("create_game", %{"game_name" => game_name}, socket) do
    reply = case Lobby.create_game(game_name) do
      :ok ->
        broadcast! socket, "game_created", %{game_name: game_name}
        IO.inspect "broadcasted"
        IO.inspect game_name
        {:reply, :ok, socket}
      {:error, reason} -> 
        {:reply, {:error, %{error: reason}}, socket}
    end
  end
end
