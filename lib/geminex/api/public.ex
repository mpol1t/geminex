defmodule Geminex.API.Public do
  @moduledoc """
  Public API endpoints for Gemini.
  """

  use Tesla

  @timeout 5_000

  # Define middleware specific to public API calls
  plug(Geminex.Middleware.DynamicBaseUrl)
  plug(Tesla.Middleware.JSON)
  plug(Tesla.Middleware.Query)
  plug(Tesla.Middleware.Timeout, timeout: @timeout)
  plug(Tesla.Middleware.Logger)

  # URLs for the API endpoints
  @symbols_url "/v1/symbols"
  @symbol_details_url "/v1/symbols/details/:symbol"
  @network_url "/v1/network/:token"
  @ticker_url "/v1/pubticker/:symbol"
  @ticker_v2_url "/v2/ticker/:symbol"
  @candles_url "/v2/candles/:symbol/:time_frame"
  @derivatives_candles_url "/v2/derivatives/candles/:symbol/:time_frame"
  @fee_promos_url "/v1/feepromos"
  @current_order_book_url "/v1/book/:symbol"
  @trade_history_url "/v1/trades/:symbol"
  @price_feed_url "/v1/pricefeed"
  @funding_amount_url "/v1/fundingamount/:symbol"
  @funding_amount_report_url "/v1/fundingamountreport/records.xlsx"

  # Helper function to handle JSON responses
  defp handle_response({:ok, %Tesla.Env{status: status, body: body}}) when status in 200..299 do
    {:ok, body}
  end

  defp handle_response({:ok, %Tesla.Env{status: status, body: body}}) do
    {:error, %{status: status, body: body}}
  end

  defp handle_response({:error, reason}), do: {:error, reason}

  @doc """
  Retrieves all available symbols for trading.
  """
  @spec symbols() :: {:ok, list(String.t())} | {:error, any}
  def symbols do
    @symbols_url |> get() |> handle_response()
  end

  @doc """
  Retrieves extra detail on a supported symbol.
  """
  @spec symbol_details(String.t()) :: {:ok, map} | {:error, any}
  def symbol_details(symbol) do
    @symbol_details_url |> String.replace(":symbol", symbol) |> get() |> handle_response()
  end

  @doc """
  Retrieves the associated network for a requested token.
  """
  @spec network(String.t()) :: {:ok, map} | {:error, any}
  def network(token) do
    @network_url |> String.replace(":token", token) |> get() |> handle_response()
  end

  @doc """
  Retrieves information about recent trading activity for the symbol.
  """
  @spec ticker(String.t()) :: {:ok, map} | {:error, any}
  def ticker(symbol) do
    @ticker_url |> String.replace(":symbol", symbol) |> get() |> handle_response()
  end

  @doc """
  Retrieves information about recent trading activity for the provided symbol (V2).
  """
  @spec ticker_v2(String.t()) :: {:ok, map} | {:error, any}
  def ticker_v2(symbol) do
    @ticker_v2_url |> String.replace(":symbol", symbol) |> get() |> handle_response()
  end

  @doc """
  Retrieves time-intervaled data for the provided symbol.
  """
  @spec candles(String.t(), String.t()) :: {:ok, list(list(any))} | {:error, any}
  def candles(symbol, time_frame) do
    @candles_url
    |> String.replace(":symbol", symbol)
    |> String.replace(":time_frame", time_frame)
    |> get()
    |> handle_response()
  end

  @doc """
  Retrieves time-intervaled data for the provided perpetual swap symbol.
  """
  @spec derivatives_candles(String.t(), String.t()) :: {:ok, list(list(any))} | {:error, any}
  def derivatives_candles(symbol, time_frame) do
    @derivatives_candles_url
    |> String.replace(":symbol", symbol)
    |> String.replace(":time_frame", time_frame)
    |> get()
    |> handle_response()
  end

  @doc """
  Retrieves symbols that currently have fee promos.
  """
  @spec fee_promos() :: {:ok, map} | {:error, any}
  def fee_promos do
    @fee_promos_url |> get() |> handle_response()
  end

  @doc """
  Retrieves the current order book for the specified symbol.
  """
  @spec current_order_book(String.t(), list()) :: {:ok, map} | {:error, any}
  def current_order_book(symbol, query \\ []) do
    @current_order_book_url
    |> String.replace(":symbol", symbol)
    |> get(query: query)
    |> handle_response()
  end

  @doc """
  Retrieves the trade history for the specified symbol.
  """
  @spec trade_history(String.t(), list()) :: {:ok, list(map)} | {:error, any}
  def trade_history(symbol, opts \\ []) do
    @trade_history_url
    |> String.replace(":symbol", symbol)
    |> get(query: opts)
    |> handle_response()
  end

  @doc """
  Retrieves the price feed for all trading pairs.
  """
  @spec price_feed() :: {:ok, list(map)} | {:error, any}
  def price_feed do
    @price_feed_url |> get() |> handle_response()
  end

  @doc """
  Retrieves the funding amount details for the specified symbol.
  """
  @spec funding_amount(String.t()) :: {:ok, map} | {:error, any}
  def funding_amount(symbol) do
    @funding_amount_url |> String.replace(":symbol", symbol) |> get() |> handle_response()
  end

  @doc """
  Retrieves the funding amount report file.
  """
  @spec funding_amount_report(list()) :: {:ok, binary} | {:error, any}
  def funding_amount_report(opts \\ []) do
    @funding_amount_report_url |> get(query: opts) |> handle_binary_response()
  end

  defp handle_binary_response({:ok, %Tesla.Env{status: status, body: body}})
       when status in 200..299 do
    {:ok, body}
  end

  defp handle_binary_response({:ok, %Tesla.Env{status: status, body: body}}) do
    {:error, %{status: status, body: body}}
  end

  defp handle_binary_response({:error, reason}), do: {:error, reason}
end
