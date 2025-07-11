# ISPAA OS Kernel Entry Point
# Copyright (C) 2025 ISPAA Technologies

.section .text
.global _start
.extern kernel_main

_start:
    # Set up stack for C code
    movl $0x90000, %esp
    
    # Clear direction flag for string operations
    cld
    
    # Call the main kernel function
    call kernel_main
    
    # If kernel_main returns (it shouldn't), halt the system
halt_loop:
    hlt
    jmp halt_loop
