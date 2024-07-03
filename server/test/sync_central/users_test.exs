defmodule SyncCentral.UsersTest do
  use SyncCentral.DataCase

  alias SyncCentral.Users

  import SyncCentral.UsersFixtures

  describe "users" do
    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end
  end

  describe "create_user_api_token/1 and fetch_user_by_api_token/1" do
    test "creates and fetches by token" do
      user = user_fixture()
      token = Users.create_user_api_token(user)
      assert Users.fetch_user_by_api_token(token) == {:ok, user}
      assert Users.fetch_user_by_api_token("invalid") == :error
    end
  end
end
