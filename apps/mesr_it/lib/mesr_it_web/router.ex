defmodule MesrItWeb.Router do
  use MesrItWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", MesrItWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    resources "/feeds", FeedController, only: [ :show ]
  end

  # Other scopes may use custom stacks.
  # scope "/api", MesrItWeb do
  #   pipe_through :api
  # end
end
