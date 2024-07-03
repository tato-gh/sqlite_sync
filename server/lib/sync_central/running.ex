defmodule SyncCentral.Running do
  @moduledoc """
  Rnning scripts
  """

  alias SyncCentral.Users

  @doc """
  Creates new user.

  The administrator tells the user the access_key.
  """
  def register_user(email) do
    access_key = Ecto.UUID.generate()
    IO.inspect(access_key, label: "AccessKey")

    Users.register_user(email, access_key)
  end
end
