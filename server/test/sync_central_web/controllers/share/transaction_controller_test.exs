defmodule SyncCentralWeb.Share.TransactionControllerTest do
  use SyncCentralWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create transaction" do
    setup(ctx) do
      setup_token(ctx)
    end

    test "renders transaction when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/share/transactions", transaction: %{
        sql: "encrypted sql"
      })
      assert %{"id" => _id} = json_response(conn, 201)["data"]
    end

    # test "renders errors when data is invalid", %{conn: conn} do
    #   conn = post(conn, ~p"/api/transactions", transaction: %{
    #   })
    #   assert json_response(conn, 422)["errors"] != %{}
    # end
  end
end
