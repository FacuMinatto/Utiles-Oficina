if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    
    $urlRaw = "https://raw.githubusercontent.com/FacuMinatto/Oficina/main/CodigoV2.ps1"
    
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm $urlRaw | iex`"" -Verb RunAs
    exit
}

function Esperar-Enter {
    Write-Host "`nPresione ENTER para continuar..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Mostrar-Menu {
    Clear-Host
   
    $Host.UI.RawUI.BackgroundColor = "DarkBlue"
    $Host.UI.RawUI.ForegroundColor = "White"
    Clear-Host

    Write-Host "¿Qué herramienta necesitas?`n" -ForegroundColor Cyan
    Write-Host "|1| Activador de Windows - Office"
    Write-Host "|2| Reiniciar ajustes de red"
    Write-Host "|3| Borrar cola de la impresora"
    Write-Host "|4| Escanear el disco en busca de errores"
    Write-Host "|5| Descargar Oracle"
    Write-Host "|6| Modificar el idioma de Oracle"
    Write-Host "|7| Descargar PDF24"
    Write-Host "|0| Salir`n"
}

function Ejecutar-Activador {
    
    irm https://get.activated.win | iex
    Esperar-Enter
}

function Reiniciar-Red {
    Clear-Host
    netsh winsock reset
    netsh int ip reset
    ipconfig /release
    ipconfig /renew
    ipconfig /flushdns
    ipconfig /registerdns
    Esperar-Enter
}

function Limpiar-Impresora {
    Clear-Host
    net stop spooler
    # Write-Host "Buscar en system32 la carpeta spool - printers; Y borras todo." -ForegroundColor Yellow
    
    # Si se comenta la linea de abajo y descomenta las otras 2 lineas, el proceso pasa a ser manual.
    Remove-Item -Path "$env:windir\System32\spool\PRINTERS\*.*" -Force -Recurse
    
    # Esperar-Enter
    net start spooler

    Write-Host "Se limpio la cola de impresión."
    Esperar-Enter
}

function Reparar-Disco {
    Clear-Host
    DISM /online /cleanup-image /checkhealth
    DISM /online /cleanup-image /scanhealth
    DISM /online /Cleanup-Image /RestoreHealth
    sfc /scannow
    Esperar-Enter
}

function Modificar-Oracle {
    $ruta = "HKLM:\SOFTWARE\WOW6432Node\ORACLE\KEY_OraClient11g_home1"
    
    try {
        New-ItemProperty -Path $ruta -Name "NLS_LANG" -Value "AMERICAN_AMERICA.WE8MSWIN1252" -PropertyType String -Force | Out-Null
        Write-Host "[EXITO] El registro fue modificado correctamente." -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Falló el comando. La ruta del registro probablemente no existe." -ForegroundColor Red
    }
    Esperar-Enter
}

function Descargar-Oracle {
    Clear-Host
    Write-Host "¿Qué versión quieres descargar?"
    Write-Host "|1| Oracle 9"
    Write-Host "|2| Oracle 11"
    
    $var = Read-Host "Ingrese opción"
    
    if ($var -eq '1') {
        $url = "https://github.com/FacuMinatto/Oficina/releases/download/Archivos/ORACLE.9.rar"
        $archivo = "Oracle 9.rar"
    }
    elseif ($var -eq '2') {
        $url = "https://github.com/FacuMinatto/Oficina/releases/download/Archivos/ORACLE.11.rar"
        $archivo = "Oracle 11.rar"
    }
    else {
        Write-Host "Opción inválida." -ForegroundColor Red
        Start-Sleep -Seconds 1
        return
    }

    $rutaDestino = "$env:USERPROFILE\Downloads\$archivo"

    Write-Host "Iniciando descarga..."
    
    curl.exe -L -o `"$rutaDestino`" `"$url`"
    
    # Validación del resultado
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n[EXITO] Archivo guardado en Descargas como: $archivo" -ForegroundColor Green
    } else {
        Write-Host "`n[ERROR] Falló la descarga. (Código de error: $LASTEXITCODE)" -ForegroundColor Red
    }
    
    Esperar-Enter
}

function Descargar-PDF24 {
    Clear-Host
    $url = "https://github.com/FacuMinatto/Oficina/releases/download/Archivos/pdf24-creator-11.0.1.msi"
    $archivo = "Pdf24 - 11.0.1.msi"
    
    # Creamos la ruta exacta apuntando a la carpeta Descargas del usuario actual
    $rutaDestino = "$env:USERPROFILE\Downloads\$archivo"

    Write-Host "Iniciando descarga..."
    
    # Le pasamos a curl la ruta de destino completa en lugar de solo el nombre
    curl.exe -L -o `"$rutaDestino`" `"$url`"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n[EXITO] Archivo guardado en Descargas como: $archivo" -ForegroundColor Green
    } else {
        Write-Host "`n[ERROR] Falló la descarga. (Código de error: $LASTEXITCODE)" -ForegroundColor Red
    }
    
    Esperar-Enter
}

$ejecutando = $true

while ($ejecutando) {
    Mostrar-Menu
    $opcion = Read-Host "Ingrese un número"
    
    switch ($opcion) {
        '1' { Ejecutar-Activador }
        '2' { Reiniciar-Red }
        '3' { Limpiar-Impresora }
        '4' { Reparar-Disco }
        '5' { Descargar-Oracle }
        '6' { Modificar-Oracle }
        '7' { Descargar-PDF24 }
        '0' { $ejecutando = $false }
        default { 
            Write-Host "Opción inválida." -ForegroundColor Red
            Start-Sleep -Seconds 1 
        }
    }
}

$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "White"
Clear-Host
Write-Host "Saliendo del sistema..." -ForegroundColor Cyan
