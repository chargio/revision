defmodule RevisionWeb.Router do
  use RevisionWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RevisionWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/session/new/multiplication/:number", SessionController, :new
    post "/session/:template/:number/:uid", SessionController, :create
    get "/session/:template/:uid", SessionController, :show
    post "/session/:template/:uid/", SessionController, :update
  end


  # Other scopes may use custom stacks.
  # scope "/api", RevisionWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: RevisionWeb.Telemetry
    end
  end
end
