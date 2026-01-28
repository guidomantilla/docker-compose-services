# Docker Compose Standards & Analysis

> Analysis of the 21 active service stacks in this repository (updated 2026-03-22).
> Use this document as reference for standardization work on a case-by-case basis.

---

## Table of Contents

1. [Active Stacks Inventory](#1-active-stacks-inventory)
2. [Current Pattern Analysis](#2-current-pattern-analysis)
3. [Inconsistencies Detected](#3-inconsistencies-detected)
4. [Per-Stack Detail](#4-per-stack-detail)
5. [Proposed Template](#5-proposed-template)
6. [Standardization Checklist](#6-standardization-checklist)

---

## 1. Active Stacks Inventory

| # | Directory | Compose File | Type | Services |
|---|-----------|-------------|------|----------|
| 1 | `clickhouse/` | `clickhouse-stack-compose.yml` | Single | clickhouse-server |
| 2 | `gcp-pubsub/` | `gcp-pubsub-stack-compose.yml` | Single | gcp-pubsub-server |
| 3 | `keycloak/` | `keycloak-stack-compose.yml` | Single | keycloak-server |
| 4 | `localstack-pro/` | `localstack-pro-stack-compose.yml` | Single | localstack-pro-server |
| 5 | `mailhog/` | `mailhog-stack-compose.yml` | Single | mailhog-server |
| 6 | `metabase/` | `metabase-stack-compose.yml` | Single | metabase-server |
| 7 | `mongo/` | `mongo-stack-compose.yml` | Single | mongo-server |
| 8 | `n8n/` | `n8n-stack-compose.yml` | Single | n8n-server |
| 9 | `openfga/` | `openfga-stack-compose.yml` | Multi-service | openfga-migrate, openfga-server |
| 10 | `oracle-23ai/` | `oracle-23ai-stack-compose.yml` | Single | oracle-23ai-server |
| 11 | `postgres/` | `postgres-stack-compose.yml` | Single | postgres-server |
| 12 | `rabbitmq/` | `rabbitmq-stack-compose.yml` | Single | rabbitmq-server |
| 13 | `redis/` | `redis-stack-compose.yml` | Single | redis-server |
| 14 | `redpanda/` | `redpanda-stack-compose.yml` | Multi-service | redpanda-broker, redpanda-console |
| 15 | `sonarqube/` | `sonarqube-stack-compose.yml` | Multi-service | sonarqube-server, sonarqube-postgres |
| 16 | `sql-server-2022/` | `sql-server-2022-stack-compose.yml` | Single | sqlserver-2022-server |
| 17 | `superset/` | `superset-stack-compose.yml` | Single | superset-server |
| 18 | `telemetry/` | `telemetry-stack-compose.yml` | Multi-service | telemetry-otel-collector, telemetry-jaeger, telemetry-prometheus, telemetry-loki, telemetry-grafana, telemetry-alloy |
| 19 | `temporal/` | `temporal-dev-stack-compose.yml` | Single | temporal-dev-server |
| 20 | `timescaledb/` | `timescaledb-stack-compose.yml` | Single | timescaledb-server |
| 21 | `versitygw/` | `versitygw-stack-compose.yml` | Single | versitygw-server |

---

## 2. Current Pattern Analysis

### 2.1 What IS Already Consistent (17/17 stacks)

| Aspect | Pattern |
|--------|---------|
| File naming | `{servicio}-stack-compose.yml` |
| No `version:` key | All use implicit Compose v2+ |
| `container_name:` explicit | Always present on every service |
| Named bridge network | `{stack}-network` with `driver: bridge` |
| One network per stack | All services within a stack share the same network |
| YAML key order | `container_name` -> `image` -> `platform` -> `restart` -> `ports` -> `environment` -> `volumes` -> `networks` |

### 2.2 Dominant Patterns (majority of stacks)

| Aspect | Dominant Pattern | Adoption |
|--------|-----------------|----------|
| `restart:` | `unless-stopped` | 17/17 (openfga-migrate uses `no` — one-shot task) |
| `platform:` | `linux/arm64` | 15/17 (sql-server: amd64; mailhog: amd64) |
| Environment vars | Map format, shell substitution from `.envrc` (`"${VAR}"`) for credentials | 17/17 |
| Volumes | Bind mounts with `${SERVICE_VOLUME_DIR}/path:/container/path` | 13/17 |
| Image tags | `:latest` | 15/17 (sql-server uses `2022-latest`, rabbitmq uses `management`) |

### 2.3 What Is NOT Present (0/17 stacks) — Out of Scope

The following features are absent across all stacks. They are **out of scope** for this standardization effort — this is a local development environment, not production infrastructure.

- **Healthchecks** — Would require case-by-case implementation (each service has a different health command).
- **Resource limits** (`deploy.resources`) — Not necessary for local development.
- **Logging config** (`logging:`) — Not necessary for local development.
- **Docker secrets** — Not supported by all images; minimal benefit for local development.

---

## 3. Inconsistencies Detected

### 3.1 `restart:` Policy

~~All stacks now use `unless-stopped`.~~ **Resolved.**

### 3.2 Environment Variable Handling (4 styles mixed)

~~Resolved.~~ Standardized to:
- **Map format** (`KEY: "value"`) across all stacks.
- **Shell substitution** (`"${VAR}"`) for credentials — externalized to `.envrc`.
- **Hardcoded values** only for non-secret service configuration.

### 3.3 Volume Strategy (3 strategies mixed)

~~Resolved.~~ Standardized to:
- **Bind mount with env var** (`${STACK_VOLUME_DIR}/path` or `${STACK_HOME}/file`) for persistent data and config/init files.
- **Named volumes** for temporary/ephemeral data managed by Docker.
- **No more relative paths** in active stacks.

Some stacks mix bind mounts and named volumes by design (e.g., telemetry uses bind mounts for configs and named volumes for temp data). This is acceptable.

### 3.4 Naming Bugs

~~Resolved.~~ Fixed:
- **minio**: `container_name` corrected from `minio-server-server` to `minio-server`.
- **kafka**: service key renamed from `kafka-ui` to `kafka-webui` to match `container_name`.

### 3.5 YAML Formatting Issues

~~Resolved.~~ Fixed across all stacks:
- Extra spaces in network references (postgres, minio, localstack-pro).
- Extra spaces in network names (oracle-23ai, sql-server-2022).
- 3-space indentation on networks blocks (minio, localstack-pro, oracle-23ai, sql-server-2022) — corrected to 2 spaces.
- Commented volume line removed (oracle-23ai).
- Port quotes standardized to `"host:container"` across all stacks.

### 3.6 `.envrc` Alias Formatting

~~Resolved.~~ Fixed:
- All aliases now use double space after `alias` (consistent across 17/17 stacks).
- Missing space in `#---` separators corrected (telemetry, temporal).

### 3.7 Port Conflicts

~~Resolved.~~ No port conflicts exist between the 17 stacks when running simultaneously.

**Remapped ports (by colision with other stacks):**
- **keycloak** `8180:8080` — colisiona con redpanda-console (`8080`), offset +100
- **openfga** `8280:8080`, `8281:8081`, `3200:3000` — colisiona con redpanda-console (`8080`) y grafana (`3000`), offset +200
- **metabase** `3300:3000` — colisiona con grafana (`3000`), offset +300
- **postgres** `15432:5432` — secundario, timescaledb ocupa el default

**Redpanda ports are official defaults (NOT remaps):**
- `19092`, `18081`, `18082` are Redpanda's external listener ports by design
- `8080` is redpanda-console's default

**Intentional remaps (same stack or privileged port):**
- **telemetry-alloy** `14317:4317`, `14318:4318` — colisiona con otel-collector (mismo stack)
- **localstack** `9443:443` — privileged port remap

---

## 4. Per-Stack Detail

### 4.1 clickhouse

```
File:           clickhouse/clickhouse-stack-compose.yml
Services:       clickhouse-server
Platform:       linux/arm64
Restart:        no                              << OLAP warehouse, run on demand
Env handling:   Shell substitution (${CLICKHOUSE_PASSWORD})
Volumes:        Env var bind mounts (data + logs)
Ports:          "8123:8123" (HTTP + web UI at /play), "9000:9000" (native client)
depends_on:     None
Healthcheck:    No
Extras:         ulimits nofile 262144. OLAP columnar engine (C++, not PostgreSQL).
```

### 4.2 gcp-pubsub

```
File:           gcp-pubsub/gcp-pubsub-stack-compose.yml
Services:       gcp-pubsub-server
Platform:       linux/amd64                     << official image has no arm64 (Rosetta OK)
Restart:        no
Env handling:   None
Volumes:        None (stateless)
Ports:          "8085:8085"
depends_on:     None
Healthcheck:    No
Extras:         Official Google Cloud Pub/Sub emulator. Python auto-detects via
                PUBSUB_EMULATOR_HOST=localhost:8085 env var.
```

### 4.3 keycloak

```
File:           keycloak/keycloak-stack-compose.yml
Services:       keycloak-server
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   Shell substitution (${KEYCLOAK_ADMIN_USERNAME}, ${KEYCLOAK_ADMIN_PASSWORD})
Volumes:        Env var bind mount (${KEYCLOAK_VOLUME_DIR}/data)
Ports:          "8180:8080"
depends_on:     None
Healthcheck:    No
Extras:         command: start-dev (development mode)
```

### 4.4 localstack-pro

```
File:           localstack-pro/localstack-pro-stack-compose.yml
Services:       localstack-pro-server
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   Shell substitution with defaults + required (${LOCALSTACK_AUTH_TOKEN:?})
Volumes:        Env var bind mount + Docker socket mount
Ports:          "127.0.0.1:4566:4566", "127.0.0.1:4510-4559:4510-4559", "127.0.0.1:9443:443"
depends_on:     None
Healthcheck:    No
Extras:         Ports bound to 127.0.0.1 only (unique in repo), Docker socket mount
```

### 4.5 mailhog

```
File:           mailhog/mailhog-stack-compose.yml
Services:       mailhog-server
Platform:       linux/amd64                     << archived project, amd64 images only
Restart:        unless-stopped
Env handling:   None (no environment block)
Volumes:        None (stateless)
Ports:          "1025:1025", "8025:8025"
depends_on:     None
Healthcheck:    No
Extras:         None
```

### 4.6 metabase

```
File:           metabase/metabase-stack-compose.yml
Services:       metabase-server
Platform:       linux/arm64
Restart:        no                              << heavy JVM app (~700MB-1GB RAM), run on demand
Env handling:   Hardcoded (MB_DB_FILE, JAVA_TIMEZONE)
Volumes:        Env var bind mount (${METABASE_VOLUME_DIR}) + /dev/urandom:/dev/random:ro
Ports:          "3300:3000"                    << remapped, grafana uses 3000
depends_on:     None
Healthcheck:    No
Extras:         Uses embedded SQLite for application database (no external DB required)
```

### 4.7 mongo

```
File:           mongo/mongo-stack-compose.yml
Services:       mongo-server
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   Shell substitution (no defaults)
Volumes:        Env var bind mounts (2 paths)
Ports:          "27017:27017"
depends_on:     None
Healthcheck:    No
Extras:         None
```

### 4.8 n8n

```
File:           n8n/n8n-stack-compose.yml
Services:       n8n-server
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   Shell substitution (credentials) + hardcoded (timezone: America/Bogota)
Volumes:        Env var bind mount (${N8N_VOLUME_DIR}) + /dev/urandom:/dev/random:ro
Ports:          "5678:5678"
depends_on:     None
Healthcheck:    No
Extras:         None
```

### 4.9 openfga

```
File:           openfga/openfga-stack-compose.yml
Services:       openfga-migrate, openfga-server
Platform:       linux/arm64
Restart:        unless-stopped (server), no (migrate — one-shot task)
Env handling:   Hardcoded (datastore config: sqlite)
Volumes:        Env var bind mount (${OPENFGA_VOLUME_DIR})
Ports:          "8280:8080", "8281:8081", "3200:3000"
depends_on:     server -> migrate (service_completed_successfully)
Healthcheck:    No
Extras:         command: migrate (init), command: run (server)
```

### 4.10 oracle-23ai

```
File:           oracle-23ai/oracle-23ai-stack-compose.yml
Services:       oracle-23ai-server
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   Shell substitution (no defaults)
Volumes:        Env var bind mounts (7 paths)
Ports:          "1521:1521"
depends_on:     None
Healthcheck:    No
Extras:         None
```

### 4.11 postgres

```
File:           postgres/postgres-stack-compose.yml
Services:       postgres-server
Platform:       linux/arm64
Restart:        no                              << secondary, timescaledb is the primary PG
Env handling:   Shell substitution (no defaults)
Volumes:        Env var bind mounts (${POSTGRES_VOLUME_DIR}/data + ${POSTGRES_HOME}/extension.sql)
Ports:          "15432:5432"                    << remapped, timescaledb uses 5432
depends_on:     None
Healthcheck:    No
Extras:         Init SQL script mounted to docker-entrypoint-initdb.d
```

### 4.12 rabbitmq

```
File:           rabbitmq/rabbitmq-stack-compose.yml
Services:       rabbitmq-server
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   Shell substitution (${RABBITMQ_DEFAULT_USER}, ${RABBITMQ_DEFAULT_PASS})
Volumes:        Env var bind mount (${RABBITMQ_VOLUME_DIR}/data)
Ports:          "5672:5672", "15672:15672"
depends_on:     None
Healthcheck:    No
Extras:         None
```

### 4.13 redis

```
File:           redis/redis-stack-compose.yml
Services:       redis-server
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   Shell substitution embedded in command args (REDIS_ARGS with ${REDIS_PASSWORD})
Volumes:        Env var bind mounts with defaults (2 paths)
Ports:          "6379:6379", "8001:8001"
depends_on:     None
Healthcheck:    No
Extras:         None
```

### 4.14 redpanda

```
File:           redpanda/redpanda-stack-compose.yml
Services:       redpanda-broker, redpanda-console
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   Hardcoded/embedded YAML in env (console CONSOLE_CONFIG_FILE multiline)
Volumes:        Named volume (broker data)
Ports:          "19092:19092", "18081:18081", "18082:18082", "19644:9644", "8080:8080"
depends_on:     console -> broker
Healthcheck:    No
Extras:         Official config per docs.redpanda.com/redpanda-labs/docker-compose/single-broker/
                Ports 19092/18081/18082 are Redpanda's official external listener defaults (not remaps).
```

### 4.15 sonarqube

```
File:           sonarqube/sonarqube-stack-compose.yml
Services:       sonarqube-server, sonarqube-postgres
Platform:       linux/arm64
Restart:        no
Env handling:   Shell substitution from .envrc (${SONARQUBE_JDBC_USERNAME}, ${SONARQUBE_JDBC_PASSWORD}, ${SONARQUBE_JDBC_DATABASE})
Volumes:        Named volumes only (6 named volumes)
Ports:          "9000:9000" (sonarqube only; postgres has no exposed ports)
depends_on:     server -> postgres
Healthcheck:    No
Extras:         Postgres has no exposed ports (internal only via network)
```

### 4.16 sql-server-2022

```
File:           sql-server-2022/sql-server-2022-stack-compose.yml
Services:       sqlserver-2022-server
Platform:       linux/amd64                     << required by SQL Server
Restart:        unless-stopped
Env handling:   Hardcoded (ACCEPT_EULA) + shell substitution (password)
Volumes:        Env var bind mount with default
Ports:          "1433:1433"
depends_on:     None
Healthcheck:    No
Extras:         None
```

### 4.17 superset

```
File:           superset/superset-stack-compose.yml
Services:       superset-server
Platform:       linux/arm64
Restart:        no                              << BI tool (~400-500 MB RAM), run on demand
Env handling:   Shell substitution (${SUPERSET_SECRET_KEY})
Volumes:        Env var bind mount (${SUPERSET_VOLUME_DIR})
Ports:          "8088:8088"
depends_on:     None
Healthcheck:    No
Extras:         Apache 2.0. Uses embedded SQLite (no external DB/Redis/Celery).
                Requires one-time init: create-admin, db upgrade, init.
                Connects to 80+ databases for querying (PostgreSQL, ClickHouse, DuckDB, etc.)
```

### 4.18 telemetry

```
File:           telemetry/telemetry-stack-compose.yml
Services:       telemetry-otel-collector, telemetry-jaeger, telemetry-prometheus,
                telemetry-loki, telemetry-grafana, telemetry-alloy
Platform:       linux/arm64
Restart:        unless-stopped (alloy: no — secondary collector, manual start)
Env handling:   Map format (jaeger: COLLECTOR_OTLP_ENABLED, grafana: anonymous auth)
Volumes:        Mixed: env var bind mounts (configs) + named volumes (temp/data)
Ports:          "1888:1888", "8888:8888", "8889:8889", "13133:13133", "4317:4317",
                "4318:4318", "55679:55679", "16686:16686", "14250:14250", "9090:9090",
                "3100:3100", "3000:3000", "12345:12345", "14317:4317", "14318:4318"
depends_on:     None (services are independent)
Healthcheck:    No
Extras:         OTEL Collector exports logs to Loki via otlphttp.
                Grafana auto-provisions datasources (Loki, Prometheus, Jaeger).
                Alloy is a secondary collector (restart: no) on remapped ports.
```

### 4.19 temporal

```
File:           temporal/temporal-dev-stack-compose.yml
Services:       temporal-dev-server
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   None (no environment block)
Volumes:        Env var bind mount with default
Ports:          "7233:7233", "8233:8233"
depends_on:     None
Healthcheck:    No
Extras:         command (server start-dev ...), working_dir: /temporal
```

### 4.20 timescaledb

```
File:           timescaledb/timescaledb-stack-compose.yml
Services:       timescaledb-server
Platform:       linux/arm64
Restart:        unless-stopped
Image:          timescale/timescaledb-ha:pg17   << PostgreSQL 17 with 50+ extensions pre-installed
Env handling:   Shell substitution (${TIMESCALEDB_PASSWORD})
Volumes:        Env var bind mounts (${TIMESCALEDB_VOLUME_DIR}/data + ${TIMESCALEDB_HOME}/extension.sql)
Ports:          "5432:5432"                    << primary PostgreSQL, replaces postgres-server
depends_on:     None
Healthcheck:    No
Extras:         Init SQL enables 13 extensions: uuid-ossp, citext, hstore, ltree, pg_trgm,
                unaccent, fuzzystrmatch, pg_stat_statements, pg_cron, timescaledb, vector,
                postgis, pgcrypto
```

### 4.21 versitygw

```
File:           versitygw/versitygw-stack-compose.yml
Services:       versitygw-server
Platform:       linux/arm64
Restart:        unless-stopped
Image:          versity/versitygw:latest        << S3-compatible gateway (Apache 2.0), replaces MinIO
Env handling:   Shell substitution (${VERSITYGW_ACCESS_KEY}, ${VERSITYGW_SECRET_KEY})
Volumes:        Env var bind mount (${VERSITYGW_VOLUME_DIR}/data)
Ports:          "7070:7070", "7071:7071"
depends_on:     None
Healthcheck:    No
Extras:         command: posix /data --port :7070 --webui :7071
                S3 API on 7070, WebUI on 7071. Backend is POSIX filesystem.
```

---

## 5. Proposed Template

### 5.1 Single-Service Template

```yaml
services:
  {stack}-server:
    container_name: {stack}-server
    image: {image}:{tag}
    platform: linux/arm64
    restart: unless-stopped
    ports:
      - "{host_port}:{container_port}"
    environment:
      ENV_VAR: "${SHELL_VAR}"
    volumes:
      - "${STACK_VOLUME_DIR}/data:/container/data/path"
    networks:
      - {stack}-network

networks:
  {stack}-network:
    name: {stack}-network
    driver: bridge
```

### 5.2 Multi-Service Template

```yaml
services:
  {stack}-{primary}:
    container_name: {stack}-{primary}
    image: {image}:{tag}
    platform: linux/arm64
    restart: unless-stopped
    ports:
      - "{host_port}:{container_port}"
    environment:
      ENV_VAR: "${SHELL_VAR}"
    volumes:
      - {stack}-{primary}_data:/container/data/path
    networks:
      - {stack}-network

  {stack}-{secondary}:
    container_name: {stack}-{secondary}
    image: {image}:{tag}
    platform: linux/arm64
    restart: unless-stopped
    depends_on:
      - {stack}-{primary}
    ports:
      - "{host_port}:{container_port}"
    environment:
      ENV_VAR: "value"
    networks:
      - {stack}-network

volumes:
  {stack}-{primary}_data:
    name: {stack}-{primary}_data

networks:
  {stack}-network:
    name: {stack}-network
    driver: bridge
```

### 5.3 Template Rules

#### Naming

| Element | Convention | Example |
|---------|-----------|---------|
| Directory | `{service-name}/` | `postgres/`, `sql-server-2022/` |
| Compose file | `{service-name}-stack-compose.yml` | `postgres-stack-compose.yml` |
| Service key | `{stack}-{role}` | `kafka-broker`, `sonarqube-postgres` |
| Container name | **Must match** service key | `container_name: kafka-broker` |
| Network name | `{stack}-network` | `kafka-network` |
| Named volumes | `{stack}-{service}_{purpose}` | `kafka-broker_data` |
| `.envrc` vars | `{STACK}_VARIABLE` | `POSTGRES_PASSWORD`, `MONGO_VOLUME_DIR` |
| `.envrc` aliases | `{STACK}_STACK_UP/STOP/DOWN` | `KAFKA_STACK_UP`, `MONGO_STACK_DOWN` |
| `README.md` | Required for **multi-service** stacks | `telemetry/README.md`, `kafka/README.md` |

#### YAML Key Order (per service)

```
1. container_name
2. image
3. platform
4. restart
5. depends_on          (if applicable)
6. ports
7. environment
8. command             (if applicable)
9. working_dir         (if applicable)
10. volumes
11. networks
```

#### Environment Variables

- Credentials: Always from `.envrc` via `"${SHELL_VAR}"` — never hardcoded in YAML.
- Service config (non-secret): Hardcoded in YAML is acceptable (e.g., `ZOOKEEPER_CLIENT_PORT: '2181'`).
- Format: Always use **map format** (`KEY: "value"`), never list format (`- KEY=value`).
- Defaults: Use `${VAR:-default}` for volume paths. Use `${VAR:?}` for required secrets with no fallback.

#### Volumes

- **Persistent data**: Use `${STACK_VOLUME_DIR}/subpath:/container/path` with env var from `.envrc`.
- **Named volumes**: Use only for temporary/ephemeral data (temp dirs) or when Docker-managed lifecycle is preferred.
- **Config files**: Use `${STACK_VOLUME_DIR}/config.yaml:/container/config.yaml` (not relative paths).
- **Init/support files**: Use `${STACK_HOME}/file:/container/path` for files that live in the stack root (not inside `volume/`).
- **Volume dir default**: Include `:-./volume` fallback for local development without `.envrc`. Use `:-.` when the env var points to the stack root (e.g., `TELEMETRY_VOLUME_DIR`, `POSTGRES_HOME`).
- **`.gitkeep`**: Every `volume/` directory must contain a `.gitkeep` file so git tracks the empty directory. Data inside `volume/` is excluded via `.gitignore`.

#### Ports

- Format: Always quoted strings `"host:container"`.
- Binding: Default to all interfaces. Use `127.0.0.1:` prefix only when explicitly needed (e.g., localstack).

#### Restart Policy

- Default: `unless-stopped` for all services.
- Exception: Document the reason as a YAML comment if a service needs `no` or `always`.

#### Platform

- Default: `linux/arm64`.
- Exception: `linux/amd64` when the image requires it (e.g., SQL Server). Document with a YAML comment.

#### Formatting

- Indentation: 2 spaces everywhere.
- No trailing spaces.
- No extra spaces in YAML values or references.
- Blank line between services, between top-level blocks (`services`, `volumes`, `networks`).

#### Documentation

- **Multi-service stacks** must include a `README.md` in the stack directory.
- Content: table of services (ports, restart policy, function), dependency diagram, port listing, and relevant notes.
- Single-service stacks do not require a `README.md` (the compose file is self-documenting).

### 5.4 `.envrc` Section Template

```bash
# ------------- {STACK_UPPER} ------------- #
alias  {STACK_UPPER}_STACK_UP="docker compose -f $SERVICES_HOME/{dir}/{dir}-stack-compose.yml -p {dir}-stack up --detach --remove-orphans"
alias  {STACK_UPPER}_STACK_STOP="docker compose -f $SERVICES_HOME/{dir}/{dir}-stack-compose.yml -p {dir}-stack stop"
alias  {STACK_UPPER}_STACK_DOWN="docker compose -f $SERVICES_HOME/{dir}/{dir}-stack-compose.yml -p {dir}-stack down"
export {STACK_UPPER}_PASSWORD="..."
export {STACK_UPPER}_HOME="$SERVICES_HOME/{dir}"              # optional, if stack has files outside volume/
export {STACK_UPPER}_VOLUME_DIR="${STACK_UPPER}_HOME/volume"   # or "$SERVICES_HOME/{dir}/volume" if no _HOME
```

---

## 6. Standardization Checklist

Use this checklist when reviewing each stack. Mark exclusions with a reason.

### Per-Stack Checklist

```
[ ] File name follows {service}-stack-compose.yml
[ ] No `version:` key
[ ] container_name matches service key
[ ] platform is set (arm64 default, amd64 with comment if needed)
[ ] restart: unless-stopped (or documented exception)
[ ] Environment vars: credentials from ${SHELL_VAR}, config hardcoded, map format only
[ ] Volumes: ${STACK_VOLUME_DIR}/path (no relative paths except documented exceptions)
[ ] Ports: quoted strings "host:container"
[ ] Network: {stack}-network with driver: bridge
[ ] YAML: 2-space indent, no extra spaces, consistent formatting
[ ] .envrc: alias spacing consistent, volume dir exported, credentials exported
```

### Stack Status Tracker

| Stack | Reviewed | Standardized | Exclusions |
|-------|----------|-------------|------------|
| clickhouse | [x] | [x] | restart: no (OLAP warehouse, run on demand) |
| gcp-pubsub | [x] | [x] | platform: linux/amd64 (official image, Rosetta OK) |
| keycloak | [x] | [x] | |
| localstack-pro | [x] | [x] | |
| mailhog | [x] | [x] | platform: linux/amd64 (archived project, no arm64 images) |
| metabase | [x] | [x] | restart: no (heavy JVM app, run on demand) |
| mongo | [x] | [x] | |
| n8n | [x] | [x] | Hardcoded timezone (America/Bogota) |
| openfga | [x] | [x] | openfga-migrate uses restart: no (one-shot task) |
| oracle-23ai | [x] | [x] | |
| postgres | [x] | [x] | restart: no (secondary, timescaledb is primary PG) |
| rabbitmq | [x] | [x] | Image tag `management` instead of `latest` |
| redis | [x] | [x] | |
| redpanda | [x] | [x] | |
| sonarqube | [x] | [x] | |
| sql-server-2022 | [x] | [x] | |
| superset | [x] | [x] | restart: no (BI tool, run on demand) |
| telemetry | [x] | [x] | |
| temporal | [x] | [x] | |
| timescaledb | [x] | [x] | Image: timescale/timescaledb-ha:pg17 |
| versitygw | [x] | [x] | |

---

## 7. Aluna Project — Stack Applicability

Stacks marked as services-up use `restart: unless-stopped` (auto-start with OrbStack); non-applicable stacks use `restart: no`.

| Stack | services-up | `restart:` | Uso |
|-------|-------------|------------|-----|
| **timescaledb** | **SI** | `unless-stopped` | BD principal PostgreSQL 17 + extensiones (puerto `5432`) |
| **redis** | **SI** | `unless-stopped` | Cache, sesiones, rate limiting |
| **versitygw** | **SI** | `unless-stopped` | Object storage S3-compatible (Apache 2.0, reemplaza MinIO) |
| **telemetry** | **SI** | `unless-stopped` | Observabilidad (OTEL + Jaeger + Prometheus + Loki + Grafana) |
| **rabbitmq** | **SI** | `unless-stopped` | Cola async para despachar jobs al runtime |
| **mailhog** | **SI** | `unless-stopped` | Emails (notificaciones, invitaciones tenant) |
| **keycloak** | **SI** | `unless-stopped` | Identity provider para auth local |
| **temporal** | **SI** | `unless-stopped` | Orquestación de workflows del runtime |
| **redpanda** | **SI** | `unless-stopped` | Event streaming (Kafka API compatible) |
| postgres | No | `no` | PostgreSQL vanilla, secundario (puerto `15432`) |
| clickhouse | No | `no` | OLAP columnar warehouse, uso esporádico |
| gcp-pubsub | No | `no` | Emulador Google Pub/Sub para desarrollo local |
| localstack-pro | No | `no` | Emula AWS |
| metabase | No | `no` | BI/dashboards, JVM pesado (~700MB-1GB RAM), uso esporádico |
| mongo | No | `no` | PostgreSQL elegido |
| n8n | No | `no` | Workflow automation, no dependencia |
| openfga | No | `no` | Authorization server |
| oracle-23ai | No | `no` | PostgreSQL elegido |
| sonarqube | No | `no` | Quality gate, no runtime |
| sql-server-2022 | No | `no` | PostgreSQL elegido |
| superset | No | `no` | BI/dashboards avanzado (~400-500 MB RAM), uso esporádico |