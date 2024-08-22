AS = nasm
CC = gcc
LD = ld

ASFLAGS = -f bin
CFLAGS = -m32 -ffreestanding -nostdlib -c
LDFLAGS = -m elf_i386 -Ttext 0x1000 --oformat binary

all: bootloader.bin kernel.bin bootable_image.bin

bootloader.bin: bootloader.asm
	$(AS) $(ASFLAGS) -o bootloader.bin bootloader.asm

kernel.o: kernel.c
	$(CC) $(CFLAGS) -o kernel.o kernel.c

kernel.bin: kernel.o
	$(LD) $(LDFLAGS) kernel.o -o kernel.bin

bootable_image.bin: bootloader.bin kernel.bin
	cat bootloader.bin kernel.bin > bootable_image.bin

clean:
	rm -f *.bin *.o
