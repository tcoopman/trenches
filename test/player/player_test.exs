defmodule Trenches.PlayerTest do
  use ExUnit.Case, async: true

  alias Trenches.Player
  alias Trenches.Unit

  setup do
    [player: Player.new(1, 'player 1'), soldier: Unit.new("soldier")]
  end

  test "player starts with 1000 credits and no units", %{player: player} do
    assert player.id == 1
    assert player.name == 'player 1'
    assert player.units == []
    assert player.money == 1000
  end

  test "buying exact amount", %{player: player} do
    player = %{player | money: 300}
    player = Player.add_unit(player, "soldier")

    assert player.units == [Unit.new("soldier")]
    assert player.money == 0
  end

  test "going over budget fails", %{player: player} do
    player = %{player | money: 299}
    player = Player.add_unit(player, "soldier")

    assert player.units == []
    assert player.money == 299
  end

  test "add unknown unit", %{player: player} do
    assert Player.add_unit(player, "unknown") == player
  end
end
