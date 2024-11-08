defmodule Test.Geminex.UtilsTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Geminex.Utils

  @max_runs 100

  describe "maybe_put/3" do
    property "returns the same map when value is nil" do
      check all(
              map <- map_with_standard_keys_and_values(),
              key <- standard_key(),
              max_runs: @max_runs
            ) do
        assert Utils.maybe_put(map, key, nil) == map
      end
    end

    property "inserts or updates key-value pair only if value is non-nil, preserving other entries" do
      check all(
              map <- map_with_standard_keys_and_values(),
              key <- standard_key(),
              value <- standard_value(),
              max_runs: @max_runs
            ) do
        result = Utils.maybe_put(map, key, value)

        # Assert the new or updated key-value pair is in the result
        assert result[key] == value

        # Verify that all other entries remain unchanged
        assert Enum.all?(map, fn {k, v} -> k == key or result[k] == v end)
      end
    end
  end

  describe "merge_map_with_string_keys/2" do
    property "adds or replaces entries in map using stringified keys from keyword_list" do
      check all(
              map <- map_of(StreamData.string(:alphanumeric), StreamData.integer()),
              xs <- map_of(StreamData.atom(:alphanumeric), StreamData.integer()),
              max_runs: @max_runs
            ) do
        keyword_list = Enum.into(xs, [])
        result = Utils.merge_map_with_string_keys(map, keyword_list)

        # Assert that all keys in keyword_list appear in result as stringified keys
        Enum.each(keyword_list, fn {k, v} ->
          assert result[Atom.to_string(k)] == v
        end)
      end
    end

    property "keeps all non-conflicting keys from the original map intact" do
      check all(
              map <- map_of(StreamData.string(:alphanumeric), StreamData.integer()),
              xs <- map_of(StreamData.atom(:alphanumeric), StreamData.integer()),
              max_runs: @max_runs
            ) do
        keyword_list = Enum.into(xs, [])
        result = Utils.merge_map_with_string_keys(map, keyword_list)

        Enum.each(map, fn {k, v} ->
          unless Enum.any?(keyword_list, fn {kw_key, _} -> Atom.to_string(kw_key) == k end) do
            assert result[k] == v
          end
        end)
      end
    end

    property "returns identical results on multiple calls (idempotent)" do
      check all(
              map <- map_of(StreamData.string(:alphanumeric), StreamData.integer()),
              xs <- map_of(StreamData.atom(:alphanumeric), StreamData.integer()),
              max_runs: @max_runs
            ) do
        keyword_list = Enum.into(xs, [])
        result_1 = Utils.merge_map_with_string_keys(map, keyword_list)
        result_2 = Utils.merge_map_with_string_keys(result_1, keyword_list)

        assert result_1 == result_2
      end
    end

    property "returns only keyword_list entries as strings when map is empty" do
      check all(
              xs <- map_of(StreamData.atom(:alphanumeric), StreamData.integer()),
              max_runs: @max_runs
            ) do
        keyword_list = Enum.into(xs, [])
        result = Utils.merge_map_with_string_keys(%{}, keyword_list)

        # Result should contain only entries from keyword_list with stringified keys
        assert Enum.count(result) == Enum.count(keyword_list)

        Enum.each(keyword_list, fn {k, v} ->
          assert result[Atom.to_string(k)] == v
        end)
      end
    end

    property "preserves map entries when keyword_list is empty" do
      check all(
              map <- map_of(StreamData.binary(), StreamData.integer()),
              max_runs: @max_runs
            ) do
        result = Utils.merge_map_with_string_keys(map, [])

        assert result == map
      end
    end
  end

  describe "handle_response/1" do
    property "returns {:ok, body} for successful status codes (200-299)" do
      check all(
              status <- StreamData.integer(200..299),
              body <- term(),
              max_runs: @max_runs
            ) do
        response = {:ok, %Tesla.Env{status: status, body: body}}
        assert Utils.handle_response(response) == {:ok, body}
      end
    end

    property "returns {:error, %{status: status, body: body}} for non-2xx status codes" do
      check all(
              status <- one_of([StreamData.integer(100..199), StreamData.integer(300..599)]),
              body <- term(),
              max_runs: @max_runs
            ) do
        response = {:ok, %Tesla.Env{status: status, body: body}}
        assert Utils.handle_response(response) == {:error, %{status: status, body: body}}
      end
    end

    property "returns {:error, reason} for client errors" do
      check all(
              reason <- term(),
              max_runs: @max_runs
            ) do
        response = {:error, reason}
        assert Utils.handle_response(response) == {:error, reason}
      end
    end
  end

  describe "handle_binary_response/1" do
    property "returns {:ok, body} for successful status codes (200-299)" do
      check all(
              status <- StreamData.integer(200..299),
              body <- term(),
              max_runs: @max_runs
            ) do
        response = {:ok, %Tesla.Env{status: status, body: body}}
        assert Utils.handle_binary_response(response) == {:ok, body}
      end
    end

    property "returns {:error, %{status: status, body: body}} for non-2xx status codes" do
      check all(
              status <- one_of([StreamData.integer(100..199), StreamData.integer(300..599)]),
              body <- term(),
              max_runs: @max_runs
            ) do
        response = {:ok, %Tesla.Env{status: status, body: body}}
        assert Utils.handle_binary_response(response) == {:error, %{status: status, body: body}}
      end
    end

    property "returns {:error, reason} for client errors" do
      check all(
              reason <- term(),
              max_runs: @max_runs
            ) do
        response = {:error, reason}
        assert Utils.handle_binary_response(response) == {:error, reason}
      end
    end
  end

  # Helper functions to generate standard key/value types for maps
  defp map_with_standard_keys_and_values do
    map_of(standard_key(), standard_value())
  end

  defp standard_key do
    one_of([StreamData.atom(:alphanumeric), StreamData.binary(), StreamData.integer()])
  end

  defp standard_value do
    one_of([StreamData.atom(:alphanumeric), StreamData.binary(), StreamData.integer()])
  end
end
