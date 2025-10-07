ORDERING_TABLE_TAM EQU 16
ORDERING_TABLE_OFFSET_SIZE EQU 0
ORDERING_TABLE_OFFSET_TABLE EQU 8


NODO_OT_TAM EQU 16
NODO_OT_OFFSET_DISPLAY_ELEMENT EQU 0
NODO_OT_OFFSET_SIGUIENTE EQU 8


NODO_DISPLAY_TAM EQU 24
NODO_DISPLAY_OFFSET_PRIMITIVA EQU 0
NODO_DISPLAY_OFFSET_X EQU 8
NODO_DISPLAY_OFFSET_Y EQU 9
NODO_DISPLAY_OFFSET_Z EQU 10
NODO_DISPLAY_OFFSET_SIGUIENTE EQU 16



section .text

global inicializar_OT_asm
global calcular_z_asm
global ordenar_display_list_asm

extern malloc
extern free


;########### SECCION DE TEXTO (PROGRAMA)

; ordering_table_t* inicializar_OT(uint8_t table_size) 
inicializar_OT_asm: ; dil = table_size
push rbp
mov rbp, rsp 
push r12
push r13

xor r12, r12
mov r12b, dil ;preservo el parámetro

mov rdi, ORDERING_TABLE_TAM
call malloc

mov r13, rax ;preservo el puntero a la estructura

mov QWORD [r13 + ORDERING_TABLE_OFFSET_SIZE], 0
mov BYTE [r13 + ORDERING_TABLE_OFFSET_SIZE], r12b

cmp r12b, 0x0
je table_null
mov rax, 8
mul r12 ;tengo que pedir memoria para el arreglo. Son 8 bytes por cada posicion ya que guardo punteros en cada una.
mov rdi, rax
call malloc
;en rax ahora tengo el puntero al array
;limpio el array con 0
mov rcx, rax
mov r8, 0x0
loop_limpiar_array:
    cmp r8b, r12b
    je fin_limpiar_array
    mov QWORD [rcx], 0x0
    add rcx, 8
    inc r8b
    jmp loop_limpiar_array

fin_limpiar_array:
mov [r13 + ORDERING_TABLE_OFFSET_TABLE], rax
jmp fin

table_null:
mov QWORD [r13 + ORDERING_TABLE_OFFSET_TABLE], 0x0

fin:
mov rax, r13
pop r13
pop r12
pop rbp
ret


; void* calcular_z(nodo_display_list_t* display_list) ;
calcular_z_asm: ;rdi = nodo_display_list_t* display_list, sil = uint8_t z_size
push rbp
mov rbp, rsp

push r12
push r13
mov r12, rdi
xor r13, r13
mov r13b, sil

loop: 
    cmp r12, 0
    je fin2

    xor rdi, rdi
    xor rsi, rsi
    xor rdx, rdx
    mov dil, BYTE [r12 + NODO_DISPLAY_OFFSET_X]
    mov sil, BYTE [r12 + NODO_DISPLAY_OFFSET_Y]
    mov dl, r13b
    call [r12 + NODO_DISPLAY_OFFSET_PRIMITIVA]

    mov BYTE [r12 + NODO_DISPLAY_OFFSET_Z], al

    mov rcx, [r12 + NODO_DISPLAY_OFFSET_SIGUIENTE]
    mov r12, rcx
    jmp loop


fin2:
pop r13
pop r12
pop rbp
ret

; void* ordenar_display_list(ordering_table_t* ot, nodo_display_list_t* display_list) ;
ordenar_display_list_asm:;rdi = ordering_table_t* ot, rsi= nodo_display_list_t* display_list
push rbp
mov rbp, rsp
push r12
push r13
push r14
push r15
;preservo los parámetros
mov r13, rdi ;r13 = ordering_table_t*
mov r12, rsi ;r12 = nodo_display_list_t*

mov rdi, r12
xor rsi, rsi
mov sil, [r13 + ORDERING_TABLE_OFFSET_SIZE] 
call calcular_z_asm


loop1:
    cmp r12, 0
    je fin3    

    ;armo nuevo nodo_ot
    mov rdi, NODO_OT_TAM
    call malloc
    ;inicializo el nuevo nodo ot
    mov [rax + NODO_OT_OFFSET_DISPLAY_ELEMENT], r12
    mov QWORD [rax + NODO_OT_OFFSET_SIGUIENTE], 0X0
    ;preservo el nuevo nodo ot
    mov r15, rax

    ;agrego el nuevo nodo ot, a la tabla ot.
    mov r14, [r13 + ORDERING_TABLE_OFFSET_TABLE]
    
    xor rcx, rcx
    xor rax, rax
    mov cl, [r12 + NODO_DISPLAY_OFFSET_Z]
    mov al, 8
    mul cl
    
    add r14 , rax

    cmp QWORD [r14], 0x0
    je primer_nodo_ot
    mov r9, [r14] ;con r9 recorro la lista enlazada de nodos_ot
    loop2:
        cmp QWORD [r9 + NODO_OT_OFFSET_SIGUIENTE], 0x0
        je fin_lista_nodo_ot

        mov rcx, [r9 + NODO_OT_OFFSET_SIGUIENTE]
        mov r9, rcx
        jmp loop2

    fin_lista_nodo_ot:
        mov [r9 + NODO_OT_OFFSET_SIGUIENTE], r15
        jmp siguiente_nodo_display

    primer_nodo_ot:
        mov [r14], r15

    siguiente_nodo_display:
    mov rcx, [r12 + NODO_DISPLAY_OFFSET_SIGUIENTE]
    mov r12, rcx
    jmp loop1


fin3:
pop r15
pop r14
pop r13
pop r12
pop rbp
ret
