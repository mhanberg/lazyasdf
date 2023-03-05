defmodule Lazyasdf.MixProject do
  use Mix.Project

  def project do
    [
      app: :lazyasdf,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      releases: releases(),
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

  def releases do
    [
      lazyasdf: [
        steps: [:assemble, &Burrito.wrap/1],
        burrito: [
          targets: [
            macos: [os: :darwin, cpu: :x86_64],
            macos_m1: [os: :darwin, cpu: :aarch64]
          ],
          debug: Mix.env() != :prod,
          no_clean: false
        ]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ratatouille, github: "ndreynolds/ratatouille"},
      {:burrito, github: "burrito-elixir/burrito"}
    ]
  end
end
