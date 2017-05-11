defmodule Trenches.Web.Auth do
  import Plug.Conn

  alias Trenches.PlayerRepo

  def init(_opts) do
  end

  def call(conn, repo) do
    user_name = get_session(conn, :user_name)
    case user_name && PlayerRepo.get(user_name) do
      {:error, _} -> conn
      player -> assign(conn, :current_user, player)
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_name, user.name)
    |> configure_session(renew: true)
  end

end