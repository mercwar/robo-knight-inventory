section .data
    cmd      db "/usr/bin/gcc", 0
    arg0     db "gcc", 0
    arg1     db "fire-engine.c", 0
    arg2     db "-o", 0
    arg3     db "fire-portal", 0
    argv     dq arg0, arg1, arg2, arg3, 0

section .text
    global _start

_start:
    ; sys_execve (rax=59) - Compiles the C dispatcher
    mov rax, 59
    mov rdi, cmd
    mov rsi, argv
    xor rdx, rdx
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
