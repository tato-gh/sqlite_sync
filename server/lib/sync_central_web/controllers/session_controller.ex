defmodule SyncCentralWeb.API.SessionController do
  use SyncCentralWeb, :controller

  alias SyncCentral.Users

  action_fallback SyncCentralWeb.FallbackController

  def create(conn, params) do
    with user <- Users.get_user_by_email(params["email"]),
         true <- Users.valid_user?(user, params["password"]),
         token <- Users.create_user_api_token(user) do
      conn
      |> put_status(:created)
      |> json(%{token: token})
    else
      false ->
        {:error, "Invalid password"}
    end
  end
end
