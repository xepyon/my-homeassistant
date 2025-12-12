# 🏠 Home Assistant + MariaDB (Docker Compose)

A simple and production-ready Docker Compose setup for **Home Assistant** with **MariaDB** as the recorder database.

---

## 📦 Overview

- **Persistent config:** `/srv/homeassistant/config`
- **Persistent database:** `/srv/mariadb`
- **Repo path:** `~/dockercompose/production/homeassistant/`

The stack is designed to be portable, version-controlled, and easily recoverable.

---

## 🚀 One-time bootstrap

```bash
cd ~/dockercompose/production/homeassistant
cp .env.example .env
$EDITOR .env   # adjust versions, TZ, and passwords

./scripts/setup_runtime.sh   # create /srv dirs, install example configs
./scripts/up.sh              # start the stack
```

Once it’s running, open  
👉 `http://<your-host-ip>:8123`

and complete the initial Home Assistant setup.

---

## 🔁 Day-to-day usage

Start / stop / update the stack:

```bash
./scripts/up.sh
./scripts/down.sh
./scripts/update.sh
```

Check logs:

```bash
docker compose logs -f homeassistant
docker compose logs -f mariadb
```

---

## 💾 Backups

Run:

```bash
./scripts/backup.sh
```

This produces:
- `homeassistant-backup-<STAMP>.sql` → MariaDB dump  
- `homeassistant-backup-<STAMP>.tar.gz` → Home Assistant `/config` archive

Both are stored in your `$HOME` directory.

---

## ⚙️ Configuration

Home Assistant reads its config from  
`/srv/homeassistant/config/configuration.yaml`

If this directory doesn’t exist, run `./scripts/setup_runtime.sh` again.  
Edit your configuration directly on the host — it’s automatically reflected inside the container.

---

## 🔁 Updating

```bash
cd ~/dockercompose/production/homeassistant
./scripts/update.sh
```

This pulls new container images and restarts the stack with the same volumes and settings.

---

## 🧱 Optional: auto-start at boot

You can enable automatic startup using a simple systemd service:

```bash
sudo systemctl enable homeassistant-compose --now
```

The corresponding unit file is included in documentation examples.

---

## ✅ Quick checklist

- `.env` created and edited  
- `./scripts/setup_runtime.sh` completed successfully  
- `/srv/homeassistant/config/` and `/srv/mariadb/` created  
- Stack up with `./scripts/up.sh`  
- UI available at `http://<host-ip>:8123`

---

### Notes

- Keep `/srv/homeassistant/config` and `/srv/mariadb` on reliable SSD storage.  
- Tune `purge_keep_days` in `configuration.yaml` to control DB growth.  
- Update periodically to get new Home Assistant and MariaDB versions.  
- The setup avoids data loss by separating **runtime data** (`/srv/...`) from **code** (this repo).

---

## DOCUMENTATION

Home Assistant: https://www.home-assistant.io/docs/
MariaDB: https://mariadb.com/kb/en/getting-started-with-mariadb/
Docker Compose: https://docs.docker.com/compose/

## DOCUMENTATION HOME ASSISTANT SERVERS

### Python-matter-server

Documentation: https://www.home-assistant.io/integrations/matter/
Repository: https://github.com/matter-js/python-matter-server/blob/main/docs/docker.md
Container: https://github.com/matter-js/python-matter-server/blob/main/docs/docker.md#running-matter-server-in-docker

## DOCUMENTATION HOME ASSISTANT APPS

### Home Assistant Companion App

Documentation: https://www.home-assistant.io/integrations/mobile_app/
Repository: https://github.com/home-assistant/core/tree/dev/homeassistant/components/mobile_app

#### MOBILE APP TRACKING TROUBLESHOOTING

https://companion.home-assistant.io/docs/troubleshooting/faqs/#starting-fresh-with-the-android-app
https://community.home-assistant.io/t/enable-device-phone-tracking-after-setting-up-ha-app-android/445828/36

**Enjoy your automated home — safe, reproducible, and easy to maintain!**


# APPS

## HOMEKIT

------------------------------------------------------------------------

# 1. Ubuntu Host (Home Assistant Container) Checks

## ✔️ 1.1 Confirm Home Assistant is running in host mode

``` bash
docker inspect homeassistant --format '{{ .HostConfig.NetworkMode }}'
```

## ✔️ 1.2 Check HomeKit Bridge port is listening

``` bash
sudo ss -tulnp | grep 21064
```

## ✔️ 1.3 Confirm firewall is not blocking anything

``` bash
sudo ufw status
```

## ✔️ 1.4 Test port connectivity from another LAN device

``` bash
nc -vz <ubuntu-ip> 21064
```

## ✔️ 1.5 Check mDNS visibility (optional)

``` bash
dns-sd -B _hap._tcp
```

------------------------------------------------------------------------

# 2. ASUS ZenWiFi (AP Mode) Configuration Checklist

## 2.1 Wireless → Professional (per band)

Settings: - Enable IGMP Snooping: **Disable** - Set AP Isolated:
**No** - Airtime Fairness: **Disable** - Multicast Rate: Auto - WMM:

OPTIONAL -> Enable - Roaming Assistant: Disable -> THIS ONE IS UNNECESSARY, that is why commented

------------------------------------------------------------------------

# 2.2 AP Mode Limitations

ASUS ZenWiFi AP mode **does not forward multicast (mDNS)** from wired →
Wi-Fi.

Symptoms: - HomeKit Bridge not discoverable - AirPlay/Chromecast
discovery issues

------------------------------------------------------------------------

# 2.3 Fixes

## ✔️ Fix A: Switch to Router Mode or AiMesh Router Mode

Path: **Administration → Operation Mode → Wireless router mode**

## ✔️ Fix B: Media Bridge Mode

(if available)

## ✔️ Fix C: Connect iPad to main router's Wi-Fi

Tests if ASUS AP is blocking mDNS.

------------------------------------------------------------------------

# 3. Final Pairing Steps

1.  Reboot ASUS
2.  Restart HA container
3.  iPad Wi-Fi OFF → ON
4.  Home → Add Accessory → More Options

