#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
[[ ! -e bundle ]] || { echo 'Move/delete existing bundle before rebuilding'; exit 1; }
docker run --rm --platform linux/amd64 -v "$PWD:/kit" debian:13-slim bash /kit/download-in-debian.sh
# A second fresh container has no network: the offline pack must work by itself.
docker run --rm --network none --platform linux/amd64 -v "$PWD:/kit" debian:13-slim bash -c 'set -o pipefail; (bash /kit/bundle/setup.sh && bash /kit/bundle/test.sh) 2>&1 | tee /kit/bundle/VALIDATION.log'
(cd bundle && zip -qr ../Mono_Full_Offline_NET472.zip . -x 'out/*')
