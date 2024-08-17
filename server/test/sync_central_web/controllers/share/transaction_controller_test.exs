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

  describe "list transactions" do
    setup do
      user = user_fixture()
      user_device = user_device_fixture(%{user_id: user.id, name: "my_device"})
      {:ok, user: user, user_device: user_device}
    end

    setup [:setup_token]

    test "renders transactions", %{conn: conn, user: user} do
      %{id: id_1} =
        _transaction_1 =
        transaction_fixture(%{user_id: user.id, inserted_at: ~U[2024-01-02 10:00:00.123456Z]})

      %{id: id_2} =
        transaction_2 =
        transaction_fixture(%{user_id: user.id, inserted_at: ~U[2024-01-03 10:00:00.123456Z]})

      %{id: id_3} =
        _transaction_3 =
        transaction_fixture(%{user_id: user.id, inserted_at: ~U[2024-01-01 10:00:00.123456Z]})

      conn =
        get(conn, ~p"/api/share/transactions", device: %{name: "my_device"})

      assert [%{"id" => ^id_3}, %{"id" => ^id_1}, %{"id" => ^id_2}] =
               json_response(conn, 200)["data"]

      user_device = Repo.get_by(UserDevice, user_id: user.id, name: "my_device")
      assert user_device.retrieved_at == transaction_2.inserted_at

      # second time
      conn =
        get(conn, ~p"/api/share/transactions", device: %{name: "my_device"})

      assert [] = json_response(conn, 200)["data"]
    end
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
