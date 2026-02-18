; fire-end.asm - Git Finalizer
section .data
    git_bin db "/usr/bin/git", 0
    a_add   dq git_bin, s_add, s_dot, 0
    a_com   dq git_bin, s_com, s_m, s_msg, 0
    a_psh   dq git_bin, s_psh, s_ori, s_main, 0

    s_add   db "add", 0
    s_dot   db ".", 0
    s_com   db "commit", 0
    s_m     db "-m", 0
    s_msg   db "AVIS: Portal Pulse Complete", 0
    s_psh   db "push", 0
    s_ori   db "origin", 0
    s_main  db "main", 0

section .text
    global _start

_start:
    ; Execute Git Add
    lea rsi, [rel a_add]
    call git_exec

    ; Execute Git Commit
    lea rsi, [rel a_com]
    call git_exec

    ; Execute Git Push
    lea rsi, [rel a_psh]
    call git_exec

    mov rax, 60
    xor rdi, rdi
    syscall

git_exec:
    mov rax, 57         ; fork
    syscall
    test rax, rax
    jz .child
    mov rdi, rax
    mov rax, 61         ; wait4
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall
    ret
.child:
    mov rdi, git_bin
    xor rdx, rdx
    mov rax, 59         ; execve
    syscall
    ret
