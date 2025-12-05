# desastres_recovery_pc
La lección más valiosa que he aprendido en estos 20 años es la filosofía de "Infraestructura Inmutable" aplicada a tu propia estación de trabajo. Tu computadora debe ser "ganado, no mascota" (Cattle, not pets). Si tu laptop explota hoy, deberías poder estar operativo en otra máquina en menos de 1 hora.

El error común es mezclar código fuente (que va en Git), documentación binaria (Word/PDF que no se llevan bien con Git) y configuraciones del sistema (tus scripts).

Aquí tienes mi propuesta de estructura y estrategia "A prueba de desastres".

1. La Estructura de Carpetas (La "Zona de Trabajo")
Recomiendo crear una carpeta raíz en la unidad principal (por ejemplo, C:\Dev o D:\Dev) para mantener las rutas cortas (Windows tiene límites de 260 caracteres que a veces rompen npm o compilaciones profundas).

Esta es la estructura ideal:

C:\Dev\
│
├── 00_Inbox\           <- "Cajón de sastre". Descargas temporales, JSONs rápidos, pruebas. Se borra cada viernes.
│
├── 01_Repositories\    <- SOLO código fuente clonado. NADA más.
│   ├── ClientA\
│   ├── Personal\
│   └── CompanyName\
│
├── 02_Toolkit\         <- Tus scripts Batch, PowerShell, Python, utilidades portables.
│   ├── bat\
│   ├── ps1\
│   └── bin\
│
└── 03_KnowledgeBase\   <- Tu documentación.
    ├── Proyectos_Specs\ (Archivos Word, Excel, PDFs)
    ├── Notas_Tecnicas\  (Markdown, Obsidian, txt)
    └── Cheatsheets\

    2. La Estrategia de Sincronización (El "Cómo")
Aquí es donde está la magia. No todas las carpetas se respaldan igual.

A. Para 01_Repositories (Git es Rey)
No uses Google Drive, OneDrive o Dropbox aquí.

Por qué: Estas nubes intentan sincronizar carpetas como node_modules, .git o bin/obj. Eso son miles de archivos pequeños que bloquean el proceso, corrompen tus repositorios y ralentizan tu PC.

Solución: Confía en el repositorio remoto (GitHub/GitLab/Azure DevOps). Tu hábito debe ser: Si no está en origin, no existe. Al terminar el día, siempre haz push, aunque sea a una rama de wip (work in progress).

B. Para 02_Toolkit (Tu navaja suiza)
Tus scripts son código. Trátalos como tal.

Solución: Crea un repositorio privado en GitHub llamado dotfiles o my-toolkit.

Clona este repo en C:\Dev\02_Toolkit.

Ventaja: Si cambias de PC, solo haces git clone y ejecutas un script de inicialización que agregue esas carpetas a tu PATH de Windows. Así tus comandos personalizados funcionan al instante en la terminal.

C. Para 03_KnowledgeBase (La Nube)
Aquí es donde van tus archivos Word y documentación.

Solución: Mueve esta carpeta dentro de tu servicio de nube favorito (OneDrive, Google Drive, Dropbox) y crea un "Symlink" (Acceso directo simbólico) o simplemente úsala desde allí.

Recomendación Senior: Si usas Markdown (.md), te sugiero usar Git también para esto (o una herramienta como Obsidian con su propio sync). Pero si dependes de Word/Excel, OneDrive es la mejor opción en Windows.

3. El Plan de Recuperación (Disaster Recovery)
Para que esto funcione, necesitas un "Script Maestro". En mi repositorio de herramientas (02_Toolkit), siempre tengo un archivo llamado setup-new-pc.ps1.

Cuando me dan una máquina nueva, hago lo siguiente:

Instalo Git.

Clono mi repo my-toolkit.

Ejecuto setup-new-pc.ps1.

¿Qué debe tener ese script? Automatiza la instalación de tus programas usando Winget (el gestor de paquetes de Windows) o Chocolatey.

Ejemplo de tu setup-new-pc.ps1:

PowerShell

# Instalar software esencial automáticamente
winget install --id Microsoft.VisualStudioCode -e
winget install --id Git.Git -e
winget install --id OpenJS.NodeJS -e
winget install --id Docker.DockerDesktop -e

