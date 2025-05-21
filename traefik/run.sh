#!/usr/bin/sh
docker compose down
docker compose --env-file /mnt/smb/docker/traefik/.env up -d