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
