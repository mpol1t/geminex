ExUnit.start()
Mox.defmock(HTTPoisonMock, for: HTTPoison.Base)
Application.put_env(:geminex, :http_client, HTTPoisonMock)
