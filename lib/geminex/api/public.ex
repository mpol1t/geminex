defmodule Geminex.API.Public do
  @moduledoc """
  Public API endpoints for Gemini.
  """

  alias Geminex.HttpClient

  @symbols_url                "/v1/symbols"
  @symbol_details_url         "/v1/symbols/details/:symbol"
  @network_url                "/v1/network/:token"
  @ticker_url                 "/v1/pubticker/:symbol"
  @ticker_v2_url              "/v2/ticker/:symbol"
  @candles_url                "/v2/candles/:symbol/:time_frame"
  @derivatives_candles_url    "/v2/derivatives/candles/:symbol/:time_frame"
  @fee_promos_url             "/v1/feepromos"
  @current_order_book_url     "/v1/book/:symbol"
  @trade_history_url          "/v1/trades/:symbol"
  @price_feed_url             "/v1/pricefeed"
  @funding_amount_url         "/v1/fundingamount/:symbol"
  @funding_amount_report_url  "/v1/fundingamountreport/records.xlsx"

  @doc """
  Retrieves all available symbols for trading.

  ## Examples

      iex> Geminex.API.Public.symbols()
      {:ok, ["btcusd", "ethbtc", "ethusd", ...]}

  """
  @spec symbols(boolean) :: {:ok, list(String.t())} | {:error, any}
  def symbols(use_prod \\ true) do
    HttpClient.use_production_url(use_prod)
    <> @symbols_url
    |> HttpClient.get_and_decode()
  end

  @doc """
  Retrieves extra detail on a supported symbol.

  ## Parameters

    - symbol: The trading pair symbol (e.g., BTCUSD).

  ## Examples

      iex> Geminex.API.Public.symbol_details("btcusd")
      {:ok, %{
        "symbol" => "BTCUSD",
        "base_currency" => "BTC",
        "quote_currency" => "USD",
        ...
      }}

  """
  @spec symbol_details(String.t(), boolean) :: {:ok, map} | {:error, any}
  def symbol_details(symbol, use_prod \\ true) do
    HttpClient.get_with_params(@symbol_details_url, %{"symbol" => symbol}, use_prod)
  end

  @doc """
  Retrieves the associated network for a requested token.

  ## Parameters

    - token: The token identifier (e.g., BTC, ETH, SOL).

  ## Examples

      iex> Geminex.API.Public.network("rbn")
      {:ok, %{"token" => "RBN", "network" => ["ethereum"]}}

  """
  @spec network(String.t(), boolean) :: {:ok, map} | {:error, any}
  def network(token, use_prod \\ true) do
    HttpClient.get_with_params(@network_url, %{"token" => token}, use_prod)
  end

  @doc """
  Retrieves information about recent trading activity for the symbol.

  ## Parameters

    - symbol: The trading pair symbol (e.g., BTCUSD).

  ## Examples

      iex> Geminex.API.Public.ticker("btcusd")
      {:ok, %{"ask" => "977.59", "bid" => "977.35", "last" => "977.65", "volume" => %{"BTC" => "2210.505328803", "USD" => "2135477.463379586263", "timestamp" => 1483018200000}}}

  """
  @spec ticker(String.t(), boolean) :: {:ok, map} | {:error, any}
  def ticker(symbol, use_prod \\ true) do
    HttpClient.get_with_params(@ticker_url, %{"symbol" => symbol}, use_prod)
  end

  @doc """
  Retrieves information about recent trading activity for the provided symbol (V2).

  ## Parameters

    - symbol: The trading pair symbol (e.g., BTCUSD).

  ## Examples

      iex> Geminex.API.Public.ticker_v2("btcusd")
      {:ok, %{
        "symbol" => "BTCUSD",
        "open" => "9121.76",
        "high" => "9440.66",
        "low" => "9106.51",
        "close" => "9347.66",
        "changes" => ["9365.1", "9386.16", ...],
        "bid" => "9345.70",
        "ask" => "9347.67"
      }}

  """
  @spec ticker_v2(String.t(), boolean) :: {:ok, map} | {:error, any}
  def ticker_v2(symbol, use_prod \\ true) do
    HttpClient.get_with_params(@ticker_v2_url, %{"symbol" => symbol}, use_prod)
  end

  @doc """
  Retrieves time-intervaled data for the provided symbol.

  ## Parameters

    - symbol: The trading pair symbol (e.g., BTCUSD).
    - time_frame: The time range for each candle (e.g., 1m, 5m, 15m, 30m, 1hr, 6hr, 1day).

  ## Examples

      iex> Geminex.API.Public.candles("btcusd", "15m")
      {:ok, [[1559755800000, 7781.6, 7820.23, 7776.56, 7819.39, 34.7624802159], ...]}

  """
  @spec candles(String.t(), String.t(), boolean) :: {:ok, list(list(any))} | {:error, any}
  def candles(symbol, time_frame, use_prod \\ true) do
    HttpClient.get_with_params(@candles_url, %{"symbol" => symbol, "time_frame" => time_frame}, use_prod)
  end

  @doc """
  Retrieves time-intervaled data for the provided perpetual swap symbol.

  ## Parameters

    - symbol: The trading pair symbol for perpetual swaps (e.g., BTCGUSDPERP).
    - time_frame: The time range for each candle (e.g., 1m).

  ## Examples

      iex> Geminex.API.Public.derivatives_candles("BTCGUSDPERP", "1m")
      {:ok, [[1714126740000, 68038, 68038, 68038, 68038, 0], ...]}

  """
  @spec derivatives_candles(String.t(), String.t(), boolean) :: {:ok, list(list(any))} | {:error, any}
  def derivatives_candles(symbol, time_frame, use_prod \\ true) do
    HttpClient.get_with_params(@derivatives_candles_url, %{"symbol" => symbol, "time_frame" => time_frame}, use_prod)
  end

  @doc """
  Retrieves symbols that currently have fee promos.

  ## Examples

      iex> Geminex.API.Public.fee_promos()
      {:ok, %{"symbols" => ["GMTUSD", "GUSDGBP", ...]}}

  """
  @spec fee_promos(boolean) :: {:ok, map} | {:error, any}
  def fee_promos(use_prod \\ true) do
    HttpClient.get_and_decode(HttpClient.use_production_url(use_prod) <> @fee_promos_url)
  end

  @doc """
  Retrieves the current order book for the specified symbol.

  ## Parameters

    - symbol: The trading pair symbol (e.g., BTCUSD).
    - limit_bids: Optional. Limit the number of bid price levels returned.
    - limit_asks: Optional. Limit the number of ask price levels returned.
    - include_breaks: Optional. Whether to display broken trades. False by default. Can be '1' or 'true' to activate

  ## Examples

      iex> Geminex.API.Public.current_order_book("btcusd", 10, 10)
      {:ok, %{
        "bids" => [%{"price" => "3607.85", "amount" => "6.643373", "timestamp" => "1547147541"}],
        "asks" => [%{"price" => "3607.86", "amount" => "14.68205084", "timestamp" => "1547147541"}]
      }}

  """
  @spec current_order_book(String.t(), integer, integer, boolean) :: {:ok, map} | {:error, any}
  def current_order_book(symbol, limit_bids \\ 50, limit_asks \\ 50, use_prod \\ true) do
    @current_order_book_url
    |> HttpClient.encode_params([limit_bids: limit_bids, limit_asks: limit_asks])
    |> HttpClient.get_with_params(%{"symbol" => symbol}, use_prod)
  end

  @doc """
  Retrieves the trade history for the specified symbol.

  ## Parameters

    - symbol: The trading pair symbol (e.g., BTCUSD).
    - opts: Optional parameters including timestamp, since_tid, limit_trades, and include_breaks.

  ## Examples

      iex> Geminex.API.Public.trade_history("btcusd", %{timestamp: nil, since_tid: nil, limit_trades: 50, include_breaks: false})
      {:ok, [
        %{
          "timestamp" => 1547146811,
          "timestampms" => 1547146811357,
          "tid" => 5335307668,
          "price" => "3610.85",
          "amount" => "0.27413495",
          "exchange" => "gemini",
          "type" => "buy"
        },
        ...
      ]}

  """
  @spec trade_history(String.t(), map, boolean) :: {:ok, list(map)} | {:error, any}
  def trade_history(symbol, opts \\ %{}, use_prod \\ true) do
    @trade_history_url
    |> HttpClient.encode_params(opts)
    |> HttpClient.get_with_params(%{"symbol" => symbol}, use_prod)
  end

  @doc """
  Retrieves the price feed for all trading pairs.

  ## Examples

      iex> Geminex.API.Public.price_feed()
      {:ok, [
        %{"pair" => "BTCUSD", "price" => "9500.00", "percentChange24h" => "5.23"},
        ...
      ]}

  """
  @spec price_feed(boolean) :: {:ok, list(map)} | {:error, any}
  def price_feed(use_prod \\ true) do
    HttpClient.use_production_url(use_prod)
    <> @price_feed_url
    |> HttpClient.get_and_decode
  end

  @doc """
  Retrieves the funding amount details for the specified symbol.

  ## Parameters

    - symbol: The trading pair symbol (e.g., BTCGUSDPERP).

  ## Examples

      iex> Geminex.API.Public.funding_amount("btcgusdperp")
      {:ok, %{
        "symbol" => "btcgusdperp",
        "fundingDateTime" => "2023-06-12T03:00:00.000Z",
        "fundingTimestampMilliSecs" => 1686538800000,
        "nextFundingTimestamp" => 1686542400000,
        "fundingAmount" => 0.51692,
        "estimatedFundingAmount" => 0.27694
      }}

  """
  @spec funding_amount(String.t(), boolean) :: {:ok, map} | {:error, any}
  def funding_amount(symbol, use_prod \\ true) do
    HttpClient.get_with_params(@funding_amount_url, %{"symbol" => symbol}, use_prod)
  end

  @doc """
  Retrieves the funding amount report file.

  ## Parameters

    - opts: Optional parameters including symbol, fromDate, toDate, and numRows.

  ## Examples

      iex> Geminex.API.Public.funding_amount_report(%{symbol: "BTCGUSDPERP", fromDate: "2024-04-10", toDate: "2024-04-25", numRows: 1000})
      {:ok, binary}

  """
  @spec funding_amount_report(map, boolean) :: {:ok, binary} | {:error, any}
  def funding_amount_report(opts \\ %{}, use_prod \\ true) do
    HttpClient.use_production_url(use_prod)
    <> @funding_amount_report_url
    |> HttpClient.encode_params(opts)
    |> HttpClient.get
  end
end
