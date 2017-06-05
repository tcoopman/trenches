defmodule Trenches.GameTest do
  use ExUnit.Case, async: true

  alias Trenches.{Game, Player}

  describe "Joining a game" do
    test "Maximum 2 players can join a game" do
      player1 = Player.new("1", 1)
      player2 = Player.new("2", 2)
      player3 = Player.new("3", 3)

      game = Game.new("test", player1)
      {:ok, game} = Game.join(game, player1)
      {:ok, game} = Game.join(game, player2)
      {:error, _} = Game.join(game, player3)
    end

    test "When 2 players joined, the status changes" do
      player1 = Player.new("1", 1)
      player2 = Player.new("2", 2)

      game = Game.new("test", player1)
      assert game.status == :waiting_for_players
      {:ok, game} = Game.join(game, player1)
      assert game.status == :waiting_for_players
      {:ok, game} = Game.join(game, player2)
      assert game.status == :countdown_to_start
    end

    test "The same player cannot join twice" do
      player1 = Player.new("1", 1)
      
      game = Game.new("test", player1)
      {:ok, game} = Game.join(game, player1)
      {:error, _} = Game.join(game, player1)
    end
  end

end