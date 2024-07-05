defmodule SyncCentral.Users.Transaction do
  use Ecto.Schema

  alias SyncCentral.Users.User

  schema "transactions" do
    belongs_to :user, User
    field :sql, :string

    timestamps(type: :utc_datetime)
  end
end
