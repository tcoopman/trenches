defmodule Trenches.Web.RoomChannel do
  use Phoenix.Channel

  alias Trenches.Game

  def join("room:game", _message, socket) do
    id = Game.join()
    send(self, {:after_join, id})
    {:ok, socket}
  end

  def handle_info({:after_join, id}, socket) do
    push socket, "player_joined", %{id: id}
    {:noreply, socket}
  end


end
