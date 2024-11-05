defmodule Geminex.API.Private do
  @moduledoc """
  Private API endpoints for Gemini.

  This module provides functions to interact with Gemini's private REST API.
  Each function corresponds to a specific endpoint and handles the HTTP requests
  and responses, returning either **{:ok, result}** or **{:error, reason}**.

  The base URL and API keys are determined by the **:environment**, **:api_key**, and **:api_secret**
  configurations in your application config.

  ## Configuration

  Add the following to your **config/config.exs**:

      config :geminex,
        environment: :sandbox,
        api_key: System.get_env("GEMINI_API_KEY"),
        api_secret: System.get_env("GEMINI_API_SECRET")
  """

  use Tesla

  alias Geminex.Utils

  @timeout 5_000

  # Middleware stack
  plug(Geminex.Middleware.DynamicBaseUrl)
  plug(Geminex.Middleware.Authentication)
  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.Query)
  plug(Tesla.Middleware.Timeout, timeout: @timeout)
  plug(Tesla.Middleware.Logger)

  # Order Placement APIs
  @new_order_url                  "/v1/order/new"
  @cancel_order_url               "/v1/order/cancel"
  @wrap_order_url                 "/v1/wrap/:symbol"
  @cancel_all_session_orders_url  "/v1/order/cancel/session"
  @cancel_all_active_orders_url   "/v1/order/cancel/all"

  # Order Status APIs
  @order_status_url   "/v1/order/status"
  @active_orders_url  "/v1/orders"
  @past_trades_url    "/v1/mytrades"
  @orders_history_url "/v1/orders/history"

  # Fee and Volume APIs
  @notional_volume_url  "/v1/notionalvolume"
  @trade_volume_url     "/v1/tradevolume"

  # FX Rate
  @fx_rate_url "/v2/fxrate/:symbol/:timestamp"

  # Derivatives APIs
  @open_positions_url               "/v1/positions"
  @account_margin_url               "/v1/margin"
  @risk_stats_url                   "/v1/riskstats/:symbol"
  @funding_payment_url              "/v1/perpetuals/fundingPayment"
  @funding_payment_report_file_url  "/v1/perpetuals/fundingpaymentreport/records.xlsx"
  @funding_payment_report_json_url  "/v1/perpetuals/fundingpaymentreport/records.json"

  # Gemini Clearing
  @new_clearing_order_url     "/v1/clearing/new"
  @new_broker_order_url       "/v1/clearing/broker/new"
  @clearing_order_status_url  "/v1/clearing/status"
  @cancel_clearing_order_url  "/v1/clearing/cancel"
  @confirm_clearing_order_url "/v1/clearing/confirm"
  @clearing_order_list_url    "/v1/clearing/list"
  @clearing_broker_list_url   "/v1/clearing/broker/list"
  @clearing_trades_url        "/v1/clearing/trades"

  # Fund Management APIs
  @available_balances_url     "/v1/balances"
  @notional_balances_url      "/v1/notionalbalances/:currency"
  @transfers_url              "/v1/transfers"
  @transactions_url           "/v1/transactions"
  @custody_account_fees_url   "/v1/custodyaccountfees"
  @deposit_addresses_url      "/v1/addresses/:network"
  @new_deposit_address_url    "/v1/deposit/:network/:new_address"
  @withdraw_crypto_funds_url  "/v1/withdraw/:currency"
  @gas_fee_estimation_url     "/v1/withdraw/:currency_code/feeEstimate"
  @internal_transfers_url     "/v1/account/transfer/:currency"
  @add_bank_url               "/v1/payments/addbank"
  @add_bank_cad_url           "/v1/payments/addbank/cad"
  @payment_methods_url        "/v1/payments/methods"

  # Gemini Staking
  @staking_balances_url     "/v1/balances/staking"
  @staking_rates_url        "/v1/staking/rates"
  @staking_rewards_url      "/v1/staking/rewards"
  @staking_history_url      "/v1/staking/history"
  @staking_deposits_url     "/v1/staking/stake"
  @staking_withdrawals_url  "/v1/staking/unstake"

  # Approved Address APIs
  @create_address_request_url                         "/v1/approvedAddresses/:network/request"
  @view_approved_addresses_url                        "/v1/approvedAddresses/account/:network"
  @remove_addresses_from_approved_addresses_list_url  "/v1/approvedAddresses/:network/remove"

  # Account Administration APIs
  @account_detail_url           "/v1/account"
  @create_account_url           "/v1/account/create"
  @rename_account_url           "/v1/account/rename"
  @accounts_in_master_group_url "/v1/account/list"

  # Session APIs
  @heartbeat_url "/v1/heartbeat"

  @doc """
  Places a new order.

  ## Parameters

    - **symbol**: The trading pair symbol (e.g., "btcusd").
    - **amount**: The amount to purchase as a string.
    - **price**: The limit price per unit as a string.
    - **side**: Order side, either **"buy"** or **"sell"**.
    - **type**: Order type, e.g., **"exchange limit"** or **"exchange stop limit"**.
    - **client_order_id** (optional): A custom client ID for the order.
    - **stop_price** (optional): The stop price for stop-limit orders.
    - **options** (optional): List of order execution options (e.g., **["maker-or-cancel"]**).
    - **account** (optional): Specifies the sub-account (required for master API keys).
  """
  @spec new_order(
          symbol          :: String.t(),
          amount          :: String.t(),
          price           :: String.t(),
          side            :: String.t(),
          type            :: String.t(),
          client_order_id :: String.t()       | nil,
          stop_price      :: String.t()       | nil,
          options         :: list(String.t()) | nil,
          account         :: String.t()       | nil
        ) :: {:ok, map} | {:error, any}
  def new_order(
        symbol,
        amount,
        price,
        side,
        type,
        client_order_id \\ nil,
        stop_price      \\ nil,
        options         \\ nil,
        account         \\ nil
      ) do
    payload = %{
      "symbol"  => symbol,
      "amount"  => amount,
      "price"   => price,
      "side"    => side,
      "type"    => type
    }
      |> Utils.maybe_put("client_order_id", client_order_id)
      |> Utils.maybe_put("stop_price",      stop_price)
      |> Utils.maybe_put("options",         options)
      |> Utils.maybe_put("account",         account)

    post(@new_order_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Cancels an existing order.

  ## Parameters

    - **order_id**: The ID of the order to cancel.
    - **account** (optional): The name of the account within the subaccount group (required for Master API keys).

  If the order is already canceled, this request will still succeed but have no effect.
  """
  @spec cancel_order(order_id :: non_neg_integer(), account :: String.t() | nil) :: {:ok, map} | {:error, any}
  def cancel_order(order_id, account \\ nil) do
    payload = %{"order_id" => order_id} |> Utils.maybe_put("account", account)

    post(@cancel_order_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Wraps or unwraps Gemini-issued assets.

  ## Parameters

    - **symbol**: The trading pair symbol for the asset to be wrapped/unwrapped (e.g., "GUSDUSD").
    - **amount**: The amount to be wrapped/unwrapped as a string.
    - **side**: The direction of the transaction, either **"buy"** (wrap) or **"sell"** (unwrap).
    - **account** (optional): Specifies the sub-account (required for master API keys).
    - **client_order_id** (optional): A custom client ID for tracking the order.
  """
  @spec wrap_order(
          symbol          :: String.t(),
          amount          :: String.t(),
          side            :: String.t(),
          account         :: String.t() | nil,
          client_order_id :: String.t() | nil
        ) :: {:ok, map} | {:error, any}
  def wrap_order(symbol, amount, side, account \\ nil, client_order_id \\ nil) do
    payload = %{"amount" => amount, "side" => side}
      |> Utils.maybe_put("account",         account)
      |> Utils.maybe_put("client_order_id", client_order_id)

    post(@wrap_order_url |> String.replace(":symbol", symbol), payload)
      |> Utils.handle_response()
  end

  @doc """
  Cancels all orders opened by this session.

  If "Require Heartbeat" is enabled for the session, this function has the same effect as a heartbeat expiration.

  ## Parameters

    - **account** (optional): Specifies the sub-account (required for master API keys).
  """
  @spec cancel_all_session_orders(account :: String.t() | nil) :: {:ok, map} | {:error, any}
  def cancel_all_session_orders(account \\ nil) do
    payload = %{} |> Utils.maybe_put("account", account)

    post(@cancel_all_session_orders_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Cancels all outstanding orders created by any session associated with this account, including UI-placed orders.

  Typically, **cancel_all_session_orders** is preferable to only cancel orders related to the current session.

  ## Parameters

    - **account** (optional): Specifies the sub-account (required for master API keys).
  """
  @spec cancel_all_active_orders(account :: String.t() | nil) :: {:ok, map} | {:error, any}
  def cancel_all_active_orders(account \\ nil) do
    payload = %{} |> Utils.maybe_put("account", account)

    post(@cancel_all_active_orders_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves the status of a specific order by **order_id** or **client_order_id**.

  ## Parameters

    - **order_id** (optional): The order ID to retrieve status for. Cannot be used with **client_order_id**.
    - **client_order_id** (optional): The client-specified order ID used during order placement. Cannot be used with **order_id**.
    - **include_trades** (optional): Boolean. If true, includes trade details of all fills for the order.
    - **account** (optional): Specifies the sub-account (required for master API keys).
  """
  @spec order_status(
          order_id        :: non_neg_integer()  | nil,
          client_order_id :: String.t()         | nil,
          include_trades  :: boolean            | nil,
          account         :: String.t()         | nil
        ) :: {:ok, map} | {:error, any}
  def order_status(order_id \\ nil, client_order_id \\ nil, include_trades \\ nil, account \\ nil) do
    payload = %{}
      |> Utils.maybe_put("order_id",        order_id)
      |> Utils.maybe_put("client_order_id", client_order_id)
      |> Utils.maybe_put("include_trades",  include_trades)
      |> Utils.maybe_put("account",         account)

    post(@order_status_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves all active (live) orders associated with the account.

  ## Parameters

    - **account** (optional): Specifies the sub-account (required for master API keys).
  """
  @spec active_orders(account :: String.t() | nil) :: {:ok, list(map)} | {:error, any}
  def active_orders(account \\ nil) do
    payload = %{}
      |> Utils.maybe_put("account", account)

    post(@active_orders_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves past trades for a specific symbol.

  ## Parameters

    - **symbol** (optional): The symbol to retrieve trades for (e.g., "btcusd").
    - **limit_trades** (optional): Maximum number of trades to return (default 50, max 500).
    - **timestamp** (optional): Only return trades on or after this timestamp.
    - **account** (optional): Specifies the sub-account (required for master API keys).
  """
  @spec past_trades(
          symbol        :: String.t()         | nil,
          limit_trades  :: non_neg_integer()  | nil,
          timestamp     :: non_neg_integer()  | nil,
          account       :: String.t()         | nil
        ) :: {:ok, list(map)} | {:error, any}
  def past_trades(symbol \\ nil, limit_trades \\ nil, timestamp \\ nil, account \\ nil) do
    payload = %{}
      |> Utils.maybe_put("symbol",        symbol)
      |> Utils.maybe_put("limit_trades",  limit_trades)
      |> Utils.maybe_put("timestamp",     timestamp)
      |> Utils.maybe_put("account",       account)

    post(@past_trades_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves a history of closed orders for a specific symbol.

  ## Parameters

    - **symbol** (optional): The symbol to retrieve orders for (e.g., "btcusd").
    - **limit_orders** (optional): Maximum number of orders to return (default 50, max 500).
    - **timestamp** (optional): Only return orders on or after this timestamp.
    - **account** (optional): Specifies the sub-account (required for master API keys).
  """
  @spec orders_history(
          symbol       :: String.t()        | nil,
          limit_orders :: non_neg_integer() | nil,
          timestamp    :: non_neg_integer() | nil,
          account      :: String.t()        | nil
        ) :: {:ok, list(map)} | {:error, any}
  def orders_history(symbol \\ nil, limit_orders \\ nil, timestamp \\ nil, account \\ nil) do
    payload = %{}
      |> Utils.maybe_put("symbol",        symbol)
      |> Utils.maybe_put("limit_orders",  limit_orders)
      |> Utils.maybe_put("timestamp",     timestamp)
      |> Utils.maybe_put("account",       account)

    post(@orders_history_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves the 30-day notional volume and fee details for the account.

  ## Parameters

    - **symbol** (optional): The participating symbol for fee promotions (e.g., "btcusd").
    - **account** (optional): Specifies the sub-account (required for master API keys).
  """
  @spec notional_volume(symbol :: String.t() | nil, account :: String.t() | nil) :: {:ok, map} | {:error, any}
  def notional_volume(symbol \\ nil, account \\ nil) do
    payload = %{}
      |> Utils.maybe_put("symbol",  symbol)
      |> Utils.maybe_put("account", account)

    post(@notional_volume_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves the trade volume data for the account over the past 30 days.

  ## Parameters

    - **account** (optional): Specifies the sub-account (required for master API keys).
  """
  @spec trade_volume(account :: String.t() | nil) :: {:ok, list(map)} | {:error, any}
  def trade_volume(account \\ nil) do
    payload = %{}
      |> Utils.maybe_put("account", account)

    post(@trade_volume_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves the historical FX rate for a specific currency pair against USD at a given timestamp.

  ## Parameters

    - **symbol**: The currency pair symbol to check the USD FX rate against (e.g., "gbpusd").
    - **timestamp**: The timestamp (in epoch format) for which the FX rate is requested.
  """
  @spec fx_rate(symbol :: String.t(), timestamp :: non_neg_integer()) :: {:ok, map} | {:error, any}
  def fx_rate(symbol, timestamp) do
    get(@fx_rate_url |> String.replace(":symbol", symbol) |> String.replace(":timestamp", timestamp))
      |> Utils.handle_response()
  end

  @doc """
  Retrieves all open positions for the account.

  ## Parameters

    - **account** (optional): Specifies the sub-account (required for master API keys).
  """
  @spec open_positions(account :: String.t() | nil) :: {:ok, list(map)} | {:error, any}
  def open_positions(account \\ nil) do
    payload = %{}
      |> Utils.maybe_put("account", account)

    post(@open_positions_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves margin details for a specific symbol.

  ## Parameters

    - **symbol**: The trading pair symbol (e.g., "BTC-GUSD-PERP").
    - **account** (optional): Specifies the sub-account (required for master API keys).
  """
  @spec account_margin(symbol :: String.t(), account :: String.t() | nil) :: {:ok, map} | {:error, any}
  def account_margin(symbol, account \\ nil) do
    payload = %{"symbol" => symbol}
      |> Utils.maybe_put("account", account)

    post(@account_margin_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves risk statistics for a specified symbol.

  ## Parameters

    - **symbol**: The trading pair symbol (e.g., "BTCGUSDPERP").
  """
  @spec risk_stats(symbol :: String.t()) :: {:ok, map} | {:error, any}
  def risk_stats(symbol) do
    get(@risk_stats_url |> String.replace(":symbol", symbol))
      |> Utils.handle_response()
  end

  @doc """
  Retrieves funding payment history within a specified time range.

  ## Parameters

    - **since** (optional): The starting timestamp for the funding payments.
    - **to** (optional): The ending timestamp for the funding payments.
    - **account** (optional): Specifies the sub-account (required for master API keys).
  """
  @spec funding_payment(
          since   :: non_neg_integer()  | nil,
          to      :: non_neg_integer()  | nil,
          account :: String.t()         | nil
        ) :: {:ok, list(map)} | {:error, any}
  def funding_payment(since \\ nil, to \\ nil, account \\ nil) do
    query_params = %{}
      |> Utils.maybe_put("since", since)
      |> Utils.maybe_put("to",    to)

    url = "#{@funding_payment_url}?#{URI.encode_query(query_params)}"

    payload = %{}
      |> Utils.maybe_put("account", account)

    post(url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves funding payment data as an Excel file for a specified date range and row limit.

  ## Parameters

    - **from_date** (optional): Start date for the records in YYYY-MM-DD format.
    - **to_date** (optional): End date for the records in YYYY-MM-DD format.
    - **num_rows** (optional): Maximum number of rows to retrieve (default 8760).
  """
  @spec funding_payment_report_file(
          from_date :: String.t()         | nil,
          to_date   :: String.t()         | nil,
          num_rows  :: non_neg_integer()  | nil
        ) :: {:ok, binary} | {:error, any}
  def funding_payment_report_file(from_date \\ nil, to_date \\ nil, num_rows \\ 8760) do
    query_params = %{}
      |> Utils.maybe_put("fromDate",  from_date)
      |> Utils.maybe_put("toDate",    to_date)
      |> Utils.maybe_put("numRows",   num_rows)

    url = "#{@funding_payment_report_file_url}?#{URI.encode_query(query_params)}"

    get(url)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves funding payment data as JSON for a specified date range and row limit.

  ## Parameters

    - **from_date** (optional): Start date for the records in YYYY-MM-DD format.
    - **to_date** (optional): End date for the records in YYYY-MM-DD format.
    - **num_rows** (optional): Maximum number of rows to retrieve (default 8760).
  """
  @spec funding_payment_report_json(
          from_date :: String.t()         | nil,
          to_date   :: String.t()         | nil,
          num_rows  :: non_neg_integer()  | nil
        ) :: {:ok, list(map)} | {:error, any}
  def funding_payment_report_json(from_date \\ nil, to_date \\ nil, num_rows \\ 8760) do
    query_params = %{}
      |> Utils.maybe_put("fromDate",  from_date)
      |> Utils.maybe_put("toDate",    to_date)
      |> Utils.maybe_put("numRows",   num_rows)

    url = "#{@funding_payment_report_json_url}?#{URI.encode_query(query_params)}"

    get(url)
      |> Utils.handle_response()
  end

  @doc """
  Creates a new clearing order with optional counterparty and expiration details.

  ## Parameters

    - **symbol**: The trading pair symbol for the order (e.g., "btcusd").
    - **amount**: The amount to purchase as a string.
    - **price**: The price per unit as a string.
    - **side**: "buy" or "sell".
    - **counterparty_id** (optional): ID of the counterparty for this trade.
    - **expires_in_hrs** (optional): Number of hours before the trade expires.
    - **account** (optional): Specifies the sub-account.
  """
  @spec new_clearing_order(
          symbol          :: String.t(),
          amount          :: String.t(),
          price           :: String.t(),
          side            :: String.t(),
          counterparty_id :: String.t()         | nil,
          expires_in_hrs  :: non_neg_integer()  | nil,
          account         :: String.t()         | nil
        ) :: {:ok, map} | {:error, any}
  def new_clearing_order(symbol, amount, price, side, counterparty_id \\ nil, expires_in_hrs \\ nil, account \\ nil) do
    payload = %{
      "symbol"  => symbol,
      "amount"  => amount,
      "price"   => price,
      "side"    => side
    }
      |> Utils.maybe_put("counterparty_id", counterparty_id)
      |> Utils.maybe_put("expires_in_hrs",  expires_in_hrs)
      |> Utils.maybe_put("account",         account)

    post(@new_clearing_order_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Creates a new broker clearing order between two counterparties.

  ## Parameters

    - **symbol**: The trading pair symbol.
    - **amount**: The amount to purchase as a string.
    - **price**: The price per unit as a string.
    - **side**: "buy" or "sell".
    - **source_counterparty_id**: The counterparty initiating the trade.
    - **target_counterparty_id**: The target counterparty.
    - **expires_in_hrs** (optional): Number of hours before the trade expires.
    - **account** (optional): Specifies the broker sub-account.
  """
  @spec new_broker_order(
          symbol                  :: String.t(),
          amount                  :: String.t(),
          price                   :: String.t(),
          side                    :: String.t(),
          source_counterparty_id  :: String.t(),
          target_counterparty_id  :: String.t(),
          expires_in_hrs          :: non_neg_integer()  | nil,
          account                 :: String.t()         | nil
        ) :: {:ok, map} | {:error, any}
  def new_broker_order(symbol, amount, price, side, source_counterparty_id, target_counterparty_id, expires_in_hrs \\ nil, account \\ nil) do
    payload = %{
      "symbol"                  => symbol,
      "amount"                  => amount,
      "price"                   => price,
      "side"                    => side,
      "source_counterparty_id"  => source_counterparty_id,
      "target_counterparty_id"  => target_counterparty_id
    }
      |> Utils.maybe_put("expires_in_hrs",  expires_in_hrs)
      |> Utils.maybe_put("account",         account)

    post(@new_broker_order_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Fetches the status of a clearing order by its unique clearing ID.

  ## Parameters
    - **clearing_id**: A unique identifier for the clearing order.
    - **account** (optional): Specifies the sub-account.
  """
  @spec clearing_order_status(clearing_id :: String.t(), opts :: keyword()) :: {:ok, map} | {:error, any}
  def clearing_order_status(clearing_id, account \\ nil) do
    payload = %{"clearing_id" => clearing_id}
      |> Utils.maybe_put("account", account)

    post(@clearing_order_status_url, payload)
      |> Utils.handle_response()
  end


  @doc """
  Cancels a specific clearing order.

  ## Parameters

    - **clearing_id**: The unique identifier of the clearing order.
    - **account** (optional): Specifies the sub-account.
  """
  @spec cancel_clearing_order(clearing_id :: String.t(), account :: String.t() | nil) :: {:ok, map} | {:error, any}
  def cancel_clearing_order(clearing_id, account \\ nil) do
    payload = %{"clearing_id" => clearing_id}
      |> Utils.maybe_put("account", account)

    post(@cancel_clearing_order_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Confirms a clearing order with the provided details.

  ## Parameters

    - **clearing_id**: The unique identifier of the clearing order.
    - **symbol**: The trading pair symbol.
    - **amount**: The amount to purchase as a string.
    - **price**: The price per unit as a string.
    - **side**: "buy" or "sell".
    - **account** (optional): Specifies the sub-account.
  """
  @spec confirm_clearing_order(
          clearing_id :: String.t(),
          symbol      :: String.t(),
          amount      :: String.t(),
          price       :: String.t(),
          side        :: String.t(),
          account     :: String.t() | nil
        ) :: {:ok, map} | {:error, any}
  def confirm_clearing_order(clearing_id, symbol, amount, price, side, account \\ nil) do
    payload = %{
      "clearing_id" => clearing_id,
      "symbol"      => symbol,
      "amount"      => amount,
      "price"       => price,
      "side"        => side
    }
      |> Utils.maybe_put("account", account)

    post(@confirm_clearing_order_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves a list of clearing orders with optional filters.

  ## Parameters

    - **symbol** (optional): Trading pair symbol.
    - **counterparty** (optional): Counterparty ID or alias.
    - **side**: "buy" or "sell" (required).
    - **expiration_start** (optional): Start timestamp for expiration filter.
    - **expiration_end** (optional): End timestamp for expiration filter.
    - **submission_start** (optional): Start timestamp for submission filter.
    - **submission_end** (optional): End timestamp for submission filter.
    - **funded** (optional): Whether the order is funded.
    - **account** (optional): Specifies the sub-account.
  """
  @spec clearing_order_list(
          side              :: String.t(),
          symbol            :: String.t()         | nil,
          counterparty      :: String.t()         | nil,
          expiration_start  :: non_neg_integer()  | nil,
          expiration_end    :: non_neg_integer()  | nil,
          submission_start  :: non_neg_integer()  | nil,
          submission_end    :: non_neg_integer()  | nil,
          funded            :: boolean            | nil,
          account           :: String.t()         | nil
        ) :: {:ok, map} | {:error, any}
  def clearing_order_list(
        side,
        symbol            \\ nil,
        counterparty      \\ nil,
        expiration_start  \\ nil,
        expiration_end    \\ nil,
        submission_start  \\ nil,
        submission_end    \\ nil,
        funded            \\ nil,
        account           \\ nil
      ) do
    payload = %{"side" => side}
      |> Utils.maybe_put("symbol",            symbol)
      |> Utils.maybe_put("counterparty",      counterparty)
      |> Utils.maybe_put("expiration_start",  expiration_start)
      |> Utils.maybe_put("expiration_end",    expiration_end)
      |> Utils.maybe_put("submission_start",  submission_start)
      |> Utils.maybe_put("submission_end",    submission_end)
      |> Utils.maybe_put("funded",            funded)
      |> Utils.maybe_put("account",           account)

    post(@clearing_order_list_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves a list of broker clearing orders with optional filters.

  ## Parameters

    - **symbol** (optional): Trading pair symbol.
    - **expiration_start** (optional): Start timestamp for expiration filter.
    - **expiration_end** (optional): End timestamp for expiration filter.
    - **submission_start** (optional): Start timestamp for submission filter.
    - **submission_end** (optional): End timestamp for submission filter.
    - **funded** (optional): Whether the order is funded.
    - **account** (optional): Specifies the sub-account.
  """
  @spec clearing_broker_list(
          symbol            :: String.t()         | nil,
          expiration_start  :: non_neg_integer()  | nil,
          expiration_end    :: non_neg_integer()  | nil,
          submission_start  :: non_neg_integer()  | nil,
          submission_end    :: non_neg_integer()  | nil,
          funded            :: boolean            | nil,
          account           :: String.t()         | nil
        ) :: {:ok, map} | {:error, any}
  def clearing_broker_list(
        symbol            \\ nil,
        expiration_start  \\ nil,
        expiration_end    \\ nil,
        submission_start  \\ nil,
        submission_end    \\ nil,
        funded            \\ nil,
        account           \\ nil
      ) do
    payload = %{}
              |> Utils.maybe_put("symbol",            symbol)
              |> Utils.maybe_put("expiration_start",  expiration_start)
              |> Utils.maybe_put("expiration_end",    expiration_end)
              |> Utils.maybe_put("submission_start",  submission_start)
              |> Utils.maybe_put("submission_end",    submission_end)
              |> Utils.maybe_put("funded",            funded)
              |> Utils.maybe_put("account",           account)

    post(@clearing_broker_list_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves a list of clearing trades with optional filters.

  ## Parameters

    - **timestamp_nanos** (optional): Only return trades on or after this timestamp in nanos.
    - **limit** (optional): The maximum number of trades to return.
    - **account** (optional): Specifies the sub-account.
  """
  @spec clearing_trades(
          timestamp_nanos :: non_neg_integer()  | nil,
          limit           :: non_neg_integer()  | nil,
          account         :: String.t()         | nil
        ) :: {:ok, map} | {:error, any}
  def clearing_trades(
        timestamp_nanos \\ nil,
        limit           \\ nil,
        account         \\ nil
      ) do
    payload = %{}
      |> Utils.maybe_put("timestamp_nanos", timestamp_nanos)
      |> Utils.maybe_put("limit",           limit)
      |> Utils.maybe_put("account",         account)

    post(@clearing_trades_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Fetches available balances in supported currencies.

  ## Parameters

    - **account** (optional): Specifies the sub-account.
  """
  @spec available_balances(account :: String.t() | nil) :: {:ok, list(map)} | {:error, any}
  def available_balances(account \\ nil) do
    payload = %{}
      |> Utils.maybe_put("account", account)

    post(@available_balances_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Fetches balances and their notional values in a specified currency.

  ## Parameters

    - **currency**: Three-letter fiat currency code for notional values (e.g., "usd").
    - **account** (optional): Specifies the sub-account.
  """
  @spec notional_balances(currency :: String.t(), account :: String.t() | nil) :: {:ok, list(map)} | {:error, any}
  def notional_balances(currency, account \\ nil) do
    payload = %{}
      |> Utils.maybe_put("account", account)

    post(@notional_balances_url |> String.replace(":currency", currency), payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves transfer history, including deposits and withdrawals.

  ## Parameters

    - **currency** (optional): Currency code to filter transfers.
    - **timestamp** (optional): Only return transfers on or after this timestamp.
    - **limit_transfers** (optional): Maximum number of transfers to return.
    - **show_completed_deposit_advances** (optional): Whether to show completed deposit advances.
    - **account** (optional): Specifies the sub-account.
  """
  @spec transfers(
          currency                        :: String.t()         | nil,
          timestamp                       :: non_neg_integer()  | nil,
          limit_transfers                 :: non_neg_integer()  | nil,
          show_completed_deposit_advances :: boolean            | nil,
          account                         :: String.t()         | nil
        ) :: {:ok, list(map)} | {:error, any}
  def transfers(
        currency                        \\ nil,
        timestamp                       \\ nil,
        limit_transfers                 \\ nil,
        show_completed_deposit_advances \\ nil,
        account                         \\ nil
      ) do
    payload = %{}
      |> Utils.maybe_put("currency",                        currency)
      |> Utils.maybe_put("timestamp",                       timestamp)
      |> Utils.maybe_put("limit_transfers",                 limit_transfers)
      |> Utils.maybe_put("show_completed_deposit_advances", show_completed_deposit_advances)
      |> Utils.maybe_put("account",                         account)

    post(@transfers_url, payload)
      |> Utils.handle_response()
  end
  @doc """
  Fetches transaction details, including trades and transfers.

  ## Parameters

    - **timestamp_nanos** (optional): Only return transactions on or after this timestamp in nanos.
    - **limit** (optional): Maximum number of transfers to return (default is 100).
    - **continuation_token** (optional): Token for pagination in subsequent requests.
    - **account** (optional): Specifies the sub-account.
  """
  @spec transactions(
          timestamp_nanos     :: non_neg_integer()  | nil,
          limit               :: non_neg_integer()  | nil,
          continuation_token  :: String.t()         | nil,
          account             :: String.t()         | nil
        ) :: {:ok, map} | {:error, any}
  def transactions(
        timestamp_nanos     \\ nil,
        limit               \\ nil,
        continuation_token  \\ nil,
        account             \\ nil
      ) do
    payload = %{}
      |> Utils.maybe_put("timestamp_nanos",     timestamp_nanos)
      |> Utils.maybe_put("limit",               limit)
      |> Utils.maybe_put("continuation_token",  continuation_token)
      |> Utils.maybe_put("account",             account)

    post(@transactions_url, payload)
      |> Utils.handle_response()
  end



  @doc """
  Estimates gas fees for a cryptocurrency withdrawal.

  ## Parameters

    - **currency**: The cryptocurrency code (e.g., "eth").
    - **address**: Destination cryptocurrency address.
    - **amount**: The amount to withdraw.
    - **account** (optional): Specifies the sub-account.
  """
  @spec estimate_gas_fee(
          currency  :: String.t(),
          address   :: String.t(),
          amount    :: String.t(),
          account   :: String.t() | nil
        ) :: {:ok, map} | {:error, any}
  def estimate_gas_fee(currency, address, amount, account \\ nil) do
    payload = %{
      "address" => address,
      "amount"  => amount
    }
      |> Utils.maybe_put("account", account)

    post(@gas_fee_estimation_url |> String.replace(":currency_code", currency), payload)
      |> Utils.handle_response()
  end

  @doc """
  Withdraws cryptocurrency funds to an approved address.

  ## Parameters

    - **currency**: The cryptocurrency code (e.g., "btc").
    - **address**: The destination cryptocurrency address.
    - **amount**: The amount to withdraw.
    - **client_transfer_id** (optional): Unique identifier for the withdrawal.
    - **memo** (optional): Memo for addresses requiring it.
    - **account** (optional): Specifies the sub-account.
  """
  @spec withdraw_crypto_funds(
          currency           :: String.t(),
          address            :: String.t(),
          amount             :: String.t(),
          client_transfer_id :: String.t() | nil,
          memo               :: String.t() | nil,
          account            :: String.t() | nil
        ) :: {:ok, map} | {:error, any}
  def withdraw_crypto_funds(
        currency,
        address,
        amount,
        client_transfer_id \\ nil,
        memo               \\ nil,
        account            \\ nil
      ) do
    payload = %{
      "address" => address,
      "amount"  => amount
    }
      |> Utils.maybe_put("clientTransferId",  client_transfer_id)
      |> Utils.maybe_put("memo",              memo)
      |> Utils.maybe_put("account",           account)

    post(@withdraw_crypto_funds_url |> String.replace(":currency", currency), payload)
      |> Utils.handle_response()
  end


  @doc """
  Executes an internal transfer between two accounts.

  ## Parameters

    - **currency**: Currency code (e.g., "btc").
    - **source_account**: The account to transfer funds from.
    - **target_account**: The account to transfer funds to.
    - **amount**: The amount to transfer.
    - **client_transfer_id** (optional): Unique identifier for the transfer.
  """
  @spec execute_internal_transfer(
          currency          :: String.t(),
          source_account    :: String.t(),
          target_account    :: String.t(),
          amount            :: String.t(),
          client_transfer_id  :: String.t() | nil
        ) :: {:ok, map} | {:error, any}
  def execute_internal_transfer(currency, source_account, target_account, amount, client_transfer_id \\ nil) do
    payload = %{
      "sourceAccount" => source_account,
      "targetAccount" => target_account,
      "amount"        => amount
    }
      |> Utils.maybe_put("clientTransferId", client_transfer_id)

    post(@internal_transfers_url |> String.replace(":currency", currency), payload)
      |> Utils.handle_response()
  end

  @doc """
  Fetches custody account fees.

  ## Parameters
    - **timestamp** (optional): Only return Custody fee records on or after this timestamp.
    - **limit_transfers** (optional): The maximum number of Custody fee records to return.
    - **account** (optional): Specifies the sub-account.
  """
  @spec custody_account_fees(
          timestamp       :: non_neg_integer(),
          limit_transfers :: non_neg_integer(),
          account         :: String.t()
        ) :: {:ok, list(map)} | {:error, any}
  def custody_account_fees(timestamp \\ nil, limit_transfers \\ nil, account \\ nil) do
    payload = %{}
      |> Utils.maybe_put("timestamp",       timestamp)
      |> Utils.maybe_put("limit_transfers", limit_transfers)
      |> Utils.maybe_put("account",         account)

    post(@custody_account_fees_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves deposit addresses for a specified network.

  ## Parameters
    - **network**: Cryptocurrency network (e.g., "bitcoin", "ethereum").
    - **timestamp** (optional): Only return addresses created on or after this timestamp.
    - **account** (optional): Specifies the sub-account.
  """
  @spec deposit_addresses(
          network     :: String.t(),
          timestamp   :: non_neg_integer(),
          account     :: String.t()
        ) :: {:ok, list(map)} | {:error, any}
  def deposit_addresses(network, timestamp \\ nil, account \\ nil) do
    payload = %{}
      |> Utils.maybe_put("timestamp", timestamp)
      |> Utils.maybe_put("account",   account)

    post(@deposit_addresses_url |> String.replace(":network", network), payload)
      |> Utils.handle_response()
  end

  @doc """
  Generates a new deposit address for a specified network.

  ## Parameters
    - **network**: Cryptocurrency network (e.g., "bitcoin", "litecoin").
    - **label** (optional): Label for the deposit address.
    - **legacy** (optional): Whether to generate a legacy P2SH-P2PKH litecoin address.
    - **account** (optional): Specifies the sub-account.
  """
  @spec new_deposit_address(
          network :: String.t(),
          label   :: String.t(),
          legacy  :: boolean(),
          account :: String.t()
        ) :: {:ok, map} | {:error, any}
  def new_deposit_address(network, label \\ nil, legacy \\ nil, account \\ nil) do
    payload = %{}
      |> Utils.maybe_put("label",   label)
      |> Utils.maybe_put("legacy",  legacy)
      |> Utils.maybe_put("account", account)

    post(@new_deposit_address_url |> String.replace(":network", network), payload)
      |> Utils.handle_response()
  end

  @doc """
  Adds a bank account for the user.

  ## Parameters
    - **account_number**: Bank account number.
    - **routing**: Routing number.
    - **type**: Type of bank account, "checking" or "savings".
    - **name**: Name on the bank account.
    - **account** (optional): Specifies the sub-account.
  """
  @spec add_bank(
          account_number  :: String.t(),
          routing         :: String.t(),
          type            :: String.t(),
          name            :: String.t(),
          account         :: String.t()
        ) :: {:ok, map} | {:error, any}
  def add_bank(account_number, routing, type, name, account \\ nil) do
    payload = %{
      "accountnumber" => account_number,
      "routing"       => routing,
      "type"          => type,
      "name"          => name
    }
      |> Utils.maybe_put("account",   account)

    post(@add_bank_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Adds a CAD bank account for the user.

  ## Parameters
    - **swift_code**: SWIFT code.
    - **account_number**: Bank account number.
    - **institution_number** (optional): Institution number of the account.
    - **branch_number** (optional): Branch number of the account.
    - **type**: Type of bank account, "checking" or "savings".
    - **name**: Name on the bank account.
    - **account** (optional): Specifies the sub-account.
  """
  @spec add_bank_cad(
          swift_code          :: String.t(),
          account_number      :: String.t(),
          type                :: String.t(),
          name                :: String.t(),
          account             :: String.t() | nil,
          institution_number  :: String.t() | nil,
          branch_number       :: String.t() | nil
        ) :: {:ok, map} | {:error, any}
  def add_bank_cad(
        swift_code,
        account_number,
        type,
        name,
        account             \\ nil,
        institution_number  \\ nil,
        branch_number       \\ nil
      ) do
    payload = %{
      "swiftcode"     => swift_code,
      "accountnumber" => account_number,
      "type"          => type,
      "name"          => name
    }
      |> Utils.maybe_put("account",             account)
      |> Utils.maybe_put("institution_number",  institution_number)
      |> Utils.maybe_put("branch_number",       branch_number)

    post(@add_bank_cad_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Fetches payment methods and available fiat balances.

  ## Parameters
    - **account** (optional): Specifies the sub-account.
  """
  @spec payment_methods(account :: String.t() | nil) :: {:ok, map} | {:error, any}
  def payment_methods(account \\ nil) do
    payload = %{}
      |> Utils.maybe_put("account", account)

    post(@payment_methods_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves the staking balances for the account.

  ## Parameters
    - **account** (optional): Specifies the sub-account.
  """
  @spec staking_balances(account :: String.t() | nil) :: {:ok, list(map)} | {:error, any}
  def staking_balances(account \\ nil) do
    payload = %{}
      |> Utils.maybe_put("account", account)

    post(@staking_balances_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Fetches current staking interest rates for specified assets or all assets if no specific asset is provided.
  """
  @spec staking_rates() :: {:ok, map} | {:error, any}
  def staking_rates() do
    get(@staking_rates_url)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves staking rewards, showing historical payments and accrual data.

  ## Parameters
    - **since**: Start date in ISO datetime format.
    - **until** (optional): End date in ISO datetime format. Defaults to the current time.
    - **provider_id** (optional): ID of the provider.
    - **currency** (optional): Currency code, e.g., "ETH".
    - **account** (optional): Specifies the sub-account (required for Master API keys).
  """
  @spec staking_rewards(
          since       :: String.t(),
          until       :: String.t() | nil,
          provider_id :: String.t() | nil,
          currency    :: String.t() | nil,
          account     :: String.t() | nil
        ) :: {:ok, map} | {:error, any}
  def staking_rewards(since, until \\ nil, provider_id \\ nil, currency \\ nil, account \\ nil) do
    payload = %{"since" => since}
      |> Utils.maybe_put("account",     account)
      |> Utils.maybe_put("until",       until)
      |> Utils.maybe_put("providerId",  provider_id)
      |> Utils.maybe_put("currency",    currency)

    post(@staking_rewards_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves staking transaction history, including deposits, redemptions, and interest accruals.

  ## Parameters
    - **since** (optional): Start date in ISO datetime format.
    - **until** (optional): End date in ISO datetime format, defaults to the current time.
    - **limit** (optional): Max number of transactions to return.
    - **provider_id** (optional): ID of the provider.
    - **currency** (optional): Currency code, e.g., "ETH".
    - **interest_only** (optional): Set to true to only return daily interest transactions.
    - **sort_asc** (optional): Set to true to sort transactions in ascending order.
    - **account** (optional): Specifies the sub-account.
  """
  @spec staking_history(
          since         :: String.t()         | nil,
          until         :: String.t()         | nil,
          limit         :: non_neg_integer()  | nil,
          provider_id   :: String.t()         | nil,
          currency      :: String.t()         | nil,
          interest_only :: boolean            | nil,
          sort_asc      :: boolean            | nil,
          account       :: String.t()         | nil
        ) :: {:ok, list(map)} | {:error, any}
  def staking_history(
        since         \\ nil,
        until         \\ nil,
        limit         \\ nil,
        provider_id   \\ nil,
        currency      \\ nil,
        interest_only \\ nil,
        sort_asc      \\ nil,
        account       \\ nil
      ) do
    payload = %{}
      |> Utils.maybe_put("since",         since)
      |> Utils.maybe_put("until",         until)
      |> Utils.maybe_put("limit",         limit)
      |> Utils.maybe_put("providerId",    provider_id)
      |> Utils.maybe_put("currency",      currency)
      |> Utils.maybe_put("interestOnly",  interest_only)
      |> Utils.maybe_put("sortAsc",       sort_asc)
      |> Utils.maybe_put("account",       account)

    post(@staking_history_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Initiates a staking deposit.

  ## Parameters
    - **provider_id**: The provider ID in UUID4 format.
    - **currency**: The currency to deposit, e.g., "ETH".
    - **amount**: Amount of currency to deposit.
    - **account** (optional): Specifies the sub-account.
  """
  @spec stake(
          provider_id :: String.t(),
          currency    :: String.t(),
          amount      :: String.t(),
          account     :: String.t() | nil
        ) :: {:ok, map} | {:error, any}
  def stake(provider_id, currency, amount, account \\ nil) do
    payload = %{
      "providerId"  => provider_id,
      "currency"    => currency,
      "amount"      => amount
    }
      |> Utils.maybe_put("account", account)

    post(@staking_deposits_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Initiates a staking withdrawal.

  ## Parameters
    - **provider_id**: The provider ID in UUID4 format.
    - **currency**: The currency to withdraw, e.g., "ETH".
    - **amount**: Amount of currency to withdraw.
    - **account** (optional): Specifies the sub-account.
  """
  @spec unstake(
          provider_id :: String.t(),
          currency    :: String.t(),
          amount      :: String.t(),
          account     :: String.t() | nil
        ) :: {:ok, map} | {:error, any}
  def unstake(provider_id, currency, amount, account \\ nil) do
    payload = %{
      "providerId"  => provider_id,
      "currency"    => currency,
      "amount"      => amount
    }
      |> Utils.maybe_put("account", account)

    post(@staking_withdrawals_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Creates a request to add an address to the approved address list.

  ## Parameters
    - **network**: The network for the address, e.g., "ethereum", "bitcoin".
    - **address**: The address to add to the approved address list.
    - **label**: The label for the approved address.
    - **account** (optional): Specifies the sub-account.
    - **memo** (optional): Memo for specific address formats, e.g., Cosmos.
  """
  @spec create_address_request(
          network :: String.t(),
          address :: String.t(),
          label   :: String.t(),
          account :: String.t() | nil,
          memo    :: String.t() | nil
        ) :: {:ok, map} | {:error, any}
  def create_address_request(network, address, label, account \\ nil, memo \\ nil) do
    payload = %{
      "address" => address,
      "label"   => label
    }
      |> Utils.maybe_put("account", account)
      |> Utils.maybe_put("memo",    memo)

    post(@create_address_request_url |> String.replace(":network", network), payload)
      |> Utils.handle_response()
  end

  @doc """
  Views the approved address list for a specific network.

  ## Parameters
    - **network**: The network to view the approved address list for, e.g., "ethereum".
    - **account** (optional): Specifies the sub-account.
  """
  @spec view_approved_addresses(
          network :: String.t(),
          account :: String.t() | nil
        ) :: {:ok, map} | {:error, any}
  def view_approved_addresses(network, account \\ nil) do
    payload = %{}
      |> Utils.maybe_put("account", account)

    post(@view_approved_addresses_url |> String.replace(":network", network), payload)
      |> Utils.handle_response()
  end

  @doc """
  Removes an address from the approved address list.

  ## Parameters
    - **network**: The network for the address, e.g., "ethereum".
    - **address**: The address to remove from the approved address list.
    - **account** (optional): Specifies the sub-account.
  """
  @spec remove_address(
          network :: String.t(),
          address :: String.t(),
          account :: String.t() | nil
        ) :: {:ok, map} | {:error, any}
  def remove_address(network, address, account \\ nil) do
    payload = %{"address" => address}
      |> Utils.maybe_put("account", account)

    post(@remove_addresses_from_approved_addresses_list_url |> String.replace(":network", network), payload)
      |> Utils.handle_response()
  end

  @doc """
  Fetches account details, including user and account information.

  ## Parameters
    - **account** (optional): Specifies the sub-account.
  """
  @spec account_detail(account :: String.t() | nil) :: {:ok, map} | {:error, any}
  def account_detail(account \\ nil) do
    payload = %{}
      |> Utils.maybe_put("account", account)

    post(@account_detail_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Creates a new account within the master group.

  ## Parameters
    - **name**: A unique name for the new account.
    - **type** (optional): Type of account. Accepts "exchange" or "custody". Defaults to "exchange".
  """
  @spec create_account(name :: String.t(), type :: String.t() | nil) :: {:ok, map} | {:error, any}
  def create_account(name, type \\ "exchange") do
    payload = %{"name" => name}
      |> Utils.maybe_put("type", type)

    post(@create_account_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Renames an account within the master group.

  ## Parameters
    - **account**: Short name of the existing account.
    - **new_name** (optional): New unique name for the account.
    - **new_account** (optional): New unique short name for the account.
  """
  @spec rename_account(
          account     :: String.t(),
          new_name    :: String.t() | nil,
          new_account :: String.t() | nil
        ) :: {:ok, map} | {:error, any}
  def rename_account(account, new_name \\ nil, new_account \\ nil) do
    payload = %{
      "account" => account
    }
      |> Utils.maybe_put("newName",     new_name)
      |> Utils.maybe_put("newAccount",  new_account)

    post(@rename_account_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Fetches a list of accounts within the master group.

  ## Parameters
    - **limit_accounts** (optional): Max number of accounts to return. Default is 500.
    - **timestamp** (optional): Only return accounts created on or before this timestamp.
  """
  @spec list_accounts(
          limit_accounts  :: non_neg_integer() | nil,
          timestamp       :: non_neg_integer() | nil
        ) :: {:ok, list(map)} | {:error, any}
  def list_accounts(limit_accounts \\ 500, timestamp \\ nil) do
    payload = %{}
      |> Utils.maybe_put("limit_accounts",  limit_accounts)
      |> Utils.maybe_put("timestamp",       timestamp)

    post(@accounts_in_master_group_url, payload)
      |> Utils.handle_response()
  end

  @doc """
  Sends a heartbeat to prevent session timeout when the require heartbeat flag is set.
  """
  @spec heartbeat() :: {:ok, map} | {:error, any}
  def heartbeat do
    post(@heartbeat_url, %{})
      |> Utils.handle_response()
  end
end
