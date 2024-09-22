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

  @spec get_and_decode(String.t()) :: {:ok, any} | {:error, any}
  def get_and_decode_with_switch(url, use_prod) do
    with {:ok, body} <- get(use_production_url(use_prod) <> url),
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
    (use_production_url(use_prod) <>
       replace_url(url, url_params))
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

  @doc """
  Performs a POST request to the specified URL with a JSON payload.

  ## Parameters

    - url: The URL to perform the POST request on.
    - payload: The payload to include in the POST request.
    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.HttpClient.post_with_payload("/v1/order/status", %{"request" => "/v1/order/status", "nonce" => 12345, "order_id" => 67890}, "mykey", "mysecret")
      {:ok, %{"order_id" => "67890", "status" => "closed", ...}}

  """
  @spec post_with_payload(String.t(), map, String.t(), String.t(), boolean) ::
          {:ok, any} | {:error, any}
  def post_with_payload(url, payload, api_key, api_secret, use_prod) do
    full_url = use_production_url(use_prod) <> url

    encoded_payload = payload |> Jason.encode!() |> Base.encode64()

    signature =
      :crypto.mac(:hmac, :sha384, api_secret, encoded_payload) |> Base.encode16(case: :lower)

    headers = [
      {"Content-Type", "text/plain"},
      {"Content-Length", "0"},
      {"X-GEMINI-APIKEY", api_key},
      {"X-GEMINI-PAYLOAD", encoded_payload},
      {"X-GEMINI-SIGNATURE", signature},
      {"Cache-Control", "no-cache"}
    ]

    case HTTPoison.post(full_url, "", headers, timeout: @timeout) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode(body)

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, %{status_code: status_code, body: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Performs a GET request to the specified URL with authentication headers and decodes the JSON response.

  ## Parameters

    - url: The URL to perform the GET request on.
    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.HttpClient.get_with_auth("/v2/fxrate/gbpusd/1594651859000", "mykey", "mysecret")
      {:ok, %{"fxPair" => "AUDUSD", "rate" => "0.69", ...}}

  """
  @spec get_with_auth(String.t(), String.t(), String.t(), boolean) :: {:ok, any} | {:error, any}
  def get_with_auth(url, api_key, api_secret, use_prod \\ true) do
    full_url = use_production_url(use_prod) <> url

    nonce = :os.system_time(:second)
    payload = %{"request" => url, "nonce" => nonce}
    encoded_payload = payload |> Jason.encode!() |> Base.encode64()

    signature =
      :crypto.mac(:hmac, :sha384, api_secret, encoded_payload) |> Base.encode16(case: :lower)

    headers = [
      {"Content-Type", "text/plain"},
      {"Content-Length", "0"},
      {"X-GEMINI-APIKEY", api_key},
      {"X-GEMINI-PAYLOAD", encoded_payload},
      {"X-GEMINI-SIGNATURE", signature},
      {"Cache-Control", "no-cache"}
    ]

    case HTTPoison.get(full_url, headers, timeout: @timeout) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode(body)

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, %{status_code: status_code, body: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Performs a POST request to the specified URL with the given query parameters and authentication headers and decodes the JSON response.

  ## Parameters

    - url: The URL to perform the POST request on.
    - params: The query parameters to include in the POST request.
    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.HttpClient.post_with_params("/v1/perpetuals/fundingPayment", %{since: 0, to: 1625196000}, "mykey", "mysecret")
      {:ok, [%{"eventType" => "Hourly Funding Transfer", ...}, ...]}

  """
  @spec post_with_params(String.t(), map, String.t(), String.t(), boolean) ::
          {:ok, any} | {:error, any}
  def post_with_params(url, params, api_key, api_secret, use_prod \\ true) do
    base_url = use_production_url(use_prod)
    full_url = base_url <> url

    nonce = :os.system_time(:second)
    payload = %{"request" => url, "nonce" => nonce} |> Map.merge(params)
    encoded_payload = payload |> Jason.encode!() |> Base.encode64()

    signature =
      :crypto.mac(:hmac, :sha384, api_secret, encoded_payload) |> Base.encode16(case: :lower)

    headers = [
      {"Content-Type", "text/plain"},
      {"Content-Length", "0"},
      {"X-GEMINI-APIKEY", api_key},
      {"X-GEMINI-PAYLOAD", encoded_payload},
      {"X-GEMINI-SIGNATURE", signature},
      {"Cache-Control", "no-cache"}
    ]

    case HTTPoison.post(full_url, "", headers, timeout: @timeout) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Jason.decode(body)

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, %{status_code: status_code, body: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Performs a GET request to the specified URL with query parameters and authentication headers and returns the response as binary.

  ## Parameters

    - url: The URL to perform the GET request on.
    - params: The query parameters to include in the GET request.
    - api_key: The API key for authentication.
    - api_secret: The API secret for signing the request.
    - use_prod: Boolean indicating whether to use the production URL (true) or the sandbox URL (false).

  ## Examples

      iex> Geminex.HttpClient.get_with_params_as_binary("/v1/perpetuals/fundingpaymentreport/records.xlsx", %{fromDate: "2024-04-10", toDate: "2024-04-25", numRows: 1000}, "mykey", "mysecret")
      {:ok, <<1, 2, 3, ...>>}

  """
  @spec get_with_params_as_binary(String.t(), map, String.t(), String.t(), boolean) ::
          {:ok, binary} | {:error, any}
  def get_with_params_as_binary(url, params, api_key, api_secret, use_prod \\ true) do
    base_url = use_production_url(use_prod)
    full_url = base_url <> encode_params(url, params)

    nonce = :os.system_time(:second)
    payload = %{"request" => url, "nonce" => nonce} |> Map.merge(params)
    encoded_payload = payload |> Jason.encode!() |> Base.encode64()

    signature =
      :crypto.mac(:hmac, :sha384, api_secret, encoded_payload) |> Base.encode16(case: :lower)

    headers = [
      {"Content-Type", "text/plain"},
      {"Content-Length", "0"},
      {"X-GEMINI-APIKEY", api_key},
      {"X-GEMINI-PAYLOAD", encoded_payload},
      {"X-GEMINI-SIGNATURE", signature},
      {"Cache-Control", "no-cache"}
    ]

    case HTTPoison.get(full_url, headers, timeout: @timeout) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, %{status_code: status_code, body: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp http_client, do: Application.get_env(:geminex, :http_client, HTTPoison)

  @doc false
  @spec match_response({:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}) ::
          {:ok, String.t()} | {:error, any}
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
