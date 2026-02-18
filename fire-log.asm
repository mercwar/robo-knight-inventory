; fire-log.asm - Multi-Target Append
section .data
    t1      db "fire-portal.log", 0
    t2      db "avis-beacon.json", 0
    msg     db '{"pulse": "DISPATCH_COMPLETE", "geo": "LOCKED"}', 10
    len_m   equ $-msg

section .text
    global _start

_start:
    ; Target 1: Portal Log
    lea rdi, [rel t1]
    call append_to_file

    ; Target 2: Beacon Status
    lea rdi, [rel t2]
    call append_to_file

    mov rax, 60
    xor rdi, rdi
    syscall

append_to_file:
    ; sys_open (O_WRONLY|O_APPEND|O_CREAT)
    mov rax, 2
    mov rsi, 02101o     ; Flags
    mov rdx, 0644o      ; Mode
    syscall
    
    mov rdi, rax        ; fd
    mov rax, 1          ; sys_write
    mov rsi, msg
    mov rdx, len_m
    syscall
    
    mov rax, 3          ; sys_close
    syscall
    ret
