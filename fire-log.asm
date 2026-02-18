; fire-log.asm - Kernel-level Log Injector
section .data
    file_name db "fire-portal.log", 0
    entry_msg db "[PULSE] Kernel Function Executed | Geo: Hardcoded", 10
    len_entry equ $-entry_msg

section .text
    global _start

_start:
    ; Open for Appending
    mov rax, 2          ; sys_open
    mov rdi, file_name
    mov rsi, 0101o      ; O_WRONLY | O_APPEND
    mov rdx, 0644o
    syscall

    ; Write Entry
    mov rdi, rax        ; fd from open
    mov rax, 1          ; sys_write
    mov rsi, entry_msg
    mov rdx, len_entry
    syscall

    ; Close & Exit
    mov rax, 3          ; sys_close
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
