defmodule Trenches.Web.GameController do
  use Trenches.Web, :controller

  #TODO duplicated behaviour
  plug :authenticate when action in [:show]

  def show(conn, %{"name" => name}) do
    render conn, "show.html", %{name: name}
  end

  defp authenticate(conn, _opts) do
    user = Map.get(conn.assigns, :current_user)
    if user != nil do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: page_path(conn, :index))
      |> halt
    end
  end
end