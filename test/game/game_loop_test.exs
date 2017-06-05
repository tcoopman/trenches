defmodule Trenches.GameLoopTest do
  use ExUnit.Case, async: true

  alias Trenches.Game
  alias Trenches.GameLoop
  alias Trenches.Player
  alias Trenches.Unit

  setup do
    player1 = Player.new(1, 1)
    player2 = Player.new(2, 2)

    game = Game.new("test", player1)
    {:ok, game} = Game.join(game, player1)
    {:ok, game} = Game.join(game, player2)
    [game: game]
  end

  test "When players have no units a tick doesn't do anything'", %{game: game} do
    assert game == GameLoop.tick(game)
  end

  test "2 units collide with same strength, both units have 0 strength left", %{game: game} do
    new_game = game
    |> add_unit_to_player(1, %Unit{type: :foo, position: 49, strength: 100, speed: 1})
    |> add_unit_to_player(2, %Unit{type: :foo, position: 49, strength: 100, speed: 1})
    |> GameLoop.tick

    strength1 = new_game.players[1].units |> Enum.at(0) |> Map.get(:strength)
    strength2 = new_game.players[2].units |> Enum.at(0) |> Map.get(:strength)
    assert 0 = strength1
    assert 0 = strength2
  end

  test "stronger unit collides with weaker unit, the stronger unit wins", %{game: game} do
    new_game = game
    |> add_unit_to_player(1, %Unit{type: :foo, position: 49, strength: 120, speed: 1})
    |> add_unit_to_player(2, %Unit{type: :foo, position: 49, strength: 100, speed: 1})
    |> GameLoop.tick

    strength1 = new_game.players[1].units |> Enum.at(0) |> Map.get(:strength)
    strength2 = new_game.players[2].units |> Enum.at(0) |> Map.get(:strength)
    assert 20 = strength1
    assert 0 = strength2

  end

  test "no collisions but there are units", %{game: game} do
    new_game = game
    |> add_unit_to_player(1, %Unit{type: :foo, position: 40, strength: 100, speed: 1})
    |> add_unit_to_player(2, %Unit{type: :foo, position: 40, strength: 100, speed: 1})
    |> GameLoop.tick

    strength1 = new_game.players[1].units |> Enum.at(0) |> Map.get(:strength)
    strength2 = new_game.players[2].units |> Enum.at(0) |> Map.get(:strength)
    assert 100 = strength1
    assert 100 = strength2
  end

  test "one player has 2 units half the strength of one unit of the other player, all keep 0 strength", %{game: game} do
    new_game = game
    |> add_unit_to_player(1, %Unit{type: :foo, position: 49, strength: 50, speed: 1})
    |> add_unit_to_player(1, %Unit{type: :foo, position: 49, strength: 50, speed: 1})
    |> add_unit_to_player(2, %Unit{type: :foo, position: 49, strength: 100, speed: 1})
    |> GameLoop.tick

    strength1 = new_game.players[1].units |> Enum.at(0) |> Map.get(:strength)
    strength2 = new_game.players[1].units |> Enum.at(1) |> Map.get(:strength)
    strength3 = new_game.players[2].units |> Enum.at(0) |> Map.get(:strength)
    assert 0 = strength1
    assert 0 = strength2
    assert 0 = strength3
  end

  test "multiple units colliding, one survives", %{game: game} do
    new_game = game
    |> add_unit_to_player(1, %Unit{type: :foo, position: 49, strength: 50, speed: 1})
    |> add_unit_to_player(1, %Unit{type: :foo, position: 49, strength: 50, speed: 1})
    |> add_unit_to_player(2, %Unit{type: :foo, position: 49, strength: 50, speed: 1})
    |> add_unit_to_player(2, %Unit{type: :foo, position: 49, strength: 51, speed: 1})
    |> GameLoop.tick

    strength_of_units_eql(new_game.players[1], [0, 0])
    strength_of_units_eql(new_game.players[2], [1, 0])
  end

  test "complex collision scenario", %{game: game} do
    new_game = game
    |> add_unit_to_player(1, %Unit{type: :foo, position: 30, strength: 20, speed: 0})
    |> add_unit_to_player(1, %Unit{type: :foo, position: 50, strength: 20, speed: 0})
    |> add_unit_to_player(1, %Unit{type: :foo, position: 60, strength: 15, speed: 0})
    |> add_unit_to_player(2, %Unit{type: :foo, position: 70, strength: 10, speed: 0})
    |> add_unit_to_player(2, %Unit{type: :foo, position: 40, strength: 20, speed: 0})
    |> add_unit_to_player(2, %Unit{type: :foo, position: 50, strength: 10, speed: 0})
    |> GameLoop.tick

    strength_of_units_eql(new_game.players[1], [0, 15, 20])
    strength_of_units_eql(new_game.players[2], [0, 0, 20])
  end

  defp add_unit_to_player(%Game{} = game, player_id, unit) do
    players = Map.update!(game.players, player_id, fn player -> 
      %{player | units: [unit | player.units]}
    end)
    %{game | players: players}
  end

  defp strength_of_units_eql(player, expected) do
    actual_units = player.units |> Enum.map(fn u -> u.strength end) |> MapSet.new
    assert actual_units == MapSet.new(expected)
  end
end