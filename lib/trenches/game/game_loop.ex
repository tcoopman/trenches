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

    sorted_units = fn player_id -> 
      Map.get(players, player_id).units
      |> Enum.sort_by(fn u -> u.position end)
      |> Enum.reverse
    end

    units1 = sorted_units.(1)
    units2 = sorted_units.(2)

    {new_units1, new_units2} = collide(units1, units2)

    players = Map.update!(players, 1, fn player -> 
      %{player | units: new_units1}
    end)
    players = Map.update!(players, 2, fn player -> 
      %{player | units: new_units2}
    end)

    %{game | players: players}
  end

  defp collide(old1, old2, new1 \\ [], new2 \\ [])
  defp collide([], old2, new1, new2), do: {new1, old2 ++ new2}
  defp collide(old1, [], new1, new2), do: {old1 ++ new1, new2}
  defp collide([u1 | tl1], [u2 | tl2], new1, new2) do
    if u1.position + u2.position >= @field_width do
      new_u1 = %{u1 | strength: max(u1.strength - u2.strength, 0)}
      new_u2 = %{u2 | strength: max(u2.strength - u1.strength, 0)}
      
      {tl1, new1} = if new_u1.strength == 0, do: {tl1, [new_u1 | new1]}, else: {[new_u1 | tl1], new1}
      {tl2, new2} = if new_u2.strength == 0, do: {tl2, [new_u2 | new2]}, else: {[new_u2 | tl2], new2}

      collide(tl1, tl2, new1, new2)
    else
      {[u1 | tl1] ++ new1, [u2 | tl2] ++ new2}
    end
  end
end