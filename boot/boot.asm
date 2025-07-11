[BITS 16]
[ORG 0x7C00]

start:
    ; Initialize segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Clear screen
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    
    ; Display simple boot message
    mov si, boot_msg
    call print_string
    
    ; Load the kernel
    call load_kernel
    
    ; Enable A20 line
    call enable_a20
    
    ; Enter protected mode
    call enter_protected_mode

print_string:
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

load_kernel:
    mov si, loading_msg
    call print_string
    
    ; Load kernel from disk
    mov bx, 0x1000  ; Load at 0x1000
    mov dh, 0x00    ; Head 0
    mov dl, 0x80    ; Drive 0x80
    mov ch, 0x00    ; Cylinder 0
    mov cl, 0x02    ; Sector 2
    mov ah, 0x02    ; Read function
    mov al, 20      ; Read 20 sectors
    int 0x13
    
    jc disk_error
    
    mov si, success_msg
    call print_string
    ret

enable_a20:
    ; Simple A20 enable via keyboard controller
    call wait_8042
    mov al, 0xAD
    out 0x64, al
    
    call wait_8042
    mov al, 0xD0
    out 0x64, al
    
    call wait_8042_data
    in al, 0x60
    push ax
    
    call wait_8042
    mov al, 0xD1
    out 0x64, al
    
    call wait_8042
    pop ax
    or al, 2
    out 0x60, al
    
    call wait_8042
    mov al, 0xAE
    out 0x64, al
    ret

wait_8042:
    in al, 0x64
    test al, 2
    jnz wait_8042
    ret

wait_8042_data:
    in al, 0x64
    test al, 1
    jz wait_8042_data
    ret

enter_protected_mode:
    cli
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    jmp 0x08:protected_start

[BITS 32]
protected_start:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    jmp 0x1000

[BITS 16]
disk_error:
    mov si, error_msg
    call print_string
    hlt

; GDT
gdt_start:
    dd 0x0, 0x0                 ; Null descriptor
    dd 0x0000FFFF, 0x00CF9A00   ; Code segment
    dd 0x0000FFFF, 0x00CF9200   ; Data segment
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; Messages
boot_msg: db 'ISPAA OS v2.0 Bootloader', 0x0D, 0x0A, 0
loading_msg: db 'Loading kernel...', 0
success_msg: db 'OK', 0x0D, 0x0A, 'Starting ISPAA OS...', 0x0D, 0x0A, 0
error_msg: db 'BOOT ERROR!', 0

times 510-($-$$) db 0
dw 0xAA55
