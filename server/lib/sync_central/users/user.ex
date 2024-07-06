defmodule SyncCentral.Users.User do
  use Ecto.Schema

  alias SyncCentral.Users.UserToken
  alias SyncCentral.Users.UserDevice

  schema "users" do
    field :email, :string
    field :hashed_access_key, :string

    timestamps(type: :utc_datetime)

    has_many :tokens, UserToken, foreign_key: :user_id
    has_many :devices, UserDevice, foreign_key: :user_id
  end
end
