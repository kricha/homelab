#!/usr/bin/sh
docker compose down
docker compose --env-file /mnt/smb/docker/pihole/.env up -d