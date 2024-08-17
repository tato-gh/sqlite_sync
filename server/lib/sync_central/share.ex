defmodule SyncCentral.Share do
  @moduledoc """
  The Share context.
  """

  import Ecto.Query, warn: false
  alias SyncCentral.Repo

  alias SyncCentral.Share.Transaction
  alias SyncCentral.Users.UserDevice

  @doc """
  Gets latest user's transaction
  """
  def get_latest_user_transaction(user) do
    from(
      q in Transaction,
      where: q.user_id == ^user.id,
      order_by: {:desc, q.inserted_at},
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  List user_device unread transactions
  """
  def list_unread_transactions(user_device) do
    retrieved_at = user_device.retrieved_at || ~U[2000-01-01 00:00:00.123456Z]

    from(
      q in Transaction,
      where: q.user_id == ^user_device.user_id,
      where: q.inserted_at > ^retrieved_at,
      order_by: {:asc, q.inserted_at}
    )
    |> Repo.all()
  end

  @doc """
  Creates transaction with given user.
  """
  def create_user_transaction(user, user_device, attrs) do
    current_time = DateTime.utc_now()

    transaction_changeset =
      %Transaction{user_id: user.id, inserted_at: current_time}
      |> Transaction.changeset(attrs)

    user_device_changeset = Ecto.Changeset.change(user_device, retrieved_at: current_time)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:transaction, transaction_changeset)
    |> Ecto.Multi.update(:user_device, user_device_changeset)
    |> Repo.transaction()
    |> then(fn
      {:ok, data} -> {:ok, Map.get(data, :transaction)}
      {:error, :transaction, changeset, _} -> {:error, changeset}
    end)
  end

  @doc """
  Gets shareable user_device with given user and condition.
  """
  def get_shareable_user_device_by!(user, condition) do
    condition = Keyword.put(condition, :user_id, user.id)

    get_latest_user_transaction(user)
    |> case do
      nil ->
        # １つもtransactionがなく(=最新状態)、nameで引ければよい
        Repo.get_by!(UserDevice, condition)

      transaction ->
        # 同期済みかを条件に加える
        # 最新まで同期していない端末は、同期可能な状態ではない
        condition = Keyword.put(condition, :retrieved_at, transaction.inserted_at)
        Repo.get_by!(UserDevice, condition)
    end
  end
end
