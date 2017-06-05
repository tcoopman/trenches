defmodule Trenches.Web.GameView do
  use Trenches.Web, :view

  alias Trenches.Game

  def render_games(games) do
    %{
      games: Enum.map(games, &game_json/1)
    }
  end

  defp game_json(%Game{name: name, status: status, created_at: created_at, created_by: created_by, players: players}) do
    %{
      name: name,
      created_at: DateTime.to_iso8601(created_at),
      status: status,
      created_by: created_by.name,
      nb_players: Map.keys(players) |> Enum.count
    }
  end
end