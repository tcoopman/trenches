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

  test "2 units collide with same strength, because nobody wins, no money is awarded", %{game: game} do
    unit1 = %Unit{type: :foo, position: 49, strength: 100, cost: 0, speed: 1}
    unit2 = %Unit{type: :foo, position: 49, strength: 100, cost: 0, speed: 1}
    players = game.players
    players = Map.update!(players, 1, fn player -> 
      %{player | units: [unit1]}
    end)
    players = Map.update!(players, 2, fn player -> 
      %{player | units: [unit2]}
    end)
    new_game = GameLoop.tick(%{game | players: players})

    strength1 = new_game.players[1].units |> Enum.at(0) |> Map.get(:strength)
    strength2 = new_game.players[2].units |> Enum.at(0) |> Map.get(:strength)
    assert 0 = strength1
    assert 0 = strength2
  end

  test "stronger unit collides, money is awarded" do

  end

  test "no collisions but there are units" do

  end

  test "more then each one unit" do
    
  end
end