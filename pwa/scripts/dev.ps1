param(
  [string]$NodeDir = "C:\Users\kgeorgiev\Downloads\node-v22.20.0-win-x64",
  [ValidateSet('dev','preview','build')]
  [string]$Mode = 'dev',
  [switch]$Expose
)

$ErrorActionPreference = 'Stop'

function Join($a,$b){ return [System.IO.Path]::Combine($a,$b) }

function Find-NodeExe([string]$root){
  $candidate = Join $root 'node.exe'
  if (Test-Path $candidate) { return $candidate }
  $hit = Get-ChildItem -Path $root -Filter 'node.exe' -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($hit) { return $hit.FullName }
  return $null
}

$NODE = Find-NodeExe -root $NodeDir
if (-not $NODE) { Write-Error "node.exe not found under $NodeDir" }
$NodeBase = Split-Path -Parent $NODE
$NPM  = Join $NodeBase 'node_modules/npm/bin/npm-cli.js'
if (-not (Test-Path $NPM))  { Write-Error "npm-cli.js not found next to node.exe (expected: $NPM)" }

# Prepend portable Node folder to PATH so child scripts can call 'node'
$env:Path = "$NodeBase;$env:Path"

# Ensure we are in pwa root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PwaRoot = Split-Path -Parent $ScriptDir
Set-Location $PwaRoot

# Optional: local npm cache to avoid OneDrive/policy issues
& $NODE $NPM config set cache (Join-Path (Get-Location) '.npm-cache') --location=project | Out-Null

# Install deps if needed (node_modules missing or vite binary not present)
$viteBin = Join-Path (Get-Location) 'node_modules/.bin/vite.cmd'
$needInstall = $false
if (-not (Test-Path 'node_modules')) { $needInstall = $true }
if (-not (Test-Path $viteBin)) { $needInstall = $true }
if ($needInstall) {
  Write-Host 'Installing dependencies...'
  & $NODE $NPM install --no-audit --no-fund
}

switch ($Mode) {
  'dev'     { $argsList = @('run','dev') }
  'preview' { $argsList = @('run','preview') }
  'build'   { $argsList = @('run','build') }
}
if ($Expose) { $argsList += '--'; $argsList += '--host' }

Write-Host "Starting: npm $($argsList -join ' ')"
& $NODE $NPM @argsList
