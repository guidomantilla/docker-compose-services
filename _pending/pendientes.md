# Stacks Pendientes por Crear

## Grafana Loki Stack

Reemplazo liviano de ELK para logging centralizado.

**Componentes:**
- **Loki** — almacena y procesa queries de logs
- **Alloy** — agente que recolecta logs y los envía a Loki (reemplaza a Promtail)
- **Grafana** — UI para visualizar y buscar logs

**Por qué:** ELK es demasiado pesado para desarrollo local (4-6GB RAM). Loki stack consume ~500MB y se integra con el OTEL Collector del stack de telemetry que ya existe.

**Referencia:** https://grafana.com/docs/loki/latest/
