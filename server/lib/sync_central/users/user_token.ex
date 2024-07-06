defmodule SyncCentral.Users.UserToken do
  use Ecto.Schema

  import Ecto.Query

  alias SyncCentral.Users.User
  alias SyncCentral.Users.UserToken

  @hash_algorithm :sha256
  @rand_size 32

  @api_validity_in_days 1

  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    belongs_to :user, User

    timestamps(updated_at: false)
  end

  def verify_api_token_query(token, context) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)
        days = days_for_context(context)

        query =
          from token in by_token_and_context_query(hashed_token, context),
            join: user in assoc(token, :user),
            where: token.inserted_at > ago(^days, "day"),
            select: user

        {:ok, query}

      :error ->
        :error
    end
  end

  def build_api_token(user, context) do
    build_hashed_token(user, context)
  end

  defp build_hashed_token(user, context) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %UserToken{
       token: hashed_token,
       context: context,
       user_id: user.id
     }}
  end

  defp days_for_context("api-token"), do: @api_validity_in_days

  @doc """
  Returns the token struct for the given token value and context.
  """
  def by_token_and_context_query(token, context) do
    from UserToken, where: [token: ^token, context: ^context]
  end
end
