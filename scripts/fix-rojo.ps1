# Fixes the Rojo "protocolVersion" error when using Rojo 7.7.0 on Windows.
#
# Rojo 7.7 uses protocol v5 (websockets). The Creator Store "Rojo Managed Plugin"
# (user_RojoManagedPlugin.rbxm) is still 7.6.x — it must be DISABLED. Use only the
# plugin installed by this script from your 7.7.0 CLI.
#
# Usage (from repo root in PowerShell):
#   .\scripts\fix-rojo.ps1
#   .\scripts\fix-rojo.ps1 -RojoExe "C:\rojo\rojo.exe"

param(
	[string]$RojoExe = ""
)

$ErrorActionPreference = "Stop"
$RequiredVersion = "7.7.0"

function Find-Rojo {
	if ($RojoExe -ne "" -and (Test-Path $RojoExe)) {
		return (Resolve-Path $RojoExe).Path
	}

	$cmd = Get-Command rojo -ErrorAction SilentlyContinue
	if ($cmd) {
		return $cmd.Source
	}

	$fallback = "C:\rojo\rojo.exe"
	if (Test-Path $fallback) {
		return $fallback
	}

	throw "Could not find rojo.exe. Pass -RojoExe C:\path\to\rojo.exe"
}

$rojo = Find-Rojo
Write-Host "Using Rojo: $rojo" -ForegroundColor Cyan
$version = & $rojo --version
Write-Host "Version: $version"

if ($version -notmatch "7\.7\.0") {
	Write-Host ""
	Write-Host "This project expects Rojo $RequiredVersion (see aftman.toml and .rojo-version)." -ForegroundColor Yellow
	Write-Host "Download: https://github.com/rojo-rbx/rojo/releases/tag/v7.7.0" -ForegroundColor Yellow
	Write-Host "Or run:  aftman install" -ForegroundColor Yellow
	Write-Host ""
}

Write-Host "Installing Rojo $RequiredVersion Studio plugin from this CLI..." -ForegroundColor Green
& $rojo plugin install

$pluginDir = Join-Path $env:LOCALAPPDATA "Roblox\Plugins"
Write-Host ""
Write-Host "=== Required steps in Roblox Studio ===" -ForegroundColor Magenta
Write-Host "1. Plugins -> Manage Plugins"
Write-Host "2. DISABLE the Creator Store 'Rojo' / 'Rojo Managed Plugin'"
Write-Host "   (user_RojoManagedPlugin.rbxm — incompatible with 7.7 protocol v5)"
Write-Host "3. Keep ONLY the file plugin Rojo installed to:"
Write-Host "   $pluginDir"
Write-Host "4. Fully quit Studio and reopen"
Write-Host "5. Run:  .\scripts\serve-hub.ps1   (or serve-farm.ps1)"
Write-Host "6. In Studio Rojo panel -> Connect (localhost)"
Write-Host ""
Write-Host "Do NOT use the Roblox Creator Store Rojo plugin with CLI 7.7." -ForegroundColor Cyan
