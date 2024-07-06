defmodule SyncCentral.Users.UserDevice do
  use Ecto.Schema

  alias SyncCentral.Users.User

  schema "user_devices" do
    belongs_to :user, User
    field :name, :string
    field :retrieved_at, :utc_datetime_usec

    timestamps(type: :utc_datetime)
  end
end
