#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
[[ $(id -u) == 0 ]] || { echo 'Run as root'; exit 1; }
[[ $(dpkg --print-architecture) == amd64 ]] || { echo 'Expected amd64'; exit 1; }
. /etc/os-release
[[ "$ID" == debian && "$VERSION_ID" == 13 ]] || { echo 'Expected Debian 13'; exit 1; }
sha256sum -c SHA256SUMS
export DEBIAN_FRONTEND=noninteractive
# Skip packages already present at equal or newer versions, including system libraries.
packages=()
for deb in "$PWD"/packages/*.deb; do
  p=$(dpkg-deb -f "$deb" Package); v=$(dpkg-deb -f "$deb" Version)
  installed=$(dpkg-query -W -f='${Version}' "$p" 2>/dev/null || true)
  status=$(dpkg-query -W -f='${Status}' "$p" 2>/dev/null || true)
  if [[ "$status" == 'install ok installed' && -n "$installed" ]] && dpkg --compare-versions "$installed" ge "$v"; then continue; fi
  packages+=("$deb")
done
if ((${#packages[@]})); then
  offline=$(mktemp -d)
  trap 'rm -rf -- "$offline"' EXIT
  chmod 755 "$offline"

  mkdir -p "$offline/sources" "$offline/lists/partial"
  touch "$offline/empty.list"

  apt-get -y --no-install-recommends \
    -o Dir::Etc::sourcelist="$offline/empty.list" \
    -o Dir::Etc::sourceparts="$offline/sources" \
    -o Dir::State::lists="$offline/lists" \
    install "${packages[@]}"
fi
dpkg --configure -a
mono --version
mcs --version
[[ -f /usr/lib/mono/4.7.2-api/mscorlib.dll ]]
