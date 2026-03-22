# Docker Compose Services

> 25 service stacks for local development (updated 2026-03-22).

---

## 1. Active Stacks

| # | Directory | Image | Ports | `restart:` |
|---|-----------|-------|-------|------------|
| 1 | `airflow/` | `apache/airflow:3.1.8` | 8380 | no |
| 2 | `clickhouse/` | `clickhouse/clickhouse-server:25.3` | 8123, 9000 | no |
| 3 | `debezium/` | `debezium/connect:3.0.0.Final` + `debezium/server:3.0.0.Final` | 8083, 8084 | no |
| 4 | `gcp-pubsub/` | `google-cloud-cli:emulators` | 8085 | no |
| 5 | `keycloak/` | `quay.io/keycloak/keycloak:26.5.2` | 8180 | no |
| 6 | `localstack-pro/` | `localstack/localstack-pro:4` | 4566, 4510-4559, 9443 | no |
| 7 | `mailhog/` | `mailhog/mailhog:v1.0.1` | 1025, 8025 | no |
| 8 | `metabase/` | `metabase/metabase:v0.53.18` | 3300 | no |
| 9 | `mongo/` | `mongo:8.2.3` | 27017 | no |
| 10 | `n8n/` | `n8nio/n8n:2.4.8` | 5678 | no |
| 11 | `neo4j/` | `neo4j:2026.02.3-community` | 7474, 7687 | no |
| 12 | `openfga/` | `openfga/openfga:v1.11.3` | 8280, 8281, 3200 | no |
| 13 | `oracle-23ai/` | `gvenzl/oracle-free:23-slim` | 1521 | no |
| 14 | `pinot/` | `apachepinot/pinot:1.4.0` | 9100, 8000 | no |
| 15 | `postgres/` | `postgres:18` | 15432 | no |
| 16 | `rabbitmq/` | `rabbitmq:management` | 5672, 15672 | no |
| 17 | `redis/` | `redis/redis-stack:7.4.0-v3` | 6379, 8001 | **unless-stopped** |
| 18 | `redpanda/` | `redpandadata/redpanda:v25.3.4` + `console:v3.3.2` | 19092, 18081, 18082, 19644, 8080 | **unless-stopped** |
| 19 | `sonarqube/` | `sonarqube:community` + `postgres:18` | 9200 | no |
| 20 | `sql-server-2022/` | `mssql/server:2022-latest` | 1433 | no |
| 21 | `superset/` | `apache/superset:latest` | 8088 | no |
| 22 | `telemetry/` | otel-collector, jaeger, prometheus, loki, grafana, alloy | 4317, 4318, 8888, 9090, 3000, 3100, 16686, ... | **unless-stopped** |
| 23 | `temporal/` | `temporalio/temporal:latest` | 7233, 8233 | no |
| 24 | `timescaledb/` | `timescale/timescaledb-ha:pg17` | 5432 | **unless-stopped** |
| 25 | `versitygw/` | `versity/versitygw:v1.3.1` | 7070, 7071 | no |

**Non-tracked:** `supabase/` (cloned from official repo, in `.gitignore`, for architecture reference only).

---

## 2. services-up

Stacks with `restart: unless-stopped` auto-start with OrbStack and are included in the `services-up` alias:

| Stack | Purpose | RAM |
|-------|---------|-----|
| **redis** | Cache, sessions | ~130 MB |
| **redpanda** | Event streaming (Kafka API compatible) | ~670 MB |
| **telemetry** | Observability (otel-collector + jaeger only in services-up) | ~50 MB |
| **timescaledb** | Primary PostgreSQL 17 + 50+ extensions | ~75 MB |

All other stacks use `restart: no` and are started on demand via individual aliases (e.g., `CLICKHOUSE_STACK_UP`).

---

## 3. Port Remapping

Most stacks use default ports. Remaps exist only where ports collide:

### Port `8080` — redpanda-console owns it

