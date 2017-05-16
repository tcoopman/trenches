defmodule Trenches.GameLoop do
  alias Trenches.Player
  alias Trenches.Game

  @field_width 100

  def tick(%Game{} = game) do
    game
    |> move_units_and_detect_collisions
    |> fire_units
    |> payout_players
    |> check_winner
  end

  defp move_units_and_detect_collisions(game) do
    game
    |> move_units
    |> detect_collisions
    |> mark_as_dead
  end

  defp fire_units(game) do
    game
  end

  defp payout_players(game) do
    game
  end

  defp check_winner(game) do
    game
  end

  def move_units(game) do
    players = game.players
    |> Map.to_list
    |> Enum.map(fn {id, player} -> 
      {id, Player.move_units(player)}
    end)
    |> Map.new
    %{game | players: players}
  end

  defp mark_as_dead(game) do
    game
  end

  defp detect_collisions(game) do
    players = game.players
    units1 = Map.get(players, 1).units
    units2 = Map.get(players, 2).units

    new_units1 = Enum.map(units1, &collide(&1, units2))
    new_units2 = Enum.map(units2, &collide(&1, units1))

    players = Map.update!(players, 1, fn player -> 
      %{player | units: new_units1}
    end)
    players = Map.update!(players, 2, fn player -> 
      %{player | units: new_units2}
    end)

    %{game | players: players}
  end

  defp collide(unit, other_units) do
    Enum.filter(other_units, fn other_unit -> 
      unit.position + other_unit.position >= @field_width
    end)
    |> Enum.reduce(unit, fn (colliding, unit) -> 
      %{unit | strength: max(unit.strength - colliding.strength, 0)}
    end)
  end
end