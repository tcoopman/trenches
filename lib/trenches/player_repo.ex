defmodule Trenches.PlayerRepo do
  use GenServer
  
  alias Trenches.Player

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: :player_repo)
  end

  def get(id) do
    IO.inspect "Getting player #{id}"
    {:ok, Player.new(id)}
  end
end