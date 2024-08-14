defmodule BlogWeb.SettingLive.Show do
  use BlogWeb, :live_view

  alias Blog.Setting

  def mount(_params, _session, socket) do
    device = Setting.get_setting()
    {:ok, assign(socket, :device, device)}
  end

  def handle_params(_params, _url, socket) do
    %{live_action: live_action} = socket.assigns
    {:noreply, apply_action(socket, live_action)}
  end

  def handle_event("delete", _params, socket) do
    Setting.delete_setting()
    {:noreply, assign(socket, :device, nil)}
  end

  def handle_info(:device_registered, socket) do
    device = Setting.get_setting()
    {:noreply, assign(socket, :device, device)}
  end

  defp apply_action(socket, :apply) do
    socket
  end

  defp apply_action(socket, :new) do
    socket
  end

  defp apply_action(socket, _), do: socket
end
