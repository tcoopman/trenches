defmodule Trenches.Game do
  alias __MODULE__
  alias Trenches.Player

  defstruct [status: :not_started, players: %{}, subscriber: nil, name: nil]

  def new(name) do
    %Game{name: name}
  end

  def join(%Game{players: players} = game, %Player{} = player) do
    if Enum.count(players) < 2 do
      players = Map.put(players, player.id, player)
      game = %{game | players: players}
      {:ok, game}
    else
      {:error, "maximum number of players reached"}
    end
  end

  def new_unit(%Game{players: players} = game, id, type) do
    players = Map.update!(players, id, fn player -> 
      Player.add_unit(player, type)
    end)
    game = %{game | players: players}
    {:ok, game}
  end

  def open?(%Game{status: status}) do
    status == :not_started
  end
end