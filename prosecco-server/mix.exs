defmodule Prosecco.MixProject do
  use Mix.Project

  def project do
    [
      app: :prosecco,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Prosecco.Server, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      {:sled, git: "https://github.com/ericentin/sled.git", branch: "master"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.2"},
      {:gproc, "0.8.0"},
      {:corsica, "~> 1.0"}
    ]
  end
end
