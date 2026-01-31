# Telemetry Stack

## Servicios

| Servicio | Puerto | `restart:` | Funcion |
|----------|--------|-----------|---------|
| telemetry-otel-collector | 4317, 4318, 8888, 8889, 1888, 13133, 55679 | `unless-stopped` | Collector principal |
| telemetry-jaeger | 16686, 14250 | `unless-stopped` | Traces UI |
| telemetry-prometheus | 9090 | `unless-stopped` | Metricas |
| telemetry-loki | 3100 | `unless-stopped` | Almacen de logs |
| telemetry-grafana | 3000 | `unless-stopped` | UI unificada |
| telemetry-alloy | 12345, 14317, 14318 | `no` | Collector secundario |

## Integraciones

```
                    ┌─→ Jaeger (traces)
OTEL Collector ────┼─→ Prometheus (metricas)
  (principal)       └─→ Loki (logs)

                    ┌─→ Jaeger (traces)
Alloy ─────────────┼─→ Prometheus (metricas)
  (restart: no)     └─→ Loki (logs)

Grafana ──── lee de ──→ Loki + Prometheus + Jaeger
```

## Archivos de configuracion

| Archivo | Usado por | Descripcion |
|---------|-----------|-------------|
| `otel-collector-config.yaml` | otel-collector | Receivers, exporters y pipelines (traces, metricas, logs) |
| `prometheus-config.yaml` | prometheus | Scrape targets (otel-collector metrics) |
| `loki-config.yaml` | loki | Modo filesystem, schema v13, sin auth |
| `grafana-datasources.yaml` | grafana | Auto-provisioning de datasources (Loki, Prometheus, Jaeger) |
| `alloy-config.alloy` | alloy | Mismas integraciones que OTEL pero en sintaxis Alloy |
