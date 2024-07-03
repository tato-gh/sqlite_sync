defmodule SyncCentral.RunningTest do
  use SyncCentral.DataCase

  alias SyncCentral.Running

  describe "register_user" do
    test "returns user" do
      {:ok, user} = Running.register_user("test@example.com")

      assert user.email
      assert user.hashed_access_key
    end
  end
end
