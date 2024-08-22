defmodule Blog.Setting do
  @moduledoc """
  The context that deals with managing the information of the device being operated.
  """

  alias Blog.Setting.Device

  @setting_file_name "setting.json"
  @access_token_file_name "access_token"

  def get_setting do
    path = get_setting_path()

    with {:ok, json} <- File.read(path),
         {:ok, data} <- Jason.decode(json) do
      struct(Device, Map.new(data, fn {k, v} -> {String.to_atom(k), v} end))
    else
      _ -> nil
    end
  end

  def apply_device_identity(_attrs) do
    # maybe post server api
    :ok
  end

  def create_setting(attrs) do
    path = get_setting_path()
    {:ok, json} = Jason.encode(attrs)
    File.write(path, json)
  end

  def delete_setting do
    get_setting_path() |> File.rm_rf()
  end

  def get_access_token do
    path = get_access_token_path()

    with {:ok, token} <- File.read(path) do
      token
    else
      _ -> nil
    end
  end

  def create_access_token(access_token) do
    path = get_access_token_path()
    File.write(path, access_token)
  end

  defp get_setting_path do
    Path.join([:code.priv_dir(:blog), @setting_file_name])
  end

  defp get_access_token_path do
    Path.join([:code.priv_dir(:blog), @access_token_file_name])
  end
end
