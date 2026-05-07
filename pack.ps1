<#
.SYNOPSIS
    Prépare les artefacts de release pour WuwaPieRelease.

.DESCRIPTION
    1. Publie WuwaPie et WuwaPieLauncher en Release
    2. Copie WuwaDatabase.db depuis WuwaHub
    3. Crée les zips prêts à uploader sur GitHub Releases

.PARAMETER AppVersion
    Version de WuwaPie  (ex: "2.1.0")

.PARAMETER LauncherVersion
    Version du Launcher (ex: "1.2.0")

.PARAMETER DbVersion
    Version de la DB    (ex: "20260507")

.EXAMPLE
    .\pack.ps1 -AppVersion 2.1.0 -LauncherVersion 1.2.0 -DbVersion 20260507
#>

param(
    [Parameter(Mandatory)] [string] $AppVersion,
    [Parameter(Mandatory)] [string] $LauncherVersion,
    [Parameter(Mandatory)] [string] $DbVersion
)

$ErrorActionPreference = "Stop"
$root     = Split-Path $PSScriptRoot -Parent
$out      = $PSScriptRoot

function Step([string]$msg) { Write-Host "`n== $msg ==" -ForegroundColor Cyan }
function Ok([string]$msg)   { Write-Host "  ✓ $msg"   -ForegroundColor Green }
function Warn([string]$msg) { Write-Host "  ! $msg"   -ForegroundColor Yellow }

# ── 1. Publier WuwaPieLauncher ──────────────────────────────────────────────
Step "Publication WuwaPieLauncher v$LauncherVersion"
$launcherSrc = "$root\WuwaPieLauncher\build\WuwaPieLauncher"
dotnet publish "$root\WuwaPieLauncher\WuwaPieLauncher.csproj" `
    -f net10.0-windows10.0.19041.0 -c Release | Out-Null
Ok "Publié dans $launcherSrc"

# ── 2. Publier WuwaPie ──────────────────────────────────────────────────────
Step "Publication WuwaPie v$AppVersion"
$appSrc = "$root\WuwaPie\build\WuwaPie"
dotnet publish "$root\WuwaPie\WuwaPie.csproj" `
    -f net10.0-windows10.0.19041.0 -c Release | Out-Null
Ok "Publié dans $appSrc"

# ── 3. Copier WuwaDatabase.db ───────────────────────────────────────────────
Step "Copie WuwaDatabase.db"
$dbSrc = "$root\WuwaHub\WuwaDatabase.db"
if (-not (Test-Path $dbSrc)) { throw "WuwaDatabase.db introuvable : $dbSrc" }
Copy-Item $dbSrc "$out\WuwaDatabase.db" -Force
Ok "DB copiée"

# ── 4. Créer les zips ───────────────────────────────────────────────────────
Step "Création des archives"

$zipApp      = "$out\WuwaPie-$AppVersion.zip"
$zipLauncher = "$out\WuwaPieLauncher-$LauncherVersion.zip"
$zipDb       = "$out\WuwaDatabase-$DbVersion.zip"

if (-not (Test-Path $appSrc))      { Warn "WuwaPie build introuvable — zip ignoré" }
else {
    if (Test-Path $zipApp) { Remove-Item $zipApp }
    Compress-Archive -Path "$appSrc\*" -DestinationPath $zipApp
    Ok "→ $zipApp"
}

if (-not (Test-Path $launcherSrc)) { Warn "WuwaPieLauncher build introuvable — zip ignoré" }
else {
    if (Test-Path $zipLauncher) { Remove-Item $zipLauncher }
    Compress-Archive -Path "$launcherSrc\*" -DestinationPath $zipLauncher
    Ok "→ $zipLauncher"
}

if (Test-Path $zipDb) { Remove-Item $zipDb }
Compress-Archive -Path "$out\WuwaDatabase.db" -DestinationPath $zipDb
Ok "→ $zipDb"

# ── 5. Récap ────────────────────────────────────────────────────────────────
Step "Artefacts prêts"
Write-Host @"

  Uploader ces fichiers sur GitHub Releases (gh release create) :
    $zipLauncher   → tag : launcher-v$LauncherVersion
    $zipApp        → tag : wuwapie-v$AppVersion
    $zipDb         → tag : db-$DbVersion

  Puis pousser manifest.json mis à jour :
    git add manifest.json
    git commit -m "manifest: wuwapie $AppVersion / launcher $LauncherVersion / db $DbVersion"
    git push
"@ -ForegroundColor White
