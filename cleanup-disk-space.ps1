Write-Host "Iniciando limpieza masiva en C:\Dev\01_Repositories..." -ForegroundColor Yellow

# Limpieza de dependencias JS (node_modules)
Get-ChildItem -Path "C:\Dev\01_Repositories" -Filter "node_modules" -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Eliminando $($_.FullName)..." -ForegroundColor DarkYellow
    Remove-Item -Path $_.FullName -Recurse -Force
}

# Limpieza de builds .NET (bin y obj)
Get-ChildItem -Path "C:\Dev\01_Repositories" -Include bin,obj -Directory -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Eliminando $($_.FullName)..." -ForegroundColor DarkCyan
    Remove-Item -Path $_.FullName -Recurse -Force
}

Write-Host "`nLimpieza de dependencias finalizada. Se liberó espacio." -ForegroundColor Green
