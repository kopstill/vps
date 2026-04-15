#!/usr/bin/env sh
set -eu

TARGET_DIR="${1:-/usr/local/share/xray}"
BASE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

check_sum() {
  file="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum -c "$file"
  else
    shasum -a 256 -c "$file"
  fi
}

mkdir -p "$TARGET_DIR"

curl -fsSL "$BASE_URL/geoip.dat" -o "$TMP_DIR/geoip.dat"
curl -fsSL "$BASE_URL/geosite.dat" -o "$TMP_DIR/geosite.dat"
curl -fsSL "$BASE_URL/geoip.dat.sha256sum" -o "$TMP_DIR/geoip.dat.sha256sum"
curl -fsSL "$BASE_URL/geosite.dat.sha256sum" -o "$TMP_DIR/geosite.dat.sha256sum"

(
  cd "$TMP_DIR"
  check_sum geoip.dat.sha256sum
  check_sum geosite.dat.sha256sum
)

install -m 0644 "$TMP_DIR/geoip.dat" "$TARGET_DIR/geoip.dat"
install -m 0644 "$TMP_DIR/geosite.dat" "$TARGET_DIR/geosite.dat"

echo "updated geoip.dat and geosite.dat in $TARGET_DIR"
