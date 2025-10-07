global templosClasicos
global cuantosTemplosClasicos


TEMPLO_TAM EQU 24
TEMPLO_OFFSET_COLUM_LARGO EQU 0
TEMPLO_OFFSET_NOMBRE EQU 8
TEMPLO_OFFSET_COLUM_CORTO EQU 16

extern calloc
;########### SECCION DE TEXTO (PROGRAMA)
section .text


;templo* templosClasicos(templo *temploArr, size_t temploArr_len)
templosClasicos: ;rdi = templo* temploArr, rsi = size_t temploArr_len
push rbp
mov rbp, rsp
push r12
push r13
push r14
push r15
;preservamos los parámetros
mov r12, rdi
mov r13, rsi

call cuantosTemplosClasicos
xor r14, r14
mov r14d, eax

xor rdi, rdi
mov edi, eax
mov rsi, TEMPLO_TAM
call calloc

;rax = puntero a mi nuevo arreglo
xor r8, r8 ; voy a usar r8 para recorrer la nueva lista
mov r8, rax
mov r15, rax
loop_templos_clasicos:
    cmp r14d, 0x0
    je fin_loop_templos_clasicos

    xor rcx, rcx
    mov cl, BYTE [r12 + TEMPLO_OFFSET_COLUM_CORTO]
    xor rdx, rdx
    mov dl, BYTE [r12 + TEMPLO_OFFSET_COLUM_LARGO]
    xor rax, rax
    mov al, 2
    mul cl
    inc ax
    cmp ax, dx
    jne siguiente_
    mov BYTE [r8 + TEMPLO_OFFSET_COLUM_CORTO], cl
    mov BYTE [r8 + TEMPLO_OFFSET_COLUM_LARGO], dl
    mov r9, QWORD [r12 + TEMPLO_OFFSET_NOMBRE]
    mov QWORD [r8 + TEMPLO_OFFSET_NOMBRE], r9
    add r8, TEMPLO_TAM
    dec r14b

siguiente_:
    add r12, TEMPLO_TAM
    jmp loop_templos_clasicos

fin_loop_templos_clasicos:
mov rax, r15
pop r15
pop r14
pop r13
pop r12
pop rbp
ret




;uint32_t cuantosTemplosClasicos(templo *temploArr, size_t temploArr_len);
cuantosTemplosClasicos: ;rdi = templo *temploArr, rsi = size_t temploArr_len
push rbp
mov rbp, rsp

xor r8d, r8d
loop_array_templos:
    cmp rsi, 0x0
    je fin_loop_array_templos

    xor rcx, rcx
    mov cl, BYTE [rdi + TEMPLO_OFFSET_COLUM_CORTO]
    xor rdx, rdx
    mov dl, BYTE [rdi + TEMPLO_OFFSET_COLUM_LARGO]
    xor rax, rax
    mov al, 2
    mul cl
    inc ax
    cmp ax, dx
    jne siguiente_templo
    inc r8d

siguiente_templo:
    dec rsi
    add rdi, TEMPLO_TAM
    jmp loop_array_templos

fin_loop_array_templos:
xor rax, rax
mov eax, r8d

pop rbp
ret