# Configurar Git globalmente
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"

# Crear carpetas base si no existen
New-Item -ItemType Directory -Force -Path "C:\Dev\01_Repositories"
New-Item -ItemType Directory -Force -Path "C:\Dev\03_KnowledgeBase"

Write-Host "¡Listo! Ahora loguéate en OneDrive para bajar tu documentación."
Resumen Visual
Consejos de un viejo lobo de mar:
Deja el Word: Intenta migrar tu documentación técnica a Markdown (.md). Al ser texto plano, se versiona perfecto en Git junto con tu código y no se corrompe como los binarios de Office.

Variables de Entorno: En tu carpeta 02_Toolkit, asegúrate de agregar la ruta a tus variables de entorno (PATH). Así, si tienes un script deploy.bat, podrás escribir deploy en cualquier terminal, en cualquier carpeta, y funcionará.

La Regla de los 15 minutos: Si te toma más de 15 minutos configurar un entorno de desarrollo para un proyecto, te falta automatización (Docker o scripts de setup).


Excelente, con ese stack tecnológico ("Fullstack Microsoft/JS pesado"), tu script de inicialización debe ser robusto. No estamos hablando solo de instalar un editor de texto, sino de configurar motores de base de datos, runtimes, emuladores de nube y contenedores.

Como Senior, sé que la parte más dolorosa de reinstalar Windows es volver a configurar las cargas de trabajo (Workloads) de Visual Studio y las versiones específicas de Node.

Aquí tienes tu setup-new-pc.ps1 diseñado para tu perfil.

Pre-requisitos
Antes de ejecutarlo en una máquina virgen, abre PowerShell como Administrador y ejecuta: Set-ExecutionPolicy RemoteSigned -Scope CurrentUser (Para permitir scripts locales).

Detalles "Senior" que marcan la diferencia
1. El problema de Visual Studio (La "Configuración .vsconfig")
El script instala el bootstrapper de Visual Studio, pero no instala las cargas de trabajo (ASP.NET, Azure Development, Node tools, etc.) porque pesan gigas.

Solución Senior:

En tu máquina actual (si alguna funciona) o cuando configures la nueva perfectamente, abre VS Installer.

Ve a "Más" -> Exportar configuración.

Esto genera un archivo .vsconfig.

Guarda ese archivo en tu carpeta 02_Toolkit.

En el futuro, cuando instales VS 2022, en el instalador solo le das a "Importar configuración", seleccionas ese archivo y él marcará todos los checkboxes correctos automáticamente. Esto ahorra horas de configuración manual.

2. NVM vs Node Directo
He puesto CoreyButler.NVMforWindows. Como trabajas con NestJS, Angular y React, es 100% seguro que te encontrarás proyectos viejos que necesiten Node 16 o 18 y nuevos que requieran Node 20+. Instalar Node directamente es un error de novato; NVM te da el control total.

3. Bases de Datos Locales vs Docker
He incluido Docker Desktop. Mi recomendación: No instales SQL Server Developer Edition ni MongoDB Server directamente en Windows.

Ensucia el registro de Windows.

Se ejecuta siempre en segundo plano consumiendo RAM aunque no programes ese día.

Es difícil de desinstalar.

Mejor práctica: Usa archivos docker-compose.yml en tus proyectos. Si necesitas un SQL Server global, corre un contenedor. Solo he incluido las herramientas de administración (Azure Data Studio y Compass) para que te conectes a esos contenedores o a Azure.

4. Extensiones de VS Code
Para completar la automatización, crea un archivo .bat o .ps1 adicional en tu toolkit llamado install-vscode-extensions.ps1:

PowerShell

# Ejemplo de recuperación de extensiones
code --install-extension ms-dotnettools.csdevkit
code --install-extension angular.ng-template
code --install-extension esbenp.prettier-vscode
code --install-extension eamodio.gitlens
# ... lista todas las que uses
Puedes obtener tu lista actual ejecutando code --list-extensions en tu terminal.

¿Te gustaría que te genere un ejemplo de un docker-compose.yml base para levantar SQL Server y Mongo localmente sin tener que instalarlos en el sistema operativo? Es la forma más limpia de trabajar hoy en día.