| Stack | Host Port | Offset | Reason |
|-------|-----------|--------|--------|
| redpanda-console | 8080 | default | — |
| keycloak | 8180 | +100 | collides with redpanda-console |
| openfga | 8280 | +200 | collides with redpanda-console |
| airflow | 8380 | +300 | collides with redpanda-console |

### Port `3000` — grafana owns it

| Stack | Host Port | Offset | Reason |
|-------|-----------|--------|--------|
| telemetry-grafana | 3000 | default | — |
| openfga (playground) | 3200 | +200 | collides with grafana |
| metabase | 3300 | +300 | collides with grafana |

### Port `9000` — clickhouse owns it

| Stack | Host Port | Offset | Reason |
|-------|-----------|--------|--------|
| clickhouse (native) | 9000 | default | — |
| pinot (controller UI) | 9100 | +100 | collides with clickhouse |
| sonarqube | 9200 | +200 | collides with clickhouse |

### Port `5432` — timescaledb owns it

| Stack | Host Port | Reason |
|-------|-----------|--------|
| timescaledb | 5432 | primary PostgreSQL |
| postgres | 15432 | secondary, vanilla PostgreSQL |

### Redpanda external ports (official defaults, NOT remaps)

`19092` (Kafka API), `18081` (Schema Registry), `18082` (Pandaproxy), `19644:9644` (Admin API) — these are Redpanda's official external listener ports per [docs.redpanda.com](https://docs.redpanda.com/redpanda-labs/docker-compose/single-broker/).

### Intentional remaps

| Stack | Host Port | Reason |
|-------|-----------|--------|
| telemetry-alloy | 14317, 14318 | collides with otel-collector (same stack) |
| localstack | 9443:443 | privileged port |
| debezium-server | 8084:8080 | collides with redpanda-console |

---

## 4. Standards

### Image Tags

- **Never use `:latest`**. Always pin to a specific version.
- `:latest` is non-deterministic — a `docker pull` can silently upgrade and break your stack.
- Exception: images that only publish `:latest` with no version tags (e.g., `apache/superset`, `temporalio/temporal`).

### Compose File Naming

`{service-name}-stack-compose.yml` — e.g., `postgres-stack-compose.yml`.

### YAML Key Order (per service)

```
container_name → image → platform → restart → depends_on → ports → environment → command → working_dir → volumes → networks
```

### Environment Variables

- Credentials: from `.envrc` via `"${SHELL_VAR}"` — never hardcoded in YAML.
- Service config (non-secret): hardcoded in YAML is acceptable.
- Format: map format (`KEY: "value"`), never list format (`- KEY=value`).

### Volumes

- Persistent data: `${STACK_VOLUME_DIR}/subpath:/container/path`.
- Init/config files: `${STACK_HOME}/file:/container/path`.
- Default fallback: `:-./volume` for development without `.envrc`.
- Every `volume/` directory has a `.gitkeep`. Data inside is excluded via `.gitignore`.

### Restart Policy

- `unless-stopped`: only for stacks in `services-up` (always running).
- `no`: everything else (started on demand).

### Platform

- Default: `linux/arm64` (Apple Silicon).
- Exception: `linux/amd64` for images without ARM64 support (mailhog, sql-server, gcp-pubsub).

### Networks

- Each stack has its own bridge network: `{stack}-network`.
- Cross-network access only when a stack needs to communicate with another (e.g., debezium accesses redpanda-network and timescaledb-network).

### `.envrc` Structure

- Alphabetically ordered sections, one per stack.
- Each section: aliases (`_STACK_UP/STOP/DOWN`) + env vars.
- `_SERVICES_UP_LIST` at the bottom: array of stacks for bulk `services-up/stop/down`.
- `.envrc.example`: same structure, passwords empty.

---

## 5. Deprecated & Pending

### `_deprecated/`

arangodb, cockroachdb, druid, elk, influxdb, kafka, metabase (old), minio, porchpass, scylladb, temporal (full), yumbrands.

### `_pending/`

Empty. All stacks have been promoted or deprecated.

### `supabase/`

Cloned from official repo for architecture reference (13 microservices). Excluded from git via `.gitignore`. Not a managed stack.
