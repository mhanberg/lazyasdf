defmodule Lazyasdf.Pane.Versions do
  import Ratatouille.View
  import Ratatouille.Constants, only: [color: 1, key: 1]

  alias Ratatouille.Runtime.Command

  alias Lazyasdf.Window
  alias Lazyasdf.Asdf

  @arrow_up key(:arrow_up)
  @arrow_down key(:arrow_down)

  @style_selected [
    color: color(:black),
    background: color(:white)
  ]

  def init(plugins) do
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
     end), []}
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
    length(model[selected_plugin(global_model.plugins)].items)
  end

  defp install_count(model, global_model) do
    length(model[selected_plugin(global_model.plugins)].installed)
  end

  def selected_plugin(model) do
    Enum.at(model.list, model.cursor_y)
  end

  def render(selected, model, %{height: height, only_installed: only_installed} = global_model) do
    selected_model = model[selected_plugin(global_model.plugins)]

    panel title:
            selected_plugin(global_model.plugins) <>
              " (#{install_count(model, global_model)}/#{version_count(model, global_model)})",
          height: :fill do
      for {version, idx} <-
            if(only_installed, do: selected_model.installed, else: selected_model.items)
            |> Enum.drop(selected_model.y_offset)
            |> Enum.take(height - 3)
            |> Enum.with_index do
        row do
          column size: 12 do
            label do
              marker(selected_model, version)
              text(content: " ")

              text(
                [content: version] ++
                  if(selected && idx + selected_model.y_offset == selected_model.cursor_y,
                    do: @style_selected,
                    else: []
                  )
              )

              text(content: " ")
              spinner(selected_model, version)
            end
          end
        end
      end
    end
  end
end
