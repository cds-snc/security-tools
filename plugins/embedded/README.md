# Embedded Linux Plugins

This directory contains YAML plugins specifically designed for **embedded Linux systems** including Yocto, Buildroot, OpenWrt, and IoT distributions.

## Overview

Embedded plugins target services and configurations common in:
- **Industrial IoT** (IIoT gateways, PLCs)
- **Edge Computing** (K3s, lightweight containers)
- **Consumer IoT** (smart home, wearables)
- **Network Appliances** (routers, VPN gateways)
- **Automotive/Medical** (safety-critical embedded systems)

## Key Differences from Desktop Plugins

1. **Lightweight Services**: dropbear (vs OpenSSH), lighttpd (vs Apache/Nginx), iwd (vs wpa_supplicant)
2. **Read-Only Rootfs**: Config paths may be in `/etc` (writable overlay) or `/data`
3. **Auto-Generated Certs**: k3s, systemd socket activation often auto-generate TLS on first boot
4. **Resource Constraints**: Minimal config parsing, optimized for low memory
5. **Industrial Protocols**: Modbus, OPC-UA, MQTT focus over HTTP/HTTPS

## Plugin Categories

### Core System Services (8)
- `systemd.yaml` - Init system, socket activation
- `udev.yaml` - Device management
- `dbus.yaml` - IPC system
- `avahi.yaml` - mDNS/DNS-SD
- `bluez.yaml` - Bluetooth stack
- `wpa_supplicant.yaml` - WiFi/802.1X
- `iwd.yaml` - Intel wireless daemon
- `NetworkManager.yaml` - Network management

### Lightweight Web/API (4)
- `lighttpd.yaml` - Lightweight web server
- `uhttpd.yaml` - OpenWrt micro HTTP server
- `mongoose.yaml` - Embedded web server library
- `dropbear.yaml` - SSH server (embedded)

### IoT/MQTT (3)
- `mosquitto.yaml` - MQTT broker
- `paho-mqtt.yaml` - MQTT client library
- `node-red.yaml` - IoT flow programming

### Container/Orchestration (2)
- `balena-engine.yaml` - Container engine for IoT
- `k3s.yaml` - Lightweight Kubernetes

### Industrial/SCADA (3)
- `codesys.yaml` - Industrial automation runtime
- `openplc.yaml` - PLC runtime
- `modbus-tcp.yaml` - Modbus TCP gateway

### Time/Security (4)
- `chrony.yaml` - NTP client/server
- `strongswan.yaml` - IPsec VPN
- `openvpn.yaml` - VPN (embedded builds)
- `tinc.yaml` - Mesh VPN

### Device-Specific (3)
- `u-boot.yaml` - Bootloader (secure boot keys)
- `optee.yaml` - Trusted execution environment
- `mbedtls.yaml` - Lightweight TLS library

## Priority Tiers

**Tier 1 (Critical)**: strongswan, k3s, wpa_supplicant
**Tier 2 (High)**: lighttpd, mosquitto, dropbear, systemd
**Tier 3 (Medium)**: chrony, iwd, balena-engine, tinc, bluez, NetworkManager
**Tier 4 (Lower)**: uhttpd, node-red, avahi, dbus, udev, openplc

## Usage

```bash
# List embedded plugins
cbom-generator --plugin-dir plugins/embedded --list-plugins

# Scan with embedded plugins
cbom-generator --plugin-dir plugins/embedded --discover-services --output embedded-cbom.json

# Scan with both standard and embedded plugins
cbom-generator --plugin-dir plugins --discover-services --output full-cbom.json
# Note: Plugin manager scans subdirectories automatically
```

## Testing

```bash
# Validate embedded plugins
./tests/validate_all_plugins.sh plugins/embedded

# Test on Yocto/Buildroot image
scp cbom-generator root@embedded-device:/tmp/
ssh root@embedded-device "/tmp/cbom-generator --plugin-dir /tmp/plugins/embedded --output /tmp/cbom.json"
```

## Creating Custom Embedded Plugins

Use the standard plugin creation script with embedded-specific considerations:

```bash
# Create new embedded plugin
./scripts/create_plugin.sh ServiceName embedded_category PORT

# Example: Create a custom industrial service
./scripts/create_plugin.sh OpcUa industrial 4840 opcua custom
```

### Embedded-Specific Config Paths

Common config locations in embedded systems:
- `/etc/` - Configuration files (may be overlayfs writable layer)
- `/data/` - Persistent storage (common in read-only rootfs)
- `/var/lib/` - Service state/keys (often writable)
- `/run/` - Runtime state (tmpfs, not persistent)
- `/opt/[vendor]/` - Vendor-specific installations

### Detection Method Recommendations

**Process Detection**: Most reliable for embedded (services often running)
**Port Detection**: Good for network services (embedded devices are often networked)
**Config File Detection**: Less reliable (read-only rootfs, minimal configs)
**Systemd Detection**: Very reliable for modern embedded (Yocto default)
**Package Detection**: Reliable for package-based systems (not custom Buildroot)

## Known Limitations

1. **OpenWrt UCI Format**: Requires custom parser (not yet implemented)
2. **Binary Libraries**: mongoose, paho-mqtt, mbedtls require binary inspection
3. **Bootloader Detection**: u-boot keys in flash, limited runtime detection
4. **Proprietary Systems**: codesys has limited open documentation
5. **Hardware TEE**: optee requires device-specific enumeration

## Contributing

When adding new embedded plugins:
1. Research typical config paths in Yocto, Buildroot, OpenWrt
2. Test on actual embedded distributions when possible
3. Document vendor-specific variations
4. Consider read-only rootfs scenarios
5. Optimize for minimal resource usage

## References

- [Yocto Project](https://www.yoctoproject.org/)
- [Buildroot](https://buildroot.org/)
- [OpenWrt](https://openwrt.org/)
- [K3s Documentation](https://k3s.io/)
- [strongSwan Configuration](https://docs.strongswan.org/)
- [wpa_supplicant Configuration](https://w1.fi/wpa_supplicant/)

---

**Version**: 1.4.0
**Last Updated**: November 18, 2025
**Plugin Count**: 19 embedded-specific plugins
