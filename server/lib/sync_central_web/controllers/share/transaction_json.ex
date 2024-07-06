defmodule SyncCentralWeb.API.Share.TransactionJSON do
  alias SyncCentral.Share.Transaction

  @doc """
  Renders a single transaction.
  """
  def show(%{transaction: transaction}) do
    %{data: data(transaction)}
  end

  defp data(%Transaction{} = transaction) do
    %{
      id: transaction.id
    }
  end
end
