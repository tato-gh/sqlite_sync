defmodule Blog.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BlogWeb.Telemetry,
      Blog.Repo,
      {Ecto.Migrator,
        repos: Application.fetch_env!(:blog, :ecto_repos),
        skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:blog, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Blog.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Blog.Finch},
      # Start a worker by calling: Blog.Worker.start_link(arg)
      # {Blog.Worker, arg},
      # Start to serve requests, typically the last entry
      BlogWeb.Endpoint
    ]

    # telemetry attach for repo
    :ok = :telemetry.attach("repo-log", [:blog, :repo, :query], &Blog.RepoLog.handle_event/4, nil)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Blog.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BlogWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
