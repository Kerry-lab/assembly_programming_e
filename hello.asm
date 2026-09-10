section .data
    msg db "Hello Worlds", 0xA
    msg_len equ $ - msg ; get length of data to be printed

section .bss

section .text
    global _start

_start:
    mov rax, 1 ; sys_write/display
    mov rdi, 1 ; std_out/on console
    mov rsi, msg ; pointer to the message
    mov rdx, msg_len ; point to the length of the message
    syscall

;   how to exit
    mov rax, 60
    xor rdi, rdi
    syscall