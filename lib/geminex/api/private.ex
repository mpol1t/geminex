defmodule Geminex.API.Private do
  @moduledoc """
  Private API endpoints for Gemini.
  """

  alias Geminex.HttpClient

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

  # Gemini Approved Address endpoints
  @create_address_request_url "/v1/approvedAddresses/:network/request"
  @view_approved_addresses_url "/v1/approvedAddresses/account/:network"
  @remove_address_url "/v1/approvedAddresses/:network/remove"

  # Gemini Account Administration endpoints
  @account_detail_url "/v1/account"
  @create_account_url "/v1/account/create"
  @rename_account_url "/v1/account/rename"
  @get_accounts_in_master_group_url "/v1/account/list"

  # Gemini Session Heartbeat endpoint
  @heartbeat_url "/v1/heartbeat"

  # Trading and Order Management endpoints
  @new_order_url "/v1/order/new"
  @cancel_order_url "/v1/order/cancel"
  @cancel_all_session_orders_url "/v1/order/cancel/session"
  @cancel_all_active_orders_url "/v1/order/cancel/all"
  @order_status_url "/v1/order/status"
  @orders_history_url "/v1/orders/history"
  @my_trades_url "/v1/mytrades"
  @orders_url "/v1/orders"

  # Volume and Notional endpoints
  @notional_volume_url "/v1/notionalvolume"
  @trade_volume_url "/v1/tradevolume"
  @notional_balances_url "/v1/notionalbalances/:currency"

  # FX Rate and Margin endpoints
  @fx_rate_url "/v2/fxrate/:symbol/:timestamp"
  @account_margin_url "/v1/margin"
  @risk_stats_url "/v1/riskstats/:symbol"

  # Perpetuals and Funding Payment endpoints
  @funding_payment_url "/v1/perpetuals/fundingPayment"
  @funding_payment_report_url "/v1/perpetuals/fundingpaymentreport/records.xlsx"
  @get_open_positions_url "/v1/positions"

  # Clearing endpoints
  @new_clearing_order_url "/v1/clearing/new"
  @clearing_broker_order_url "/v1/clearing/broker/new"
  @clearing_order_status_url "/v1/clearing/status"
  @cancel_clearing_order_url "/v1/clearing/cancel"
  @confirm_clearing_order_url "/v1/clearing/confirm"
  @clearing_order_list_url "/v1/clearing/list"
  @clearing_broker_list_url "/v1/clearing/broker/list"
  @clearing_trades_url "/v1/clearing/trades"

  @doc """
  Places a new order.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `order_params`: A map containing the following keys:
    - `symbol`: The symbol for the new order.
    - `amount`: Quoted decimal amount to purchase.
    - `price`: Quoted decimal amount to spend per unit.
    - `side`: "buy" or "sell".
    - `type`: The order type. "exchange limit" or "exchange stop limit".
    - `options`: Optional. An array containing at most one supported order execution option.
    - `stop_price`: Optional. The price to trigger a stop-limit order (only for stop-limit orders).
    - `client_order_id`: Optional. A client-specified order id.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec new_order(
          String.t(),
          String.t(),
          map(),
          boolean
        ) :: {:ok, map} | {:error, any}
  def new_order(
        api_key,
        api_secret,
        %{"symbol" => symbol, "amount" => amount, "price" => price, "side" => side, "type" => type} = order_params,
        use_prod \\ false
      ) do
    # Set default values for optional parameters
    options = Map.get(order_params, "options", [])
    stop_price = Map.get(order_params, "stop_price", nil)
    client_order_id = Map.get(order_params, "client_order_id", nil)

    # Build the payload
    payload =
      generate_payload(
        @new_order_url,
        %{
          "symbol" => symbol,
          "amount" => amount,
          "price" => price,
          "side" => side,
          "type" => type,
          "options" => options
        }
        |> Map.put_new("stop_price", stop_price)
        |> Map.put_new("client_order_id", client_order_id)
      )

    # Send the HTTP request
    HttpClient.post_with_payload(@new_order_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Cancels an order.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `order_id`: The order ID to cancel.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec cancel_order(String.t(), String.t(), integer, boolean) :: {:ok, map} | {:error, any}
  def cancel_order(api_key, api_secret, order_id, use_prod \\ false) do
    payload = generate_payload(@cancel_order_url, %{"order_id" => order_id})

    HttpClient.post_with_payload(@cancel_order_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Cancels all orders for the current session.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec cancel_all_session_orders(String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def cancel_all_session_orders(api_key, api_secret, use_prod \\ false) do
    payload = generate_payload(@cancel_all_session_orders_url, %{})

    HttpClient.post_with_payload(@cancel_all_session_orders_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Cancels all active orders.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec cancel_all_active_orders(String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def cancel_all_active_orders(api_key, api_secret, use_prod \\ false) do
    payload = generate_payload(@cancel_all_active_orders_url, %{})

    HttpClient.post_with_payload(@cancel_all_active_orders_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves the status of a specific order.

  ## Parameters
  - `order_id`: The order ID to get information on.
  - `include_trades`: Whether to include trade details.
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec order_status(integer, boolean, String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def order_status(api_key, api_secret, order_id, include_trades \\ false, use_prod \\ true) do
    payload =
      generate_payload(@order_status_url, %{
        "order_id" => order_id,
        "include_trades" => include_trades
      })

    HttpClient.post_with_payload(@order_status_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves all active orders.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec active_orders(String.t(), String.t(), boolean) :: {:ok, list(map)} | {:error, any}
  def active_orders(api_key, api_secret, use_prod \\ false) do
    HttpClient.post_with_payload(@orders_url, generate_payload(@orders_url, %{}), api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves past trades for a specified symbol.

  ## Parameters
  - `symbol`: The trading pair symbol (e.g., BTCUSD).
  - `opts`: Optional parameters including limit_trades, timestamp.
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec past_trades(String.t(), map, String.t(), String.t(), boolean) :: {:ok, list(map)} | {:error, any}
  def past_trades(api_key, api_secret, symbol, opts \\ %{}, use_prod \\ true) do
    payload = generate_payload(@my_trades_url, Map.merge(%{"symbol" => symbol}, opts))

    HttpClient.post_with_payload(@my_trades_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves order history for an account.

  ## Parameters
  - `timestamp`: The timestamp from which to retrieve order history.
  - `limit_orders`: The maximum number of orders to return.
  - `symbol`: Optional. The symbol to retrieve orders for.
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec orders_history(integer, integer, String.t() | nil, String.t(), String.t(), boolean) ::
          {:ok, list(map)} | {:error, any}
  def orders_history(api_key, api_secret, timestamp \\ 0, limit_orders \\ 50, symbol \\ nil, use_prod \\ true) do
    payload =
      generate_payload(
        @orders_history_url,
        Map.put_new(%{"timestamp" => timestamp, "limit_orders" => limit_orders}, "symbol", symbol)
      )

    HttpClient.post_with_payload(@orders_history_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves the notional volume for the account.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `symbol`: Optional. The participating symbol for fee promotions.
  - `account`: Optional. The name of the account within the subaccount group.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_notional_volume(String.t(), String.t(), String.t() | nil, String.t() | nil, boolean) ::
          {:ok, map} | {:error, any}
  def get_notional_volume(api_key, api_secret, symbol \\ nil, account \\ nil, use_prod \\ false) do
    payload =
      generate_payload(
        @notional_volume_url,
        %{}
        |> Map.put_new("symbol", symbol)
        |> Map.put_new("account", account)
      )

    HttpClient.post_with_payload(@notional_volume_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves the trade volume for the account.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `account`: Optional. The name of the account within the subaccount group.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_trade_volume(String.t(), String.t(), String.t() | nil, boolean) :: {:ok, list(map)} | {:error, any}
  def get_trade_volume(api_key, api_secret, account \\ nil, use_prod \\ false) do
    payload = generate_payload(@trade_volume_url, Map.put_new(%{}, "account", account))

    HttpClient.post_with_payload(@trade_volume_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves the FX rate for the specified symbol at the given timestamp.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `symbol`: The currency to check the USD FX rate against.
  - `timestamp`: The Unix timestamp to pull the FX rate for.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_fx_rate(String.t(), String.t(), String.t(), integer, boolean) :: {:ok, map} | {:error, any}
  def get_fx_rate(api_key, api_secret, symbol, timestamp, use_prod \\ true) do
    url =
      @fx_rate_url
      |> String.replace(":symbol", symbol)
      |> String.replace(":timestamp", Integer.to_string(timestamp))

    HttpClient.get_with_auth(url, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves the open positions for the account.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `account`: Optional. The name of the account within the subaccount group.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_open_positions(String.t(), String.t(), String.t() | nil, boolean) :: {:ok, list(map)} | {:error, any}
  def get_open_positions(api_key, api_secret, account \\ nil, use_prod \\ false) do
    payload = generate_payload(@open_positions_url, Map.put_new(%{}, "account", account))

    HttpClient.post_with_payload(@open_positions_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves the account margin information.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `symbol`: The trading pair symbol (e.g., BTC-GUSD-PERP).
  - `account`: Optional. The name of the account within the subaccount group.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_account_margin(String.t(), String.t(), String.t(), String.t() | nil, boolean) :: {:ok, map} | {:error, any}
  def get_account_margin(api_key, api_secret, symbol, account \\ nil, use_prod \\ false) do
    payload = generate_payload(@account_margin_url, Map.put_new(%{"symbol" => symbol}, "account", account))

    HttpClient.post_with_payload(@account_margin_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves the risk stats for the specified symbol.

  ## Parameters
  - `symbol`: The trading pair symbol (e.g., BTCGUSDPERP).
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_risk_stats(String.t(), boolean) :: {:ok, map} | {:error, any}
  def get_risk_stats(symbol, use_prod \\ false) do
    url = String.replace(@risk_stats_url, ":symbol", symbol)

    HttpClient.get_and_decode_with_switch(url, use_prod)
  end

  @doc """
  Retrieves the funding payments for the account.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `since`: Optional. Only return funding payments after this point.
  - `to`: Optional. Only return funding payments until this point.
  - `account`: Optional. The name of the account within the subaccount group.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_funding_payments(String.t(), String.t(), integer | nil, integer | nil, String.t() | nil, boolean) ::
          {:ok, list(map)} | {:error, any}
  def get_funding_payments(api_key, api_secret, since \\ nil, to \\ nil, account \\ nil, use_prod \\ false) do
    payload =
      generate_payload(
        @funding_payment_url,
        %{}
        |> Map.put_new("since", since)
        |> Map.put_new("to", to)
        |> Map.put_new("account", account)
      )

    HttpClient.post_with_payload(@funding_payment_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Fetches the funding payment report file in Excel format.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `from_date`: Optional. Start date for fetching records.
  - `to_date`: Optional. End date for fetching records.
  - `num_rows`: Optional. Maximum number of rows to fetch.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec funding_payment_report_file(
          String.t(),
          String.t(),
          String.t() | nil,
          String.t() | nil,
          integer | nil,
          boolean
        ) :: {:ok, binary} | {:error, any}
  def funding_payment_report_file(
        api_key,
        api_secret,
        from_date \\ nil,
        to_date \\ nil,
        num_rows \\ 8760,
        use_prod \\ false
      ) do
    query_params =
      %{
        "fromDate" => from_date,
        "toDate" => to_date,
        "numRows" => num_rows
      }
      |> Enum.filter(fn {_, v} -> not is_nil(v) end)
      |> Map.new()

    url = @funding_payment_report_url <> "?" <> URI.encode_query(query_params)

    HttpClient.get_with_auth(url, api_key, api_secret, use_prod)
  end

  @doc """
  Fetches the funding payment report in JSON format.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `from_date`: Optional. Start date for fetching records.
  - `to_date`: Optional. End date for fetching records.
  - `num_rows`: Optional. Maximum number of rows to fetch.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec funding_payment_report_json(
          String.t(),
          String.t(),
          String.t() | nil,
          String.t() | nil,
          integer | nil,
          boolean
        ) :: {:ok, list(map)} | {:error, any}
  def funding_payment_report_json(
        api_key,
        api_secret,
        from_date \\ nil,
        to_date \\ nil,
        num_rows \\ 8760,
        use_prod \\ false
      ) do
    query_params =
      %{
        "fromDate" => from_date,
        "toDate" => to_date,
        "numRows" => num_rows
      }
      |> Enum.filter(fn {_, v} -> not is_nil(v) end)
      |> Map.new()

    url = @funding_payment_report_url <> "?" <> URI.encode_query(query_params)

    HttpClient.get_with_auth(url, api_key, api_secret, use_prod)
  end

  @doc """
  Creates a new clearing order.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `order_params`: The parameters for the new order.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec new_clearing_order(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def new_clearing_order(api_key, api_secret, order_params, use_prod \\ false) do
    payload = Map.merge(%{"request" => @new_clearing_order_url, "nonce" => :os.system_time(:second)}, order_params)

    HttpClient.post_with_payload(@new_clearing_order_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Creates a new broker order.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `order_params`: The parameters for the new order.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec new_broker_order(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def new_broker_order(api_key, api_secret, order_params, use_prod \\ false) do
    payload = Map.merge(%{"request" => @clearing_broker_order_url, "nonce" => :os.system_time(:second)}, order_params)

    HttpClient.post_with_payload(@clearing_broker_order_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves the status of a clearing order.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `clearing_id`: The clearing ID of the order.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec clearing_order_status(String.t(), String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def clearing_order_status(api_key, api_secret, clearing_id, use_prod \\ false) do
    payload = %{
      "request" => @clearing_order_status_url,
      "nonce" => :os.system_time(:second),
      "clearing_id" => clearing_id
    }

    HttpClient.post_with_payload(@clearing_order_status_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Cancels a clearing order.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `clearing_id`: The clearing ID of the order.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec cancel_clearing_order(String.t(), String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def cancel_clearing_order(api_key, api_secret, clearing_id, use_prod \\ false) do
    payload = %{
      "request" => @cancel_clearing_order_url,
      "nonce" => :os.system_time(:second),
      "clearing_id" => clearing_id
    }

    HttpClient.post_with_payload(@cancel_clearing_order_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Confirms a clearing order.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `confirm_params`: The parameters for confirming the order.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec confirm_clearing_order(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def confirm_clearing_order(api_key, api_secret, confirm_params, use_prod \\ false) do
    payload = Map.merge(%{"request" => @confirm_clearing_order_url, "nonce" => :os.system_time(:second)}, confirm_params)

    HttpClient.post_with_payload(@confirm_clearing_order_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Lists clearing orders.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `list_params`: Optional parameters for listing orders.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec clearing_order_list(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def clearing_order_list(api_key, api_secret, list_params \\ %{}, use_prod \\ false) do
    payload = Map.merge(%{"request" => @clearing_order_list_url, "nonce" => :os.system_time(:second)}, list_params)

    HttpClient.post_with_payload(@clearing_order_list_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Lists clearing broker orders.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `list_params`: Optional parameters for listing orders.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec clearing_broker_list(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def clearing_broker_list(api_key, api_secret, list_params \\ %{}, use_prod \\ false) do
    payload = Map.merge(%{"request" => @clearing_broker_list_url, "nonce" => :os.system_time(:second)}, list_params)

    HttpClient.post_with_payload(@clearing_broker_list_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Lists clearing trades.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `trades_params`: Optional parameters for listing trades.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec clearing_trades(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def clearing_trades(api_key, api_secret, trades_params \\ %{}, use_prod \\ false) do
    payload = Map.merge(%{"request" => @clearing_trades_url, "nonce" => :os.system_time(:second)}, trades_params)

    HttpClient.post_with_payload(@clearing_trades_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves account balances.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_balances(String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def get_balances(api_key, api_secret, use_prod \\ false) do
    payload = %{
      "request" => @get_balances_url,
      "nonce" => :os.system_time(:second)
    }

    HttpClient.post_with_payload(@get_balances_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves notional balances for a specified currency.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `currency`: The currency to retrieve notional balances for.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_notional_balances(String.t(), String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def get_notional_balances(api_key, api_secret, currency, use_prod \\ false) do
    url = String.replace(@get_notional_balances_url, ":currency", currency)

    payload = %{
      "request" => url,
      "nonce" => :os.system_time(:second)
    }

    HttpClient.post_with_payload(url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves transfer history.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `params`: Optional parameters for retrieving transfers.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_transfers(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_transfers(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = Map.merge(%{"request" => @get_transfers_url, "nonce" => :os.system_time(:second)}, params)

    HttpClient.post_with_payload(@get_transfers_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves transaction history.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `params`: Optional parameters for retrieving transactions.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_transactions(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_transactions(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = Map.merge(%{"request" => @get_transactions_url, "nonce" => :os.system_time(:second)}, params)

    HttpClient.post_with_payload(@get_transactions_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves custody fees.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `params`: Optional parameters for retrieving custody fees.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_custody_fees(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_custody_fees(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = Map.merge(%{"request" => @get_custody_fees_url, "nonce" => :os.system_time(:second)}, params)

    HttpClient.post_with_payload(@get_custody_fees_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves deposit addresses for a specified network.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `network`: The network to retrieve deposit addresses for.
  - `params`: Optional parameters for retrieving deposit addresses.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_deposit_addresses(String.t(), String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_deposit_addresses(api_key, api_secret, network, params \\ %{}, use_prod \\ false) do
    url = String.replace(@get_deposit_addresses_url, ":network", network)
    payload = Map.merge(%{"request" => url, "nonce" => :os.system_time(:second)}, params)

    HttpClient.post_with_payload(url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Creates a new deposit address for a specified network.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `network`: The network to create a new deposit address for.
  - `params`: Optional parameters for creating a new deposit address.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec new_deposit_address(String.t(), String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def new_deposit_address(api_key, api_secret, network, params \\ %{}, use_prod \\ false) do
    url = String.replace(@new_deposit_address_url, ":network", network)
    payload = Map.merge(%{"request" => url, "nonce" => :os.system_time(:second)}, params)

    HttpClient.post_with_payload(url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Withdraws cryptocurrency.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `currency`: The currency to withdraw.
  - `params`: Optional parameters for withdrawing cryptocurrency.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec withdraw_crypto(String.t(), String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def withdraw_crypto(api_key, api_secret, currency, params \\ %{}, use_prod \\ false) do
    url = String.replace(@withdraw_crypto_url, ":currency", currency)
    payload = Map.merge(%{"request" => url, "nonce" => :os.system_time(:second)}, params)

    HttpClient.post_with_payload(url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves fee estimate for a specified currency.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `currency`: The currency to retrieve fee estimate for.
  - `params`: Optional parameters for retrieving fee estimate.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_fee_estimate(String.t(), String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_fee_estimate(api_key, api_secret, currency, params \\ %{}, use_prod \\ false) do
    url = String.replace(@get_fee_estimate_url, ":currency", currency)
    payload = Map.merge(%{"request" => url, "nonce" => :os.system_time(:second)}, params)

    HttpClient.post_with_payload(url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Transfers funds internally within an account.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `currency`: The currency to transfer.
  - `params`: Optional parameters for transferring funds.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec internal_transfer(String.t(), String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def internal_transfer(api_key, api_secret, currency, params \\ %{}, use_prod \\ false) do
    url = String.replace(@internal_transfer_url, ":currency", currency)
    payload = Map.merge(%{"request" => url, "nonce" => :os.system_time(:second)}, params)

    HttpClient.post_with_payload(url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Adds a new bank account.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `params`: Optional parameters for adding a new bank account.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec add_bank(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def add_bank(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = Map.merge(%{"request" => @add_bank_url, "nonce" => :os.system_time(:second)}, params)

    HttpClient.post_with_payload(@add_bank_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Adds a new CAD bank account.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `params`: Optional parameters for adding a new CAD bank account.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec add_bank_cad(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def add_bank_cad(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = Map.merge(%{"request" => @add_bank_cad_url, "nonce" => :os.system_time(:second)}, params)

    HttpClient.post_with_payload(@add_bank_cad_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves payment methods.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_payment_methods(String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def get_payment_methods(api_key, api_secret, use_prod \\ false) do
    payload = %{
      "request" => @get_payment_methods_url,
      "nonce" => :os.system_time(:second)
    }

    HttpClient.post_with_payload(@get_payment_methods_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves Gemini Earn balances.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_earn_balances(String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def get_earn_balances(api_key, api_secret, use_prod \\ false) do
    payload = %{
      "request" => @get_earn_balances_url,
      "nonce" => :os.system_time(:second)
    }

    HttpClient.post_with_payload(@get_earn_balances_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves Gemini Earn rates.

  ## Parameters
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_earn_rates(boolean) :: {:ok, map} | {:error, any}
  def get_earn_rates(use_prod \\ false) do
    url = HttpClient.use_production_url(use_prod) <> @get_earn_rates_url
    HttpClient.get_and_decode(url)
  end

  @doc """
  Retrieves Gemini Earn interest.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `params`: Optional parameters for retrieving Earn interest.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_earn_interest(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_earn_interest(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = Map.merge(%{"request" => @get_earn_interest_url, "nonce" => :os.system_time(:second)}, params)

    HttpClient.post_with_payload(@get_earn_interest_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves Gemini Earn history.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `params`: Optional parameters for retrieving Earn history.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_earn_history(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_earn_history(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = Map.merge(%{"request" => @get_earn_history_url, "nonce" => :os.system_time(:second)}, params)

    HttpClient.post_with_payload(@get_earn_history_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves Gemini Staking balances.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_staking_balances(String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def get_staking_balances(api_key, api_secret, use_prod \\ false) do
    payload = %{
      "request" => @get_staking_balances_url,
      "nonce" => :os.system_time(:second)
    }

    HttpClient.post_with_payload(@get_staking_balances_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves Gemini Staking rates.

  ## Parameters
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_staking_rates(boolean) :: {:ok, map} | {:error, any}
  def get_staking_rates(use_prod \\ false) do
    url = HttpClient.use_production_url(use_prod) <> @get_staking_rates_url
    HttpClient.get_and_decode(url)
  end

  @doc """
  Retrieves Gemini Staking rewards.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `params`: Optional parameters for retrieving Staking rewards.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_staking_rewards(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_staking_rewards(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = Map.merge(%{"request" => @get_staking_rewards_url, "nonce" => :os.system_time(:second)}, params)

    HttpClient.post_with_payload(@get_staking_rewards_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves Gemini Staking history.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `params`: Optional parameters for retrieving Staking history.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_staking_history(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def get_staking_history(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = Map.merge(%{"request" => @get_staking_history_url, "nonce" => :os.system_time(:second)}, params)

    HttpClient.post_with_payload(@get_staking_history_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Deposits funds for staking.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `params`: Optional parameters for staking deposit.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec staking_deposit(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def staking_deposit(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = Map.merge(%{"request" => @staking_deposit_url, "nonce" => :os.system_time(:second)}, params)

    HttpClient.post_with_payload(@staking_deposit_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Withdraws funds from staking.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `params`: Optional parameters for staking withdrawal.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec staking_withdrawal(String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def staking_withdrawal(api_key, api_secret, params \\ %{}, use_prod \\ false) do
    payload = Map.merge(%{"request" => @staking_withdrawal_url, "nonce" => :os.system_time(:second)}, params)

    HttpClient.post_with_payload(@staking_withdrawal_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Creates an approved address request.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `network`: The network for the address.
  - `address`: The address to be approved.
  - `label`: The label for the approved address.
  - `account`: Optional. The account within the subaccount group.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec create_address_request(String.t(), String.t(), String.t(), String.t(), String.t(), map, boolean) ::
          {:ok, map} | {:error, any}
  def create_address_request(api_key, api_secret, network, address, label, account \\ nil, use_prod \\ false) do
    payload = %{
      "request" => String.replace(@create_address_request_url, ":network", network),
      "nonce" => :os.system_time(:second),
      "address" => address,
      "label" => label,
      "account" => account
    }

    HttpClient.post_with_payload(@create_address_request_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Views approved addresses.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `network`: The network for the address.
  - `account`: Optional. The account within the subaccount group.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec view_approved_addresses(String.t(), String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def view_approved_addresses(api_key, api_secret, network, account \\ nil, use_prod \\ false) do
    payload = %{
      "request" => String.replace(@view_approved_addresses_url, ":network", network),
      "nonce" => :os.system_time(:second),
      "account" => account
    }

    HttpClient.post_with_payload(@view_approved_addresses_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Removes an approved address.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `network`: The network for the address.
  - `address`: The address to be removed.
  - `account`: Optional. The account within the subaccount group.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec remove_address(String.t(), String.t(), String.t(), String.t(), map, boolean) :: {:ok, map} | {:error, any}
  def remove_address(api_key, api_secret, network, address, account \\ nil, use_prod \\ false) do
    payload = %{
      "request" => String.replace(@remove_address_url, ":network", network),
      "nonce" => :os.system_time(:second),
      "address" => address,
      "account" => account
    }

    HttpClient.post_with_payload(@remove_address_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves account details.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `account`: Optional. The name of the account within the subaccount group.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec account_detail(String.t(), String.t(), String.t() | nil, boolean) :: {:ok, map} | {:error, any}
  def account_detail(api_key, api_secret, account \\ nil, use_prod \\ false) do
    payload = %{
      "request" => @account_detail_url,
      "nonce" => :os.system_time(:second),
      "account" => account
    }

    HttpClient.post_with_payload(@account_detail_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Creates a new account.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `name`: The name of the new account.
  - `type`: Optional. The type of account ("exchange" or "custody").
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec create_account(String.t(), String.t(), String.t(), String.t() | nil, boolean) :: {:ok, map} | {:error, any}
  def create_account(api_key, api_secret, name, type \\ "exchange", use_prod \\ false) do
    payload = %{
      "request" => @create_account_url,
      "nonce" => :os.system_time(:second),
      "name" => name,
      "type" => type
    }

    HttpClient.post_with_payload(@create_account_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Renames an account.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `account`: The shortname of the account within the subaccount group.
  - `new_name`: Optional. A new name for the account.
  - `new_account`: Optional. A new shortname for the account.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec rename_account(String.t(), String.t(), String.t(), String.t() | nil, String.t() | nil, boolean) ::
          {:ok, map} | {:error, any}
  def rename_account(api_key, api_secret, account, new_name \\ nil, new_account \\ nil, use_prod \\ false) do
    payload = %{
      "request" => @rename_account_url,
      "nonce" => :os.system_time(:second),
      "account" => account,
      "newName" => new_name,
      "newAccount" => new_account
    }

    HttpClient.post_with_payload(@rename_account_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Retrieves accounts in the master group.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `limit_accounts`: Optional. The maximum number of accounts to return (default: 500).
  - `timestamp`: Optional. Only return accounts created on or before this timestamp.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec get_accounts_in_master_group(String.t(), String.t(), integer | nil, integer | nil, boolean) ::
          {:ok, map} | {:error, any}
  def get_accounts_in_master_group(api_key, api_secret, limit_accounts \\ 500, timestamp \\ nil, use_prod \\ false) do
    payload = %{
      "request" => @get_accounts_in_master_group_url,
      "nonce" => :os.system_time(:second),
      "limit_accounts" => limit_accounts,
      "timestamp" => timestamp
    }

    HttpClient.post_with_payload(@get_accounts_in_master_group_url, payload, api_key, api_secret, use_prod)
  end

  @doc """
  Prevents a session from timing out and canceling orders if the require heartbeat flag has been set.

  ## Parameters
  - `api_key`: The API key for authentication.
  - `api_secret`: The API secret for signing the request.
  - `use_prod`: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).
  """
  @spec heartbeat(String.t(), String.t(), boolean) :: {:ok, map} | {:error, any}
  def heartbeat(api_key, api_secret, use_prod \\ false) do
    payload = %{
      "request" => @heartbeat_url,
      "nonce" => :os.system_time(:second)
    }

    HttpClient.post_with_payload(@heartbeat_url, payload, api_key, api_secret, use_prod)
  end

  defp generate_payload(request, params) do
    Map.merge(%{"request" => request, "nonce" => :os.system_time(:second)}, params)
  end
end
