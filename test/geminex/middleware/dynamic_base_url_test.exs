defmodule Test.Geminex.Middleware.DynamicBaseUrlTest do
  use ExUnit.Case, async: true

  alias Geminex.Middleware.DynamicBaseUrl

  setup do
    original_env = Application.get_env(:geminex, :environment)
    on_exit(fn -> Application.put_env(:geminex, :environment, original_env) end)
    {:ok, environment: original_env}
  end

  describe "base_url/0" do
    test "returns sandbox URL when :sandbox config flag is used", %{environment: _original_env} do
      Application.put_env(:geminex, :environment, :sandbox)
      assert DynamicBaseUrl.base_url() == "https://api.sandbox.gemini.com"
    end

    test "returns production URL when :production config flag is used", %{
      environment: _original_env
    } do
      Application.put_env(:geminex, :environment, :production)
      assert DynamicBaseUrl.base_url() == "https://api.gemini.com"
    end

    test "raises error for unexpected environment value", %{environment: _original_env} do
      Application.put_env(:geminex, :environment, :invalid)

      assert_raise FunctionClauseError, fn ->
        DynamicBaseUrl.base_url()
      end
    end
  end
end
