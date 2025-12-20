#!/usr/bin/env bash
set -euo pipefail

# Move to repo root (script may be called from anywhere)
cd "$(dirname "$0")/.."

# Load .env if present; otherwise fall back to example
if [[ -f .env ]]; then
  set -a; source .env; set +a
else
  echo "[WARN] .env not found. Using defaults from .env.example"
  set -a; source .env.example; set +a
fi

# Setup runtime directories based on environment
if [[ -z "$1" == "dev" ]]; then
  echo "==> Setting up runtime directories for DEVELOPMENT environment"
  sudo mkdir -p /srv/ha/dev
  sudo chown "$USER":"$USER" /srv/ha/dev
  CONFIG_DIR="${CONFIG_DIR:-/srv/ha/dev/homeassistant/config}"
  MARIADB_DIR="${MARIADB_DIR:-/srv/ha/dev/mariadb}"
  MS_DATA_DIR="${MS_DATA_DIR:-/srv/ha/dev/matter-server/data}"
  MOSQUITTO_DIR="${MOSQUITTO_DIR:-/srv/ha/dev/mosquitto/data}"
  ZIGBEE2MQTT_DIR="${ZIGBEE2MQTT_DIR:-/srv/ha/dev/zigbee2mqtt/data}"
elif [[ -z "$1" == "prod" ]]; then
  echo "==> Setting up runtime directories for PRODUCTION environment"
  sudo mkdir -p /srv/ha/prod
  sudo chown "$USER":"$USER" /srv/ha/prod
  CONFIG_DIR="${CONFIG_DIR:-/srv/ha/prod/homeassistant/config}"
  MARIADB_DIR="${MARIADB_DIR:-/srv/ha/prod/mariadb}"
  MS_DATA_DIR="${MS_DATA_DIR:-/srv/ha/prod/matter-server/data}"
  MOSQUITTO_DIR="${MOSQUITTO_DIR:-/srv/ha/dev/mosquitto/data}"
  ZIGBEE2MQTT_DIR="${ZIGBEE2MQTT_DIR:-/srv/ha/dev/zigbee2mqtt/data}"
else
  echo "==> Could not determine environment (dev/prod). Please specify as first argument."
  exit 1
fi

# Copy example configs if missing
EX_SRC_CONF="homeassistant/config/configuration.yaml.example"
EX_SRC_SECR="homeassistant/config/secrets.yaml.example"
DST_CONF="$CONFIG_DIR/configuration.yaml"
DST_SECR="$CONFIG_DIR/secrets.yaml"

if [[ ! -f "$DST_CONF" ]]; then
  echo "==> Installing example Home Assistant configuration: $DST_CONF"
  cp "$EX_SRC_CONF" "$DST_CONF"
else
  echo "[OK] $DST_CONF already exists (leaving as is)."
fi

# Prepare secrets: prefer DB_PASSWORD from .env; else generate a random value
ENV_DB_PASS="${DB_PASSWORD:-}"
if [[ -z "$ENV_DB_PASS" ]]; then
  echo "[INFO] DB_PASSWORD not set; generating a random one for secrets.yaml"
  ENV_DB_PASS="$(tr -dc 'A-Za-z0-9!@#%^_+=' </dev/urandom | head -c 24)"
fi

if [[ ! -f "$DST_SECR" ]]; then
  echo "==> Creating secrets file: $DST_SECR"
  cat > "$DST_SECR" <<EOF
db_password: ${ENV_DB_PASS}
EOF
else
  echo "[OK] $DST_SECR already exists (leaving as is)."
fi

# ... after loading .env
DB_HOST="${MARIADB_CONTAINER_NAME:-mariadb}"   # or "${MARIADB_CONTAINER_NAME:-mariadb}" if both are on same bridge network
RECORDER_DB_URL="mysql://ha:${DB_PASSWORD}@${MARIADB_CONTAINER_NAME:-mariadb}:3306/homeassistant?charset=utf8mb4"

if [[ ! -f "$DST_SECR" ]]; then
  cat > "$DST_SECR" <<EOF
db_password: ${DB_PASSWORD:-$ENV_DB_PASS}
recorder_db_url: ${RECORDER_DB_URL}
EOF
else
  # update/ensure keys exist without clobbering others
  awk -v url="$RECORDER_DB_URL" -v pass="${DB_PASSWORD:-$ENV_DB_PASS}" '
    BEGIN{found1=found2=0}
    /^db_password:/ {print "db_password: " pass; found1=1; next}
    /^recorder_db_url:/ {print "recorder_db_url: " url; found2=1; next}
    {print}
    END{
      if(!found1) print "db_password: " pass
      if(!found2) print "recorder_db_url: " url
    }' "$DST_SECR" > "$DST_SECR.tmp" && mv "$DST_SECR.tmp" "$DST_SECR"
fi

echo
echo "==> Summary"
echo "  CONFIG_DIR : $CONFIG_DIR"
echo "  MARIADB_DIR: $MARIADB_DIR"
echo "  MS_DATA_DIR: $MS_DATA_DIR"
echo "  configuration.yaml: $( [[ -f "$DST_CONF" ]] && echo present || echo missing )"
echo "  secrets.yaml      : $( [[ -f "$DST_SECR" ]] && echo present || echo missing )"

echo
echo "Next:"
echo "  1) Review $DST_SECR (ensure password matches .env DB_PASSWORD if you want them identical)."
echo "  2) Start the stack: ./scripts/up.sh"

