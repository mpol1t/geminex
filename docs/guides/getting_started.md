# Getting Started

`geminex` provides public and private REST clients for Gemini.

## Install

```elixir
def deps do
  [
    {:geminex, "~> 0.1.1"}
  ]
end
```

## Configure

```elixir
import Config

config :geminex,
  environment: :sandbox,
  api_key: System.get_env("GEMINI_API_KEY"),
  api_secret: System.get_env("GEMINI_API_SECRET")
```

## Call public and private endpoints

```elixir
{:ok, symbols} = Geminex.API.Public.symbols()
{:ok, balances} = Geminex.API.Private.available_balances()
```

## Next

- See [Configuration](configuration.md)
- See [Authentication and Nonce](authentication_and_nonce.md)
