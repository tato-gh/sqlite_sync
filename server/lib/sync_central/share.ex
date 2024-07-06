defmodule SyncCentral.Share do
  @moduledoc """
  The Share context.
  """

  import Ecto.Query, warn: false
  alias SyncCentral.Repo

  alias SyncCentral.Share.Transaction

  def create_user_transaction(user, attrs) do
    %Transaction{user_id: user.id}
    |> Transaction.changeset(attrs)
    |> Repo.insert()
  end
end
