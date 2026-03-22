[![codecov](https://codecov.io/gh/mpol1t/geminex/graph/badge.svg?token=LBmtXjUrNa)](https://codecov.io/gh/mpol1t/geminex)
[![Hex.pm](https://img.shields.io/hexpm/v/geminex.svg)](https://hex.pm/packages/geminex)
[![License](https://img.shields.io/github/license/mpol1t/geminex.svg)](https://github.com/mpol1t/geminex/blob/main/LICENSE)
[![Documentation](https://img.shields.io/badge/docs-hexdocs-blue.svg)](https://hexdocs.pm/geminex)
[![Build Status](https://github.com/mpol1t/geminex/actions/workflows/elixir.yml/badge.svg)](https://github.com/mpol1t/geminex/actions)
[![Elixir Version](https://img.shields.io/badge/elixir-~%3E%201.16-purple.svg)](https://elixir-lang.org/)

# Geminex

`geminex` is an Elixir REST client for Gemini public and private APIs.

## Documentation

HexDocs includes API reference plus focused guides:

- [Getting Started](docs/guides/getting_started.md)
- [Configuration](docs/guides/configuration.md)
- [Public API](docs/guides/public_api.md)
- [Private API](docs/guides/private_api.md)
- [Authentication and Nonce](docs/guides/authentication_and_nonce.md)
- [Error Handling](docs/guides/error_handling.md)

## Installation

Add `geminex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:geminex, "~> 0.1.1"}
  ]
end
```

Then fetch dependencies:

```bash
mix deps.get
```

## Quickstart

```elixir
import Config

config :geminex,
  environment: :sandbox,
  api_key: System.get_env("GEMINI_API_KEY"),
  api_secret: System.get_env("GEMINI_API_SECRET")
```

```elixir
{:ok, symbols} = Geminex.API.Public.symbols()
{:ok, balances} = Geminex.API.Private.available_balances()
```

## Notes

- Private API requests are signed in `Geminex.Middleware.Authentication`.
- Nonce generation uses second precision and is sourced from `System.os_time(:second)`.
- Default Tesla adapter is Mint; you can override Tesla adapter configuration in your app.

## Running Tests

```bash
mix test
```

## Running Dialyzer

```bash
mix dialyzer --plt
mix dialyzer
```

## License

Apache License 2.0. See [LICENSE](LICENSE).
