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
  Places a new order with specified parameters and optional settings.

  ## Parameters

    - **symbol** (*String.t()*): The trading pair symbol (e.g., **"btcusd"**).
    - **amount** (*String.t()*): The amount to purchase as a string.
    - **price** (*String.t()*): The limit price per unit as a string.
    - **side** (*String.t()*): Order side, either **"buy"** or **"sell"**.
    - **type** (*String.t()*): Order type, e.g., **"exchange limit"** or **"exchange stop limit"**.
    - **opts** (*keyword list, optional*): Optional settings for the order.
      - **:client_order_id** (*String.t()*): A custom client ID for the order.
      - **:stop_price** (*String.t()*): The stop price for stop-limit orders.
      - **:options** (*list(String.t())*): List of order execution options (e.g., **["maker-or-cancel"]**).
      - **:account** (*String.t()*): Specifies the sub-account (required for master API keys).

  ## Returns

    - **{:ok, map}** on success, containing order details.
    - **{:error, any}** on failure, with an error reason.
  """
  @spec new_order(
          symbol  :: String.t(),
          amount  :: String.t(),
          price   :: String.t(),
          side    :: String.t(),
          type    :: String.t(),
          opts    :: [
            {:client_order_id,  String.t()},
            {:stop_price,       String.t()},
            {:options,          list(String.t())},
            {:account,          String.t()}
          ]
        ) :: {:ok, map} | {:error, any}
  def new_order(symbol, amount, price, side, type, opts \\ []) do
    payload = %{
      "symbol"  => symbol,
      "amount"  => amount,
      "price"   => price,
      "side"    => side,
      "type"    => type
    }
      |> Utils.merge_map_with_string_keys(opts)

    post(@new_order_url, payload, opts: [path: @new_order_url])
      |> Utils.handle_response()
  end

  @doc """
  Cancels an existing order by order ID.

  ## Parameters

    - **order_id** (*non_neg_integer()*): The ID of the order to cancel.
    - **opts** (*keyword list, optional*): A list of additional options.
      - **:account** (*String.t()*): Specifies the name of the account within the subaccount group. This is required if using a Master API key.

  ## Behavior

    If the order has already been canceled, this request will succeed but have no effect. The order status will remain unchanged.

  ## Returns

    - **{:ok, map}** on success, containing the response details of the canceled order.
    - **{:error, any}** on failure, with an error reason.
  """
  @spec cancel_order(
          order_id  :: non_neg_integer(),
          opts      :: [
                         {:account, String.t()}
                       ]
        ) :: {:ok, map} | {:error, any}
  def cancel_order(order_id, opts \\ []) do
    payload = %{"order_id" => order_id} |> Utils.merge_map_with_string_keys(opts)

    post(@cancel_order_url, payload, opts: [path: @cancel_order_url])
      |> Utils.handle_response()
  end

  @doc """
  Wraps or unwraps Gemini-issued assets.

  ## Parameters

    - **symbol** (*String.t()*): The trading pair symbol for the asset to be wrapped or unwrapped (e.g., **"GUSDUSD"**).
    - **amount** (*String.t()*): The amount to be wrapped or unwrapped, specified as a string.
    - **side** (*String.t()*): The direction of the transaction, either **"buy"** (to wrap) or **"sell"** (to unwrap).
    - **opts** (*keyword list, optional*): Additional options for the transaction.
      - **:account** (*String.t()*): Specifies the sub-account, required if using a master API key.
      - **:client_order_id** (*String.t()*): A custom client ID for tracking the order.

  ## Returns

    - **{:ok, map}** on success, containing details of the wrap or unwrap transaction.
    - **{:error, any}** on failure, with an error reason.
  """
  @spec wrap_order(
          symbol :: String.t(),
          amount :: String.t(),
          side :: String.t(),
          opts :: [
                    {:account, String.t()},
                    {:client_order_id, String.t()}
                  ]
        ) :: {:ok, map} | {:error, any}
  def wrap_order(symbol, amount, side, opts \\ []) do
    payload = %{"amount" => amount, "side" => side}
      |> Utils.merge_map_with_string_keys(opts)

    post(@wrap_order_url |> String.replace(":symbol", symbol), payload, opts: [path: @wrap_order_url])
      |> Utils.handle_response()
  end

  @doc """
  Cancels all orders opened by this session.

  If "Require Heartbeat" is enabled for the session, this function behaves as a heartbeat expiration.

  ## Parameters

    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account, required if using a master API key.
  """
  @spec cancel_all_session_orders(opts :: [account: String.t()]) :: {:ok, map} | {:error, any}
  def cancel_all_session_orders(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@cancel_all_session_orders_url, payload, opts: [path: @cancel_all_session_orders_url])
      |> Utils.handle_response()
  end

  @doc """
  Cancels all outstanding orders created by any session associated with this account, including those placed via the UI.

  Generally, it is recommended to use **cancel_all_session_orders** to only cancel orders related to the current session.

  ## Parameters

    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account, required if using a master API key.
  """
  @spec cancel_all_active_orders(opts :: [account: String.t()]) :: {:ok, map} | {:error, any}
  def cancel_all_active_orders(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@cancel_all_active_orders_url, payload, opts: [path: @cancel_all_active_orders_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves the status of a specific order, identified by either **order_id** or **client_order_id**.

  ## Parameters

    - **opts** (*keyword list, optional*): Options for specifying order details.
      - **:order_id** (*non_neg_integer()*): The order ID to retrieve status for. Cannot be used with **client_order_id**.
      - **:client_order_id** (*String.t()*): The client-specified order ID used during order placement. Cannot be used with **order_id**.
      - **:include_trades** (*boolean()*): If **true**, includes trade details for all fills associated with the order.
      - **:account** (*String.t()*): Specifies the sub-account, required if using a master API key.
  """
  @spec order_status(opts :: [
                               {:order_id, non_neg_integer()},
                               {:client_order_id, String.t()},
                               {:include_trades, boolean},
                               {:account, String.t()}
                             ]
        ) :: {:ok, map} | {:error, any}
  def order_status(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@order_status_url, payload, opts: [path: @order_status_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves all active (live) orders associated with the account.

  ## Parameters

    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account, required if using a master API key.
  """
  @spec active_orders(opts :: [account: String.t()]) :: {:ok, list(map)} | {:error, any}
  def active_orders(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@active_orders_url, payload, opts: [path: @active_orders_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves past trades for a specific symbol.

  ## Parameters

    - **opts** (*keyword list, optional*): Options to customize the trade retrieval.
      - **:symbol** (*String.t()*): The symbol to retrieve trades for (e.g., "btcusd").
      - **:limit_trades** (*non_neg_integer()*): Maximum number of trades to return (default 50, max 500).
      - **:timestamp** (*non_neg_integer()*): Only return trades on or after this timestamp.
      - **:account** (*String.t()*): Specifies the sub-account, required if using a master API key.
  """
  @spec past_trades(opts :: [
                              {:symbol,       String.t()},
                              {:limit_trades, non_neg_integer()},
                              {:timestamp,    non_neg_integer()},
                              {:account,      String.t()}
                            ]
        ) :: {:ok, list(map)} | {:error, any}
  def past_trades(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@past_trades_url, payload, opts: [path: @past_trades_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves a history of closed orders for a specific symbol.

  ## Parameters

    - **opts** (*keyword list, optional*): Options to customize the order retrieval.
      - **:symbol** (*String.t()*): The symbol to retrieve orders for (e.g., "btcusd").
      - **:limit_orders** (*non_neg_integer()*): Maximum number of orders to return (default 50, max 500).
      - **:timestamp** (*non_neg_integer()*): Only return orders on or after this timestamp.
      - **:account** (*String.t()*): Specifies the sub-account, required if using a master API key.
  """
  @spec orders_history(opts :: [
                                 {:symbol,        String.t()},
                                 {:limit_orders,  non_neg_integer()},
                                 {:timestamp,     non_neg_integer()},
                                 {:account,       String.t()}
                               ]
        ) :: {:ok, list(map)} | {:error, any}
  def orders_history(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@orders_history_url, payload, opts: [path: @orders_history_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves the 30-day notional volume and fee details for the account.

  ## Parameters

    - **opts** (*keyword list, optional*): Additional options.
      - **:symbol** (*String.t()*): The participating symbol for fee promotions (e.g., "btcusd").
      - **:account** (*String.t()*): Specifies the sub-account, required if using a master API key.
  """
  @spec notional_volume(opts :: [
                                  {:symbol,   String.t()},
                                  {:account,  String.t()}
                                ]
        ) :: {:ok, map} | {:error, any}
  def notional_volume(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@notional_volume_url, payload, opts: [path: @notional_volume_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves the trade volume data for the account over the past 30 days.

  ## Parameters

    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account. This is required if using a master API key.
  """
  @spec trade_volume(opts :: [account: String.t()]) :: {:ok, list(map)} | {:error, any}
  def trade_volume(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@trade_volume_url, payload, opts: [path: @trade_volume_url])
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
    url = @fx_rate_url
            |> String.replace(":symbol",    symbol)
            |> String.replace(":timestamp", Integer.to_string(timestamp))

    get(url, opts: [path: @fx_rate_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves all open positions for the account.

  ## Parameters

    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account. This is required if using a master API key.
  """
  @spec open_positions(opts :: [account: String.t()]) :: {:ok, list(map)} | {:error, any}
  def open_positions(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@open_positions_url, payload, opts: [path: @open_positions_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves margin details for a specific symbol.

  ## Parameters

    - **symbol** (*String.t()*): The trading pair symbol (e.g., **"BTC-GUSD-PERP"**).
    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account. This is required if using a master API key.
  """
  @spec account_margin(symbol :: String.t(), opts :: [account: String.t()]) :: {:ok, map} | {:error, any}
  def account_margin(symbol, opts \\ []) do
    payload = %{"symbol" => symbol}
      |> Utils.merge_map_with_string_keys(opts)

    post(@account_margin_url, payload, opts: [path: @account_margin_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves risk statistics for a specified symbol.

  ## Parameters

    - **symbol** (*String.t()*): The trading pair symbol (e.g., **"BTCGUSDPERP"**).
  """
  @spec risk_stats(symbol :: String.t()) :: {:ok, map} | {:error, any}
  def risk_stats(symbol) do
    get(@risk_stats_url |> String.replace(":symbol", symbol), opts: [path: @risk_stats_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves funding payment history within a specified time range.

  ## Parameters

    - **opts** (*keyword list, optional*): Options to customize the funding payment query.
      - **:since** (*non_neg_integer()*): The starting timestamp for the funding payments.
      - **:to** (*non_neg_integer()*): The ending timestamp for the funding payments.
      - **:account** (*String.t()*): Specifies the sub-account. This is required if using a master API key.
  """
  @spec funding_payment(opts :: [
                                  {:since,    non_neg_integer()},
                                  {:to,       non_neg_integer()},
                                  {:account,  String.t()}
                                ]
        ) :: {:ok, list(map)} | {:error, any}
  def funding_payment(opts \\ []) do
    query = opts
       |> Enum.filter(fn {key, _} -> key in [:since, :to] end)

    payload = %{}
      |> Utils.maybe_put("account", Keyword.get(opts, :account))

    post(@funding_payment_url, payload, query: query, opts: [path: @funding_payment_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves funding payment data as an Excel file for a specified date range and row limit.

  ## Parameters

    - **opts** (*keyword list, optional*): Options to customize the data retrieval.
      - **:from_date** (*String.t()*): Start date for the records in **YYYY-MM-DD** format.
      - **:to_date** (*String.t()*): End date for the records in **YYYY-MM-DD** format.
      - **:num_rows** (*non_neg_integer()*): Maximum number of rows to retrieve (default 8760).
  """
  @spec funding_payment_report_file(
          opts :: [
                    {:from_date,  String.t()},
                    {:to_date,    String.t()},
                    {:num_rows,   non_neg_integer()}
                  ]
        ) :: {:ok, binary} | {:error, any}
  def funding_payment_report_file(opts \\ []) do
    get(@funding_payment_report_file_url, query: opts, opts: [path: @funding_payment_report_file_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves funding payment data as JSON for a specified date range and row limit.

  ## Parameters

    - **opts** (*keyword list, optional*): Options to customize the data retrieval.
      - **:from_date** (*String.t()*): Start date for the records in **YYYY-MM-DD** format.
      - **:to_date** (*String.t()*): End date for the records in **YYYY-MM-DD** format.
      - **:num_rows** (*non_neg_integer()*): Maximum number of rows to retrieve (default 8760).
  """
  @spec funding_payment_report_json(
          opts :: [
                    {:from_date,  String.t()},
                    {:to_date,    String.t()},
                    {:num_rows,   non_neg_integer()}
                  ]
        ) :: {:ok, list(map)} | {:error, any}
  def funding_payment_report_json(opts \\ []) do
    get(@funding_payment_report_json_url, query: opts, opts: [path: @funding_payment_report_json_url])
      |> Utils.handle_response()
  end

  @doc """
  Creates a new clearing order with optional counterparty and expiration details.

  ## Parameters

    - **symbol** (*String.t()*): The trading pair symbol for the order (e.g., **"btcusd"**).
    - **amount** (*String.t()*): The amount to purchase as a string.
    - **price** (*String.t()*): The price per unit as a string.
    - **side** (*String.t()*): **"buy"** or **"sell"**.
    - **opts** (*keyword list, optional*): Additional options for the clearing order.
      - **:counterparty_id** (*String.t()*): ID of the counterparty for this trade.
      - **:expires_in_hrs** (*non_neg_integer()*): Number of hours before the trade expires.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec new_clearing_order(
          symbol  :: String.t(),
          amount  :: String.t(),
          price   :: String.t(),
          side    :: String.t(),
          opts    :: [
                      {:counterparty_id,  String.t()},
                      {:expires_in_hrs,   non_neg_integer()},
                      {:account,          String.t()}
                    ]
        ) :: {:ok, map} | {:error, any}
  def new_clearing_order(symbol, amount, price, side, opts \\ []) do
    payload = %{
      "symbol" => symbol,
      "amount" => amount,
      "price"  => price,
      "side"   => side
    }
    |> Utils.merge_map_with_string_keys(opts)

    post(@new_clearing_order_url, payload, opts: [path: @new_clearing_order_url])
      |> Utils.handle_response()
  end

  @doc """
  Creates a new broker clearing order between two counterparties.

  ## Parameters

    - **symbol** (*String.t()*): The trading pair symbol.
    - **amount** (*String.t()*): The amount to purchase as a string.
    - **price** (*String.t()*): The price per unit as a string.
    - **side** (*String.t()*): **"buy"** or **"sell"**.
    - **source_counterparty_id** (*String.t()*): The counterparty initiating the trade.
    - **target_counterparty_id** (*String.t()*): The target counterparty.
    - **opts** (*keyword list, optional*): Additional options for the broker order.
      - **:expires_in_hrs** (*non_neg_integer()*): Number of hours before the trade expires.
      - **:account** (*String.t()*): Specifies the broker sub-account.
  """
  @spec new_broker_order(
          symbol                  :: String.t(),
          amount                  :: String.t(),
          price                   :: String.t(),
          side                    :: String.t(),
          source_counterparty_id  :: String.t(),
          target_counterparty_id  :: String.t(),
          opts :: [
                    {:expires_in_hrs, non_neg_integer()},
                    {:account,        String.t()}
                  ]
        ) :: {:ok, map} | {:error, any}
  def new_broker_order(symbol, amount, price, side, source_counterparty_id, target_counterparty_id, opts \\ []) do
    payload = %{
      "symbol"                 => symbol,
      "amount"                 => amount,
      "price"                  => price,
      "side"                   => side,
      "source_counterparty_id" => source_counterparty_id,
      "target_counterparty_id" => target_counterparty_id
    }
      |> Utils.merge_map_with_string_keys(opts)

    post(@new_broker_order_url, payload, opts: [path: @new_broker_order_url])
      |> Utils.handle_response()
  end
  @doc """
  Fetches the status of a clearing order by its unique clearing ID.

  ## Parameters
    - **clearing_id**: A unique identifier for the clearing order.
    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec clearing_order_status(clearing_id :: String.t(), opts :: [account: String.t()]) :: {:ok, map} | {:error, any}
  def clearing_order_status(clearing_id, opts \\ []) do
    payload = %{"clearing_id" => clearing_id}
      |> Utils.merge_map_with_string_keys(opts)

    post(@clearing_order_status_url, payload, opts: [path: @clearing_order_status_url])
      |> Utils.handle_response()
  end

  @doc """
  Cancels a specific clearing order.

  ## Parameters

    - **clearing_id**: The unique identifier of the clearing order.
    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec cancel_clearing_order(clearing_id :: String.t(), opts :: [account: String.t()]) :: {:ok, map} | {:error, any}
  def cancel_clearing_order(clearing_id, opts \\ []) do
    payload = %{"clearing_id" => clearing_id}
      |> Utils.merge_map_with_string_keys(opts)

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
    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec confirm_clearing_order(
          clearing_id :: String.t(),
          symbol      :: String.t(),
          amount      :: String.t(),
          price       :: String.t(),
          side        :: String.t(),
          opts        :: [account: String.t()]
        ) :: {:ok, map} | {:error, any}
  def confirm_clearing_order(clearing_id, symbol, amount, price, side, opts \\ []) do
    payload = %{
      "clearing_id" => clearing_id,
      "symbol"      => symbol,
      "amount"      => amount,
      "price"       => price,
      "side"        => side
    }
      |> Utils.merge_map_with_string_keys(opts)

    post(@confirm_clearing_order_url, payload, opts: [path: @confirm_clearing_order_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves a list of clearing orders with optional filters.

  ## Parameters

    - **side** (*String.t()*): "buy" or "sell" (required).
    - **opts** (*keyword list, optional*): Filter options for the clearing orders.
      - **:symbol** (*String.t()*): Trading pair symbol.
      - **:counterparty** (*String.t()*): Counterparty ID or alias.
      - **:expiration_start** (*non_neg_integer()*): Start timestamp for expiration filter.
      - **:expiration_end** (*non_neg_integer()*): End timestamp for expiration filter.
      - **:submission_start** (*non_neg_integer()*): Start timestamp for submission filter.
      - **:submission_end** (*non_neg_integer()*): End timestamp for submission filter.
      - **:funded** (*boolean()*): Whether the order is funded.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec clearing_order_list(
          side    :: String.t(),
          opts    :: [
             {:symbol,            String.t()},
             {:counterparty,      String.t()},
             {:expiration_start,  non_neg_integer()},
             {:expiration_end,    non_neg_integer()},
             {:submission_start,  non_neg_integer()},
             {:submission_end,    non_neg_integer()},
             {:funded,            boolean()},
             {:account,           String.t()}
         ]
        ) :: {:ok, map} | {:error, any}
  def clearing_order_list(side, opts \\ []) do
    payload = %{"side" => side}
      |> Utils.merge_map_with_string_keys(opts)

    post(@clearing_order_list_url, payload, opts: [path: @clearing_order_list_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves a list of broker clearing orders with optional filters.

  ## Parameters

    - **opts** (*keyword list, optional*): Filter options for broker clearing orders.
      - **:symbol** (*String.t()*): Trading pair symbol.
      - **:expiration_start** (*non_neg_integer()*): Start timestamp for expiration filter.
      - **:expiration_end** (*non_neg_integer()*): End timestamp for expiration filter.
      - **:submission_start** (*non_neg_integer()*): Start timestamp for submission filter.
      - **:submission_end** (*non_neg_integer()*): End timestamp for submission filter.
      - **:funded** (*boolean()*): Whether the order is funded.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec clearing_broker_list(
          opts :: [
            {:symbol,           String.t()},
            {:expiration_start, non_neg_integer()},
            {:expiration_end,   non_neg_integer()},
            {:submission_start, non_neg_integer()},
            {:submission_end,   non_neg_integer()},
            {:funded,           boolean()},
            {:account,          String.t()}
          ]
        ) :: {:ok, map} | {:error, any}
  def clearing_broker_list(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@clearing_broker_list_url, payload, opts: [path: @clearing_broker_list_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves a list of clearing trades with optional filters.

  ## Parameters

    - **opts** (*keyword list, optional*): Filter options for clearing trades.
      - **:timestamp_nanos** (*non_neg_integer()*): Only return trades on or after this timestamp in nanoseconds.
      - **:limit** (*non_neg_integer()*): The maximum number of trades to return.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec clearing_trades(
          opts :: [
            {:timestamp_nanos,  non_neg_integer()},
            {:limit,            non_neg_integer()},
            {:account,          String.t()}
          ]
        ) :: {:ok, map} | {:error, any}
  def clearing_trades(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@clearing_trades_url, payload, opts: [path: @clearing_trades_url])
      |> Utils.handle_response()
  end
  @doc """
  Fetches available balances in supported currencies.

  ## Parameters

    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec available_balances(opts :: [account: String.t()]) :: {:ok, list(map)} | {:error, any}
  def available_balances(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@available_balances_url, payload, opts: [path: @available_balances_url])
      |> Utils.handle_response()
  end

  @doc """
  Fetches balances and their notional values in a specified currency.

  ## Parameters

    - **currency** (*String.t()*): Three-letter fiat currency code for notional values (e.g., "usd").
    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec notional_balances(currency :: String.t(), opts :: [account: String.t()]) :: {:ok, list(map)} | {:error, any}
  def notional_balances(currency, opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@notional_balances_url |> String.replace(":currency", currency), payload, opts: [path: @notional_balances_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves transfer history, including deposits and withdrawals.

  ## Parameters

    - **opts** (*keyword list, optional*): Options for filtering transfers.
      - **:currency** (*String.t()*): Currency code to filter transfers.
      - **:timestamp** (*non_neg_integer()*): Only return transfers on or after this timestamp.
      - **:limit_transfers** (*non_neg_integer()*): Maximum number of transfers to return.
      - **:show_completed_deposit_advances** (*boolean()*): Whether to show completed deposit advances.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec transfers(
          opts :: [
            {:currency,                         String.t()},
            {:timestamp,                        non_neg_integer()},
            {:limit_transfers,                  non_neg_integer()},
            {:show_completed_deposit_advances,  boolean()},
            {:account,                          String.t()}
          ]
        ) :: {:ok, list(map)} | {:error, any}
  def transfers(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@transfers_url, payload, opts: [path: @transfers_url])
      |> Utils.handle_response()
  end

  @doc """
  Fetches transaction details, including trades and transfers.

  ## Parameters

    - **opts** (*keyword list, optional*): Options for filtering transactions.
      - **:timestamp_nanos** (*non_neg_integer()*): Only return transactions on or after this timestamp in nanoseconds.
      - **:limit** (*non_neg_integer()*): Maximum number of transactions to return (default is 100).
      - **:continuation_token** (*String.t()*): Token for pagination in subsequent requests.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec transactions(
          opts :: [
           {:timestamp_nanos,     non_neg_integer()},
           {:limit,               non_neg_integer()},
           {:continuation_token,  String.t()},
           {:account,             String.t()}
         ]
        ) :: {:ok, map} | {:error, any}
  def transactions(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@transactions_url, payload, opts: [path: @transactions_url])
      |> Utils.handle_response()
  end

  @doc """
  Estimates gas fees for a cryptocurrency withdrawal.

  ## Parameters

    - **currency** (*String.t()*): The cryptocurrency code (e.g., "eth").
    - **address** (*String.t()*): Destination cryptocurrency address.
    - **amount** (*String.t()*): The amount to withdraw.
    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec estimate_gas_fee(
          currency :: String.t(),
          address  :: String.t(),
          amount   :: String.t(),
          opts     :: [account: String.t()]
        ) :: {:ok, map} | {:error, any}
  def estimate_gas_fee(currency, address, amount, opts \\ []) do
    payload = %{
      "address" => address,
      "amount"  => amount
    }
      |> Utils.merge_map_with_string_keys(opts)

    url = @gas_fee_estimation_url |> String.replace(":currency_code", currency)

    post(url, payload, opts: [path: @gas_fee_estimation_url])
      |> Utils.handle_response()
  end

  @doc """
  Withdraws cryptocurrency funds to an approved address.

  ## Parameters

    - **currency** (*String.t()*): The cryptocurrency code (e.g., "btc").
    - **address** (*String.t()*): The destination cryptocurrency address.
    - **amount** (*String.t()*): The amount to withdraw.
    - **opts** (*keyword list, optional*): Additional options.
      - **:client_transfer_id** (*String.t()*): Unique identifier for the withdrawal.
      - **:memo** (*String.t()*): Memo for addresses requiring it.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec withdraw_crypto_funds(
          currency :: String.t(),
          address  :: String.t(),
          amount   :: String.t(),
          opts     :: [
            {:client_transfer_id, String.t()},
            {:memo,               String.t()},
            {:account,            String.t()}
          ]
        ) :: {:ok, map} | {:error, any}
  def withdraw_crypto_funds(currency, address, amount, opts \\ []) do
    payload = %{
      "address" => address,
      "amount"  => amount
    }
      |> Utils.merge_map_with_string_keys(opts)

    url = @withdraw_crypto_funds_url |> String.replace(":currency", currency)

    post(url, payload, opts: [path: @withdraw_crypto_funds_url])
      |> Utils.handle_response()
  end
  @doc """
  Executes an internal transfer between two accounts.

  ## Parameters

    - **currency** (*String.t()*): Currency code (e.g., "btc").
    - **source_account** (*String.t()*): The account to transfer funds from.
    - **target_account** (*String.t()*): The account to transfer funds to.
    - **amount** (*String.t()*): The amount to transfer.
    - **opts** (*keyword list, optional*): Additional options.
      - **:client_transfer_id** (*String.t()*): Unique identifier for the transfer.
  """
  @spec execute_internal_transfer(
          currency         :: String.t(),
          source_account   :: String.t(),
          target_account   :: String.t(),
          amount           :: String.t(),
          opts             :: [client_transfer_id: String.t()]
        ) :: {:ok, map} | {:error, any}
  def execute_internal_transfer(currency, source_account, target_account, amount, opts \\ []) do
    payload = %{
      "sourceAccount" => source_account,
      "targetAccount" => target_account,
      "amount"        => amount
    }
      |> Utils.merge_map_with_string_keys(opts)

    url = @internal_transfers_url |> String.replace(":currency", currency)

    post(url, payload, opts: [path: @internal_transfers_url])
      |> Utils.handle_response()
  end

  @doc """
  Fetches custody account fees.

  ## Parameters

    - **opts** (*keyword list, optional*): Options for filtering custody fees.
      - **:timestamp** (*non_neg_integer()*): Only return Custody fee records on or after this timestamp.
      - **:limit_transfers** (*non_neg_integer()*): The maximum number of Custody fee records to return.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec custody_account_fees(
          opts :: [
            {:timestamp,        non_neg_integer()},
            {:limit_transfers,  non_neg_integer()},
            {:account,          String.t()}
          ]
        ) :: {:ok, list(map)} | {:error, any}
  def custody_account_fees(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@custody_account_fees_url, payload, opts: [path: @custody_account_fees_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves deposit addresses for a specified network.

  ## Parameters

    - **network** (*String.t()*): Cryptocurrency network (e.g., "bitcoin", "ethereum").
    - **opts** (*keyword list, optional*): Additional options.
      - **:timestamp** (*non_neg_integer()*): Only return addresses created on or after this timestamp.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec deposit_addresses(
          network :: String.t(),
          opts    :: [
             {:timestamp, non_neg_integer()},
             {:account,   String.t()}
           ]
        ) :: {:ok, list(map)} | {:error, any}
  def deposit_addresses(network, opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@deposit_addresses_url |> String.replace(":network", network), payload, opts: [path: @deposit_addresses_url])
      |> Utils.handle_response()
  end

  @doc """
  Generates a new deposit address for a specified network.

  ## Parameters

    - **network** (*String.t()*): Cryptocurrency network (e.g., "bitcoin", "litecoin").
    - **opts** (*keyword list, optional*): Additional options.
      - **:label** (*String.t()*): Label for the deposit address.
      - **:legacy** (*boolean()*): Whether to generate a legacy P2SH-P2PKH litecoin address.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec new_deposit_address(
          network :: String.t(),
          opts    :: [
            {:label,    String.t()},
            {:legacy,   boolean()},
            {:account,  String.t()}
          ]
        ) :: {:ok, map} | {:error, any}
  def new_deposit_address(network, opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    url = @new_deposit_address_url |> String.replace(":network", network)

    post(url, payload, opts: [path: @new_deposit_address_url])
      |> Utils.handle_response()
  end

  @doc """
  Adds a bank account for the user.

  ## Parameters

    - **account_number** (*String.t()*): Bank account number.
    - **routing** (*String.t()*): Routing number.
    - **type** (*String.t()*): Type of bank account, either **"checking"** or **"savings"**.
    - **name** (*String.t()*): Name on the bank account.
    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec add_bank(
          account_number :: String.t(),
          routing        :: String.t(),
          type           :: String.t(),
          name           :: String.t(),
          opts           :: [account: String.t()]
        ) :: {:ok, map} | {:error, any}
  def add_bank(account_number, routing, type, name, opts \\ []) do
    payload = %{
      "accountnumber" => account_number,
      "routing"       => routing,
      "type"          => type,
      "name"          => name
    }
      |> Utils.merge_map_with_string_keys(opts)

    post(@add_bank_url, payload, opts: [path: @add_bank_url])
      |> Utils.handle_response()
  end
  @doc """
  Adds a CAD bank account for the user.

  ## Parameters

    - **swift_code** (*String.t()*): SWIFT code.
    - **account_number** (*String.t()*): Bank account number.
    - **type** (*String.t()*): Type of bank account, either "checking" or "savings".
    - **name** (*String.t()*): Name on the bank account.
    - **opts** (*keyword list, optional*): Additional options.
      - **:institution_number** (*String.t()*): Institution number of the account.
      - **:branch_number** (*String.t()*): Branch number of the account.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec add_bank_cad(
          swift_code      :: String.t(),
          account_number  :: String.t(),
          type            :: String.t(),
          name            :: String.t(),
          opts            :: [
            {:institution_number, String.t()},
            {:branch_number,      String.t()},
            {:account,            String.t()}
          ]
        ) :: {:ok, map} | {:error, any}
  def add_bank_cad(swift_code, account_number, type, name, opts \\ []) do
    payload = %{
      "swiftcode"     => swift_code,
      "accountnumber" => account_number,
      "type"          => type,
      "name"          => name
    }
      |> Utils.merge_map_with_string_keys(opts)

    post(@add_bank_cad_url, payload, opts: [path: @add_bank_cad_url])
      |> Utils.handle_response()
  end

  @doc """
  Fetches payment methods and available fiat balances.

  ## Parameters

    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec payment_methods(opts :: [account: String.t()]) :: {:ok, map} | {:error, any}
  def payment_methods(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@payment_methods_url, payload, opts: [path: @payment_methods_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves the staking balances for the account.

  ## Parameters

    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec staking_balances(opts :: [account: String.t()]) :: {:ok, list(map)} | {:error, any}
  def staking_balances(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@staking_balances_url, payload, opts: [path: @staking_balances_url])
      |> Utils.handle_response()
  end

  @doc """
  Fetches current staking interest rates for specified assets or all assets if no specific asset is provided.
  """
  @spec staking_rates() :: {:ok, map} | {:error, any}
  def staking_rates() do
    get(@staking_rates_url, opts: [path: @staking_rates_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves staking rewards, showing historical payments and accrual data.

  ## Parameters

    - **since** (*String.t()*): Start date in ISO datetime format.
    - **opts** (*keyword list, optional*): Additional options.
      - **:until** (*String.t()*): End date in ISO datetime format. Defaults to the current time.
      - **:provider_id** (*String.t()*): ID of the provider.
      - **:currency** (*String.t()*): Currency code, e.g., "ETH".
      - **:account** (*String.t()*): Specifies the sub-account (required for Master API keys).
  """
  @spec staking_rewards(
          since :: String.t(),
          opts  :: [
            {:until,        String.t()},
            {:provider_id,  String.t()},
            {:currency,     String.t()},
            {:account,      String.t()}
          ]
        ) :: {:ok, map} | {:error, any}
  def staking_rewards(since, opts \\ []) do
    payload = %{"since" => since}
      |> Utils.merge_map_with_string_keys(opts)

    post(@staking_rewards_url, payload, opts: [path: @staking_rewards_url])
      |> Utils.handle_response()
  end

  @doc """
  Retrieves staking transaction history, including deposits, redemptions, and interest accruals.

  ## Parameters

    - **opts** (*keyword list, optional*): Options for filtering staking history.
      - **:since** (*String.t()*): Start date in ISO datetime format.
      - **:until** (*String.t()*): End date in ISO datetime format, defaults to the current time.
      - **:limit** (*non_neg_integer()*): Max number of transactions to return.
      - **:provider_id** (*String.t()*): ID of the provider.
      - **:currency** (*String.t()*): Currency code, e.g., "ETH".
      - **:interest_only** (*boolean()*): Set to true to only return daily interest transactions.
      - **:sort_asc** (*boolean()*): Set to true to sort transactions in ascending order.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec staking_history(
          opts :: [
            {:since,          String.t()},
            {:until,          String.t()},
            {:limit,          non_neg_integer()},
            {:provider_id,    String.t()},
            {:currency,       String.t()},
            {:interest_only,  boolean()},
            {:sort_asc,       boolean()},
            {:account,        String.t()}
          ]
        ) :: {:ok, list(map)} | {:error, any}
  def staking_history(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@staking_history_url, payload, opts: [path: @staking_history_url])
      |> Utils.handle_response()
  end

  @doc """
  Initiates a staking deposit.

  ## Parameters

    - **provider_id** (*String.t()*): The provider ID in UUID4 format.
    - **currency** (*String.t()*): The currency to deposit, e.g., "ETH".
    - **amount** (*String.t()*): Amount of currency to deposit.
    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec stake(
          provider_id :: String.t(),
          currency    :: String.t(),
          amount      :: String.t(),
          opts        :: [account: String.t()]
        ) :: {:ok, map} | {:error, any}
  def stake(provider_id, currency, amount, opts \\ []) do
    payload = %{
      "providerId" => provider_id,
      "currency"   => currency,
      "amount"     => amount
    }
      |> Utils.merge_map_with_string_keys(opts)

    post(@staking_deposits_url, payload, opts: [path: @staking_deposits_url])
      |> Utils.handle_response()
  end

  @doc """
  Initiates a staking withdrawal.

  ## Parameters

    - **provider_id** (*String.t()*): The provider ID in UUID4 format.
    - **currency** (*String.t()*): The currency to withdraw, e.g., "ETH".
    - **amount** (*String.t()*): Amount of currency to withdraw.
    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec unstake(
          provider_id :: String.t(),
          currency    :: String.t(),
          amount      :: String.t(),
          opts        :: [account: String.t()]
        ) :: {:ok, map} | {:error, any}
  def unstake(provider_id, currency, amount, opts \\ []) do
    payload = %{
      "providerId" => provider_id,
      "currency"   => currency,
      "amount"     => amount
    }
      |> Utils.merge_map_with_string_keys(opts)

    post(@staking_withdrawals_url, payload, opts: [path: @staking_withdrawals_url])
      |> Utils.handle_response()
  end

  @doc """
  Creates a request to add an address to the approved address list.

  ## Parameters

    - **network** (*String.t()*): The network for the address, e.g., "ethereum", "bitcoin".
    - **address** (*String.t()*): The address to add to the approved address list.
    - **label** (*String.t()*): The label for the approved address.
    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account.
      - **:memo** (*String.t()*): Memo for specific address formats, e.g., Cosmos.
  """
  @spec create_address_request(
          network :: String.t(),
          address :: String.t(),
          label   :: String.t(),
          opts    :: [
            {:account,  String.t()},
            {:memo,     String.t()}
          ]
        ) :: {:ok, map} | {:error, any}
  def create_address_request(network, address, label, opts \\ []) do
    payload = %{
      "address" => address,
      "label"   => label
    }
      |> Utils.merge_map_with_string_keys(opts)

    url = @create_address_request_url |> String.replace(":network", network)

    post(url, payload, opts: [path: @create_address_request_url])
      |> Utils.handle_response()
  end

  @doc """
  Views the approved address list for a specific network.

  ## Parameters

    - **network** (*String.t()*): The network to view the approved address list for, e.g., "ethereum".
    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec view_approved_addresses(
          network :: String.t(),
          opts    :: [account: String.t()]
        ) :: {:ok, map} | {:error, any}
  def view_approved_addresses(network, opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    url = @view_approved_addresses_url |> String.replace(":network", network)

    post(url, payload, opts: [path: @view_approved_addresses_url])
      |> Utils.handle_response()
  end

  @doc """
  Removes an address from the approved address list.

  ## Parameters

    - **network** (*String.t()*): The network for the address, e.g., "ethereum".
    - **address** (*String.t()*): The address to remove from the approved address list.
    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec remove_address(
          network :: String.t(),
          address :: String.t(),
          opts    :: [account: String.t()]
        ) :: {:ok, map} | {:error, any}
  def remove_address(network, address, opts \\ []) do
    payload = %{"address" => address}
      |> Utils.merge_map_with_string_keys(opts)

    url = @remove_addresses_from_approved_addresses_list_url |> String.replace(":network", network)

    post(url, payload, opts: [path: @remove_addresses_from_approved_addresses_list_url])
      |> Utils.handle_response()
  end

  @doc """
  Fetches account details, including user and account information.

  ## Parameters

    - **opts** (*keyword list, optional*): Additional options.
      - **:account** (*String.t()*): Specifies the sub-account.
  """
  @spec account_detail(opts :: [account: String.t()]) :: {:ok, map} | {:error, any}
  def account_detail(opts \\ []) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@account_detail_url, payload, opts: [path: @account_detail_url])
      |> Utils.handle_response()
  end

  @doc """
  Creates a new account within the master group.

  ## Parameters

    - **name** (*String.t()*): A unique name for the new account.
    - **opts** (*keyword list, optional*): Additional options.
      - **:type** (*String.t()*): Type of account. Accepts **"exchange"** or **"custody"**. Defaults to **"exchange"**.
  """
  @spec create_account(name :: String.t(), opts :: [type: String.t()]) :: {:ok, map} | {:error, any}
  def create_account(name, opts \\ [type: "exchange"]) do
    payload = %{"name" => name}
      |> Utils.merge_map_with_string_keys(opts)

    post(@create_account_url, payload, opts: [path: @create_account_url])
      |> Utils.handle_response()
  end

  @doc """
  Renames an account within the master group.

  ## Parameters

    - **account** (*String.t()*): Short name of the existing account.
    - **opts** (*keyword list, optional*): Additional options for renaming the account.
      - **:new_name** (*String.t()*): New unique name for the account.
      - **:new_account** (*String.t()*): New unique short name for the account.
  """
  @spec rename_account(
          account :: String.t(),
          opts    :: [
            {:new_name,     String.t()},
            {:new_account,  String.t()}
          ]
        ) :: {:ok, map} | {:error, any}
  def rename_account(account, opts \\ []) do
    payload = %{"account" => account}
      |> Utils.merge_map_with_string_keys(opts)

    post(@rename_account_url, payload, opts: [path: @rename_account_url])
      |> Utils.handle_response()
  end

  @doc """
  Fetches a list of accounts within the master group.

  ## Parameters

    - **opts** (*keyword list, optional*): Options for filtering the account list.
      - **:limit_accounts** (*non_neg_integer()*): Max number of accounts to return. Default is 500.
      - **:timestamp** (*non_neg_integer()*): Only return accounts created on or before this timestamp.
  """
  @spec list_accounts(
          opts :: [
            {:limit_accounts, non_neg_integer()},
            {:timestamp,      non_neg_integer()}
          ]
        ) :: {:ok, list(map)} | {:error, any}
  def list_accounts(opts \\ [limit_accounts: 500]) do
    payload = %{}
      |> Utils.merge_map_with_string_keys(opts)

    post(@accounts_in_master_group_url, payload, opts: [path: @accounts_in_master_group_url])
      |> Utils.handle_response()
  end

  @doc """
  Sends a heartbeat to prevent session timeout when the require heartbeat flag is set.
  """
  @spec heartbeat() :: {:ok, map} | {:error, any}
  def heartbeat do
    post(@heartbeat_url, %{}, opts: [path: @heartbeat_url])
      |> Utils.handle_response()
  end
end
