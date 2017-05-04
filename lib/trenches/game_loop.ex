defmodule Trenches.GameLoop do
  alias Trenches.Player

  def tick(players) do
    players
    |> move_units
    |> fire_units
    |> mark_as_dead
    |> detect_collisions
    |> mark_as_dead
    |> payout_players
    |> check_winner
  end

  defp move_units(players) do
    players
    |> Map.to_list
    |> Enum.map(fn {id, player} -> 
      {id, Player.move_units(player)}
    end)
    |> Map.new
  end

  defp fire_units(players) do
    players
  end

  defp mark_as_dead(players) do
    players
  end

  defp detect_collisions(players) do
    players
  end

  defp payout_players(players) do
    players
  end

  defp check_winner(players) do
    players
  end
end