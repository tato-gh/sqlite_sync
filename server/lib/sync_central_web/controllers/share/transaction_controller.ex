defmodule SyncCentralWeb.API.Share.TransactionController do
  use SyncCentralWeb, :controller

  alias SyncCentral.Share
  alias SyncCentral.Share.Transaction

  action_fallback SyncCentralWeb.FallbackController

  def create(conn, %{"transaction" => transaction_params}) do
    %{current_user: current_user} = conn.assigns

    with {:ok, %Transaction{} = transaction} <- Share.create_user_transaction(current_user, transaction_params) do
      conn
      |> put_status(:created)
      |> render(:show, transaction: transaction)
    end
  end
end
