defmodule Trenches.Web.RoomChannel do
  use Phoenix.Channel

  def join("room:game", _message, socket) do
    {:ok, socket}
  end
end
