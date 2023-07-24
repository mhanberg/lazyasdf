defmodule Lazyasdf.App do
  @behaviour Ratatouille.App

  alias Ratatouille.Runtime.Command
  import Ratatouille.View
  import Ratatouille.Constants, only: [key: 1]

  alias Lazyasdf.Pane.Plugins
  alias Lazyasdf.Pane.Versions
  alias Lazyasdf.Pane.Info
  alias Lazyasdf.Asdf

  @arrow_left key(:arrow_left)
  @arrow_right key(:arrow_right)

  defmodule Model do
    defstruct [:height, :width, :plugins, :versions, :info, selected_pane: :plugins, only_installed: true]
  end

  alias __MODULE__.Model

  @impl true
  def init(%{window: %{height: h, width: w}}) do
    {plugin_state, load_versions_for_first_plugin} = Plugins.init()
    {version_state, _} = Versions.init(plugin_state.list)
    {info_state, info_commands} = Info.init()

    {%Model{
       height: h,
       width: w,
       plugins: plugin_state,
       versions: version_state,
       info: info_state

     }, Command.batch(load_versions_for_first_plugin ++ info_commands)}
  end

  @impl true
  def update(%Model{} = model, msg) do
    new_model =
      case {model.selected_pane, msg} do
        {_, {:event, %{ch: ch, key: key}}} when ch == ?h or key == @arrow_left ->
          put_in(model.selected_pane, :plugins)

        {_, {:event, %{ch: ch, key: key}}} when ch == ?l or key == @arrow_right ->
          put_in(model.selected_pane, :versions)

        {_, {:event, %{ch: ?a}}} ->
          put_in(model.only_installed, !model.only_installed)

        {_, {{:refresh, plugin}, versions}} ->
          put_in(model.versions[plugin].items, versions)

        {_, {:current, plugins}} ->
          put_in(model.info.plugins, plugins)

        {_, {{:installed, plugin}, versions}} ->
          put_in(model.versions[plugin].installed, versions)

        {_, {{:local_finished, {plugin, version}}, :ok}} ->
          command = Command.new(fn -> Asdf.current() end, :current)

          {update_in(model.versions[plugin].localing, &List.delete(&1, version)), command}

        {_, {{:global_finished, {plugin, version}}, :ok}} ->
          command = Command.new(fn -> Asdf.current() end, :current)

          {update_in(model.versions[plugin].globaling, &List.delete(&1, version)), command}

        {_, {{:install_finished, {plugin, version}}, :ok}} ->
          command = Command.new(fn -> Asdf.list(plugin) end, {:installed, plugin})

          {update_in(model.versions[plugin].installing, &List.delete(&1, version)), command}

        {_, {{:uninstall_finished, {plugin, version}}, :ok}} ->
          command = Command.new(fn -> Asdf.list(plugin) end, {:installed, plugin})

          {update_in(model.versions[plugin].uninstalling, &List.delete(&1, version)), command}

        {:plugins, msg} ->
          case Plugins.update(model.plugins, msg) do
            {pmodel, command} ->
              {put_in(model.plugins, pmodel), command}

            pmodel ->
              put_in(model.plugins, pmodel)
          end

        {:versions, msg} ->
          case Versions.update(Plugins.selected(model.plugins), model.versions, model.only_installed, msg) do
            {vmodel, command} ->
              {put_in(model.versions, vmodel), command}

            vmodel ->
              put_in(model.versions, vmodel)
          end

        _ ->
          model
      end

    new_model
  end

  defp space(), do: text(content: " | ")

  defp help_bar(%{selected_pane: :versions} = model) do
    bar do
      label do
        text(content: "[h/j/k/l] movement")
        space()
        text(content: if(model.only_installed, do: "show [a]ll", else: "show only inst[a]lled"))
        space()
        text(content: "[i]nstall")
        space()
        text(content: "[u]ninstall")
        space()
        text(content: "set [L]ocal")
        space()
        text(content: "set [G]lobal")
        space()
        text(content: "[q]uit")
      end
    end
  end

  defp help_bar(model) do
    bar do
      label do
        text(content: "[h/j/k/l] movement")
        space()
        text(content: if(model.only_installed, do: "show [a]ll", else: "show only inst[a]lled"))
        space()
        text(content: "[q]uit")
      end
    end
  end

  @impl true
  def render(model) do
    view bottom_bar: help_bar(model) do
      row do
        column size: 6 do
          Info.render(model)
          Plugins.render(model.selected_pane == :plugins, model.plugins, model)
        end

        column size: 6 do
          Versions.render(model.selected_pane == :versions, model.versions, model)
        end
      end

      row do
        column size: 12 do
          label(content: "")
        end
      end
    end
  end
end
