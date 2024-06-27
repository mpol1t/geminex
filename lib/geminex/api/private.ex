defmodule Geminex.API.Private do
  @moduledoc """
  Private API endpoints for Gemini.
  """

  alias Geminex.HttpClient

  @available_balances_url       "/v1/balances"
  @notional_balances_url        "/v1/notionalbalances/:currency"
  @transfers_url                "/v1/transfers"
  @transactions_url             "/v1/transactions"
  @custody_account_fees_url     "/v1/custodyaccountfees"
  @get_deposit_addresses_url    "/v1/addresses/:network"
  @new_deposit_address_url      "/v1/deposit/:network/newAddress"
  @withdraw_crypto_funds_url    "/v1/withdraw/:currency"
  @gas_fee_estimation_url       "/v1/withdraw/:currencyCodeLowerCase/feeEstimate"
  @internal_transfers_url       "/v1/account/transfer/:currency"
  @add_bank_url                 "/v1/payments/addbank"
  @add_bank_cad_url             "/v1/payments/addbank/cad"
  @payment_methods_url          "/v1/payments/methods"
  @earn_balances_url            "/v1/balances/earn"
  @earn_rates_url               "/v1/earn/rates"
  @earn_interest_url            "/v1/earn/interest"
  @earn_history_url             "/v1/earn/history"
  @staking_balances_url         "/v1/balances/staking"
  @staking_rates_url            "/v1/staking/rates"
  @staking_rewards_url          "/v1/staking/rewards"
  @staking_history_url          "/v1/staking/history"
  @staking_deposit_url          "/v1/staking/stake"
  @staking_withdrawal_url       "/v1/staking/unstake"
  @create_address_request_url   "/v1/approvedAddresses/:network/request"
  @view_approved_addresses_url  "/v1/approvedAddresses/account/:network"
  @remove_address_url           "/v1/approvedAddresses/:network/remove"
  @account_detail_url           "/v1/account"
  @create_account_url           "/v1/account/create"
  @rename_account_url           "/v1/account/rename"
  @get_accounts_url             "/v1/account/list"
  @heartbeat_url                "/v1/heartbeat"
  @orders_history_url           "/v1/orders/history"
  @my_trades_url                "/v1/mytrades"
  @orders_url                   "/v1/orders"
  @order_status_url             "/v1/order/status"
  @new_order_url                "/v1/order/new"
  @cancel_order_url             "/v1/order/cancel"
  @cancel_all_session_orders_url "/v1/order/cancel/session"
  @cancel_all_active_orders_url  "/v1/order/cancel/all"
  @notional_volume_url           "/v1/notionalvolume"
  @trade_volume_url              "/v1/tradevolume"

  @doc """
  Places a new order.

  ## Parameters

    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - symbol: The symbol for the new order.
    - amount: Quoted decimal amount to purchase.
    - price: Quoted decimal amount to spend per unit.
    - side: "buy" or "sell".
    - type: The order type. "exchange limit" or "exchange stop limit".
    - options: Optional. An array containing at most one supported order execution option.
    - stop_price: Optional. The price to trigger a stop-limit order (only for stop-limit orders).
    - client_order_id: Optional. A client-specified order id.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.new_order("mykey", "mysecret", "btcusd", "5", "3633.00", "buy", "exchange limit", ["maker-or-cancel"], nil, "my-client-id")
      {:ok, %{"order_id" => "106817811", "status" => "closed", ...}}

  """
  @spec new_order(String.t(), String.t(), String.t(), String.t(), String.t(), String.t(), String.t(), list(String.t()), String.t() | nil, String.t() | nil, boolean) :: {:ok, map} | {:error, any}
  def new_order(api_key, api_secret, symbol, amount, price, side, type, options \\ [], stop_price \\ nil, client_order_id \\ nil, use_prod \\ false) do
    payload = generate_payload(@new_order_url, %{
                                                 "symbol" => symbol,
                                                 "amount" => amount,
                                                 "price" => price,
                                                 "side" => side,
                                                 "type" => type,
                                                 "options" => options
                                               } |> Map.put_new("stop_price", stop_price)
                                               |> Map.put_new("client_order_id", client_order_id))

    HttpClient.post_with_payload(@new_order_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Cancels an order.

  ## Parameters

    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - order_id: The order ID to cancel.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.cancel_order("mykey", "mysecret", 106817811)
      {:ok, %{"order_id" => "106817811", "status" => "cancelled", ...}}

  """
  @spec cancel_order(String.t(), String.t(), integer, boolean) :: {:ok, map} | {:error, any}
  def cancel_order(api_key, api_secret, order_id, use_prod \\ false) do
    payload = generate_payload(@cancel_order_url, %{"order_id" => order_id})

    HttpClient.post_with_payload(@cancel_order_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Cancels all orders for the current session.

  ## Parameters

    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.cancel_all_session_orders("mykey", "mysecret")
      {:ok, %{"result" => "ok", "details" => %{"cancelledOrders" => [...], "cancelRejects" => [...]}}}

  """
  @spec cancel_all_session_orders(String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def cancel_all_session_orders(api_key, api_secret, use_prod \\ false) do
    payload = generate_payload(@cancel_all_session_orders_url, %{})

    HttpClient.post_with_payload(@cancel_all_session_orders_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Cancels all active orders.

  ## Parameters

    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.cancel_all_active_orders("mykey", "mysecret")
      {:ok, %{"result" => "ok", "details" => %{"cancelledOrders" => [...], "cancelRejects" => [...]}}}

  """
  @spec cancel_all_active_orders(String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def cancel_all_active_orders(api_key, api_secret, use_prod \\ false) do
    payload = generate_payload(@cancel_all_active_orders_url, %{})

    HttpClient.post_with_payload(@cancel_all_active_orders_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves the status of a specific order.

  ## Parameters

    - order_id: The order ID to get information on.
    - include_trades: Whether to include trade details.
    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.order_status(123456789012345, true, "mykey", "mysecret")
      {:ok, %{"order_id" => "123456789012345", "status" => "closed", ...}}

  """
  @spec order_status(integer, boolean, String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def order_status(api_key, api_secret, order_id, include_trades \\ false, use_prod \\ true) do
    payload = generate_payload(@order_status_url, %{
      "order_id" => order_id,
      "include_trades" => include_trades
    })

    HttpClient.post_with_payload(@order_status_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves all active orders.

  ## Parameters

    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.active_orders("mykey", "mysecret")
      {:ok, [%{"order_id" => "107421210", "status" => "live", ...}, ...]}

  """
  @spec active_orders(String.t(), String.t(), boolean) :: {:ok, list(map)} | {:error, any}
  def active_orders(api_key, api_secret, use_prod \\ true) do
    HttpClient.post_with_payload(@orders_url, generate_payload(@orders_url, %{}), api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves past trades for a specified symbol.

  ## Parameters

    - symbol: The trading pair symbol (e.g., BTCUSD).
    - opts: Optional parameters including limit_trades, timestamp.
    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.past_trades("btcusd", %{limit_trades: 50, timestamp: 0}, "mykey", "mysecret")
      {:ok, [%{"price" => "3648.09", "amount" => "0.0027343246", ...}, ...]}

  """
  @spec past_trades(String.t(), map, String.t(), String.t(), boolean) :: {:ok, list(map)} | {:error, any}
  def past_trades(api_key, api_secret, symbol, opts \\ %{}, use_prod \\ true) do
    payload = generate_payload(@my_trades_url, %{"symbol" => symbol} |> Map.merge(opts))

    HttpClient.post_with_payload(@my_trades_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves order history for an account.

  ## Parameters

    - timestamp: The timestamp from which to retrieve order history.
    - limit_orders: The maximum number of orders to return.
    - symbol: Optional. The symbol to retrieve orders for.
    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.orders_history(0, 50, "btcusd", "mykey", "mysecret")
      {:ok, [%{"order_id" => "73751560172006688", "symbol" => "ethgusd", ...}, ...]}

  """
  @spec orders_history(integer, integer, String.t() | nil, String.t(), String.t(), boolean) :: {:ok, list(map)} | {:error, any}
  def orders_history(api_key, api_secret, timestamp \\ 0, limit_orders \\ 50, symbol \\ nil, use_prod \\ true) do
    payload = generate_payload(
      @orders_history_url,
      %{
        "timestamp"     => timestamp,
        "limit_orders"  => limit_orders
      }
      |> Map.put_new("symbol", symbol)
    )

    HttpClient.post_with_payload(@orders_history_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves the notional volume for the account.

  ## Parameters

    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - symbol: Optional. The participating symbol for fee promotions.
    - account: Optional. The name of the account within the subaccount group.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.get_notional_volume("mykey", "mysecret", "btcusd", "myaccount")
      {:ok, %{"notional_30d_volume" => 150.00, "api_maker_fee_bps" => 10, ...}}

  """
  @spec get_notional_volume(String.t(), String.t(), String.t() | nil, String.t() | nil, boolean) :: {:ok, map} | {:error, any}
  def get_notional_volume(api_key, api_secret, symbol \\ nil, account \\ nil, use_prod \\ false) do
    payload = generate_payload(@notional_volume_url, %{}
                                                     |> Map.put_new("symbol", symbol)
                                                     |> Map.put_new("account", account))

    HttpClient.post_with_payload(@notional_volume_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves the trade volume for the account.

  ## Parameters

    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - account: Optional. The name of the account within the subaccount group.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.get_trade_volume("mykey", "mysecret", "myaccount")
      {:ok, [%{"symbol" => "btcusd", "total_volume_base" => 8.06021756, ...}, ...]}

  """
  @spec get_trade_volume(String.t(), String.t(), String.t() | nil, boolean) :: {:ok, list(map)} | {:error, any}
  def get_trade_volume(api_key, api_secret, account \\ nil, use_prod \\ false) do
    payload = generate_payload(@trade_volume_url, %{}
                                                  |> Map.put_new("account", account))

    HttpClient.post_with_payload(@trade_volume_url, payload, api_key, api_secret, use_prod)
  end

  defp generate_payload(request, params) do
    %{
      "request" => request,
      "nonce" => :os.system_time(:second)
    }
    |> Map.merge(params)
  end
end