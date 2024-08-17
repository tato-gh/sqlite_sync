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

  @doc """
  Verifies the access_key.

  If there is no user or the user doesn't have a access_key, we call
  `Argon2.no_user_verify/0` to avoid timing attacks.
  """
  def valid_access_key?(%SyncCentral.Users.User{hashed_access_key: hashed_access_key}, access_key)
      when is_binary(hashed_access_key) and byte_size(access_key) > 0 do
    Argon2.verify_pass(access_key, hashed_access_key)
  end

  def valid_access_key?(_, _) do
    Argon2.no_user_verify()
    false
  end
end
