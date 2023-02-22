defmodule Lazyasdf do
  @moduledoc """
  Documentation for `Lazyasdf`.
  """

  defmodule App do
    @behaviour Ratatouille.App

    alias Ratatouille.Runtime.Command
    import Ratatouille.View
    import Ratatouille.Constants, only: [color: 1, key: 1]

    @arrow_up key(:arrow_up)
    @arrow_down key(:arrow_down)
    @arrow_left key(:arrow_left)
    @arrow_right key(:arrow_right)

    @style_selected [
      color: color(:black),
      background: color(:white)
    ]

    def init(%{window: %{height: h, width: w}}) do
      {output, 0} = System.cmd("asdf", ["plugin", "list"])
      plugins = output |> String.trim() |> String.split("\n")

      commands =
        for p <- plugins do
          Command.new(
            fn ->
              {output, 0} = System.cmd("asdf", ["list", "all", p])
              output |> String.trim() |> String.split("\n")
            end,
            {:refresh, p}
          )
        end

      {%{
         height: h,
         width: w,
         selected_pane: :plugins,
         plugins: %{
           list: plugins,
           cursor_y: 0,
           selected: List.first(plugins)
         },
         versions:
           Map.new(plugins, fn p -> {p, %{items: ["Loading..."], cursor_y: 0, y_offset: 0}} end)
       }, Command.batch(commands)}
    end

    def update(model, msg) do
      new_model =
        case {model.selected_pane, msg} do
          {:plugins, {:event, %{ch: ch, key: key}}} when ch == ?j or key == @arrow_down ->
            update_in(
              model.plugins.cursor_y,
              &min(&1 + 1, Enum.count(model.plugins.list) - 1)
            )

          {:plugins, {:event, %{ch: ch, key: key}}} when ch == ?k or key == @arrow_up ->
            update_in(model.plugins.cursor_y, &max(&1 - 1, 0))

          {:versions, {:event, %{ch: ch, key: key}}} when ch == ?j or key == @arrow_down ->
            update_in(
              model.versions[selected_plugin(model)].cursor_y,
              &min(&1 + 1, Enum.count(model.versions[selected_plugin(model)].items) - 1)
            )
            |> then(
              &put_in(
                &1.versions[selected_plugin(model)],
                calculate_y_offset(&1, &1.versions[selected_plugin(&1)])
              )
            )

          {:versions, {:event, %{ch: ch, key: key}}} when ch == ?k or key == @arrow_up ->
            update_in(model.versions[selected_plugin(model)].cursor_y, &max(&1 - 1, 0))
            |> then(
              &put_in(
                &1.versions[selected_plugin(model)],
                calculate_y_offset(&1, &1.versions[selected_plugin(&1)])
              )
            )

          {_, {:event, %{ch: ch, key: key}}} when ch == ?h or key == @arrow_left ->
            put_in(model.selected_pane, :plugins)

          {_, {:event, %{ch: ch, key: key}}} when ch == ?l or key == @arrow_right ->
            put_in(model.selected_pane, :versions)

          {_, {{:refresh, plugin}, versions}} ->
            put_in(model.versions[plugin].items, versions)

          _ ->
            model
        end

      new_model
    end

    defp selected_plugin(model) do
      Enum.at(model.plugins.list, model.plugins.cursor_y)
    end

    defp calculate_y_offset(model, item = %{y_offset: y_offset, cursor_y: selected_row}) do
      height = model.height - 5
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

    def render(model) do
      view do
        row do
          column size: 6 do
            panel title: "Plugins" do
              table do
                for {plugin, idx} <- Enum.with_index(model.plugins.list) do
                  table_row do
                    table_cell(
                      [content: plugin] ++
                        if(model.selected_pane == :plugins && idx == model.plugins.cursor_y,
                          do: @style_selected,
                          else: []
                        )
                    )
                  end
                end
              end
            end
          end

          column size: 6 do
            panel title: selected_plugin(model), height: :fill do
              viewport offset_y: model.versions[selected_plugin(model)].y_offset do
                table do
                  for {version, idx} <-
                        Enum.with_index(model.versions[selected_plugin(model)].items) do
                    table_row do
                      table_cell(
                        [content: version] ++
                          if(
                            model.selected_pane == :versions &&
                              idx == model.versions[selected_plugin(model)].cursor_y,
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
      end
    end
  end

  def start do
    Ratatouille.run(Lazyasdf.App)
  end
end
