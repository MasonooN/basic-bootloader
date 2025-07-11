.section .text
.global _start

_start:
    call kernel_main
    
    # Infinite loop if kernel_main returns
halt:
    hlt
    jmp halt
