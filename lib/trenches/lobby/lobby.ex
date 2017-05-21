defmodule Trenches.Lobby do
  import Supervisor.Spec

  alias Trenches.{Game, GameServer}

  def start_link do
    children = [
      worker(Trenches.GameServer, [], restart: :transient)
    ]
    Supervisor.start_link(children, strategy: :simple_one_for_one, name: __MODULE__)
  end

  def create_game(name) do
    game = Game.new(name)
    case Supervisor.start_child(__MODULE__, [game]) do
      {:ok, _} -> :ok
      {:error, {:already_started, _}} -> {:error, :duplicate_name}
    end
  end

  def all_open_games() do
    Supervisor.which_children(__MODULE__)
    |> Enum.map(fn {_, pid, _, _} -> pid end)
    |> Enum.filter(&(GameServer.open?(&1)))
    |> Enum.map(&(GameServer.name(&1)))
  end
end