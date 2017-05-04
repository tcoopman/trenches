defmodule Trenches.Web.RoomChannel do
  use Phoenix.Channel

  alias Trenches.Game

  def join("room:game", _message, socket) do
    Game.subscribe(self())
    case Game.join() do
      {:error, message} ->
        {:ok, socket} # TODO the user should be informed
      {:ok, id} ->
        send(self, {:after_join, id})
        {:ok, socket}
    end
  end

  def handle_in("new_unit", %{"type" => type, "id" => id}, socket) do
    Game.new_unit(id, type)
    {:reply, :ok, socket}
  end

  def handle_info({:after_join, id}, socket) do
    push socket, "player_joined", %{id: id}
    {:noreply, socket}
  end

  def handle_info({:tick, players}, socket) do
    broadcast socket, "tick", %{players: Map.values(players)}
    {:noreply, socket}
  end
end
