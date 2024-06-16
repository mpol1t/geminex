#defmodule Geminex.API.Private do
#  @moduledoc """
#  Private API endpoints for Gemini.
#  """
#
#  alias Geminex.HttpClient
#
#  # Base URL
#  @base_url "https://api.gemini.com/v1"
#
#  # Private API endpoints
#  @available_balances_url       "#{@base_url}/balances"
#  @notional_balances_url        "#{@base_url}/notionalbalances/:currency"
#  @transfers_url                "#{@base_url}/transfers"
#  @transactions_url             "#{@base_url}/transactions"
#  @custody_account_fees_url     "#{@base_url}/custodyaccountfees"
#  @get_deposit_addresses_url    "#{@base_url}/addresses/:network"
#  @new_deposit_address_url      "#{@base_url}/deposit/:network/newAddress"
#  @withdraw_crypto_funds_url    "#{@base_url}/withdraw/:currency"
#  @gas_fee_estimation_url       "#{@base_url}/withdraw/:currencyCodeLowerCase/feeEstimate"
#  @internal_transfers_url       "#{@base_url}/account/transfer/:currency"
#  @add_bank_url                 "#{@base_url}/payments/addbank"
#  @add_bank_cad_url             "#{@base_url}/payments/addbank/cad"
#  @payment_methods_url          "#{@base_url}/payments/methods"
#  @earn_balances_url            "#{@base_url}/balances/earn"
#  @earn_rates_url               "#{@base_url}/earn/rates"
#  @earn_interest_url            "#{@base_url}/earn/interest"
#  @earn_history_url             "#{@base_url}/earn/history"
#  @staking_balances_url         "#{@base_url}/balances/staking"
#  @staking_rates_url            "#{@base_url}/staking/rates"
#  @staking_rewards_url          "#{@base_url}/staking/rewards"
#  @staking_history_url          "#{@base_url}/staking/history"
#  @staking_deposit_url          "#{@base_url}/staking/stake"
#  @staking_withdrawal_url       "#{@base_url}/staking/unstake"
#  @create_address_request_url   "#{@base_url}/approvedAddresses/:network/request"
#  @view_approved_addresses_url  "#{@base_url}/approvedAddresses/account/:network"
#  @remove_address_url           "#{@base_url}/approvedAddresses/:network/remove"
#  @account_detail_url           "#{@base_url}/account"
#  @create_account_url           "#{@base_url}/account/create"
#  @rename_account_url           "#{@base_url}/account/rename"
#  @get_accounts_url             "#{@base_url}/account/list"
#  @heartbeat_url                "#{@base_url}/heartbeat"
#  @doc """
#  Places a new order.
#
#  ## Parameters
#
#    - symbol: The symbol for the new order (e.g., BTCUSD).
#    - amount: The amount to purchase.
#    - price: The price per unit.
#    - side: "buy" or "sell".
#    - type: The order type ("exchange limit" or "exchange stop limit").
#    - options: Optional array of order execution options.
#    - stop_price: Optional stop price for stop-limit orders.
#    - client_order_id: Optional client-specified order ID.
#    - account: Optional account for Master API keys.
#
#  ## Examples
#
#      iex> Geminex.API.Private.new_order(%{
#             "symbol" => "btcusd",
#             "amount" => "5",
#             "price" => "3633.00",
#             "side" => "buy",
#             "type" => "exchange limit",
#             "options" => ["maker-or-cancel"]
#           })
#      {:ok, %{"order_id" => "106817811", ...}}
#
#  """
#  @spec new_order(map) :: {:ok, map} | {:error, any}
#  def new_order(order_params) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Cancels an order.
#
#  ## Parameters
#
#    - order_id: The order ID to cancel.
#    - account: Optional account for Master API keys.
#
#  ## Examples
#
#      iex> Geminex.API.Private.cancel_order("106817811")
#      {:ok, %{"order_id" => "106817811", "is_cancelled" => true, ...}}
#
#  """
#  @spec cancel_order(String.t(), String.t() | nil) :: {:ok, map} | {:error, any}
#  def cancel_order(order_id, account \\ nil) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Wraps or unwraps Gemini issued assets.
#
#  ## Parameters
#
#    - symbol: The trading pair symbol (e.g., GUSDUSD).
#    - amount: The amount to wrap or unwrap.
#    - side: "buy" or "sell".
#    - client_order_id: Optional client-specified order ID.
#    - account: Optional account for Master API keys.
#
#  ## Examples
#
#      iex> Geminex.API.Private.wrap_order(%{
#             "symbol" => "GUSDUSD",
#             "amount" => "1",
#             "side" => "buy",
#             "client_order_id" => "4ac6f45f-baf1-40f8-83c5-001e3ea73c7f"
#           })
#      {:ok, %{"orderId" => 429135395, ...}}
#
#  """
#  @spec wrap_order(map) :: {:ok, map} | {:error, any}
#  def wrap_order(order_params) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Cancels all orders opened by the current session.
#
#  ## Parameters
#
#    - account: Optional account for Master API keys.
#
#  ## Examples
#
#      iex> Geminex.API.Private.cancel_all_session_orders()
#      {:ok, %{"result" => "ok", "details" => %{"cancelledOrders" => [330429345], "cancelRejects" => []}}}
#
#  """
#  @spec cancel_all_session_orders(String.t() | nil) :: {:ok, map} | {:error, any}
#  def cancel_all_session_orders(account \\ nil) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Cancels all outstanding orders created by all sessions owned by this account.
#
#  ## Parameters
#
#    - account: Optional account for Master API keys.
#
#  ## Examples
#
#      iex> Geminex.API.Private.cancel_all_active_orders()
#      {:ok, %{"result" => "ok", "details" => %{"cancelledOrders" => [330429106, 330429079, 330429082], "cancelRejects" => []}}}
#
#  """
#  @spec cancel_all_active_orders(String.t() | nil) :: {:ok, map} | {:error, any}
#  def cancel_all_active_orders(account \\ nil) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves the notional volume.
#
#  ## Parameters
#
#    - symbol: Optional. The participating symbol for fee promotions.
#    - account: Optional. Required for Master API keys. Specifies the account on which the trades were placed.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_notional_volume()
#      {:ok, %{"notional_30d_volume" => 150.00, ...}}
#
#  """
#  @spec get_notional_volume(map) :: {:ok, map} | {:error, any}
#  def get_notional_volume(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves the trade volume.
#
#  ## Parameters
#
#    - account: Optional. Required for Master API keys. Specifies the account on which the orders were placed.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_trade_volume()
#      {:ok, [%{"symbol" => "btcusd", ...}, ...]}
#
#  """
#  @spec get_trade_volume(map) :: {:ok, list} | {:error, any}
#  def get_trade_volume(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves the FX rate for a given symbol and timestamp.
#
#  ## Parameters
#
#    - symbol: The currency to check the USD FX rate against.
#    - timestamp: The timestamp to pull the FX rate for.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_fx_rate("gbpusd", 1594651859000)
#      {:ok, %{"fxPair" => "GBPUSD", "rate" => "0.69", ...}}
#
#  """
#  @spec get_fx_rate(String.t(), non_neg_integer) :: {:ok, map} | {:error, any}
#  def get_fx_rate(symbol, timestamp) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves open positions.
#
#  ## Parameters
#
#    - account: Optional. Required for Master API keys. Specifies the account on which the orders were placed.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_open_positions()
#      {:ok, [%{"symbol" => "btcgusdperp", ...}, ...]}
#
#  """
#  @spec get_open_positions(map) :: {:ok, list} | {:error, any}
#  def get_open_positions(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves account margin details.
#
#  ## Parameters
#
#    - symbol: Trading pair symbol.
#    - account: Optional. Required for Master API keys. Specifies the account on which the orders were placed.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_account_margin("BTC-GUSD-PERP")
#      {:ok, %{"margin_assets_value" => "9800", ...}}
#
#  """
#  @spec get_account_margin(String.t(), map) :: {:ok, map} | {:error, any}
#  def get_account_margin(symbol, params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves risk stats for a given symbol.
#
#  ## Parameters
#
#    - symbol: Trading pair symbol.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_risk_stats("BTCGUSDPERP")
#      {:ok, %{"product_type" => "PerpetualSwapContract", ...}}
#
#  """
#  @spec get_risk_stats(String.t()) :: {:ok, map} | {:error, any}
#  def get_risk_stats(symbol) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves funding payments.
#
#  ## Parameters
#
#    - since: Optional. Only return funding payments after this point.
#    - to: Optional. Only returns funding payment until this point.
#    - account: Optional. Required for Master API keys. Specifies the account on which the orders were placed.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_funding_payment(%{"since" => 1683730803940, "to" => 1683734406746})
#      {:ok, [%{"eventType" => "Hourly Funding Transfer", ...}, ...]}
#
#  """
#  @spec get_funding_payment(map) :: {:ok, list} | {:error, any}
#  def get_funding_payment(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Downloads the funding payment report as a file.
#
#  ## Parameters
#
#    - fromDate: Optional. If empty, will only fetch records by numRows value.
#    - toDate: Optional. If empty, will only fetch records by numRows value.
#    - numRows: Optional. If empty, default value '8760'.
#
#  ## Examples
#
#      iex> Geminex.API.Private.download_funding_payment_report(%{"fromDate" => "2024-04-10", "toDate" => "2024-04-25"})
#      :ok
#
#  """
#  @spec download_funding_payment_report(map) :: :ok | {:error, any}
#  def download_funding_payment_report(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves the FX rate for a given symbol and timestamp.
#
#  ## Parameters
#
#    - symbol: The currency to check the USD FX rate against.
#    - timestamp: The timestamp to pull the FX rate for.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_fx_rate("gbpusd", 1594651859000)
#      {:ok, %{"fxPair" => "GBPUSD", "rate" => "0.69", ...}}
#
#  """
#  @spec get_fx_rate(String.t(), non_neg_integer) :: {:ok, map} | {:error, any}
#  def get_fx_rate(symbol, timestamp) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves risk stats for a given symbol.
#
#  ## Parameters
#
#    - symbol: Trading pair symbol.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_risk_stats("BTCGUSDPERP")
#      {:ok, %{"product_type" => "PerpetualSwapContract", ...}}
#
#  """
#  @spec get_risk_stats(String.t()) :: {:ok, map} | {:error, any}
#  def get_risk_stats(symbol) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves available balances.
#
#  ## Parameters
#
#    - account: Optional. Required for Master API keys. Specifies the account within the subaccount group.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_available_balances()
#      {:ok, [%{"currency" => "BTC", "amount" => "1154.62034001", ...}, ...]}
#
#  """
#  @spec get_available_balances(map) :: {:ok, list} | {:error, any}
#  def get_available_balances(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves notional balances.
#
#  ## Parameters
#
#    - currency: The fiat currency code, e.g. usd or gbp.
#    - account: Optional. Required for Master API keys. Specifies the account within the subaccount group.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_notional_balances("usd")
#      {:ok, [%{"currency" => "BTC", "amount" => "1154.62034001", ...}, ...]}
#
#  """
#  @spec get_notional_balances(String.t(), map) :: {:ok, list} | {:error, any}
#  def get_notional_balances(currency, params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves transfer history.
#
#  ## Parameters
#
#    - currency: Optional. Currency code, see symbols.
#    - timestamp: Optional. Only return transfers on or after this timestamp.
#    - limit_transfers: Optional. The maximum number of transfers to return.
#    - account: Optional. Only required when using a master api-key.
#    - show_completed_deposit_advances: Optional. Whether to display completed deposit advances.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_transfers(%{"currency" => "BTC"})
#      {:ok, [%{"type" => "Deposit", "currency" => "BTC", ...}, ...]}
#
#  """
#  @spec get_transfers(map) :: {:ok, list} | {:error, any}
#  def get_transfers(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves transactions history.
#
#  ## Parameters
#
#    - timestamp_nanos: Optional. Only return transfers on or after this timestamp in nanos.
#    - limit: Optional. The maximum number of transfers to return.
#    - continuation_token: Optional. For subsequent requests, use the returned continuation_token value for next page.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_transactions(%{"timestamp_nanos" => 1630382206000000000, "limit" => 50})
#      {:ok, %{"results" => [%{"account" => "primary", ...}, ...], "continuationToken" => "token"}}
#
#  """
#  @spec get_transactions(map) :: {:ok, map} | {:error, any}
#  def get_transactions(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves custody account fees.
#
#  ## Parameters
#
#    - timestamp: Optional. Only return Custody fee records on or after this timestamp.
#    - limit_transfers: Optional. The maximum number of Custody fee records to return.
#    - account: Optional. Only required when using a master api-key.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_custody_account_fees(%{"timestamp" => 1657236174056, "limit_transfers" => 10})
#      {:ok, [%{"txTime" => 1657236174056, "feeAmount" => "10", ...}, ...]}
#
#  """
#  @spec get_custody_account_fees(map) :: {:ok, list} | {:error, any}
#  def get_custody_account_fees(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves deposit addresses for a given network.
#
#  ## Parameters
#
#    - network: The network for which to retrieve addresses.
#    - timestamp: Optional. Only returns addresses created on or after this timestamp.
#    - account: Optional. Required for Master API keys. Specifies the account within the subaccount group.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_deposit_addresses("bitcoin")
#      {:ok, [%{"address" => "n2saq73aDTu42bRgEHd8gd4to1gCzHxrdj", ...}, ...]}
#
#  """
#  @spec get_deposit_addresses(String.t(), map) :: {:ok, list} | {:error, any}
#  def get_deposit_addresses(network, params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Generates a new deposit address for a given network.
#
#  ## Parameters
#
#    - network: The network for which to generate a new address.
#    - label: Optional. Label for the deposit address.
#    - legacy: Optional. Whether to generate a legacy P2SH-P2PKH litecoin address.
#    - account: Optional. Required for Master API keys. Specifies the account within the subaccount group.
#
#  ## Examples
#
#      iex> Geminex.API.Private.new_deposit_address("bitcoin", %{"label" => "optional test label"})
#      {:ok, %{"address" => "n2saq73aDTu42bRgEHd8gd4to1gCzHxrdj", ...}}
#
#  """
#  @spec new_deposit_address(String.t(), map) :: {:ok, map} | {:error, any}
#  def new_deposit_address(network, params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Withdraws crypto funds to an approved address.
#
#  ## Parameters
#
#    - currency: The currency to withdraw.
#    - address: Standard string format of cryptocurrency address.
#    - amount: Quoted decimal amount to withdraw.
#    - memo: Optional. For addresses that require a memo.
#    - clientTransferId: Optional. A unique identifier for the withdrawal, in uuid4 format.
#
#  ## Examples
#
#      iex> Geminex.API.Private.withdraw_crypto("btc", %{"address" => "mi98Z9brJ3TgaKsmvXatuRahbFRUFKRUdR", "amount" => "1"})
#      {:ok, %{"address" => "mi98Z9brJ3TgaKsmvXatuRahbFRUFKRUdR", "amount" => "1", ...}}
#
#  """
#  @spec withdraw_crypto(String.t(), map) :: {:ok, map} | {:error, any}
#  def withdraw_crypto(currency, params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Estimates gas fees for a withdrawal.
#
#  ## Parameters
#
#    - currencyCodeLowerCase: The currency code of a supported crypto-currency, e.g. eth.
#    - address: Standard string format of cryptocurrency address.
#    - amount: Quoted decimal amount to withdraw.
#    - account: The name of the account within the subaccount group.
#
#  ## Examples
#
#      iex> Geminex.API.Private.gas_fee_estimate("eth", %{"address" => "0x31c2105b8dea834167f32f7ea7d877812e059230", "amount" => "0.01"})
#      {:ok, %{"currency" => "ETH", "fee" => "{currency: 'ETH', value: '0'}", ...}}
#
#  """
#  @spec gas_fee_estimate(String.t(), map) :: {:ok, map} | {:error, any}
#  def gas_fee_estimate(currencyCodeLowerCase, params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Executes an internal transfer between any two accounts within the Master Group.
#
#  ## Parameters
#
#    - currency: The currency to transfer.
#    - sourceAccount: Nickname of the account you are transferring from.
#    - targetAccount: Nickname of the account you are transferring to.
#    - amount: Quoted decimal amount to withdraw.
#    - clientTransferId: Optional. A unique identifier for the internal transfer, in uuid4 format.
#
#  ## Examples
#
#      iex> Geminex.API.Private.internal_transfer("btc", %{"sourceAccount" => "my-account", "targetAccount" => "my-other-account", "amount" => "1"})
#      {:ok, %{"fromAccount" => "my-account", "toAccount" => "my-other-account", ...}}
#
#  """
#  @spec internal_transfer(String.t(), map) :: {:ok, map} | {:error, any}
#  def internal_transfer(currency, params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Adds a new bank account.
#
#  ## Parameters
#
#    - accountnumber: Account number of bank account to be added.
#    - routing: Routing number of bank account to be added.
#    - type: Type of bank account to be added. Accepts checking or savings.
#    - name: The name of the bank account as shown on your account statements.
#    - account: Optional. Required for Master API keys. Specifies the account within the subaccount group.
#
#  ## Examples
#
#      iex> Geminex.API.Private.add_bank(%{"accountnumber" => "123456789", "routing" => "987654321", "type" => "checking", "name" => "My Checking Account"})
#      {:ok, %{"referenceId" => "BankAccountRefId(18428)"}}
#
#  """
#  @spec add_bank(map) :: {:ok, map} | {:error, any}
#  def add_bank(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Adds a new CAD bank account.
#
#  ## Parameters
#
#    - swiftcode: The account SWIFT code.
#    - accountnumber: Account number of bank account to be added.
#    - institutionnumber: Optional. The institution number of the account.
#    - branchnumber: Optional. The branch number.
#    - type: Type of bank account to be added. Accepts checking or savings.
#    - name: The name of the bank account as shown on your account statements.
#    - account: Optional. Required for Master API keys. Specifies the account within the subaccount group.
#
#  ## Examples
#
#      iex> Geminex.API.Private.add_bank_cad(%{"swiftcode" => "ABC123", "accountnumber" => "123456789", "type" => "checking", "name" => "My CAD Checking Account"})
#      {:ok, %{"result" => "OK"}}
#
#  """
#  @spec add_bank_cad(map) :: {:ok, map} | {:error, any}
#  def add_bank_cad(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves payment methods.
#
#  ## Parameters
#
#    - account: Optional. Required for Master API keys. Specifies the account within the subaccount group.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_payment_methods(%{"account" => "primary"})
#      {:ok, %{"balances" => [...], "banks" => [...]}}
#
#  """
#  @spec get_payment_methods(map) :: {:ok, map} | {:error, any}
#  def get_payment_methods(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves Earn balances.
#
#  ## Parameters
#
#    - account: Optional. Required for Master API keys. Specifies the account within the subaccount group.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_earn_balances()
#      {:ok, [%{"type" => "Earn", "currency" => "BTC", ...}, ...]}
#
#  """
#  @spec get_earn_balances(map) :: {:ok, list} | {:error, any}
#  def get_earn_balances(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves Earn rates.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_earn_rates()
#      {:ok, %{"providerId" => %{"BTC" => %{"rate" => 100, ...}, ...}}}
#
#  """
#  @spec get_earn_rates() :: {:ok, map} | {:error, any}
#  def get_earn_rates() do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves Earn interest.
#
#  ## Parameters
#
#    - since: In iso datetime with timezone format.
#    - until: Optional. In iso datetime with timezone format, default to current time as of server time.
#    - providerId: Optional. Borrower Id, in uuid4 format.
#    - currency: Optional. Currency code, see symbols.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_earn_interest(%{"since" => "2022-01-01T00:00:00Z"})
#      {:ok, %{"providerId" => %{"BTC" => %{"accrualTotal" => 0.0546, ...}, ...}}}
#
#  """
#  @spec get_earn_interest(map) :: {:ok, map} | {:error, any}
#  def get_earn_interest(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves Earn history.
#
#  ## Parameters
#
#    - since: Optional. In iso datetime with timezone format.
#    - until: Optional. In iso datetime with timezone format, default to current time as of server time.
#    - limit: Optional. The maximum number of transactions to return.
#    - providerId: Optional. Borrower Id, in uuid4 format.
#    - currency: Optional. Currency code, see symbols.
#    - interestOnly: Optional. Toggles whether to only return daily interest transactions. Defaults to false.
#    - sortAsc: Optional. Toggles whether to sort the transactions in ascending order by datetime. Defaults to false.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_earn_history(%{"since" => "2022-01-01T00:00:00Z", "limit" => 500})
#      {:ok, [%{"providerId" => "provider-id", "transactions" => [...]}, ...]}
#
#  """
#  @spec get_earn_history(map) :: {:ok, list} | {:error, any}
#  def get_earn_history(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves staking balances.
#
#  ## Parameters
#
#    - account: Optional. Required for Master API keys. Specifies the account within the subaccount group.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_staking_balances()
#      {:ok, [%{"type" => "Staking", "currency" => "MATIC", ...}, ...]}
#
#  """
#  @spec get_staking_balances(map) :: {:ok, list} | {:error, any}
#  def get_staking_balances(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves staking rates.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_staking_rates()
#      {:ok, %{"providerId" => %{"MATIC" => %{"rate" => 429.386, ...}, ...}}}
#
#  """
#  @spec get_staking_rates() :: {:ok, map} | {:error, any}
#  def get_staking_rates() do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves staking rewards.
#
#  ## Parameters
#
#    - since: In iso datetime with timezone format.
#    - until: Optional. In iso datetime with timezone format, default to current time as of server time.
#    - providerId: Optional. Borrower Id, in uuid4 format.
#    - currency: Optional. Currency code, see symbols.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_staking_rewards(%{"since" => "2022-01-01T00:00:00Z"})
#      {:ok, %{"providerId" => %{"MATIC" => %{"accrualTotal" => 0.103994, ...}, ...}}}
#
#  """
#  @spec get_staking_rewards(map) :: {:ok, map} | {:error, any}
#  def get_staking_rewards(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves staking history.
#
#  ## Parameters
#
#    - since: Optional. In iso datetime with timezone format.
#    - until: Optional. In iso datetime with timezone format, default to current time as of server time.
#    - limit: Optional. The maximum number of transactions to return.
#    - providerId: Optional. Borrower Id, in uuid4 format.
#    - currency: Optional. Currency code, see symbols.
#    - interestOnly: Optional. Toggles whether to only return daily interest transactions. Defaults to false.
#    - sortAsc: Optional. Toggles whether to sort the transactions in ascending order by datetime. Defaults to false.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_staking_history(%{"since" => "2022-01-01T00:00:00Z", "limit" => 500})
#      {:ok, [%{"providerId" => "provider-id", "transactions" => [...]}, ...]}
#
#  """
#  @spec get_staking_history(map) :: {:ok, list} | {:error, any}
#  def get_staking_history(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Initiates staking deposits.
#
#  ## Parameters
#
#    - providerId: Provider Id, in uuid4 format.
#    - currency: Currency code, see symbols.
#    - amount: The amount of currency to deposit.
#    - account: Optional. Required for Master API keys. Specifies the account within the subaccount group.
#
#  ## Examples
#
#      iex> Geminex.API.Private.stake(%{"providerId" => "provider-id", "currency" => "MATIC", "amount" => 30})
#      {:ok, %{"transactionId" => "65QN4XM5", ...}}
#
#  """
#  @spec stake(map) :: {:ok, map} | {:error, any}
#  def stake(params) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Initiates staking withdrawals.
#
#  ## Parameters
#
#    - providerId: Provider Id, in uuid4 format.
#    - currency: Currency code, see symbols.
#    - amount: The amount of currency to withdraw.
#    - account: Optional. Required for Master API keys. Specifies the account within the subaccount group.
#
#  ## Examples
#
#      iex> Geminex.API.Private.unstake(%{"providerId" => "provider-id", "currency" => "MATIC", "amount" => 20})
#      {:ok, %{"transactionId" => "MPZ7LDD8", ...}}
#
#  """
#  @spec unstake(map) :: {:ok, map} | {:error, any}
#  def unstake(params) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Creates an approved address request.
#
#  ## Parameters
#
#    - network: The network for which to create an approved address request.
#    - address: A string of the address to be added to the approved address list.
#    - label: The label of the approved address.
#    - account: Optional. Required for Master API keys. Specifies the account within the subaccount group.
#    - memo: Optional. It would be present if applicable.
#
#  ## Examples
#
#      iex> Geminex.API.Private.create_approved_address_request("ethereum", %{"address" => "0x0000000000000000000000000000000000000000", "label" => "api_added_ETH_address"})
#      {:ok, %{"message" => "Approved address addition is now waiting a 7-day approval hold before activation."}}
#
#  """
#  @spec create_approved_address_request(String.t(), map) :: {:ok, map} | {:error, any}
#  def create_approved_address_request(network, params) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves approved addresses.
#
#  ## Parameters
#
#    - network: The network for which to retrieve approved addresses.
#    - account: Optional. Required for Master API keys. Specifies the account within the subaccount group.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_approved_addresses("ethereum")
#      {:ok, %{"approvedAddresses" => [...]}}
#
#  """
#  @spec get_approved_addresses(String.t(), map) :: {:ok, map} | {:error, any}
#  def get_approved_addresses(network, params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Removes an address from the approved address list.
#
#  ## Parameters
#
#    - network: The network for which to remove the approved address.
#    - address: A string of the address to be removed from the approved address list.
#    - account: Optional. Required for Master API keys. Specifies the account within the subaccount group.
#
#  ## Examples
#
#      iex> Geminex.API.Private.remove_approved_address("ethereum", %{"address" => "0x0000000000000000000000000000000000000000"})
#      {:ok, %{"message" => "0x0000000000000000000000000000000000000000 removed from group pending-time approved addresses."}}
#
#  """
#  @spec remove_approved_address(String.t(), map) :: {:ok, map} | {:error, any}
#  def remove_approved_address(network, params) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves account details.
#
#  ## Parameters
#
#    - account: Optional. Required for Master API keys. Specifies the account within the subaccount group.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_account_details(%{"account" => "primary"})
#      {:ok, %{"account" => %{"accountName" => "Primary", ...}, "users" => [...]}}
#
#  """
#  @spec get_account_details(map) :: {:ok, map} | {:error, any}
#  def get_account_details(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Creates a new account.
#
#  ## Parameters
#
#    - name: A unique name for the new account.
#    - type: Optional. Either "exchange" or "custody". Defaults to "exchange".
#
#  ## Examples
#
#      iex> Geminex.API.Private.create_account(%{"name" => "My Secondary Account"})
#      {:ok, %{"account" => "my-secondary-account", "type" => "exchange"}}
#
#  """
#  @spec create_account(map) :: {:ok, map} | {:error, any}
#  def create_account(params) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Renames an account.
#
#  ## Parameters
#
#    - account: The shortname of the account within the subaccount group.
#    - newName: Optional. A unique name for the new account.
#    - newAccount: Optional. A unique shortname for the new account.
#
#  ## Examples
#
#      iex> Geminex.API.Private.rename_account(%{"account" => "my-exchange-account", "newName" => "My Exchange Account New Name"})
#      {:ok, %{"name" => "My Exchange Account New Name", "account" => "my-exchange-account-new-name"}}
#
#  """
#  @spec rename_account(map) :: {:ok, map} | {:error, any}
#  def rename_account(params) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Retrieves accounts in the master group.
#
#  ## Parameters
#
#    - limit_accounts: Optional. The maximum number of accounts to return.
#    - timestamp: Optional. Only return accounts created on or before the supplied timestamp.
#
#  ## Examples
#
#      iex> Geminex.API.Private.get_accounts_in_master_group(%{"limit_accounts" => 100})
#      {:ok, [%{"name" => "Primary", ...}, ...]}
#
#  """
#  @spec get_accounts_in_master_group(map) :: {:ok, list} | {:error, any}
#  def get_accounts_in_master_group(params \\ %{}) do
#    # Implementation will go here
#  end
#
#  @doc """
#  Sends a heartbeat request to prevent session timeout.
#
#  ## Examples
#
#      iex> Geminex.API.Private.heartbeat()
#      {:ok, %{"result" => "ok"}}
#
#  """
#  @spec heartbeat() :: {:ok, map} | {:error, any}
#  def heartbeat() do
#    # Implementation will go here
#  end
#end