# Jellyfin in Docker on Proxmox LXC with Hardware Transcoding

This sets up Jellyfin, a self-hosted media server, in Docker on an unprivileged Proxmox LXC container (Ubuntu 24.10 in my case). It uses hardware transcoding (e.g., Intel iGPU) and exposes Jellyfin securely to the internet via a Cloudflare Zero Trust tunnel.

## Prerequisites
- Proxmox VE installed.
- NAS or storage with media files (e.g., `/mnt/pve/nas-media/`).
- Cloudflare account with Zero Trust tunnel configured.
- Basic knowledge of LXC, Docker, and Linux.

## LXC Configuration
### Key Settings
In Proxmox, create an unprivileged LXC container with:
```
dev0: /dev/dri/card0,gid=44
dev1: /dev/dri/renderD128,gid=104
mp0: /mnt/pve/nas-media/,mp=/media,ro=1
mp1: /mnt/docker/jellyfin,mp=/mnt/docker/jellyfin
unprivileged: 1
```
- **`dev0`/`dev1`**: Pass GPU devices for HW transcoding (`gid=44` is `video`, `gid=104` is `render`).
- **`mp0`**: Mounts read-only media from host to `/media`:
    ```
    /media/
    ├── Movies
    └── Shows
    ```
- **`unprivileged: 1`**: Enhances security.

### Mounting NAS on Host
Mount the NAS share to the host via `/etc/fstab` to avoid permission issues in LXC:
1. Create mount point:
    ```bash
    mkdir /mnt/docker
    ```
2. Add to `/etc/fstab`:
    ```bash
    echo "//NAS_IP/docker /mnt/docker cifs credentials=/root/.credentials-docker,_netdev,x-systemd.automount,noatime,uid=101000,gid=101000,dir_mode=0770,file_mode=0770 0 0" >> /etc/fstab
    ```
3. Create `/root/.credentials-docker`:
    ```text
    username=SMB_USERNAME
    password=SMB_PASSWORD
    ```
4. Apply:
    ```bash
    systemctl daemon-reload
    mount -a
    ```
    - **Note**: `uid=101000,gid=101000` fixes LXC permission quirks.
### Useful links
 - [fixing nobody/nogroup permission issue on mount](https://forum.proxmox.com/threads/lxc-idmap-home-directory-nobody-nogroup.103643/)
 - [jellyfin HW acceleration](https://jellyfin.org/docs/general/administration/hardware-acceleration/)
 - [cloudflare tunnel documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/)