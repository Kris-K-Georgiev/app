# Clear cache and start dev server
Write-Host "🧹 Изчистване на кеш..." -ForegroundColor Cyan

# Add Node to PATH
$env:PATH = "C:\Users\kgeorgiev\Downloads\node-v22.20.0-win-x64\node-v22.20.0-win-x64;$env:PATH"

# Navigate to pwa directory
Set-Location -Path $PSScriptRoot

# Clear Vite cache
if (Test-Path "node_modules\.vite") {
    Remove-Item -Recurse -Force "node_modules\.vite"
    Write-Host "✓ Vite кеш изчистен" -ForegroundColor Green
}

# Clear browser cache hint
Write-Host ""
Write-Host "💡 За да изчистите браузър кеша:" -ForegroundColor Yellow
Write-Host "   - Chrome/Edge: Ctrl+Shift+Del или F12 > Network > Disable cache" -ForegroundColor Gray
Write-Host "   - Firefox: Ctrl+Shift+Del" -ForegroundColor Gray
Write-Host ""

# Start dev server
Write-Host "🚀 Стартиране на dev сървър..." -ForegroundColor Cyan
npm.cmd run dev
