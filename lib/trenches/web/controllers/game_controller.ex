defmodule Trenches.Web.GameController do
  use Trenches.Web, :controller

  plug :authenticate when action in [:index]

  def index(conn, _params) do
    render conn, "index.html"
  end

  defp authenticate(conn, _opts) do
    if Map.has_key?(conn.assigns, :current_user) do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: page_path(conn, :index))
      |> halt
    end
  end

end