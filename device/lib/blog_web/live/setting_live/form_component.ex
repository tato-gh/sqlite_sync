defmodule BlogWeb.SettingLive.FormComponent do
  use BlogWeb, :live_component

  alias Blog.Setting

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.header>
        Register your device identity and your passphrase to share devices.
        <:subtitle>Passphrase is stored only in this device. Remember the passphrase.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="form"
        phx-target={@myself}
        phx-submit="save"
      >
        <.input field={@form[:identity]} type="text" label="Identity" />
        <.input field={@form[:passphrase]} type="password" label="Passphrase" />
        <:actions>
          <.button phx-disable-with="Saving...">Save</.button>
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
       to_form(%{"identity" => "", "passphrase" => ""})
     end)}
  end

  def handle_event("save", params, socket) do
    Setting.create_setting(params)
    send(self(), :device_registered)

    {:noreply,
      socket
      |> put_flash(:info, "Start sharing")
      |> push_patch(to: socket.assigns.patch)}
  end
end
