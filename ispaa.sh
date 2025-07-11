#!/bin/bash

# ISPAA OS Development Script
# Copyright (C) 2025 ISPAA Technologies

set -e

echo "=================================================="
echo "   ISPAA OS v2.0 - Development Environment"
echo "   The Future is Here!"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${CYAN}$1${NC}"
}

# Check if required tools are installed
check_dependencies() {
    print_header "Checking Dependencies..."
    
    local missing_deps=()
    
    if ! command -v nasm &> /dev/null; then
        missing_deps+=("nasm")
    fi
    
    if ! command -v gcc &> /dev/null; then
        missing_deps+=("gcc")
    fi
    
    if ! command -v ld &> /dev/null; then
        missing_deps+=("binutils")
    fi
    
    if ! command -v make &> /dev/null; then
        missing_deps+=("make")
    fi
    
    if ! command -v qemu-system-i386 &> /dev/null; then
        missing_deps+=("qemu-system-x86")
    fi
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        print_status "All dependencies are installed!"
    else
        print_error "Missing dependencies: ${missing_deps[*]}"
        echo ""
        echo "Install them with:"
        echo "  Ubuntu/Debian: sudo apt install nasm gcc binutils make qemu-system-x86"
        echo "  Fedora/RHEL:   sudo dnf install nasm gcc binutils make qemu-system-x86"
        echo "  Arch Linux:    sudo pacman -S nasm gcc binutils make qemu"
        echo "  macOS:         brew install nasm gcc binutils make qemu"
        exit 1
    fi
}

# Build the OS
build_os() {
    print_header "Building ISPAA OS..."
    make clean
    make all
    print_status "Build completed successfully!"
}

# Run in QEMU
run_qemu() {
    print_header "Starting ISPAA OS in QEMU..."
    if [ -f "ispaa_os.bin" ]; then
        print_status "Launching QEMU emulator..."
        make run
    else
        print_error "OS image not found. Run build first."
        exit 1
    fi
}

# Run with debugging
debug_qemu() {
    print_header "Starting ISPAA OS in debug mode..."
    if [ -f "ispaa_os.bin" ]; then
        print_status "Launching QEMU with GDB support..."
        print_warning "Connect GDB on port 1234"
        make run-debug
    else
        print_error "OS image not found. Run build first."
        exit 1
    fi
}

# Create bootable USB
create_usb() {
    if [ -z "$1" ]; then
        print_error "Usage: $0 usb /dev/sdX"
        exit 1
    fi
    
    local device=$1
    
    print_header "Creating Bootable USB..."
    print_warning "This will DESTROY all data on $device!"
    read -p "Are you absolutely sure? (type 'YES' to continue): " confirm
    
    if [ "$confirm" = "YES" ]; then
        print_status "Writing ISPAA OS to $device..."
        sudo make install DEVICE=$device
        print_status "Bootable USB created successfully!"
    else
        print_status "USB creation cancelled."
    fi
}

# Test the OS
test_os() {
    print_header "Testing ISPAA OS..."
    make test
    print_status "Boot test completed!"
}

# Show help
show_help() {
    echo ""
    echo "ISPAA OS Development Script"
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  check      - Check build dependencies"
    echo "  build      - Build ISPAA OS"
    echo "  run        - Run OS in QEMU"
    echo "  debug      - Run OS with debugging"
    echo "  test       - Quick boot test"
    echo "  usb <dev>  - Create bootable USB"
    echo "  clean      - Clean build files"
    echo "  info       - Show project information"
    echo "  help       - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 build       # Build the OS"
    echo "  $0 run         # Run in emulator"
    echo "  $0 usb /dev/sdb # Create bootable USB"
    echo ""
}

# Show project info
show_info() {
    print_header "ISPAA OS Project Information"
    echo ""
    echo "Version: 2.0"
    echo "Architecture: x86-32"
    echo "License: GPL v3"
    echo "Language: C + Assembly"
    echo ""
    echo "Features:"
    echo "  ✓ Custom bootloader with splash screen"
    echo "  ✓ 32-bit protected mode"
    echo "  ✓ Interactive command shell"
    echo "  ✓ Memory management"
    echo "  ✓ VGA text mode graphics"
    echo "  ✓ A20 line support"
    echo ""
    echo "Build targets:"
    make info
}

# Main script logic
case "$1" in
    "check")
        check_dependencies
        ;;
    "build")
        check_dependencies
        build_os
        ;;
    "run")
        run_qemu
        ;;
    "debug")
        debug_qemu
        ;;
    "test")
        test_os
        ;;
    "usb")
        create_usb "$2"
        ;;
    "clean")
        print_header "Cleaning build files..."
        make clean
        print_status "Clean completed!"
        ;;
    "info")
        show_info
        ;;
    "help"|""|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
