defmodule Trenches.Lobby do
  import Supervisor.Spec

  alias Trenches.{Game, GameServer}

  def start_link do
    children = [
      worker(Trenches.GameServer, [], restart: :transient)
    ]
    Supervisor.start_link(children, strategy: :simple_one_for_one, name: __MODULE__)
  end

  def create_game(name, player) do
    game = Game.new(name, player)
    case Supervisor.start_child(__MODULE__, [game]) do
      {:ok, _} -> {:ok, game}
      {:error, {:already_started, _}} -> {:error, :duplicate_name}
    end
  end

  def all_games() do
    Supervisor.which_children(__MODULE__)
    |> Enum.map(fn {_, pid, _, _} -> pid end)
    |> Enum.map(&(GameServer.game(&1)))
  end

  def get(name) do
    result = Supervisor.which_children(__MODULE__)
    |> Enum.find(fn {_, pid, _, _} -> GameServer.game(pid).name == name end)

    case result do
      nil -> {:error, "No game found with name: #{name}"}
      {_, pid, _, _} -> {:ok, pid}
    end
  end
end