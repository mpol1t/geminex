[![codecov](https://codecov.io/gh/mpol1t/geminex/graph/badge.svg?token=LBmtXjUrNa)](https://codecov.io/gh/mpol1t/geminex)
[![Hex.pm](https://img.shields.io/hexpm/v/geminex.svg)](https://hex.pm/packages/geminex)
[![License](https://img.shields.io/github/license/mpol1t/geminex.svg)](https://github.com/mpol1t/geminex/blob/main/LICENSE)
[![Documentation](https://img.shields.io/badge/docs-hexdocs-blue.svg)](https://hexdocs.pm/geminex)
[![Build Status](https://github.com/mpol1t/geminex/actions/workflows/elixir.yml/badge.svg)](https://github.com/mpol1t/geminex/actions)
<!--[![Downloads](https://img.shields.io/hexpm/dt/geminex.svg)](https://hex.pm/packages/geminex)-->
<!--[![Last Commit](https://img.shields.io/github/last-commit/mpol1t/geminex.svg)](https://github.com/mpol1t/geminex/commits/main)-->
[![Elixir Version](https://img.shields.io/badge/elixir-~%3E%201.16-purple.svg)](https://elixir-lang.org/)

# Geminex

Geminex is an Elixir client for the [Gemini API](https://docs.gemini.com/), offering easy access to trading, account management, and market data. With both public and private endpoints, it supports order placement, balance checks, market data retrieval, and more, all while abstracting the complexities of API interaction.

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
    - [Public API](#public-api)
    - [Private API](#private-api)
- [Error Handling](#error-handling)
- [Running Tests](#running-tests)
- [Running Dialyzer](#running-dialyzer)
- [Contributing](#contributing)
- [License](#license)

## Features

- Access to **public API** endpoints for market data and trading symbols
- **Private API** for order placement, trades, account management, staking, and more
- Built-in **middleware** for authentication and environment switching
- Simplified **error handling** for cleaner code integration

## Installation

Add `geminex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:geminex, "~> 0.0.4"}
  ]
end
```

Then, run:

```bash
mix deps.get
```

## Configuration

Configure `Geminex` in your application’s configuration file. Set the environment and provide your Gemini API credentials. You can choose between sandbox and production environments.

**config/config.exs**:

```elixir
import Config

config :geminex,
       environment: :sandbox,             # Options: :sandbox or :production
       api_key:     System.get_env("GEMINI_API_KEY"),
       api_secret:  System.get_env("GEMINI_API_SECRET")
```

Replace `<api_key>` and `<api_secret>` with your Gemini API credentials.
## Usage

Geminex offers both **public** and **private** APIs for interacting with Gemini's exchange.

### Public API

The public API allows access to trading symbols, order books, and market data. These endpoints do not require authentication.

```elixir
# Retrieve all available trading symbols
{:ok, symbols} = Geminex.API.Public.symbols()

# Fetch ticker data for a specific symbol
{:ok, ticker_data} = Geminex.API.Public.ticker("btcusd")
```

### Private API

The private API enables management of orders, trades, account settings, staking, and more. These endpoints require valid API credentials and are restricted by Gemini’s account access policies.

```elixir
# Place a new order
{:ok, order_response} = Geminex.API.Private.new_order("btcusd", "0.1", "50000", "buy", "exchange limit", client_order_id: "order_12345")

# Retrieve account balance
{:ok, balances} = Geminex.API.Private.available_balances()
```

### Error Handling

All functions return `{:ok, result}` on success and `{:error, reason}` on failure. You can use pattern matching to handle these responses effectively:

```elixir
case Geminex.API.Public.symbols() do
  {:ok, symbols} ->
    IO.inspect(symbols)

  {:error, reason} ->
    IO.puts("Failed to retrieve symbols: #{inspect(reason)}")
end
```

### Running Tests

To run tests:

```bash
mix test
```

### Running Dialyzer

For static analysis with Dialyzer, make sure PLTs are built:

```bash
mix dialyzer --plt
mix dialyzer
```

## Contributing

Feel free to open issues or submit PRs to enhance the functionality. Contributions are welcome!

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.
