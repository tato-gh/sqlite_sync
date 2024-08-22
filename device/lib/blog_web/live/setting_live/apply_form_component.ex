defmodule BlogWeb.SettingLive.ApplyFormComponent do
  use BlogWeb, :live_component

  alias Blog.Setting

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.header>
        Apply device identity for this device
        <:subtitle>get identity to send your account information.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="apply-form"
        phx-target={@myself}
        phx-submit="save"
      >
        <.input field={@form[:email]} type="text" label="Email" />
        <.input field={@form[:password]} type="password" label="Password" />
        <:actions>
          <.button phx-disable-with="Sending...">Apply</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(%{"email" => "", "password" => ""})
     end)}
  end

  def handle_event("save", params, socket) do
    Setting.apply_device_identity(params)

    {:noreply,
      socket
      |> put_flash(:info, "Please wait for a response")
      |> push_patch(to: socket.assigns.patch)}
  end
end
