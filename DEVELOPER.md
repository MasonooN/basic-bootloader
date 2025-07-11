# ISPAA OS Developer Documentation

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Boot Process](#boot-process)
3. [Kernel Design](#kernel-design)
4. [Memory Layout](#memory-layout)
5. [Adding Features](#adding-features)
6. [Debugging Guide](#debugging-guide)
7. [API Reference](#api-reference)

## Architecture Overview

ISPAA OS follows a traditional monolithic kernel design with the following components:

```
┌─────────────────────────────────────────┐
│             Applications                │ (Future)
├─────────────────────────────────────────┤
│              System Calls               │ (Future)
├─────────────────────────────────────────┤
│          Kernel Services                │
│  ┌─────────────┬─────────────────────┐   │
│  │   Shell     │    Memory Manager   │   │
│  ├─────────────┼─────────────────────┤   │
│  │ VGA Driver  │   Command Parser    │   │
│  └─────────────┴─────────────────────┘   │
├─────────────────────────────────────────┤
│          Hardware Abstraction           │
├─────────────────────────────────────────┤
│             Hardware                    │
└─────────────────────────────────────────┘
```

## Boot Process

### Stage 1: BIOS Boot Sector (boot/boot.asm)

1. **Initialization**

   - Set up segment registers (DS, ES, SS)
   - Initialize stack at 0x7C00
   - Clear screen with blue background

2. **Splash Screen**

   - Display ISPAA OS title with ASCII art
   - Show version and copyright information
   - Present loading animation

3. **Kernel Loading**

   - Read 20 sectors from disk starting at LBA 2
   - Load kernel at memory address 0x1000
   - Verify successful disk read

4. **A20 Line Activation**

   - Enable access to memory beyond 1MB
   - Use keyboard controller method
   - Critical for protected mode

5. **Protected Mode Transition**
   - Set up Global Descriptor Table (GDT)
   - Enable 32-bit protected mode
   - Jump to kernel entry point

### Stage 2: Kernel Entry (kernel/start.s)

1. **Stack Setup**

   - Initialize stack pointer to 0x90000
   - Clear direction flag for string operations

2. **C Runtime**
   - Call main kernel function
   - Handle kernel return (shouldn't happen)

## Kernel Design

### Core Components

#### VGA Text Mode Driver

- **Purpose**: Handle all screen output and formatting
- **Location**: `kernel/kernel_main.c` (functions: `put_char`, `print_string`, etc.)
- **Features**:
  - 80x25 character display
  - 16-color foreground/background
  - Cursor positioning
  - Screen scrolling
  - Colored text output

#### Memory Manager

- **Purpose**: Basic heap allocation
- **Location**: `kernel/kernel_main.c` (function: `malloc`)
- **Features**:
  - Simple linear allocator
  - Heap starts at 0x100000 (1MB)
  - 1MB heap size
  - No deallocation (future enhancement)

#### Command Shell

- **Purpose**: Interactive user interface
- **Location**: `kernel/kernel_main.c` (function: `command_shell`)
- **Features**:
  - Command parsing
  - Built-in commands
  - Colored prompt
  - Help system

## Memory Layout

```
Physical Memory Layout:
┌─────────────────────────────────────────┐ 0xFFFFFFFF
│                                         │
│          Extended Memory                │
│                                         │
├─────────────────────────────────────────┤ 0x200000 (2MB)
│             Heap Space                  │
│            (Available)                  │
├─────────────────────────────────────────┤ 0x100000 (1MB)
│             Kernel Code                 │
│          (Loaded here)                  │
├─────────────────────────────────────────┤ 0x1000
│                                         │
│          Free Memory                    │
│                                         │
├─────────────────────────────────────────┤ 0x90000
│             Stack                       │ ↓ Grows Down
├─────────────────────────────────────────┤
│                                         │
│          Free Memory                    │
│                                         │
├─────────────────────────────────────────┤ 0x7E00
│          Boot Sector                    │
│         (Loaded here)                   │
├─────────────────────────────────────────┤ 0x7C00
│                                         │
│          BIOS Data                      │
│                                         │
├─────────────────────────────────────────┤ 0x500
│       Interrupt Vector Table            │
└─────────────────────────────────────────┘ 0x0
```

## Adding Features

### Adding a New Shell Command

1. **Define the command function**:

```c
void cmd_mycommand(void) {
    print_colored("My custom command output\n", VGA_COLOR(COLOR_BLACK, COLOR_YELLOW));
}
```

2. **Add to command parser** in `process_command()`:

```c
} else if (strcmp(cmd, "mycommand") == 0) {
    cmd_mycommand();
```

3. **Update help system** in `show_help()`:

```c
print_colored("mycommand", VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_GREEN));
print_string(" - Description of my command\n");
```

### Adding Kernel Features

1. **Create the feature function**:

```c
void my_kernel_feature(void) {
    // Implementation here
}
```

2. **Call from appropriate location**:
   - Boot-time: Add to `kernel_main()`
   - Command-driven: Add to shell commands
   - Interrupt-driven: Add interrupt handler (future)

### Extending the Bootloader

1. **Modify** `boot/boot.asm`
2. **Key areas**:
   - Splash screen: Update text and colors
   - Loading: Change sectors to load
   - Memory setup: Modify memory configuration

## Debugging Guide

### Using QEMU + GDB

1. **Start QEMU with debugging**:

```bash
make run-debug
```

2. **Connect GDB**:

```bash
gdb
(gdb) target remote localhost:1234
(gdb) set architecture i386
```

3. **Common breakpoints**:

```gdb
# Break at kernel entry
(gdb) break kernel_main

# Break at specific function
(gdb) break process_command

# Break at memory address
(gdb) break *0x1000
```

4. **Useful commands**:

```gdb
# Examine memory
(gdb) x/10x 0xb8000    # VGA memory
(gdb) x/10i $pc        # Instructions

# Registers
(gdb) info registers
(gdb) print $eax

# Step through code
(gdb) step             # Step into
(gdb) next             # Step over
(gdb) continue         # Continue execution
```

### Common Issues

#### Boot Problems

- **Symptom**: System hangs at boot
- **Causes**:
  - Incorrect GDT setup
  - A20 line not enabled
  - Wrong kernel load address
- **Debug**: Use QEMU monitor, check assembly code

#### Kernel Crashes

- **Symptom**: Triple fault, reboot loop
- **Causes**:
  - Stack overflow
  - Invalid memory access
  - Interrupt without handler
- **Debug**: Use GDB, check memory layout

#### Display Issues

- **Symptom**: Garbled or missing text
- **Causes**:
  - Wrong VGA memory address
  - Incorrect color codes
  - Cursor position errors
- **Debug**: Check VGA memory contents

## API Reference

### Display Functions

#### `void clear_screen(void)`

Clears the entire screen with the current background color.

#### `void put_char(char c)`

Outputs a single character at the current cursor position.

- `\n`: New line
- `\r`: Carriage return
- `\b`: Backspace

#### `void print_string(const char* str)`

Outputs a null-terminated string.

#### `void print_colored(const char* str, uint8_t color)`

Outputs a string with specified foreground/background color.

#### `void set_cursor_position(uint8_t x, uint8_t y)`

Sets cursor to specific screen coordinates (0-based).

### Memory Functions

#### `void* malloc(size_t size)`

Allocates memory from the heap.

- **Returns**: Pointer to allocated memory
- **Note**: No corresponding `free()` function yet

### Utility Functions

#### `int strcmp(const char* str1, const char* str2)`

Compares two strings.

- **Returns**: 0 if equal, <0 if str1 < str2, >0 if str1 > str2

#### `int strlen(const char* str)`

Returns length of string.

#### `void strcpy(char* dest, const char* src)`

Copies string from source to destination.

### Color Constants

```c
#define COLOR_BLACK 0
#define COLOR_BLUE 1
#define COLOR_GREEN 2
#define COLOR_CYAN 3
#define COLOR_RED 4
#define COLOR_MAGENTA 5
#define COLOR_BROWN 6
#define COLOR_LIGHT_GRAY 7
#define COLOR_DARK_GRAY 8
#define COLOR_LIGHT_BLUE 9
#define COLOR_LIGHT_GREEN 10
#define COLOR_LIGHT_CYAN 11
#define COLOR_LIGHT_RED 12
#define COLOR_LIGHT_MAGENTA 13
#define COLOR_YELLOW 14
#define COLOR_WHITE 15

// Create color byte
#define VGA_COLOR(bg, fg) ((bg << 4) | fg)
```

## Future Enhancements

### Planned Features

- Real keyboard input handling
- Interrupt descriptor table (IDT)
- Timer interrupts
- Basic file system
- Multi-tasking support
- Network stack
- Graphics mode support

### Code Organization

As the kernel grows, consider splitting into modules:

- `drivers/` - Hardware drivers
- `fs/` - File system code
- `mm/` - Memory management
- `kernel/` - Core kernel functions
- `lib/` - Utility functions
- `include/` - Header files

---

**Note**: This documentation covers ISPAA OS v2.0. Check the repository for updates and additional resources.
