; /*******************************************************************************
;  * TYPE: LAW | CLASS: MASTER-FINALIZER | NAME: fire-end.asm
;  * IDENTITY: VERSION 5.2 // FIRE-END // CVBGOD
;  * ROLE: Git Add, Commit, and Push via Kernel Syscalls
;  *******************************************************************************/

section .data
    git_bin     db "/usr/bin/git", 0
    
    ; Argument Vectors (argv) - Each list must be NULL terminated
    arg_add     dq git_bin, str_add, str_dot, 0
    arg_commit  dq git_bin, str_com, str_m, str_msg, 0
    arg_push    dq git_bin, str_psh, str_ori, str_main, 0

    str_add     db "add", 0
    str_dot     db ".", 0
    str_com     db "commit", 0
    str_m       db "-m", 0
    str_msg     db "AVIS: Portal Pulse Complete - Binary Sync", 0
    str_psh     db "push", 0
    str_ori     db "origin", 0
    str_main    db "main", 0

    msg_fin     db "[END] Pulse Complete. Pushing to Main...", 10
    len_fin     equ $-msg_fin

section .text
    global _start

_start:
    ; 1. Terminal Notification
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_fin
    mov rdx, len_fin
    syscall

    ; 2. EXEC: git add .
    call git_dispatch_add

    ; 3. EXEC: git commit -m "..."
    call git_dispatch_commit

    ; 4. EXEC: git push origin main
    call git_dispatch_push

    ; 5. Final Exit (Kills the Portal)
    mov rax, 60
    xor rdi, rdi
    syscall

; ---------------------------------------------------------
; DISPATCHERS: Fork and Execute Git commands
; ---------------------------------------------------------

git_dispatch_add:
    mov rax, 57                 ; sys_fork
    syscall
    test rax, rax
    jz .do_exec                 ; If child, go to exec
    mov rdi, rax
    mov rax, 61                 ; parent waits for child (sys_wait4)
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall
    ret
.do_exec:
    mov rdi, git_bin
    mov rsi, arg_add            ; Address of the argv array
    xor rdx, rdx                ; envp = NULL
    mov rax, 59                 ; sys_execve
    syscall
    ret

git_dispatch_commit:
    mov rax, 57
    syscall
    test rax, rax
    jz .do_exec
    mov rdi, rax
    mov rax, 61
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall
    ret
.do_exec:
    mov rdi, git_bin
    mov rsi, arg_commit
    xor rdx, rdx
    mov rax, 59
    syscall
    ret

git_dispatch_push:
    mov rax, 57
    syscall
    test rax, rax
    jz .do_exec
    mov rdi, rax
    mov rax, 61
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall
    ret
.do_exec:
    mov rdi, git_bin
    mov rsi, arg_push
    xor rdx, rdx
    mov rax, 59
    syscall
    ret
