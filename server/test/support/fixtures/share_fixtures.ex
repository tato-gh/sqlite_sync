defmodule SyncCentral.ShareFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SyncCentral.Share` context.
  """

  alias SyncCentral.Repo
  alias SyncCentral.Share.Transaction

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(attrs \\ %{}) do
    {:ok, transaction} =
      %Transaction{
        sql: "my sql"
      }
      |> Map.merge(attrs)
      |> Repo.insert()

    transaction
  end
end
