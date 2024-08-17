defmodule SyncCentralWeb.API.SessionControllerTest do
  use SyncCentralWeb.ConnCase

  alias SyncCentral.Users

  setup do
    {:ok, user} = Users.register_user("test@example.com", "access_key")
    {:ok, user: user}
  end

  test "POST /api/login", %{conn: conn} do
    conn =
      post(conn, ~p"/api/login", %{
        email: "test@example.com",
        password: "access_key"
      })

    assert %{"token" => _} = json_response(conn, 201)
  end

  test "POST /api/login, case invalid password", %{conn: conn} do
    conn =
      post(conn, ~p"/api/login", %{
        email: "test@example.com",
        password: "invalid"
      })

    assert %{"message" => "Invalid password"} = json_response(conn, 400)
  end
end
