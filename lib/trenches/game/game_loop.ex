defmodule Trenches.GameLoop do
  alias Trenches.Player

  @field_width 100

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
    units1 = Map.get(players, 1).units
    units2 = Map.get(players, 2).units

    new_units = find_collisions(units1, units2)
    |> update_collisions

    units1 = Enum.map(new_units, fn {u1, _} -> u1 end)
    units2 = Enum.map(new_units, fn {_, u2} -> u2 end)

    players = Map.update!(players, 1, fn player -> 
      %{player | units: units1}
    end)
    players = Map.update!(players, 2, fn player -> 
      %{player | units: units2}
    end)

    players
  end

  defp find_collisions(units1, units2) do
    zip_all(units1, units2)
    |> Enum.filter(fn {u1, u2} -> 
      u1.position + u2.position >= @field_width
    end)
  end

  defp zip_all(list1, list2) do
    Enum.flat_map(list1, fn item1 -> 
      Enum.map(list2, fn item2 -> 
        {item1, item2}
      end)
    end)
  end

  defp update_collisions(collisions) do
    Enum.map(collisions, fn {u1, u2} -> 
      updated_u1 = %{u1 | strength: max(u1.strength - u2.strength, 0)}
      updated_u2 = %{u2 | strength: max(u2.strength - u1.strength, 0)}
      {updated_u1, updated_u2}
    end)
  end
end