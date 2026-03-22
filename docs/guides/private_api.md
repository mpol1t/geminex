# Private API

Use `Geminex.API.Private` for authenticated account/order endpoints.

Common calls:

```elixir
{:ok, order} =
  Geminex.API.Private.new_order(
    "btcusd",
    "0.01",
    "50000",
    "buy",
    "exchange limit",
    client_order_id: "example-1"
  )

{:ok, active_orders} = Geminex.API.Private.active_orders()
{:ok, balances} = Geminex.API.Private.available_balances()
{:ok, cancel_all} = Geminex.API.Private.cancel_all_active_orders()
```

Request payload options are converted to Gemini API string-key shape before signing.
