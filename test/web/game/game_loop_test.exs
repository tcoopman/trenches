defmodule Trenches.GameLoopTest do
  use ExUnit.Case, async: true

  alias Trenches.GameLoop
  alias Trenches.Player
  alias Trenches.Unit

  setup do
    player1 = Player.new(1, 1)
    player2 = Player.new(2, 2)
    [player1: player1, player2: player2]
  end

  test "When players have no units a tick doesn't do anything'", context do
    players = %{
      1 => context[:player1],
      2 => context[:player2]
    }
    assert players == GameLoop.tick(players)
  end

  test "2 units collide with same strength, because nobody wins, no money is awarded", context do
    unit1 = %Unit{type: :foo, position: 49, strength: 100, cost: 0, speed: 1}
    unit2 = %Unit{type: :foo, position: 49, strength: 100, cost: 0, speed: 1}
    player1 = %{context[:player1] | units: [unit1]}
    player2 = %{context[:player2] | units: [unit2]}
    players = %{
      1 => player1,
      2 => player2
    }
    new_players = GameLoop.tick(players)

    strength1 = new_players[1].units |> Enum.at(0) |> Map.get(:strength)
    strength2 = new_players[2].units |> Enum.at(0) |> Map.get(:strength)
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