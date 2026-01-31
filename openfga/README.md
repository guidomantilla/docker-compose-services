# OpenFGA Stack

## Servicios

| Servicio | Puerto | `restart:` | Funcion |
|----------|--------|-----------|---------|
| openfga-migrate | — | `no` | Migracion de schema (one-shot) |
| openfga-server | 8280, 8281, 3200 | `no` | Servidor de autorizacion |

## Dependencias

```
openfga-migrate (exits after completion)
  └─→ openfga-server (waits for service_completed_successfully)
```

## Puertos

- `8280:8080` — HTTP API
- `8281:8081` — gRPC API
- `3200:3000` — Playground UI

## Almacenamiento

SQLite en bind mount (`${OPENFGA_VOLUME_DIR:-./volume}:/home/nonroot`). Ambos servicios comparten el mismo volumen.
