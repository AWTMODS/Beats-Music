/// Shared async HTTP client for WASM plugin host functions.
///
/// All plugin adapters need to perform HTTP requests from inside synchronous
/// WIT host function callbacks. Because these callbacks execute within an
/// existing Tokio runtime (provided by flutter_rust_bridge), using
/// `reqwest::blocking` — which tries to spin up its own runtime — causes a
/// panic: "Cannot start a runtime from within a runtime".
///
/// The solution is a single shared `reqwest::Client` (async, not blocking)
/// combined with `tokio::task::block_in_place`, which parks the current
/// thread and runs the future on the existing multi-threaded Tokio executor
/// without creating a nested runtime.

use once_cell::sync::Lazy;

/// Global async HTTP client shared across all plugin adapters.
/// `reqwest::Client` is cheaply cloneable (backed by an `Arc`), so a single
/// instance avoids redundant connection-pool and TLS-session creation.
static ASYNC_HTTP_CLIENT: Lazy<reqwest::Client> = Lazy::new(|| {
    reqwest::Client::builder()
        .user_agent(
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) \
             AppleWebKit/537.36 (KHTML, like Gecko) \
             Chrome/124.0.0.0 Safari/537.36",
        )
        .timeout(std::time::Duration::from_secs(30))
        .build()
        .unwrap_or_else(|_| reqwest::Client::new())
});

/// Response returned to callers — mirrors the WIT `http-response` record.
pub struct PluginHttpResponse {
    pub status: u16,
    pub headers: Vec<(String, String)>,
    pub body: Vec<u8>,
}

/// Execute an HTTP request from within a synchronous WIT host-function context.
///
/// # Parameters
/// * `url`             — destination URL
/// * `method`          — HTTP method (already converted to `reqwest::Method`)
/// * `headers`         — optional request headers
/// * `body`            — optional raw request body bytes
/// * `timeout_seconds` — per-request timeout cap (max 30 s)
///
/// # Async / blocking bridge
/// Uses `tokio::task::block_in_place` so the Tokio worker thread is donated
/// to this blocking wait without stalling the scheduler.  This requires the
/// **`rt-multi-thread`** Tokio runtime, which FRB already activates.
pub fn execute_http_request(
    url: String,
    method: reqwest::Method,
    headers: Option<Vec<(String, String)>>,
    body: Option<Vec<u8>>,
    timeout_seconds: Option<u32>,
) -> Result<PluginHttpResponse, String> {
    tokio::task::block_in_place(|| {
        tokio::runtime::Handle::current().block_on(async {
            let mut req = ASYNC_HTTP_CLIENT.request(method, &url);

            if let Some(secs) = timeout_seconds {
                let capped = secs.min(30);
                req = req.timeout(std::time::Duration::from_secs(capped as u64));
            }

            if let Some(hdrs) = headers {
                for (k, v) in hdrs {
                    req = req.header(k, v);
                }
            }

            if let Some(b) = body {
                req = req.body(b);
            }

            let resp = req.send().await.map_err(|e| {
                format!(
                    "HTTP GET failed: error sending request for url ({}): {}",
                    url, e
                )
            })?;

            let status = resp.status().as_u16();
            let out_headers: Vec<(String, String)> = resp
                .headers()
                .iter()
                .map(|(k, v)| {
                    (
                        k.as_str().to_string(),
                        v.to_str().unwrap_or("").to_string(),
                    )
                })
                .collect();
            let body_bytes = resp
                .bytes()
                .await
                .map_err(|e| format!("Failed to read response body: {}", e))?
                .to_vec();

            Ok(PluginHttpResponse {
                status,
                headers: out_headers,
                body: body_bytes,
            })
        })
    })
}