En la carpeta 01_Repositories, los archivos que no subes al repositorio remoto suelen ser de dos tipos:

Archivos grandes/binarios que has ignorado intencionalmente (.gitignore).

Archivos de configuración local (ej: credenciales, settings de ambiente de desarrollo, bases de datos locales incrustadas, o configuraciones específicas de tu IDE) que no deben ir al código fuente.

Dado que tu objetivo es la recuperación total (setup-new-pc-interactive.ps1), aquí tienes dos estrategias senior para gestionar esa información de forma segura y portable:

1. Archivos de Configuración Local y Credenciales
Esta es la forma más limpia para manejar secrets, variables de entorno locales o archivos de settings de IDE que deben estar cerca del proyecto pero fuera de Git.

A. La Estrategia del "Secrets Repo" (Recomendada)
En lugar de mezclar estos archivos con tu código, crea un repositorio Git privado y cifrado que solo contenga los archivos de configuración.

Crea el Repo: Crea un nuevo repositorio privado y cifrado (puedes usar herramientas como git-crypt o simplemente un archivo ZIP cifrado). Yo lo llamo 02_Toolkit/01_Secrets.git.

Estructura del Repo de Secrets:

Dentro de 01_Secrets, crea una carpeta por proyecto (ej: ClientA-Backend).

Dentro de esa carpeta, guarda los archivos críticos: appsettings.Development.json, .env.local, o docker-compose.override.yml.

Integración en setup-new-pc-interactive.ps1:

Añade una sección al script para clonar este repositorio en tu C:\Dev\02_Toolkit.

Incluye una función manual o automatizada (si usas git-crypt) para descifrarlo en el momento de la configuración inicial.

Uso diario: Cuando clones un proyecto en 01_Repositories, solo tienes que copiar el archivo de configuración necesario de 02_Toolkit/01_Secrets/ProyectoX a la carpeta raíz del nuevo proyecto.

Beneficio: Separas código (en 01_Repositories) de configuración sensible (en 02_Toolkit), mejorando la seguridad y portabilidad.

2. Archivos Binarios, Bases de Datos o Cachés Grandes
Si son archivos grandes que no quieres subir a Git pero necesitas preservar (ej: copias de bases de datos de prueba, archivos de clientes de gran tamaño, o assemblies específicos).

B. La Estrategia del "Backup de Nube por Exclusión"
Utiliza tu servicio de almacenamiento en la nube (OneDrive, Google Drive, etc.) para sincronizar una carpeta específica de la estructura.

Crea la Carpeta de Sincronización:

Crea una carpeta llamada 01_Repositories_Sync dentro de tu servicio de nube (ej: C:\Users\User\OneDrive\Dev\01_Repositories_Sync).

Manejo de Proyectos:

Repositorio Principal: Clona el código fuente en C:\Dev\01_Repositories\ProyectoX.

Archivos Locales Grandes: Mueve los archivos locales necesarios (los que antes ignorabas) a una carpeta especial, por ejemplo: C:\Dev\01_Repositories_Sync\ProyectoX_Assets.

Recuperación:

Cuando ejecutes setup-new-pc-interactive.ps1, solo tienes que asegurarte de que tu nube sincronice la carpeta 01_Repositories_Sync.

Recomendación Senior: Git LFS
Si estos archivos grandes son esenciales para el build del proyecto y no son sensibles, pero son demasiado grandes para Git, la solución profesional es Git LFS (Large File Storage).

Cómo funciona: Git LFS reemplaza los archivos grandes del repo con punteros de texto pequeños. Los archivos reales se almacenan en un servidor de LFS (que es un servicio adicional de GitHub/Azure DevOps).

Ventaja: Mantienes la lógica del proyecto dentro del repo. Al clonar, Git LFS descarga automáticamente el archivo grande en la carpeta local, haciendo que tu carpeta 01_Repositories sea completamente autosuficiente y portable.

Tu script setup-new-pc-interactive.ps1 debe incluir un paso para clonar o montar el repositorio de Secrets/Assets desde 02_Toolkit antes de que empieces a trabajar en 01_Repositories.

