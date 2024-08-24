defmodule Blog.RepoLog do
  @moduledoc """
  Repo telemetry only CUD
  """

  def handle_event(_, _measurements, %{options: [schema_migration: true]}, _config) do
    # nothing to do
  end

  def handle_event(_, _measurements, %{stacktrace: nil}, _config) do
    # nothing to do
    # TODO: improve to prevent ignition when acquiring transaction (import)
  end

  def handle_event(
    [:blog, :repo, :query],
    _measurements,
    %{result: {:ok, %{columns: []}}} = meta,
    _config
  ) do
    Phoenix.PubSub.broadcast(Blog.PubSub, "cud_query", {:transaction, gen_sql_from_log(meta)})
  end

  def handle_event([:blog, :repo, :query], _measurements, _meta, _config) do
    # SELECT and others nothing to do
  end

  defp gen_sql_from_log(meta) do
    Enum.reduce(meta.params, meta.query, fn
      value, sql when not is_bitstring(value) ->
        String.replace(sql, "?", "'" <> to_string(value) <> "'", global: false)

      value, sql ->
        String.replace(sql, "?", "'" <> value <> "'", global: false)
    end)
  end
end
