defmodule Trenches.Lobby do
  use Supervisor

  import Supervisor.Spec

  alias Trenches.Game

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: :lobby)
  end
  
  def init(_) do
    children = [
      worker(Game, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
  
  def open_game(name) do
    case Supervisor.start_child(:lobby, [{:via, Registry, {:games, name}}]) do
      {:ok, _} -> :ok
      {:error, {:already_started, _}} -> {:error, "Game #{name} is already started"}
      _ -> {:error, "Unknown error"}
    end
  end

  def get(name) do
    case Registry.lookup(:games, name) do
      [{pid, nil}] -> {:ok, pid}
      _ -> {:error, "Game #{name} is not found, does it really exist?"}
    end
  end

end