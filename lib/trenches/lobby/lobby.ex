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
    name = {:via, Registry, {:games, name}}
    case Supervisor.start_child(:lobby, [name]) do
      {:ok, _} -> :ok
      {:error, {:already_started, _}} -> {:error, :already_started}
      _ -> {:error, :unknown}
    end
  end

  def get(name) do
    case Registry.lookup(:games, name) do
      [{pid, nil}] -> {:ok, pid}
      _ -> {:error, :not_found}
    end
  end

end