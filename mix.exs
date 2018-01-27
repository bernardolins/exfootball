defmodule Exfootball.Mixfile do
  use Mix.Project

  def project do
    [
      app: :exfootball,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      elixirc_paths: elixirc_paths(Mix.env),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:tesla, "0.10.0"},
      {:poison, ">= 1.0.0"},
      {:fake_server, github: "bernardolins/fake_server", branch: "feature/improve_route_response", only: :test},
      {:faker, "~> 0.9", only: :test}
    ]
  end
end
