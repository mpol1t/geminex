defmodule Geminex.API.PrivateTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import Mox
  import Tesla.Test

  alias Geminex.Middleware.DynamicBaseUrl
  alias Geminex.Utils

  setup :set_mox_from_context
  setup :verify_on_exit!

  @max_runs 100

  defp alpha_string,  do: string(:alphanumeric, min_length: 3, max_length: 6)
  defp non_neg_float, do: float(min: 0)
  defp order_side,    do: StreamData.one_of([constant("buy"), constant("sell")])
  defp order_type,    do: StreamData.one_of([constant("exchange limit"), constant("exchange stop limit")])

  defp assert_expected_call(env, expected_path, status, actual_payload, payload, opts) do
    assert_tesla_env(env, %Tesla.Env{
        method:   :post,
        status:   status,
        url:      DynamicBaseUrl.base_url() <> expected_path,
        body:     "",
        query:    Keyword.get(opts, :query, [])
      },
      exclude_headers: [
        "X-GEMINI-APIKEY",
        "X-GEMINI-PAYLOAD",
        "X-GEMINI-SIGNATURE",
        "Content-Type",
        "Content-Length",
        "Cache-Control"
      ]
    )

    assert Map.delete(actual_payload, "nonce") == payload

    assert_tesla_empty_mailbox()
  end

  defp decode_and_assert(%Tesla.Env{headers: headers} = env, path, payload, opts \\ []) do
      {_,   encoded_payload}  = List.keyfind(headers, "X-GEMINI-PAYLOAD", 0)
      {:ok, decoded_payload}  = Base.decode64(encoded_payload)
      {:ok, actual_payload}   = Jason.decode(decoded_payload)

      assert_expected_call(env, path, 200, actual_payload, payload, opts)

      {:ok, %Tesla.Env{status: 200}}
  end

  describe "new_order/6" do
    property "places a new order" do
      check all symbol  <- alpha_string(),
                amount  <- non_neg_float(),
                price   <- non_neg_float(),
                side    <- order_side(),
                type    <- order_type(),
                opts    <- optional_map(%{
                  client_order_id:  alpha_string(),
                  stop_price:       non_neg_float(),
                  options:          list_of(one_of([constant("maker-or-cancel")])),
                  account:          alpha_string()
                })
                   |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                   |> StreamData.map(&Enum.into(&1, [])),
                  max_runs: @max_runs do
                  request_path = "/v1/order/new"

                  payload = %{
                    "symbol"  => symbol,
                    "amount"  => amount,
                    "price"   => price,
                    "side"    => side,
                    "type"    => type,
                    "request" => request_path
                  }
                    |> Utils.merge_map_with_string_keys(opts)

                  Mox.expect(
                    Geminex.MockAdapter, :call, fn env, _opts -> decode_and_assert(env, request_path, payload) end
                  )

                  Geminex.API.Private.new_order(symbol, amount, price, side, type, opts)
              end
        end
  end

  describe "cancel_order/2" do
    property "cancels an order by order ID" do
      check all order_id  <- non_negative_integer(),
                opts      <- optional_map(
                  %{
                    account: alpha_string()
                  }
                )
                 |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                 |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/order/cancel"

        payload = %{
          "order_id"  => order_id,
          "request"   => request_path
        }
          |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.cancel_order(order_id, opts)
      end
    end
  end

  describe "wrap_order/4" do
    property "wraps or unwraps Gemini-issued assets" do
      check all symbol  <- alpha_string(),
                amount  <- non_neg_float(),
                side    <- order_side(),
                opts    <- optional_map(%{
                  account:          alpha_string(),
                  client_order_id:  alpha_string()
                })
                  |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                  |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do

        request_path = "/v1/wrap/#{symbol}"

        payload = %{
          "amount" => amount,
          "side" => side,
          "request" => request_path
        }
          |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(
          Geminex.MockAdapter, :call, fn env, _opts -> decode_and_assert(env, request_path, payload) end
        )

        Geminex.API.Private.wrap_order(symbol, amount, side, opts)
      end
    end
  end

  describe "cancel_all_session_orders/1" do
    property "cancels all orders opened by this session" do
      check all opts <- optional_map(%{
        account: alpha_string()
      })
        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do

        request_path = "/v1/order/cancel/session"

        payload = %{"request" => request_path} |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(
          Geminex.MockAdapter, :call, fn env, _opts -> decode_and_assert(env, request_path, payload) end
        )

        Geminex.API.Private.cancel_all_session_orders(opts)
      end
    end
  end

  describe "cancel_all_active_orders/1" do
    property "cancels all outstanding orders created by any session associated with this account" do
      check all opts <- optional_map(%{
        account: alpha_string()
      })
        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
        |> StreamData.map(&Enum.into(&1, [])), max_runs: @max_runs do

        request_path = "/v1/order/cancel/all"

        payload = %{"request" => request_path} |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(
          Geminex.MockAdapter, :call, fn env, _opts -> decode_and_assert(env, request_path, payload) end
        )

        Geminex.API.Private.cancel_all_active_orders(opts)
      end
    end
  end

  describe "order_status/1" do
    property "retrieves the status of a specific order" do
      check all opts <- optional_map(%{
        order_id: non_negative_integer(),
        client_order_id: alpha_string(),
        include_trades: boolean(),
        account: alpha_string()
      })
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/order/status"

        payload = %{"request" => request_path} |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.order_status(opts)
      end
    end
  end

  describe "active_orders/1" do
    property "retrieves all active orders" do
      check all opts <- optional_map(%{account: alpha_string()})
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/orders"

        payload = %{"request" => request_path} |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.active_orders(opts)
      end
    end
  end

  describe "past_trades/1" do
    property "retrieves past trades for a specific symbol" do
      check all opts <- optional_map(%{
        symbol: alpha_string(),
        limit_trades: non_negative_integer(),
        timestamp: non_negative_integer(),
        account: alpha_string()
      })
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/mytrades"

        payload = %{"request" => request_path} |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.past_trades(opts)
      end
    end
  end

  describe "orders_history/1" do
    property "retrieves closed orders history for a symbol" do
      check all opts <- optional_map(%{
        symbol: alpha_string(),
        limit_orders: non_negative_integer(),
        timestamp: non_negative_integer(),
        account: alpha_string()
      })
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/orders/history"

        payload = %{"request" => request_path} |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.orders_history(opts)
      end
    end
  end

  describe "notional_volume/1" do
    property "retrieves the 30-day notional volume" do
      check all opts <- optional_map(%{symbol: alpha_string(), account: alpha_string()})
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/notionalvolume"

        payload = %{"request" => request_path} |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.notional_volume(opts)
      end
    end
  end

  describe "trade_volume/1" do
    property "retrieves trade volume data" do
      check all opts <- optional_map(%{account: alpha_string()})
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/tradevolume"

        payload = %{"request" => request_path} |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.trade_volume(opts)
      end
    end
  end

  describe "fx_rate/2" do
    property "retrieves historical FX rate for a specific currency pair against USD" do
      check all symbol <- alpha_string(),
            timestamp <- non_negative_integer(),
            max_runs: @max_runs do
        request_path = "/v2/fxrate/#{symbol}/#{timestamp}"

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          assert env.method == :get
          assert env.url == DynamicBaseUrl.base_url() <> request_path
          assert_tesla_empty_mailbox()
          {:ok, %Tesla.Env{status: 200}}
        end)

        Geminex.API.Private.fx_rate(symbol, timestamp)
      end
    end
  end

  describe "open_positions/1" do
    property "retrieves all open positions for the account" do
      check all opts <- optional_map(%{account: alpha_string()})
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/positions"

        payload = %{"request" => request_path} |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.open_positions(opts)
      end
    end
  end

  describe "account_margin/2" do
    property "retrieves margin details for a specific symbol" do
      check all symbol <- alpha_string(),
            opts <- optional_map(%{account: alpha_string()})
                    |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                    |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/margin"

        payload = %{"symbol" => symbol, "request" => request_path} |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.account_margin(symbol, opts)
      end
    end
  end

  describe "risk_stats/1" do
    property "retrieves risk statistics for a specified symbol" do
      check all symbol <- alpha_string(),
            max_runs: @max_runs do
        request_path = "/v1/riskstats/#{symbol}"

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          assert env.method == :get
          assert env.url == DynamicBaseUrl.base_url() <> request_path
          assert_tesla_empty_mailbox()
          {:ok, %Tesla.Env{status: 200}}
        end)

        Geminex.API.Private.risk_stats(symbol)
      end
    end
  end

  describe "funding_payment/1" do
    property "retrieves funding payment history within a specified time range" do
      check all opts <- optional_map(%{
        since: non_negative_integer(),
        to: non_negative_integer(),
        account: alpha_string()
      })
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/perpetuals/fundingPayment"
        query = Enum.filter(opts, fn {k, _} -> k in [:since, :to] end)
        payload = %{"request" => request_path}
          |> Utils.merge_map_with_string_keys(Enum.reject(opts, fn {k, _} -> k in [:since, :to] end))

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload, query: query)
        end)

        Geminex.API.Private.funding_payment(opts)
      end
    end
  end

  describe "funding_payment_report_file/1" do
    property "retrieves funding payment data as an Excel file" do
      check all opts <- optional_map(%{
        from_date: alpha_string(),
        to_date: alpha_string(),
        num_rows: non_negative_integer()
      })
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/perpetuals/fundingpaymentreport/records.xlsx"

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          assert env.method == :get
          assert env.query == opts
          assert env.url == DynamicBaseUrl.base_url() <> request_path
          assert_tesla_empty_mailbox()
          {:ok, %Tesla.Env{status: 200}}
        end)

        Geminex.API.Private.funding_payment_report_file(opts)
      end
    end
  end

  describe "funding_payment_report_json/1" do
    property "retrieves funding payment data as JSON" do
      check all opts <- optional_map(%{
        from_date: alpha_string(),
        to_date: alpha_string(),
        num_rows: non_negative_integer()
      })
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/perpetuals/fundingpaymentreport/records.json"

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          assert env.method == :get
          assert env.query == opts
          assert env.url == DynamicBaseUrl.base_url() <> request_path
          assert_tesla_empty_mailbox()
          {:ok, %Tesla.Env{status: 200}}
        end)

        Geminex.API.Private.funding_payment_report_json(opts)
      end
    end
  end

  describe "new_clearing_order/5" do
    property "creates a new clearing order" do
      check all symbol <- alpha_string(),
            amount <- non_neg_float(),
            price <- non_neg_float(),
            side <- order_side(),
            opts <- optional_map(%{
              counterparty_id: alpha_string(),
              expires_in_hrs: non_negative_integer(),
              account: alpha_string()
            })
                    |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                    |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/clearing/new"

        payload = %{
                    "symbol" => symbol,
                    "amount" => amount,
                    "price" => price,
                    "side" => side,
                    "request" => request_path
                  }
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.new_clearing_order(symbol, amount, price, side, opts)
      end
    end
  end

  describe "new_broker_order/7" do
    property "creates a new broker clearing order between two counterparties" do
      check all symbol                 <- alpha_string(),
            amount                 <- non_neg_float(),
            price                  <- non_neg_float(),
            side                   <- order_side(),
            source_counterparty_id <- alpha_string(),
            target_counterparty_id <- alpha_string(),
            opts                   <- optional_map(%{
              expires_in_hrs: non_negative_integer(),
              account: alpha_string()
            })
                                      |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                                      |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/clearing/broker/new"

        payload = %{
                    "symbol"                 => symbol,
                    "amount"                 => amount,
                    "price"                  => price,
                    "side"                   => side,
                    "source_counterparty_id" => source_counterparty_id,
                    "target_counterparty_id" => target_counterparty_id,
                    "request"                => request_path
                  }
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.new_broker_order(symbol, amount, price, side, source_counterparty_id, target_counterparty_id, opts)
      end
    end
  end

  describe "clearing_order_status/2" do
    property "fetches the status of a clearing order by its unique clearing ID" do
      check all clearing_id <- alpha_string(),
            opts        <- optional_map(%{account: alpha_string()})
                           |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                           |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/clearing/status"

        payload = %{"clearing_id" => clearing_id, "request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.clearing_order_status(clearing_id, opts)
      end
    end
  end

  describe "cancel_clearing_order/2" do
    property "cancels a specific clearing order" do
      check all clearing_id <- alpha_string(),
            opts        <- optional_map(%{account: alpha_string()})
                           |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                           |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/clearing/cancel"

        payload = %{"clearing_id" => clearing_id, "request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.cancel_clearing_order(clearing_id, opts)
      end
    end
  end

  describe "confirm_clearing_order/6" do
    property "confirms a clearing order with the provided details" do
      check all clearing_id <- alpha_string(),
            symbol      <- alpha_string(),
            amount      <- non_neg_float(),
            price       <- non_neg_float(),
            side        <- order_side(),
            opts        <- optional_map(%{account: alpha_string()})
                           |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                           |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/clearing/confirm"

        payload = %{
                    "clearing_id" => clearing_id,
                    "symbol"      => symbol,
                    "amount"      => amount,
                    "price"       => price,
                    "side"        => side,
                    "request"     => request_path
                  }
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.confirm_clearing_order(clearing_id, symbol, amount, price, side, opts)
      end
    end
  end

  describe "clearing_order_list/2" do
    property "retrieves a list of clearing orders with optional filters" do
      check all side <- order_side(),
            opts <- optional_map(%{
              symbol: alpha_string(),
              counterparty: alpha_string(),
              expiration_start: non_negative_integer(),
              expiration_end: non_negative_integer(),
              submission_start: non_negative_integer(),
              submission_end: non_negative_integer(),
              funded: boolean(),
              account: alpha_string()
            })
                    |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                    |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/clearing/list"

        payload = %{"side" => side, "request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.clearing_order_list(side, opts)
      end
    end
  end

  describe "clearing_broker_list/1" do
    property "retrieves a list of broker clearing orders with optional filters" do
      check all opts <- optional_map(%{
        symbol: alpha_string(),
        expiration_start: non_negative_integer(),
        expiration_end: non_negative_integer(),
        submission_start: non_negative_integer(),
        submission_end: non_negative_integer(),
        funded: boolean(),
        account: alpha_string()
      })
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/clearing/broker/list"

        payload = %{"request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.clearing_broker_list(opts)
      end
    end
  end

  describe "clearing_trades/1" do
    property "retrieves a list of clearing trades with optional filters" do
      check all opts <- optional_map(%{
        timestamp_nanos: non_negative_integer(),
        limit: non_negative_integer(),
        account: alpha_string()
      })
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/clearing/trades"

        payload = %{"request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.clearing_trades(opts)
      end
    end
  end

  describe "available_balances/1" do
    property "fetches available balances in supported currencies" do
      check all opts <- optional_map(%{account: alpha_string()})
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/balances"

        payload = %{"request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.available_balances(opts)
      end
    end
  end

  describe "notional_balances/2" do
    property "fetches balances and their notional values in a specified currency" do
      check all currency <- alpha_string(),
            opts     <- optional_map(%{account: alpha_string()})
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/notionalbalances/#{currency}"

        payload = %{"request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.notional_balances(currency, opts)
      end
    end
  end

  describe "transfers/1" do
    property "retrieves transfer history with optional filters" do
      check all opts <- optional_map(%{
        currency: alpha_string(),
        timestamp: non_negative_integer(),
        limit_transfers: non_negative_integer(),
        show_completed_deposit_advances: boolean(),
        account: alpha_string()
      })
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/transfers"

        payload = %{"request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.transfers(opts)
      end
    end
  end

  describe "transactions/1" do
    property "fetches transaction details with optional filters" do
      check all opts <- optional_map(%{
        timestamp_nanos: non_negative_integer(),
        limit: non_negative_integer(),
        continuation_token: alpha_string(),
        account: alpha_string()
      })
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/transactions"

        payload = %{"request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.transactions(opts)
      end
    end
  end

  describe "estimate_gas_fee/4" do
    property "estimates gas fees for a cryptocurrency withdrawal" do
      check all currency <- alpha_string(),
            address  <- alpha_string(),
            amount   <- non_neg_float(),
            opts     <- optional_map(%{account: alpha_string()})
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/withdraw/#{currency}/feeEstimate"

        payload = %{
                    "address" => address,
                    "amount"  => amount,
                    "request" => request_path
                  }
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.estimate_gas_fee(currency, address, amount, opts)
      end
    end
  end

  describe "withdraw_crypto_funds/4" do
    property "withdraws cryptocurrency funds to an approved address" do
      check all currency <- alpha_string(),
            address  <- alpha_string(),
            amount   <- non_neg_float(),
            opts     <- optional_map(%{
              client_transfer_id: alpha_string(),
              memo: alpha_string(),
              account: alpha_string()
            })
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/withdraw/#{currency}"

        payload = %{
                    "address" => address,
                    "amount"  => amount,
                    "request" => request_path
                  }
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.withdraw_crypto_funds(currency, address, amount, opts)
      end
    end
  end

  describe "execute_internal_transfer/5" do
    property "executes an internal transfer between two accounts" do
      check all currency         <- alpha_string(),
            source_account   <- alpha_string(),
            target_account   <- alpha_string(),
            amount           <- non_neg_float(),
            opts             <- optional_map(%{client_transfer_id: alpha_string()})
                                |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                                |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/account/transfer/#{currency}"

        payload = %{
                    "sourceAccount" => source_account,
                    "targetAccount" => target_account,
                    "amount"        => amount,
                    "request"       => request_path
                  }
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.execute_internal_transfer(currency, source_account, target_account, amount, opts)
      end
    end
  end

  describe "custody_account_fees/1" do
    property "fetches custody account fees with optional filters" do
      check all opts <- optional_map(%{
        timestamp: non_negative_integer(),
        limit_transfers: non_negative_integer(),
        account: alpha_string()
      })
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/custodyaccountfees"

        payload = %{"request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.custody_account_fees(opts)
      end
    end
  end
  describe "deposit_addresses/2" do
    property "retrieves deposit addresses for a specified network" do
      check all network <- alpha_string(),
            opts <- optional_map(%{
              timestamp: non_negative_integer(),
              account: alpha_string()
            })
                    |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                    |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/addresses/#{network}"

        payload = %{"request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.deposit_addresses(network, opts)
      end
    end
  end

  describe "new_deposit_address/2" do
    property "generates a new deposit address for a specified network" do
      check all network <- alpha_string(),
            opts <- optional_map(%{
              label: alpha_string(),
              legacy: boolean(),
              account: alpha_string()
            })
                    |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                    |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/deposit/#{network}/newAddress"

        payload = %{"request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.new_deposit_address(network, opts)
      end
    end
  end

  describe "add_bank/5" do
    property "adds a bank account for the user" do
      check all account_number <- alpha_string(),
            routing <- alpha_string(),
            type <- StreamData.one_of([constant("checking"), constant("savings")]),
            name <- alpha_string(),
            opts <- optional_map(%{account: alpha_string()})
                    |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                    |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/payments/addbank"

        payload = %{
                    "accountnumber" => account_number,
                    "routing" => routing,
                    "type" => type,
                    "name" => name,
                    "request" => request_path
                  }
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.add_bank(account_number, routing, type, name, opts)
      end
    end
  end

  describe "add_bank_cad/5" do
    property "adds a CAD bank account for the user" do
      check all swift_code <- alpha_string(),
            account_number <- alpha_string(),
            type <- StreamData.one_of([constant("checking"), constant("savings")]),
            name <- alpha_string(),
            opts <- optional_map(%{
              institution_number: alpha_string(),
              branch_number: alpha_string(),
              account: alpha_string()
            })
                    |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                    |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/payments/addbank/cad"

        payload = %{
                    "swiftcode" => swift_code,
                    "accountnumber" => account_number,
                    "type" => type,
                    "name" => name,
                    "request" => request_path
                  }
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.add_bank_cad(swift_code, account_number, type, name, opts)
      end
    end
  end

  describe "payment_methods/1" do
    property "fetches payment methods and available fiat balances" do
      check all opts <- optional_map(%{account: alpha_string()})
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/payments/methods"

        payload = %{"request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.payment_methods(opts)
      end
    end
  end

  describe "staking_balances/1" do
    property "retrieves the staking balances for the account" do
      check all opts <- optional_map(%{account: alpha_string()})
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/balances/staking"

        payload = %{"request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.staking_balances(opts)
      end
    end
  end

  describe "staking_rates/0" do
    property "fetches current staking interest rates" do
      request_path = "/v1/staking/rates"

      Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
        assert_tesla_env(env, %Tesla.Env{
          method: :get,
          url: DynamicBaseUrl.base_url() <> request_path,
          body: ""
        },
          exclude_headers: [
            "X-GEMINI-APIKEY",
            "X-GEMINI-PAYLOAD",
            "X-GEMINI-SIGNATURE",
            "Content-Type",
            "Content-Length",
            "Cache-Control"
          ]
        )

        {:ok, %Tesla.Env{status: 200}}
      end)

      Geminex.API.Private.staking_rates()
    end
  end

  describe "staking_rewards/2" do
    property "retrieves staking rewards with optional filters" do
      check all since <- alpha_string(),
            opts <- optional_map(%{
              until: alpha_string(),
              provider_id: alpha_string(),
              currency: alpha_string(),
              account: alpha_string()
            })
                    |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                    |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/staking/rewards"

        payload = %{"since" => since, "request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.staking_rewards(since, opts)
      end
    end
  end

  describe "create_address_request/4" do
    property "creates a request to add an address to the approved list" do
      check all network <- alpha_string(),
            address <- alpha_string(),
            label <- alpha_string(),
            opts <- optional_map(%{
              account: alpha_string(),
              memo: alpha_string()
            })
                    |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                    |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/approvedAddresses/#{network}/request"

        payload = %{
                    "address" => address,
                    "label" => label,
                    "request" => request_path
                  }
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.create_address_request(network, address, label, opts)
      end
    end
  end
  describe "view_approved_addresses/2" do
    property "views the approved address list for a specific network" do
      check all network <- alpha_string(),
            opts <- optional_map(%{account: alpha_string()})
                    |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                    |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/approvedAddresses/account/#{network}"

        payload = %{"request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.view_approved_addresses(network, opts)
      end
    end
  end

  describe "remove_address/3" do
    property "removes an address from the approved address list" do
      check all network <- alpha_string(),
            address <- alpha_string(),
            opts <- optional_map(%{account: alpha_string()})
                    |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                    |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/approvedAddresses/#{network}/remove"

        payload = %{
                    "address" => address,
                    "request" => request_path
                  }
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.remove_address(network, address, opts)
      end
    end
  end

  describe "account_detail/1" do
    property "fetches account details, including user and account information" do
      check all opts <- optional_map(%{account: alpha_string()})
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/account"

        payload = %{"request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.account_detail(opts)
      end
    end
  end

  describe "create_account/2" do
    property "creates a new account within the master group" do
      check all name <- alpha_string(),
            opts <- optional_map(%{type: StreamData.one_of([constant("exchange"), constant("custody")])})
                    |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                    |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/account/create"

        payload = %{
                    "name" => name,
                    "request" => request_path
                  }
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.create_account(name, opts)
      end
    end
  end

  describe "rename_account/2" do
    property "renames an account within the master group" do
      check all account <- alpha_string(),
            opts <- optional_map(%{
              new_name: alpha_string(),
              new_account: alpha_string()
            })
                    |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                    |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/account/rename"

        payload = %{
                    "account" => account,
                    "request" => request_path
                  }
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.rename_account(account, opts)
      end
    end
  end

  describe "list_accounts/1" do
    property "fetches a list of accounts within the master group" do
      check all opts <- optional_map(%{
        limit_accounts: non_negative_integer(),
        timestamp: non_negative_integer()
      })
                        |> StreamData.map(&Enum.reject(&1, fn {_key, v} -> is_nil(v) end))
                        |> StreamData.map(&Enum.into(&1, [])),
            max_runs: @max_runs do
        request_path = "/v1/account/list"

        payload = %{"request" => request_path}
                  |> Utils.merge_map_with_string_keys(opts)

        Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
          decode_and_assert(env, request_path, payload)
        end)

        Geminex.API.Private.list_accounts(opts)
      end
    end
  end

  describe "heartbeat/0" do
    test "sends a heartbeat to prevent session timeout" do
      request_path = "/v1/heartbeat"

      Mox.expect(Geminex.MockAdapter, :call, fn env, _opts ->
        decode_and_assert(env, request_path, %{"request" => request_path})

        {:ok, %Tesla.Env{status: 200}}
      end)

      Geminex.API.Private.heartbeat()
    end
  end
end