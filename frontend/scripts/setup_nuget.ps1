Param(
    [string]$PathToInstall = 'C:\tools\nuget'
)

Write-Host "==> Ensuring directory $PathToInstall" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $PathToInstall | Out-Null

$nugetExe = Join-Path $PathToInstall 'nuget.exe'
if(Test-Path $nugetExe){
  Write-Host "nuget.exe already exists at $nugetExe" -ForegroundColor Yellow
} else {
  Write-Host "Downloading latest nuget.exe..." -ForegroundColor Cyan
  Invoke-WebRequest -Uri https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile $nugetExe
  Write-Host "Downloaded nuget.exe" -ForegroundColor Green
}

# Add to PATH for current session
if(-not ($env:PATH -split ';' | Where-Object { $_ -eq $PathToInstall })){
  $env:PATH += ";$PathToInstall"
}

# Persist (user PATH)
Write-Host "Adding to user PATH (setx)" -ForegroundColor Cyan
setx PATH "$($env:PATH)" | Out-Null

Write-Host "Verification:"
where.exe nuget

Write-Host "Done. Open a NEW PowerShell and run: flutter build windows" -ForegroundColor Green
