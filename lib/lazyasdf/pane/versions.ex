defmodule Lazyasdf.Pane.Versions do
  import Ratatouille.View
  import Ratatouille.Constants, only: [color: 1, key: 1]

  alias Ratatouille.Runtime.Command

  alias Lazyasdf.Window
  alias Lazyasdf.Asdf
  alias Lazyasdf.Pane.Plugins

  @arrow_up key(:arrow_up)
  @arrow_down key(:arrow_down)
  @enter key(:enter)

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
       {p, %{items: ["Loading..."], cursor_y: 0, y_offset: 0, installed: []}}
     end), version_commands ++ installed_commands}
  end

  def update(plugin, model, msg) do
    case msg do
      {:event, %{key: key}} when key == @enter ->
        selected_version = selected_version(plugin, model)

        {model,
         Command.new(
           fn ->
             {_, 0} =
               System.cmd("asdf", ["install", plugin, selected_version], stderr_to_stdout: true)

             :ok
           end,
           {:install_finished, plugin}
         )}

      {:event, %{ch: ch, key: key}} when ch == ?j or key == @arrow_down ->
        update_in(model[plugin].cursor_y, &min(&1 + 1, Enum.count(model[plugin].items) - 1))
        |> then(&put_in(&1[plugin], Window.calculate_y_offset(&1[plugin])))

      {:event, %{ch: ch, key: key}} when ch == ?k or key == @arrow_up ->
        update_in(model[plugin].cursor_y, &max(&1 - 1, 0))
        |> then(&put_in(&1[plugin], Window.calculate_y_offset(&1[plugin])))
    end
  end

  defp selected_version(plugin, model) do
    plugin_versions = model[plugin]

    Enum.at(plugin_versions.items, plugin_versions.cursor_y)
  end

  defp plugin_version(model, version) do
    installed =
      if version in model.installed do
        "* "
      else
        "  "
      end

    installed <> version
  end

  def render(selected, model, global_model) do
    panel title: Plugins.selected(global_model.plugins), height: :fill do
      viewport offset_y: model[Plugins.selected(global_model.plugins)].y_offset do
        table do
          for {version, idx} <-
                Enum.with_index(model[Plugins.selected(global_model.plugins)].items) do
            table_row do
              table_cell(
                [content: plugin_version(model[Plugins.selected(global_model.plugins)], version)] ++
                  if(selected && idx == model[Plugins.selected(global_model.plugins)].cursor_y,
                    do: @style_selected,
                    else: []
                  )
              )
            end
          end
        end
      end
    end
  end
end
