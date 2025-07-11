@echo off
:: ISPAA OS Development Script for Windows
:: Copyright (C) 2025 ISPAA Technologies

setlocal enabledelayedexpansion

echo ==================================================
echo    ISPAA OS v2.0 - Development Environment
echo    The Future is Here!
echo ==================================================
echo.

if "%1"=="" goto :show_help
if "%1"=="help" goto :show_help
if "%1"=="-h" goto :show_help
if "%1"=="--help" goto :show_help

if "%1"=="check" goto :check_deps
if "%1"=="build" goto :build_os
if "%1"=="run" goto :run_qemu
if "%1"=="debug" goto :debug_qemu
if "%1"=="test" goto :test_os
if "%1"=="clean" goto :clean_build
if "%1"=="info" goto :show_info

echo [ERROR] Unknown command: %1
echo.
goto :show_help

:check_deps
echo [INFO] Checking Dependencies...
echo.

set missing_deps=

where nasm >nul 2>&1
if errorlevel 1 set missing_deps=!missing_deps! nasm

where gcc >nul 2>&1
if errorlevel 1 set missing_deps=!missing_deps! gcc

where ld >nul 2>&1
if errorlevel 1 set missing_deps=!missing_deps! binutils

where make >nul 2>&1
if errorlevel 1 set missing_deps=!missing_deps! make

where qemu-system-i386 >nul 2>&1
if errorlevel 1 set missing_deps=!missing_deps! qemu

if "!missing_deps!"=="" (
    echo [INFO] All dependencies are installed!
) else (
    echo [ERROR] Missing dependencies:!missing_deps!
    echo.
    echo Install them with:
    echo   MSYS2/MinGW: pacman -S nasm gcc binutils make qemu
    echo   Chocolatey:  choco install nasm gcc make qemu
    echo   Scoop:       scoop install nasm gcc make qemu
    exit /b 1
)
goto :eof

:build_os
echo [INFO] Building ISPAA OS...
call :check_deps
if errorlevel 1 exit /b 1
make clean
make all
if errorlevel 1 (
    echo [ERROR] Build failed!
    exit /b 1
)
echo [INFO] Build completed successfully!
goto :eof

:run_qemu
echo [INFO] Starting ISPAA OS in QEMU...
if not exist "ispaa_os.bin" (
    echo [ERROR] OS image not found. Run build first.
    exit /b 1
)
echo [INFO] Launching QEMU emulator...
make run
goto :eof

:debug_qemu
echo [INFO] Starting ISPAA OS in debug mode...
if not exist "ispaa_os.bin" (
    echo [ERROR] OS image not found. Run build first.
    exit /b 1
)
echo [INFO] Launching QEMU with GDB support...
echo [WARN] Connect GDB on port 1234
make run-debug
goto :eof

:test_os
echo [INFO] Testing ISPAA OS...
make test
echo [INFO] Boot test completed!
goto :eof

:clean_build
echo [INFO] Cleaning build files...
make clean
echo [INFO] Clean completed!
goto :eof

:show_info
echo ISPAA OS Project Information
echo.
echo Version: 2.0
echo Architecture: x86-32
echo License: GPL v3
echo Language: C + Assembly
echo.
echo Features:
echo   ✓ Custom bootloader with splash screen
echo   ✓ 32-bit protected mode
echo   ✓ Interactive command shell
echo   ✓ Memory management
echo   ✓ VGA text mode graphics
echo   ✓ A20 line support
echo.
echo Build targets:
make info
goto :eof

:show_help
echo.
echo ISPAA OS Development Script for Windows
echo.
echo Usage: %0 [command] [options]
echo.
echo Commands:
echo   check      - Check build dependencies
echo   build      - Build ISPAA OS
echo   run        - Run OS in QEMU
echo   debug      - Run OS with debugging
echo   test       - Quick boot test
echo   clean      - Clean build files
echo   info       - Show project information
echo   help       - Show this help
echo.
echo Examples:
echo   %0 build       # Build the OS
echo   %0 run         # Run in emulator
echo   %0 test        # Quick test
echo.
echo Note: This script requires MSYS2/MinGW or similar Unix-like
echo       environment on Windows for the build tools.
echo.
goto :eof
