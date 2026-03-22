defmodule Test.Geminex.Middleware.AuthenticationTest do
  use ExUnit.Case, async: false

  import Mox

  alias Geminex.API.Private

  setup :set_mox_from_context
  setup :verify_on_exit!

  test "uses second-based nonce" do
    expect(Geminex.MockAdapter, :call, fn env, _opts ->
      {_, encoded_payload} = List.keyfind(env.headers, "X-GEMINI-PAYLOAD", 0)
      {:ok, decoded_payload} = Base.decode64(encoded_payload)
      {:ok, payload} = Jason.decode(decoded_payload)

      nonce = payload["nonce"]
      now = System.os_time(:second)

      assert is_integer(nonce)
      assert nonce <= now
      assert nonce >= now - 5

      {:ok, %Tesla.Env{status: 200, body: "[]"}}
    end)

    assert {:ok, "[]"} = Private.active_orders()
  end
end
