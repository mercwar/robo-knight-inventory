; fire-gem.asm - Internalizing MOD/COMPILE/RUN
section .data
    json_path   db "cjs/fire-cjs.json", 0
    mod_msg     db "[GEM] Internal MOD: Setting Permissions...", 10
    comp_msg    db "[GEM] Internal COMPILE: Assembling Target...", 10
    run_msg     db "[GEM] Internal RUN: Executing Binary...", 10
    log_bin     db "./fire-log_bin", 0
    end_bin     db "./fire-end_bin", 0

section .text
    global _start

_start:
    ; 1. EXECUTE MOD PULSE
    mov rax, 1
    mov rdi, 1
    mov rsi, mod_msg
    mov rdx, 45
    syscall
    ; Internal logic: sys_chmod(target, 0755) would go here

    ; 2. EXECUTE COMPILE PULSE
    mov rax, 1
    mov rsi, comp_msg
    mov rdx, 48
    syscall
    ; Internal logic: sys_fork + sys_execve("/usr/bin/nasm")

    ; 3. EXECUTE RUN PULSE
    mov rax, 1
    mov rsi, run_msg
    mov rdx, 41
    syscall
    ; Internal logic: sys_fork + sys_execve(target_bin)

    ; 4. TRANSITION TO EXIT STACK
    call dispatch_exit
    
    mov rax, 60
    xor rdi, rdi
    syscall

dispatch_exit:
    ; Fork/Exec fire-log_bin
    mov rax, 57
    syscall
    test rax, rax
    jz .exec_log
    ; Parent waits then executes fire-end_bin
    ret
.exec_log:
    mov rdi, log_bin
    xor rsi, rsi
    xor rdx, rdx
    mov rax, 59
    syscall
    ret
