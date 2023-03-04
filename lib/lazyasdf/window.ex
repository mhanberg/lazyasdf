defmodule Lazyasdf.Window do
  def calculate_y_offset(item = %{y_offset: y_offset, cursor_y: selected_row}) do
    height = Ratatouille.Window.fetch(:height) |> then(fn {:ok, h} -> h - 5 end)

    # recalculate the scroll position of the window based on which row is selected
    cond do
      y_offset > 0 and selected_row < height ->
        %{item | y_offset: y_offset - 1}

      selected_row < height ->
        %{item | y_offset: 0}

      y_offset > selected_row ->
        %{item | y_offset: selected_row}

      selected_row > height + y_offset ->
        %{item | y_offset: selected_row - height}

      true ->
        item
    end
  end
end
