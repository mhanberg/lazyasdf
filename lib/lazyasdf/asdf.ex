defmodule Lazyasdf.Asdf do
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
    |> Enum.reverse()
  end

  def plugin_list() do
    asdf(["plugin", "list"]) |> String.trim() |> String.split("\n")
  end

  def install(plugin, version) do
    asdf(["install", plugin, version])
  end

  defp asdf(args) do
    {output, 0} = System.cmd("asdf", args, stderr_to_stdout: true)
    output
  end
end
