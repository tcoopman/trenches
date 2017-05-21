defmodule Trenches.LobbyTest do
  use ExUnit.Case

  alias Trenches.Lobby

  test "A scenario" do
    :ok = Lobby.create_game("game 1")
    {:error, :duplicate_name} = Lobby.create_game("game 1")

    assert ["game 1"] == Lobby.all_open_games()

    :ok = Lobby.create_game("game 2")

    assert ["game 1", "game 2"] == Lobby.all_open_games()
  end
end