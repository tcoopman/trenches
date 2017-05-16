defmodule Trenches.GameLoopTest do
  use ExUnit.Case, async: true

  alias Trenches.Game
  alias Trenches.GameLoop
  alias Trenches.Player
  alias Trenches.Unit

  setup do
    player1 = Player.new(1, 1)
    player2 = Player.new(2, 2)

    game = Game.new("test")
    {:ok, game} = Game.join(game, player1)
    {:ok, game} = Game.join(game, player2)
    [game: game]
  end

  test "When players have no units a tick doesn't do anything'", %{game: game} do
    assert game == GameLoop.tick(game)
  end

  test "2 units collide with same strength, both units have 0 strength left", %{game: game} do
    unit1 = %Unit{type: :foo, position: 49, strength: 100, cost: 0, speed: 1}
    unit2 = %Unit{type: :foo, position: 49, strength: 100, cost: 0, speed: 1}

    new_game = game
    |> add_unit_to_player(1, unit1)
    |> add_unit_to_player(2, unit2)
    |> GameLoop.tick

    strength1 = new_game.players[1].units |> Enum.at(0) |> Map.get(:strength)
    strength2 = new_game.players[2].units |> Enum.at(0) |> Map.get(:strength)
    assert 0 = strength1
    assert 0 = strength2
  end

  test "stronger unit collides with weaker unit, the stronger unit wins", %{game: game} do
    unit1 = %Unit{type: :foo, position: 49, strength: 120, cost: 0, speed: 1}
    unit2 = %Unit{type: :foo, position: 49, strength: 100, cost: 0, speed: 1}
    
    new_game = game
    |> add_unit_to_player(1, unit1)
    |> add_unit_to_player(2, unit2)
    |> GameLoop.tick

    strength1 = new_game.players[1].units |> Enum.at(0) |> Map.get(:strength)
    strength2 = new_game.players[2].units |> Enum.at(0) |> Map.get(:strength)
    assert 20 = strength1
    assert 0 = strength2

  end

  test "no collisions but there are units", %{game: game} do
    unit1 = %Unit{type: :foo, position: 40, strength: 100, cost: 0, speed: 1}
    unit2 = %Unit{type: :foo, position: 40, strength: 100, cost: 0, speed: 1}

    new_game = game
    |> add_unit_to_player(1, unit1)
    |> add_unit_to_player(2, unit2)
    |> GameLoop.tick

    strength1 = new_game.players[1].units |> Enum.at(0) |> Map.get(:strength)
    strength2 = new_game.players[2].units |> Enum.at(0) |> Map.get(:strength)
    assert 100 = strength1
    assert 100 = strength2
  end

  test "more then each one unit" do
    
  end

  defp add_unit_to_player(%Game{} = game, player_id, unit) do
    players = Map.update!(game.players, player_id, fn player -> 
      %{player | units: [unit | player.units]}
    end)
    %{game | players: players}
  end
end