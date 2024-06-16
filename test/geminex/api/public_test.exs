defmodule Geminex.API.PublicTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import Mox
  import Geminex.Utils.Generators

  alias Geminex.API.Public

  setup :verify_on_exit!

  @n 100

  defp base_url(true), do: "https://api.gemini.com"
  defp base_url(false), do: "https://api.sandbox.gemini.com"

  property "symbols/1 constructs the correct URL, calls HttpClient.get/1, and decodes the response" do
    check all use_prod <- StreamData.boolean(),
          body <- symbols(),
          max_runs: @n do
      {:ok, encoded_body} = Jason.encode(body)

      HTTPoisonMock
      |> expect(:get, fn url, _headers, _options ->
        assert url == "#{base_url(use_prod)}/v1/symbols"
        {:ok, %HTTPoison.Response{status_code: 200, body: encoded_body}}
      end)

      assert Public.symbols(use_prod) == {:ok, body}
    end
  end

  property "symbol_details/2 constructs the correct URL, calls HttpClient.get_with_params/3, and decodes the response" do
    check all symbol <- string_generator(),
          use_prod <- StreamData.boolean(),
          body <- symbol_details(),
          max_runs: @n do
      {:ok, encoded_body} = Jason.encode(body)

      HTTPoisonMock
      |> expect(:get, fn url, _headers, _options ->
        assert url == "#{base_url(use_prod)}/v1/symbols/details/#{symbol}"
        {:ok, %HTTPoison.Response{status_code: 200, body: encoded_body}}
      end)

      assert Public.symbol_details(symbol, use_prod) == {:ok, body}
    end
  end

  property "network/2 constructs the correct URL, calls HttpClient.get_with_params/3, and decodes the response" do
    check all token <- string_generator(),
          use_prod <- StreamData.boolean(),
          body <- network_detail(),
          max_runs: @n do
      {:ok, encoded_body} = Jason.encode(body)

      HTTPoisonMock
      |> expect(:get, fn url, _headers, _options ->
        assert url == "#{base_url(use_prod)}/v1/network/#{token}"
        {:ok, %HTTPoison.Response{status_code: 200, body: encoded_body}}
      end)

      assert Public.network(token, use_prod) == {:ok, body}
    end
  end

  property "ticker/2 constructs the correct URL, calls HttpClient.get_with_params/3, and decodes the response" do
    check all symbol <- string_generator(),
          use_prod <- StreamData.boolean(),
          body <- ticker_detail(),
          max_runs: @n do
      {:ok, encoded_body} = Jason.encode(body)

      HTTPoisonMock
      |> expect(:get, fn url, _headers, _options ->
        assert url == "#{base_url(use_prod)}/v1/pubticker/#{symbol}"
        {:ok, %HTTPoison.Response{status_code: 200, body: encoded_body}}
      end)

      assert Public.ticker(symbol, use_prod) == {:ok, body}
    end
  end

  property "ticker_v2/2 constructs the correct URL, calls HttpClient.get_with_params/3, and decodes the response" do
    check all symbol <- string_generator(),
          use_prod <- StreamData.boolean(),
          body <- ticker_v2_detail(),
          max_runs: @n do
      {:ok, encoded_body} = Jason.encode(body)

      HTTPoisonMock
      |> expect(:get, fn url, _headers, _options ->
        assert url == "#{base_url(use_prod)}/v2/ticker/#{symbol}"
        {:ok, %HTTPoison.Response{status_code: 200, body: encoded_body}}
      end)

      assert Public.ticker_v2(symbol, use_prod) == {:ok, body}
    end
  end

  property "candles/3 constructs the correct URL, calls HttpClient.get_with_params/3, and decodes the response" do
    check all symbol <- string_generator(),
          time_frame <- string_generator(),
          use_prod <- StreamData.boolean(),
          body <- candles_detail(),
          max_runs: @n do
      {:ok, encoded_body} = Jason.encode(body)

      HTTPoisonMock
      |> expect(:get, fn url, _headers, _options ->
        assert url == "#{base_url(use_prod)}/v2/candles/#{symbol}/#{time_frame}"
        {:ok, %HTTPoison.Response{status_code: 200, body: encoded_body}}
      end)

      assert Public.candles(symbol, time_frame, use_prod) == {:ok, body}
    end
  end

  property "derivatives_candles/3 constructs the correct URL, calls HttpClient.get_with_params/3, and decodes the response" do
    check all symbol <- string_generator(),
          time_frame <- string_generator(),
          use_prod <- StreamData.boolean(),
          body <- candles_detail(),
          max_runs: @n do
      {:ok, encoded_body} = Jason.encode(body)

      HTTPoisonMock
      |> expect(:get, fn url, _headers, _options ->
        assert url == "#{base_url(use_prod)}/v2/derivatives/candles/#{symbol}/#{time_frame}"
        {:ok, %HTTPoison.Response{status_code: 200, body: encoded_body}}
      end)

      assert Public.derivatives_candles(symbol, time_frame, use_prod) == {:ok, body}
    end
  end

  property "fee_promos/1 constructs the correct URL, calls HttpClient.get_and_decode/1, and decodes the response" do
    check all use_prod <- StreamData.boolean(),
          body <- fee_promos_detail(),
          max_runs: @n do
      {:ok, encoded_body} = Jason.encode(body)

      HTTPoisonMock
      |> expect(:get, fn url, _headers, _options ->
        assert url == "#{base_url(use_prod)}/v1/feepromos"
        {:ok, %HTTPoison.Response{status_code: 200, body: encoded_body}}
      end)

      assert Public.fee_promos(use_prod) == {:ok, body}
    end
  end

  property "current_order_book/2 constructs the correct URL, calls HttpClient.get_with_params/3, and decodes the response" do
    check all symbol <- string_generator(),
          use_prod <- StreamData.boolean(),
          limit_bids <- StreamData.integer(50..1000),
          limit_asks <- StreamData.integer(50..1000),
          body <- order_book(),
          max_runs: @n do
      {:ok, encoded_body} = Jason.encode(body)

      HTTPoisonMock
      |> expect(:get, fn url, _headers, _options ->
        assert url == "#{base_url(use_prod)}/v1/book/#{symbol}?limit_bids=#{limit_bids}&limit_asks=#{limit_asks}"
        {:ok, %HTTPoison.Response{status_code: 200, body: encoded_body}}
      end)

      assert Public.current_order_book(symbol, limit_bids, limit_asks, use_prod) == {:ok, body}
    end
  end

  property "trade_history/3 constructs the correct URL, calls HttpClient.get_with_params/3, and decodes the response" do
    check all symbol <- string_generator(),
          opts <- StreamData.map_of(string_generator(), StreamData.integer() |> StreamData.map(&to_string/1), max_length: 5),
          use_prod <- StreamData.boolean(),
          body <- trade_history_detail(),
          max_runs: @n do
      {:ok, encoded_body} = Jason.encode(body)

      HTTPoisonMock
      |> expect(:get, fn url, _headers, _options ->
        assert url == "#{base_url(use_prod)}/v1/trades/#{symbol}?#{URI.encode_query(opts)}"
        {:ok, %HTTPoison.Response{status_code: 200, body: encoded_body}}
      end)

      assert Public.trade_history(symbol, opts, use_prod) == {:ok, body}
    end
  end

  property "price_feed/1 constructs the correct URL, calls HttpClient.get_and_decode/1, and decodes the response" do
    check all use_prod <- StreamData.boolean(),
          body <- price_feed_detail(),
          max_runs: @n do
      {:ok, encoded_body} = Jason.encode(body)

      HTTPoisonMock
      |> expect(:get, fn url, _headers, _options ->
        assert url == "#{base_url(use_prod)}/v1/pricefeed"
        {:ok, %HTTPoison.Response{status_code: 200, body: encoded_body}}
      end)

      assert Public.price_feed(use_prod) == {:ok, body}
    end
  end

  property "funding_amount/2 constructs the correct URL, calls HttpClient.get_with_params/3, and decodes the response" do
    check all symbol <- string_generator(),
          use_prod <- StreamData.boolean(),
          body <- funding_amount_detail(),
          max_runs: @n do
      {:ok, encoded_body} = Jason.encode(body)

      HTTPoisonMock
      |> expect(:get, fn url, _headers, _options ->
        assert url == "#{base_url(use_prod)}/v1/fundingamount/#{symbol}"
        {:ok, %HTTPoison.Response{status_code: 200, body: encoded_body}}
      end)

      assert Public.funding_amount(symbol, use_prod) == {:ok, body}
    end
  end

  property "funding_amount_report/2 constructs the correct URL, calls HttpClient.get/1, and handles the response" do
    check all symbol <- string_generator(),
          from_date <- string_generator(),
          to_date <- string_generator(),
          num_rows <- StreamData.integer(),
          use_prod <- StreamData.boolean(),
          max_runs: @n do

      opts = %{
        symbol: symbol,
        fromDate: from_date,
        toDate: to_date,
        numRows: num_rows
      }

      encoded_params = URI.encode_query(opts)
      expected_url = "#{base_url(use_prod)}/v1/fundingamountreport/records.xlsx?#{encoded_params}"

      HTTPoisonMock
      |> expect(:get, fn url, _headers, _options ->
        assert url == expected_url
        {:ok, %HTTPoison.Response{status_code: 200, body: "binary content"}}
      end)

      assert Public.funding_amount_report(opts, use_prod) == {:ok, "binary content"}
    end
  end
end