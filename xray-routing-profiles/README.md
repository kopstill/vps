# Xray 分流配置

这套配置面向已经可用的 Xray 客户端，只提供 `dns` 和 `routing` 片段，不覆盖你现有的节点参数、TLS、Reality、WS、gRPC 等出站细节。

## 规则源

- `Loyalsoldier/v2ray-rules-dat`：当前最常见、维护活跃的 `geosite.dat` / `geoip.dat` 增强规则集，适用于 Xray。
- 上游域名分类来自 `v2fly/domain-list-community`。

## 文件说明

- `mainland.fragment.json`：适合中国大陆使用，白名单模式。
  - 大陆/局域网/港澳 IP 直连。
  - 广告和 BT 拦截。
  - 其它流量默认走代理。
- `hongkong.fragment.json`：适合香港使用，黑名单/PAC 风格。
  - 大部分站点直连。
  - `gfw`、`category-anticensorship`、`telegram` 走代理。
  - 广告和 BT 拦截。
- `update-geodata.sh`：更新 `geoip.dat` 和 `geosite.dat` 的脚本。

## 使用前提

你的现有 `outbounds` 里至少要有这三个标签：

```json
[
  {
    "tag": "proxy"
  },
  {
    "protocol": "freedom",
    "tag": "direct"
  },
  {
    "protocol": "blackhole",
    "tag": "block"
  }
]
```

如果你现在的标签名不是 `proxy` / `direct` / `block`，只改这三个 `tag` 名称，不要改规则顺序。

## 建议的接入方式

1. 先执行 `update-geodata.sh`，把 `geoip.dat` 和 `geosite.dat` 放到 Xray 能读取的位置。
2. 把对应 profile 里的 `dns` 和 `routing` 合并到你的客户端主配置。
3. 如果你用的是 `tun`、`dokodemo-door` 或透明代理，给相应 `inbound` 打开 `sniffing`，否则基于域名的规则命中率会下降。

参考 `sniffing`：

```json
"sniffing": {
  "enabled": true,
  "destOverride": ["http", "tls", "quic"]
}
```

## 切换建议

- 常驻中国大陆：用 `mainland.fragment.json`
- 常驻香港：用 `hongkong.fragment.json`
- 如果你人在香港，但希望 ChatGPT/流媒体/部分美区服务固定走美国 VPS，可以在 `hongkong.fragment.json` 的 `proxy-gfw-domains` 规则上方，额外插入你自己的强制代理域名规则。

## 更新命令

默认目标目录是 `/usr/local/share/xray`：

```sh
./update-geodata.sh
```

如果你的系统把 geodata 放在 `/usr/share/xray`：

```sh
./update-geodata.sh /usr/share/xray
```

## 注意点

- `mainland.fragment.json` 我把 `geoip:hk` 和 `geoip:mo` 也放进了直连，原因是你在大陆时访问港澳站点通常没必要回美国再绕一圈。
- `hongkong.fragment.json` 默认是性能优先，不是“全都走美国出口”。如果你要的是固定美区出口，这份配置就不够，应该再做一份香港场景下的“半白名单”版本。
