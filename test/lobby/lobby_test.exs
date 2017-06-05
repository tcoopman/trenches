defmodule Trenches.LobbyTest do
  use ExUnit.Case

  alias Trenches.Lobby
  alias Trenches.Game

  test "A scenario" do
    {:ok, %Game{name: "game 1"}} = Lobby.create_game("game 1")
    {:error, :duplicate_name} = Lobby.create_game("game 1")

    assert [%Game{name: "game 1"}] = Lobby.all_games()

    {:ok, %Game{name: "game 2"}} = Lobby.create_game("game 2")

    assert [%Game{name: "game 1"}, %Game{name: "game 2"}] = Lobby.all_games()

    assert {:ok, %Game{name: "game 1"}} = Lobby.get("game 1")
  end

  test "get when there is no game" do
    assert {:error, _} = Lobby.get("unknown")
  end
end