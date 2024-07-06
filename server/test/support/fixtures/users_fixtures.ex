defmodule SyncCentral.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SyncCentral.Users` context.
  """

  alias SyncCentral.Repo
  alias SyncCentral.Users.User
  alias SyncCentral.Users.UserToken

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

  @doc """
  Generate a user_token.
  """
  def user_token_fixture(attrs \\ %{}) do
    raw_token = Map.get(attrs, :raw_token, "test")
    token = gen_test_token(raw_token)

    {:ok, user_token} =
      %UserToken{
        token: token,
        context: "api-token"
      }
      |> Map.merge(attrs)
      |> Repo.insert()

    {user_token, raw_token}
  end

  defp gen_test_token(token) do
    token
    |> Base.url_decode64(padding: false)
    |> then(fn {:ok, decoded} -> :crypto.hash(:sha256, decoded) end)
  end
end
