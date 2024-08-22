[BITS 16]
[ORG 0x60C0]

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00  ; Stack pointer at 0x60C0

    ; Load the kernel (Assume the kernel is located at LBA 2)
    mov bx, 0x1000  ; Load kernel at 0x1000
    mov dh, 0x00    ; Head
    mov dl, 0x80    ; Drive (first hard drive)
    mov ch, 0x00    ; Cylinder
    mov cl, 0x02    ; Sector (LBA 2)
    mov ah, 0x02    ; BIOS read sectors function
    mov al, 10      ; Load 10 sectors (5 KB kernel)
    int 0x13        ; BIOS interrupt to read disk sectors

    jc disk_error   ; Jump if there's an error

    ; Jump to the loaded kernel
    jmp 0x1000:0x0000  ; Jump to the kernel code at 0x1000:0x0000

disk_error:
    hlt  ; Halt if disk loading failed?

times 510-($-$$) db 0  ; Fill up to 510 bytes with zeros don't know why we need to do this but it doesn't proceed unless we do
dw 0xAA55              ; Boot signature
