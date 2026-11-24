$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if (Test-Path bundle) { throw 'Move/delete existing bundle before rebuilding' }
$mount = "${PSScriptRoot}:/kit"
docker run --rm --platform linux/amd64 -v $mount debian:13-slim bash /kit/download-in-debian.sh
if ($LASTEXITCODE -ne 0) { throw 'Download failed' }
docker run --rm --network none --platform linux/amd64 -v $mount debian:13-slim bash -c 'set -o pipefail; (bash /kit/bundle/setup.sh && bash /kit/bundle/test.sh) 2>&1 | tee /kit/bundle/VALIDATION.log'
if ($LASTEXITCODE -ne 0) { throw 'Offline test failed' }
Compress-Archive -Path 'bundle/*' -DestinationPath 'Mono_Full_Offline_NET472.zip' -Force
Write-Host 'Created Mono_Full_Offline_NET472.zip'
