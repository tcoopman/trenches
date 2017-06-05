defmodule Trenches.Web.Auth do
  import Plug.Conn

  alias Trenches.PlayerRepo

  def init(_opts) do
  end

  def call(conn, _) do
    user_name = get_session(conn, :user_name)
    case user_name != nil && PlayerRepo.get_by_name(user_name) do
      {:ok, player} -> assign(conn, :current_user, player)
      _ -> assign(conn, :current_user, nil)
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_name, user.name)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end
end