defmodule Geminex.Utils.Generators do
  @moduledoc """
  Utility module providing data generators for testing Geminex API.
  """

  @min_string_length 1
  @max_string_length 10

  @min_list_length 1
  @max_list_length 100

  @max_float_value 100_000.0
  @max_timestamp 1_000_000_000_000

  @doc """
  Generates a random ASCII string with a length between `@min_string_length` and `@max_string_length`.
  """
  @spec string_generator() :: StreamData.t()
  def string_generator do
    StreamData.string(:ascii, min_length: @min_string_length, max_length: @max_string_length)
  end

  @doc """
  Generates a random float string with values between 0 and `@max_float_value`.
  """
  @spec float_string_generator() :: StreamData.t()
  def float_string_generator do
    StreamData.float(min: 0.0, max: @max_float_value) |> StreamData.map(&Float.to_string/1)
  end

  @doc """
  Generates a random timestamp integer between 0 and `@max_timestamp`.
  """
  @spec timestamp_generator() :: StreamData.t()
  def timestamp_generator do
    StreamData.integer(0..@max_timestamp)
  end

  @doc """
  Generates a list of random ASCII strings with lengths between `@min_list_length` and `@max_list_length`.
  """
  @spec list_of_strings(integer, integer) :: StreamData.t()
  def list_of_strings(min_length \\ @min_list_length, max_length \\ @max_list_length) do
    StreamData.list_of(string_generator(), min_length: min_length, max_length: max_length)
  end

  @doc """
  Generates a list of symbols.
  """
  @spec symbols() :: StreamData.t()
  def symbols do
    list_of_strings()
  end

  @doc """
  Generates details for a symbol.
  """
  @spec symbol_details() :: StreamData.t()
  def symbol_details do
    StreamData.fixed_map(%{
      "symbol" => string_generator(),
      "base_currency" => string_generator(),
      "quote_currency" => string_generator(),
      "tick_size" => StreamData.float(min: 1.0e-8, max: 1.0),
      "quote_increment" => StreamData.float(min: 0.01, max: 1.0),
      "min_order_size" => string_generator(),
      "status" => string_generator(),
      "wrap_enabled" => StreamData.boolean(),
      "product_type" => string_generator(),
      "contract_type" => string_generator(),
      "contract_price_currency" => string_generator()
    })
  end

  @doc """
  Generates network details for a token.
  """
  @spec network_detail() :: StreamData.t()
  def network_detail do
    StreamData.fixed_map(%{
      "token" => string_generator(),
      "network" => list_of_strings(1, 3)
    })
  end

  @doc """
  Generates volume details for a symbol.
  """
  @spec volume_detail() :: StreamData.t()
  def volume_detail do
    StreamData.fixed_map(%{
      "BTC" => string_generator(),
      "USD" => string_generator(),
      "timestamp" => timestamp_generator()
    })
  end

  @doc """
  Generates ticker details for a symbol.
  """
  @spec ticker_detail() :: StreamData.t()
  def ticker_detail do
    StreamData.fixed_map(%{
      "ask" => string_generator(),
      "bid" => string_generator(),
      "last" => string_generator(),
      "volume" => volume_detail()
    })
  end

  @doc """
  Generates ticker V2 details for a symbol.
  """
  @spec ticker_v2_detail() :: StreamData.t()
  def ticker_v2_detail do
    StreamData.fixed_map(%{
      "symbol" => string_generator(),
      "open" => StreamData.float(min: 1.0, max: 10_000.0),
      "high" => StreamData.float(min: 1.0, max: 10_000.0),
      "low" => StreamData.float(min: 1.0, max: 10_000.0),
      "close" => StreamData.float(min: 1.0, max: 10_000.0),
      "changes" =>
        StreamData.list_of(StreamData.float(min: 1.0, max: 10_000.0),
          min_length: 1,
          max_length: 24
        ),
      "bid" => StreamData.float(min: 1.0, max: 10_000.0),
      "ask" => StreamData.float(min: 1.0, max: 10_000.0)
    })
  end

  @doc """
  Generates candles detail data for a symbol.
  """
  @spec candles_detail() :: StreamData.t()
  def candles_detail do
    StreamData.list_of(
      StreamData.fixed_list([
        timestamp_generator(),
        StreamData.float(min: 0.0, max: @max_float_value),
        StreamData.float(min: 0.0, max: @max_float_value),
        StreamData.float(min: 0.0, max: @max_float_value),
        StreamData.float(min: 0.0, max: @max_float_value),
        StreamData.float(min: 0.0, max: @max_float_value)
      ]),
      min_length: @min_list_length,
      max_length: @max_list_length
    )
  end

  @doc """
  Generates details for fee promos.
  """
  @spec fee_promos_detail() :: StreamData.t()
  def fee_promos_detail do
    StreamData.fixed_map(%{
      "symbols" => list_of_strings(1, 20)
    })
  end

  @doc """
  Generates an entry for the order book.
  """
  @spec order_book_entry() :: StreamData.t()
  def order_book_entry do
    StreamData.fixed_map(%{
      "price" => float_string_generator(),
      "amount" => float_string_generator(),
      "timestamp" => StreamData.string(:ascii, length: 10)
    })
  end

  @doc """
  Generates the order book data.
  """
  @spec order_book() :: StreamData.t()
  def order_book do
    StreamData.fixed_map(%{
      "bids" => StreamData.list_of(order_book_entry(), min_length: 1, max_length: 50),
      "asks" => StreamData.list_of(order_book_entry(), min_length: 1, max_length: 50)
    })
  end

  @doc """
  Generates trade history details.
  """
  @spec trade_history_detail() :: StreamData.t()
  def trade_history_detail do
    StreamData.list_of(
      StreamData.fixed_map(%{
        "timestamp" => timestamp_generator(),
        "timestampms" => timestamp_generator(),
        "tid" => StreamData.integer(),
        "price" => string_generator(),
        "amount" => string_generator(),
        "exchange" => StreamData.constant("gemini"),
        "type" => StreamData.member_of(["buy", "sell"]),
        "broken" => StreamData.boolean()
      }),
      min_length: @min_list_length,
      max_length: @max_list_length
    )
  end

  @doc """
  Generates price feed details.
  """
  @spec price_feed_detail() :: StreamData.t()
  def price_feed_detail do
    StreamData.list_of(
      StreamData.fixed_map(%{
        "pair" => string_generator(),
        "price" => string_generator(),
        "percentChange24h" => string_generator()
      }),
      min_length: @min_list_length,
      max_length: @max_list_length
    )
  end

  @doc """
  Generates funding amount details.
  """
  @spec funding_amount_detail() :: StreamData.t()
  def funding_amount_detail do
    StreamData.fixed_map(%{
      "symbol" => string_generator(),
      "fundingDateTime" => string_generator(),
      "fundingTimestampMilliSecs" => timestamp_generator(),
      "nextFundingTimestamp" => timestamp_generator(),
      "fundingAmount" => StreamData.float(),
      "estimatedFundingAmount" => StreamData.float()
    })
  end
end
