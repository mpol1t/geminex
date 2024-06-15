defmodule Geminex.Config do
  @moduledoc """
  Configuration for Gemini API.
  """
  @sandbox_url    "https://api.sandbox.gemini.com"
  @production_url "https://api.gemini.com"

  def api_url(:sandbox),    do: @sandbox_url
  def api_url(:production), do: @production_url
end
