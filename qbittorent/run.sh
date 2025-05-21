#!/usr/bin/sh
docker compose down
docker compose --env-file /mnt/smb/docker/qbittorrent/.env up -d