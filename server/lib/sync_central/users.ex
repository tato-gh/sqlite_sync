defmodule SyncCentral.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false

  alias SyncCentral.Repo
  alias SyncCentral.Users.User
  alias SyncCentral.Users.UserToken
  alias SyncCentral.Users.UserDevice

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  """
  def get_user_by_email!(email) do
    Repo.get_by!(User, email: email)
  end

  @doc """
  """
  def valid_user?(user, access_key) do
    User.valid_access_key?(user, access_key)
  end

  @doc """
  Registers a user.
  """
  def register_user(email, access_key) do
    hashed_value = Argon2.hash_pwd_salt(access_key)
    Repo.insert(%User{email: email, hashed_access_key: hashed_value})
  end

  @doc """
  Creates a new api token for a user.

  The token returned must be saved somewhere safe.
  This token cannot be recovered from the database.
  """
  def create_user_api_token(user) do
    {encoded_token, user_token} = UserToken.build_api_token(user, "api-token")
    Repo.insert!(user_token)
    encoded_token
  end

  @doc """
  Fetches the user by API token.
  """
  def fetch_user_by_api_token(token) do
    with {:ok, query} <- UserToken.verify_api_token_query(token, "api-token"),
         %User{} = user <- Repo.one(query) do
      {:ok, user}
    else
      _ -> :error
    end
  end

  @doc """
  Updates user_devices.retrieved_at by given time.
  """
  def touch_user_device_retrieved_at(user_device, timestamp) do
    Ecto.Changeset.change(user_device, %{retrieved_at: timestamp})
    |> Repo.update()
  end

  @doc """
  Gets user_device by condition
  """
  def get_user_device_by!(condition) do
    Repo.get_by!(UserDevice, condition)
  end
end
