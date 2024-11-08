ExUnit.start()

{:ok, _} = Application.ensure_all_started(:mox)
{:ok, _} = Application.ensure_all_started(:tesla)

Application.put_env(:tesla, :adapter, Geminex.MockAdapter)

# Load support files
Path.join(__DIR__, "support/**/*.exs")
|> Path.wildcard()
|> Enum.each(&Code.require_file/1)
