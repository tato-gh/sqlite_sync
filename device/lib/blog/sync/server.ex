defmodule Blog.Sync.Server do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "http://server:4000/"
  plug Tesla.Middleware.JSON

  # TODO
  plug Tesla.Middleware.Headers, [{"authorization", "token xyz"}]

  def login(params) do
    post("/api/login", params)
  end

  #   with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
  #        {:ok, user} <- Users.fetch_user_by_api_token(token) do
  # end
end
