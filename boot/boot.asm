[BITS 16]
[ORG 0x7C00]

start:
    ; Initialize segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    ; Clear screen with cool blue background
    call clear_screen
    
    ; Display ISPAA OS splash screen
    call display_splash
    
    ; Show loading animation
    call loading_animation
    
    ; Load the kernel
    call load_kernel
    
    ; Enable A20 line for access to extended memory
    call enable_a20
    
    ; Enter protected mode and jump to kernel
    call enter_protected_mode

clear_screen:
    mov ah, 0x00    ; Set video mode
    mov al, 0x03    ; 80x25 text mode
    int 0x10
    
    mov ah, 0x06    ; Scroll window up
    mov al, 0x00    ; Clear entire screen
    mov bh, 0x1F    ; White text on blue background
    mov cx, 0x0000  ; Top-left corner
    mov dx, 0x184F  ; Bottom-right corner
    int 0x10
    ret

display_splash:
    ; Set cursor position for title
    mov ah, 0x02
    mov bh, 0x00
    mov dh, 0x08    ; Row 8
    mov dl, 0x20    ; Column 32 (centered)
    int 0x10
    
    ; Display ISPAA OS title with style
    mov si, ispaa_title
    call print_string_colored
    
    ; Display version info
    mov ah, 0x02
    mov dh, 0x0A
    mov dl, 0x25
    int 0x10
    
    mov si, version_info
    call print_string_colored
    
    ; Display copyright
    mov ah, 0x02
    mov dh, 0x15
    mov dl, 0x1C
    int 0x10
    
    mov si, copyright_info
    call print_string_colored
    ret

print_string_colored:
    mov ah, 0x0E    ; Teletype output
    mov bh, 0x00    ; Page number
    mov bl, 0x0F    ; Bright white text
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

loading_animation:
    mov cx, 20      ; 20 loading steps
    mov ah, 0x02
    mov dh, 0x0C    ; Row 12
    mov dl, 0x1E    ; Column 30
    int 0x10
    
    mov si, loading_text
    call print_string_colored
    
.loading_loop:
    ; Print loading bar character
    mov ah, 0x0E
    mov al, 0xDB    ; Block character
    mov bl, 0x0A    ; Green color
    int 0x10
    
    ; Delay
    push cx
    mov cx, 0xFFFF
.delay:
    nop
    loop .delay
    pop cx
    
    loop .loading_loop
    ret

load_kernel:
    ; Display loading message
    mov ah, 0x02
    mov dh, 0x0E
    mov dl, 0x1A
    int 0x10
    
    mov si, kernel_loading
    call print_string_colored
    
    ; Load kernel from disk
    mov bx, 0x1000  ; Load kernel at 0x1000
    mov dh, 0x00    ; Head
    mov dl, 0x80    ; Drive
    mov ch, 0x00    ; Cylinder
    mov cl, 0x02    ; Start sector
    mov ah, 0x02    ; Read sectors
    mov al, 20      ; Read 20 sectors (10KB kernel)
    int 0x13
    
    jc disk_error
    
    ; Success message
    mov si, kernel_loaded
    call print_string_colored
    ret

enable_a20:
    ; Enable A20 line via keyboard controller
    call wait_8042
    mov al, 0xAD
    out 0x64, al    ; Disable keyboard
    
    call wait_8042
    mov al, 0xD0
    out 0x64, al    ; Read output port
    
    call wait_8042_data
    in al, 0x60
    push ax
    
    call wait_8042
    mov al, 0xD1
    out 0x64, al    ; Write output port
    
    call wait_8042
    pop ax
    or al, 2        ; Set A20 bit
    out 0x60, al
    
    call wait_8042
    mov al, 0xAE
    out 0x64, al    ; Enable keyboard
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
    cli             ; Disable interrupts
    lgdt [gdt_descriptor]
    
    mov eax, cr0
    or eax, 1       ; Set protected mode bit
    mov cr0, eax
    
    jmp 0x08:protected_mode_start

[BITS 32]
protected_mode_start:
    mov ax, 0x10    ; Data segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    ; Jump to kernel
    jmp 0x1000

[BITS 16]
disk_error:
    mov si, error_msg
    call print_string_colored
    hlt

; GDT (Global Descriptor Table)
gdt_start:
    dd 0x0          ; Null descriptor
    dd 0x0

    ; Code segment descriptor
    dw 0xFFFF       ; Limit
    dw 0x0000       ; Base
    db 0x00         ; Base
    db 10011010b    ; Access byte
    db 11001111b    ; Granularity
    db 0x00         ; Base

    ; Data segment descriptor
    dw 0xFFFF       ; Limit
    dw 0x0000       ; Base
    db 0x00         ; Base
    db 10010010b    ; Access byte
    db 11001111b    ; Granularity
    db 0x00         ; Base
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; Strings
ispaa_title: db '*** ISPAA OS v2.0 - The Future is Here ***', 0
version_info: db 'Advanced 32-bit Operating System', 0
copyright_info: db '(C) 2025 ISPAA Technologies - All Rights Reserved', 0
loading_text: db 'Loading ISPAA OS: [', 0
kernel_loading: db 'Loading kernel modules...', 0
kernel_loaded: db ' DONE!', 0x0A, 0x0D, 'Starting ISPAA OS...', 0
error_msg: db 'BOOT ERROR: Cannot load ISPAA OS!', 0

times 510-($-$$) db 0  ; Fill up to 510 bytes with zeros don't know why we need to do this but it doesn't proceed unless we do
dw 0xAA55              ; Boot signature
