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
  @fx_rate_url                  "/v2/fxrate/:symbol/:timestamp"
  @account_margin_url           "/v1/margin"
  @risk_stats_url               "/v1/riskstats/:symbol"
  @funding_payment_url          "/v1/perpetuals/fundingPayment"
  @open_positions_url           "/v1/positions"
  @funding_payment_report_url   "/v1/perpetuals/fundingpaymentreport/records.xlsx"
  @new_clearing_order_url       "/v1/clearing/new"
  @clearing_broker_order_url    "/v1/clearing/broker/new"
  @clearing_order_status_url    "/v1/clearing/status"
  @cancel_clearing_order_url    "/v1/clearing/cancel"
  @confirm_clearing_order_url   "/v1/clearing/confirm"
  @clearing_order_list_url      "/v1/clearing/list"
  @clearing_broker_list_url     "/v1/clearing/broker/list"
  @clearing_trades_url          "/v1/clearing/trades"

  # Fund Management endpoints
  @get_balances_url "/v1/balances"
  @get_notional_balances_url "/v1/notionalbalances/:currency"
  @get_transfers_url "/v1/transfers"
  @get_transactions_url "/v1/transactions"
  @get_custody_fees_url "/v1/custodyaccountfees"
  @get_deposit_addresses_url "/v1/addresses/:network"
  @new_deposit_address_url "/v1/deposit/:network/newAddress"
  @withdraw_crypto_url "/v1/withdraw/:currency"
  @get_fee_estimate_url "/v1/withdraw/:currency/feeEstimate"
  @internal_transfer_url "/v1/account/transfer/:currency"
  @add_bank_url "/v1/payments/addbank"
  @add_bank_cad_url "/v1/payments/addbank/cad"
  @get_payment_methods_url "/v1/payments/methods"

  # Gemini Earn endpoints
  @get_earn_balances_url "/v1/balances/earn"
  @get_earn_rates_url "/v1/earn/rates"
  @get_earn_interest_url "/v1/earn/interest"
  @get_earn_history_url "/v1/earn/history"

  # Gemini Staking endpoints
  @get_staking_balances_url "/v1/balances/staking"
  @get_staking_rates_url "/v1/staking/rates"
  @get_staking_rewards_url "/v1/staking/rewards"
  @get_staking_history_url "/v1/staking/history"
  @staking_deposit_url "/v1/staking/stake"
  @staking_withdrawal_url "/v1/staking/unstake"

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
  def active_orders(api_key, api_secret, use_prod \\ false) do
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

  @doc """
  Retrieves the FX rate for the specified symbol at the given timestamp.

  ## Parameters

    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - symbol: The currency to check the USD FX rate against.
    - timestamp: The Unix timestamp to pull the FX rate for.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.get_fx_rate("mykey", "mysecret", "gbpusd", 1719520074000)
      {:ok, %{"fxPair" => "AUDUSD", "rate" => "0.69", ...}}

  """
  @spec get_fx_rate(String.t(), String.t(), String.t(), integer, boolean) :: {:ok, map} | {:error, any}
  def get_fx_rate(api_key, api_secret, symbol, timestamp, use_prod \\ true) do
    url = @fx_rate_url
          |> String.replace(":symbol", symbol)
          |> String.replace(":timestamp", Integer.to_string(timestamp))

    HttpClient.get_with_auth(url, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves the open positions for the account.

  ## Parameters

    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - account: Optional. The name of the account within the subaccount group.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.get_open_positions("mykey", "mysecret", "myaccount")
      {:ok, [%{"symbol" => "btcgusdperp", "quantity" => "0.2", ...}]}

  """
  @spec get_open_positions(String.t(), String.t(), String.t() | nil, boolean) :: {:ok, list(map)} | {:error, any}
  def get_open_positions(api_key, api_secret, account \\ nil, use_prod \\ false) do
    payload = generate_payload(@open_positions_url, %{}
                                                    |> Map.put_new("account", account))

    HttpClient.post_with_payload(@open_positions_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves the account margin information.

  ## Parameters

    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - symbol: The trading pair symbol (e.g., BTC-GUSD-PERP).
    - account: Optional. The name of the account within the subaccount group.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.get_account_margin("mykey", "mysecret", "BTC-GUSD-PERP", "myaccount")
      {:ok, %{"margin_assets_value" => "9800", "initial_margin" => "6000", ...}}

  """
  @spec get_account_margin(String.t(), String.t(), String.t(), String.t() | nil, boolean) :: {:ok, map} | {:error, any}
  def get_account_margin(api_key, api_secret, symbol, account \\ nil, use_prod \\ false) do
    payload = generate_payload(@account_margin_url, %{
                                                      "symbol" => symbol
                                                    } |> Map.put_new("account", account))

    HttpClient.post_with_payload(@account_margin_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves the risk stats for the specified symbol.

  ## Parameters

    - symbol: The trading pair symbol (e.g., BTCGUSDPERP).
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.get_risk_stats("BTCGUSDPERP")
      {:ok, %{"product_type" => "PerpetualSwapContract", "mark_price" => "30080.00", ...}}

  """
  @spec get_risk_stats(String.t(), boolean) :: {:ok, map} | {:error, any}
  def get_risk_stats(symbol, use_prod \\ false) do
    url = String.replace(@risk_stats_url, ":symbol", symbol)

    HttpClient.get_and_decode_with_switch(url, use_prod)
  end

  @doc """
  Retrieves the funding payments for the account.

  ## Parameters

    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - since: Optional. Only return funding payments after this point.
    - to: Optional. Only return funding payments until this point.
    - account: Optional. The name of the account within the subaccount group.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.get_funding_payments("mykey", "mysecret", 1609459200, 1612137600, "myaccount")
      {:ok, [%{"eventType" => "Hourly Funding Transfer", "timestamp" => 1683730803940, ...}]}

  """
  @spec get_funding_payments(String.t(), String.t(), integer | nil, integer | nil, String.t() | nil, boolean) :: {:ok, list(map)} | {:error, any}
  def get_funding_payments(api_key, api_secret, since \\ nil, to \\ nil, account \\ nil, use_prod \\ false) do
    payload = generate_payload(@funding_payment_url, %{}
                                                     |> Map.put_new("since", since)
                                                     |> Map.put_new("to", to)
                                                     |> Map.put_new("account", account))

    HttpClient.post_with_payload(@funding_payment_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Fetches the funding payment report file in Excel format.

  ## Parameters

    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - from_date: Optional. Start date for fetching records.
    - to_date: Optional. End date for fetching records.
    - num_rows: Optional. Maximum number of rows to fetch.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.funding_payment_report_file("mykey", "mysecret", "2024-04-10", "2024-04-25", 1000)
      {:ok, binary_data}

  """
  @spec funding_payment_report_file(String.t(), String.t(), String.t() | nil, String.t() | nil, integer | nil, boolean) :: {:ok, binary} | {:error, any}
  def funding_payment_report_file(api_key, api_secret, from_date \\ nil, to_date \\ nil, num_rows \\ 8760, use_prod \\ false) do
    query_params = %{
                     "fromDate" => from_date,
                     "toDate" => to_date,
                     "numRows" => num_rows
                   }
                   |> Enum.filter(fn {_, v} -> not is_nil(v) end)
                   |> Enum.into(%{})

    url = @funding_payment_report_url <> "?" <> URI.encode_query(query_params)

    HttpClient.get_with_auth(url, api_key, api_secret, use_prod)
  end

  @doc """
  Fetches the funding payment report in JSON format.

  ## Parameters

    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - from_date: Optional. Start date for fetching records.
    - to_date: Optional. End date for fetching records.
    - num_rows: Optional. Maximum number of rows to fetch.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.API.Private.funding_payment_report_json("mykey", "mysecret", "2024-04-10", "2024-04-25", 1000)
      {:ok, [%{"eventType" => "Hourly Funding Transfer", ...}]}

  """
  @spec funding_payment_report_json(String.t(), String.t(), String.t() | nil, String.t() | nil, integer | nil, boolean) :: {:ok, list(map)} | {:error, any}
  def funding_payment_report_json(api_key, api_secret, from_date \\ nil, to_date \\ nil, num_rows \\ 8760, use_prod \\ false) do
    query_params = %{
                     "fromDate" => from_date,
                     "toDate" => to_date,
                     "numRows" => num_rows
                   }
                   |> Enum.filter(fn {_, v} -> not is_nil(v) end)
                   |> Enum.into(%{})

    url = @funding_payment_report_url <> "?" <> URI.encode_query(query_params)

    HttpClient.get_with_auth(url, api_key, api_secret, use_prod)
  end

  @spec new_clearing_order(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def new_clearing_order(api_key, api_secret, order_params, use_prod \\ false) do
    payload = %{
                "request" => @new_clearing_order_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(order_params)

    HttpClient.post_with_payload(@new_clearing_order_url, payload, api_key, api_secret, use_prod)
  end

  @spec new_broker_order(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def new_broker_order(api_key, api_secret, order_params, use_prod \\ false) do
    payload = %{
                "request" => @clearing_broker_order_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(order_params)

    HttpClient.post_with_payload(@clearing_broker_order_url, payload, api_key, api_secret, use_prod)
  end

  @spec clearing_order_status(String.t(), String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def clearing_order_status(api_key, api_secret, clearing_id, use_prod \\ false) do
    payload = %{
      "request" => @clearing_order_status_url,
      "nonce" => :os.system_time(:second),
      "clearing_id" => clearing_id
    }

    HttpClient.post_with_payload(@clearing_order_status_url, payload, api_key, api_secret, use_prod)
  end

  @spec cancel_clearing_order(String.t(), String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def cancel_clearing_order(api_key, api_secret, clearing_id, use_prod \\ false) do
    payload = %{
      "request" => @cancel_clearing_order_url,
      "nonce" => :os.system_time(:second),
      "clearing_id" => clearing_id
    }

    HttpClient.post_with_payload(@cancel_clearing_order_url, payload, api_key, api_secret, use_prod)
  end

  @spec confirm_clearing_order(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def confirm_clearing_order(api_key, api_secret, confirm_params, use_prod \\ false) do
    payload = %{
                "request" => @confirm_clearing_order_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(confirm_params)

    HttpClient.post_with_payload(@confirm_clearing_order_url, payload, api_key, api_secret, use_prod)
  end

  @spec clearing_order_list(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def clearing_order_list(api_key, api_secret, list_params \\ %{}, use_prod \\ false) do
    payload = %{
                "request" => @clearing_order_list_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(list_params)

    HttpClient.post_with_payload(@clearing_order_list_url, payload, api_key, api_secret, use_prod)
  end

  @spec clearing_broker_list(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def clearing_broker_list(api_key, api_secret, list_params \\ %{}, use_prod \\ false) do
    payload = %{
                "request" => @clearing_broker_list_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(list_params)

    HttpClient.post_with_payload(@clearing_broker_list_url, payload, api_key, api_secret, use_prod)
  end

  @spec clearing_trades(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def clearing_trades(api_key, api_secret, trades_params \\ %{}, use_prod \\ false) do
    payload = %{
                "request" => @clearing_trades_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(trades_params)

    HttpClient.post_with_payload(@clearing_trades_url, payload, api_key, api_secret, use_prod)
  end

  @spec get_balances(String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def get_balances(api_key, api_secret, use_prod \\ false) do
    payload = %{
      "request" => @get_balances_url,
      "nonce" => :os.system_time(:second)
    }

    HttpClient.post_with_payload(@get_balances_url, payload, api_key, api_secret, use_prod)
  end

  @spec get_notional_balances(String.t(), String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def get_notional_balances(api_key, api_secret, currency, use_prod \\ false) do
    url = String.replace(@get_notional_balances_url, ":currency", currency)
    payload = %{
      "request" => url,
      "nonce" => :os.system_time(:second)
    }

    HttpClient.post_with_payload(url, payload, api_key, api_secret, use_prod)
  end

  @spec get_transfers(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_transfers(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = %{
                "request" => @get_transfers_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(params)

    HttpClient.post_with_payload(@get_transfers_url, payload, api_key, api_secret, use_prod)
  end

  @spec get_transactions(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_transactions(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = %{
                "request" => @get_transactions_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(params)

    HttpClient.post_with_payload(@get_transactions_url, payload, api_key, api_secret, use_prod)
  end

  @spec get_custody_fees(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_custody_fees(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = %{
                "request" => @get_custody_fees_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(params)

    HttpClient.post_with_payload(@get_custody_fees_url, payload, api_key, api_secret, use_prod)
  end

  @spec get_deposit_addresses(String.t(), String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_deposit_addresses(api_key, api_secret, network, params \\ %{}, use_prod \\ false) do
    url = String.replace(@get_deposit_addresses_url, ":network", network)
    payload = %{
                "request" => url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(params)

    HttpClient.post_with_payload(url, payload, api_key, api_secret, use_prod)
  end

  @spec new_deposit_address(String.t(), String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def new_deposit_address(api_key, api_secret, network, params \\ %{}, use_prod \\ false) do
    url = String.replace(@new_deposit_address_url, ":network", network)
    payload = %{
                "request" => url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(params)

    HttpClient.post_with_payload(url, payload, api_key, api_secret, use_prod)
  end

  @spec withdraw_crypto(String.t(), String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def withdraw_crypto(api_key, api_secret, currency, params \\ %{}, use_prod \\ false) do
    url = String.replace(@withdraw_crypto_url, ":currency", currency)
    payload = %{
                "request" => url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(params)

    HttpClient.post_with_payload(url, payload, api_key, api_secret, use_prod)
  end

  @spec get_fee_estimate(String.t(), String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_fee_estimate(api_key, api_secret, currency, params \\ %{}, use_prod \\ false) do
    url = String.replace(@get_fee_estimate_url, ":currency", currency)
    payload = %{
                "request" => url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(params)

    HttpClient.post_with_payload(url, payload, api_key, api_secret, use_prod)
  end

  @spec internal_transfer(String.t(), String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def internal_transfer(api_key, api_secret, currency, params \\ %{}, use_prod \\ false) do
    url = String.replace(@internal_transfer_url, ":currency", currency)
    payload = %{
                "request" => url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(params)

    HttpClient.post_with_payload(url, payload, api_key, api_secret, use_prod)
  end

  @spec add_bank(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def add_bank(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = %{
                "request" => @add_bank_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(params)

    HttpClient.post_with_payload(@add_bank_url, payload, api_key, api_secret, use_prod)
  end

  @spec add_bank_cad(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def add_bank_cad(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = %{
                "request" => @add_bank_cad_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(params)

    HttpClient.post_with_payload(@add_bank_cad_url, payload, api_key, api_secret, use_prod)
  end

  @spec get_payment_methods(String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def get_payment_methods(api_key, api_secret, use_prod \\ false) do
    payload = %{
      "request" => @get_payment_methods_url,
      "nonce" => :os.system_time(:second)
    }

    HttpClient.post_with_payload(@get_payment_methods_url, payload, api_key, api_secret, use_prod)
  end

  @spec get_earn_balances(String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def get_earn_balances(api_key, api_secret, use_prod \\ false) do
    payload = %{
      "request" => @get_earn_balances_url,
      "nonce" => :os.system_time(:second)
    }

    HttpClient.post_with_payload(@get_earn_balances_url, payload, api_key, api_secret, use_prod)
  end

  @spec get_earn_rates(boolean) :: {:ok, map} | {:error, any}
  def get_earn_rates(use_prod \\ false) do
    url = HttpClient.use_production_url(use_prod) <> @get_earn_rates_url
    HttpClient.get_and_decode(url)
  end

  @spec get_earn_interest(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_earn_interest(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = %{
                "request" => @get_earn_interest_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(params)

    HttpClient.post_with_payload(@get_earn_interest_url, payload, api_key, api_secret, use_prod)
  end

  @spec get_earn_history(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_earn_history(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = %{
                "request" => @get_earn_history_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(params)

    HttpClient.post_with_payload(@get_earn_history_url, payload, api_key, api_secret, use_prod)
  end

  @spec get_staking_balances(String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def get_staking_balances(api_key, api_secret, use_prod \\ false) do
    payload = %{
      "request" => @get_staking_balances_url,
      "nonce" => :os.system_time(:second)
    }

    HttpClient.post_with_payload(@get_staking_balances_url, payload, api_key, api_secret, use_prod)
  end

  @spec get_staking_rates(boolean) :: {:ok, map} | {:error, any}
  def get_staking_rates(use_prod \\ false) do
    url = HttpClient.use_production_url(use_prod) <> @get_staking_rates_url
    HttpClient.get_and_decode(url)
  end

  @spec get_staking_rewards(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_staking_rewards(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = %{
                "request" => @get_staking_rewards_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(params)

    HttpClient.post_with_payload(@get_staking_rewards_url, payload, api_key, api_secret, use_prod)
  end

  @spec get_staking_history(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_staking_history(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = %{
                "request" => @get_staking_history_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(params)

    HttpClient.post_with_payload(@get_staking_history_url, payload, api_key, api_secret, use_prod)
  end

  @spec staking_deposit(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def staking_deposit(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = %{
                "request" => @staking_deposit_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(params)

    HttpClient.post_with_payload(@staking_deposit_url, payload, api_key, api_secret, use_prod)
  end

  @spec staking_withdrawal(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def staking_withdrawal(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = %{
                "request" => @staking_withdrawal_url,
                "nonce" => :os.system_time(:second)
              } |> Map.merge(params)

    HttpClient.post_with_payload(@staking_withdrawal_url, payload, api_key, api_secret, use_prod)
  end

  defp generate_payload(request, params) do
    %{
      "request" => request,
      "nonce" => :os.system_time(:second)
    }
    |> Map.merge(params)
  end
end