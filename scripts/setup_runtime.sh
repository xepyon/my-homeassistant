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

CONFIG_DIR="${CONFIG_DIR:-/srv/homeassistant/config}"
MARIADB_DIR="${MARIADB_DIR:-/srv/mariadb}"
MS_DATA_DIR="${MS_DATA_DIR:-/srv/matter-server/data}"

# New: Mosquitto & Zigbee2MQTT config dirs (override in .env if you like)
MOSQUITTO_CONFIG_DIR="${MOSQUITTO_CONFIG_DIR:-$PWD/mosquitto/config}"
Z2M_CONFIG_DIR="${Z2M_CONFIG_DIR:-$PWD/zigbee2mqtt/config}"

echo "==> Creating runtime directories (may prompt for sudo)..."
sudo mkdir -p \
  "$CONFIG_DIR" \
  "$MARIADB_DIR" \
  "$MS_DATA_DIR" \
  "$MOSQUITTO_CONFIG_DIR" \
  "$Z2M_CONFIG_DIR"

# Try to chown to current user (safe even if owned by root/docker)
if sudo chown -R "$USER":"$USER" \
  "$(dirname "$CONFIG_DIR")" \
  "$MARIADB_DIR" \
  "$MS_DATA_DIR" \
  "$MOSQUITTO_CONFIG_DIR" \
  "$Z2M_CONFIG_DIR" 2>/dev/null; then
  echo "==> Ownership set to $USER"
else
  echo "[INFO] Could not change ownership; continuing."
fi

# Copy example Home Assistant configs if missing
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
DB_HOST="${MARIADB_CONTAINER_NAME:-mariadb}"
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

########################################
# Mosquitto example config
########################################
EX_MOSQ_CONF="mosquitto/config/mosquitto.conf.example"
DST_MOSQ_CONF="$MOSQUITTO_CONFIG_DIR/mosquitto.conf"

if [[ -f "$EX_MOSQ_CONF" ]]; then
  if [[ ! -f "$DST_MOSQ_CONF" ]]; then
    echo "==> Installing example Mosquitto config: $DST_MOSQ_CONF"
    cp "$EX_MOSQ_CONF" "$DST_MOSQ_CONF"
  else
    echo "[OK] $DST_MOSQ_CONF already exists (leaving as is)."
  fi
else
  echo "[WARN] Example Mosquitto config not found at $EX_MOSQ_CONF"
fi

########################################
# Zigbee2MQTT example config
########################################
EX_Z2M_CONF="zigbee2mqtt/config/configuration.yaml.example"
DST_Z2M_CONF="$Z2M_CONFIG_DIR/configuration.yaml"

if [[ -f "$EX_Z2M_CONF" ]]; then
  if [[ ! -f "$DST_Z2M_CONF" ]]; then
    echo "==> Installing example Zigbee2MQTT config: $DST_Z2M_CONF"
    cp "$EX_Z2M_CONF" "$DST_Z2M_CONF"
  else
    echo "[OK] $DST_Z2M_CONF already exists (leaving as is)."
  fi
else
  echo "[WARN] Example Zigbee2MQTT config not found at $EX_Z2M_CONF"
fi

echo
echo "==> Summary"
echo "  CONFIG_DIR         : $CONFIG_DIR"
echo "  MARIADB_DIR        : $MARIADB_DIR"
echo "  MS_DATA_DIR        : $MS_DATA_DIR"
echo "  MOSQUITTO_CONFIG_DIR: $MOSQUITTO_CONFIG_DIR"
echo "  Z2M_CONFIG_DIR     : $Z2M_CONFIG_DIR"
echo "  configuration.yaml (HA): $( [[ -f "$DST_CONF" ]] && echo present || echo missing )"
echo "  secrets.yaml (HA)      : $( [[ -f "$DST_SECR" ]] && echo present || echo missing )"
echo "  mosquitto.conf         : $( [[ -f "$DST_MOSQ_CONF" ]] && echo present || echo missing )"
echo "  Zigbee2MQTT config     : $( [[ -f "$DST_Z2M_CONF" ]] && echo present || echo missing )"

echo
echo "Next:"
echo "  1) Review $DST_SECR (ensure password matches .env DB_PASSWORD if you want them identical)."
echo "  2) Review $DST_MOSQ_CONF and $DST_Z2M_CONF and adjust as needed."
echo "  3) Start the stack: ./scripts/up.sh"

