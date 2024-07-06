defmodule SyncCentral.Share.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  alias SyncCentral.Users.User

  schema "transactions" do
    belongs_to :user, User
    field :sql, :string

    timestamps(type: :utc_datetime_usec, updated_at: false)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:sql])
    |> validate_required([:user_id, :sql])
  end
end
