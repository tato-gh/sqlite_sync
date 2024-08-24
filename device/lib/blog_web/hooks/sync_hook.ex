defmodule BlogWeb.SyncHook do
  @moduledoc """
  for SyncCentral
  """

  import Phoenix.Component, only: [assign: 3]
  import Phoenix.LiveView, only: [attach_hook: 4]

  require Logger

  alias Blog.Setting

  def on_mount(:load_setting, _params, _session, socket) do
    device = Setting.get_setting()
    {:cont, assign(socket, :device, device)}
  end

  def on_mount(:load_access_token, _params, _sesison, socket) do
    access_token = Setting.get_access_token()
    {:cont, assign(socket, :access_token, access_token)}
  end

  def on_mount(:fetch_transactions, _params, _sesison, %{
      assigns: %{device: nil}
    } = socket) do
    # アカウント設定をしていないので特になにもしない
    {:cont, assign(socket, :require_login, false)}
  end

  def on_mount(:fetch_transactions, _params, _sesison, %{
      assigns: %{device: device, access_token: nil}
    } = socket) when not is_nil(device) do
    # アクセストークンがないためログインを促す
    socket =
      socket
      |> assign(:require_login, true)
      |> attach_hook(:login, :handle_info, &handle_info/2)

    {:cont, socket}
  end

  def on_mount(:fetch_transactions, _params, _sesison, socket) do
    # TODO: 同期を行う
    {:cont, assign(socket, :require_login, false)}
  end

  def on_mount(:prepare_cryptor, _params, _sesison, socket) do
    {:cont,
      socket
      |> assign(:cryptor, nil)
      |> attach_hook(:cryptor, :handle_info, &handle_info/2)}
  end

  # for repo telemetry only CUD
  def handle_event(_, _measurements, %{options: [schema_migration: true]}, _config) do
    # nothing to do
  end

  def handle_event(
    [:blog, :repo, :query],
    _measurements,
    %{result: {:ok, %{columns: []}}} = meta,
    _config
  ) do
    send(self(), {:send_sql, gen_sql_from_log(meta)})
  end

  def handle_event([:blog, :repo, :query], _measurements, _meta, _config) do
    # SELECT and others nothing to do
  end

  defp handle_info(:logged_in, socket) do
    access_token = Setting.get_access_token()

    {:cont,
      socket
      |> assign(:require_login, false)
      |> assign(:access_token, access_token)}
  end

  defp handle_info({:cryptor_setup, cryptor_id}, socket) do
    {:cont, assign(socket, :cryptor, cryptor_id)}
  end

  defp handle_info({:send_sql, sql}, socket) do
    %{cryptor: cryptor} = socket.assigns

    if cryptor do
      send(cryptor, {:cryption_request, sql, :transaction})
    end

    {:cont, socket}
  end

  defp handle_info({:encrypted, encrypted_sql, :transaction}, socket) do
    IO.inspect(encrypted_sql, label: "=================== DEBUG")
    {:cont, socket}
  end

  defp handle_info(_, socket) do
    {:cont, socket}
  end

  defp gen_sql_from_log(meta) do
    Enum.reduce(meta.params, meta.query, fn
      value, sql when not is_bitstring(value) ->
        String.replace(sql, "?", to_string(value), global: false)

      value, sql ->
        String.replace(sql, "?", value, global: false)
    end)
  end
end
