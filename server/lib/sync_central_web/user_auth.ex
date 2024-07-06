defmodule SyncCentralWeb.UserAuth do
  @moduledoc """
  API user authentication

  see

  - https://hexdocs.pm/phoenix/api_authentication.html#api-authentication-plug
  """

  import Plug.Conn

  alias SyncCentral.Users

  def fetch_api_user(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, user} <- Users.fetch_user_by_api_token(token) do
      assign(conn, :current_user, user)
    else
      _ ->
        conn
        |> send_resp(:unauthorized, "No access for you")
        |> halt()
    end
  end
end
