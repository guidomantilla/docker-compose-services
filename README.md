# Docker Compose Standards & Analysis

> Analysis of the 17 active service stacks in this repository.
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
| 1 | `kafka/` | `kafka-stack-compose.yml` | Multi-service | kafka-zookeeper, kafka-broker, kafka-ui |
| 2 | `keycloak/` | `keycloak-stack-compose.yml` | Single | keycloak-server |
| 3 | `localstack-pro/` | `localstack-pro-stack-compose.yml` | Single | localstack-pro-server |
| 4 | `mailhog/` | `mailhog-stack-compose.yml` | Single | mailhog-server |
| 5 | `minio/` | `minio-stack-compose.yml` | Single | minio-server |
| 6 | `mongo/` | `mongo-stack-compose.yml` | Single | mongo-server |
| 7 | `n8n/` | `n8n-stack-compose.yml` | Single | n8n-server |
| 8 | `openfga/` | `openfga-stack-compose.yml` | Multi-service | openfga-migrate, openfga-server |
| 9 | `oracle-23ai/` | `oracle-23ai-stack-compose.yml` | Single | oracle-23ai-server |
| 10 | `postgres/` | `postgres-stack-compose.yml` | Single | postgres-server |
| 11 | `rabbitmq/` | `rabbitmq-stack-compose.yml` | Single | rabbitmq-server |
| 12 | `redis/` | `redis-stack-compose.yml` | Single | redis-server |
| 13 | `redpanda/` | `redpanda-stack-compose.yml` | Multi-service | redpanda-broker, redpanda-console |
| 14 | `sonarqube/` | `sonarqube-stack-compose.yml` | Multi-service | sonarqube-server, sonarqube-postgres |
| 15 | `sql-server-2022/` | `sql-server-2022-stack-compose.yml` | Single | sqlserver-2022-server |
| 16 | `telemetry/` | `telemetry-stack-compose.yml` | Multi-service | telemetry-otel-collector, telemetry-jaeger, telemetry-prometheus, telemetry-loki, telemetry-grafana, telemetry-alloy |
| 17 | `temporal/` | `temporal-dev-stack-compose.yml` | Single | temporal-dev-server |

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

Conflicts were previously resolved by prefixing `1` to the host port (convention: `1XXXX:XXXX`):

**Temporal** — remapped to avoid historical conflict:
- `7233` → `17233:7233`
- `8233` → `18233:8233`

**Redpanda** — avoided conflict with kafka:
- `8080` → `18080:8080` (kafka-webui uses 8080)
- `9092` → `19092:9092` (kafka-broker uses 9092)
- `9644` → `19644:9644`
- `8081` → `18081:18081`
- `8082` → `18082:18082`

**Postgres** — remapped to avoid historical conflict:
- `5432` → `15432:5432`

**Sonarqube** — avoided conflict with minio:
- `9000` → `19000:9000` (minio uses 9000)

---

## 4. Per-Stack Detail

### 4.1 kafka

```
File:           kafka/kafka-stack-compose.yml
Services:       kafka-zookeeper, kafka-broker, kafka-webui
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   Hardcoded (zookeeper, webui) + shell substitution with defaults (broker: ${DOCKER_HOST_IP:-127.0.0.1})
Volumes:        Named volumes only (5 named volumes)
Ports:          "2181:2181", "9093:9093", "9092:9092", "29092:29092", "9999:9999", "8080:8080"
depends_on:     broker -> zookeeper, webui -> broker
Healthcheck:    No
Extras:         None
```

### 4.2 keycloak

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

### 4.3 localstack-pro

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

### 4.4 mailhog

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

### 4.5 minio

```
File:           minio/minio-stack-compose.yml
Services:       minio-server
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   Shell substitution (no defaults on credentials, default on volume path)
Volumes:        Env var bind mount with default
Ports:          "9000:9000", "9001:9001"
depends_on:     None
Healthcheck:    No
Extras:         command: server /data --console-address ":9001"
```

### 4.6 mongo

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

### 4.7 n8n

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

### 4.8 openfga

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

### 4.9 oracle-23ai

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

### 4.10 postgres

```
File:           postgres/postgres-stack-compose.yml
Services:       postgres-server
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   Shell substitution (no defaults)
Volumes:        Env var bind mounts (${POSTGRES_VOLUME_DIR}/data + ${POSTGRES_HOME}/extension.sql)
Ports:          "15432:5432"
depends_on:     None
Healthcheck:    No
Extras:         Init SQL script mounted to docker-entrypoint-initdb.d
```

