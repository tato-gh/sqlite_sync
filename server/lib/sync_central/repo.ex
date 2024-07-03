defmodule SyncCentral.Repo do
  use Ecto.Repo,
    otp_app: :sync_central,
    adapter: Ecto.Adapters.Postgres
end
