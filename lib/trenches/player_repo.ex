defmodule Trenches.PlayerRepo do
  use GenServer
  
  alias Trenches.Player

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: :player_repo)
  end

  def create(name) do
    GenServer.call(:player_repo, {:create, name})
  end

  def get(name) do
    GenServer.call(:player_repo, {:get, name})
  end

  def handle_call({:create, name}, _from, %{} = state) do
    if Map.has_key?(state, name) do
      {:reply, {:error, "Name: #{name} is not unique"}, state}
    else
      player = Player.new(name, UUID.uuid4)
      state = Map.put(state, name, player)
      {:reply, :ok, state}
    end
  end

  def handle_call({:get, name}, _from, %{} = state) do
    case Map.get(state, name) do
      nil -> {:reply, {:error, "#{name} is not found."}, state}
      player -> {:reply, {:ok, player}, state}
    end
  end
end