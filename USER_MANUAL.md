# CBOM Generator — User Manual

**Version**: 1.9.0
**Date**: December 2025
**Platform**: Linux (Ubuntu, RHEL, Debian)

---

## Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Quick Start](#quick-start)
4. [CLI Reference](#cli-reference)
5. [Feature Guide](#feature-guide)
6. [Reading CycloneDX CBOM Output](#reading-cyclonedx-cbom-output)
7. [Use Cases & Examples](#use-cases--examples)
8. [Interpreting Results](#interpreting-results)
9. [Troubleshooting](#troubleshooting)

---

## Introduction

### What is CBOM Generator?

The **Cryptographic Bill of Materials (CBOM) Generator** is a production-ready, high-performance C11 multithreaded application that inventories cryptographic assets on Linux systems to assess Post-Quantum Cryptography (PQC) readiness.

**Key Capabilities**:
- 🔐 **Comprehensive Asset Discovery**: Certificates, keys, packages, services, protocols, cipher suites
- 🔗 **Complete Dependency Graph**: Tracks relationships between services, protocols, and algorithms
- 🛡️ **PQC Readiness Assessment**: Analyzes quantum vulnerability across your entire cryptographic infrastructure
- ⚡ **High Performance**: Scans 12,000+ files/minute with parallel processing
- 🔒 **Privacy-by-Default**: GDPR/CCPA compliant with configurable redaction
- ✅ **Industry Standards**: Outputs CycloneDX 1.6/1.7 format with CBOM extensions

### Why Use CBOM Generator?

**For Security Teams**:
- Inventory all cryptographic assets before quantum computers break current encryption
- Identify weak or deprecated algorithms that need immediate replacement
- Track certificate expiration and trust issues
- Map service dependencies on cryptographic components

**For Compliance**:
- Generate machine-readable cryptographic inventories for audits
- Track FIPS 140-2/3 certified implementations
- Document privacy controls and data redaction
- Provide SLSA provenance for build transparency

**For Operations**:
- Discover all TLS/SSH configurations across infrastructure
- Identify services using deprecated protocols or cipher suites
- Plan migrations with PQC readiness scoring and recommendations

---

## What's New in v1.6

The v1.6 release introduces **Extensible Crypto Registry** via YAML configuration, enabling support for new distributions and custom crypto libraries without code changes:

| Feature | Status | Description |
|---------|--------|-------------|
| **YAML Crypto Registry** | ✅ Complete | External YAML files extend built-in crypto library registry |
| **Distribution Support** | ✅ Complete | Pre-built registries for Ubuntu (16 libs), Yocto (26 libs), OpenWrt (6 libs), Alpine (8 libs) |
| **Custom Libraries** | ✅ Complete | Detect BoringSSL, LibreSSL, GnuTLS, NSS, mbedTLS, wolfSSL without recompiling |
| **Graceful Degradation** | ✅ Complete | YAML failures are warnings, built-in registry always works |
| **CLI Flag** | ✅ Complete | `--crypto-registry FILE` loads external registry |

**New Capabilities in v1.6**:
- **No-Code Extension**: Add support for new crypto libraries by editing YAML (no recompilation)
- **Embedded Linux**: Detect Yocto/Buildroot-specific crypto implementations (dropbear, mbedTLS, wolfSSL)
- **OpenWrt Support**: Detect wolfSSL (default since Oct 2024), hostapd, dropbear, dnsmasq
- **Alpine/Container Support**: Detect musl-based OpenSSL, LibreSSL, container-focused services
- **Cloud Environments**: Recognize BoringSSL (Google), LibreSSL (OpenBSD forks)
- **JVM Crypto**: Detect Bouncy Castle and other Java crypto providers
- **Example Registries**: 4 distribution-specific registries included (Ubuntu, Yocto, OpenWrt, Alpine)

**Upgrade Impact**:
- Fully backward compatible with v1.5
- `--crypto-registry` flag is optional (default behavior unchanged)
- Built-in registry always available (5 libraries + 3 embedded apps)
- YAML extensions searched only after built-in registry

---

## What's New in v1.3

The v1.3 release introduces **YAML Plugin Architecture** for extensible service discovery and automated cryptographic configuration extraction:

| Feature | Status | Description |
|---------|--------|-------------|
| **YAML Plugin System** | ✅ Complete | Declarative service detection with 13 built-in plugins |
| **Service Discovery Engine** | ✅ Complete | 5 detection methods (process, port, config, systemd, package) |
| **Config Extraction Framework** | ✅ Complete | 6 parsers (INI, Apache, Nginx, YAML, JSON, OpenSSL cipher) |
| **Component Factory** | ✅ Complete | Automated component generation from discovered services |
| **Full Pipeline Integration** | ✅ Complete | End-to-end Phase 1→2→3→4 data flow |
| **13 Service Plugins** | ✅ Complete | PostgreSQL, MySQL, MongoDB, Nginx, Apache, Caddy, RabbitMQ, Kafka, Redis, MariaDB, CouchDB, OpenVPN, WireGuard |
| **CLI Enhancements** | ✅ Complete | --discover-services, --plugin-dir, --list-plugins flags |

**New Capabilities in v1.3**:
- **Automated Service Discovery**: Detect running services without manual configuration
- **TLS/SSL Config Extraction**: Automatically parse service configurations for crypto settings
- **Extensible Plugin System**: Add custom service detectors via YAML (no code required)
- **Full Relationship Mapping**: Trace complete dependency chain from service to algorithm
- **136+ Components**: Typical system now generates comprehensive service-level CBOM

**Upgrade Impact**:
- Fully backward compatible with v1.2
- New flags are optional (existing scans work unchanged)
- YAML plugins only load when --discover-services flag is used
- No breaking changes to output format

---

## What's New in v1.0

The v1.0 release represents a major milestone with comprehensive cryptographic inventory and PQC readiness capabilities:

| Feature | Status | Description |
|---------|--------|-------------|
| **Privacy-by-Default** | ✅ Complete | GDPR/CCPA compliant redaction with salted hashing |
| **CycloneDX 1.6/1.7** | ✅ Complete | Dual-schema support with `--cyclonedx-spec` flag |
| **cryptoProperties** | ✅ Complete | Full lifecycle tracking (certificates, keys, algorithms) |
| **PQC Readiness** | ✅ Complete | 4-category assessment (SAFE, TRANSITIONAL, DEPRECATED, UNSAFE) |
| **Relationship Graph** | ✅ Complete | Dependencies array + typed relationships with confidence |
| **Deduplication** | ✅ Complete | 3 modes (off, safe, strict) with evidence tracking |
| **5 Built-in Scanners** | ✅ Complete | Certificates, keys, packages, services, filesystem (plus application/library discovery and algorithm extraction) |
| **SSH Config Scanning** | ✅ Complete | Server, system client, user client (opt-in) with PQC KEX detection |
| **PQC Instance Counting** | ✅ Complete | Tracks both unique algorithms and deployment breadth |
| **Attestation Infrastructure** | ⏸️ Partial | SLSA provenance ✅, Digital signing ⏸️ (v1.1) |
| **FIPS Validation** | ⏸️ Stub | Metadata only, full CMVP integration in v1.1 |

**Breaking Changes from Beta**:
- Epoch fields renamed to `*_epoch` suffix (canonical: ISO-8601 in cryptoProperties)
- cryptoProperties structure now required for cryptographic assets
- dependencies array replaces legacy relationship format

---

## Installation

### Prerequisites

```bash
# Ubuntu/Debian
sudo apt-get install build-essential cmake libssl-dev libjson-c-dev libcurl4-openssl-dev

# RHEL/CentOS
sudo yum install gcc cmake openssl-devel json-c-devel libcurl-devel
```

**Required Dependencies**:
- OpenSSL 3.0+ (3.5+ recommended for PQC support)
- json-c 0.15+
- libcurl (latest)
- ncurses (for TUI)
- CMake 3.16+
- GCC with C11 support

### Build from Source

```bash
# Clone repository
git clone https://github.com/your-org/cryptoBOM.git
cd cryptoBOM

# Configure for release build
cmake -B build -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build build

# Install (optional)
sudo cmake --install build
```

### Verify Installation

```bash
./build/cbom-generator --version
# Output: CBOM Generator 1.0.0
```

---

## Quick Start

### Basic System Scan

```bash
# Scan entire system, output to stdout
./build/cbom-generator

# Save to file
./build/cbom-generator --output my-cbom.json

# Generate CycloneDX format
./build/cbom-generator --format cyclonedx --output cbom.cdx.json
```

### Privacy-Compliant Scan

```bash
# Privacy mode (default: redacts hostnames, paths, usernames)
./build/cbom-generator --no-personal-data --output cbom.json

# Include full paths (disable redaction)
./build/cbom-generator --include-personal-data --output cbom-full.json
```

### PQC Readiness Check

```bash
# Generate CBOM with PQC assessment
./build/cbom-generator --format cyclonedx --output pqc-assessment.json

# View PQC readiness score
jq '.pqc_assessment.readiness_score' pqc-assessment.json
# Output: "4.9" (4.9% ready - needs migration!)
```

---

## CLI Reference

### Output Options

#### `-o, --output FILE`
**Description**: Specify output file path (default: stdout)

**Examples**:
```bash
# Write to file
./build/cbom-generator --output /tmp/cbom.json

# Write to stdout (default)
./build/cbom-generator > cbom.json
```

#### `-f, --format FORMAT`
**Description**: Output format selection (vestigial flag - always outputs CycloneDX)

**Values**: `json`, `cyclonedx` (both produce identical CycloneDX output)

**Note**: The `--format` flag is accepted for backward compatibility but has no effect. The generator always outputs CycloneDX format regardless of this flag's value.

**Examples**:
```bash
# All of these produce identical CycloneDX output:
./build/cbom-generator --output cbom.json
./build/cbom-generator --format json --output cbom.json
./build/cbom-generator --format cyclonedx --output cbom.json
```

#### `--cyclonedx-spec VERSION`
**Description**: CycloneDX specification version

**Values**: `1.6` (default), `1.7`

**Examples**:
```bash
# CycloneDX 1.6 (default, maximum compatibility)
./build/cbom-generator --output cbom.json

# CycloneDX 1.7 (latest spec)
./build/cbom-generator --cyclonedx-spec=1.7 --output cbom.json
```

**Note**: Both versions produce identical content; only the `specVersion` field differs (`"1.6"` vs `"1.7"`).

---

### Privacy Options

#### `--no-personal-data` (Default: ON)
**Description**: Redact personal data for GDPR/CCPA compliance

**What is redacted**:
- Hostnames → `<host-hash-XXXXXXXX>`
- Home directories → `<path-hash-XXXXXXXX>`
- Usernames → salted hashes

**Examples**:
```bash
# Privacy mode (default)
./build/cbom-generator --no-personal-data --output cbom.json

# Explicitly enable (same as default)
./build/cbom-generator --no-personal-data --output cbom.json
```

#### `--include-personal-data`
**Description**: Include hostnames, usernames, full file paths, and scan user SSH configurations

**What this enables**:
- Hostnames in metadata (instead of `<host-hash-XXXXXXXX>`)
- Usernames in file paths (instead of `<user-username>`)
- Full home directory paths (instead of `<path-hash-XXXXXXXX>`)
- **User SSH config scanning** (~/.ssh/config for all users in /home/*)

**Use when**: Internal scans, debugging, or when GDPR/CCPA doesn't apply

**Examples**:
```bash
# Include all personal data + user SSH configs
./build/cbom-generator --include-personal-data --output cbom-full.json
```

**⚠️ Warning**: Output may contain sensitive information. Use appropriate access controls.

**Note**: User SSH config scanning is privacy-sensitive because it:
- Accesses user home directories
- Reveals individual user cryptographic preferences
- May expose non-public KEX algorithm choices

#### `--no-network`
**Description**: Disable network operations (vestigial flag - no network code in v1.0)

**Status**: The flag is accepted and recorded in output metadata, but has no functional effect in v1.0 because network operations (OCSP, CRL, NIST CMVP validation) are not yet implemented.

**Planned for v1.1+**:
- OCSP (Online Certificate Status Protocol) validation
- CRL (Certificate Revocation List) checking
- Remote NIST CMVP certification database queries
- Network-based trust validation

**Current behavior**: Flag is stored in metadata and sets `revocation_policy` to "disabled" vs "cache-only" in output, but no actual network operations occur regardless of flag value.

**Examples**:
```bash
# Flag accepted but has no effect in v1.0
./build/cbom-generator --no-network --output cbom.json

# Combine with privacy mode (both metadata-only in v1.0)
./build/cbom-generator --no-personal-data --no-network --output cbom.json
```

---

### Display Options

#### `--tui`
**Description**: Enable Terminal User Interface with real-time progress display

**Features**:
- Real-time progress bars for each scanner
- Live file counters and asset discovery counts
- Current directory being scanned
- Estimated completion percentage
- Asset breakdown by type (certs, keys, algorithms, libraries, protocols, services, cipher suites)
- Clean exit summary with PQC assessment

**Examples**:
```bash
# Enable TUI mode
./build/cbom-generator --tui --output cbom.json

# TUI with specific directory
./build/cbom-generator --tui /etc/ssl

# TUI with multiple paths
./build/cbom-generator --tui --output cbom.json /etc/ssl /etc/pki /usr/share
```

**Display Layout**:
```
+- CBOM Generator ------------------------- CipherIQ v1.0.0 -+
| Progress: [####################] 100%      Time: 00:00:03 |
+- Scanning Progress ------------------------------------------+
| [X] Certificate Scanner  215000 files   152 certs         |
| [X] Key Scanner         216000 files     0 keys           |
| [X] Package Scanner     System-wide      0 pkgs           |
| [X] Service Scanner     System-wide      0 svcs           |
| [X] Filesystem Scanner  164000 files  3689 files          |
| [X] Output Generation   System-wide      1 output         |
+- Status ----------------------------------------------------|
| Total Assets: 289 (193 certs, 16 keys, 14 algos, ...)     |
| COMPLETE                                                   |
+--------------------------------- Graziano Labs Corp. -+
  Press any key to exit
```

**After Completion**:
- Screen remains visible until you press any key
- Clean summary printed: PQC assessment + output filename
- No verbose log messages in TUI mode

**Use when**:
- Interactive scans where you want to monitor progress
- Large directory scans (prevents "hanging" appearance)
- Demonstrations or presentations
- Real-time visibility into scanning status

**Note on Error Visibility**:
In TUI mode, stderr is suppressed to prevent display corruption. Use `--error-log` to capture errors to a file for real-time monitoring.

---

#### `--pqc-report FILE` (v1.2+)
**Description**: Generate comprehensive PQC migration report in human-readable text format

**Features**:
- Executive summary with vulnerability breakdown
- Assets grouped by break year (2030/2035/2040/2045)
- Migration timeline with phased approach (2024-2045)
- NIST standards reference (FIPS 203/204/205)
- Prioritized recommendations and action items
- Risk assessment matrix
- Compliance guidance (NSA CNSA 2.0, FIPS 140-3)

**Examples**:
```bash
# Generate CBOM + PQC migration report
./build/cbom-generator /etc/ssl/certs \
  --output cbom.json \
  --pqc-report migration-report.txt

# View migration priorities
cat migration-report.txt

# TUI mode with PQC report
./build/cbom-generator --tui \
  --output cbom.json \
  --pqc-report pqc-report.txt
```

**Sample Report Output**:
```
═══════════════════════════════════════════════════════════════
       POST-QUANTUM CRYPTOGRAPHY MIGRATION REPORT
═══════════════════════════════════════════════════════════════

EXECUTIVE SUMMARY
─────────────────
Total Cryptographic Assets: 351
PQC-Safe Assets: 1 (0.3%)
Quantum-Vulnerable Assets: 199 (56.7%)

VULNERABILITY BREAKDOWN BY BREAK YEAR
──────────────────────────────────────
🚨 CRITICAL (Break by 2030):    119 assets  [IMMEDIATE ACTION]
⚠️  HIGH (Break by 2035):         64 assets  [PLAN MIGRATION NOW]
⚡ MEDIUM (Break by 2040):        0 assets  [MONITOR CLOSELY]
ℹ️  LOW (Break by 2045+):          0 assets  [LONG-TERM PLAN]
```

**Report File Size**: Typically 5-10KB for system-wide scan

**Use Cases**:
- Executive briefings on quantum readiness
- Migration planning with timelines
- Compliance reporting (NSA CNSA 2.0 deadline tracking)
- Risk assessment and prioritization

---

#### `--error-log FILE`
**Description**: Write errors to a log file with timestamps (especially useful with `--tui`)

**Problem Solved**: In TUI mode, stderr output is suppressed to prevent display corruption. Without `--error-log`, errors are only visible in the final JSON output (`metadata.annotations`), making it impossible to debug issues during the scan.

**Features**:
- ISO-8601 timestamps for each error: `[YYYY-MM-DD HH:MM:SS]`
- Severity levels: `[error]`, `[warning]`
- Component name and detailed error message
- Context information (file paths, error codes)
- Immediate write with `fflush()` for real-time visibility
- Thread-safe operation

**Use Cases**:
- **TUI Mode Debugging**: Monitor errors in real-time while TUI is running
- **Production Monitoring**: Tail the error log during long scans
- **Offline Analysis**: Review errors after scan completion
- **Automation**: Parse error logs in CI/CD pipelines

**Examples**:
```bash
# TUI mode with error logging (recommended)
./build/cbom-generator --tui --error-log /tmp/cbom-errors.log --output cbom.json

# Monitor errors in real-time (separate terminal)
tail -f /tmp/cbom-errors.log

# Normal mode with error logging
./build/cbom-generator --error-log /tmp/cbom-errors.log --output cbom.json

# Privacy-compliant scan with error logging
./build/cbom-generator --no-personal-data --error-log /var/log/cbom-errors.log --output cbom.json
```

**Error Log Format**:
```
[2025-11-15 14:33:01] [error] certificate_scanner: Certificate parsing failed (post-detection): MEMORY_ERROR - error:0480006C:PEM routines::no start line (/etc/ssl/certs/ca-certificates.crt)
[2025-11-15 14:33:01] [error] certificate_scanner: Certificate parsing failed (post-detection): MEMORY_ERROR - error:0480006C:PEM routines::no start line (/etc/ssl/certs/GlobalSign_Root_CA.pem)
[2025-11-15 14:33:02] [warning] key_scanner: Permission denied: /root/.ssh/id_rsa
```

**Real-Time Monitoring**:
```bash
# Start scan in one terminal
./build/cbom-generator --tui --error-log /tmp/errors.log --output cbom.json

# Monitor errors in another terminal
tail -f /tmp/errors.log

# Or use watch for periodic updates
watch -n 1 'tail -20 /tmp/errors.log'
```

**Log Rotation**: The error log file is opened in append mode. For long-running deployments, implement external log rotation using `logrotate` or similar tools.

**Privacy Note**: Error logs may contain file paths. Use `--no-personal-data` to ensure path redaction is applied consistently.

---

### Performance Options

#### `-t, --threads N`
**Description**: Number of worker threads for parallel scanner execution

**Default**: CPU count (auto-detected) - **Parallel execution is enabled by default**

**Range**: 1 to 32 threads

**Default Behavior** (when flag not specified):
- Automatically detects CPU count using `sysconf(_SC_NPROCESSORS_ONLN)`
- Creates thread pool with detected CPU count
- On 4-core system: 4 threads (parallel)
- On 8-core system: 8 threads (parallel)
- On 16-core system: 16 threads (parallel)
- Fallback: 4 threads if detection fails

**How it works**:
- Creates thread pool with N worker threads
- Runs all 5 scanners in parallel (certificate, key, package, service, filesystem)
- Utilizes available CPU cores efficiently
- Thread-safe operations on shared asset store (mutex-protected)

**Examples**:
```bash
# Use 8 threads (parallel)
./build/cbom-generator --threads 8 --output cbom.json

# Single-threaded (sequential fallback)
./build/cbom-generator --threads 1 --output cbom.json

# Maximum parallelism (default: CPU count)
./build/cbom-generator --output cbom.json
```

**Performance** (measured on /etc/ssl with 294 certificates):
- Sequential (--threads 1): 0.36 seconds
- Parallel (--threads 4): 0.22 seconds
- **Speedup: 1.64x faster** (64% improvement)

**Note**: Speedup varies by workload. Best results on systems with 4+ cores scanning large directories.

#### `-d, --deterministic` (Default: ON)
**Description**: Enable deterministic output (same input → identical hash)

**Examples**:
```bash
# Deterministic mode (default)
./build/cbom-generator --deterministic --output cbom.json

# Disable determinism (includes timestamps)
./build/cbom-generator --no-deterministic --output cbom.json
```

**Use deterministic mode when**:
- Comparing CBOMs across time
- CI/CD pipelines
- Change detection
- Reproducible builds

#### `--cross-arch` (v1.7+)
**Description**: Enable cross-architecture scanning mode for embedded/Yocto systems

This is the **canonical way** to scan cross-compiled rootfs images (e.g., ARM64 Yocto builds from an x86_64 development host). The scanner analyzes the actual binaries using ELF analysis without relying on external metadata like manifests.

**What it does:**
1. **Disables Host Package Manager**: Skips dpkg/rpm queries that would return incorrect host packages
2. **Uses VERNEED/SONAME Version Detection**: Extracts versions directly from ELF binaries
3. **Enables Embedded Service Detection**: Works with `--plugin-dir plugins/embedded`

**Version Resolution (without manifest):**
| Tier | Source | Confidence | Example |
|------|--------|------------|---------|
| Tier 3 | ELF VERNEED | 0.80 | `OPENSSL_3.0.0` → `3.0.0` |
| Tier 4 | SONAME parsing | 0.60 | `libssl.so.3` → `3` |

**Canonical Usage (Yocto Development System):**
```bash
# Define the rootfs path in your Yocto build directory
ROOTFS=/mnt/yocto-builds/yocto-cbom/poky/build-qemu/tmp/work/qemuarm64-poky-linux/core-image-minimal/1.0/rootfs

# Scan cross-compiled ARM64 rootfs from x86_64 host
./build/cbom-generator \
  --cross-arch \
  --discover-services \
  --plugin-dir plugins/embedded \
  --crypto-registry crypto-registry-yocto.yaml \
  --format cyclonedx --cyclonedx-spec=1.7 \
  -o yocto-cbom.json \
  $ROOTFS/usr/bin $ROOTFS/usr/sbin $ROOTFS/usr/lib $ROOTFS/etc
```

**Why scan binaries directly (not manifests)?**
Scanning the actual ELF binaries provides ground truth about what cryptographic libraries are actually linked, rather than relying on build system metadata. This catches:
- Runtime library substitutions
- Statically linked crypto
- Embedded crypto implementations
- Actual SONAME versions deployed

**What gets detected:**
- Crypto libraries via SONAME (libssl.so.3, libgnutls.so.30, libcrypto.so.3)
- Embedded services (dropbear, wpa_supplicant, strongSwan, lighttpd)
- Application→library dependencies
- Certificates and keys in the rootfs

**Example Output:**
```
INFO: Cross-architecture mode enabled (host package manager disabled)
INFO: Package scanner: SKIPPED (cross-arch mode - host package manager disabled)
...
Components: 177
Crypto libraries: libgnutls.so.30, libssl.so.3, libnettle.so.8, libhogweed.so.6
Dependencies with links: 16
Ubuntu contamination: NONE ✓
```

**Important Notes:**
1. **Never use `--cross-arch` with host paths** like `/usr/bin` - that's contradictory
2. **Use Yocto build directory paths** - development systems have rootfs under `tmp/work/.../rootfs/`
3. **Include multiple directories** for comprehensive coverage (`usr/bin`, `usr/sbin`, `usr/lib`, `etc`)
4. **Use embedded plugins** (`plugins/embedded/`) for IoT/embedded services
5. **Use Yocto crypto registry** (`crypto-registry-yocto.yaml`) for embedded library patterns

**Deprecated Flag:**
`--no-package-resolution` is deprecated. Use `--cross-arch` instead (provides clearer semantics and enables VERNEED version detection).

**See Also:**
- `docs/CROSS_ARCH_SCANNING.md` - Complete cross-architecture scanning guide
- `docs/YOCTO_TESTING_GUIDE.md` - Yocto build environment setup

---

### Deduplication Options

#### `--dedup-mode MODE`
**Description**: Control duplicate asset handling

**Values**:
- `off` - No deduplication (legacy behavior)
- `safe` - Deduplicate certificates, keys, OpenPGP (default, recommended)
- `strict` - Safe mode + bundle modeling + relationship pruning

**Examples**:
```bash
# Safe deduplication (default)
./build/cbom-generator --dedup-mode=safe --output cbom.json

# No deduplication (all files reported separately)
./build/cbom-generator --dedup-mode=off --output cbom.json

# Strict deduplication with bundle modeling
./build/cbom-generator --dedup-mode=strict --emit-bundles --output cbom.json
```

**Deduplication Behavior**:
- **safe mode**: Same certificate found in multiple locations → single component with multiple evidence entries
- **strict mode**: Bundles similar components (e.g., all system CA certificates → single bundle)

####  `--emit-bundles`
**Description**: Emit bundle components when using `--dedup-mode=strict`

**Examples**:
```bash
# Strict mode with bundles
./build/cbom-generator --dedup-mode=strict --emit-bundles --output cbom.json
```

---

### Service Discovery Options (v1.3)

**New in v1.3**: YAML Plugin-Driven Service Discovery

The CBOM Generator v1.3 introduces an extensible plugin architecture for discovering running services and extracting their cryptographic configurations automatically.

#### `--discover-services`

**Description**: Enable YAML plugin-driven service discovery pipeline

**What it does**:
1. **Phase 1**: Loads YAML plugins from plugins/ directory (13 plugins included)
2. **Phase 2**: Discovers running services via process, port, config file, systemd, and package detection
3. **Phase 3**: Extracts TLS/SSL configuration from each detected service
4. **Phase 4**: Generates CycloneDX components with full crypto metadata and PQC assessment

**Supported Services** (13 built-in plugins):
- **Databases**: PostgreSQL, MySQL, MariaDB, MongoDB, Redis, CouchDB
- **Web Servers**: Nginx, Apache HTTPD, Caddy
- **Message Queues**: RabbitMQ, Apache Kafka
- **VPN**: OpenVPN, WireGuard

**Examples**:
```bash
# Discover all services and generate CBOM
./build/cbom-generator --discover-services --output discovered.json

# With privacy mode (recommended)
./build/cbom-generator --discover-services --no-personal-data --output cbom.json

# With custom plugin directory
./build/cbom-generator --discover-services --plugin-dir /custom/plugins --output cbom.json

# Verbose output
./build/cbom-generator --discover-services -o cbom.json 2>&1 | grep "Phase"
```

**Output**:
```
INFO: Phase 1: Loading YAML plugins...
INFO:   Loaded 13 YAML plugins from 'plugins/'
INFO: Phase 2: Discovering services...
INFO:   Discovered 3 service(s)
INFO: Phase 3: Extracting crypto configurations...
INFO:   Processing service: PostgreSQL SSL/TLS Scanner
INFO:     Certificates: 1, Keys: 1, TLS: yes
INFO:     Components generated successfully
INFO: Extracted configs for 3/3 services
INFO: Phase 4.5 pipeline complete
```

**Detection Methods**:
- **Process**: Scans /proc for process names and command patterns
- **Port**: Checks listening ports with optional TLS handshake probe
- **Config File**: Glob pattern matching for config file presence
- **Systemd**: Queries systemd for active services
- **Package**: Checks if service packages are installed

**Configuration Extraction**:
- Parses service config files (postgresql.conf, nginx.conf, etc.)
- Extracts certificate paths, key paths, CA certificates
- Identifies TLS versions and cipher suites
- Detects security settings (client cert required, cipher preference)

**Component Generation**:
- Creates SERVICE components for each discovered service
- Creates CERTIFICATE components from extracted cert paths
- Creates PROTOCOL components (TLS 1.2, TLS 1.3, SSH)
- Creates CIPHER_SUITE components from config
- Builds relationship graph: SERVICE→CERT→PROTOCOL→CIPHER

**Use Cases**:
- Automated inventory of production services
- TLS/SSL configuration compliance auditing
- Service dependency mapping
- PQC readiness assessment for running services

#### `--plugin-dir DIR`

**Description**: Specify custom directory for YAML plugins

**Default**: `plugins/` (relative to current directory)

**Examples**:
```bash
# Use custom plugin directory
./build/cbom-generator --discover-services --plugin-dir /etc/cbom/plugins

# Use absolute path
./build/cbom-generator --discover-services --plugin-dir /opt/cbom-plugins

# Multiple locations (load from first found)
./build/cbom-generator --discover-services --plugin-dir ./custom-plugins
```

**Plugin File Format**: YAML files (.yaml or .yml extension)

**Plugin Schema**: See `docs/PLUGIN_SCHEMA.md` for YAML plugin development guide

#### `--list-plugins`

**Description**: List all loaded plugins and exit

**Features**:
- Lists 5 built-in scanners (always available)
- Loads and lists YAML plugins from plugins/ directory
- Shows plugin count and versions
- Exits after listing (no scan performed)

**Examples**:
```bash
# List all plugins
./build/cbom-generator --list-plugins

# List plugins from custom directory
./build/cbom-generator --list-plugins --plugin-dir /custom/plugins
```

**Output**:
```
Loaded 13 YAML plugins from 'plugins/'

=== CBOM Generator Plugins ===

Built-in Scanners (5):
  1. builtin_cert_scanner v1.0.0 - Certificate Scanner
  2. builtin_key_scanner v1.0.0 - Key Scanner
  3. builtin_package_scanner v1.0.0 - Package Scanner
  4. builtin_service_scanner v1.0.0 - Service Scanner
  5. builtin_fs_scanner v1.0.0 - Filesystem Scanner

YAML Plugins (13 loaded)

Total: 18 plugins (5 built-in + 13 YAML)

INFO: Loaded YAML plugin: PostgreSQL SSL/TLS Scanner v1.0.0 (plugins//postgresql.yaml)
INFO: Loaded YAML plugin: MongoDB TLS Scanner v1.0.0 (plugins//mongodb.yaml)
INFO: Loaded YAML plugin: Nginx SSL/TLS Scanner v1.0.0 (plugins//nginx.yaml)
... (and 10 more)
```

**Use Cases**:
- Verify plugin installation
- Check available service detectors
- Debug plugin loading issues
- Validate custom plugin deployment

#### Creating Custom Plugins

**YAML Plugin Structure**:
```yaml
# plugins/myservice.yaml
plugin:
  plugin_schema_version: "1.0"
  name: "My Service TLS Scanner"
  version: "1.0.0"
  category: "custom"
  description: "Detects My Service and extracts TLS config"

detection:
  methods:
    - type: process
      names: ["myservice"]
    - type: port
      ports: [8443]
      check_ssl: true

config_extraction:
  files:
    - path: "/etc/myservice/config.yaml"
      parser: "yaml"
      crypto_directives:
        - key: "tls.cert"
          type: "path"
          maps_to: "certificate.path"
```

**Supported Parsers** (Phase 3):
- `ini` - INI/properties format (PostgreSQL, MySQL, Redis)
- `apache` - Apache HTTPD config format
- `nginx` - Nginx config format
- `yaml` - YAML format (MongoDB, Kubernetes)
- `json` - JSON format (Caddy, modern apps)
- `openssl_cipher` - OpenSSL cipher string expansion

**See Also**: `docs/PLUGIN_DEVELOPMENT.md` for complete plugin writing guide

---

### Crypto Registry Extension (v1.6)

**New in v1.6**: Extensible Crypto Library Registry via YAML Configuration

The CBOM Generator v1.6 introduces external YAML configuration files to extend the built-in crypto library registry, enabling support for new distributions (Yocto, Alpine, Buildroot) and custom crypto implementations **without code changes or recompilation**.


The **Crypto Registry** is a declarative catalog of cryptographic libraries, providers, and embedded crypto engines used across Linux systems and embedded environments. By externalizing this knowledge into YAML, the CBOM Generator gains a portable, extensible source of truth that drives accurate detection of cryptographic components during scanning. Instead of relying on hard-coded heuristics, the registry allows the CBOM to correctly classify crypto libraries (e.g., OpenSSL, GnuTLS, Kerberos, wolfSSL, mbedTLS) and embedded providers (e.g., OpenSSH, NGINX, VPN daemons), ensuring each application or service receives precise **DEPENDS_ON** relationships in the CycloneDX 1.7 output. The result is a richer, more complete CBOM with reliable PQC readiness assessment, platform-aware crypto visibility, and the ability to adapt instantly to new distributions, Yocto builds, or vendor-specific crypto stacks simply by updating the registry—without modifying the scanner's code.

#### How the Crypto Registry Works in the Scan Flow

When scanning binaries, the CBOM Generator uses the crypto registry to identify cryptographic dependencies:

**Binary Scan Flow (default - readelf)**:
```
1. Scanner finds ELF binary (e.g., /usr/sbin/nginx)
2. Reads ELF dependencies via `readelf -d` → [libssl.so.3, libcrypto.so.3]
   (extracts sonames only, no path resolution needed)
3. Queries registry: find_crypto_lib_by_soname("libssl.so.3")
4. Registry returns: {id: "openssl", algorithms: [AES, RSA, ECDSA, ...]}
5. Creates DEPENDS_ON relationship: nginx → openssl
```

**Library Dependency Behavior (v1.8.6+)**:
- **All library dependencies are included by default** - both crypto and non-crypto libraries
- This provides complete dependency graphs for comprehensive security analysis
- No CLI flag required - this is now the default behavior
- Previously, only crypto-related libraries (matching the registry) were included

**Why readelf is the default**:
- **Cross-architecture safe**: Works on ARM/MIPS binaries from x86 host (essential for Yocto/embedded)
- **Faster**: Parses ELF headers directly, no dynamic linker involved
- **No execution risk**: Static analysis only, never runs the binary
- **Alternative**: Use `--use-ldd` for resolved library paths (host architecture only)

**Example: nginx with OpenSSL**:
```
Binary: /usr/sbin/nginx
    │
    ├── readelf -d → NEEDED: libssl.so.3
    │                        libcrypto.so.3
    │                        libz.so.1
    │                        libpcre.so.3
    │
    └── Registry Lookup:
        ├── libssl.so.3    → openssl (match!)
        ├── libcrypto.so.3 → openssl (match!)
        ├── libz.so.1      → (no crypto match)
        └── libpcre.so.3   → (no crypto match)

Result: nginx DEPENDS_ON openssl
        openssl provides: AES-256-GCM, RSA-2048, ECDSA-P256, SHA-256, ...
```

**Registry Lookup Flow**:
```
┌─────────────────────────────────────────────────────────────┐
│                    Crypto Registry                          │
├─────────────────────────────────────────────────────────────┤
│  Library Entries:                                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ id: openssl                                          │  │
│  │ soname_patterns: [libssl.so, libcrypto.so]          │  │
│  │ pkg_patterns: [libssl, libssl3, libcrypto3]         │  │
│  │ algorithms: [AES, RSA, ECDSA, SHA-256, ...]         │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  Lookup Functions:                                          │
│  • find_crypto_lib_by_soname("libssl.so.3")                │
│    → Matches "libssl.so" pattern → returns openssl         │
│  • find_crypto_lib_by_pkg("libgcrypt20")                   │
│    → Matches "libgcrypt" pattern → returns libgcrypt       │
└─────────────────────────────────────────────────────────────┘
```

#### `--crypto-registry FILE`

**Description**: Load external crypto library registry from YAML file to extend built-in registry

**How it works**:
1. **Built-in Registry** (Always Available): 5 crypto libraries (OpenSSL, libgcrypt, libsodium, nettle, Kerberos)
2. **YAML Extension** (Optional): Loads additional libraries from external YAML file
3. **Lookup Order**: Searches built-in first, then YAML extensions (built-in wins on conflicts)
4. **Graceful Degradation**: YAML loading failures are warnings, not errors

**Examples**:
```bash
# Standard scan (built-in registry only)
./build/cbom-generator --output cbom.json

# With Ubuntu/Debian registry extension
./build/cbom-generator --crypto-registry crypto-registry-ubuntu.yaml --output cbom.json

# With Yocto/embedded registry extension
./build/cbom-generator --crypto-registry crypto-registry-yocto.yaml --output cbom.json

# Invalid file (graceful degradation)
./build/cbom-generator --crypto-registry /nonexistent.yaml --output cbom.json
# Output: WARNING: Failed to load crypto registry from /nonexistent.yaml: ...
#         WARNING: Continuing with built-in crypto registry only.
```

**Output (successful load)**:
```
INFO: Loaded external crypto registry from crypto-registry-ubuntu.yaml
```

**Output (failed load)**:
```
WARNING: Failed to load crypto registry from invalid.yaml: Failed to parse YAML: ...
WARNING: Continuing with built-in crypto registry only.
```

#### Built-in Crypto Libraries

The generator includes 5 built-in crypto libraries that are always available:

| Library ID | Description | Package Patterns | SONAME Patterns |
|------------|-------------|------------------|-----------------|
| **openssl** | OpenSSL TLS library | libssl, libssl3, libcrypto3 | libssl.so, libcrypto.so |
| **libgcrypt** | GnuPG crypto library | libgcrypt, libgcrypt20 | libgcrypt.so |
| **libsodium** | NaCl crypto library | libsodium, libsodium-dev | libsodium.so |
| **nettle** | Low-level crypto library | libnettle, libhogweed | libnettle.so, libhogweed.so |
| **krb5** | Kerberos crypto | libkrb5, libgssapi-krb5 | libgssapi_krb5.so, libkrb5.so |

**Built-in Embedded Apps (3)**:
- `openssh_internal` - OpenSSH built-in crypto
- `wireguard_internal` - WireGuard VPN crypto
- `age_internal` - age encryption tool

#### YAML Registry Format

**Schema Version 1**:
```yaml
version: 1  # Schema version (required)

crypto_libraries:
  - id: boringssl                    # Unique identifier
    pkg_patterns:                     # Package name patterns
      - libboringssl
      - boringssl
    soname_patterns:                  # Shared library patterns
      - libboringssl.so
    algorithms:                       # Supported algorithms
      - RSA
      - ECDSA
      - AES-GCM

embedded_crypto_apps:
  - provider_id: dropbear            # Unique provider ID
    binary_names:                     # Binary name patterns
      - dropbear
      - dbclient
    package_names:                    # Package name patterns
      - dropbear
    algorithms:                       # Supported algorithms
      - aes128-ctr
      - curve25519-sha256
```

**Pattern Matching**: All patterns use substring matching (`strstr()`):
- Pattern `libssl.so` matches `libssl.so.3`, `libssl.so.1.1`
- Pattern `openssl` matches `openssl-dev`, `libopenssl3`

**Validation Rules**:
- `version` must be 1 (other versions rejected)
- Either `crypto_libraries` or `embedded_crypto_apps` must be present
- Each library must have `id`, each app must have `provider_id`
- Arrays can be empty (`[]`) but not missing
- Unknown fields are ignored (forward-compatible)

#### Example Registry Files

**crypto-registry-ubuntu.yaml** (16 libraries + 7 apps):

Comprehensive registry for Ubuntu/Debian-based systems including Raspberry Pi OS and Armbian:
- **OpenSSL, libgcrypt, libsodium, nettle, krb5** - Core crypto libraries
- **GnuTLS, NSS, BoringSSL, LibreSSL, mbedTLS** - Alternative TLS implementations
- **wolfSSL, Crypto++, libsrtp, Argon2, Bouncy Castle** - Specialized crypto
- **Embedded apps**: OpenSSH, WireGuard, age, nginx, Apache, OpenVPN, strongSwan

**registry/crypto-registry-yocto.yaml** (26 libraries + 4 apps):

Targets Yocto/Buildroot embedded Linux (no package manager, soname-only detection):
- **OpenSSL, mbedTLS, wolfSSL, libsodium, nettle, GnuTLS, libgcrypt** - Common embedded TLS
- **libsrtp, Argon2, curl, libwebsockets, mosquitto** - Application-specific crypto
- **strongSwan** (core + 17 plugins) - Complete IPsec VPN stack
- **Embedded apps**: device_agent, mgmt_ui, mqtt_internal, vpn_internal (vendor placeholders)

**registry/crypto-registry-openwrt.yaml** (6 libraries + 7 apps):

Router/networking-focused registry for OpenWrt and LEDE:
- **wolfSSL** (default since Oct 2024), **mbedTLS** (previous default), **OpenSSL** (optional)
- **libsodium, nettle, ustream-ssl** - Supporting crypto
- **Embedded apps**: hostapd/wpad (WPA2/WPA3), dnsmasq (DNSSEC), dropbear (SSH), uhttpd, OpenVPN, WireGuard, OpenSSH

**registry/crypto-registry-alpine.yaml** (8 libraries + 7 apps):

Container and musl-based system registry for Alpine Linux:
- **OpenSSL** (musl-based), **LibreSSL** (historical default), **libsodium**
- **GnuTLS, nettle, libgcrypt, mbedTLS, NSS** - Alternative implementations
- **Embedded apps**: OpenSSH, BusyBox, nginx, haproxy, stunnel, Docker/containerd, WireGuard

#### Use Cases

**1. Yocto/Embedded Linux Systems**:
```bash
# Scan embedded device with Yocto-specific libraries
./build/cbom-generator \
  --crypto-registry crypto-registry-yocto.yaml \
  --discover-services \
  --output embedded-cbom.json

# Verify dropbear SSH detected
cat embedded-cbom.json | jq '.components[] | select(.name | contains("dropbear"))'
```

**2. Custom Crypto Library Detection**:
```bash
# Create custom registry for your organization
cat > my-crypto-registry.yaml << 'EOF'
version: 1
crypto_libraries:
  - id: acme_tls
    pkg_patterns:
      - acme-crypto-lib
    soname_patterns:
      - libacme_tls.so
    algorithms:
      - RSA
      - AES-256-GCM
EOF

# Scan with custom registry
./build/cbom-generator --crypto-registry my-crypto-registry.yaml --output cbom.json
```

**3. Multi-Distribution Support**:
```bash
# Ubuntu/Debian/RPi OS/Armbian
./build/cbom-generator --crypto-registry crypto-registry-ubuntu.yaml -o ubuntu-cbom.json

# OpenWrt/LEDE routers
./build/cbom-generator --crypto-registry registry/crypto-registry-openwrt.yaml -o openwrt-cbom.json

# Alpine Linux/Docker containers
./build/cbom-generator --crypto-registry registry/crypto-registry-alpine.yaml -o alpine-cbom.json

# Yocto/Buildroot embedded
./build/cbom-generator --crypto-registry registry/crypto-registry-yocto.yaml -o yocto-cbom.json
```

#### Security Considerations

**Soft Limits** (prevent YAML bombs):
- Maximum 100 crypto libraries per YAML file
- Maximum 50 embedded apps per YAML file
- File size limited to 1MB (inherited from YAML parser)
- Nesting depth limited to 32 levels

**Graceful Degradation**:
- YAML parsing errors → warning + continue with built-in registry
- File not found → warning + continue with built-in registry
- Invalid schema version → warning + continue with built-in registry
- **Scanner never fails** due to external registry issues

**Thread Safety**:
- Registry loaded once at startup (before threading begins)
- Read-only after initialization (no locking required)
- No runtime reload support (restart required for registry changes)

**Temporary Directory Security** (noexec mount):

The CBOM Generator prefers a `noexec`-mounted temporary directory for security hardening. This prevents execution of any files written to temp directories, mitigating potential attacks where malicious files could be written and executed.

**Recommended Setup**:
```bash
# Create a dedicated noexec temp directory
sudo mkdir -p /var/tmp/cbom
sudo mount -t tmpfs -o noexec,nosuid,size=100M tmpfs /var/tmp/cbom

# Make permanent (add to /etc/fstab)
echo "tmpfs /var/tmp/cbom tmpfs noexec,nosuid,size=100M 0 0" | sudo tee -a /etc/fstab
```

**Current Behavior**:
- The scanner silently falls back to `/tmp` if no noexec directory is found
- This is normal on most desktop/development systems
- Production systems should configure a noexec temp mount for defense-in-depth
- No warnings are displayed (the fallback is silent)

**Why noexec matters**:
- Prevents execution of temporary files created during scanning
- Blocks potential code execution attacks via temp directory
- Follows security hardening best practices (CIS benchmarks recommend noexec on /tmp)
- Most cloud/container deployments already mount /tmp with noexec

#### Creating Custom Registry Files

**Step 1: Copy example file**:
```bash
cp crypto-registry-ubuntu.yaml my-registry.yaml
```

**Step 2: Add your custom libraries**:
```yaml
version: 1

crypto_libraries:
  # Keep built-in entries or remove them (built-in always available)

  # Add your custom library
  - id: my_custom_tls
    pkg_patterns:
      - my-tls-package
    soname_patterns:
      - libmytls.so
    algorithms:
      - RSA
      - AES-GCM
```

**Step 3: Validate**:
```bash
# Test registry loads without errors
./build/cbom-generator --crypto-registry my-registry.yaml --help 2>&1 | grep -i "loaded external"
# Expected output: INFO: Loaded external crypto registry from my-registry.yaml
```

**Step 4: Verify detection**:
```bash
# Run scan and check if your library is detected
./build/cbom-generator --crypto-registry my-registry.yaml --output cbom.json 2>/dev/null | \
  jq '.components[] | select(.name | contains("my_custom_tls"))'
```

#### Comparison: Built-in vs YAML Extension

| Feature | Built-in Registry | YAML Extension |
|---------|------------------|----------------|
| **Libraries** | 5 standard (OpenSSL, libgcrypt, etc.) | Unlimited (up to 100 per file) |
| **Embedded Apps** | 3 standard (OpenSSH, WireGuard, age) | Unlimited (up to 50 per file) |
| **Modification** | Requires code changes + recompile | Edit YAML file only |
| **Distribution** | Same on all systems | Distribution-specific (Ubuntu, Yocto, Alpine) |
| **Availability** | Always present | Optional (--crypto-registry flag) |
| **Priority** | Searched first | Searched second (extension not replacement) |

#### When to Use Custom Registries

**Use YAML extension when**:
- Running on non-Ubuntu/RHEL distributions (Yocto, Alpine, Gentoo)
- Organization uses custom-compiled crypto libraries (BoringSSL builds, etc.)
- Detecting vendor-specific crypto implementations
- Supporting embedded systems with alternative crypto stacks
- Need to add new libraries without recompiling the generator

**Use built-in registry when**:
- Standard Ubuntu/Debian/RHEL deployment
- Only need common crypto libraries (OpenSSL, GnuTLS, etc.)
- Simplicity preferred over customization
- No custom crypto implementations

**See Also**:
- `crypto-registry-ubuntu.yaml` - Ubuntu/Debian/RPi OS/Armbian (16 libraries + 7 apps)
- `registry/crypto-registry-yocto.yaml` - Yocto/Buildroot embedded (26 libraries + 4 apps)
- `registry/crypto-registry-openwrt.yaml` - OpenWrt/LEDE routers (6 libraries + 7 apps)
- `registry/crypto-registry-alpine.yaml` - Alpine/Docker containers (8 libraries + 7 apps)
- `docs/CRYPTO_REGISTRY.md` - Registry selection guide
- `docs/CRYPTO_REGISTRY_YAML_EXTENSION_SPEC.md` - Complete specification

---

### Attestation Options (Partial in v1.0, Complete in v1.1)

**v1.0 Status**:
- ✅ **Implemented**: SLSA v0.2 provenance metadata (build info, compiler, git commit, OpenSSL version)
- ⏸️ **Deferred**: Cryptographic signing (DSSE envelope, PGP signatures)

**What v1.0 Provides**:
The `metadata.provenance` block includes build attestation:
```json
{
  "provenance": {
    "git_commit": "abc123...",
    "compiler": "GCC 11.4.0",
    "openssl_version": "3.0.2",
    "build_timestamp": "2025-11-09T15:00:00Z",
    "build_type": "Release"
  }
}
```

This allows build verification without cryptographic signatures. Actual signing support planned for v1.1.

**Planned for v1.1** — See GitHub issues or ROADMAP.md for timeline.

#### `--enable-attestation`
**Description**: Enable CBOM attestation with digital signature

**Status**: v1.0 accepts flag but skips signing; v1.1 will implement full DSSE/PGP signing

**Examples**:
```bash
# Enable attestation (v1.0: metadata only, v1.1: with signature)
./build/cbom-generator --enable-attestation --signing-key key.pem --output cbom.json
```

#### `--signature-method METHOD`
**Description**: Signature method selection (v1.1 feature)

**Values**: `dsse` (default), `pgp`

**Examples**:
```bash
# DSSE envelope (v1.1)
./build/cbom-generator --enable-attestation --signature-method=dsse --signing-key key.pem

# PGP signature (v1.1)
./build/cbom-generator --enable-attestation --signature-method=pgp --signing-key key.asc
```

**Planned for v1.1** — See GitHub issues or ROADMAP.md for timeline.

#### `--signing-key PATH`
**Description**: Path to signing key file (v1.1 feature)

**Examples**:
```bash
./build/cbom-generator --enable-attestation --signing-key /path/to/key.pem --output cbom.json
```

**Planned for v1.1** — See GitHub issues or ROADMAP.md for timeline.

---

### Information Options

#### `-h, --help`
**Description**: Display help message and exit

```bash
./build/cbom-generator --help
```

#### `-v, --version`
**Description**: Display version information and exit

```bash
./build/cbom-generator --version
# Output:
# CBOM Generator 1.0.0
# Build: Release 2025-11-09T15:00:00Z
# Compiler: GCC 11.4.0
# OpenSSL: 3.0.2
```

---

## Feature Guide

### Asset Discovery

The CBOM Generator includes 5 built-in scanners that discover cryptographic assets across your system:

### Scanner Behavior and File Counting

**Understanding File Counts vs Component Counts:**

The TUI displays both **file counts** (how many files examined) and **component counts** (cryptographic assets discovered). These numbers differ significantly due to scanner filtering and extraction logic.

#### File Scanning Strategies

**Certificate & Key Scanners** (Comprehensive):
- **Scan every file** in the target directory
- Must check all files to find certificates/keys
- No extension filtering (certificates can have any extension)
- Skip hidden directories (`.cache`, `.config`, `.local`, etc.)
- **File count**: 4.1M files on typical /home directory

**Filesystem Scanner** (Selective):
- **Filters by crypto-related file types only**:
  - Certificates/Keys: `.crt`, `.pem`, `.key`, `.p12`, `.der`, `.cer`
  - Configurations: `.conf`, `.config`, `.xml`, `.json`, `.yaml`
  - Libraries: `.so`, `.a`, `.dylib`
- **Skips non-crypto files**: `.txt`, `.jpg`, `.mp4`, `.pdf`, `.zip`, etc.
- **File count**: ~1.5M files on /home (36% of total - only crypto-related)

**Example File Counts** (on /home with 4.23M total files):
```
Certificate Scanner: 4,122,000 files examined (97.4%)
Key Scanner:         4,126,000 files examined (97.5%)
Filesystem Scanner:  1,525,000 files examined (36% - crypto files only)
```

**Why counts differ:**
- Certificate/Key scanners examine EVERY file (comprehensive search)
- Filesystem scanner pre-filters by extension (efficient search)
- Both strategies are correct for their use cases

#### Component Extraction from Files

**Certificate Bundles** (Multiple Components per File):
- Single file (e.g., `ca-certificates.crt`) may contain 100+ certificates
- Each certificate extracted as separate component
- **Example**: 581 certificate files → 1968 certificate components (3.4x ratio)

**Algorithm Extraction** (Derived Components):
- Each certificate/key creates algorithm components
- RSA-2048, SHA-256, ECDSA-P256, etc. extracted from parent asset
- **Example**: 1 certificate → 1 cert + 2-3 algorithm components

**Example Asset Extraction:**
```
File: /etc/ssl/certs/ca-certificates.crt (1 file)
  ├─ 147 Certificate components (bundle of root CAs)
  ├─ 14 Algorithm components (RSA, SHA-256, ECDSA, etc.)
  ├─ 3 Protocol components (TLS versions)
  └─ Total: 164 components from 1 file
```

#### Hidden Directory Handling

**Both Certificate and Key scanners skip hidden directories:**
- `.cache` (package manager caches)
- `.config` (application configs - rarely contain production certs/keys)
- `.local` (user application data)
- `.mozilla`, `.thunderbird` (browser stores - handled separately)
- `.ssh` (handled by service scanner with proper permissions)

**Rationale:**
- Production certificates/keys rarely in hidden directories
- Reduces false positives from test/development files
- Improves scan performance
- Avoids scanning package manager caches (yarn, npm, uv, pip)

**Example:** Scanning /home skips:
- `~/.cache/` (Git, browser caches, build artifacts)
- `~/.config/` (application settings)
- `~/.local/` (user-installed applications)

**To include hidden directories** (not recommended):
- Requires code modification (no CLI flag in v1.0)
- Planned for v1.1 with `--include-hidden-dirs` flag

---

#### 1. Certificate Scanner
**Discovers**: X.509 and OpenPGP certificates

**Formats**: PEM, DER, PKCS#12

**Scanning Strategy**: Examines every file in target directory (except hidden directories)

**Information Extracted**:
- Subject and issuer DNs (RFC2253 normalized)
- Validity periods (notValidBefore, notValidAfter)
- Signature algorithms with OIDs
- Public key algorithms and sizes
- Trust validation status (15 failure reasons tracked)
- Certificate state (active, expired, revoked)
- Extensions (KeyUsage, ExtendedKeyUsage, SubjectAltName)

**Deduplication Behavior:**

Certificate scanning includes automatic deduplication to prevent duplicate reporting:

- **Bundles scanned first**: Files like ca-certificates.crt contain 100+ certificates
- **Individual files scanned second**: Symlinks often point to certs already in bundles
- **Duplicates skipped**: Asset store rejects duplicate certificates
- **Counted as failures**: Diagnostics show "individual file failures" for duplicates

**Example**: Scanning /etc/ssl/certs shows ~95% individual file failure rate because most .pem symlinks are duplicates of certificates already extracted from ca-certificates.crt bundle. This is **expected** and **correct** behavior.

**Actual Parsing Metrics:**
```bash
# View accurate metrics
jq '.properties[] | select(.name | startswith("cbom:diagnostics"))' cbom.json

# Key metrics:
# - bundle_certs_failed: Certs that failed within bundles
# - individual_file_failures: Non-bundle files that failed
# - actual_failure_rate_pct: Individual file failure percentage
```

**Example Component**:
```json
{
  "type": "cryptographic-asset",
  "name": "CN=Example CA",
  "cryptoProperties": {
    "assetType": "certificate",
    "certificateProperties": {
      "subjectName": "CN=Example CA",
      "issuerName": "CN=Root CA",
      "notValidBefore": "2020-01-01T00:00:00Z",
      "notValidAfter": "2030-01-01T00:00:00Z",
      "certificateFormat": "X.509",
      "certificateState": [
        {
          "state": "active",
          "activationDate": "2020-01-01T00:00:00Z"
        }
      ]
    }
  }
}
```

#### 2. Key Scanner
**Discovers**: Private and public keys

**Formats**: PEM, DER, OpenSSH

**Key Types**: RSA, ECDSA, Ed25519, Ed448, DSA, DH

**Scanning Strategy**: Examines every file in target directory (except hidden directories) - same as certificate scanner

**Security Features**:
- **CRITICAL**: Only stores SHA-256 hashes, NEVER raw key material
- Detects storage security (plaintext, encrypted, HSM, TPM)
- Tracks key lifecycle states (NIST SP 800-57)
- Identifies weak keys (RSA <2048, ECDSA <256)

**Example Component**:
```json
{
  "type": "cryptographic-asset",
  "name": "RSA-2048 Key",
  "cryptoProperties": {
    "assetType": "related-crypto-material",
    "relatedCryptoMaterialProperties": {
      "type": "private-key",
      "state": "active",
      "size": 2048,
      "format": "PEM"
    }
  }
}
```

#### 3. Package Scanner
**Discovers**: Cryptographic libraries via package managers

**Scanning Strategy**: System-wide database queries (not file-based)

**Package Managers**: APT, RPM, Pacman, pip, npm, RubyGems

**Libraries Detected**: OpenSSL, GnuTLS, libgcrypt, nettle, Python cryptography, and 20+ more

**How it works**:
- Queries package manager databases (`dpkg -l`, `rpm -qa`, `pip list`, etc.)
- **No file scanning** - reads installed package lists
- System-wide scope (not directory-specific)
- Completes quickly (no disk I/O beyond database reads)

**Information Tracked**:
- Library name and version
- Provided algorithms (AES, RSA, ECDSA, etc.)
- FIPS certification status (stub metadata only)
- Package manager source

**TUI Display**:
- Shows "System-wide" instead of file count
- Asset count shows "0 pkgs" (not updated progressively)
- Final count appears in Total Assets breakdown

**Example**: Detects 29 crypto libraries on typical Ubuntu system

#### 4. Service Scanner
**Discovers**: Network services using cryptography

**Scanning Strategy**: System-wide process and configuration analysis (not file-based)

**Services**: Apache, Nginx, OpenSSH, Postfix

**How it works**:
- Scans running processes (`ps`, `/proc`)
- Reads service configuration files (`/etc/ssh/sshd_config`, `/etc/nginx/nginx.conf`, etc.)
- Extracts cryptographic protocols and cipher suites
- **No recursive file scanning** - reads specific known config paths
- System-wide scope (not directory-specific)

**Analysis**:
- Config file parsing (httpd.conf, nginx.conf, sshd_config)
- TLS/SSH protocol detection
- Cipher suite extraction
- Security profile classification (MODERN, INTERMEDIATE, OLD)
- Network endpoint mapping

**TUI Display**:
- Shows "System-wide" instead of file count
- Asset count shows "0 svcs" (not updated progressively)
- Final count appears in Total Assets breakdown
- Note: 153 "svcs" includes services + derived protocols + algorithms

**Example Relationship Chain**:
```
Apache HTTPD
    └─[USES]→ TLS 1.2
                 └─[PROVIDES]→ ECDHE-RSA-AES256-GCM-SHA384
                                    ├─[USES]→ ECDHE (key exchange)
                                    ├─[USES]→ RSA (authentication)
                                    ├─[USES]→ AES-256-GCM (encryption)
                                    └─[USES]→ SHA384 (MAC)
```

**SSH Configuration Scanning** (Enhanced in v1.0):

The Service Scanner includes comprehensive SSH configuration analysis:

**Server Configuration**:
- File: `/etc/ssh/sshd_config`
- Extracts: KexAlgorithms (key exchange)
- Usage: `server` (inbound connections)
- Confidence: 0.95 (config-based detection)

**System Client Configuration**:
- File: `/etc/ssh/ssh_config`
- Extracts: KexAlgorithms, Ciphers, MACs, HostKeyAlgorithms
- Usage: `client` (system-wide outbound connections)
- Confidence: 0.95 (config-based detection)

**User Client Configuration** (Privacy-aware):
- Files: `~/.ssh/config` (all users in /home/*)
- Extracts: KexAlgorithms from user configs
- Usage: `client-user-<username>` (per-user outbound)
- Confidence: 0.90 (user config detection)
- **Requires**: `--include-personal-data` flag (opt-in)
- **Privacy**: Paths redacted as `<user-username>/.ssh/config`

**PQC KEX Algorithm Detection**:
The scanner detects Post-Quantum safe KEX algorithms including:
- `sntrup761x25519-sha512@openssh.com` (NTRU Prime + X25519 hybrid)
- Other PQC hybrid algorithms
- Updates PQC readiness score based on KEX usage

**Example Detection**:
```bash
# Default: scans server + system client configs
./build/cbom-generator --output cbom.json

# Include user configs (privacy opt-in)
./build/cbom-generator --include-personal-data --output cbom-full.json
```

**Results**:
- Server KEX: MODERN profile if using sntrup761 or strong algorithms
- System Client: Detects default KEX preferences
- User Client: Reveals individual user PQC adoption (with consent)
- **Instance Counting**: `pqc_safe_instances` metric counts how many configs use PQC

**Instance vs Unique Metrics**:
- `pqc_safe_count`: Unique PQC algorithms (e.g., 1 for sntrup761)
- `pqc_safe_instances`: Config instances using PQC (e.g., 3 if server + system client + user client all use sntrup761)

This provides visibility into both **breadth** (unique algorithms) and **deployment** (actual usage across configs).

#### 5. Filesystem Scanner
**Discovers**: Files containing cryptographic material

**Scanning Strategy**: Pre-filters by crypto-related file extensions (selective scanning)

**File Types Scanned**:
- Certificates/Keys: `.crt`, `.pem`, `.key`, `.p12`, `.der`, `.cer`
- Configurations: `.conf`, `.config`, `.xml`, `.json`, `.yaml`
- Libraries: `.so`, `.a`, `.dylib`

**Files Skipped**:
- Non-crypto files: `.txt`, `.jpg`, `.mp4`, `.pdf`, `.zip`, `.html`, etc.
- Significantly reduces scan time by pre-filtering

**Features**:
- Recursive directory scanning (up to 32 levels deep)
- Parallel processing with thread pool
- Extension-based filtering (crypto files only)
- Permission-aware (graceful degradation)

**Example**: On /home with 4.23M total files, scans only 1.5M crypto-related files (36%)

#### 6. Application Scanner
**Discovers**: Cryptographic-using applications (services, clients, utilities)

**Directories Scanned**:
- Default: `/usr/bin`, `/usr/sbin`
- Custom paths via command line arguments
- Cross-architecture compatible via readelf (not just native ldd)

**Discovery Process**:
1. **ELF Validation**: Checks executable permission and ELF magic bytes (`0x7F 'E' 'L' 'F'`)
2. **Library Extraction**: Uses `readelf -d` (cross-arch compatible) or `ldd` via `--use-ldd` flag
3. **Crypto Detection**: Matches libraries against crypto registry (SONAME patterns)
4. **Alternate Detection**: If no dynamic libraries found, checks for:
   - Kernel crypto API usage (AF_ALG markers)
   - Statically linked crypto (Go `crypto/tls`, Rust `ring::`, `rustls::`)
   - Embedded crypto symbols (`AES_encrypt`, `SHA256_Init`)

**Role Classification**:
Applications are classified into one of three roles based on heuristics:

| Role | Classification Criteria | Examples |
|------|------------------------|----------|
| **Service** | Located in `/sbin/`, OR name ends with 'd', OR contains "server"/"daemon" | sshd, nginx, dockerd, redis-server |
| **Client** | Contains "client", OR matches known patterns | ssh, curl, wget, git |
| **Utility** | Default (everything else) | openssl, gpg, certbot |

**Detection Methods**:
Each application records how its crypto dependencies were discovered:

| Method | Description | Use Case |
|--------|-------------|----------|
| `BINARY_SCAN` | Sequential binary analysis | Single-threaded scanning |
| `BINARY_SCAN_PARALLEL` | Parallel binary analysis | Default multi-threaded mode |
| `KERNEL_CRYPTO_API` | Linux AF_ALG socket usage | Kernel crypto (cryptsetup, dm-crypt) |
| `STATIC_LINKED` | Statically linked crypto | Go/Rust binaries with embedded crypto |
| `SYMBOL_ANALYSIS` | Embedded crypto symbols | Binaries with compiled-in OpenSSL |

**Example Component**:
```json
{
  "type": "application",
  "name": "nginx",
  "bom-ref": "app:nginx",
  "properties": [
    { "name": "cbom:app:role", "value": "service" },
    { "name": "cbom:app:binary_path", "value": "/usr/sbin/nginx" },
    { "name": "cbom:app:detection_method", "value": "BINARY_SCAN_PARALLEL" },
    { "name": "cbom:app:is_daemon", "value": "true" }
  ]
}
```

**Relationships Created**:
- `APPLICATION` → `LIBRARY` (DEPENDS_ON, confidence 0.90)
- Links to all dynamically linked libraries (crypto and non-crypto)

#### 7. Library Scanner
**Discovers**: Crypto libraries linked to applications and services

**Note**: Library detection is integrated into the Application Scanner, not a standalone scanner.

**Discovery Process**:
1. **SONAME Extraction**: Parses ELF `.dynamic` section to extract library names
2. **Crypto Registry Matching**: Matches SONAME/package patterns against built-in registry
3. **Package Resolution**: Queries dpkg/rpm/pacman for version info (disabled in `--cross-arch` mode)
4. **Caching**: Thread-safe caches prevent redundant analysis

**Built-in Crypto Registry**:
The following libraries are recognized without external configuration:

| Library | SONAME Patterns | Algorithms Provided |
|---------|-----------------|---------------------|
| **OpenSSL** | libssl.so, libcrypto.so | RSA, ECDSA, AES, ChaCha20-Poly1305, SHA-256/384, X25519, P-256/384 |
| **libgcrypt** | libgcrypt.so | RSA, DSA, ECDSA, AES, Twofish, SHA-1, SHA-256 |
| **libsodium** | libsodium.so | X25519, Ed25519, ChaCha20-Poly1305, BLAKE2b |
| **nettle** | libnettle.so, libhogweed.so | RSA, ECDSA, AES, ChaCha20, SHA-256 |
| **Kerberos** | libkrb5.so, libgssapi_krb5.so | AES, 3DES, RC4, HMAC-SHA1/256 |
| **libcrypt** | libcrypt.so | bcrypt, yescrypt, sha512crypt, sha256crypt |
| **liboqs** | liboqs.so | ML-KEM-512/768/1024, ML-DSA-44/65/87, Falcon, SPHINCS+ |

**Embedded Crypto Providers**:
Some applications have built-in crypto engines detected automatically:

| Provider | Binary Patterns | Algorithms |
|----------|----------------|------------|
| **openssh_internal** | sshd, ssh | chacha20-poly1305@openssh.com, aes128/256-ctr, curve25519-sha256, ssh-ed25519, sntrup761x25519 |
| **wireguard_internal** | wg, wg-quick | ChaCha20, Poly1305, BLAKE2s, Curve25519 |
| **age_internal** | age, age-keygen | X25519, ChaCha20-Poly1305, HMAC-SHA256 |

**YAML Extension** (`--crypto-registry`):
External YAML files extend the built-in registry for custom distributions. See [Crypto Registry Extension](#crypto-registry-extension-v16) for details.

**Example Component**:
```json
{
  "type": "library",
  "name": "OpenSSL",
  "bom-ref": "library:openssl",
  "version": "3.0.2",
  "properties": [
    { "name": "cbom:lib:soname", "value": "libssl.so.3" },
    { "name": "cbom:lib:type", "value": "crypto" },
    { "name": "cbom:pqc:status", "value": "DEPRECATED" },
    { "name": "cbom:pqc:rationale", "value": "Implements deprecated algorithm: MD5" }
  ]
}
```

**Relationships Created**:
- `LIBRARY` → `ALGORITHM` (PROVIDES, confidence 0.85-0.90)
- Links library to all algorithms it can provide

#### 8. Algorithm Detection
**Discovers**: Cryptographic algorithms from certificates, keys, cipher suites, and libraries

Algorithms are **derived components** - they are extracted from other assets rather than discovered directly from files. The scanner creates algorithm assets from four sources:

**Source 1: From Certificates**

When parsing X.509 certificates, the scanner extracts:
- **Public Key Algorithm**: Via `X509_get_pubkey()` → RSA, ECDSA, Ed25519, Ed448, DSA
- **Signature Algorithm**: Via `X509_get_signature_nid()` → sha256WithRSAEncryption, ecdsa-with-SHA256, etc.

| Certificate Field | Algorithm Extracted | Example |
|-------------------|--------------------| --------|
| Public Key | Key exchange/signature | RSA-2048, ECDSA-P256, Ed25519 |
| Signature Algorithm | Hash + signature | SHA256withRSA, SHA384withECDSA |

**Source 2: From Keys**

Key material analysis extracts algorithm based on key type and size:

| Key Type | Algorithm Name Pattern | Example |
|----------|----------------------|---------|
| RSA | RSA-{keysize} | RSA-2048, RSA-4096 |
| ECDSA | ECDSA-{curve} | ECDSA-P256, ECDSA-P384 |
| EdDSA | Ed25519, Ed448 | Ed25519 |
| DH | DH-{keysize} | DH-2048 |

**Source 3: From Cipher Suites**

Cipher suites are decomposed into component algorithms:

**TLS 1.3 Cipher Suites** (fixed list):
| Cipher Suite | Encryption | Hash | Security Bits |
|--------------|------------|------|---------------|
| TLS_AES_256_GCM_SHA384 | AES-256-GCM | SHA384 | 256 |
| TLS_AES_128_GCM_SHA256 | AES-128-GCM | SHA256 | 128 |
| TLS_CHACHA20_POLY1305_SHA256 | ChaCha20-Poly1305 | SHA256 | 256 |
| TLS_AES_128_CCM_SHA256 | AES-128-CCM | SHA256 | 128 |
| TLS_AES_128_CCM_8_SHA256 | AES-128-CCM-8 | SHA256 | 128 |

**TLS 1.2 Cipher Suites** (decomposed):
| Component | Extracted From | Examples |
|-----------|---------------|----------|
| Key Exchange (KEX) | Cipher name prefix | ECDHE, DHE, RSA |
| Authentication | After KEX | RSA, ECDSA, PSK |
| Encryption | Cipher block | AES-256, AES-128, ChaCha20 |
| Mode | After encryption | GCM, CBC, CCM |
| MAC | Suffix | SHA256, SHA384, POLY1305 |

**Example**: `ECDHE-RSA-AES256-GCM-SHA384` creates 4 algorithm components:
- `algo:ecdhe` (key exchange)
- `algo:rsa` (authentication)
- `algo:aes-256-gcm-256` (encryption)
- `algo:sha384` (MAC)

**Source 4: From Libraries**

Libraries provide algorithm capabilities via the crypto registry:

```
OpenSSL (library:openssl)
    ├── PROVIDES → algo:rsa
    ├── PROVIDES → algo:ecdsa
    ├── PROVIDES → algo:aes-256-gcm-256
    ├── PROVIDES → algo:chacha20-poly1305
    ├── PROVIDES → algo:sha-256
    └── PROVIDES → algo:x25519
```

**Algorithm Asset Properties**:
```json
{
  "type": "cryptographic-asset",
  "name": "AES-256-GCM",
  "bom-ref": "algo:aes-256-gcm-256",
  "cryptoProperties": {
    "assetType": "algorithm",
    "algorithmProperties": {
      "primitive": "ae",
      "parameterSetIdentifier": "256",
      "mode": "gcm",
      "classicalSecurityLevel": 256
    }
  },
  "properties": [
    { "name": "cbom:algo:key_size", "value": "256" },
    { "name": "cbom:algo:is_weak", "value": "false" },
    { "name": "cbom:pqc:status", "value": "SAFE" },
    { "name": "cbom:pqc:rationale", "value": "Symmetric algorithm with sufficient key size" }
  ]
}
```

**OID Mapping**:
The scanner maps 47+ algorithm OIDs to human-readable names:

| OID | Algorithm Name |
|-----|---------------|
| 1.2.840.113549.1.1.1 | RSA |
| 1.2.840.113549.1.1.11 | sha256WithRSAEncryption |
| 1.2.840.10045.4.3.2 | ecdsa-with-SHA256 |
| 1.3.101.112 | Ed25519 |
| 2.16.840.1.101.3.4.1.42 | AES-256-CBC |

---

### Key Material Detection (Phase 7.0)

The Key Material Scanner provides comprehensive discovery and security analysis of cryptographic keys across your system.

#### Supported Key Types

| Key Type | Description | Example Sizes |
|----------|-------------|---------------|
| **RSA** | RSA asymmetric keys | 1024, 2048, 3072, 4096 bits |
| **ECDSA** | Elliptic Curve DSA | P-256, P-384, P-521 |
| **Ed25519** | Edwards curve 25519 | 256 bits (fixed) |
| **Ed448** | Edwards curve 448 | 448 bits (fixed) |
| **DSA** | Digital Signature Algorithm (legacy) | 1024, 2048, 3072 bits |
| **DH** | Diffie-Hellman | 2048, 3072, 4096 bits |
| **AES** | AES symmetric keys | 128, 192, 256 bits |
| **ChaCha20** | ChaCha20 stream cipher | 256 bits |
| **HMAC** | HMAC keys | Variable |
| **Generic** | Unknown/generic secret keys | Variable |

#### Supported Formats

- **PEM**: ASCII armor format with BEGIN/END markers
- **DER**: Binary Distinguished Encoding Rules
- **OpenSSH**: OpenSSH format (`ssh-rsa`, `ssh-ed25519`, etc.)
- **PKCS#8**: Private key information syntax
- **PKCS#1**: RSA private key format
- **SEC1**: EC private key format
- **RAW**: Raw key bytes

#### Storage Security Detection

The scanner automatically detects how keys are protected:

| Storage Type | Description | Security Level |
|--------------|-------------|----------------|
| **HSM** | Hardware Security Module | Highest |
| **TPM** | Trusted Platform Module | High |
| **Encrypted** | Password-protected (AES-256-CBC, 3DES-CBC, etc.) | Medium |
| **Keyring** | OS keyring/keychain | Medium |
| **Plaintext** | Unencrypted file | **LOW RISK** |

**Example Detection:**
```bash
# Scan for unencrypted private keys
cbom-generator /etc/ssl/private --output cbom.json 2>/dev/null | \
  jq '.components[] | select(.properties[]? | select(.name == "cbom:key:storage_security" and .value == "PLAINTEXT")) | .name'
```

#### Key Lifecycle Tracking (NIST SP 800-57)

Keys are classified by their lifecycle state:

| State | Description | CycloneDX Value |
|-------|-------------|-----------------|
| **Pre-activation** | Generated but not yet in use | `pre-activation` |
| **Active** | Currently in use | `active` |
| **Suspended** | Temporarily disabled | `suspended` |
| **Deactivated** | No longer in use | `deactivated` |
| **Compromised** | Known or suspected compromise | `compromised` |
| **Destroyed** | Securely deleted | `destroyed` |

#### Weakness Detection

The scanner automatically identifies weak keys:

- **RSA keys < 2048 bits** (NIST recommendation)
- **ECDSA keys < 256 bits** (NIST recommendation)
- **DSA keys** (deprecated algorithm)
- **DH keys < 2048 bits**

#### CycloneDX Properties

Keys appear in the output with these properties:

```json
{
  "type": "cryptographic-asset",
  "name": "RSA-2048",
  "bom-ref": "key:rsa-2048-sha256:a1b2c3d4",
  "cryptoProperties": {
    "assetType": "related-crypto-material",
    "relatedCryptoMaterialProperties": {
      "type": "private-key",
      "state": "active",
      "size": 2048
    },
    "oid": "1.2.840.113549.1.1.1"
  },
  "properties": [
    { "name": "cbom:key:type", "value": "RSA" },
    { "name": "cbom:key:size", "value": "2048" },
    { "name": "cbom:key:format", "value": "PEM" },
    { "name": "cbom:key:classification", "value": "private" },
    { "name": "cbom:key:storage_security", "value": "ENCRYPTED" },
    { "name": "cbom:key:is_weak", "value": "false" },
    { "name": "cbom:pqc:status", "value": "UNSAFE" },
    { "name": "cbom:pqc:migration_urgency", "value": "HIGH" },
    { "name": "cbom:pqc:alternative", "value": "Kyber-768" },
    { "name": "cbom:pqc:break_estimate", "value": "2035" }
  ]
}
```

#### Common Use Cases

**Finding Unencrypted Private Keys:**
```bash
cbom-generator /etc/ssl --output cbom.json 2>/dev/null | \
  jq -r '.components[] |
    select(.cryptoProperties?.relatedCryptoMaterialProperties?.type == "private-key") |
    select(.properties[]? | select(.name == "cbom:key:storage_security" and .value == "PLAINTEXT")) |
    .evidence.occurrences[0].location'
```

**Identifying Weak Keys:**
```bash
cbom-generator --output cbom.json 2>/dev/null | \
  jq '.components[] |
    select(.properties[]? | select(.name == "cbom:key:is_weak" and .value == "true")) |
    {name: .name, location: .evidence.occurrences[0].location, reason: [.properties[] | select(.name == "cbom:key:weak_reason").value]}'
```

**HSM Inventory:**
```bash
cbom-generator --output cbom.json 2>/dev/null | \
  jq -r '.components[] |
    select(.properties[]? | select(.name == "cbom:key:storage_security" and .value == "HSM")) |
    "\(.name) - \(.evidence.occurrences[0].location)"'
```

**Security Note:** The scanner NEVER stores raw key material. Only SHA-256 hashes of key content are stored for identification purposes.

---

### Service Dependencies (Phase 7.2)

The Service Discovery Scanner automatically detects running services and maps their complete cryptographic dependency chains.

#### 4-Level Dependency Architecture

```
SERVICE → PROTOCOL → CIPHER_SUITE → ALGORITHM
```

This architecture enables complete PQC readiness assessment by tracing every algorithm used by each service.

#### Supported Services (69+ Total)

**Built-in Scanners (4):**
- Apache HTTPD, Nginx
- OpenSSH
- Postfix

**YAML Plugins (65+):**
- **Databases**: PostgreSQL, MySQL, MongoDB, MariaDB, Redis, Cassandra, Elasticsearch, InfluxDB, Neo4j, CouchDB
- **Web Servers**: Caddy, Traefik, HAProxy, lighttpd, uhttpd
- **Containers**: Docker, Kubernetes, K3s, containerd, Podman, balena-engine
- **VPN**: OpenVPN, WireGuard, strongSwan, tinc, OpenConnect
- **Mail**: Dovecot, Exim, Sendmail, Courier
- **Message Brokers**: RabbitMQ, Kafka, ActiveMQ, ZeroMQ, mosquitto
- **Monitoring**: Prometheus, Grafana, Fluentd
- **Application Servers**: Tomcat, Jetty, WildFly, Gunicorn, uWSGI
- **Other**: BIND (DNS), vsftpd/ProFTPD (FTP), Kong/Tyk (API), Memcached/Varnish (Cache), OpenLDAP, Samba

#### Detection Methods

Services are discovered using multiple detection methods:

1. **Process Detection**: Scanning `/proc` for running daemons
2. **Port Detection**: Analyzing `/proc/net/tcp` for listening services
3. **Config File Detection**: Finding configuration files in standard paths
4. **Systemd Detection**: Querying `systemctl` for active services
5. **Package Detection**: Checking installed packages (dpkg/rpm/pacman)

#### Application Scanner Detection Methods

The application scanner performs deep binary analysis and reports how crypto was detected:

| Detection Method | Description | Use Case |
|-----------------|-------------|----------|
| **BINARY_SCAN** | Sequential binary analysis | Single-threaded scanning |
| **BINARY_SCAN_PARALLEL** | Parallel binary analysis | Default multi-threaded mode |
| **KERNEL_CRYPTO_API** | Linux AF_ALG socket usage | Kernel crypto (cryptsetup, dm-crypt) |
| **STATIC_LINKED** | Statically linked crypto | Go/Rust binaries with embedded crypto |
| **SYMBOL_ANALYSIS** | Embedded crypto symbols | Binaries with OpenSSL/libgcrypt symbols |

**Detection Fallback Logic (v1.8.4):**

When parallel binary scanning finds no crypto libraries via dynamic linking, the scanner
attempts alternate detection methods in order:

1. **Kernel Crypto API**: Searches for AF_ALG markers (`algif_hash`, `algif_skcipher`)
2. **Static Linking**: Searches for Go (`crypto/tls`) or Rust (`ring::`, `rustls::`) markers
3. **Symbol Analysis**: Searches for embedded OpenSSL symbols (`AES_encrypt`, `SHA256_Init`)

This ensures statically-linked Go/Rust binaries and kernel crypto users are properly detected.

#### Deduplication Behavior

When both the YAML plugin system and application scanner detect the same binary:

- **YAML plugins preferred**: Plugins provide richer context (config paths, cipher suites)
- **Detection method preserved**: The winning component retains its original detection method
- **Evidence tracked**: Both detection sources are recorded in deduplication statistics

This means services detected by YAML plugins will show detection methods like `binary`,
`process`, or `config`, while application-scanner-only discoveries show `BINARY_SCAN_PARALLEL`
or the alternate method used.

#### Security Profiles

Services are automatically classified based on their TLS/SSH configuration:

| Profile | Criteria | Risk Level |
|---------|----------|------------|
| **MODERN** | TLS 1.3 only, no weak versions/ciphers | Low |
| **INTERMEDIATE** | TLS 1.2+ with strong ciphers | Medium |
| **OLD** | TLS 1.0/1.1 enabled or weak ciphers | **HIGH RISK** |
| **CUSTOM** | Custom configuration | Varies |

#### Example Dependency Chain

**Apache HTTPD with TLS 1.2:**

```
service:apache-httpd (Apache HTTPD 2.4.52)
  |-- USES --> protocol:tls (TLS 1.2)
      |-- PROVIDES --> cipher:tls-ecdhe-rsa-with-aes-256-gcm-sha384
          |-- USES --> algo:ecdhe (ECDHE key exchange)
          |-- USES --> algo:rsa (RSA authentication)
          |-- USES --> algo:aes-256-gcm-256 (AES-256-GCM encryption)
          |-- USES --> algo:sha384 (SHA384 MAC)
      |-- PROVIDES --> cipher:tls-ecdhe-rsa-with-aes-128-gcm-sha256
          |-- USES --> algo:ecdhe
          |-- USES --> algo:rsa
          |-- USES --> algo:aes-128-gcm-128
          |-- USES --> algo:sha256
```

**OpenSSH with PQC KEX:**

```
service:openssh (OpenSSH 8.9p1)
  |-- USES --> protocol:ssh-2 (SSH 2.0)
      |-- USES --> algo:curve25519-sha256 (X25519 KEX)
      |-- USES --> algo:ecdh-sha2-nistp256 (ECDH-P256 KEX)
      |-- USES --> algo:sntrup761x25519-sha512-openssh-com (PQC HYBRID KEX) [PQC SAFE]
```

#### CycloneDX Dependencies Array

The complete dependency graph appears in the `dependencies` array:

```json
{
  "dependencies": [
    {
      "ref": "service:apache-httpd",
      "dependsOn": ["protocol:tls"]
    },
    {
      "ref": "protocol:tls",
      "dependsOn": [
        "cipher:tls-ecdhe-rsa-with-aes-256-gcm-sha384",
        "cipher:tls-ecdhe-rsa-with-aes-128-gcm-sha256"
      ]
    },
    {
      "ref": "cipher:tls-ecdhe-rsa-with-aes-256-gcm-sha384",
      "dependsOn": [
        "algo:ecdhe",
        "algo:rsa",
        "algo:aes-256-gcm-256",
        "algo:sha384"
      ]
    }
  ]
}
```

#### Service Properties

Services include these properties:

```json
{
  "type": "operating-system",
  "name": "Apache HTTPD",
  "bom-ref": "service:apache-httpd",
  "properties": [
    { "name": "cbom:svc:name", "value": "Apache HTTPD" },
    { "name": "cbom:svc:version", "value": "2.4.52" },
    { "name": "cbom:svc:is_running", "value": "true" },
    { "name": "cbom:svc:port", "value": "443" },
    { "name": "cbom:svc:config_file", "value": "/etc/apache2/sites-enabled/default-ssl.conf" },
    { "name": "cbom:pqc:status", "value": "UNSAFE" }
  ]
}
```

#### Common Queries

**Finding Services by Security Profile:**
```bash
# List all services with OLD security profile (high risk)
cbom-generator --discover-services --output cbom.json 2>/dev/null | \
  jq -r '.components[] |
    select(.type == "operating-system") |
    select(.properties[]? | select(.name == "cbom:proto:security_profile" and .value == "OLD")) |
    "\(.name) - \(.properties[] | select(.name == "cbom:svc:config_file").value)"'
```

**Mapping Service Crypto Dependencies:**
```bash
# Show complete dependency chain for a service
cbom-generator --discover-services --output cbom.json 2>/dev/null | \
  jq '.dependencies[] | select(.ref | startswith("service:"))'
```

**Finding PQC-Ready Services:**
```bash
# List services using PQC/hybrid algorithms
cbom-generator --discover-services --output cbom.json 2>/dev/null | \
  jq -r '.components[] |
    select(.type == "operating-system") |
    select(.properties[]? | select(.name == "cbom:pqc:status" and .value == "SAFE")) |
    .name'
```

---

### Protocol Properties (Phase 7.2/7.3)

The Protocol Analysis module extracts detailed cryptographic protocol configurations from services.

#### Supported Protocol Types

| Protocol | Description | Detection Source |
|----------|-------------|------------------|
| **TLS** | Transport Layer Security | Apache, Nginx, Postfix configs |
| **SSH** | Secure Shell | sshd_config, ssh_config |
| **IPsec** | IP Security | strongSwan, OpenConnect configs |
| **DTLS** | Datagram TLS | VPN configurations |
| **QUIC** | Quick UDP Internet Connections | Modern web servers |
| **WireGuard** | WireGuard VPN | WireGuard configs |
| **OpenVPN** | OpenVPN protocol | OpenVPN configs |

#### TLS Version Detection

Protocols track which TLS versions are enabled:

```json
{
  "type": "cryptographic-asset",
  "name": "TLS",
  "bom-ref": "protocol:tls",
  "properties": [
    { "name": "cbom:proto:type", "value": "TLS" },
    { "name": "cbom:proto:version", "value": "1.3" },
    { "name": "cbom:proto:enabled_version", "value": "TLSv1.3" },
    { "name": "cbom:proto:enabled_version", "value": "TLSv1.2" },
    { "name": "cbom:proto:security_profile", "value": "MODERN" }
  ]
}
```

#### Weak Configuration Detection

The scanner automatically identifies risky protocol configurations:

**Weak TLS Versions:**
- SSLv2, SSLv3 (completely broken)
- TLSv1.0, TLSv1.1 (deprecated, weak)

**Weak Cipher Indicators:**
- RC4, DES, 3DES (weak encryption)
- NULL encryption (no confidentiality)
- EXPORT ciphers (deliberately weakened)
- Anonymous authentication (ADH, AECDH)
- MD5 hashing (cryptographically broken)

**Example Weak Protocol:**
```json
{
  "type": "cryptographic-asset",
  "name": "TLS",
  "bom-ref": "protocol:tls-old",
  "properties": [
    { "name": "cbom:proto:enabled_version", "value": "TLSv1.0" },
    { "name": "cbom:proto:enabled_version", "value": "TLSv1.1" },
    { "name": "cbom:proto:enabled_version", "value": "TLSv1.2" },
    { "name": "cbom:proto:weak_config", "value": "TLSv1.0 enabled (deprecated)" },
    { "name": "cbom:proto:weak_config", "value": "RC4 cipher enabled" },
    { "name": "cbom:proto:security_profile", "value": "OLD" }
  ]
}
```

#### TLS 1.3 Cipher Suites

TLS 1.3 supports a fixed list of 5 cipher suites (all AEAD-based):

| Cipher Suite | Encryption | Hash | Security Bits |
|--------------|------------|------|---------------|
| TLS_AES_256_GCM_SHA384 | AES-256-GCM | SHA384 | 256 |
| TLS_AES_128_GCM_SHA256 | AES-128-GCM | SHA256 | 128 |
| TLS_CHACHA20_POLY1305_SHA256 | ChaCha20-Poly1305 | SHA256 | 256 |
| TLS_AES_128_CCM_SHA256 | AES-128-CCM | SHA256 | 128 |
| TLS_AES_128_CCM_8_SHA256 | AES-128-CCM-8 | SHA256 | 128 |

**All TLS 1.3 cipher suites are quantum-vulnerable** (rely on classical key exchange).

#### Cipher Suite Decomposition

Each cipher suite is decomposed into its component algorithms:

```json
{
  "type": "cryptographic-asset",
  "name": "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
  "bom-ref": "cipher:tls-ecdhe-rsa-with-aes-256-gcm-sha384",
  "properties": [
    { "name": "cbom:cipher:protocol_family", "value": "TLS" },
    { "name": "cbom:cipher:encryption", "value": "AES-256-GCM" },
    { "name": "cbom:cipher:hash", "value": "SHA384" },
    { "name": "cbom:cipher:security_bits", "value": "256" },
    { "name": "cbom:cipher:quantum_vulnerable", "value": "true" }
  ]
}
```

#### SSH Protocol with PQC KEX

OpenSSH protocol components show PQC hybrid key exchange:

```json
{
  "type": "cryptographic-asset",
  "name": "SSH",
  "bom-ref": "protocol:ssh-2",
  "properties": [
    { "name": "cbom:proto:type", "value": "SSH" },
    { "name": "cbom:proto:version", "value": "2.0" },
    { "name": "cbom:proto:security_profile", "value": "MODERN" }
  ]
}
```

With dependency to PQC KEX algorithm:

```json
{
  "dependencies": [
    {
      "ref": "protocol:ssh-2",
      "dependsOn": [
        "algo:curve25519-sha256",
        "algo:ecdh-sha2-nistp256",
        "algo:sntrup761x25519-sha512-openssh-com"
      ]
    }
  ]
}
```

Where `sntrup761x25519-sha512@openssh.com` is marked as:
```json
{
  "properties": [
    { "name": "cbom:pqc:status", "value": "SAFE" },
    { "name": "cbom:pqc:is_hybrid", "value": "true" },
    { "name": "cbom:pqc:rationale", "value": "Hybrid classical+PQC KEX (X25519 + Streamlined NTRU Prime 761)" }
  ]
}
```

#### Common Queries

**Finding Weak Protocols:**
```bash
# List all protocols with weak configurations
cbom-generator --discover-services --output cbom.json 2>/dev/null | \
  jq '.components[] |
    select(.properties[]? | select(.name == "cbom:proto:weak_config")) |
    {name: .name, weaknesses: [.properties[] | select(.name == "cbom:proto:weak_config").value]}'
```

**Listing All Cipher Suites:**
```bash
# Show all enabled cipher suites
cbom-generator --discover-services --output cbom.json 2>/dev/null | \
  jq -r '.components[] |
    select(."bom-ref" | startswith("cipher:")) |
    "\(.name) (\(.properties[] | select(.name == "cbom:cipher:security_bits").value) bits)"'
```

**Finding PQC-Ready Services:**
```bash
# List services with PQC/hybrid algorithms
cbom-generator --discover-services --output cbom.json 2>/dev/null | \
  jq -r '.components[] |
    select(.type == "operating-system") |
    select(.properties[]? | select(.name == "cbom:pqc:status" and .value == "SAFE")) |
    "\(.name): \(.properties[] | select(.name == "cbom:pqc:rationale").value)"'
```

---

### PQC Readiness Assessment

**4 Safety Categories**:

| Category | Meaning | Examples | Risk Level |
|----------|---------|----------|------------|
| **SAFE** | Post-quantum secure | ML-KEM (Kyber), ML-DSA (Dilithium), SPHINCS+ | ✅ Low |
| **TRANSITIONAL** | Classically strong, quantum-vulnerable | RSA-2048+, ECDSA-P256+, AES-256, SHA-256 | ⚠️ Medium-High |
| **DEPRECATED** | Broken/weak algorithms | MD5, SHA-1, RC4, DES | 🚫 Critical |
| **UNSAFE** | Quantum-vulnerable + weak | RSA-1024, DSA | 🔴 Critical |

**v1.2 Enhancement: Break Year Estimation**

Starting in v1.2, each quantum-vulnerable algorithm includes an estimated break year based on NIST IR 8413 and NSA CNSA 2.0 guidance:

| Algorithm | Key Size | Break Year | Priority | Rationale |
|-----------|----------|------------|----------|-----------|
| RSA-1024, MD5, SHA-1, RC4, DES | - | **2030** | 🚨 CRITICAL | Already weakened by classical attacks |
| RSA-2048, ECDSA-P256, ECDH-P256 | 2048/256 bits | **2035** | ⚠️ HIGH | NIST baseline, NSA CNSA 2.0 deadline |
| RSA-3072, ECDSA-P384 | 3072/384 bits | **2040** | ⚡ MEDIUM | Conservative quantum resistance estimate |
| RSA-4096, ECDSA-P521 | 4096+/521 bits | **2045** | ℹ️ LOW | Optimistic, assumes slower quantum progress |

**Readiness Score**: 0-100% calculated as:
```
score = (SAFE×100 + TRANSITIONAL×50 + DEPRECATED×0 + UNSAFE×0) / total
```

**Migration Recommendations**:
- **< 30%**: CRITICAL - Immediate action required
- **30-60%**: Plan migration within 12-24 months
- **60-90%**: Good readiness - complete remaining migrations
- **> 90%**: PQC-ready - maintain configuration

**Example Output (v1.2 with break year distribution)**:
```json
{
  "properties": [
    {"name": "cbom:pqc:total_assets", "value": "351"},
    {"name": "cbom:pqc:safe_count", "value": "1"},
    {"name": "cbom:pqc:transitional_count", "value": "20"},
    {"name": "cbom:pqc:deprecated_count", "value": "0"},
    {"name": "cbom:pqc:unsafe_count", "value": "330"},
    {"name": "cbom:pqc:readiness_score", "value": "3.1"},
    {"name": "cbom:pqc:break_2030_count", "value": "119"},
    {"name": "cbom:pqc:break_2035_count", "value": "64"},
    {"name": "cbom:pqc:break_2040_count", "value": "0"},
    {"name": "cbom:pqc:break_2045_count", "value": "0"},
    {"name": "cbom:pqc:hybrid_detected", "value": "0"},
    {"name": "cbom:pqc:priority_assets", "value": "119"},
    {"name": "cbom:pqc:migration_timeline", "value": "2024"},
    {"name": "cbom:pqc:assessment_timestamp", "value": "2025-11-17T01:35:18Z"}
  ]
}
```

**Understanding Metrics**:
- `pqc_safe_count`: Number of unique PQC-safe algorithms (e.g., 1 for sntrup761)
- `pqc_safe_instances`: Number of configuration instances using PQC algorithms (e.g., 3 if server + system client + user client all use sntrup761)
- **Use `pqc_safe_count`** to track algorithm diversity
- **Use `pqc_safe_instances`** to measure deployment breadth

**Per-Component PQC Status (v1.2 Enhanced)**:
Every algorithm, certificate, and key includes comprehensive PQC assessment:
```json
{
  "name": "RSA-2048",
  "properties": [
    {
      "name": "cbom:pqc:status",
      "value": "TRANSITIONAL"
    },
    {
      "name": "cbom:pqc:confidence",
      "value": "HIGH"
    },
    {
      "name": "cbom:pqc:migration_urgency",
      "value": "HIGH"
    },
    {
      "name": "cbom:pqc:alternative",
      "value": "ML-DSA-65"
    },
    {
      "name": "cbom:pqc:break_estimate",
      "value": "2035"
    },
    {
      "name": "cbom:pqc:rationale",
      "value": "Quantum-vulnerable but meets current classical security standards (2048-bit key)"
    }
  ]
}
```

**Key Improvements in v1.2**:
- **Correct classification**: RSA-2048 is TRANSITIONAL (was incorrectly UNSAFE in v1.0-1.1)
- **Break year estimates**: Timeline-based vulnerability assessment
- **Rationale**: Explains why each classification was made
- **Hybrid detection**: Identifies X25519-ML-KEM-768 and similar hybrids

---

### PQC Classification Philosophy

The CBOM Generator uses different classification logic for **libraries** versus **services/applications**, reflecting their distinct security roles:

#### Libraries: Worst-Case Classification

Libraries are classified based on the **weakest (worst-case)** algorithm they implement:

| Library Implements | Classification | Rationale |
|-------------------|----------------|-----------|
| AES-256 + RSA-2048 + MD5 | **DEPRECATED** | MD5 is deprecated; library can be misused |
| AES-256 + RSA-2048 | **TRANSITIONAL** | RSA-2048 is quantum-vulnerable |
| AES-256 + ML-KEM-768 | **SAFE** | Both algorithms are PQC-safe |

**Why worst-case?** A library that implements weak cryptography poses a risk regardless of what else it implements. If an application links against a library with MD5 support, it *could* use MD5. The library's weakest algorithm defines its security ceiling.

**Example**: OpenSSL implements many algorithms including deprecated ones:
```json
{
  "name": "OpenSSL",
  "bom-ref": "library:openssl",
  "properties": [
    { "name": "cbom:pqc:status", "value": "DEPRECATED" },
    { "name": "cbom:pqc:rationale", "value": "Implements deprecated algorithm: MD5" }
  ]
}
```

#### Services/Applications: Best-Case Classification

Services and applications are classified based on the **best (strongest)** configured algorithm:

| Service Configured With | Classification | Rationale |
|------------------------|----------------|-----------|
| TLS_AES_256_GCM_SHA384 + curve25519-sha256 | **TRANSITIONAL** | No PQC KEX configured |
| TLS_AES_256_GCM_SHA384 + sntrup761x25519 | **SAFE** | PQC KEX available |
| SSLv3 + RC4 only | **DEPRECATED** | Only deprecated protocols |

**Why best-case?** If a service *can* use PQC algorithms, it's PQC-ready. Configuration determines actual behavior, not library capabilities. A service configured with both classical and PQC options will negotiate the strongest available algorithm.

**Algorithm Detection Paths**:

The generator uses multiple traversal paths to find all algorithms available to a service:

1. **Protocol Path** (TLS/HTTPS services):
   ```
   SERVICE → PROTOCOL → CIPHER_SUITE → ALGORITHM
   ```
   Used for: nginx, apache2, postfix, and other TLS-based services.

2. **Library Path** (SSH and embedded crypto services):
   ```
   SERVICE → LIBRARY → ALGORITHM
   ```
   Used for: OpenSSH (sshd), OpenVPN, and services with embedded crypto providers.

   SSH algorithms are provided by the `openssh-internal` library, not via TLS cipher suites. The generator follows DEPENDS_ON relationships to libraries, then checks which algorithms each library IMPLEMENTS or PROVIDES.

**PQC KEX Detection**:

The generator recognizes these Post-Quantum key exchange algorithms:
- `sntrup761*` / `sntrup*` / `ntruprime*` — NTRU Prime hybrid (OpenSSH)
- `mlkem*` / `ML-KEM*` / `kyber*` — ML-KEM/Kyber (TLS 1.3 PQC)
- `dilithium*` / `mldsa*` / `ML-DSA*` — ML-DSA/Dilithium (PQC signatures)

When any PQC algorithm is found via either path, the service is immediately classified as **SAFE**.

**Application vs Service Types**:

Discovered services may appear as either `ASSET_TYPE_SERVICE` or `ASSET_TYPE_APPLICATION` depending on how they were detected:
- **Binary scanners**: Detect running processes as APPLICATION with `cbom:app:role=service`
- **YAML plugins**: Detect services as SERVICE type

Both types use best-case classification when the `cbom:app:role=service` property is present.

**Example**: OpenSSH with PQC KEX configured:
```json
{
  "name": "sshd",
  "bom-ref": "app:sshd",
  "properties": [
    { "name": "cbom:app:role", "value": "service" },
    { "name": "cbom:pqc:status", "value": "SAFE" },
    { "name": "cbom:pqc:rationale", "value": "PQC-ready via sntrup761x25519-sha512@openssh.com" }
  ]
}
```

**Example**: Nginx without PQC groups configured:
```json
{
  "name": "nginx",
  "bom-ref": "service:nginx",
  "properties": [
    { "name": "cbom:pqc:status", "value": "TRANSITIONAL" },
    { "name": "cbom:pqc:rationale", "value": "Best available: TLS_AES_256_GCM_SHA384 (classical); no PQC algorithms configured" }
  ]
}
```

#### TLS 1.3 Layered Classification

TLS 1.3 requires special handling because its classification depends on the configured **Key Exchange (KEX)** groups, not just the cipher suite name:

**Service Level**: Check configured KEX groups
- With `ssl_ecdh_curve X25519:P-256` (classical only) → **TRANSITIONAL**
- With `ssl_ecdh_curve X25519MLKEM768:X25519` (PQC hybrid) → **SAFE**

**Cipher Suite Level**: Symmetric ciphers are quantum-resistant
- `TLS_AES_256_GCM_SHA384` → **SAFE** (as a cipher)
- `TLS_CHACHA20_POLY1305_SHA256` → **SAFE** (as a cipher)

**Algorithm Level**: Each decomposed algorithm is classified independently:
- AES-256-GCM → **SAFE** (symmetric, quantum-resistant)
- SHA-384 → **SAFE** (hash, quantum-resistant for current uses)
- X25519 → **TRANSITIONAL** (classical ECDH)
- X25519MLKEM768 → **SAFE** (hybrid PQC)

**Key Insight**: TLS 1.3's cipher suite names don't include the KEX algorithm (unlike TLS 1.2). The service's PQC status is determined by examining the configured `ssl_ecdh_curve` or equivalent setting.

```bash
# Find services without PQC KEX configured
cbom-generator --discover-services -o cbom.json 2>/dev/null
cat cbom.json | jq -r '.components[] |
  select(.type == "operating-system") |
  select(.properties[]? | select(.name == "cbom:pqc:status" and .value == "TRANSITIONAL")) |
  "\(.name): \(.properties[] | select(.name == "cbom:pqc:rationale").value)"'
```

#### Classification Summary Table

| Component Type | Logic | Question Answered |
|---------------|-------|-------------------|
| **Library** | Worst-case | "What's the weakest crypto this library can be misused for?" |
| **Certificate** | Key algorithm | "What algorithm protects this certificate?" |
| **Key** | Key algorithm | "What algorithm does this key support?" |
| **Service** | Best-case (config) | "Can this service use PQC when properly configured?" |
| **Application** | Best-case (config) | "Can this app use PQC with current configuration?" |
| **Protocol** | Best-case (suites) | "What's the strongest cipher suite available?" |
| **Cipher Suite** | Worst component | "What's the weakest algorithm in this suite?" |
| **Algorithm** | Intrinsic | "Is this specific algorithm quantum-safe?" |

#### Enabling PQC for Services

**OpenSSH** (v9.0+): Enable hybrid PQC KEX
```bash
# /etc/ssh/sshd_config
KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256
```

**Nginx** (OpenSSL 3.2+): Enable hybrid PQC groups
```nginx
ssl_ecdh_curve X25519MLKEM768:X25519:P-256;
```

**Apache** (OpenSSL 3.2+): Enable hybrid PQC groups
```apache
SSLOpenSSLConfCmd Curves X25519MLKEM768:X25519:P-256
```

After configuration, re-run the CBOM generator to verify PQC status:
```bash
./cbom-generator --discover-services --plugin-dir plugins \
  --format cyclonedx --cyclonedx-spec=1.7 \
  --no-personal-data -o /tmp/cbom.json /usr/sbin /etc

# Check sshd status (may appear as app:sshd or service:sshd)
cat /tmp/cbom.json | jq '.components[] |
  select(.name == "sshd" or .name == "openssh" or .name == "OpenSSH") |
  {name, "bom-ref", pqc: [.properties[] | select(.name | startswith("cbom:pqc:"))]}'
```

---

### Relationship Graph

**Dependency Tracking**: The generator builds a complete graph showing how services depend on protocols, which use cipher suites, which employ algorithms.

**Relationship Types**:

| Relationship | Description | Example |
|--------------|-------------|---------|
| **USES** | Consumer uses provider | Service uses Protocol, Protocol uses Algorithm |
| **PROVIDES** | Provider offers capability | Protocol provides Cipher Suite, Library provides Algorithm |
| **DEPENDS_ON** | Direct dependency | Application depends on Library, Certificate depends on Key |
| **AUTHENTICATES_WITH** | Service authenticates with certificate | nginx authenticates with server.crt |
| **CONFIGURES** | Service configures protocol settings | apache2 configures TLS 1.3 |
| **SIGNS** | Certificate signs another certificate | CA signs end-entity certificate |
| **ISSUED_BY** | Certificate issued by CA | End-entity issued by Intermediate CA |

**CycloneDX dependencies Array** (v1.1+ with readable bom-refs):
```json
{
  "dependencies": [
    {
      "ref": "service:nginx",
      "dependsOn": ["protocol:tls"]
    },
    {
      "ref": "cipher:tls-ecdhe-rsa-with-aes-256-gcm-sha384",
      "dependsOn": [
        "algo:aes-256-gcm-256",
        "algo:ecdhe",
        "algo:sha384"
      ]
    }
  ]
}
```

**Provider Properties**:
Components that provide services include `cbom:provides` property:
```json
{
  "name": "TLS",
  "type": "protocol",
  "properties": [
    {
      "name": "cbom:provides",
      "value": "cipher-suite-1, cipher-suite-2, ..."
    }
  ]
}
```

---

### Privacy Controls

**Privacy-by-Default** (GDPR/CCPA compliant):

**What is Redacted**:
- Hostnames
- Usernames
- Home directory paths (`/home/user` → `<path-hash-XXXXXXXX>`)
- Personally identifiable file paths

**What is NOT Redacted**:
- System paths (`/etc`, `/usr`, `/var`)
- Algorithm names and OIDs
- Certificate subjects/issuers (already pseudonymous)
- Cryptographic properties

**Redaction Method**:
- Salted hashing with CBOM_SALT environment variable
- Consistent across runs (same input → same pseudonym)
- Entropy validation (≥128 bits required)

**Privacy Metadata** (in output):
```json
{
  "metadata": {
    "privacy": {
      "no_personal_data": true,
      "redaction_applied": true,
      "methods": ["hostname_redaction", "path_redaction", "username_redaction"],
      "compliance": ["GDPR", "CCPA"],
      "mode": "privacy-by-default"
    }
  }
}
```

**Compliance & Future Enhancements**:

The v1.0 privacy controls provide baseline GDPR/CCPA compliance through:
- Hostname and username redaction
- Salted hashing for consistent pseudonyms
- Configurable personal data inclusion/exclusion
- Privacy metadata documentation in output

**Advanced Privacy Features (Planned for v2.0)**:
- Differential privacy with configurable epsilon
- k-anonymity guarantees for component sets
- Homomorphic aggregation for cross-organization analysis
- Zero-knowledge proofs for compliance verification

For immediate compliance needs, v1.0's `--no-personal-data` mode meets GDPR Article 25 (privacy by design) and CCPA 1798.100(c) requirements for de-identified data. For questions about specific compliance scenarios, consult your legal/compliance team or see `docs/PRIVACY_CONTROLS.md` (if available).

---

### Deduplication

**Modes**:

**OFF** - Legacy behavior, no deduplication:
- Same certificate found in 3 files → 3 separate components
- Use for: Forensic analysis, exact file-level tracking

**SAFE** (Default, Recommended) - Smart deduplication:
- Same certificate in 3 files → 1 component with 3 evidence occurrences
- Applies to: Certificates, keys, OpenPGP keys
- Use for: Most production scans

**STRICT** - Aggressive deduplication with bundles:
- Safe mode + bundle modeling
- Groups similar components (e.g., all CA certs → bundle)
- Use for: High-level inventory, executive summaries

**Deduplication Statistics** (in output):
```json
{
  "dedup_statistics": {
    "certificates_merged": 42,
    "keys_merged": 3,
    "files_suppressed": 45,
    "bundles_created": 2
  }
}
```

---

## Reading CycloneDX CBOM Output

### Top-Level Structure

```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.6",
  "serialNumber": "urn:uuid:...",
  "version": 1,
  "metadata": { /* Tool, host, provenance */ },
  "components": [ /* Array of cryptographic assets */ ],
  "dependencies": [ /* Provider/consumer graph */ ],
  "relationships": [ /* Typed edges with confidence */ ],
  "pqc_assessment": { /* PQC readiness analysis */ },
  "scan_completion_pct": 92,
  "completion": { /* Scanner completeness */ },
  "errors": [ /* Non-fatal issues */ ]
}
```

---

### Understanding Components

Every component represents a cryptographic asset with:

**Required Fields**:
- `type`: Component type (`cryptographic-asset`, `library`, `operating-system`)
- `name`: Human-readable name
- `bom-ref`: Unique identifier (v1.0: SHA-256 hash, v1.1+: human-readable)

**v1.1 Enhancement: Human-Readable bom-refs**

Starting in v1.1, bom-ref values are human-readable instead of SHA-256 hashes:

**Before (v1.0)**:
```json
"bom-ref": "5db9813bf30c015aaf7c729a5f84c415d6b1a90bf090f1fceb..."
```

**After (v1.1)**:
```json
"bom-ref": "cert:swisssign-gold-ca-g2"
```

**Format by Asset Type**:
- Certificates: `cert:<sanitized-cn>` (e.g., `cert:digicert-assured-id-root-ca`)
- Algorithms: `algo:<algorithm>-<keysize>` (e.g., `algo:aes-256-gcm-256`)
- Keys: `key:<algorithm>-<keysize>-<hash>` (e.g., `key:rsa-2048-a1b2c3d4`)
- Services: `service:<name>` (e.g., `service:apache-httpd`)
- Protocols: `protocol:<name>` (e.g., `protocol:tls`)
- Cipher Suites: `cipher:<name>` (e.g., `cipher:tls-ecdhe-rsa-with-aes-256-gcm-sha384`)

**Benefits**:
- Easy to identify components at a glance
- Dependencies are self-documenting
- Simpler debugging and analysis
- Better human readability

**Cryptographic Assets Include**:
- `cryptoProperties`: CycloneDX CBOM-specific fields
- `properties`: Namespaced cbom:* properties
- `evidence`: File locations and hashes where asset was found

#### Component Types

**cryptographic-asset** - Has `cryptoProperties` block:
- Algorithms (`assetType: "algorithm"`)
- Certificates (`assetType: "certificate"`)
- Keys (`assetType: "related-crypto-material"`)
- Protocols (`assetType: "protocol"`)
- Cipher Suites (`assetType: "algorithm"`)

**library** - Crypto libraries:
- OpenSSL, GnuTLS, libgcrypt, etc.
- Package manager tracked
- FIPS certification status

**operating-system** - Services:
- Apache, Nginx, OpenSSH, Postfix
- Configuration file paths
- Network endpoints

---

### cryptoProperties Explained

#### algorithmProperties

**For**: Algorithms and cipher suites

**Fields**:
```json
{
  "primitive": "ae",                    // Authenticated encryption
  "parameterSetIdentifier": "256",     // Key/digest length
  "mode": "gcm",                        // Block cipher mode
  "classicalSecurityLevel": 256,       // Bits of classical security
  "nistQuantumSecurityLevel": 5,       // NIST category (0-6)
  "certificationLevel": ["fips140-2-l1"], // FIPS certifications
  "policy": "CNSA"                      // Policy compliance
}
```

**Primitives**:
- `ae` - Authenticated encryption (AES-GCM, ChaCha20-Poly1305)
- `block-cipher` - AES, DES, 3DES
- `stream-cipher` - ChaCha20, Salsa20, RC4
- `hash` - SHA-2, SHA-3, BLAKE2, MD5
- `signature` - RSA, ECDSA, Ed25519, ML-DSA
- `key-agree` - ECDH, DH, X25519
- `mac` - HMAC
- `kdf` - PBKDF2, HKDF, scrypt
- `kem` - ML-KEM (Kyber), NTRU

#### certificateProperties

**For**: X.509 certificates

**Fields**:
```json
{
  "subjectName": "CN=Example CA",
  "issuerName": "CN=Root CA",
  "notValidBefore": "2020-01-01T00:00:00Z",  // ISO-8601
  "notValidAfter": "2030-01-01T00:00:00Z",   // ISO-8601
  "certificateFormat": "X.509",
  "certificateState": [
    {
      "state": "active",              // or: pre-activation, deactivated, revoked
      "activationDate": "2020-01-01T00:00:00Z",
      "deactivationDate": null,       // Set if expired/revoked
      "revocationDate": null,         // Set if revoked
      "reason": null                  // Revocation reason
    }
  ]
}
```

**Certificate States**:
- **pre-activation**: Not yet valid (notValidBefore in future)
- **active**: Currently valid
- **deactivated**: Expired (past notValidAfter)
- **revoked**: Revoked by CA (requires trust validation)

#### relatedCryptoMaterialProperties

**For**: Private keys, public keys, secrets

**Fields**:
```json
{
  "type": "private-key",              // or: public-key, secret-key, key
  "state": "active",                  // NIST SP 800-57 states
  "size": 2048,                       // Key size in bits
  "format": "PEM",                    // PEM, DER, OpenSSH
  "creationDate": "2024-01-01T00:00:00Z",     // Optional
  "activationDate": "2024-01-01T00:00:00Z",   // Optional
  "expirationDate": "2034-01-01T00:00:00Z"    // Optional
}
```

**Key States** (NIST SP 800-57):
- `pre-activation` - Generated but not yet active
- `active` - In use
- `suspended` - Temporarily disabled
- `deactivated` - No longer used for protection
- `compromised` - Known or suspected compromise
- `destroyed` - Securely erased

---

### Namespaced Properties (cbom:*)

All components include detailed properties using the `cbom:*` namespace:

#### Algorithm Properties
```json
{
  "name": "cbom:algo:primitive",
  "value": "block-cipher"
}
```

#### Certificate Properties
```json
{
  "name": "cbom:cert:signature_algorithm_oid",
  "value": "1.2.840.113549.1.1.11"  // RSA with SHA-256
},
{
  "name": "cbom:cert:not_before_epoch",  // Deprecated in v1.1
  "value": 1577836800
},
{
  "name": "cbom:cert:validity_state",
  "value": "active"                       // pre-activation, active, deactivated
},
{
  "name": "cbom:cert:revocation_status",
  "value": "GOOD"                         // GOOD, REVOKED, UNKNOWN
}
```

#### Key Properties
```json
{
  "name": "cbom:key:storage_security",
  "value": "plaintext"  // or: encrypted, hsm, tpm, keyring
},
{
  "name": "cbom:key:is_weak",
  "value": "false"
}
```

#### Protocol Properties
```json
{
  "name": "cbom:proto:security_profile",
  "value": "MODERN"  // MODERN, INTERMEDIATE, OLD
},
{
  "name": "cbom:proto:supported_versions",
  "value": "TLS 1.2, TLS 1.3"
}
```

#### PQC Properties

**Standard Properties (v1.0+)**:
```json
{
  "name": "cbom:pqc:status",
  "value": "TRANSITIONAL"  // SAFE, TRANSITIONAL, DEPRECATED, UNSAFE
},
{
  "name": "cbom:pqc:alternative",
  "value": "Dilithium-3"
},
{
  "name": "cbom:pqc:migration_urgency",
  "value": "HIGH"  // LOW, MEDIUM, HIGH, CRITICAL
},
{
  "name": "cbom:pqc:confidence",
  "value": "HIGH"  // HIGH, MEDIUM, LOW (calculated based on metadata quality)
}
```

**v1.2 Enhancement - New Properties**:
```json
{
  "name": "cbom:pqc:break_estimate",
  "value": "2035"  // Estimated year quantum computers can break (2030/2035/2040/2045)
},
{
  "name": "cbom:pqc:rationale",
  "value": "Quantum-vulnerable but meets current classical security standards (2048-bit key)"
},
{
  "name": "cbom:pqc:is_hybrid",
  "value": "true"  // Only present if hybrid algorithm detected (e.g., X25519-ML-KEM-768)
}
```

**Property Descriptions**:

- **cbom:pqc:status**: PQC safety category (SAFE/TRANSITIONAL/DEPRECATED/UNSAFE)
- **cbom:pqc:alternative**: Recommended PQC replacement algorithm
- **cbom:pqc:migration_urgency**: Migration priority level
- **cbom:pqc:confidence**: Classification confidence (HIGH/MEDIUM/LOW)
- **cbom:pqc:break_estimate** (v1.2): Year quantum computers expected to break this algorithm
  - Based on NIST IR 8413 + NSA CNSA 2.0 guidance
  - Helps prioritize migrations by deadline
- **cbom:pqc:rationale** (v1.2): Human-readable explanation of classification decision
  - Example: "NIST-finalized post-quantum algorithm"
  - Example: "Deprecated algorithm with known vulnerabilities"
- **cbom:pqc:is_hybrid** (v1.2): Flags hybrid classical+PQC algorithms
  - Detects: X25519-ML-KEM-768, P256-ML-DSA-65, etc.
  - Only present if hybrid detected

#### Context Properties
```json
{
  "name": "cbom:ctx:detection_method",
  "value": "FILE_CONTENT"  // or: CONFIG_PARSE, PROCESS_SCAN
},
{
  "name": "cbom:ctx:confidence",
  "value": "0.95"  // 0.0-1.0
}
```

---

### Dependencies Array

The `dependencies` array shows provider/consumer relationships (v1.1+ with readable bom-refs):

```json
{
  "dependencies": [
    {
      "ref": "service:nginx",
      "dependsOn": [
        "protocol:tls",
        "library:openssl"
      ]
    },
    {
      "ref": "cipher:tls-ecdhe-rsa-with-aes-256-gcm-sha384",
      "dependsOn": [
        "algo:aes-256-gcm-256",
        "algo:ecdhe",
        "algo:sha384"
      ]
    }
  ]
}
```

**Key Points**:
- **ref**: Consumer component ID (readable bom-ref in v1.1+)
- **dependsOn**: Array of provider component IDs (readable in v1.1+)
- **Directionality**: Consumer depends on provider (correct semantics)
- **Sorted**: Arrays sorted alphabetically for determinism
- **Validated**: No dangling refs, no self-dependencies

**v1.1 Improvement**: All refs now use human-readable identifiers (e.g., `service:nginx`, `algo:aes-256-gcm-256`) instead of SHA-256 hashes, making dependency graphs self-documenting

---

### Relationships Array

The `relationships` array provides detailed typed edges with confidence:

```json
{
  "relationships": [
    {
      "type": "USES",
      "source": "service|apache",
      "target": "protocol|TLS",
      "confidence": "0.95"
    },
    {
      "type": "PROVIDES",
      "source": "protocol|TLS",
      "target": "cipher-suite-123",
      "confidence": "0.95"
    },
    {
      "type": "evidence",
      "source": "/etc/ssl/cert.pem",
      "target": "component-456"
    }
  ]
}
```

**Relationship Types**:

| Type | Description | Created When |
|------|-------------|--------------|
| `USES` | Consumer uses provider | Service uses protocol/algorithm |
| `PROVIDES` | Provider offers capability | Protocol provides cipher suite, Library provides algorithm |
| `DEPENDS_ON` | Direct dependency | Application depends on library, Certificate depends on key |
| `AUTHENTICATES_WITH` | Authentication relationship | Service authenticates with certificate |
| `CONFIGURES` | Configuration relationship | Service configures protocol settings |
| `SIGNS` | Signing relationship | CA certificate signs another certificate |
| `ISSUED_BY` | Issuance relationship | Certificate issued by CA |
| `evidence` | File evidence | File contains component |

---

## Use Cases & Examples

### Use Case 1: PQC Migration Planning (v1.2 Enhanced)

**Goal**: Identify quantum-vulnerable components and generate migration timeline

**Step 1: Generate CBOM + Migration Report**
```bash
# Generate comprehensive PQC assessment
./build/cbom-generator /etc/ssl/certs \
  --output pqc-scan.json \
  --pqc-report migration-report.txt

# View migration report
cat migration-report.txt
```

**Step 2: Query by Break Year**
```bash
# List CRITICAL assets (break by 2030)
jq '.components[] | select(.properties[]?.name == "cbom:pqc:break_estimate" and .properties[]?.value == "2030") | {name, algorithm: (.properties[] | select(.name == "cbom:cert:public_key_algorithm").value // .name)}' pqc-scan.json

# List HIGH priority assets (break by 2035)
jq '.components[] | select(.properties[]?.name == "cbom:pqc:break_estimate" and .properties[]?.value == "2035") | {name, alternative: (.properties[] | select(.name == "cbom:pqc:alternative").value)}' pqc-scan.json
```

**Step 3: Check Metadata Summary**
```bash
# View break year distribution
jq '.properties[] | select(.name | startswith("cbom:pqc:break_")) | {name, value}' pqc-scan.json
```

**Output**:
```json
{"name": "cbom:pqc:break_2030_count", "value": "119"}
{"name": "cbom:pqc:break_2035_count", "value": "64"}
{"name": "cbom:pqc:priority_assets", "value": "119"}
{"name": "cbom:pqc:migration_timeline", "value": "2024"}
```

**Interpretation**:
- 119 assets need migration by 2030 (CRITICAL)
- 64 assets need migration by 2035 (HIGH - NSA CNSA 2.0 deadline)
- Recommended start: 2024 (immediate planning required)

---

### Use Case 2: Certificate Lifecycle Tracking

**Goal**: Find expiring or expired certificates

```bash
# Scan with certificate lifecycle data
./build/cbom-generator --format cyclonedx --output certs.json

# Find certificates expiring soon
jq '.components[] | select(.cryptoProperties.assetType == "certificate") | select(.cryptoProperties.certificateProperties.certificateState[0].state == "active") | {subject: .cryptoProperties.certificateProperties.subjectName, expires: .cryptoProperties.certificateProperties.notValidAfter}' certs.json

# Find expired certificates
jq '.components[] | select(.cryptoProperties.assetType == "certificate") | select(.cryptoProperties.certificateProperties.certificateState[0].state == "deactivated") | .cryptoProperties.certificateProperties.subjectName' certs.json
```

---

### Use Case 3: Service Dependency Mapping

**Goal**: Understand which services depend on which cryptographic components

```bash
# Generate CBOM with full relationship graph
./build/cbom-generator --format cyclonedx --output services.json

# Extract service dependencies
jq '.dependencies[] | select(.ref | contains("service|"))' services.json
```

**Output**:
```json
{
  "ref": "service|Apache HTTPD",
  "dependsOn": ["protocol|TLS"]
}
{
  "ref": "service|OpenSSH",
  "dependsOn": ["protocol|SSH"]
}
```

**Visualize full dependency chain**:
```bash
jq -r '.relationships[] | select(.type == "USES" or .type == "PROVIDES") | "\(.source) --[\(.type)]-> \(.target)"' services.json
```

---

### Use Case 4: Privacy-Compliant Audit

**Goal**: Generate CBOM for audit without exposing sensitive data

```bash
# Privacy mode with CBOM_SALT
export CBOM_SALT="your-random-salt-here-min-16-chars-required"

# Generate privacy-compliant CBOM
./build/cbom-generator \
  --no-personal-data \
  --no-network \
  --format cyclonedx \
  --output audit-cbom.json

# Verify privacy controls
jq '.metadata.privacy' audit-cbom.json
```

**Output**:
```json
{
  "no_personal_data": true,
  "redaction_applied": true,
  "methods": ["hostname_redaction", "path_redaction"],
  "compliance": ["GDPR", "CCPA"]
}
```

---

### Use Case 5: FIPS Compliance Check

**Goal**: Identify FIPS 140-2/3 certified implementations

```bash
# Generate CBOM
./build/cbom-generator --format cyclonedx --output fips.json

# Find FIPS-certified algorithms
jq '.components[] | select(.cryptoProperties.algorithmProperties.certificationLevel) | {name, certifications: .cryptoProperties.algorithmProperties.certificationLevel}' fips.json
```

**Note**: v1.0 includes stub FIPS metadata. Full NIST CMVP validation deferred to v1.1.

---

### Use Case 6: Weak Algorithm Detection

**Goal**: Find deprecated or weak cryptographic algorithms

```bash
# Generate CBOM
./build/cbom-generator --format cyclonedx --output weak.json

# Find DEPRECATED algorithms
jq '.components[] | select(any(.properties[]?; .name == "cbom:pqc:status" and .value == "DEPRECATED")) | .name' weak.json
```

**Common Deprecated Algorithms**:
- MD5
- SHA-1
- RC4
- DES (single DES, not 3DES)
- SSLv3, TLS 1.0, TLS 1.1

---

## Interpreting Results

### PQC Readiness Scores

| Score | Status | Action Required |
|-------|--------|-----------------|
| **90-100%** | 🟢 PQC-Ready | Maintain current configuration |
| **60-90%** | 🟡 Good | Complete remaining migrations |
| **30-60%** | 🟠 Moderate | Plan migration in 12-24 months |
| **0-30%** | 🔴 Critical | Immediate action required |

**Example Interpretation**:
```
Score: 4.9%
Status: CRITICAL
Assets: 203 total (0 safe, 20 transitional, 0 deprecated, 183 unsafe)

Analysis:
- 90% of assets are quantum-vulnerable (RSA, ECDSA, ECDH)
- Only 10% are classically strong symmetric algorithms
- No PQC algorithms deployed yet
- Immediate migration planning required
```

---

### Trust Validation Status

**Certificate Trust Status** (from `cbom:cert:trust_status`):

| Status | Meaning |
|--------|---------|
| `VALID` | Certificate is trusted and valid |
| `EXPIRED` | Certificate has expired |
| `NOT_YET_VALID` | Certificate not yet valid |
| `REVOKED` | Certificate revoked by CA |
| `UNTRUSTED_CA` | CA not in system trust store |
| `SELF_SIGNED` | Self-signed certificate |
| `CHAIN_INCOMPLETE` | Trust chain cannot be built |
| `WEAK_SIGNATURE` | Uses weak signature algorithm |
| `UNKNOWN` | Trust status cannot be determined |

---

### Weakness Detection

**Algorithm Weakness** (from `cbom:pqc:status`):
- `DEPRECATED`: Known broken/weak (MD5, SHA-1, RC4, DES)
- `UNSAFE`: Quantum-vulnerable (RSA, ECDSA, ECDH, DSA)

**Certificate Weakness**:
- Expired certificates
- Self-signed without validation
- Weak signatures (MD5, SHA-1)
- Small key sizes (RSA <2048, ECDSA <256)

**Protocol Weakness**:
- SSLv3, TLS 1.0, TLS 1.1
- Weak cipher suites (NULL, EXPORT, RC4, DES)
- Security profile: OLD or INTERMEDIATE

---

## Troubleshooting

### Issue: No Components Found

**Symptoms**: Empty components array

**Solutions**:
```bash
# Check scanner output
./build/cbom-generator 2>&1 | grep "scan complete"

# Try scanning specific directory
./build/cbom-generator /etc/ssl

# Check permissions
sudo ./build/cbom-generator --output cbom.json
```

---

### Issue: Low PQC Readiness Score

**Expected**: Most systems will show <30% readiness until PQC migration

**This is normal** - indicates work needed:
1. Review `pqc_assessment.migration_recommendations`
2. List UNSAFE components: `jq '.components[] | select(any(.properties[]?; .name == "cbom:pqc:status" and .value == "UNSAFE"))'`
3. Prioritize asymmetric algorithm migration (RSA → Dilithium, ECDH → Kyber)
4. Plan hybrid cipher suite deployment

---

### Issue: Permission Denied Errors

**Symptoms**: Many files skipped, errors in output

**Solutions**:
```bash
# Run with appropriate permissions
sudo ./build/cbom-generator --output cbom.json

# Or scan specific accessible directory
./build/cbom-generator $HOME/.ssh
```

**Check errors array**:
```bash
jq '.errors[]' cbom.json
```

---

### Issue: Large Output File

**Symptoms**: CBOM >100MB

**Solutions**:
```bash
# Use deduplication
./build/cbom-generator --dedup-mode=safe --output cbom.json

# Strict deduplication
./build/cbom-generator --dedup-mode=strict --output cbom.json

# Scan specific directories instead of entire system
./build/cbom-generator /etc/ssl /etc/ssh --output cbom.json
```

---

### Issue: Resource Limit Exceeded

**Symptoms**:
- Log message: `ERROR: Filesystem scanning failed: Resource limit exceeded`
- CBOM metadata shows `cbom:scan_completion_pct` less than 100%
- Some expected components missing from output

**Explanation**:

The scanner has built-in resource limits to prevent runaway scans on large filesystems:

| Resource | Default Limit | Purpose |
|----------|---------------|---------|
| `scan_max_files` | 10,000 per scanner | Prevents excessive scan times |
| `scan_depth_limit` | 5 levels | Limits directory recursion depth |
| `max_packages` | 10,000 | Package manager query limit |

These limits are reported in the CBOM metadata:
```bash
cat cbom.json | jq '.metadata.properties[] | select(.name | test("scan_max_files|scan_depth_limit|completion"))'
```

**Checking if limits were hit**:
```bash
# Check stderr/log for resource errors
./build/cbom-generator /usr 2>&1 | grep -i "limit\|exceeded"

# Check completion percentage in CBOM
cat cbom.json | jq '.metadata.properties[] | select(.name == "cbom:scan_completion_pct")'
# Value < 100 indicates incomplete scan
```

**Solutions**:

1. **Scan specific directories** instead of broad paths:
   ```bash
   # Instead of scanning all of /usr
   ./build/cbom-generator /usr/lib/x86_64-linux-gnu /usr/local/lib

   # Target crypto-relevant locations
   ./build/cbom-generator /etc/ssl /etc/ssh /usr/lib/ssl
   ```

2. **Prioritize root-level files**: The scanner uses two-pass traversal to process files before subdirectories, ensuring important libraries at the root level (like `/usr/local/lib/liboqs.so`) are scanned before hitting limits in deep subdirectories.

3. **Run multiple targeted scans**: Generate separate CBOMs for different subsystems and merge if needed.

**Note**: The `scan_completion_pct` in CBOM metadata indicates what percentage of the requested scan completed successfully. A value below 100% combined with the "Resource limit exceeded" error means some files were not scanned.

---

### Issue: Non-Deterministic Output

**Symptoms**: Different hash on each run

**Solutions**:
```bash
# Ensure deterministic mode enabled (default)
./build/cbom-generator --deterministic --output cbom.json

# Set CBOM_SALT for consistent pseudonyms
export CBOM_SALT="your-consistent-salt"
./build/cbom-generator --output cbom.json
```

**Check determinism**:
```bash
./build/cbom-generator --output run1.json
./build/cbom-generator --output run2.json
diff run1.json run2.json
# Should show only timestamp differences if --no-deterministic
```

---

### Performance Tuning

**Slow Scans**:
```bash
# Increase thread count
./build/cbom-generator --threads 16 --output cbom.json

# Skip network operations
./build/cbom-generator --no-network --output cbom.json
```

**High Memory Usage**:
```bash
# Reduce thread count
./build/cbom-generator --threads 2 --output cbom.json

# Scan smaller directories
./build/cbom-generator /etc/ssl --output cbom.json
```

**Cache Behavior**:
The generator uses SQLite-based persistent caching for 10x+ performance improvement on repeated scans.

**Cache Details**:
- **Location**: `~/.cache/cbom/` (per-user)
- **Storage**: Encrypted SQLite database
- **TTL**: File modification time-based invalidation
- **Size**: Typically <10MB for full system scan
- **Performance**: First scan: ~20s, subsequent scans: ~2s (on same files)

**Cache Management**:
```bash
# Clear cache if corrupted
rm -rf ~/.cache/cbom/

# Check cache size
du -sh ~/.cache/cbom/

# Disable cache (for testing)
# Note: No CLI flag yet, cache always enabled in v1.0
```

**Cache Invalidation**: Automatic when files are modified (based on mtime). No manual invalidation needed in normal operation.

---

## Advanced Usage

### Comparing CBOMs Over Time

```bash
# Generate baseline
./build/cbom-generator --deterministic --output baseline.json

# After system changes
./build/cbom-generator --deterministic --output current.json

# Compare
diff <(jq -S . baseline.json) <(jq -S . current.json)
```

---

### Filtering Output

**Extract specific asset types**:
```bash
# All certificates
jq '.components[] | select(.cryptoProperties.assetType == "certificate")' cbom.json

# All algorithms
jq '.components[] | select(.cryptoProperties.assetType == "algorithm")' cbom.json

# All services
jq '.components[] | select(.type == "operating-system")' cbom.json
```

**Extract by PQC status**:
```bash
# All quantum-vulnerable components
jq '.components[] | select(any(.properties[]?; .name == "cbom:pqc:status" and .value == "UNSAFE"))' cbom.json

# Components needing migration
jq '.components[] | select(any(.properties[]?; .name == "cbom:pqc:status" and (.value == "UNSAFE" or .value == "DEPRECATED")))' cbom.json
```

---

### Generating Reports

**PQC Migration Report**:
```bash
./build/cbom-generator --format cyclonedx --output pqc.json

echo "PQC Readiness Report"
echo "===================="
jq -r '.pqc_assessment | "
Readiness Score: \(.readiness_score)%
Total Assets: \(.total_assets)
- Safe (PQC): \(.pqc_safe_count)
- Transitional: \(.pqc_transitional_count)
- Deprecated: \(.pqc_deprecated_count)
- Unsafe: \(.pqc_unsafe_count)

Recommendations:
\(.migration_recommendations | join("\n"))
"' pqc.json
```

**Certificate Expiration Report**:
```bash
jq -r '.components[] | select(.cryptoProperties.assetType == "certificate") | select(.cryptoProperties.certificateProperties.certificateState[0].state == "deactivated") | "EXPIRED: \(.cryptoProperties.certificateProperties.subjectName) (expired: \(.cryptoProperties.certificateProperties.notValidAfter))"' cbom.json
```

---

## Output Format

### CycloneDX Format (Only Supported Format)

The CBOM Generator outputs exclusively in **CycloneDX format** - the industry-standard SBOM format with cryptographic extensions.

**Note**: The `--format` flag is vestigial (accepted for backward compatibility but has no effect). All output is CycloneDX regardless of the flag value.

**Why CycloneDX Only?**:
- Industry-standard SBOM format with broad tool support
- Native cryptoProperties support (CycloneDX 1.6+)
- Lifecycle and state tracking capabilities
- Dependency graph and relationship support
- Compliance-ready for audit use cases

### CycloneDX Specification Versions

The generator supports both CycloneDX 1.6 and 1.7:

**CycloneDX 1.6** (default):
```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.6",
  "components": [
    {
      "type": "cryptographic-asset",
      "bom-ref": "abc123...",
      "cryptoProperties": {
        "assetType": "algorithm",
        "algorithmProperties": {...}
      }
    }
  ],
  "dependencies": [...],
  "pqc_assessment": {...}
}
```

**CycloneDX 1.7**:
- Same structure as 1.6
- Only difference: `"specVersion": "1.7"`
- Use when: Tools require latest spec version

**Selecting version**:
```bash
# CycloneDX 1.6 (default)
./build/cbom-generator --output cbom.json

# CycloneDX 1.7
./build/cbom-generator --cyclonedx-spec=1.7 --output cbom.json
```

---

## Deprecated Features

### Epoch Timestamps (Deprecated in v1.1)

**Current** (v1.0):
```json
{
  "name": "cbom:cert:not_before_epoch",
  "value": 1577836800
}
```

**Canonical Source**:
```json
{
  "cryptoProperties": {
    "certificateProperties": {
      "notValidBefore": "2020-01-01T00:00:00Z"
    }
  }
}
```

**Migration Path**: Use ISO-8601 timestamps in `certificateProperties` instead of epoch integers. The `*_epoch` fields will be removed in v1.1.

---

## Best Practices

### 1. Always Use Privacy Mode for External Sharing
```bash
./build/cbom-generator --no-personal-data --no-network --output cbom.json
```

### 2. Enable Deduplication for Production Scans
```bash
./build/cbom-generator --dedup-mode=safe --output cbom.json
```

### 3. Use CycloneDX Format for Interoperability
```bash
./build/cbom-generator --format cyclonedx --output cbom.cdx.json
```

### 4. Set Consistent CBOM_SALT for Reproducibility
```bash
export CBOM_SALT="$(openssl rand -hex 32)"
./build/cbom-generator --output cbom.json
```

### 5. Validate Output Against Schema
```bash
# Included in build
./tests/validate_schemas.sh
```

---

## Further Reading

### Technical Documentation

- **[DESIGN.md](docs/DESIGN.md)**: Technical architecture and implementation details (~250KB, comprehensive design document)
- **[REQUIREMENTS.md](docs/REQUIREMENTS.md)**: Formal requirements specification with acceptance criteria
- **[V1_0_RELEASE_READINESS.md](V1_0_RELEASE_READINESS.md)**: Release verification and acceptance criteria
- **[PLUGIN_SYSTEM.md](docs/PLUGIN_GUIDE.md)**: Plugin development guide with API reference
- **[PQC_ASSESSMENT.md](docs/PQC_ASSESSMENT.md)**: Detailed PQC migration guidance (662 lines)
- **[NORMALIZATION.md](docs/NORMALIZATION.md)**: Asset normalization specification with test vectors

### Standards References

- **CycloneDX Specification**: https://cyclonedx.org/specification/overview/
- **NIST IR 8413**: Status Report on the Third Round of the NIST Post-Quantum Cryptography Standardization Process
- **NIST SP 800-57**: Recommendation for Key Management
- **NIST FIPS 203/204/205**: ML-KEM, ML-DSA, SLH-DSA standards

---

## Support

### Getting Help

```bash
# Built-in help
./build/cbom-generator --help

# Version information
./build/cbom-generator --version
```

### Reporting Issues

For bugs, feature requests, or questions:
- GitHub Issues: [repository]/issues
- Documentation: See `docs/` directory
- Test Suite: `cd build && ctest`

---

## Appendix: Complete CLI Syntax

```
Usage: cbom-generator [OPTIONS] [TARGET_PATH]

Cryptographic Bill of Materials (CBOM) Generator
Inventories cryptographic assets on Linux systems

Options:
  -o, --output FILE          Output file path (default: stdout)
  -f, --format FORMAT        Output format: json, cyclonedx (vestigial - always outputs CycloneDX)
      --cyclonedx-spec VER   CycloneDX spec version: 1.6, 1.7 (default: 1.6)
  -t, --threads N            Number of worker threads (default: CPU count)
  -d, --deterministic        Enable deterministic output (default: on)
      --no-deterministic     Disable deterministic output

Privacy Options:
      --no-personal-data     Redact personal data (default: on)
      --include-personal-data Include personal data + scan user SSH configs
      --no-network           Disable network operations (no-op in v1.0)

Attestation Options:
      --enable-attestation   Enable CBOM attestation with digital signature
      --signature-method M   Signature method: dsse, pgp (default: dsse)
      --signing-key PATH     Path to signing key file

Deduplication Options:
      --dedup-mode MODE      Deduplication mode: off, safe, strict (default: safe)
      --emit-bundles         Emit bundle components in strict mode

Service Discovery Options (v1.3):
      --discover-services    Enable YAML plugin-driven service discovery
      --plugin-dir DIR       Custom plugin directory (default: plugins/)
      --list-plugins         List all loaded plugins and exit

Display Options:
      --tui                  Enable terminal user interface with progress display
      --error-log FILE       Write errors to log file (useful with --tui)
      --pqc-report FILE      Generate PQC migration report (text format)

  -h, --help                 Show this help message
  -v, --version              Show version information

Examples:
  cbom-generator                                      # Scan system, CycloneDX to stdout
  cbom-generator -o cbom.json                         # Save CycloneDX to file
  cbom-generator --cyclonedx-spec=1.7 -o cbom.json    # CycloneDX 1.7 format
  cbom-generator --tui -o cbom.json                   # Interactive TUI with progress
  cbom-generator --tui --error-log errors.log -o cbom.json  # TUI with error logging
  cbom-generator --discover-services -o discovered.json    # Service discovery (v1.3)
  cbom-generator --list-plugins                            # List available plugins (v1.3)
  cbom-generator --discover-services --plugin-dir /custom  # Custom plugins (v1.3)
  cbom-generator --no-network                         # Privacy mode (default)
  cbom-generator --include-personal-data -o cbom.json # Include hostnames/usernames
  cbom-generator --enable-attestation --signing-key key.pem  # Sign CBOM output

Target Path:
  Optional positional argument specifying directory to scan (default: current directory)

Environment Variables:
  CBOM_SALT          Salt for privacy hashing (min 16 characters, 128+ bits entropy)
                     Used for consistent pseudonym generation across runs
```
---
## YOCTO
For a given Yocto image, the BSP team can:

Edit soname_patterns to match their actual libs (e.g. libmbedtls.so.3, libvendorcrypto.so).

Add or remove crypto_libraries entries without touching C code.
---

## License & Copyright

CBOM Generator v1.0.0
Copyright © 2025

---

**End of User Manual**
