defmodule Geminex.Utils do
  @moduledoc """
  Utility functions for handling common tasks within the Geminex library.

  This module provides helper functions to manage payload transformations,
  handle HTTP responses, and merge maps with keyword lists.
  """

    @doc """
  Conditionally adds a key-value pair to a map if the value is not **nil**.

  ## Parameters

    - **map**: The original map to which the key-value pair may be added.
    - **key**: The key to be added to the map.
    - **value**: The value to be associated with the key. If this is **nil**, the key-value pair is not added.

  ## Returns

    - The original map if **value** is **nil**, or a new map with the key-value pair added if **value** is not **nil**.

  ## Examples

      iex> Utils.maybe_put(%{"a" => 1}, "b", 2)
      %{"a" => 1, "b" => 2}

      iex> Utils.maybe_put(%{"a" => 1}, "b", nil)
      %{"a" => 1}

  """
  @spec maybe_put(map(), any(), any()) :: map()
  def maybe_put(map, _key, nil),   do: map
  def maybe_put(map,  key, value), do: Map.put(map, key, value)

  @doc """
  Handles HTTP responses by returning **{:ok, body}** for successful responses or **{:error, reason}** for failures.

  ## Parameters

    - **response**: The HTTP response tuple returned by the Tesla client.

  ## Returns

    - **{:ok, body}** if the HTTP status is in the 200–299 range.
    - **{:error, %{status: status, body: body}}** if the status is outside of the success range.
    - **{:error, reason}** if there is a client error.

  ## Examples

      iex> Utils.handle_response({:ok, %Tesla.Env{status: 200, body: %{"result" => "success"}}})
      {:ok, %{"result" => "success"}}

      iex> Utils.handle_response({:ok, %Tesla.Env{status: 400, body: %{"error" => "invalid_request"}}})
      {:error, %{status: 400, body: %{"error" => "invalid_request"}}}

      iex> Utils.handle_response({:error, :timeout})
      {:error, :timeout}

  """
  @spec handle_response({:ok, Tesla.Env.t()} | {:error, any()}) :: {:ok, any()} | {:error, any()}
  def handle_response({:ok, %Tesla.Env{status: s, body: b}}) when s in 200..299, do: {:ok, b}
  def handle_response({:ok, %Tesla.Env{status: s, body: b}}),                    do: {:error, %{status: s, body: b}}
  def handle_response({:error, reason}),                                         do: {:error, reason}

  def handle_binary_response({:ok, %Tesla.Env{status: s, body: b}}) when s in 200..299,  do: {:ok, b}
  def handle_binary_response({:ok, %Tesla.Env{status: s, body: b}}),                     do: {:error, %{status: s, body: b}}
  def handle_binary_response({:error, reason}),                                          do: {:error, reason}

  @doc """
  Merges a map with a keyword list, ensuring all keys from the keyword list are converted to strings.

  ## Parameters

    - **map**: The base map to merge into.
    - **keyword_list**: A keyword list with atom keys that need to be converted to strings.

  ## Returns

    - A new map with all keys from **keyword_list** as strings, merged into **map**.

  ## Examples

      iex> Utils.merge_map_with_string_keys(%{"a" => 1, "b" => 2}, [a: 10, c: 3])
      %{"a" => 10, "b" => 2, "c" => 3}

  """
  @spec merge_map_with_string_keys(map(), keyword()) :: map()
  def merge_map_with_string_keys(map, keyword_list) do
    string_key_map =
      keyword_list
      |> Enum.map(fn {key, value} -> {Atom.to_string(key), value} end)
      |> Enum.into(%{})

    Map.merge(map, string_key_map)
  end
end