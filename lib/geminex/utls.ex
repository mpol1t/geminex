defmodule Geminex.Utils do
  # Helper function to conditionally add fields to the payload map
  def maybe_put(map, _key, nil),   do: map
  def maybe_put(map,  key, value), do: Map.put(map, key, value)

  # Helper function to conditionally add fields to the payload map
  def maybe_put_keyword(xs, _key, nil),   do: xs
  def maybe_put_keyword(xs,  key, value), do: Keyword.put(xs, key, value)

  # Helper function to handle responses
  def handle_response({:ok, %Tesla.Env{status: s, body: b}}) when s in 200..299, do: {:ok, b}
  def handle_response({:ok, %Tesla.Env{status: s, body: b}}),                    do: {:error, %{status: s, body: b}}
  def handle_response({:error, reason}),                                         do: {:error, reason}


  def handle_binary_response({:ok, %Tesla.Env{status: s, body: b}}) when s in 200..299,  do: {:ok, b}
  def handle_binary_response({:ok, %Tesla.Env{status: s, body: b}}),                     do: {:error, %{status: s, body: b}}
  def handle_binary_response({:error, reason}),                                          do: {:error, reason}
end