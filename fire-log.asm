section .data
    filename db "fire-asm.log", 0
    msg      db "FIRE-PORTAL DISPATCH LOOPING", 10
    msglen   equ $ - msg

section .text
    global _start

_start:
    mov r15, 5              ; Set loop counter (5 iterations)

.loop:
    ; sys_open (rax=2), O_WRONLY|O_CREAT|O_APPEND (0x441)
    mov rax, 2
    mov rdi, filename
    mov rsi, 1089           ; 0x441
    mov rdx, 0644o
    syscall

    push rax                ; Save file descriptor
    mov rdi, rax            ; Move fd to rdi for write
    
    ; sys_write (rax=1)
    mov rax, 1
    mov rsi, msg
    mov rdx, msglen
    syscall

    ; sys_close (rax=3)
    mov rax, 3
    pop rdi                 ; Retrieve fd
    syscall

    dec r15                 ; Decrement counter
    jnz .loop               ; Jump if not zero

    ; sys_exit (rax=60)
    mov rax, 60
    xor rdi, rdi
    syscall
