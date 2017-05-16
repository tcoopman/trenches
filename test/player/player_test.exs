defmodule Trenches.PlayerTest do
  use ExUnit.Case, async: true

  alias Trenches.Player

  test "verify the constructor" do
    player = Player.new(1, 'player 1')
    assert player.id == 1
    assert player.name == 'player 1'
    assert player.units == []
    assert player.money == 1000
  end
end
