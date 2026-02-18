section .data
    json_file db "fire-gem.json", 0
    nasm_path db "/usr/bin/nasm", 0
    ld_path   db "/usr/bin/ld", 0
    
    ; Dispatch Targets
    file1 db "fire-log.asm", 0
    file2 db "fire.cjs.asm", 0
    file3 db "fire-end.asm", 0

    ; Command Arguments for compilation (Example for fire-log)
    nasm_args dq nasm_path, "-f", "elf64", file1, "-o", "fire-log.o", 0
    ld_args   dq ld_path, "fire-log.o", "-o", "fire-log", 0

section .bss
    buffer resb 4096

section .text
    global _start

_start:
    ; --- STEP 1: LOAD JSON ---
    mov rax, 2          ; sys_open (rax=2)
    mov rdi, json_file
    mov rsi, 0          ; O_RDONLY
    syscall
    
    mov rdi, rax        ; fd from open
    mov rax, 0          ; sys_read (rax=0)
    mov rsi, buffer
    mov rdx, 4096
    syscall

    ; --- STEP 2: MOD & COMPILE (fire-log.asm) ---
    ; In a strict ASM portal, we manually execute the compile for each file
    mov rax, 59         ; sys_execve (rax=59)
    mov rdi, nasm_path
    mov rsi, nasm_args
    xor rdx, rdx        ; envp = NULL
    syscall

    ; --- STEP 3: RUN DISPATCH ---
    ; Repeat execve for fire.cjs.asm and fire-end.asm following your JSON logic
    
    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall
