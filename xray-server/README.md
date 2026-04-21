# Xray Server-Side Assets

Server-side bits for the Xray install on the VPS. Client routing lives in the
top-level `clash-*.template.yaml` (Mihomo) — this directory only contains
things that run on the VPS itself.

## `routing.json`

Minimal server-side routing fragment. The client (Mihomo) already decides what
to proxy, so the server only needs four rules:

1. **`block-bittorrent`** — drop BT traffic so the provider's TOS is not violated.
2. **`block-ads`** — drop `geosite:category-ads-all` to save outbound bandwidth.
3. **`block-private-ip`** — refuse `geoip:private` targets so the proxy cannot
   be pivoted into the server's own LAN (defense against RFC1918 probing).
4. **`direct-catch-all`** — send everything else out via the `freedom` outbound.

Merge into your existing `/usr/local/etc/xray/config.json`. The `outbounds`
array must provide `direct` (freedom) and `block` (blackhole) tags:

```json
{
  "outbounds": [
    { "protocol": "vless", "tag": "proxy", "settings": { "...": "..." } },
    {
      "protocol": "freedom",
      "tag": "direct",
      "settings": { "domainStrategy": "UseIPv4" }
    },
    { "protocol": "blackhole", "tag": "block" }
  ]
}
```

## `update-geodata.sh`

Refresh `geoip.dat` / `geosite.dat` from Loyalsoldier's release. Run on the
VPS after provisioning and via cron weekly.

```sh
# Default target: /usr/local/share/xray
./update-geodata.sh

# Override target (some distros use /usr/share/xray)
./update-geodata.sh /usr/share/xray
```

Script verifies sha256 before installing and cleans up the temp dir on exit.
