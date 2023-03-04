defmodule Lazyasdf.Pane.Info do
  import Ratatouille.Constants, only: [color: 1, key: 1]
  import Ratatouille.View

  alias Ratatouille.Runtime.Command

  alias Lazyasdf.Asdf

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
    command = Command.new(fn -> Asdf.current() end, :current)

    {%{
       cursor_y: 0,
       plugins: []
     }, [command]}
  end

  def update(model) do
    model
  end

  def render(%{info: info} = _model) do
    panel title: "Info" do
      for {p, v} <- info.plugins do
        row do
          column size: 3 do
            label do
              text(content: p)
            end
          end
          column size: 9 do
            label do
              text(content: v)
            end
          end
        end
      end
    end
  end
end
