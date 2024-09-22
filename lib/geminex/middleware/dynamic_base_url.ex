defmodule Geminex.Middleware.DynamicBaseUrl do
  @moduledoc false
  @behaviour Tesla.Middleware

  @sandbox_url "https://api.sandbox.gemini.com"
  @production_url "https://api.gemini.com"

  @impl true
  def call(env, next, _opts) do
    base_url = :geminex |> Application.get_env(:environment, @sandbox_url) |> match_env()
    env_url = env.url

    # Ensure the base URL does not have a trailing slash
    base_url = String.trim_trailing(base_url, "/")
    # Ensure the path starts with a slash
    env_url = if String.starts_with?(env_url, "/"), do: env_url, else: "/" <> env_url

    # Concatenate the base URL and the path
    env = %{env | url: base_url <> env_url}
    Tesla.run(env, next)
  end

  defp match_env(:sandbox), do: @sandbox_url
  defp match_env(:production), do: @production_url
  defp match_env(_), do: @sandbox_url
end
