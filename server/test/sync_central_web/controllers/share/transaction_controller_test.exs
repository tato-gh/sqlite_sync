defmodule SyncCentralWeb.Share.TransactionControllerTest do
  use SyncCentralWeb.ConnCase

  import SyncCentral.UsersFixtures
  import SyncCentral.ShareFixtures

  alias SyncCentral.Repo
  alias SyncCentral.Share.Transaction
  alias SyncCentral.Users.UserDevice

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create transaction" do
    setup do
      user = user_fixture()
      user_device = user_device_fixture(%{user_id: user.id, name: "my_device"})
      {:ok, user: user, user_device: user_device}
    end

    setup [:setup_token]

    test "renders transaction when data is valid", %{conn: conn, user: user} do
      # first time
      conn =
        post(conn, ~p"/api/share/transactions",
          device: %{name: "my_device"},
          transaction: %{sql: "encrypted sql"}
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]
      assert transaction = Repo.get(Transaction, id)

      assert Repo.get_by(UserDevice,
               user_id: user.id,
               name: "my_device",
               retrieved_at: transaction.inserted_at
             )

      # second time
      conn =
        post(conn, ~p"/api/share/transactions",
          device: %{name: "my_device"},
          transaction: %{sql: "encrypted sql 2"}
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]
      assert transaction = Repo.get(Transaction, id)

      assert Repo.get_by(UserDevice,
               user_id: user.id,
               name: "my_device",
               retrieved_at: transaction.inserted_at
             )
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/share/transactions",
          device: %{name: "my_device"},
          transaction: %{}
        )

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "renders errors when request is wrong", %{conn: conn} do
      conn = post(conn, ~p"/api/share/transactions")
      assert json_response(conn, 404)["errors"] != %{}
    end

    test "renders errors when user_device is not shareable", %{conn: conn, user: user} do
      transaction_fixture(%{user_id: user.id})

      # 未同期状態のデバイスからは新しいTransactionが積めないこと
      past_retrieved_at = DateTime.utc_now() |> DateTime.add(-1, :hour)

      user_device_fixture(%{
        user_id: user.id,
        name: "my_device_2",
        retrieved_at: past_retrieved_at
      })

      assert_raise Ecto.NoResultsError, fn ->
        post(conn, ~p"/api/share/transactions",
          device: %{name: "my_device_2"},
          transaction: %{sql: "encrypted sql"}
        )
      end
    end
  end
end
