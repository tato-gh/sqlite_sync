defmodule Blog.Sync.Server do
  @middleware [
    {Tesla.Middleware.BaseUrl, "http://server:4000/"},
    Tesla.Middleware.JSON
  ]

  def login(params) do
    Tesla.client(@middleware)
    |> Tesla.post("/api/login", params)
  end

  def post_transaction(device, access_token, encrypted) do
    middleware = @middleware ++ [
      {Tesla.Middleware.Headers, [{"authorization", "Bearer " <> access_token}]}
    ]

    Tesla.client(middleware)
    |> Tesla.post("/api/share/transactions", %{
      device: %{name: device.identity},
      transaction: %{sql: encrypted}
    })
  end

  def list_transactions(device, access_token) do
    middleware = @middleware ++ [
      {Tesla.Middleware.Headers, [{"authorization", "Bearer " <> access_token}]}
    ]

    Tesla.client(middleware)
    |> Tesla.get("/api/share/transactions", query: [{:device, device.identity}]
    )
  end
end
