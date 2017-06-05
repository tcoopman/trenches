defmodule Trenches.Web.GameView do
  alias Trenches.Game

  def render("games.json", %{games: games}) do
    %{
      games: Enum.map(games, &game_json/1)
    }
  end

  defp game_json(%Game{name: name, status: status, created_at: created_at}) do
    %{
      name: name,
      created_at: DateTime.to_iso8601(created_at),
      status: status
    }
  end
end