Esa es la fase más importante: garantizar que el corazón de tu trabajo esté seguro en la nube.

Asumo que ya tienes Git instalado (gracias a tu setup-new-pc-interactive.ps1) y que tienes una cuenta en GitHub.

Aquí tienes los pasos detallados para tomar un proyecto que ya moviste a C:\Dev\01_Repositories y subirlo a tu GitHub personal.

🛠️ Pasos para Subir Repositorios Existentes a GitHub
Hay dos escenarios: 1) El proyecto ya tiene Git localmente (.git existe) o 2) es un código nuevo sin control de versiones.

Escenario A: Proyecto Local YA es un Repositorio Git
Utilizaremos el proyecto de ejemplo MiProyectoWeb ubicado en C:\Dev\01_Repositories\Personal\MiProyectoWeb.

Paso 1: Crear el Repositorio Vacío en GitHub
Abre tu navegador y ve a GitHub
.

Inicia sesión y haz clic en el botón verde "New" (Nuevo).

Owner: Tu usuario personal.

Repository name: MiProyectoWeb.

Description: (Opcional) Una breve descripción.

Visibility: Private (Privado) o Public (Público), según tu preferencia.

IMPORTANTE: No marques las opciones para añadir README, .gitignore o licencia. Queremos un repositorio completamente vacío para no causar conflictos con tu código local.

Haz clic en "Create repository" (Crear repositorio).

Paso 2: Obtener la URL Remota
Una vez creado, GitHub te mostrará una página con varias instrucciones.

