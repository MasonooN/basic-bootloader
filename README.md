# 🚀 ISPAA OS v2.0 - The Future is Here

![ISPAA OS](https://img.shields.io/badge/ISPAA%20OS-v2.0-blue?style=for-the-badge)
![Architecture](https://img.shields.io/badge/Architecture-x86--32-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-ISPAA%20Tech-yellow?style=for-the-badge)

**ISPAA OS** is an advanced 32-bit operating system that showcases modern OS development techniques while maintaining simplicity and educational value. Built from the ground up with cutting-edge features and a beautiful user interface.

## ✨ Features

### 🎯 Core Features

- **32-bit Protected Mode** - Full x86 protected mode with GDT
- **Advanced Bootloader** - Custom bootloader with splash screen and loading animation
- **Memory Management** - Basic heap allocation and memory protection
- **Interactive Shell** - Full-featured command-line interface
- **VGA Graphics** - Colorful text-mode display with 16-color support
- **A20 Line Support** - Access to extended memory beyond 1MB

### 🎨 Visual Features

- **ASCII Art Logo** - Beautiful ISPAA branding
- **Color-coded Interface** - Intuitive color scheme for better UX
- **Loading Animations** - Professional boot experience
- **System Information Display** - Comprehensive system status
- **Border Graphics** - Clean, professional appearance

### 💻 Shell Commands

- `clear` - Clear the screen
- `help` - Display command help
- `info` - Show system information
- `memory` - Display memory status
- `logo` - Show ISPAA OS logo
- `colors` - Test color display
- `reboot` - Restart the system
- `shutdown` - Shutdown the system

## 🏗️ Architecture

```
ISPAA OS v2.0 Architecture
├── Boot Sector (boot/boot.asm)
│   ├── BIOS initialization
│   ├── Splash screen display
│   ├── Kernel loading
│   ├── A20 line activation
│   └── Protected mode transition
├── Kernel (kernel/)
│   ├── Entry point (start.s)
│   ├── Main kernel (kernel_main.c)
│   ├── Memory management
│   ├── VGA display driver
│   └── Command shell
└── Build System (Makefile)
    ├── Cross-compilation
    ├── Image creation
    └── Testing framework
```

## 🚀 Quick Start

### Prerequisites

- **GCC** cross-compiler for i386
- **NASM** assembler
- **GNU ld** linker
- **QEMU** emulator (for testing)
- **Make** build system

### Building ISPAA OS

```bash
# Clone the repository
git clone https://github.com/yourusername/ispaa-os.git
cd ispaa-os

# Build the complete OS
make all

# Run in QEMU emulator
make run

# Build and test
make test
```

### Build Targets

| Target      | Description              |
| ----------- | ------------------------ |
| `all`       | Build complete ISPAA OS  |
| `run`       | Run in QEMU emulator     |
| `run-debug` | Run with GDB debugging   |
| `test`      | Quick boot test          |
| `install`   | Install to USB device    |
| `clean`     | Remove build artifacts   |
| `info`      | Show build information   |
| `size`      | Display size information |
| `release`   | Create release package   |

## 📁 Project Structure

```
basic-bootloader/
├── boot/
│   └── boot.asm          # Enhanced bootloader with splash screen
├── kernel/
│   ├── start.s           # Kernel entry point
│   └── kernel_main.c     # Main kernel with shell and features
├── Makefile              # Advanced build system
├── README.md             # This file
└── LICENSE               # License information
```

## 🎮 Running ISPAA OS

### In QEMU Emulator

```bash
# Standard run
make run

# With debugging support
make run-debug

# Quick test (10 second timeout)
make test
```

### On Real Hardware

```bash
# Install to USB drive (requires root)
sudo make install DEVICE=/dev/sdX

# Or manually copy the image
sudo dd if=ispaa_os.bin of=/dev/sdX bs=512
```

⚠️ **Warning**: Installing to real hardware will overwrite the target device!

## 🛠️ Development

### Adding New Features

1. **Kernel Functions**: Add to `kernel/kernel_main.c`
2. **Boot Features**: Modify `boot/boot.asm`
3. **Build Options**: Update `Makefile`

### Debugging

```bash
# Start with debugging
make run-debug

# In another terminal, connect GDB
gdb
(gdb) target remote localhost:1234
(gdb) set architecture i386
(gdb) break kernel_main
(gdb) continue
```

## 📊 System Requirements

### Minimum Requirements

- **CPU**: Intel 80386 or compatible
- **Memory**: 1MB RAM
- **Storage**: 1.44MB floppy or USB
- **Graphics**: VGA compatible

### Recommended

- **CPU**: Intel Pentium or newer
- **Memory**: 4MB+ RAM
- **Storage**: USB flash drive
- **Emulator**: QEMU for development

## 🎯 Roadmap

### Version 2.1 (Planned)

- [ ] Real keyboard input handling
- [ ] File system support
- [ ] Multi-tasking capabilities
- [ ] Network stack basics
- [ ] GUI framework

### Version 3.0 (Future)

- [ ] 64-bit support
- [ ] UEFI boot support
- [ ] Advanced memory management
- [ ] Device driver framework
- [ ] Application framework

## 🤝 Contributing

We welcome contributions to ISPAA OS! Here's how you can help:

1. **Fork** the repository
2. **Create** a feature branch
3. **Commit** your changes
4. **Push** to the branch
5. **Create** a Pull Request

### Contribution Guidelines

- Follow existing code style
- Add comments for complex functionality
- Test your changes thoroughly
- Update documentation as needed

## 📄 License

Copyright (C) 2025 ISPAA Technologies - All Rights Reserved

This project is licensed under the ISPAA Technologies License. See the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OSDev Community** - For excellent documentation and tutorials
- **QEMU Project** - For the amazing emulation platform
- **GNU Project** - For the essential development tools
- **Intel/AMD** - For x86 architecture documentation

## 📞 Support

- **Documentation**: [ISPAA OS Wiki](https://github.com/yourusername/ispaa-os/wiki)
- **Issues**: [GitHub Issues](https://github.com/yourusername/ispaa-os/issues)
- **Community**: [ISPAA OS Discord](https://discord.gg/ispaa-os)
- **Email**: support@ispaa-technologies.com

---

<div align="center">

**ISPAA OS v2.0** - _The Future is Here_

Made with ❤️ by ISPAA Technologies

</div>
