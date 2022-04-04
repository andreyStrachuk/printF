section .data
Msg:  db "I am here%c%c!dgdfgsdf%c", 0xA, 0

ConvertTable	db "0123456789ABCDEF"

section .bss

buf     resb 4096

section .text

global _start

_start:
        mov rdi, 'R'
        mov rsi, 'A'
        mov rdx, 'J'

        push r9
        push r8
        push rcx
        push rdx
        push rsi
        push rdi

        mov rax, buf
        mov rbx, Msg
        call cpy

        pop rdi
        pop rsi
        pop rdx
        pop rcx
        pop r8
        pop r9

        mov rsi, buf
        call StrLen
        mov edx, ecx

        mov eax, 0x04
        mov ebx, 1
        mov ecx, buf
        int 0x80

        mov eax, 0x01
        xor ebx, ebx
        int 0x80


;--------------------------------------------
; Converts an integer value to a null-terminated string using
; the specified base and stores the result in the array given by str parameter.
;
; Entry: 	RSI - addr of the string
;			RBX - number
;			RCX - base of numeric system
;
; Exit:		RSI - addr of the string
;
; Destr:	RAX, RBX, RDX
;--------------------------------------------
itoa:
            mov rax, rbx          

.count:
            xor rdx, rdx
            div rcx

            cmp rax, 0
            je .MainFunc
            inc rsi
            jmp .count

.MainFunc:
            mov rax, rbx

.itoaloop:
            xor rdx, rdx
            div rcx

            mov rbx, rdx
            mov dl, byte [rbx + ConvertTable]   

            mov byte [rsi], dl     
            dec rsi

            cmp rax, 0
            jne .itoaloop

            inc rsi

	    ret

;---------------------------------
; This function calculates	the length of string which terminates by '\0' symbol
; Entry: RSI - addres of string
;
; Exit: RCX	- length
; Destr: RCX
;---------------------------------
StrLen:
                push rsi
                xor rcx, rcx
                dec rcx
                dec rsi

.cycle_len:     inc rsi
                inc rcx

                cmp byte [rsi], 0

                jne .cycle_len

                pop rsi

                ret


;-------------------------------------------------
; SI - string literal, DI - buffer to print
; 
; go through buffer
;-------------------------------------------------
cpy:
        push rbp
        mov rbp, rsp

        xor rcx, rcx
        mov rcx, 16

cycle:  xor rdx, rdx
        cmp byte [rbx], 0
        je exit

        cmp byte [rbx], '%'
        je p_hand

        jne ord_h

p_hand: cmp byte [rbx + 1], 'c'

        jne ord_h

        je c_hand


c_hand: mov rdx, [rbp + rcx]
        mov byte [rax], dl
        add rbx, 2
        inc rax
        add rcx, 8

        jmp cycle

ord_h:  mov rdx, [rbx]
        mov [rax], rdx

        inc rax
        inc rbx

        jmp cycle

exit:
        mov byte [rbx], 0

        pop rbp

        ret
