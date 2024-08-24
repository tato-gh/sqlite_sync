defmodule SyncCentralWeb.API.Share.TransactionJSON do
  alias SyncCentral.Share.Transaction

  @doc """
  Renders multi transactions.
  """
  def index(%{transactions: transactions}) do
    multi_data = Enum.map(transactions, &data/1)
    %{data: multi_data}
  end

  @doc """
  Renders a single transaction.
  """
  def show(%{transaction: transaction}) do
    %{data: data(transaction)}
  end

  defp data(%Transaction{} = transaction) do
    %{
      id: transaction.id,
      sql: transaction.sql
    }
  end
end
