defmodule SyncCentral.UsersTest do
  use SyncCentral.DataCase

  alias SyncCentral.Users

  describe "users" do
    alias SyncCentral.Users.User

    import SyncCentral.UsersFixtures

    @invalid_attrs %{email: nil, hashed_password: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{email: "some email", hashed_password: "some hashed_password"}

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)
      assert user.email == "some email"
      assert user.hashed_password == "some hashed_password"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{email: "some updated email", hashed_password: "some updated hashed_password"}

      assert {:ok, %User{} = user} = Users.update_user(user, update_attrs)
      assert user.email == "some updated email"
      assert user.hashed_password == "some updated hashed_password"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
