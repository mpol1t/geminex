defmodule Geminex.Middleware.DynamicBaseUrl do
  @moduledoc false
  @behaviour Tesla.Middleware

  @sandbox_url    "https://api.sandbox.gemini.com"
  @production_url "https://api.gemini.com"

  @impl true
  def call(%Tesla.Env{url: url} = env, next, _opts) do
    Tesla.run(%Tesla.Env{ env | url: base_url() <> url}, next)
  end

  def base_url, do: Application.fetch_env!(:geminex, :environment) |> match_env()

  defp match_env(:sandbox),     do: @sandbox_url
  defp match_env(:production),  do: @production_url
end
