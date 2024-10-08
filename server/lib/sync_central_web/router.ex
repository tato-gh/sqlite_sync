defmodule SyncCentralWeb.Router do
  use SyncCentralWeb, :router

  import SyncCentralWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SyncCentralWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_user do
    plug :fetch_api_user
  end

  scope "/", SyncCentralWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api", SyncCentralWeb.API do
    pipe_through :api

    post "/login", SessionController, :create
  end

  scope "/api", SyncCentralWeb.API do
    pipe_through [:api, :api_user]

    scope "/share", Share do
      resources "/transactions", TransactionController, only: [:index, :create]
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:sync_central, :dev_routes) do
    # If you want to use the LiveDashboard in production, you shojld put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SyncCentralWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
