defmodule Lazyasdf.Pane.Versions do
  import Ratatouille.View
  import Ratatouille.Constants, only: [color: 1, key: 1]

  alias Ratatouille.Runtime.Command

  alias Lazyasdf.Window
  alias Lazyasdf.Asdf
  alias Lazyasdf.Pane.Plugins

  @arrow_up key(:arrow_up)
  @arrow_down key(:arrow_down)

  @style_selected [
    color: color(:black),
    background: color(:white)
  ]

  def init(plugins) do
    version_commands =
      for p <- plugins, do: Command.new(fn -> Asdf.list_all(p) end, {:refresh, p})

    installed_commands =
      for p <- plugins, do: Command.new(fn -> Asdf.list(p) end, {:installed, p})

    {Map.new(plugins, fn p ->
       {p,
        %{
          items: ["Loading..."],
          cursor_y: 0,
          y_offset: 0,
          installed: [],
          installing: [],
          localing: [],
          globaling: [],
          uninstalling: []
        }}
     end), version_commands ++ installed_commands}
  end

  def update(plugin, model, msg) do
    case msg do
      {:event, %{ch: ?G}} ->
        selected_version = selected_version(plugin, model)

        {update_in(model[plugin].globaling, &[selected_version | &1]),
         Command.new(
           fn ->
             Asdf.global(plugin, selected_version)

             :ok
           end,
           {:global_finished, {plugin, selected_version}}
         )}

      {:event, %{ch: ?L}} ->
        selected_version = selected_version(plugin, model)

        {update_in(model[plugin].localing, &[selected_version | &1]),
         Command.new(
           fn ->
             Asdf.local(plugin, selected_version)

             :ok
           end,
           {:local_finished, {plugin, selected_version}}
         )}

      {:event, %{ch: ?u}} ->
        selected_version = selected_version(plugin, model)

        {update_in(model[plugin].uninstalling, &[selected_version | &1]),
         Command.new(
           fn ->
             Asdf.uninstall(plugin, selected_version)

             :ok
           end,
           {:uninstall_finished, {plugin, selected_version}}
         )}

      {:event, %{ch: ?i}} ->
        selected_version = selected_version(plugin, model)

        {update_in(model[plugin].installing, &[selected_version | &1]),
         Command.new(
           fn ->
             Asdf.install(plugin, selected_version)

             :ok
           end,
           {:install_finished, {plugin, selected_version}}
         )}

      {:event, %{ch: ch, key: key}} when ch == ?j or key == @arrow_down ->
        update_in(model[plugin].cursor_y, &min(&1 + 1, Enum.count(model[plugin].items) - 1))
        |> then(&put_in(&1[plugin], Window.calculate_y_offset(&1[plugin])))

      {:event, %{ch: ch, key: key}} when ch == ?k or key == @arrow_up ->
        update_in(model[plugin].cursor_y, &max(&1 - 1, 0))
        |> then(&put_in(&1[plugin], Window.calculate_y_offset(&1[plugin])))

      _ ->
        model
    end
  end

  defp selected_version(plugin, model) do
    plugin_versions = model[plugin]

    Enum.at(plugin_versions.items, plugin_versions.cursor_y)
  end

  defp marker(model, version) do
    if version in model.installed do
      text(content: "*", color: color(:green))
    else
      text(content: " ")
    end
  end

  defp spinner(model, version) do
    cond do
      version in model.installing ->
        text(content: "🔄")

      version in model.uninstalling ->
        text(content: "🗑️")

      version in model.localing ->
        text(content: "🏠")

      version in model.globaling ->
        text(content: "🌎")

      true ->
        text(content: " ")
    end
  end

  defp version_count(model, global_model) do
    length(model[Plugins.selected(global_model.plugins)].items)
  end

  defp install_count(model, global_model) do
    length(model[Plugins.selected(global_model.plugins)].installed)
  end

  defp title(model, global_model) do
    Plugins.selected(global_model.plugins) <>
      " (#{install_count(model, global_model)}/#{version_count(model, global_model)})"
  end

  def render(selected, model, global_model) do
    panel title: title(model, global_model), height: :fill do
      viewport offset_y: model[Plugins.selected(global_model.plugins)].y_offset do
        for {version, idx} <-
              Enum.with_index(model[Plugins.selected(global_model.plugins)].items) do
          row do
            column size: 12 do
              label do
                marker(model[Plugins.selected(global_model.plugins)], version)
                text(content: " ")

                text(
                  [content: version] ++
                    if(selected && idx == model[Plugins.selected(global_model.plugins)].cursor_y,
                      do: @style_selected,
                      else: []
                    )
                )

                text(content: " ")
                spinner(model[Plugins.selected(global_model.plugins)], version)
              end
            end
          end
        end
      end
    end
  end
end
