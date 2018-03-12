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

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:tesla, "~> 0.10.0"},
      {:hackney, "~> 1.11.0"},
      {:poison, ">= 1.0.0"},
      {:fake_server, "~> 1.4", only: :test},
      {:faker, "~> 0.9", only: :test}
    ]
  end
end
