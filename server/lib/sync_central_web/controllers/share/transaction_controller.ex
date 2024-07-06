defmodule SyncCentralWeb.API.Share.TransactionController do
  use SyncCentralWeb, :controller

  alias SyncCentral.Share
  alias SyncCentral.Share.Transaction

  action_fallback SyncCentralWeb.FallbackController

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

  defp get_shareable_user_device_by!(user, device_name) do
    Share.get_shareable_user_device_by!(user, name: device_name)
  end

  defp create_user_transaction(user, user_device, transaction_params) do
    Share.create_user_transaction(user, user_device, transaction_params)
  end
end
