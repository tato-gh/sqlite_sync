defmodule BlogWeb.Router do
  use BlogWeb, :router

  alias BlogWeb.SyncHook

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BlogWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", BlogWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  live_session :default, on_mount: [
    {SyncHook, :load_setting},
    {SyncHook, :load_access_token},
    {SyncHook, :prepare_cryptor},
    {SyncHook, :maybe_require_login}
  ] do
    scope "/", BlogWeb do
      pipe_through :browser

      live "/posts", PostLive.Index, :index
      live "/posts/new", PostLive.Index, :new
      live "/posts/:id/edit", PostLive.Index, :edit

      live "/posts/:id", PostLive.Show, :show
      live "/posts/:id/show/edit", PostLive.Show, :edit

      live "/setting", SettingLive.Show, :show
      live "/setting/apply", SettingLive.Show, :apply
      live "/setting/new", SettingLive.Show, :new
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:blog, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BlogWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
