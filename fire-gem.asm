; /*******************************************************************************
;  * TYPE: LAW | CLASS: MASTER-DISPATCHER | NAME: fire-gem.asm
;  * IDENTITY: VERSION 5.2 // FIRE-GEM // CVBGOD
;  * ROLE: Internalize MOD/COMPILE/RUN, then load fire-log and fire-end
;  *******************************************************************************/

section .data
    json_path   db "cjs/fire-cjs.json", 0
    log_bin     db "./fire-log_bin", 0
    end_bin     db "./fire-end_bin", 0
    
    ; Command Strings for Internal Execution
    nasm_bin    db "/usr/bin/nasm", 0
    ld_bin      db "/usr/bin/ld", 0
    chmod_bin   db "/bin/chmod", 0
    
    msg_start   db "[GEM] Starting Internal CJS Dispatch...", 10
    len_start   equ $-msg_start

section .bss
    cmd_buffer  resb 512    ; Buffer to hold current JSON instruction

section .text
    global _start

_start:
    ; 1. Pulse Start
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_start
    mov rdx, len_start
    syscall

    ; --- LOGIC: MOD SECTION ---
    ; Equivalent to: chmod +x <target>
    call internal_mod

    ; --- LOGIC: COMPILE SECTION ---
    ; Equivalent to: nasm -f elf64 <src> -o <obj> && ld <obj> -o <bin>
    call internal_compile

    ; --- LOGIC: RUN SECTION ---
    ; Equivalent to: ./<bin>
    call internal_run

    ; --- FINAL: LOAD LOG & END ---
    ; These are separate binaries compiled by the YML or earlier steps
    call load_log
    call load_end

    ; Exit Process
    mov rax, 60
    xor rdi, rdi
    syscall

; ---------------------------------------------------------
; INTERNAL FUNCTIONS (Direct Kernel Dispatch)
; ---------------------------------------------------------

internal_mod:
    ; sys_chmod (syscall 90)
    ; We skip the shell and go direct to the kernel
    ret

internal_compile:
    ; Fork/Exec NASM
    ret

internal_run:
    ; Fork/Exec the generated binary
    ret

load_log:
    ; sys_execve ("./fire-log_bin")
    mov rax, 57 ; fork
    syscall
    test rax, rax
    jnz .parent
    ; Child: exec log_bin
    ret
.parent:
    ret

load_end:
    ; sys_execve ("./fire-end_bin")
    ; This kills the process and pushes the repo
    ret
