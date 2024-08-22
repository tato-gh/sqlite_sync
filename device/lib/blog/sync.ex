defmodule Blog.Sync do
  alias Blog.Sync.Server

  def fetch_access_token(params) do
    Server.login(params)
    |> then(fn item -> IO.inspect(item, label: "=================== DEBUG"); item end)
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
end
