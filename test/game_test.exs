defmodule Trenches.GameTest do
  use ExUnit.Case, async: true

  alias Trenches.{Game, Player}

  describe "Joining a game" do
    test "Maximum 2 players can join a game" do
      player1 = Player.new("1", 1)
      player2 = Player.new("2", 2)
      player3 = Player.new("3", 3)

      game = Game.new("test")
      {:ok, game} = Game.join(game, player1)
      {:ok, game} = Game.join(game, player2)
      {:error, _} = Game.join(game, player3)
    end

    test "The same player cannot join twice" do
      player1 = Player.new("1", 1)
      
      game = Game.new("test")
      {:ok, game} = Game.join(game, player1)
      {:error, _} = Game.join(game, player1)
    end
  end

end