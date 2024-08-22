defmodule BlogWeb.LoginComponent do
  @moduledoc """
  """

  use BlogWeb, :live_component

  alias Blog.Setting
  alias Blog.Sync

  def render(assigns) do
    ~H"""
    <div id={@id} class="mx-auto max-w-sm">
      <.header class="text-center">
        Sign in to account to sync multiple devices
      </.header>

      <.simple_form
        id="form-login"
        for={@form}
        phx-submit="login"
        phx-target={@myself}
      >
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <p :if={@error} class="text-red-600">
          ログインに失敗しました
        </p>

        <:actions>
          <.button phx-disable-with="Signing in..." class="w-full">
            Sign in <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(assigns, socket) do
    form = to_form(%{"email" => "", "password" => ""})

    {:ok,
      socket
      |> assign(assigns)
      |> assign(:error, false)
      |> assign(:form, form)}
  end

  def handle_event("login", params, socket) do
    Sync.fetch_access_token(params)
    |> case do
      nil ->
        form = to_form(Map.take(params, ["email"]))

        {:noreply,
          socket
          |> assign(:error, true)
          |> assign(:form, form)}

      access_token ->
        Setting.create_access_token(access_token)
        send(self(), :logged_in)
        {:noreply, socket}
    end
  end
end
