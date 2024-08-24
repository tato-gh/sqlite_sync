defmodule BlogWeb.CryptorLive do
  @moduledoc """
  Elixir Desktopでの個別OSを考慮して共通鍵暗号方式をJavascriptで行うために用いるLiveViewプロセス

  refs:
  - [Communicating between LiveViews on the same page](https://thepugautomatic.com/2020/08/communicating-between-liveviews-on-the-same-page/)
  """

  use BlogWeb, :live_view

  def render(assigns) do
    ~H"""
    <div
      id="process-cryptor"
      phx-hook="Cryption"
      data-salt={@device.identity}
    >
      <button phx-click="test">test</button>
    </div>
    """
  end

  def mount(_params, session, socket) do
    if connected?(socket) do
      send(socket.transport_pid, {:cryptor_setup, self()})
    end

    {:ok,
      assign(socket, :device, session["device"]),
      layout: false}
  end

  def handle_info({:cryption_request, raw, options}, socket) do
    {:noreply,
      push_event(socket, "encode", %{raw: raw, options: options})}
  end

  def handle_event("test", _params, socket) do
    {:noreply,
      push_event(socket, "encode", %{raw: "test"})}
  end

  def handle_event("encrypted", params, socket) do
    send(socket.transport_pid, {:encrypted, params["encrypted"], params["options"]})

    {:noreply, socket}
  end
end
