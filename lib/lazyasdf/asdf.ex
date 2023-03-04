defmodule Lazyasdf.Asdf do
  def current do
    asdf(["current"])
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn line ->
      [plugin, version | _] = String.split(line)

      {plugin, version}
    end)
  end

  def list_all(plugin) do
    asdf(["list", "all", plugin])
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reverse()
  end

  def list(plugin) do
    asdf(["list", plugin])
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.replace_prefix(&1, "*", ""))
    |> Enum.reject(&(&1 == "No versions installed"))
    |> Enum.reverse()
  end

  def plugin_list() do
    asdf(["plugin", "list"]) |> String.trim() |> String.split("\n")
  end

  def install(plugin, version) do
    asdf(["install", plugin, version])
  end

  def local(plugin, version) do
    asdf(["local", plugin, version])
  end

  def global(plugin, version) do
    asdf(["global", plugin, version])
  end

  def uninstall(plugin, version) do
    asdf(["uninstall", plugin, version])
  end

  defp asdf(args) do
    {output, 0} = System.cmd("asdf", args, stderr_to_stdout: true)
    output
  end
end
