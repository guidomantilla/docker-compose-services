# Redpanda Stack

## Servicios

| Servicio | Puerto | `restart:` | Funcion |
|----------|--------|-----------|---------|
| redpanda-broker | 19092, 18081, 18082, 19644 | `unless-stopped` | Broker de mensajes (compatible con Kafka API) |
| redpanda-console | 18080 | `unless-stopped` | UI de administracion |

## Dependencias

```
redpanda-broker
  └─→ redpanda-console
```

## Puertos

Todos remapeados con prefijo `1` para evitar conflicto con kafka:

- `19092:19092` — Kafka API (external)
- `18081:18081` — Schema Registry
- `18082:18082` — HTTP Proxy (Pandaproxy)
- `19644:9644` — Admin API
- `18080:8080` — Console UI

## Nota

Corre en modo `dev-container` con 1 core (`--smp 1`).
