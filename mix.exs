defmodule Geminex.MixProject do
  use Mix.Project
  @version "0.1.1"

  def project do
    [
      app: :geminex,
      version: @version,
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      description:
        "Geminex is an Elixir client for Gemini's API, providing streamlined access to trading, account management, and market data. It simplifies integration with Gemini’s REST API, handling authentication, requests, and responses for both public and private endpoints. ",
      package: [
        licenses: ["Apache-2.0"],
        links: %{
          "GitHub" => "https://github.com/mpol1t/geminex",
          "Changelog" => "https://github.com/mpol1t/geminex/blob/main/CHANGELOG.md"
        }
      ],
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.cobertura": :test
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.2"},
      {:mint, "~> 1.6"},
      {:tesla, "~> 1.16.0"},
      {:stream_data, "~> 1.3.0", only: :test},
      {:mox, "~> 1.2", only: :test},
      {:ex_doc, "~> 0.40.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:styler, "~> 1.11.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18.3", only: [:test], runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: "https://github.com/mpol1t/geminex",
      canonical: "https://hexdocs.pm/geminex",
      extras: [
        "README.md",
        "CHANGELOG.md",
        "LICENSE",
        "docs/guides/getting_started.md",
        "docs/guides/configuration.md",
        "docs/guides/public_api.md",
        "docs/guides/private_api.md",
        "docs/guides/authentication_and_nonce.md",
        "docs/guides/error_handling.md"
      ],
      groups_for_extras: [
        Project: ["README.md", "CHANGELOG.md", "LICENSE"],
        Guides: ~r/docs\/guides\/.*/
      ]
    ]
  end
end
