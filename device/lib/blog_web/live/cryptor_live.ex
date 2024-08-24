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
      Phoenix.PubSub.subscribe(Blog.PubSub, "cud_query")
    end

    {:ok,
      assign(socket, :device, session["device"]),
      layout: false}
  end

  def handle_info({:transaction, raw_sql}, socket) do
    {:noreply,
      push_event(socket, "encode", %{raw: raw_sql, options: %{}})}
  end

  def handle_event("test", _params, socket) do
    {:noreply,
      push_event(socket, "encode", %{raw: "test"})}
  end

  def handle_event("encrypted", params, socket) do
    Blog.Sync.send_transaction(params["encrypted"])

    {:noreply, socket}
  end
end
