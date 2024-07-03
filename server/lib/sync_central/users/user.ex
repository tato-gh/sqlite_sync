defmodule SyncCentral.Users.User do
  use Ecto.Schema

  schema "users" do
    field :email, :string
    field :hashed_access_key, :string

    timestamps(type: :utc_datetime)
  end
end
