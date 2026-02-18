section .data
    sh_bin      db "/bin/bash", 0
    sh_script   db "./fire-log.sh", 0
    sh_arg      db "ASM_PULSE_COMPLETE", 0
    
    ; argv array for execve: ["/bin/bash", "./fire-log.sh", "ASM_PULSE_COMPLETE", NULL]
    shell_argv  dq sh_bin, sh_script, sh_arg, 0

section .text
    ; ... (fork logic) ...
    mov rdi, sh_bin
    lea rsi, [rel shell_argv]
    xor rdx, rdx
    mov rax, 59         ; sys_execve
    syscall
