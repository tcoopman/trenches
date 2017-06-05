defmodule Trenches.Game do
  alias __MODULE__
  alias Trenches.{Player, GameLoop}

  defstruct [
    status: :waiting_for_players,
    players: %{},
    subscriber: nil,
    name: nil,
    created_at: nil,
    created_by: nil,
    countdown_clock: 50
  ]

  def new(name, %Player{} = creator) do
    %Game{name: name, created_at: DateTime.utc_now, created_by: creator}
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
        |> update_status
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
    case game.status do
      :waiting_for_players -> game
      :countdown_to_start -> 
        countdown = game.countdown_clock - 1
        if countdown == 0 do
          %{game | countdown_clock: countdown, status: :in_progress}
        else
          %{game | countdown_clock: countdown}
        end
      :in_progress ->
        GameLoop.tick(game)
    end
  end

  def open?(%Game{status: status}), do: status == :not_started

  defp update_status(%Game{players: players} = game) do
    case Enum.count(players) == 2 do
      true -> %{game | status: :countdown_to_start}
      false -> game
    end
  end
end