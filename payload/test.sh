#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p out
framework=/usr/lib/mono/4.7.2-api
refs=(mscorlib System System.Core System.Numerics System.Numerics.Vectors System.Xml System.Xml.Linq System.Data System.Data.DataSetExtensions Microsoft.CSharp System.Deployment System.Drawing System.Net.Http System.Windows.Forms System.IO.Compression System.IO.Compression.FileSystem)
mcsrefs=(); cscrefs=()
for ref in "${refs[@]}"; do
  [[ -f "$framework/$ref.dll" ]] || { echo "MISSING $ref.dll"; exit 1; }
  if [[ "$ref" != mscorlib ]]; then mcsrefs+=("-r:$framework/$ref.dll"); fi
  cscrefs+=("-r:$framework/$ref.dll")
done
mcs -sdk:4.7.2 -out:out/Hello.exe Hello.cs
mono out/Hello.exe
mcs -sdk:4.7.2 -langversion:7.2 "${mcsrefs[@]}" -out:out/FrameworkProbe.exe FrameworkProbe.cs
xvfb-run -a mono out/FrameworkProbe.exe
xbuild /version
csc="$PWD/roslyn/tasks/net472/csc.exe"
mono "$csc" -version
mono "$csc" -noconfig -nostdlib+ -langversion:7.3 -unsafe+ "${cscrefs[@]}" -out:out/CSharp73.exe CSharp73.cs
mono out/CSharp73.exe
mono "$csc" -noconfig -nostdlib+ -langversion:7.3 "${cscrefs[@]}" -out:out/FrameworkProbeRoslyn.exe FrameworkProbe.cs
xvfb-run -a mono out/FrameworkProbeRoslyn.exe
echo 'ALL OFFLINE TESTS PASS'
