defmodule Lazyasdf.Pane.Plugins do
  import Ratatouille.Constants, only: [color: 1, key: 1]
  import Ratatouille.View

  @arrow_up key(:arrow_up)
  @arrow_down key(:arrow_down)
  @arrow_left key(:arrow_left)
  @arrow_right key(:arrow_right)
  @enter key(:enter)

  @style_selected [
    color: color(:black),
    background: color(:white)
  ]

  def init() do
    {output, 0} = System.cmd("asdf", ["plugin", "list"])
    plugins = output |> String.trim() |> String.split("\n")

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
    end
  end

  def render(selected, model, _) do
    panel title: "Plugins" do
      table do
        for {plugin, idx} <- Enum.with_index(model.list) do
          table_row do
            table_cell(
              [content: plugin] ++
                if(selected && idx == model.cursor_y, do: @style_selected, else: [])
            )
          end
        end
      end
    end
  end
end
