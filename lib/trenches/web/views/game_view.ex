defmodule Trenches.Web.GameView do
  use Trenches.Web, :view

  alias Trenches.Game

  def render_games(games) do
    %{
      games: Enum.map(games, &render_game/1)
    }
  end

  def render_game(%Game{name: name, status: status, created_at: created_at, created_by: created_by, players: players}) do
    %{
      name: name,
      created_at: DateTime.to_iso8601(created_at),
      status: status,
      created_by: created_by.name,
      nb_players: Map.keys(players) |> Enum.count
    }
  end

  def render_full_game(%Game{} = game) do
    game
    |> render_game
    |> Map.put(:players, game.players)
    |> Map.put(:countdown_clock, game.countdown_clock)
  end
end