# Fixes the Rojo "protocolVersion" error on Windows.
# Root cause: Studio's auto-installed "Rojo Managed Plugin" (7.6.x) talking to a
# different CLI version (often 7.7.x). Only ONE plugin + ONE CLI version may be active.
#
# Usage (from repo root in PowerShell):
#   .\scripts\fix-rojo.ps1
#   .\scripts\fix-rojo.ps1 -RojoExe "C:\rojo\rojo.exe"

param(
	[string]$RojoExe = ""
)

$ErrorActionPreference = "Stop"

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

if ($version -match "7\.7") {
	Write-Host ""
	Write-Host "WARNING: Rojo 7.7 uses protocol v5 (websockets)." -ForegroundColor Yellow
	Write-Host "The Roblox Managed Plugin is usually still 7.6.x and WILL cause protocolVersion errors." -ForegroundColor Yellow
	Write-Host ""
	Write-Host "Recommended: install Rojo 7.6.1 and use that instead:" -ForegroundColor Yellow
	Write-Host "  https://github.com/rojo-rbx/rojo/releases/tag/v7.6.1" -ForegroundColor Yellow
	Write-Host "  Replace C:\rojo\rojo.exe with the 7.6.1 build, then re-run this script." -ForegroundColor Yellow
	Write-Host ""
}

Write-Host "Installing matching Studio plugin from this CLI..." -ForegroundColor Green
& $rojo plugin install

$pluginDir = Join-Path $env:LOCALAPPDATA "Roblox\Plugins"
Write-Host ""
Write-Host "=== Manual steps in Roblox Studio (required) ===" -ForegroundColor Magenta
Write-Host "1. Plugins -> Manage Plugins"
Write-Host "2. DISABLE or uninstall 'Rojo' / 'Rojo Managed Plugin' from the Creator Store"
Write-Host "   (the one loaded from user_RojoManagedPlugin.rbxm — this is the usual culprit)"
Write-Host "3. Keep ONLY the plugin Rojo just installed to:"
Write-Host "   $pluginDir"
Write-Host "4. Fully quit Studio and reopen"
Write-Host "5. In this folder run:  rojo serve default.project.json"
Write-Host "6. In Studio Rojo panel click Connect (localhost, default port)"
Write-Host ""
Write-Host "If you still see protocolVersion errors, downgrade CLI to 7.6.1 (link above)." -ForegroundColor Yellow
