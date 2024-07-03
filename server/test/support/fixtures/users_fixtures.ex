defmodule SyncCentral.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SyncCentral.Users` context.
  """

  alias SyncCentral.Repo
  alias SyncCentral.Users.User

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      %User{
        email: "some email",
        hashed_access_key: "some hashed_access_key"
      }
      |> Map.merge(attrs)
      |> Repo.insert()

    user
  end
end
