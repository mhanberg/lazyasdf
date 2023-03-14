defmodule Lazyasdf.Pane.Plugins do
  import Ratatouille.Constants, only: [color: 1, key: 1]
  import Ratatouille.View

  alias Lazyasdf.Asdf

  @arrow_up key(:arrow_up)
  @arrow_down key(:arrow_down)

  @style_selected [
    color: color(:black),
    background: color(:white)
  ]

  def init() do
    plugins = Asdf.plugin_list()

    {%{
       list: plugins,
       cursor_y: 0,
       selected: List.first(plugins)
     }, []}
  end

  def selected(model) do
    Enum.at(model.list, model.cursor_y)
  end

  def update(model, msg) do
    case msg do
      {:event, %{ch: ch, key: key}} when ch == ?j or key == @arrow_down ->
        update_in(
          model.cursor_y,
          &min(&1 + 1, Enum.count(model.list) - 1)
        )

      {:event, %{ch: ch, key: key}} when ch == ?k or key == @arrow_up ->
        update_in(model.cursor_y, &max(&1 - 1, 0))

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
