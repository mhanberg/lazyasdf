defmodule Lazyasdf do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Ratatouille.Runtime.Supervisor,
       runtime: [app: Lazyasdf.App, shutdown: {:application, :lazyasdf}]}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Lazyasdf.Supervisor)
  end

  def stop(_) do
    System.halt(0)
  end
end
