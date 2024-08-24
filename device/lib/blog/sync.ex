defmodule Blog.Sync do
  alias Blog.Sync.Server
  alias Blog.Setting

  def fetch_access_token(params) do
    Server.login(params)
    |> case do
      {:ok, %{status: 201} = response} ->
        %{body: %{"token" => token}} = response
        token

      {:ok, _error} ->
        nil

      {:error, _reason} ->
        nil
    end
  end

  def send_transaction(encrypted) do
    device = Setting.get_setting()
    access_token = Setting.get_access_token()

    Server.post_transaction(device, access_token, encrypted)
  end

  def get_transactions do
    device = Setting.get_setting()
    access_token = Setting.get_access_token()

    Server.list_transactions(device, access_token)
    |> case do
      {:ok, %{body: %{"data" => list}}} ->
        encrypted_list = Enum.map(list, & &1["sql"])
        Phoenix.PubSub.broadcast(Blog.PubSub, "retrieve", {:encrypted_transactions, encrypted_list})

      _ ->
        []
    end
  end
end
