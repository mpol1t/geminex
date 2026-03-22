# Configuration

`geminex` reads configuration from `:geminex` application env.

## Required private-api config

- `:environment` - `:sandbox` or `:production`
- `:api_key`
- `:api_secret`

## Example

```elixir
import Config

config :geminex,
  environment: :sandbox,
  api_key: System.get_env("GEMINI_API_KEY"),
  api_secret: System.get_env("GEMINI_API_SECRET")
```

## Tesla adapter

Default adapter is Mint:

```elixir
config :tesla, adapter: Tesla.Adapter.Mint
```

You can override adapter/options globally per Tesla documentation.
