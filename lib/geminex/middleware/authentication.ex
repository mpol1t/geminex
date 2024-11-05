defmodule Geminex.Middleware.Authentication do
  @moduledoc false
  @behaviour Tesla.Middleware

  @impl true
  def call(env, next, _opts) do
    api_key = Application.fetch_env!(:geminex, :api_key)
    api_secret = Application.fetch_env!(:geminex, :api_secret)

    nonce = :os.system_time(:millisecond)

    # Build the payload
    payload = build_payload(env, nonce)

    encoded_payload = Jason.encode!(payload) |> Base.encode64()

    signature =
      :crypto.mac(:hmac, :sha384, api_secret, encoded_payload) |> Base.encode16(case: :lower)

    # Add authentication headers
    headers = [
      {"X-GEMINI-APIKEY", api_key},
      {"X-GEMINI-PAYLOAD", encoded_payload},
      {"X-GEMINI-SIGNATURE", signature},
      {"Content-Type", "text/plain"},
      {"Content-Length", "0"},
      {"Cache-Control", "no-cache"}
    ]

    env = %{env | headers: headers ++ env.headers, body: ""}

    Tesla.run(env, next)
  end

  defp build_payload(env, nonce) do
    path = URI.parse(env.url).path

    # Merge body params if present
    body_params =
      case env.body do
        %{} = body  -> body
        _           -> %{}
      end

    Map.merge(
      %{
        "request" => path,
        "nonce" => nonce
      },
      body_params
    )
  end
end
