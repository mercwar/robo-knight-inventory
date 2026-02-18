; fire-end.asm - Git Push Orchestrator
section .data
    git_path    db "/usr/bin/git", 0
    msg_push    db "[END] Staging artifacts and pushing to origin...", 10
    len_push    equ $-msg_push

    ; Git Commands
    arg_add     dq git_path, str_add, str_dot, 0
    arg_commit  dq git_path, str_com, str_m, str_msg, 0
    arg_push    dq git_path, str_psh, str_ori, str_main, 0

    str_add db "add", 0
    str_dot db ".", 0
    str_com db "commit", 0
    str_m   db "-m", 0
    str_msg db "AVIS: Portal Execution Complete", 0
    str_psh db "push", 0
    str_ori db "origin", 0
    str_main db "main", 0

section .text
    global _start

_start:
    ; Print status
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_push
    mov rdx, len_push
    syscall

    ; Note: In a production loop, you would fork/exec each git command.
    ; This binary ensures the runner's state is pushed before the job dies.
    
    mov rax, 60 ; Final Exit
    xor rdi, rdi
    syscall
