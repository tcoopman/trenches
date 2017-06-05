defmodule Trenches.LobbyTest do
  use ExUnit.Case

  alias Trenches.Lobby
  alias Trenches.Game

  test "A scenario" do
    :ok = Lobby.create_game("game 1")
    {:error, :duplicate_name} = Lobby.create_game("game 1")

    assert [%Game{name: "game 1"}] = Lobby.all_games()

    :ok = Lobby.create_game("game 2")

    assert [%Game{name: "game 1"}, %Game{name: "game 2"}] = Lobby.all_games()
  end
end