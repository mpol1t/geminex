defmodule Geminex.MixProject do
  use Mix.Project

  def project do
    [
      app: :geminex,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison,    "~> 1.8"},
      {:jason,        "~> 1.2"},
      {:mox,          "~> 1.0",   only: :test},
      {:exvcr,        "~> 0.13",  only: :test},
      {:stream_data,  "~> 0.5.0", only: :test}
    ]
  end
end