use metrics_exporter_prometheus::PrometheusBuilder;
use std::net::SocketAddr;
use tokio::sync::oneshot;
use tracing::{debug, error, info};

/// Prometheus metrics exporter that serves metrics via HTTP
pub struct MetricsExporter {
    bind_address: String,
    shutdown_sender: Option<oneshot::Sender<()>>,
}

impl MetricsExporter {
    /// Create and start a new metrics exporter
    pub async fn new(bind_address: String) -> eyre::Result<Self> {
        let addr: SocketAddr = bind_address.parse()
            .map_err(|e| eyre::eyre!("Invalid bind address '{}': {}", bind_address, e))?;

        info!("Setting up Prometheus metrics exporter on http://{}/metrics", addr);

        // Set up the Prometheus exporter with custom configuration
        let builder = PrometheusBuilder::new()
            .with_http_listener(addr)
            .add_global_label("service", "state_bridge")
            .add_global_label("version", env!("CARGO_PKG_VERSION"));

        let handle = builder
            .install()
            .map_err(|e| eyre::eyre!("Failed to install Prometheus exporter: {}", e))?;

        info!("Prometheus metrics server started on http://{}/metrics", addr);
        debug!("Metrics handle: {:?}", handle);

        Ok(Self {
            bind_address,
            shutdown_sender: None,
        })
    }

    /// Get the bind address
    pub fn bind_address(&self) -> &str {
        &self.bind_address
    }

    /// Shutdown the metrics exporter
    pub fn shutdown(mut self) {
        if let Some(sender) = self.shutdown_sender.take() {
            if sender.send(()).is_err() {
                error!("Failed to send shutdown signal to metrics exporter");
            } else {
                info!("Metrics exporter shutdown signal sent");
            }
        }
    }
}

impl Drop for MetricsExporter {
    fn drop(&mut self) {
        if let Some(sender) = self.shutdown_sender.take() {
            let _ = sender.send(());
        }
    }
}

/// Health check endpoint data
#[derive(Debug, serde::Serialize)]
pub struct HealthStatus {
    pub status: String,
    pub service: String,
    pub version: String,
    pub uptime_seconds: f64,
    pub metrics_endpoint: String,
}

impl HealthStatus {
    pub fn healthy(uptime_seconds: f64, metrics_endpoint: String) -> Self {
        Self {
            status: "healthy".to_string(),
            service: "state_bridge".to_string(),
            version: env!("CARGO_PKG_VERSION").to_string(),
            uptime_seconds,
            metrics_endpoint,
        }
    }
}

/// Utility function to get current metrics as text (for debugging)
pub async fn get_metrics_text() -> String {
    use prometheus::{TextEncoder, gather};
    
    let encoder = TextEncoder::new();
    let metric_families = gather();
    
    match encoder.encode_to_string(&metric_families) {
        Ok(text) => text,
        Err(e) => {
            error!("Failed to encode metrics: {}", e);
            format!("# Error encoding metrics: {}\n", e)
        }
    }
} 