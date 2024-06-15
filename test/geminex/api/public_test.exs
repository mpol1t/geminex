defmodule Geminex.API.Public do
  @moduledoc """
  Public API endpoints.
  """
  alias Geminex.HttpClient

  @spec get_order_book(String.t()) :: {:ok, map} | {:error, any}
  def get_order_book(symbol) do
    HttpClient.request(:get, "v1/book/#{symbol}")
  end

  @spec get_trade_history(String.t()) :: {:ok, map} | {:error, any}
  def get_trade_history(symbol) do
    HttpClient.request(:get, "v1/trades/#{symbol}")
  end
end
