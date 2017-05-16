defmodule Trenches.PlayerTest do
  use ExUnit.Case, async: true

  alias Trenches.Player
  alias Trenches.Unit

  setup do
    [player: Player.new(1, 'player 1')]
  end

  test "verify the constructor", %{player: player} do
    assert player.id == 1
    assert player.name == 'player 1'
    assert player.units == []
    assert player.money == 1000
  end

  test "add known unit generates a new player", %{player: player} do
    player = Player.add_unit(player, "soldier")
    assert player.units == [Unit.new("soldier")]
    assert player.money == 1000 - Unit.new("soldier").cost
  end

  test "add unknown unit doesnt change the player", %{player: player} do
    assert Player.add_unit(player, "unknown") == player
  end

end