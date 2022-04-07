section .data
Msg:  db "%xI am here%s!dgdfgsdf %s %c", 0xA, 0

str:  db "something to print", 0
str1:  db "something to print 2", 0

tmpBuff  times 40 db 0

ConvertTable	db "0123456789ABCDEF"

jmpTable        dq ord_h
                dq b_hand
                dq c_hand
                dq d_hand
                dq ord_h
                dq ord_h
                dq ord_h
                dq ord_h
                dq ord_h
                dq ord_h
                dq ord_h
                dq ord_h
                dq ord_h
                dq o_hand
                dq ord_h
                dq ord_h
                dq s_h
                dq ord_h
                dq ord_h
                dq ord_h
                dq ord_h
                dq x_hand
                dq ord_h
                dq ord_h
                dq ord_h


section .bss

buf     resb 4096

section .text

global _start

_start:
        mov rdi, 1612
        mov rsi, str
        mov rdx, str1
        mov rcx, 'W'

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

            mov byte [rsi + 1], 0

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
; This function forms string which is to be printed
; 
; RBX - string literal, RAX - buffer to print
; 
; Destr: RCX, RDX
;-------------------------------------------------
cpy:
                push rbp
                mov rbp, rsp

                xor rcx, rcx
                mov rcx, 16

cycle:          xor rdx, rdx
                cmp byte [rbx], 0
                je exit

                cmp byte [rbx], '%'
                je p_hand

                jne ord_h       

p_hand:         cmp byte [rbx + 1], 'c'

                je c_hand

                cmp byte [rbx + 1], 'd'

                je d_hand

                cmp byte [rbx + 1], 'b'

                je b_hand

                cmp byte [rbx + 1], 'o'

                je o_hand

                cmp byte [rbx + 1], 'x'

                je x_hand

                cmp byte [rbx + 1], 's'
                jne ord_h

                call ps_hand

                jmp cycle


c_hand:         call pc_hand

                jmp cycle

d_hand:         push r10
                mov r10, 10
                call number_hand
                pop r10

                jmp cycle

b_hand:         push r10
                mov r10, 2
                call number_hand
                pop r10

                jmp cycle

o_hand:         push r10
                mov r10, 8
                call number_hand
                pop r10

                jmp cycle

x_hand:         push r10
                mov r10, 16
                call number_hand
                pop r10

                jmp cycle

ord_h:          mov rdx, [rbx]
                mov [rax], rdx

                inc rax
                inc rbx

                jmp cycle

exit:
                mov byte [rbx], 0

                pop rbp

                ret

;--------------------------------------------
; This function stores %d value in the buffer
;
; Entry: RAX - buffer, RBP - stack base, RCX - shift in stack
; RBX - literal, 
;
; Destr: DX
;--------------------------------------------
number_hand:
                xor rdx, rdx

                push rbx
                push rcx
                push rsi

                push rax
                push rdx

                mov rbx, [rbp + rcx]
                mov rcx, r10
                mov rsi, tmpBuff
                call itoa

                pop rdx
                pop rax

.cycle:         cmp byte [rsi], 0
                je .return

                mov rdx, [rsi]
                mov byte [rax], dl
                inc rax
                inc rsi

                jmp .cycle

.return:        pop rsi
                pop rcx
                pop rbx

                add rbx, 2
                add rcx, 8

                ret


;--------------------------------------------
; This function stores %c value in the buffer
;
; Entry: RAX - buffer, RBP - stack base, RCX - shift in stack
; RBX - literal
;
; Destr: DX
;--------------------------------------------
pc_hand:
                xor dx, dx
                mov rdx, [rbp + rcx]
                mov byte [rax], dl
                add rbx, 2
                inc rax
                add rcx, 8

                ret


                
;--------------------------------------------
; This function stores %s value in the buffer
;
; Entry: RAX - buffer, RBP - stack base, RCX - shift in stack
; RBX - literal
;
; Destr: DX
;--------------------------------------------
ps_hand:
                xor rdx, rdx

                mov rdx, [rbp + rcx]
                push rbx

s_h:            xor rbx, rbx

                cmp byte [rdx], 0
                je out

                mov rbx, [rdx]
                mov [rax], rbx

                inc rax
                inc rdx

                jmp s_h

out:            add rcx, 8
                pop rbx

                add rbx, 2

                ret



;------------------------------------------------
; Copies the character string pointed to by src,
; including the null terminator, to the character
; array whose first element is pointed to by dest.
;
; The behavior is undefined if the	dest array is not
; large enough. The behavior is undefined if the strings overlap.
;
; Entry: RSI - addr	of the source string
;
; Exit:  RDI - addr	of dest	string
; Destr: BX, AX
;------------------------------------------------
strcpy:
                call StrLen	     ; calculating length of source string, CX

                rep movsb

                ret
