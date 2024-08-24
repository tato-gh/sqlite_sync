defmodule BlogWeb.CryptorLive do
  @moduledoc """
  Elixir Desktopでの個別OSを考慮して共通鍵暗号方式をJavascriptで行うために用いるLiveViewプロセス

  refs:
  - [Communicating between LiveViews on the same page](https://thepugautomatic.com/2020/08/communicating-between-liveviews-on-the-same-page/)
  """

  use BlogWeb, :live_view

  alias Blog.Sync
  alias Blog.Posts

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
      Phoenix.PubSub.subscribe(Blog.PubSub, "retrieve")
    end

    socket =
      if connected?(socket) do
        assign_async(socket, :transactions, fn ->
          Sync.get_transactions()
          {:ok, %{transactions: []}}
        end)
      else
        socket
      end

    {:ok, assign(socket, :device, session["device"]), layout: false}
  end

  def handle_info({:transaction, raw_sql}, socket) do
    {:noreply,
      push_event(socket, "encode", %{raw: raw_sql, options: %{}})}
  end

  def handle_info({:encrypted_transactions, encrypted_list}, socket) do
    socket =
      Enum.reduce(encrypted_list, socket, fn encrypted, acc ->
        push_event(acc, "decode", %{encrypted: encrypted})
      end)

    {:noreply, socket}
  end

  def handle_event("test", _params, socket) do
    {:noreply,
      push_event(socket, "encode", %{raw: "test"})}
  end

  def handle_event("encrypted", params, socket) do
    Sync.send_transaction(params["encrypted"])

    {:noreply, socket}
  end

  def handle_event("decrypted", params, socket) do
    Posts.retrieve_transaction(params["raw"])

    {:noreply, socket}
  end
end