### 4.11 rabbitmq

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

### 4.12 redis

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

### 4.13 redpanda

```
File:           redpanda/redpanda-stack-compose.yml
Services:       redpanda-broker, redpanda-console
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   Hardcoded/embedded YAML in env (console CONSOLE_CONFIG_FILE multiline)
Volumes:        Named volume (broker data)
Ports:          "18081:18081", "18082:18082", "19092:19092", "19644:9644", "18080:8080"
depends_on:     console -> broker
Healthcheck:    No
Extras:         Complex command (broker), entrypoint override (console: /bin/sh -c ...)
```

### 4.14 sonarqube

```
File:           sonarqube/sonarqube-stack-compose.yml
Services:       sonarqube-server, sonarqube-postgres
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   Shell substitution from .envrc (${SONARQUBE_JDBC_USERNAME}, ${SONARQUBE_JDBC_PASSWORD}, ${SONARQUBE_JDBC_DATABASE})
Volumes:        Named volumes only (6 named volumes)
Ports:          "9000:9000" (sonarqube only; postgres has no exposed ports)
depends_on:     server -> postgres
Healthcheck:    No
Extras:         Postgres has no exposed ports (internal only via network)
```

### 4.15 sql-server-2022

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

### 4.16 telemetry

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

### 4.17 temporal

```
File:           temporal/temporal-dev-stack-compose.yml
Services:       temporal-dev-server
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   None (no environment block)
Volumes:        Env var bind mount with default
Ports:          "17233:7233", "18233:8233"
depends_on:     None
Healthcheck:    No
Extras:         command (server start-dev ...), working_dir: /temporal
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
| kafka | [x] | [x] | |
| keycloak | [x] | [x] | |
| localstack-pro | [x] | [x] | |
| mailhog | [x] | [x] | platform: linux/amd64 (archived project, no arm64 images) |
| minio | [x] | [x] | |
| mongo | [x] | [x] | |
| n8n | [x] | [x] | Hardcoded timezone (America/Bogota) |
| openfga | [x] | [x] | openfga-migrate uses restart: no (one-shot task) |
| oracle-23ai | [x] | [x] | |
| postgres | [x] | [x] | |
| rabbitmq | [x] | [x] | Image tag `management` instead of `latest` |
| redis | [x] | [x] | |
| redpanda | [x] | [x] | |
| sonarqube | [x] | [x] | |
| sql-server-2022 | [x] | [x] | |
| telemetry | [x] | [x] | |
| temporal | [x] | [x] | |

---

## 7. Aluna Project — Stack Applicability

Stacks relevant to the [Aluna](https://github.com/guidomau/aluna) platform (local development, no GCP). Stacks marked as Aluna-applicable use `restart: unless-stopped` (auto-start with OrbStack); non-applicable stacks use `restart: no`.

| Stack | Aplica a Aluna | `restart:` | Uso |
|-------|---------------|------------|-----|
| **postgres** | **SI** | `unless-stopped` | BD principal multi-tenant (puerto `15432`) |
| **redis** | **SI** | `unless-stopped` | Cache, sesiones, rate limiting |
| **minio** | **SI** | `unless-stopped` | Almacenamiento de archivos/objetos |
| **telemetry** | **SI** | `unless-stopped` | Observabilidad (OTEL + Jaeger + Prometheus) |
| **rabbitmq** | **SI** | `unless-stopped` | Cola async para despachar jobs al runtime |
| **mailhog** | **SI** | `unless-stopped` | Emails (notificaciones, invitaciones tenant) |
| **keycloak** | **SI** | `unless-stopped` | Identity provider para auth local |
| **temporal** | **SI** | `unless-stopped` | Orquestación de workflows del runtime |
| **redpanda** | **SI** | `unless-stopped` | Event streaming entre microservicios |
| kafka | No | `no` | Conflicta con redpanda |
| localstack-pro | No | `no` | Emula AWS, no GCP |
| mongo | No | `no` | PostgreSQL elegido |
| n8n | No | `no` | Competidor, no dependencia |
| openfga | No | `no` | RBAC a nivel de aplicación |
| oracle-23ai | No | `no` | PostgreSQL elegido |
| sonarqube | No | `no` | Quality gate, no runtime |
| sql-server-2022 | No | `no` | PostgreSQL elegido |