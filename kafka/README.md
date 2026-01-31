# Kafka Stack

## Servicios

| Servicio | Puerto | `restart:` | Funcion |
|----------|--------|-----------|---------|
| kafka-zookeeper | 2181 | `no` | Coordinador del cluster |
| kafka-broker | 9092, 9093, 29092, 9999 | `no` | Broker de mensajes |
| kafka-webui | 8080 | `no` | UI de administracion |

## Dependencias

```
kafka-zookeeper
  └─→ kafka-broker
        └─→ kafka-webui
```

## Puertos

- `2181` — ZooKeeper client
- `9092` — Kafka external listener
- `9093` — Kafka external listener (alt)
- `29092` — Kafka Docker listener
- `9999` — JMX
- `8080` — Kafka UI

## Nota

Conflicta con redpanda (mismos puertos). No pueden correr simultaneamente.
