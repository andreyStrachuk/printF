%macro          saveregs 0
                push rbx
                push r12
                push r13
                push r14
                push r15
%endmacro

%macro          recregs 0
                pop r15
                pop r14
                pop r13
                pop r12
                pop rbx
%endmacro

%macro          pushparams 0
                push r9
                push r8
                push rcx
                push rdx
                push rsi
                push rdi
%endmacro

%macro          popparams 0
                pop rdi
                pop rsi
                pop rdx
                pop rcx
                pop r8
                pop r9
%endmacro


section .data

baseshift       equ 64

tmpBuff  times 40 db 0

ConvertTable	db "0123456789ABCDEF"


jmpTable        dq wrong_perc
                dq b_hand
                dq c_hand
                dq d_hand
                dq wrong_perc
                dq wrong_perc
                dq wrong_perc
                dq wrong_perc
                dq wrong_perc
                dq wrong_perc
                dq wrong_perc
                dq wrong_perc
                dq wrong_perc
                dq wrong_perc
                dq o_hand
                dq wrong_perc
                dq wrong_perc
                dq wrong_perc
                dq s_h
                dq wrong_perc
                dq wrong_perc
                dq wrong_perc
                dq wrong_perc
                dq x_hand
                dq wrong_perc
                dq wrong_perc


section .bss

buf     resb 4096

section .text

global printF

;----------------------------
; This function works as printf from libc
; Supported formats: %b, %o, %d, %x, %s, %c
; 
; Entry: RDI - string literal; RSI, RDX, RCX, R8, R9 - arguments
; if you want print more than 5 args - push them to stack before calling this function (don't remove ret addr - function will do this for you)
;
; Destr: nothing
;----------------------------
printF:
                pop r10         ; pop ret addr from stack to r10 reg

                pushparams

                saveregs

                mov rax, buf
                mov rbx, rdi

                call cpy

                mov rsi, buf
                call StrLen
                mov rdx, rcx

                mov rax, 0x04
                mov rbx, 1
                mov rcx, buf
                int 0x80

                recregs

                push r10        ; push ret addr to stack

                ret


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
                mov rcx, baseshift

cycle:          xor rdx, rdx
                cmp byte [rbx], 0
                je exit

                cmp byte [rbx], '%'
                je p_hand

                cmp byte [rbx], '\'
                je bslash_h

                jne ord_h

p_hand:         cmp byte [rbx + 1], '%'
                je perc_perc

                xor rdx, rdx
                mov dl, byte [rbx + 1]
                sub rdx, 'a'

                jmp [jmpTable + 8 * rdx]


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

wrong_perc:     mov rdx, [rbx]
                mov [rax], rdx

                mov byte [rax + 1], ' '

                add rax, 2
                add rbx, 2

                jmp cycle

s_h:            call ps_hand

                jmp cycle

perc_perc:      mov rdx, [rbx + 1]
                mov [rax], rdx

                inc rax
                add rbx, 2

                jmp cycle

bslash_h:       cmp byte [rbx + 1], 'n'
                jne ord_h

                mov byte [rax], 0xA
                inc rax
                add rbx, 2

                jmp cycle

exit:
                mov byte [rax], 0

                pop rbp

                ret

;--------------------------------------------
; This function stores %d value in the buffer
;
; Entry: RAX - buffer, RBP - stack base, RCX - shift in stack
; RBX - literal
;
; Destr: RDX
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
                push rdx
                xor rdx, rdx

                mov rdx, [rbp + rcx]
                push rbx

s_hand:         xor rbx, rbx

                cmp byte [rdx], 0
                je out

                mov rbx, [rdx]
                mov [rax], rbx

                inc rax
                inc rdx

                jmp s_hand

out:            add rcx, 8
                pop rbx

                add rbx, 2

                pop rdx

                ret
