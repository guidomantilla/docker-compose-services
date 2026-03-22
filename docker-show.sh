#!/bin/bash

separator() { printf '%.0s─' $(seq 1 "${1:-80}"); echo; }

echo
echo "╔══════════════════════════════╗"
echo "║       DOCKER IMAGES          ║"
echo "╚══════════════════════════════╝"
docker image ls --format "{{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}" \
  | sort \
  | awk -F'\t' 'BEGIN { printf "%-50s %-15s %-10s %s\n", "REPOSITORY", "TAG", "SIZE", "CREATED"; print "" } { printf "%-50s %-15s %-10s %s\n", $1, $2, $3, $4 }'

echo
echo "╔══════════════════════════════╗"
echo "║      DOCKER CONTAINERS       ║"
echo "╚══════════════════════════════╝"
docker container ls -a --format "{{.Names}}\t{{.Status}}\t{{.Ports}}" \
  | sort \
  | while IFS=$'\t' read -r name status ports; do
      clean=$(echo "$ports" | grep -oE '0\.0\.0\.0:[0-9]+(-[0-9]+)?' | sed 's/0\.0\.0\.0://' | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')
      printf "%-30s %-35s %s\n" "$name" "$status" "$clean"
    done \
  | (printf "%-30s %-35s %s\n\n" "NAME" "STATUS" "PORTS"; cat)

echo
echo "╔══════════════════════════════╗"
echo "║      DOCKER NETWORKS         ║"
echo "╚══════════════════════════════╝"
docker network ls --format "{{.Name}}\t{{.Driver}}" \
  | sort \
  | awk -F'\t' 'BEGIN { printf "%-30s %s\n", "NAME", "DRIVER"; print "" } { printf "%-30s %s\n", $1, $2 }'

echo
echo "╔══════════════════════════════╗"
echo "║       DOCKER VOLUMES         ║"
echo "╚══════════════════════════════╝"
docker volume ls --format "{{.Name}}\t{{.Driver}}" \
  | sort \
  | awk -F'\t' 'BEGIN { printf "%-50s %s\n", "NAME", "DRIVER"; print "" } { printf "%-50s %s\n", $1, $2 }'
echo
