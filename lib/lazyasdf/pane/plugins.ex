defmodule Lazyasdf.Pane.Plugins do
  import Ratatouille.Constants, only: [color: 1, key: 1]
  import Ratatouille.View

  alias Ratatouille.Runtime.Command

  alias Lazyasdf.Asdf

  @arrow_up key(:arrow_up)
  @arrow_down key(:arrow_down)

  @style_selected [
    color: color(:black),
    background: color(:white)
  ]

  def init() do
    plugins = Asdf.plugin_list()
    selected = List.first(plugins)

    {%{
       list: plugins,
       cursor_y: 0,
       selected: selected
     }, [
       Command.new(fn -> Asdf.list_all(selected) end, {:refresh, selected}),
       Command.new(fn -> Asdf.list(selected) end, {:installed, selected})
     ]}
  end

  def selected(model) do
    Enum.at(model.list, model.cursor_y)
  end

  def update(model, msg) do
    case msg do
      {:event, %{ch: ch, key: key}} when ch == ?j or key == @arrow_down ->
        new_cursor_y = min(model.cursor_y + 1, Enum.count(model.list) - 1)
        selected = Enum.at(model.list, new_cursor_y)

        {
          update_in(model.cursor_y, fn _ -> new_cursor_y end),
          Command.batch([
            Command.new(fn -> Asdf.list_all(selected) end, {:refresh, selected}),
            Command.new(fn -> Asdf.list(selected) end, {:installed, selected})
          ])
        }

      {:event, %{ch: ch, key: key}} when ch == ?k or key == @arrow_up ->
        new_cursor_y = max(model.cursor_y - 1, 0)
        selected = Enum.at(model.list, new_cursor_y)

        {
          update_in(model.cursor_y, &max(&1 - 1, 0)),
          Command.batch([
            Command.new(fn -> Asdf.list_all(selected) end, {:refresh, selected}),
            Command.new(fn -> Asdf.list(selected) end, {:installed, selected})
          ])
        }

      _ ->
        model
    end
  end

  def render(selected, model, _) do
    y_offset = max(0, model.cursor_y - 5)

    panel title: "Plugins",
          height: 10 do
      for {plugin, idx} <-
        model.list
        |> Enum.drop(y_offset)
        |> Enum.take(10 - 3)
        |> Enum.with_index do
        row do
          column size: 12 do
            label(
              [content: plugin] ++
                if(selected && idx + y_offset == model.cursor_y, do: @style_selected, else: [])
            )
          end
        end
      end
    end
  end
end
