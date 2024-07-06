defmodule SyncCentral.TestHelper do
  @moduledoc """
  Test helpers.
  """

  import Plug.Conn
  import SyncCentral.UsersFixtures

  def setup_token(%{conn: conn, user: user}) do
    {_user_token, raw_token} = user_token_fixture(%{user_id: user.id})

    {:ok,
     conn:
       put_req_header(conn, "authorization", "Bearer " <> raw_token)}
  end

  def setup_token(ctx) do
    user = user_fixture()
    setup_token(Map.put(ctx, :user, user))
  end
end
