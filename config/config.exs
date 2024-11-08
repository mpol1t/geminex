import Config

config :geminex,
  environment: :sandbox,
  api_key: "<api_key>",
  api_secret: "<api_secret>"

config :tesla, adapter: Tesla.Adapter.Mint

config :logger, level: :warning
