defmodule SyncCentral.Running do
  @moduledoc """
  Rnning scripts
  """

  alias SyncCentral.Users

  @doc """
  Creates new user.

  The administrator tells the user the access_key.

  Users decide their passphrase on each them device.
  So there are no problem to share access_key with administrator and the user.
  """
  def register_user(email) do
    access_key = Ecto.UUID.generate()
    IO.inspect(access_key, label: "AccessKey")

    Users.register_user(email, access_key)
  end
end
