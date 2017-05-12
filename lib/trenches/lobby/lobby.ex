defmodule Trenches.Lobby do
  use GenServer

  alias __MODULE__
  alias Trenches.Game

  defstruct [players: [], games: %{}]

  def start_link do
    GenServer.start_link(__MODULE__, %Lobby{}, name: :lobby)
  end

  def open_game(name) do
    GenServer.call(:lobby, {:open_game, name})
  end

  def all_open_games() do
    GenServer.call(:lobby, :all_open_games)
  end

  # Server
  def handle_call({:open_game, name}, _from, %Lobby{games: games} = state) do
    case Map.has_key?(games, name) do
      true ->
        {:reply, {:error, "Game #{name} already exists"}, state}
      false ->
        game = Game.new(name)
        state = %{state | games: Map.put(games, name, game)}
        {:reply, :ok, state}
    end
  end

  def handle_call(:all_open_games, _from, %Lobby{games: games} = state) do
    open_games = games
    |> Map.values
    |> Enum.filter(&Game.open?/1)

    {:reply, open_games, state}
  end
end