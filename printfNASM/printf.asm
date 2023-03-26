extern printf

section .data

frmt_str:   db "%d %s %c %d %d %d %d", 0xA, 0

str:        db "i've called printf"

section .text

global main

main:

    mov rdi, frmt_str
    mov rsi, 34
    mov rdx, str
    mov rcx, 65
    mov r8, 34
    mov r9, 35

    push 5
    push 6

    xor rax, rax
    call printf

    

    ret