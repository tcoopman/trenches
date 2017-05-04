defmodule Trenches.GameLoop do
  alias Trenches.Player

  def tick(players) do
    players
    |> move_units_and_detect_collisions
    |> fire_units
    |> payout_players
    |> check_winner
  end

  defp move_units_and_detect_collisions(players) do
    players
    |> move_units
    |> detect_collisions
    |> mark_as_dead
  end

  defp fire_units(players) do
    players
  end

  defp payout_players(players) do
    players
  end

  defp check_winner(players) do
    players
  end

  def move_units(players) do
    players
    |> Map.to_list
    |> Enum.map(fn {id, player} -> 
      {id, Player.move_units(player)}
    end)
    |> Map.new
  end

  defp mark_as_dead(players) do
    players
  end

  defp detect_collisions(players) do
    players
  end
end