# defmodule Geminex.HttpClient do
#  @moduledoc """
#  HTTP Client for Gemini API.
#  """
#  @behaviour HTTPoison.Base
#  alias Geminex.Config
#
#  @spec request(atom, String.t(), map, keyword) :: {:ok, map} | {:error, any}
#  def request(method, endpoint, params \\ %{}, headers \\ []) do
#    url = "#{Config.api_url()}/#{endpoint}"
#    headers = add_auth_headers(headers, params)
#    HTTPoison.request(method, url, params, headers, [])
#  end
#
#  defp add_auth_headers(headers, params) do
#    # Add authentication headers as described in the Gemini API documentation
#  end
# end
