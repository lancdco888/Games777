# 仅在电脑没有 Python 3.9+ 时，由 download-h215.bat 调用。
# 把官方免安装 Python 解压到脚本旁边的 .pyruntime，不改系统环境变量。
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$dest = Join-Path $PSScriptRoot ".pyruntime"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
$arch = $env:PROCESSOR_ARCHITECTURE
$tag = "embed-amd64"
if ($arch -eq "x86") { $tag = "embed-win32" }
$url = "https://www.python.org/ftp/python/3.12.8/python-3.12.8-$tag.zip"
$zip = Join-Path $dest "python-embed.zip"
Write-Host "下载 $url"
Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing
Expand-Archive -Path $zip -DestinationPath $dest -Force
Remove-Item $zip
$python = Join-Path $dest "python.exe"
if (-not (Test-Path $python)) {
    throw "python.exe was not extracted"
}
Write-Host "Python 已放在 $python"
