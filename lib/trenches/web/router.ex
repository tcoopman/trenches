defmodule Trenches.Web.Router do
  use Trenches.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Trenches.Web.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Trenches.Web do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/lobby", LobbyController, :index
    get "/game/:name", GameController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", Trenches.Web do
  #   pipe_through :api
  # end
end
