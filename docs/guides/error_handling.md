# Error Handling

`geminex` returns tuple results:

- success: `{:ok, body}`
- API/http failure: `{:error, %{status: status, body: body}}`
- transport/client failure: `{:error, reason}`

Example:

```elixir
case Geminex.API.Private.active_orders() do
  {:ok, orders} ->
    {:ok, orders}

  {:error, %{status: status, body: body}} ->
    {:api_error, status, body}

  {:error, reason} ->
    {:transport_error, reason}
end
```
