defmodule Blog.Setting do
  @moduledoc """
  The context that deals with managing the information of the device being operated.
  """

  alias Blog.Setting.Device

  @file_name "setting.json"

  def get_setting do
    path = get_path()

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
    path = get_path()
    {:ok, json} = Jason.encode(attrs)
    File.write(path, json)
  end

  def delete_setting do
    File.rm_rf(get_path())
  end

  defp get_path do
    Path.join([:code.priv_dir(:blog), @file_name])
  end
end
