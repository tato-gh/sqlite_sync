defmodule SyncCentralWeb.API.Share.TransactionController do
  use SyncCentralWeb, :controller

  alias SyncCentral.Share
  alias SyncCentral.Share.Transaction
  alias SyncCentral.Users

  action_fallback SyncCentralWeb.FallbackController

  def index(conn, %{"device" => %{"name" => device_name}}) do
    %{current_user: current_user} = conn.assigns

    with user_device <- get_user_device_by!(current_user, device_name) do
      transactions = Share.list_unread_transactions(user_device)
      update_user_device_retrieved_at(user_device, Enum.at(transactions, -1))

      conn
      |> put_status(:ok)
      |> render(:index, transactions: transactions)
    end
  end

  def create(
        conn,
        %{
          "device" => %{"name" => device_name},
          "transaction" => transaction_params
        }
      ) do
    %{current_user: current_user} = conn.assigns

    with user_device <- get_shareable_user_device_by!(current_user, device_name),
         {:ok, %Transaction{} = transaction} <-
           create_user_transaction(current_user, user_device, transaction_params) do
      conn
      |> put_status(:created)
      |> render(:show, transaction: transaction)
    end
  end

  def create(_conn, _params) do
    {:error, :not_found}
  end

  defp get_user_device_by!(user, device_name) do
    Users.get_user_device_by!(user_id: user.id, name: device_name)
  end

  defp get_shareable_user_device_by!(user, device_name) do
    Share.get_shareable_user_device_by!(user, name: device_name)
  end

  defp create_user_transaction(user, user_device, transaction_params) do
    Share.create_user_transaction(user, user_device, transaction_params)
  end

  defp update_user_device_retrieved_at(_user_device, nil), do: nil

  defp update_user_device_retrieved_at(user_device, latest_transaction) do
    Users.touch_user_device_retrieved_at(user_device, latest_transaction.inserted_at)
  end
end
