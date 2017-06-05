defmodule Trenches.Game do
  alias __MODULE__
  alias Trenches.{Player, GameLoop}

  defstruct [status: :not_started, players: %{}, subscriber: nil, name: nil, created_at: nil]

  def new(name) do
    %Game{name: name, created_at: DateTime.utc_now}
  end

  def join(%Game{players: players} = game, %Player{} = player) do
    cond do
      Map.has_key?(players, player.id) ->
        {:error, "player already joined the game"}
      Enum.count(players) >= 2 ->
        {:error, "maximum number of players reached"}
      true ->
        players = Map.put(players, player.id, player)
        game = %{game | players: players}
        {:ok, game}
    end
  end

  def new_unit(%Game{players: players} = game, player_id, type) do
    players = Map.update!(players, player_id, fn player -> 
      Player.add_unit(player, type)
    end)
    game = %{game | players: players}
    {:ok, game}
  end

  def tick(%Game{} = game) do
    GameLoop.tick(game)
  end

  def open?(%Game{status: status}), do: status == :not_started
end