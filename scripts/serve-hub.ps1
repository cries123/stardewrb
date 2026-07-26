# Start Rojo for the Hub place (default.project.json). Requires Rojo 7.7.0.
param(
	[string]$RojoExe = "C:\rojo\rojo.exe"
)

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent

if (-not (Test-Path $RojoExe)) {
	$cmd = Get-Command rojo -ErrorAction SilentlyContinue
	if ($cmd) { $RojoExe = $cmd.Source } else { throw "Rojo not found. Set -RojoExe or install via aftman." }
}

Write-Host "Serving Hub with $RojoExe" -ForegroundColor Cyan
& $RojoExe --version
Set-Location $root
& $RojoExe serve default.project.json
