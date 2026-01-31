# SonarQube Stack

## Servicios

| Servicio | Puerto | `restart:` | Funcion |
|----------|--------|-----------|---------|
| sonarqube-server | 19000 | `no` | Analisis de calidad de codigo |
| sonarqube-postgres | — (interno) | `no` | BD dedicada para SonarQube |

## Dependencias

```
sonarqube-postgres
  └─→ sonarqube-server
```

## Puertos

- `19000:9000` — SonarQube UI (remapeado para evitar conflicto con minio en 9000)

## Credenciales

Desde `.envrc`:
- `SONARQUBE_JDBC_USERNAME` — usuario de PostgreSQL
- `SONARQUBE_JDBC_PASSWORD` — password de PostgreSQL
- `SONARQUBE_JDBC_DATABASE` — nombre de la BD

## Nota

PostgreSQL interno no expone puertos al host. Solo es accesible via `sonarqube-network`.
