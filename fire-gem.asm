section .data
    filename db "fire-asm.log", 0
    message  db "FIRE-GEM PORTAL ENTRY: TEST 4 COMPLETE", 10
    msglen   equ $ - message

section .text
    global _start

_start:
    ; --- STEP 1: OPEN FILE ---
    ; sys_open (rax=2), rdi=filename, rsi=flags, rdx=mode
    mov rax, 2          
    mov rdi, filename
    ; O_WRONLY(1) | O_CREAT(64) | O_APPEND(1024) = 1089 (0x441)
    mov rsi, 0x441      
    mov rdx, 0644o       ; File permissions (rw-r--r--)
    syscall

    ; Save file descriptor returned in RAX
    push rax
    mov rdi, rax         ; Use fd for next call

    ; --- STEP 2: WRITE TO FILE ---
    ; sys_write (rax=1), rdi=fd, rsi=buffer, rdx=length
    mov rax, 1
    mov rsi, message
    mov rdx, msglen
    syscall

    ; --- STEP 3: CLOSE FILE ---
    ; sys_close (rax=3), rdi=fd
    mov rax, 3
    pop rdi              ; Retrieve fd from stack
    syscall

    ; --- STEP 4: EXIT ---
    ; sys_exit (rax=60), rdi=status
    mov rax, 60
    xor rdi, rdi
    syscall
