# Public API

Use `Geminex.API.Public` for unauthenticated market-data endpoints.

Common calls:

```elixir
{:ok, symbols} = Geminex.API.Public.symbols()
{:ok, ticker} = Geminex.API.Public.ticker("btcusd")
{:ok, book} = Geminex.API.Public.current_order_book("btcusd", limit_bids: 50, limit_asks: 50)
{:ok, trades} = Geminex.API.Public.trade_history("btcusd", limit_trades: 100)
```

All functions return either `{:ok, payload}` or `{:error, reason}`.
