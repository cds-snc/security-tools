#!/bin/bash

#
# Downloads and installs the Trivy binary for the current runner architecture,
# verifying it against a hardcoded SHA256 checksum.
#
# Usage:
#   install_trivy.sh <version> <sha256_amd64> <sha256_arm64>
#
# Arguments:
#   version       Trivy version without the 'v' prefix, e.g. 0.69.3
#   sha256_amd64  Expected SHA256 checksum of the Linux-64bit tarball
#   sha256_arm64  Expected SHA256 checksum of the Linux-ARM64 tarball
#

set -euo pipefail

TRIVY_VERSION="${1:-}"
SHA256_AMD64="${2:-}"
SHA256_ARM64="${3:-}"

if [[ -z "$TRIVY_VERSION" || -z "$SHA256_AMD64" || -z "$SHA256_ARM64" ]]; then
  echo "Usage: $0 <version> <sha256_amd64> <sha256_arm64>"
  exit 1
fi

ARCH="$(uname -m)"
if [[ "$ARCH" == "x86_64" ]]; then
  ASSET="trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz"
  EXPECTED_SHA="$SHA256_AMD64"
elif [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
  ASSET="trivy_${TRIVY_VERSION}_Linux-ARM64.tar.gz"
  EXPECTED_SHA="$SHA256_ARM64"
else
  echo "Unsupported runner architecture: $ARCH"
  exit 1
fi

echo "Downloading ${ASSET}..."
curl --silent --show-error --location \
  "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/${ASSET}" \
  --output "/tmp/${ASSET}"

echo "Verifying checksum..."
if ! echo "${EXPECTED_SHA}  /tmp/${ASSET}" | shasum -a 256 --check --status; then
  echo "ERROR: Checksum verification failed for ${ASSET}" >&2
  echo "  Expected: ${EXPECTED_SHA}" >&2
  exit 1
fi
echo "Checksum verified: ${ASSET}"

tar --extract --file "/tmp/${ASSET}" --directory /tmp trivy
mv /tmp/trivy /usr/local/bin/trivy
chmod +x /usr/local/bin/trivy
