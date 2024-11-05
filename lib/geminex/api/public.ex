defmodule Geminex.API.Public do
  @moduledoc """
  Public API endpoints for Gemini.
  """

  use Tesla

  alias Geminex.Utils

  @timeout 5_000

  plug(Geminex.Middleware.DynamicBaseUrl)
  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.Query)
  plug(Tesla.Middleware.Timeout, timeout: @timeout)
  plug(Tesla.Middleware.Logger)

  # Public API endpoints
  @symbols_url                   "/v1/symbols"
  @symbol_details_url            "/v1/symbols/details/:symbol"
  @network_url                   "/v1/network/:token"
  @ticker_url                    "/v1/pubticker/:symbol"
  @ticker_v2_url                 "/v2/ticker/:symbol"
  @candles_url                   "/v2/candles/:symbol/:time_frame"
  @derivatives_candles_url       "/v2/derivatives/candles/:symbol/:time_frame"
  @fee_promos_url                "/v1/feepromos"
  @current_order_book_url        "/v1/book/:symbol"
  @trade_history_url             "/v1/trades/:symbol"
  @price_feed_url                "/v1/pricefeed"
  @funding_amount_url            "/v1/fundingamount/:symbol"
  @funding_amount_report_url     "/v1/fundingamountreport/records.xlsx"

  @doc """
  Retrieves all available symbols for trading.
  """
  @spec symbols() :: {:ok, list(String.t())} | {:error, any}
  def symbols do
    @symbols_url |> get() |> Utils.handle_response()
  end

  @doc """
  Retrieves extra detail on a supported symbol.

  ## Parameters

    - **symbol**: Trading pair symbol (e.g., "btcusd").
  """
  @spec symbol_details(symbol :: String.t()) :: {:ok, map} | {:error, any}
  def symbol_details(symbol) do
    @symbol_details_url |> String.replace(":symbol", symbol) |> get() |> Utils.handle_response()
  end

  @doc """
  Retrieves the associated network for a requested token.

  ## Parameters

    - **token**: Token identifier (e.g., "eth").
  """
  @spec network(token :: String.t()) :: {:ok, map} | {:error, any}
  def network(token) do
    @network_url |> String.replace(":token", token) |> get() |> Utils.handle_response()
  end

  @doc """
  Retrieves information about recent trading activity for the symbol.

  ## Parameters

    - **symbol**: Trading pair symbol (e.g., "btcusd").
  """
  @spec ticker(symbol :: String.t()) :: {:ok, map} | {:error, any}
  def ticker(symbol) do
    @ticker_url |> String.replace(":symbol", symbol) |> get() |> Utils.handle_response()
  end

  @doc """
  Retrieves information about recent trading activity for the provided symbol (V2).

  ## Parameters

    - **symbol**: Trading pair symbol (e.g., "btcusd").
  """
  @spec ticker_v2(symbol :: String.t()) :: {:ok, map} | {:error, any}
  def ticker_v2(symbol) do
    @ticker_v2_url |> String.replace(":symbol", symbol) |> get() |> Utils.handle_response()
  end

  @doc """
  Retrieves time-intervaled data for the provided symbol.

  ## Parameters

    - **symbol**: Trading pair symbol (e.g., "btcusd").
    - **time_frame**: Time range for each candle (e.g., "1m", "5m").
  """
  @spec candles(symbol :: String.t(), time_frame :: String.t()) :: {:ok, list(list(any))} | {:error, any}
  def candles(symbol, time_frame) do
    @candles_url
      |> String.replace(":symbol",      symbol)
      |> String.replace(":time_frame",  time_frame)
      |> get()
      |> Utils.handle_response()
  end

  @doc """
  Retrieves time-intervaled data for the provided perpetual swap symbol.

  ## Parameters

    - **symbol**: Perpetual swap symbol (e.g., "BTCGUSDPERP").
    - **time_frame**: Time range for each candle (e.g., "1m").
  """
  @spec derivatives_candles(symbol :: String.t(), time_frame :: String.t()) :: {:ok, list(list(any))} | {:error, any}
  def derivatives_candles(symbol, time_frame) do
    @derivatives_candles_url
      |> String.replace(":symbol",      symbol)
      |> String.replace(":time_frame",  time_frame)
      |> get()
      |> Utils.handle_response()
  end

  @doc """
  Retrieves symbols that currently have fee promos.
  """
  @spec fee_promos() :: {:ok, map} | {:error, any}
  def fee_promos do
    @fee_promos_url |> get() |> Utils.handle_response()
  end

  @doc """
  Retrieves the current order book for the specified symbol.

  ## Parameters

    - **symbol**: Trading pair symbol (e.g., "btcusd").
    - **query** (optional): List of query parameters, e.g., limit_bids, limit_asks.
  """
  @spec current_order_book(symbol :: String.t(), query :: list()) :: {:ok, map} | {:error, any}
  def current_order_book(symbol, limit_bids \\ nil, limit_asks \\ nil) do
    query = %{}
      |> Utils.maybe_put_keyword("limit_bids", limit_bids)
      |> Utils.maybe_put_keyword("limit_asks", limit_asks)

    @current_order_book_url
      |> String.replace(":symbol", symbol)
      |> get(query: query)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves the trade history for the specified symbol.

  ## Parameters

    - **symbol**: Trading pair symbol (e.g., "btcusd").
    - **opts** (optional): List of options such as **timestamp**, **limit_trades**, etc.
  """
  @spec trade_history(
          symbol          :: String.t(),
          timestamp       :: non_neg_integer()  | nil,
          since_tid       :: non_neg_integer()  | nil,
          limit_trades    :: non_neg_integer()  | nil,
          include_breaks  :: boolean()          | nil
        ) :: {:ok, list(map)} | {:error, any}
  def trade_history(symbol, timestamp \\ nil, since_tid \\ nil, limit_trades \\ nil, include_breaks \\ nil) do
    query = %{}
      |> Utils.maybe_put_keyword("timestamp",       timestamp)
      |> Utils.maybe_put_keyword("since_tid",       since_tid)
      |> Utils.maybe_put_keyword("limit_trades",    limit_trades)
      |> Utils.maybe_put_keyword("include_breaks",  include_breaks)

    @trade_history_url
      |> String.replace(":symbol", symbol)
      |> get(query: query)
      |> Utils.handle_response()
  end

  @doc """
  Retrieves the price feed for all trading pairs.
  """
  @spec price_feed() :: {:ok, list(map)} | {:error, any}
  def price_feed do
    @price_feed_url |> get() |> Utils.handle_response()
  end

  @doc """
  Retrieves the funding amount details for the specified symbol.

  ## Parameters

    - **symbol**: Trading pair symbol (e.g., "btcgusdperp").
  """
  @spec funding_amount(symbol :: String.t()) :: {:ok, map} | {:error, any}
  def funding_amount(symbol) do
    @funding_amount_url |> String.replace(":symbol", symbol) |> get() |> Utils.handle_response()
  end

  @doc """
  Retrieves the funding amount report file.

  ## Parameters

    - **opts** (optional): List of options such as **fromDate**, **toDate**, **numRows**.
  """
  @spec funding_amount_report(opts :: list()) :: {:ok, binary} | {:error, any}
  def funding_amount_report(opts \\ []) do
    @funding_amount_report_url |> get(query: opts) |> Utils.handle_binary_response()
  end
end