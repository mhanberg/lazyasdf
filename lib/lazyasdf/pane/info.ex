defmodule Lazyasdf.Pane.Info do
  import Ratatouille.View

  alias Ratatouille.Runtime.Command

  alias Lazyasdf.Asdf

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

  def render(%{info: info, height: height} = _model) do
    height = height - 11

    panel title: "Info",
          height: height do
      for {p, v} <- info.plugins |> Enum.drop(0) |> Enum.take(max(height - 3, 0)) do
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
