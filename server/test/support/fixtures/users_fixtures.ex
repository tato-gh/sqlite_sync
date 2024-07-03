defmodule SyncCentral.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SyncCentral.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "some email",
        hashed_password: "some hashed_password"
      })
      |> SyncCentral.Users.create_user()

    user
  end
end
