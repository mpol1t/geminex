defmodule Geminex.API.PublicTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import Mox
  import Tesla.Test

  alias Geminex.API.Public
  alias Geminex.Middleware.DynamicBaseUrl

  setup :set_mox_from_context
  setup :verify_on_exit!

  @max_runs 100

  defp assert_expected_call(expected_url, status, query \\ []) do
    assert_received_tesla_call(actual_env, actual_opts)

    assert_tesla_env(actual_env, %Tesla.Env{
      method: :get,
      status: status,
      url: DynamicBaseUrl.base_url() <> expected_url,
      query: query
    })

    assert actual_opts == []
    assert_tesla_empty_mailbox()
  end

  describe "symbols/0" do
    test "requests list of symbols" do
      expect_tesla_call(times: 1, returns: %Tesla.Env{status: 200})

      Public.symbols()
      assert_expected_call("/v1/symbols", 200)
    end
  end

  describe "symbol_details/1" do
    property "returns details for a given symbol" do
      check all(
              symbol <- string(:alphanumeric, min_length: 3, max_length: 6),
              max_runs: @max_runs
            ) do
        expect_tesla_call(times: 1, returns: %Tesla.Env{status: 200})

        Public.symbol_details(symbol)
        assert_expected_call("/v1/symbols/details/#{symbol}", 200)
      end
    end
  end

  describe "network/1" do
    property "returns network details for a given token" do
      check all(token <- string(:alphanumeric, min_length: 3, max_length: 6), max_runs: @max_runs) do
        expect_tesla_call(times: 1, returns: %Tesla.Env{status: 200})

        Public.network(token)
        assert_expected_call("/v1/network/#{token}", 200)
      end
    end
  end

  describe "ticker/1" do
    property "retrieves ticker information for a symbol" do
      check all(
              symbol <- string(:alphanumeric, min_length: 3, max_length: 6),
              max_runs: @max_runs
            ) do
        expect_tesla_call(times: 1, returns: %Tesla.Env{status: 200})

        Public.ticker(symbol)
        assert_expected_call("/v1/pubticker/#{symbol}", 200)
      end
    end
  end

  describe "ticker_v2/1" do
    property "retrieves ticker information for a symbol" do
      check all(
              symbol <- string(:alphanumeric, min_length: 3, max_length: 6),
              max_runs: @max_runs
            ) do
        expect_tesla_call(times: 1, returns: %Tesla.Env{status: 200})

        Public.ticker_v2(symbol)
        assert_expected_call("/v2/ticker/#{symbol}", 200)
      end
    end
  end

  describe "candles/2" do
    property "retrieves candle data for a symbol and time frame" do
      check all(
              symbol <- string(:alphanumeric, min_length: 3, max_length: 6),
              time_frame <-
                one_of([
                  StreamData.constant("1m"),
                  StreamData.constant("5m"),
                  StreamData.constant("15m"),
                  StreamData.constant("1h")
                ]),
              max_runs: @max_runs
            ) do
        expect_tesla_call(times: 1, returns: %Tesla.Env{status: 200})

        Public.candles(symbol, time_frame)
        assert_expected_call("/v2/candles/#{symbol}/#{time_frame}", 200)
      end
    end
  end

  describe "derivatives_candles/2" do
    property "retrieves derivatives candle data for a symbol and time frame" do
      check all(
              symbol <- string(:alphanumeric, min_length: 3, max_length: 6),
              time_frame <-
                one_of([
                  StreamData.constant("1m"),
                  StreamData.constant("5m"),
                  StreamData.constant("15m"),
                  StreamData.constant("1h")
                ]),
              max_runs: @max_runs
            ) do
        expect_tesla_call(times: 1, returns: %Tesla.Env{status: 200})

        Public.derivatives_candles(symbol, time_frame)
        assert_expected_call("/v2/derivatives/candles/#{symbol}/#{time_frame}", 200)
      end
    end
  end

  describe "fee_promos/0" do
    test "retrieves fee promo details" do
      expect_tesla_call(times: 1, returns: %Tesla.Env{status: 200})

      Public.fee_promos()
      assert_expected_call("/v1/feepromos", 200)
    end
  end

  describe "current_order_book/2" do
    property "retrieves order book data for a symbol with optional params" do
      check all(
              symbol <- string(:alphanumeric, min_length: 3, max_length: 6),
              opts <-
                StreamData.map_of(
                  StreamData.one_of([
                    :limit_bids,
                    :limit_asks
                  ]),
                  non_negative_integer(),
                  max_length: 2
                ),
              max_runs: @max_runs
            ) do
        query = Enum.into(opts, [])

        expect_tesla_call(times: 1, returns: %Tesla.Env{status: 200})

        Public.current_order_book(symbol, query)
        assert_expected_call("/v1/book/#{symbol}", 200, query)
      end
    end
  end

  describe "trade_history/1" do
    property "Retrieves the trade history for the specified trading pair symbol" do
      check all(
              symbol <- string(:alphanumeric, min_length: 3, max_length: 6),
              opts <-
                optional_map(%{
                  timestamp: non_negative_integer(),
                  since_tid: non_negative_integer(),
                  limit_trades: non_negative_integer(),
                  include_breaks: boolean()
                })
                |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                |> StreamData.map(&Enum.into(&1, [])),
              max_runs: @max_runs
            ) do
        query = Enum.into(opts, [])

        expect_tesla_call(times: 1, returns: %Tesla.Env{status: 200})

        Public.trade_history(symbol, query)
        assert_expected_call("/v1/trades/#{symbol}", 200, query)
      end
    end
  end

  describe "price_feed/0" do
    test "retrieves the price feed for all trading pairs" do
      expect_tesla_call(times: 1, returns: %Tesla.Env{status: 200})

      Public.price_feed()
      assert_expected_call("/v1/pricefeed", 200)
    end
  end

  describe "funding_amount/1" do
    property "retrieves the funding amount details for the specified symbol" do
      check all(
              symbol <- string(:alphanumeric, min_length: 3, max_length: 6),
              max_runs: @max_runs
            ) do
        expect_tesla_call(times: 1, returns: %Tesla.Env{status: 200})

        Public.funding_amount(symbol)
        assert_expected_call("/v1/fundingamount/#{symbol}", 200, [])
      end
    end
  end

  describe "funding_amount_report/0" do
    property "retrieves the funding amount report file" do
      check all(
              opts <-
                optional_map(%{
                  timestamp: non_negative_integer(),
                  since_tid: non_negative_integer(),
                  limit_trades: non_negative_integer(),
                  include_breaks: boolean()
                })
                |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                |> StreamData.map(&Enum.into(&1, [])),
              max_runs: @max_runs
            ) do
        query = Enum.into(opts, [])

        expect_tesla_call(times: 1, returns: %Tesla.Env{status: 200})

        Public.funding_amount_report(opts)
        assert_expected_call("/v1/fundingamountreport/records.xlsx", 200, query)
      end
    end
  end
end
