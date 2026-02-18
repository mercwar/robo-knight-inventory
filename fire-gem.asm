; fire-gem.asm - Master Dispatcher for cjs/fire-cjs.json
section .data
    json_path   db "cjs/fire-cjs.json", 0
    sh_bin      db "/bin/bash", 0
    mod_cmd     db "chmod +x ", 0
    log_msg     db "[GEM] Dispatching command stack...", 10
    len_log     equ $-log_msg

section .text
    global _start

_start:
    ; 1. Print Startup to stdout
    mov rax, 1
    mov rdi, 1
    mov rsi, log_msg
    mov rdx, len_log
    syscall

    ; 2. The Logic: In a real run, you'd use 'jq' or a buffer parser here.
    ; For the Debian Core, we trigger the fire-start.sh to handle the JSON parsing
    ; because parsing complex JSON in pure ASM is bulky. 
    
    mov rax, 57       ; sys_fork
    syscall
    test rax, rax
    jz child_exec

parent_wait:
    mov rdi, rax
    mov rax, 61       ; sys_wait4
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall
    jmp exit_success

child_exec:
    ; Launch fire-start.sh which interprets cjs/fire-cjs.json
    lea rdi, [rel sh_bin]
    lea rsi, [rel shell_argv]
    xor rdx, rdx
    mov rax, 59       ; sys_execve
    syscall

exit_success:
    mov rax, 60
    xor rdi, rdi
    syscall

section .data
shell_argv:
    dq sh_bin
    dq shell_path
    dq 0
shell_path:
    db "./fire-start.sh", 0
