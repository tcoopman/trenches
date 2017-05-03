defmodule Trenches.Web.PageController do
  use Trenches.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
