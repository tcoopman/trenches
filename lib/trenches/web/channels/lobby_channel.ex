defmodule Trenches.Web.LobbyChannel do
  use Phoenix.Channel

  alias Trenches.Web.GameView
  alias Trenches.PlayerRepo
  alias Trenches.Lobby

  def join("lobby", _params, socket) do
    games = Lobby.all_games
    games_view = GameView.render("games.json", %{games: games})
    {:ok, games_view, socket}
  end

  def handle_in("create_game", %{"game_name" => game_name}, socket) do
    reply = case Lobby.create_game(game_name) do
      :ok ->
        broadcast! socket, "game_created", %{game_name: game_name}
        {:reply, :ok, socket}
      {:error, reason} -> 
        {:reply, {:error, %{error: reason}}, socket}
    end
  end
end
