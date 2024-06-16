defmodule Geminex.HttpClient do
  @moduledoc """
  HTTP Client for Gemini API.
  """

  @sandbox_url "https://api.sandbox.gemini.com"
  @production_url "https://api.gemini.com"
  @timeout 5000

  @doc """
  Returns the base URL for the production or sandbox environment.

  ## Parameters

    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.HttpClient.use_production_url(true)
      "https://api.gemini.com"

  """
  @spec use_production_url(boolean) :: String.t()
  def use_production_url(true), do: @production_url
  def use_production_url(false), do: @sandbox_url

  @doc """
  Performs a GET request to the specified URL and decodes the JSON response.

  ## Parameters

    - url: The URL to perform the GET request on.

  ## Examples

      iex> Geminex.HttpClient.get_and_decode("https://api.gemini.com/v1/symbols")
      {:ok, ["btcusd", "ethbtc", "ethusd", ...]}

  """
  @spec get_and_decode(String.t()) :: {:ok, any} | {:error, any}
  def get_and_decode(url) do
    with {:ok, body} <- get(url),
         {:ok, data} <- Jason.decode(body) do
      {:ok, data}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Performs a GET request to the specified URL with parameters and decodes the JSON response.

  ## Parameters

    - url: The URL to perform the GET request on.
    - url_params: A map of URL parameters to replace in the URL.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.HttpClient.get_with_params("/v1/symbols/details/:symbol", %{"symbol" => "btcusd"})
      {:ok, %{"symbol" => "btcusd", "base_currency" => "BTC", "quote_currency" => "USD", ...}}

  """
  @spec get_with_params(String.t(), map, boolean) :: {:ok, any} | {:error, any}
  def get_with_params(url, url_params \\ %{}, use_prod \\ true) do
    use_production_url(use_prod)
    <> replace_url(url, url_params)
    |> get_and_decode()
  end

  @doc """
  Encodes the provided parameters into a query string and appends it to the URL.

  ## Parameters

    - url: The base URL.
    - params: A map of parameters to encode into the query string.

  ## Examples

      iex> Geminex.HttpClient.encode_params("/v1/symbols", %{"limit" => 10, "offset" => 0})
      "/v1/symbols?limit=10&offset=0"

  """
  @spec encode_params(String.t(), map) :: String.t()
  def encode_params(url, params) do
    url <> "?" <> URI.encode_query(params |> filter_params())
  end

  @doc """
  Filters out parameters with nil values from the provided map.

  ## Parameters

  - params: A map of parameters to filter.

  ## Examples

      iex> Geminex.HttpClient.filter_params(%{"limit" => 10, "offset" => nil})
      %{"limit" => 10}

  """
  @spec filter_params(map) :: map
  def filter_params(params) do
    params
    |> Enum.filter(fn
      {_, nil} -> false
      {_, _} -> true
    end)
    |> Enum.into(%{})
  end

  @doc """
  Replaces placeholders in the URL with corresponding values from the provided map.

  ## Parameters

    - url: The URL with placeholders.
    - params: A map of parameters to replace in the URL.

  ## Examples

      iex> Geminex.HttpClient.replace_url("/v1/symbols/details/:symbol", %{"symbol" => "btcusd"})
      "/v1/symbols/details/btcusd"

  """
  @spec replace_url(String.t(), map) :: String.t()
  def replace_url(url, params) do
    Enum.reduce(params, url, fn {key, value}, acc ->
      String.replace(acc, ":#{key}", value)
    end)
  end

  @doc """
  Performs a GET request to the specified URL and returns the response.

  ## Parameters

    - url: The URL to perform the GET request on.

  ## Examples

      iex> Geminex.HttpClient.get("https://api.gemini.com/v1/symbols")
      {:ok, "[\"btcusd\", \"ethbtc\", \"ethusd\", ...]"}

  """
  @spec get(String.t()) :: {:ok, String.t()} | {:error, any}
  def get(url) do
    http_client().get(url, [], timeout: @timeout) |> match_response()
  end

  defp http_client, do: Application.get_env(:geminex, :http_client, HTTPoison)

  @doc false
  @spec match_response({:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}) :: {:ok, String.t()} | {:error, any}
  defp match_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    {:ok, body}
  end

  defp match_response({:ok, %HTTPoison.Response{status_code: status_code}}) do
    {:error, "HTTP error with status code: #{status_code}"}
  end

  defp match_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, "HTTP request failed: #{inspect(reason)}"}
  end
end