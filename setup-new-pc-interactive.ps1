<#
.SYNOPSIS
    Script de Setup Interactivo para Fullstack Developer (.NET + JS/TS + Azure).
    Modo: Pregunta antes de instalar.
    Autor: Tu Yo del Futuro
#>

$ErrorActionPreference = "Stop"

# --- FUNCIONES AUXILIARES ---

function Write-Header {
    param($text)
    Write-Host "`n========================================================" -ForegroundColor Cyan
    Write-Host $text -ForegroundColor Cyan
    Write-Host "========================================================`n"
}

function Confirm-Installation {
    param(
        [string]$Name,
        [string]$CommandCheck = "" # Comando para verificar si ya existe (ej: "git")
    )

    # Si pasamos un comando para chequear y existe, avisamos
    if ($CommandCheck -ne "" -and (Get-Command $CommandCheck -ErrorAction SilentlyContinue)) {
        Write-Host " [!] $Name parece ya estar instalado (detectado '$CommandCheck')." -ForegroundColor Magenta
    }

    $response = Read-Host " -> ¿Deseas instalar/actualizar $Name? (S/N)"
    if ($response -eq 'S' -or $response -eq 's') {
        return $true
    }
    return $false
}

function Install-WingetPackage {
    param($id, $name)
    Write-Host "Solicitando instalación de $name..." -ForegroundColor Gray
    winget install --id $id -e --source winget --accept-package-agreements --accept-source-agreements
    if ($?) { Write-Host "$name procesado correctamente." -ForegroundColor Green }
}

# --- INICIO DEL SCRIPT ---

Write-Header "1. CREANDO ESTRUCTURA DE CARPETAS (La Zona de Trabajo)"

# Carpetas estáticas (toolkit, docs, etc.)
$staticFolders = @(
    "C:\Dev\00_Inbox",
    "C:\Dev\02_Toolkit",
    "C:\Dev\03_KnowledgeBase",
    "C:\Dev\04_DockerVolumes"
)

foreach ($folder in $staticFolders) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Force -Path $folder | Out-Null
        Write-Host "Creado: $folder" -ForegroundColor Green
    } else {
        Write-Host "Existe: $folder" -ForegroundColor DarkGray
    }
}

# --- Lógica Interactiva para 01_Repositories ---
$baseRepoPath = "C:\Dev\01_Repositories"

if (!(Test-Path $baseRepoPath)) {
    New-Item -ItemType Directory -Force -Path $baseRepoPath | Out-Null
}

Write-Host "`n[REPOSITORIOS] Ingresa los nombres de tus Clientes/Proyectos principales (separados por coma):" -ForegroundColor Yellow
Write-Host "(Ej: ClientA, ClientB, Personal, CompanyName)" -ForegroundColor Gray
$clientInput = Read-Host " -> Nombres de Clientes/Proyectos"

$clientNames = $clientInput -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }

foreach ($client in $clientNames) {
    Write-Host "Procesando cliente/proyecto: $client" -ForegroundColor DarkYellow
    
    # Define la estructura Backend y Frontend
    $clientBackendPath = Join-Path -Path $baseRepoPath -ChildPath "$client\Backend"
    $clientFrontendPath = Join-Path -Path $baseRepoPath -ChildPath "$client\Frontend"

    # Creación
    New-Item -ItemType Directory -Force -Path $clientBackendPath | Out-Null
    New-Item -ItemType Directory -Force -Path $clientFrontendPath | Out-Null
    Write-Host " -> Creada estructura para $client: Backend y Frontend" -ForegroundColor Green
}

Write-Header "2. HERRAMIENTAS BASE"

if (Confirm-Installation "Git" "git") {
    Install-WingetPackage "Git.Git" "Git"
    # Configuración base recomendada
    git config --global core.autocrlf false
    git config --global init.defaultBranch main
}

if (Confirm-Installation "PowerShell 7 & Windows Terminal" "pwsh") {
    Install-WingetPackage "Microsoft.PowerShell" "PowerShell 7 (Core)"
    Install-WingetPackage "Microsoft.WindowsTerminal" "Windows Terminal"
}

Write-Header "3. ENTORNOS DE DESARROLLO (IDEs)"

if (Confirm-Installation "Visual Studio Code" "code") {
    Install-WingetPackage "Microsoft.VisualStudioCode" "VS Code"
}

if (Confirm-Installation "Visual Studio 2022 Professional") {
    Install-WingetPackage "Microsoft.VisualStudio.2022.Professional" "Visual Studio 2022 Pro"
}

Write-Header "4. RUNTIMES"

if (Confirm-Installation "NVM (Node Version Manager)" "nvm") {
    Install-WingetPackage "CoreyButler.NVMforWindows" "NVM for Windows"
}

if (Confirm-Installation ".NET 8 SDK" "dotnet") {
    Install-WingetPackage "Microsoft.DotNet.SDK.8" ".NET 8 SDK"
}

Write-Header "5. INFRAESTRUCTURA & CLOUD"

if (Confirm-Installation "Docker Desktop" "docker") {
    Install-WingetPackage "Docker.DockerDesktop" "Docker Desktop"
}

if (Confirm-Installation "Azure CLI" "az") {
    Install-WingetPackage "Microsoft.AzureCLI" "Azure CLI"
}

Write-Header "6. HERRAMIENTAS DE BASE DE DATOS (CLIENTES)"

if (Confirm-Installation "Azure Data Studio (SQL Client)") {
    Install-WingetPackage "Microsoft.AzureDataStudio" "Azure Data Studio"
}

if (Confirm-Installation "MongoDB Compass (Mongo Client)") {
    Install-WingetPackage "MongoDB.Compass.Full" "MongoDB Compass"
}

# ----------------------------------------------------------------------------------
# NUEVA SECCIÓN: GESTIÓN DE SECRETOS Y CONFIGURACIÓN LOCAL
# ----------------------------------------------------------------------------------
Write-Header "7. GESTIÓN DE CONFIGURACIÓN Y SECRETOS"

if (Confirm-Installation "Repositorio de Configuraciones (01_Secrets)") {
    
    # Solicitamos la URL al usuario
    Write-Host "`nPor favor, ingresa la URL SSH o HTTPS de tu repositorio de Secrets/Configuraciones." -ForegroundColor Yellow
    Write-Host "(Ej: git@github.com:tu_user/mis-secrets.git o https://...)" -ForegroundColor Gray
    $repoUrl = Read-Host " -> URL del Repositorio Secreto"
    
    if ($repoUrl -ne "") {
        $targetPath = "C:\Dev\02_Toolkit\01_Secrets"
        
        Write-Host "Clonando $repoUrl en $targetPath..." -ForegroundColor Yellow
        
        # Clonamos el repositorio
        try {
            # Nos movemos a la carpeta padre para que el clone cree la subcarpeta
            Set-Location C:\Dev\02_Toolkit
            git clone $repoUrl 01_Secrets
            
            if ($?) {
                Write-Host "Repositorio de Secrets clonado exitosamente." -ForegroundColor Green
                Write-Host "Recuerda, si usas SSH, debes tener tu clave configurada." -ForegroundColor Yellow
            } else {
                Write-Host "Error al clonar el repositorio. Verifica la URL y las credenciales/llaves SSH." -ForegroundColor Red
            }
        } catch {
            Write-Host "Ocurrió un error inesperado durante el clonado." -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
    } else {
        Write-Host "URL vacía. Se omitió la clonación del repositorio de Secrets." -ForegroundColor DarkGray
    }
}
# ----------------------------------------------------------------------------------


Write-Host "`n--- PROCESO COMPLETADO ---" -ForegroundColor Cyan
Pause
