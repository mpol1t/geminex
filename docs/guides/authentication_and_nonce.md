# Authentication and Nonce

Private requests are signed by `Geminex.Middleware.Authentication`.

## Signature flow

1. Build payload with request path and nonce.
2. JSON encode payload.
3. Base64 encode payload.
4. Sign encoded payload with HMAC-SHA384 using API secret.
5. Attach Gemini headers:
   - `X-GEMINI-APIKEY`
   - `X-GEMINI-PAYLOAD`
   - `X-GEMINI-SIGNATURE`

## Nonce

Nonce is generated from:

- `System.os_time(:second)`

This keeps nonce precision simple and stable for production/sandbox private calls.
