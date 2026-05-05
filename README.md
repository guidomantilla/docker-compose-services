# Docker Compose Services

A curated catalog of standardized Docker Compose stacks for local development. 26 service stacks, version-pinned, direnv-driven, opinionated by convention (updated 2026-05-05).

## What this repo IS

- A **standardized catalog** of `docker compose` stacks — same layout, naming, env-var conventions, and network topology across every service
- **Version-pinned by default** — every image tagged to a specific version; a fresh `docker pull` cannot silently upgrade and break a stack
- **Direnv-driven** — `.envrc` exposes per-stack aliases (`*_STACK_UP / STOP / DOWN`) so any service is one shell word away
- **Composable** — `services-up` bulk alias drives the always-on subset (redis, redpanda, telemetry, timescaledb); the rest start on demand
- **Apple-Silicon first** — defaults to `linux/arm64`, with `linux/amd64` exceptions only where ARM64 isn't published
- **Self-contained per stack** — each folder is a single `docker compose -f` invocation with its own bridge network and volume conventions
- **AI-readable** — predictable file naming, fixed YAML key order, and one section per stack in `.envrc` let coding assistants navigate any stack with no prior context

## What this repo is NOT

- **Not production-grade** — single-node, no replication, no backups, no secret manager, no resource limits
- **Not a Kubernetes replacement** — for k8s-target apps use Tilt, Skaffold, or Garden
- **Not a Testcontainers substitute** — those are programmatic and per-test ephemeral; this is shared infra you keep running across sessions
- **Not a dev-container replacement** — devcontainers bundle into the IDE per project; this lives at the user level and serves multiple projects
- **Not exhaustive** — covers what the author actually uses (postgres, kafka-equivalent, observability, identity, etc.), not every CNCF service
- **Not auto-updating** — image bumps are intentional, tracked, and manual; pinning is a feature, not a limitation
- **Not opinion-free** — port remappings, restart policies, network names, and `services-up` membership reflect explicit choices, not consensus
- **Not platform-agnostic** — Apple Silicon is primary; `linux/amd64` works but receives less testing

## How this compares to alternatives

If you've used the tools below, this is how they relate. They are complementary — none replaces another.

| Tool | What it is | When to use |
|---|---|---|
| Brew · MacPorts services | OS-installed daemons | One instance per machine, deep OS integration, no version isolation |
| devcontainers | IDE-bound per-project env | Project-scoped, IDE-coupled (VS Code, JetBrains) |
| Tilt · Skaffold · Garden | Kubernetes dev orchestration | App targets Kubernetes in production |
| Testcontainers | Programmatic per-test containers | Test isolation, lifecycle managed by test runner |
| **docker-compose-services** | Standalone catalog of shared local infra | Multi-project, terminal-driven, infra outlives any single project |

This catalog does not compete with the above — it covers the gap when you want **infra that survives across projects** without being globally installed on the host.

---

## Structure

### Active Stacks (26)

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
| 12 | `nginx/` | `nginx:1.27-alpine` | 8090 | no |
| 13 | `openfga/` | `openfga/openfga:v1.11.3` | 8280, 8281, 3200 | no |
| 14 | `oracle-23ai/` | `gvenzl/oracle-free:23-slim` | 1521 | no |
| 15 | `pinot/` | `apachepinot/pinot:1.4.0` | 9100, 8000 | no |
| 16 | `postgres/` | `postgres:18` | 15432 | no |
| 17 | `rabbitmq/` | `rabbitmq:management` | 5672, 15672 | no |
| 18 | `redis/` | `redis/redis-stack:7.4.0-v3` | 6379, 8001 | **unless-stopped** |
| 19 | `redpanda/` | `redpandadata/redpanda:v25.3.4` + `console:v3.3.2` | 19092, 18081, 18082, 19644, 8080 | **unless-stopped** |
| 20 | `sonarqube/` | `sonarqube:community` + `postgres:18` | 9200 | no |
| 21 | `sql-server-2022/` | `mssql/server:2022-latest` | 1433 | no |
| 22 | `superset/` | `apache/superset:latest` | 8088 | no |
| 23 | `telemetry/` | otel-collector, jaeger, prometheus, loki, grafana, alloy | 4317, 4318, 8888, 9090, 3000, 3100, 16686, ... | **unless-stopped** |
| 24 | `temporal/` | `temporalio/temporal:latest` | 7233, 8233 | no |
| 25 | `timescaledb/` | `timescale/timescaledb-ha:pg17` | 5432 | **unless-stopped** |
| 26 | `versitygw/` | `versity/versitygw:v1.3.1` | 7070, 7071 | no |

**Non-tracked:** `supabase/` is cloned from the official repo into `supabase/`, gitignored, kept for architecture reference only (not a managed stack).

### `services-up` subset (always-on)

Stacks with `restart: unless-stopped` auto-start with OrbStack and are included in the `services-up` bulk alias:

| Stack | Purpose | RAM |
|-------|---------|-----|
| **redis** | Cache, sessions | ~130 MB |
| **redpanda** | Event streaming (Kafka API compatible) | ~670 MB |
| **telemetry** | Observability (otel-collector + jaeger only in services-up) | ~50 MB |
| **timescaledb** | Primary PostgreSQL 17 + 50+ extensions | ~75 MB |

Everything else uses `restart: no` and starts on demand via its individual alias (e.g. `CLICKHOUSE_STACK_UP`).

### Deprecated and pending

| Folder | Contents |
|---|---|
| `_deprecated/` | arangodb, cockroachdb, druid, elk, influxdb, kafka, metabase (old), minio, porchpass, scylladb, temporal (full), yumbrands |
| `_pending/` | empty — all stacks have been promoted or deprecated |
| `supabase/` | cloned official repo, 13 microservices, gitignored, reference only |

