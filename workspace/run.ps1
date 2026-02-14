# Script PowerShell - Lab 1 Análisis Léxico

function Show-Help {
    Write-Host "Lab 1 - Analizador Léxico con Flex" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Uso: .\run.ps1 [comando]"
    Write-Host ""
    Write-Host "Comandos:"
    Write-Host "  compile      - Compilar el lexer"
    Write-Host "  test-java    - Ejecutar prueba con test_java.java"
    Write-Host "  test-c       - Ejecutar prueba con test_c.c"
    Write-Host "  test-all     - Ejecutar todas las pruebas"
    Write-Host "  clean        - Limpiar archivos generados"
    Write-Host "  docker-run   - Ejecutar en Docker"
    Write-Host "  help         - Mostrar esta ayuda"
}

function Compile-Lexer {
    if (-not (Get-Command flex -ErrorAction SilentlyContinue)) {
        Write-Host "Error: Flex no instalado. Usa 'docker-run'" -ForegroundColor Red
        return $false
    }
    
    flex java_lexer.l
    if ($LASTEXITCODE -ne 0) { return $false }
    
    gcc lex.yy.c -o java_lexer.exe -lfl
    if ($LASTEXITCODE -ne 0) { return $false }
    
    Write-Host "Lexer compilado exitosamente" -ForegroundColor Green
    return $true
}

function Test-Java {
    if (-not (Test-Path "java_lexer.exe")) {
        Write-Host "Error: Ejecuta 'compile' primero" -ForegroundColor Red
        return
    }
    .\java_lexer.exe test_java.java
}

function Test-C {
    if (-not (Test-Path "java_lexer.exe")) {
        Write-Host "Error: Ejecuta 'compile' primero" -ForegroundColor Red
        return
    }
    .\java_lexer.exe test_c.c
}

function Clean-Files {
    if (Test-Path "lex.yy.c") { Remove-Item "lex.yy.c" }
    if (Test-Path "java_lexer.exe") { Remove-Item "java_lexer.exe" }
    Write-Host "Archivos limpiados" -ForegroundColor Green
}

function Docker-Run {
    Push-Location ..
    docker-compose up -d
    docker exec -it flex_container bash
    Pop-Location
}

param([string]$Command = "help")

switch ($Command.ToLower()) {
    "compile" { Compile-Lexer }
    "test-java" { Test-Java }
    "test-c" { Test-C }
    "test-all" { Test-Java; Test-C }
    "clean" { Clean-Files }
    "docker-run" { Docker-Run }
    "help" { Show-Help }
    default { 
        Write-Host "Comando desconocido: $Command" -ForegroundColor Red
        Show-Help 
    }
}