Copia la URL, asegurándote de seleccionar el protocolo HTTPS (ej: https://github.com/tu-usuario/MiProyectoWeb.git).

Paso 3: Vincular el Repositorio Local con el Remoto
Abre PowerShell o la Terminal y navega hasta la carpeta de tu proyecto local:

PowerShell

cd C:\Dev\01_Repositories\Personal\MiProyectoWeb
Verificar el estado local: Asegúrate de que no tienes cambios pendientes:

Bash

git status
Vincular el remoto: Usa la URL que copiaste en el Paso 2 para decirle a Git dónde debe enviar el código. Usamos origin por convención.

Bash

# Reemplaza la URL con la que copiaste de GitHub
git remote add origin https://github.com/tu-usuario/MiProyectoWeb.git
Confirmar la vinculación:

Bash

git remote -v
(Deberías ver la URL de GitHub listada como origin).

Paso 4: Subir el Código (Push Inicial)
Envía tu rama principal (que probablemente se llama main o master) al nuevo repositorio remoto, estableciendo la rama de seguimiento (-u).

Bash

# Si tu rama principal se llama 'main'
git push -u origin main
# O si se llama 'master'
# git push -u origin master 
Nota: Si te pide credenciales (usuario/contraseña o PAT), ingrésalas.

Refresca la página de GitHub. ¡Tu código ya debería estar allí!

Escenario B: Proyecto Local NUEVO sin Control de Versiones
Si moviste una carpeta que solo contiene código, pero que nunca tuvo control de versiones (no tiene la carpeta .git):

Paso 1 y 2: (Igual que arriba)
Crea el repositorio vacío en GitHub y obtén la URL (HTTPS).

Paso 3: Inicializar Git Localmente
Navega hasta la carpeta de tu proyecto local (ej: C:\Dev\01_Repositories\Personal\NuevoProyecto).

PowerShell

cd C:\Dev\01_Repositories\Personal\NuevoProyecto
Inicializa el repositorio:

Bash

git init
Crear el .gitignore: (Opcional, pero muy recomendado)

Crea un archivo llamado .gitignore y añade las carpetas que nunca deben subir (ej: node_modules/, bin/, obj/, temp/). Esto es esencial.

Realizar el primer commit:

Bash

git add .
git commit -m "feat: Initial commit and project setup"
Paso 4: Vincular y Subir
Cambia el nombre de tu rama principal (si Git la creó como master y GitHub espera main):

Bash

git branch -M main
Vincular el remoto:

Bash

git remote add origin https://github.com/tu-usuario/NuevoProyecto.git
Subir el código:

Bash

git push -u origin main
Resumen de la clave
La clave de la estructura C:\Dev\01_Repositories es que, una vez que el proyecto está dentro, las operaciones de Git (como clonar, añadir remotos y pushear) se vuelven un proceso sistemático sin importar el entorno en el que te encuentres.



📝 Adaptación de la Estructura
La estructura propuesta quedaría formalmente así, manteniendo la coherencia y jerarquía:
C:\Dev\
...
├── 01_Repositories\        <- Contenedor principal de Código.
│   │
│   ├── ClientA\            <- Raíz del Cliente.
│   │   ├── Backend\        <- Repositorio/Proyecto del API (.NET/NestJS).
│   │   └── Frontend\       <- Repositorio/Proyecto de la UI (Angular/React).
│   │
│   ├── ClientB\            
│   │   ├── Backend\
│   │   └── Frontend\
│   │
│   ├── Personal\           <- Para tus proyectos propios o de entrenamiento.
│   │   ├── MySideProject_API\
│   │   └── MySideProject_UI\
│   │
│   └── CompanyName\        <- Para proyectos de tu empleador.
...

✅ Impacto de esta Adaptación
En la Migración (Fase 2):

Cuando migres tus proyectos existentes (usando el Move-Item de PowerShell), simplemente asegúrate de crear las subcarpetas Backend y Frontend en el destino antes de mover el contenido del repositorio.

Ejemplo de Tarea de Terminal:

PowerShell

# 1. Crear la estructura
New-Item -ItemType Directory -Force -Path "C:\Dev\01_Repositories\ClientA\Backend"
# 2. Mover el proyecto
Move-Item -Path "C:\OldProjects\ClientA_NetAPI" -Destination "C:\Dev\01_Repositories\ClientA\Backend\"
En Git (Fase 3):

Cada carpeta (Backend y Frontend) es un repositorio Git independiente. Esto es lo ideal, ya que cada capa debería tener su propio historial, branching strategy y pipeline de CI/CD.

En la Configuración Local (Secrets):

Al usar esta estructura, tu repositorio de secretos (02_Toolkit\01_Secrets) debería reflejar esta separación para claridad. Podrías tener archivos de configuración guardados como:

ClientA/Backend/appsettings.Development.json

ClientA/Frontend/.env.local

Esta adaptación es un estándar de oro para la organización de proyectos fullstack y se integra perfectamente con la filosofía de estructura que hemos definido.

Excelente. La modificación principal se centra en la Sección 1 de la creación de la estructura, ya que esta nueva jerarquía es dinámica (depende de los nombres de tus clientes).

El cambio clave es que, en lugar de crear solo 01_Repositories, ahora preguntaremos interactivamente qué clientes manejas y crearemos automáticamente las subcarpetas anidadas Backend y Frontend para cada uno.

Aquí tienes la modificación del script setup-new-pc-interactive.ps1:

💾 Cambios en el Script setup-new-pc-interactive.ps1
El cambio se realiza exclusivamente en la Sección 1. El resto del script (instalación de herramientas, gestión de secretos) permanece igual.

1. Sección 1 (Creación de Estructura) — MODIFICADA
Reemplaza la lógica anterior de la Sección 1 con la siguiente:

PowerShell

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
🔑 Consideraciones Adicionales (Sección 7 y Migración)
Aunque la Sección 7 (Gestión de Secretos) no requiere cambios de código, esta nueva estructura tiene una implicación directa en cómo organizas tus secretos:

Estructura de Secretos Espejo: Tu repositorio de secretos (C:\Dev\02_Toolkit\01_Secrets) ahora debería tener una estructura que refleje la de 01_Repositories.

Ejemplo de Estructura del Repositorio de Secretos:

Plaintext

01_Secrets\
├── ClientA\
│   ├── Backend\
│   │   └── appsettings.Development.json
│   └── Frontend\
│       └── .env.local
├── ClientB\
└── Personal\
Al clonar un proyecto de código fuente (ej: ClientA/Backend), simplemente tendrás que copiar los archivos de configuración desde 02_Toolkit\01_Secrets\ClientA\Backend a la raíz de tu proyecto recién clonado. Esto mantiene el principio de la separación de código y configuración de manera muy limpia.
