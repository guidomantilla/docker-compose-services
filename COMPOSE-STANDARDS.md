# Docker Compose Standards & Analysis

> Analysis of the 13 active service stacks in this repository.
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
| 2 | `localstack-pro/` | `localstack-pro-stack-compose.yml` | Single | localstack-pro-server |
| 3 | `minio/` | `minio-stack-compose.yml` | Single | minio-server |
| 4 | `mongo/` | `mongo-stack-compose.yml` | Single | mongo-server |
| 5 | `oracle-23ai/` | `oracle-23ai-stack-compose.yml` | Single | oracle-23ai-server |
| 6 | `postgres/` | `postgres-stack-compose.yml` | Single | postgres-server |
| 7 | `redis/` | `redis-stack-compose.yml` | Single | redis-server |
| 8 | `redpanda/` | `redpanda-stack-compose.yml` | Multi-service | redpanda-broker, redpanda-console |
| 9 | `sonarqube/` | `sonarqube-stack-compose.yml` | Multi-service | sonarqube-server, sonarqube-postgres |
| 10 | `sql-server-2022/` | `sql-server-2022-stack-compose.yml` | Single | sqlserver-2022-server |
| 11 | `telemetry/` | `telemetry-stack-compose.yml` | Multi-service | telemetry-otel-collector, telemetry-jaeger, telemetry-prometheus |
| 12 | `temporal/` | `temporal-dev-stack-compose.yml` | Single | temporal-dev-server |
| 13 | `yumbrands/` | `yumbrands-stack-compose.yml` | Multi-service | 11 services (postgres, kafka, temporal, etc.) |

---

## 2. Current Pattern Analysis

### 2.1 What IS Already Consistent (13/13 stacks)

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
| `restart:` | `unless-stopped` | 13/13 |
| `platform:` | `linux/arm64` | 11/13 |
| Environment vars | Map format, shell substitution from `.envrc` (`"${VAR}"`) for credentials | 12/13 (yumbrands exception) |
| Volumes | Bind mounts with `${SERVICE_VOLUME_DIR}/path:/container/path` | 9/13 |
| Image tags | `:latest` | 11/13 (sql-server uses `2022-latest`, yumbrands uses pinned versions) |

### 2.3 What Is NOT Present (0/13 stacks) — Out of Scope

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
- **Exception:** yumbrands retains hardcoded credentials — it is a project-specific stack, not a reusable service.

### 3.3 Volume Strategy (3 strategies mixed)

~~Resolved.~~ Standardized to:
- **Bind mount with env var** (`${STACK_VOLUME_DIR}/path` or `${STACK_HOME}/file`) for persistent data and config/init files.
- **Named volumes** for temporary/ephemeral data managed by Docker.
- **No more relative paths** in active stacks.
- **Exception:** yumbrands retains relative paths (`./dynamicconfig`) — it is a project-specific stack.

Some stacks mix bind mounts and named volumes by design (e.g., telemetry uses bind mounts for configs and named volumes for temp data). This is acceptable.

### 3.4 Naming Bugs

~~Resolved.~~ Fixed:
- **minio**: `container_name` corrected from `minio-server-server` to `minio-server`.
- **kafka**: service key renamed from `kafka-ui` to `kafka-webui` to match `container_name`.
- **Exception:** yumbrands retains `mockordertransmission` / `mock-order-transmission` mismatch — it is a project-specific stack.

### 3.5 YAML Formatting Issues

~~Resolved.~~ Fixed across all stacks:
- Extra spaces in network references (postgres, minio, localstack-pro).
- Extra spaces in network names (oracle-23ai, sql-server-2022).
- 3-space indentation on networks blocks (minio, localstack-pro, oracle-23ai, sql-server-2022) — corrected to 2 spaces.
- Commented volume line removed (oracle-23ai).
- Port quotes standardized to `"host:container"` across all stacks (including yumbrands).

### 3.6 `.envrc` Alias Formatting

~~Resolved.~~ Fixed:
- All aliases now use double space after `alias` (consistent across 13/13 stacks).
- Missing space in `#---` separators corrected (telemetry, temporal, yumbrands).

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

### 4.2 localstack-pro

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

### 4.3 minio

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

### 4.4 mongo

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

### 4.5 oracle-23ai

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

### 4.6 postgres

```
File:           postgres/postgres-stack-compose.yml
Services:       postgres-server
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   Shell substitution (no defaults)
Volumes:        Env var bind mounts (${POSTGRES_VOLUME_DIR}/data + ${POSTGRES_HOME}/extension.sql)
Ports:          "5432:5432"
depends_on:     None
Healthcheck:    No
Extras:         Init SQL script mounted to docker-entrypoint-initdb.d
```

### 4.7 redis

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

### 4.8 redpanda

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

### 4.9 sonarqube

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

### 4.10 sql-server-2022

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

### 4.11 telemetry

```
File:           telemetry/telemetry-stack-compose.yml
Services:       telemetry-otel-collector, telemetry-jaeger, telemetry-prometheus
Platform:       linux/arm64
Restart:        unless-stopped
Env handling:   Map format (jaeger: COLLECTOR_OTLP_ENABLED, otel/prometheus: no env)
Volumes:        Mixed: env var bind mounts (configs) + named volumes (temp/data)
Ports:          "1888:1888", "8888:8888", "8889:8889", "13133:13133", "4317:4317", "4318:4318", "55679:55679", "16686:16686", "14250:14250", "9090:9090"
depends_on:     None (services are independent)
Healthcheck:    No
Extras:         Inline port comments (e.g. # pprof extension)
```

### 4.12 temporal

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

### 4.13 yumbrands (exception — project-specific stack)

```
File:           yumbrands/yumbrands-stack-compose.yml
Services:       postgres, kafka-zookeeper, kafka-broker, kafka-ui, commerceorderservicedbm,
                mockordertransmission, temporal-elasticsearch, temporal-postgres,
                temporal, temporal-admin-tools, temporal-ui
Platform:       linux/amd64 (all services)      << required by private images
Restart:        unless-stopped
Env handling:   Hardcoded credentials + map format (standardized from list format)
Volumes:        Named volumes + relative path (./dynamicconfig)
Ports:          "5432:5432", "2181:2181", "9093:9093", "9092:9092", "8080:8080", "3009:3009", "7233:7233", "8088:8080"
depends_on:     broker -> zookeeper, dbm -> postgres, temporal -> postgres+es, admin -> temporal, ui -> temporal
Healthcheck:    No
Extras:         profiles (commerceorderservicedbm: optional), labels (temporal: kompose.volume.type),
                stdin_open + tty (admin-tools), expose (zookeeper, broker, elasticsearch, postgres internal)
Exclusions:     Hardcoded credentials, relative paths, naming mismatch (mockordertransmission/mock-order-transmission).
                This is a project-specific environment, not a reusable service.
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
- **Volume dir default**: Include `:-./volume` fallback for local development without `.envrc`.

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
| localstack-pro | [x] | [x] | |
| minio | [x] | [x] | |
| mongo | [x] | [x] | |
| oracle-23ai | [x] | [x] | |
| postgres | [x] | [x] | |
| redis | [x] | [x] | |
| redpanda | [x] | [x] | |
| sonarqube | [x] | [x] | |
| sql-server-2022 | [x] | [x] | |
| telemetry | [x] | [x] | |
| temporal | [x] | [x] | |
| yumbrands | [x] | [x] | Hardcoded credentials, relative paths, naming mismatch |