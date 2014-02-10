; Hello World!/your program here
_start:
 
    ; write(stdout, message, length)
 
    mov    rax, syscall_write
    mov    rdi, 1           ; stdout
    mov    rsi, message     ; message address
    mov    rdx, length      ; message string length
    syscall
 
    ; exit(return_code)
 
    mov    rax, syscall_exit
    mov    rdi, 0           ; return 0 (success)
    syscall
 
    message:
        db 'Hello, world!',0x0A         ; message and newline
    length: equ    $-message            ; message length calculation
