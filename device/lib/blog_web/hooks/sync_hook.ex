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

  def on_mount(:maybe_require_login, _params, _sesison, %{
      assigns: %{device: nil}
    } = socket) do
    # アカウント設定をしていないので特になにもしない
    {:cont, assign(socket, :require_login, false)}
  end

  def on_mount(:maybe_require_login, _params, _sesison, %{
      assigns: %{device: device, access_token: nil}
    } = socket) when not is_nil(device) do
    # アクセストークンがないためログインを促す
    socket =
      socket
      |> assign(:require_login, true)
      |> attach_hook(:login, :handle_info, &handle_info/2)

    {:cont, socket}
  end

  def on_mount(:maybe_require_login, _params, _sesison, socket) do
    {:cont, assign(socket, :require_login, false)}
  end

  def on_mount(:prepare_cryptor, _params, _sesison, socket) do
    {:cont,
      socket
      |> assign(:cryptor, nil)
      |> attach_hook(:cryptor, :handle_info, &handle_info/2)}
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

  defp handle_info(_, socket) do
    {:cont, socket}
  end
end
