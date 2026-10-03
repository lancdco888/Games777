$ErrorActionPreference = 'Stop'
$pf86 = ${env:ProgramFiles(x86)}
$names = @(
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
    "$pf86\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "$pf86\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
)
$browser = $names | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $browser) {
    Write-Host "No Edge or Chrome found."
    exit 1
}
Write-Host "browser: $browser"

$dirs = @(
    "$env:USERPROFILE\.CocosCreator\profiles\v2\editor\packages",
    "$env:USERPROFILE\.CocosCreator\profiles\v2\packages"
)
foreach ($dir in $dirs) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
$files = New-Object System.Collections.Generic.List[string]
Get-ChildItem "$env:USERPROFILE\.CocosCreator" -Recurse -Filter program.json -ErrorAction SilentlyContinue | ForEach-Object { $files.Add($_.FullName) }
foreach ($dir in $dirs) {
    $path = Join-Path $dir "program.json"
    if (-not $files.Contains($path)) { $files.Add($path) }
}

$utf8 = New-Object System.Text.UTF8Encoding $false
foreach ($path in $files) {
    $json = @{ browser = $browser }
    if (Test-Path $path) {
        try {
            $existing = Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json
            $existing | Add-Member -NotePropertyName browser -NotePropertyValue $browser -Force
            $json = $existing
        } catch {
            $json = @{ browser = $browser }
        }
    }
    [System.IO.File]::WriteAllText($path, ($json | ConvertTo-Json -Depth 6), $utf8)
    Write-Host "updated $path"
}

Write-Host "Open http://127.0.0.1:7456 after pressing Play in Creator."
Start-Process -FilePath $browser -ArgumentList "http://127.0.0.1:7456"
