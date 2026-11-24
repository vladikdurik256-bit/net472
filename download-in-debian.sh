#!/usr/bin/env bash
set -euo pipefail
cd /kit
export DEBIAN_FRONTEND=noninteractive
# First download the full dependency closure on a clean Debian 13 image.
mkdir -p bundle/packages bundle/roslyn
cp payload/* bundle/
apt-get update
apt-get -y --download-only --no-install-recommends -o Dir::Cache::archives=/kit/bundle/packages install \
  mono-devel mono-xbuild libgdiplus xvfb xauth fonts-dejavu-core \
  libmono-system-numerics4.0-cil libmono-system-numerics-vectors4.0-cil \
  libmono-system-drawing4.0-cil libmono-system-windows-forms4.0-cil \
  libmono-system-xml-linq4.0-cil libmono-system-data4.0-cil \
  libmono-system-data-datasetextensions4.0-cil libmono-system-deployment4.0-cil \
  libmono-system-net-http4.0-cil libmono-system-io-compression4.0-cil \
  libmono-system-io-compression-filesystem4.0-cil
# Only install network download helpers after collecting Mono dependencies.
apt-get -y --no-install-recommends install ca-certificates curl unzip
url=https://api.nuget.org/v3-flatcontainer/microsoft.net.compilers.toolset/4.8.0/microsoft.net.compilers.toolset.4.8.0.nupkg
curl --fail --location --retry 3 "$url" -o /tmp/roslyn.nupkg
unzip -q /tmp/roslyn.nupkg -d bundle/roslyn
[[ -f bundle/roslyn/tasks/net472/csc.exe ]]
rm -f bundle/packages/lock
rmdir bundle/packages/partial 2>/dev/null || true
cd bundle
find packages roslyn -type f -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS
