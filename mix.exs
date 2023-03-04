defmodule Lazyasdf.MixProject do
  use Mix.Project

  def project do
    [
      app: :lazyasdf,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Lazyasdf, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ratatouille, github: "ndreynolds/ratatouille"}
    ]
  end
end
