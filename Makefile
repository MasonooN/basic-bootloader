# ISPAA OS Build System
# Copyright (C) 2025 ISPAA Technologies

AS = nasm
CC = gcc
LD = ld
ASFLAGS = -f bin
CFLAGS = -m32 -ffreestanding -nostdlib -nostartfiles -fno-pic -c -O2 -Wall -Wextra
LDFLAGS = -m elf_i386 -Ttext 0x1000 --oformat binary

# Define the paths
BOOTLOADER_SRC = boot/boot.asm
BOOTLOADER_BIN = ispaa_bootloader.bin
KERNEL_START_SRC = kernel/start.s
KERNEL_START_OBJ = start.o
KERNEL_SRC = kernel/kernel_main.c
KERNEL_OBJ = kernel.o
KERNEL_BIN = ispaa_kernel.bin
IMAGE_BIN = ispaa_os.bin

# Build targets
all: $(BOOTLOADER_BIN) $(KERNEL_BIN) $(IMAGE_BIN)
	@echo "ISPAA OS build complete!"
	@echo "Boot image: $(IMAGE_BIN)"
	@echo "Size: `du -h $(IMAGE_BIN) | cut -f1`"

$(BOOTLOADER_BIN): $(BOOTLOADER_SRC)
	@echo "Building ISPAA OS bootloader..."
	$(AS) $(ASFLAGS) -o $@ $<

$(KERNEL_START_OBJ): $(KERNEL_START_SRC)
	@echo "Assembling kernel entry point..."
	as --32 -o $@ $<

$(KERNEL_OBJ): $(KERNEL_SRC)
	@echo "Compiling ISPAA OS kernel..."
	$(CC) $(CFLAGS) -o $@ $<

$(KERNEL_BIN): $(KERNEL_START_OBJ) $(KERNEL_OBJ)
	@echo "Linking kernel..."
	$(LD) $(LDFLAGS) $(KERNEL_START_OBJ) $(KERNEL_OBJ) -o $@

$(IMAGE_BIN): $(BOOTLOADER_BIN) $(KERNEL_BIN)
	@echo "Creating bootable ISPAA OS image..."
	cat $(BOOTLOADER_BIN) $(KERNEL_BIN) > $(IMAGE_BIN)
	
	# Pad to minimum size for proper booting
	@SIZE=$$(stat -c%s $(IMAGE_BIN) 2>/dev/null || stat -f%z $(IMAGE_BIN) 2>/dev/null || echo 1024); \
	if [ $$SIZE -lt 1474560 ]; then \
		dd if=/dev/zero bs=1 count=$$((1474560 - $$SIZE)) >> $(IMAGE_BIN) 2>/dev/null; \
	fi

# Development and testing targets
run: $(IMAGE_BIN)
	@echo "Running ISPAA OS in QEMU..."
	qemu-system-i386 -fda $(IMAGE_BIN) -boot a

run-debug: $(IMAGE_BIN)
	@echo "Running ISPAA OS in QEMU with debugging..."
	qemu-system-i386 -fda $(IMAGE_BIN) -boot a -s -S

test: $(IMAGE_BIN)
	@echo "Testing ISPAA OS boot process..."
	timeout 10 qemu-system-i386 -fda $(IMAGE_BIN) -boot a -nographic || echo "Boot test completed"

# File operations
install: $(IMAGE_BIN)
	@echo "Installing ISPAA OS to USB device (requires root)..."
	@echo "WARNING: This will overwrite the target device!"
	@echo "Usage: sudo make install DEVICE=/dev/sdX"
	@if [ -z "$(DEVICE)" ]; then \
		echo "Error: Please specify DEVICE=/dev/sdX"; \
		exit 1; \
	fi
	@read -p "Are you sure you want to install to $(DEVICE)? [y/N] " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		dd if=$(IMAGE_BIN) of=$(DEVICE) bs=512; \
		sync; \
		echo "ISPAA OS installed to $(DEVICE)"; \
	else \
		echo "Installation cancelled"; \
	fi

# Information targets
info:
	@echo "=== ISPAA OS Build Information ==="
	@echo "Bootloader: $(BOOTLOADER_BIN)"
	@echo "Kernel: $(KERNEL_BIN)"
	@echo "Final Image: $(IMAGE_BIN)"
	@echo "Build Tools:"
	@echo "  Assembler: $(AS)"
	@echo "  Compiler: $(CC)"
	@echo "  Linker: $(LD)"
	@echo ""
	@echo "Available targets:"
	@echo "  all      - Build complete ISPAA OS"
	@echo "  run      - Run in QEMU emulator"
	@echo "  run-debug- Run with GDB debugging"
	@echo "  test     - Quick boot test"
	@echo "  install  - Install to USB (requires DEVICE=)"
	@echo "  clean    - Remove build artifacts"
	@echo "  info     - Show this information"

size: $(IMAGE_BIN)
	@echo "=== ISPAA OS Size Information ==="
	@echo "Bootloader: `stat -c%s $(BOOTLOADER_BIN) 2>/dev/null || stat -f%z $(BOOTLOADER_BIN)` bytes"
	@echo "Kernel: `stat -c%s $(KERNEL_BIN) 2>/dev/null || stat -f%z $(KERNEL_BIN)` bytes"
	@echo "Total Image: `stat -c%s $(IMAGE_BIN) 2>/dev/null || stat -f%z $(IMAGE_BIN)` bytes"

# Cleanup
clean:
	@echo "Cleaning ISPAA OS build artifacts..."
	rm -f $(BOOTLOADER_BIN) $(KERNEL_BIN) $(KERNEL_START_OBJ) $(KERNEL_OBJ) $(IMAGE_BIN)
	@echo "Clean complete!"

# Create a release package
release: clean all
	@echo "Creating ISPAA OS release package..."
	@mkdir -p release
	@cp $(IMAGE_BIN) release/
	@cp README.md release/ 2>/dev/null || echo "# ISPAA OS v2.0" > release/README.md
	@tar czf ispaa-os-v2.0.tar.gz release/
	@echo "Release package created: ispaa-os-v2.0.tar.gz"

.PHONY: all run run-debug test install info size clean release
