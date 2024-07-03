defmodule SyncCentral.UsersTest do
  use SyncCentral.DataCase

  alias SyncCentral.Users

  describe "users" do
    import SyncCentral.UsersFixtures

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end
  end
end
