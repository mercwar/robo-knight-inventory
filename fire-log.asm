; fire-log.asm - Multi-File Pulse Sync
section .data
    target1 db "fire-portal.log", 0
    target2 db "avis-beacon.json", 0
    target3 db "cjs/geo-audit.log", 0
    pulse   db "[PULSE] Multi-Target Log Sync Complete", 10

section .text
    global _start

_start:
    ; Iterate through targets 1-3
    mov r15, 1
.loop:
    cmp r15, 1
    je .t1
    cmp r15, 2
    je .t2
    cmp r15, 3
    je .t3
    jmp .done

.t1: lea rdi, [rel target1]
     jmp .write
.t2: lea rdi, [rel target2]
     jmp .write
.t3: lea rdi, [rel target3]
     jmp .write

.write:
    mov rax, 2          ; sys_open
    mov rsi, 02101o     ; O_WRONLY | O_APPEND | O_CREAT
    mov rdx, 0644o
    syscall
    mov rbx, rax        ; save fd
    
    mov rax, 1          ; sys_write
    mov rdi, rbx
    mov rsi, pulse
    mov rdx, 41
    syscall
    
    mov rax, 3          ; sys_close
    mov rdi, rbx
    syscall
    
    inc r15
    jmp .loop

.done:
    mov rax, 60
    xor rdi, rdi
    syscall
