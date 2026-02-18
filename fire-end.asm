section .data
    filename db "fire-asm.log", 0
    msg      db "--- PORTAL CLOSED: DISPATCH END ---", 10
    msglen   equ $ - msg

section .text
    global _start

_start:
    ; Write final log entry
    mov rax, 2
    mov rdi, filename
    mov rsi, 1089
    mov rdx, 0644o
    syscall

    mov rdi, rax
    mov rax, 1
    mov rsi, msg
    mov rdx, msglen
    syscall

    ; Final sys_exit
    mov rax, 60
    xor rdi, rdi
    syscall
