defmodule Geminex.HttpClient do
  @moduledoc """
  HTTP Client for Gemini API.
  """
  @behaviour HTTPoison.Base
  alias Geminex.Config

  @sandbox_url    "https://api.sandbox.gemini.com"
  @production_url "https://api.gemini.com"

  def use_production_url(true),   do: @production_url
  def use_production_url(false),  do: @sandbox_url

  def get_and_decode(url) do
    with {:ok, body} <- get(url),
         {:ok, data} <- Jason.decode(body) do
      {:ok, data}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_with_params(url, url_params \\ %{}, use_prod \\ true) do
    use_production_url(use_prod)
    <> replace_url(url, url_params)
    |> get_and_decode
  end

  def encode_params(url, params) do
    url <> "?" <> URI.encode_query(params |> filter_params)
  end

  def filter_params(params) do
    params |> Enum.filter(
                fn
                  {k, nil}  -> false
                  {k, v}    -> true
                end
              )
  end

  def replace_url(url, params) do
    Enum.reduce(params, url, fn {key, value}, acc ->
      String.replace(acc, ":#{key}", value)
    end)
  end

  def get(url) do
    url |> HTTPoison.get([], timeout: @timeout) |> match_response
  end

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