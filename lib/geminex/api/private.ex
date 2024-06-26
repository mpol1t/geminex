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

  defp generate_payload(request, params) do
    %{
      "request" => request,
      "nonce" => :os.system_time(:second)
    }
    |> Map.merge(params)
  end
end