---

## Port Remapping

Most stacks use default ports. Remaps exist only where ports collide. The convention is **+100 / +200 / +300 offsets from the owning service's default port**, so the remap origin is always readable.

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

### Redpanda external listeners (official defaults, not remaps)

`19092` (Kafka API) · `18081` (Schema Registry) · `18082` (Pandaproxy) · `19644:9644` (Admin API) — Redpanda's official external listener ports per [docs.redpanda.com](https://docs.redpanda.com/redpanda-labs/docker-compose/single-broker/).

### Intentional remaps

| Stack | Host Port | Reason |
|-------|-----------|--------|
| telemetry-alloy | 14317, 14318 | collides with otel-collector (same stack) |
| localstack | 9443:443 | privileged port |
| debezium-server | 8084:8080 | collides with redpanda-console |
| nginx | 8090:80 | privileged port |

---

## How to Use This Repo

### Initial setup

```bash
git clone git@github.com:guidomantilla/docker-compose-services.git
cd docker-compose-services
cp .envrc.example .envrc        # then fill in passwords
direnv allow                    # if using direnv
```

### Single-stack lifecycle

Each stack exposes three aliases via `.envrc`:

```bash
POSTGRES_STACK_UP        # docker compose up --detach --remove-orphans
POSTGRES_STACK_STOP      # docker compose stop
POSTGRES_STACK_DOWN      # docker compose down
```

The pattern is `{STACK}_STACK_UP/STOP/DOWN` for every stack listed above.

### Bulk lifecycle (services-up subset)

```bash
services-up              # iterates _SERVICES_UP_LIST
services-stop
services-down
```

`_SERVICES_UP_LIST` is defined at the bottom of `.envrc`; uncomment a stack name to include it in bulk operations.

### Quick connectivity check

```bash
./docker-show.sh         # lists running containers + their published ports
```

### Adding a new stack

1. Create `{stack}/` with `{stack}-stack-compose.yml` following the YAML key order standard
2. Add a `volume/.gitkeep` if the stack mounts persistent data
3. Add a section in `.envrc` and `.envrc.example` (alphabetical)
4. Add a row to the `Active Stacks` table above (alphabetical, renumber as needed)
5. If the host port collides with an existing remap group, use the next `+100` offset; otherwise document under `Intentional remaps`

---

## Design Decisions

| Decision | Rationale |
|---|---|
| **Pin every image version, never `:latest`** | `:latest` is non-deterministic — a `docker pull` can silently upgrade and break a stack. Exception: images that publish *only* `:latest` (apache/superset, temporalio/temporal). |
| **Compose file naming `{service}-stack-compose.yml`** | Discoverable via filename alone; predictable for IDE search and CLI completion. |
| **Fixed YAML key order per service** | `container_name → image → platform → restart → depends_on → ports → environment → command → working_dir → volumes → networks`. Mechanical to read, mechanical to diff. |
| **Credentials only via `.envrc`** | Secrets out of YAML, out of git. `.envrc` is gitignored; `.envrc.example` ships with empty values. |
| **Map-format env vars (`KEY: "value"`)** | Predictable interpolation. List format (`- KEY=value`) loses type clarity and resists templating. |
| **Per-stack bridge network `{stack}-network`** | Isolation by default. Cross-network access is added explicitly when a stack needs to talk to another (e.g., debezium ↔ redpanda + timescaledb). |
| **`unless-stopped` only for `services-up`** | Always-on subset auto-starts with OrbStack. Everything else is `restart: no` and runs on demand — keeps idle RAM low. |
| **Default platform `linux/arm64`** | Apple Silicon is the primary target. `linux/amd64` is the exception, used only when ARM64 is not published (mailhog, sql-server, gcp-pubsub). |
| **`.envrc` alphabetical, one section per stack** | Mechanical to extend — new stacks insert in their alphabetical slot, no merge conflicts on order. |
| **Volumes split: `${STACK_VOLUME_DIR}` for data, `${STACK_HOME}` for init/config** | Data and configuration have different backup/lifecycle needs. Default fallback `:-./volume` lets the stack run without `.envrc`. |
| **`.gitkeep` in every `volume/`** | Reserves the path in git; data inside is excluded via `.gitignore` glob. |
| **Port remaps localized and documented** | Every remap has a written reason in this README. The `+100/+200/+300` offset convention makes the origin port readable. |
| **No resource limits on stacks** | Development laptop on OrbStack — limits add friction without value. Revisit per-stack only if OrbStack overloads. |
| **Multi-service stacks ship a per-stack `README.md`** | When a folder contains more than one service (kafka, openfga, redpanda, sonarqube, telemetry, yumbrands), the local README documents the relationship. |

---

## References

### Tooling
- [Docker Compose specification](https://docs.docker.com/compose/compose-file/)
- [OrbStack](https://orbstack.dev/) — recommended Docker runtime on macOS
- [direnv](https://direnv.net/) — per-directory env loading (drives `.envrc`)

### Per-stack canonical sources
- [Redpanda single-broker compose](https://docs.redpanda.com/redpanda-labs/docker-compose/single-broker/)
- [Apache Airflow Docker](https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html)
- [Keycloak quickstart](https://www.keycloak.org/server/containers)
- [TimescaleDB Docker](https://docs.timescale.com/self-hosted/latest/install/installation-docker/)
- [OpenFGA Docker](https://openfga.dev/docs/getting-started/setup-openfga/docker)
- Per-stack official documentation linked from each `{stack}/README.md`

---

## License

Apache License 2.0 — see [LICENSE](LICENSE).

Copyright 2026 Guido Mauricio Mantilla Tarazona (guidomau / usq0x6e.co). Bogotá, Colombia.
