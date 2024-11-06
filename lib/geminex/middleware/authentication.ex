defmodule Geminex.Middleware.Authentication do
  @moduledoc false
  @behaviour Tesla.Middleware

  @impl true
  def call(%Tesla.Env{body: body, headers: headers, opts: [path: request_path]} = env, next, _opts) do
    api_key     = Application.fetch_env!(:geminex, :api_key)
    api_secret  = Application.fetch_env!(:geminex, :api_secret)

    payload = build_payload(body, request_path, :os.system_time(:millisecond))

    encoded_payload = Jason.encode!(payload) |> Base.encode64()

    signature = :crypto.mac(:hmac, :sha384, api_secret, encoded_payload) |> Base.encode16(case: :lower)

    # Add authentication headers
    gemini_headers = [
      {"X-GEMINI-APIKEY",     api_key},
      {"X-GEMINI-PAYLOAD",    encoded_payload},
      {"X-GEMINI-SIGNATURE",  signature},
      {"Content-Type",        "text/plain"},
      {"Content-Length",      "0"},
      {"Cache-Control",       "no-cache"}
    ]

    Tesla.run(%Tesla.Env{ env | headers: gemini_headers ++ headers, body: ""}, next)
  end

  defp build_payload(nil, _path, _nonce), do: %{}
  defp build_payload(body, path,  nonce)  do
    body
      |> Map.merge(
        %{
          "request" => path,
          "nonce"   => nonce
        }
      )
  end
end
