; /*******************************************************************************
;  * TYPE: LAW | CLASS: MASTER-FINALIZER | NAME: fire-end.asm
;  * IDENTITY: VERSION 5.3 // FIRE-END-EXPANDED // CVBGOD
;  * ROLE: Orchestrate Git Add -> Commit -> Push with Kernel Blocking
;  *******************************************************************************/

section .data
    git_bin     db "/usr/bin/git", 0
    
    ; Argument Vectors (argv) - Each array must be NULL terminated
    arg_add     dq git_bin, str_add, str_dot, 0
    arg_commit  dq git_bin, str_com, str_m, str_msg, 0
    arg_push    dq git_bin, str_psh, str_ori, str_main, 0

    str_add     db "add", 0
    str_dot     db ".", 0
    str_com     db "commit", 0
    str_m       db "-m", 0
    str_msg     db "AVIS: Portal Pulse Complete - Expanded Sync", 0
    str_psh     db "push", 0
    str_ori     db "origin", 0
    str_main    db "main", 0

    msg_fin     db "[END] Pulse Complete. Synchronizing Repository...", 10
    len_fin     equ $-msg_fin

section .text
    global _start

_start:
    ; 1. Notify Terminal
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    mov rsi, msg_fin
    mov rdx, len_fin
    syscall

    ; 2. STEP: GIT ADD .
    lea rsi, [rel arg_add]
    call git_exec_block

    ; 3. STEP: GIT COMMIT -m "..."
    lea rsi, [rel arg_commit]
    call git_exec_block

    ; 4. STEP: GIT PUSH ORIGIN MAIN
    lea rsi, [rel arg_push]
    call git_exec_block

    ; 5. EXIT PROCESS
    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall

; ---------------------------------------------------------
; KERNEL BLOCKING EXECUTION (Fork -> Exec -> Wait)
; RDI: Binary Path | RSI: Argv Array
; ---------------------------------------------------------
git_exec_block:
    push rsi            ; Save argv for child
    mov rax, 57         ; sys_fork
    syscall
    
    test rax, rax
    jz .child_node      ; If rax == 0, we are in the child process

.parent_node:
    ; Parent must wait for child (PID in RAX) to prevent race conditions
    mov rdi, rax        ; Target PID to wait for
    mov rax, 61         ; sys_wait4
    xor rsi, rsi        ; status = NULL
    xor rdx, rdx        ; options = 0
    xor r10, r10        ; rusage = NULL
    syscall
    pop rsi             ; Restore stack
    ret

.child_node:
    pop rsi             ; Restore argv into RSI
    mov rdi, git_bin    ; RDI = /usr/bin/git
    xor rdx, rdx        ; RDX = envp (NULL)
    mov rax, 59         ; sys_execve
    syscall
    ; If execve returns, it failed
    mov rax, 60
    mov rdi, 1
    syscall
