LISTA_OFFSET_FIRST EQU 0
LISTA_OFFSET_LAST EQU 8
LISTA_TAM EQU 16


LISTA_ELEM_TAM EQU 24
LIST_ELEM_OFFSET_DATA EQU 0
LIST_ELEM_OFFSET_NEXT EQU 8
LIST_ELEM_OFFSET_PREV EQU 16


PAGO_OFFSET_TAM EQU 24
PAGO_OFFSET_COBRADOR EQU 16
PAGO_OFFSET_PAGADOR EQU 8
PAGO_OFFSET_MONTO EQU 0
PAGO_OFFSET_APROBADO EQU 1


PAGO_SPLITTED_TAM EQU 24
PAGO_SPLITTED_APROBADOS EQU 0
PAGO_SPLITTED_RECHAZADOS EQU 1
PAGO_SPLITTED_ARRAY_APROBADOS EQU 8
PAGO_SPLITTED_ARRAY_RECHAZADOS EQU 16

section .text



global contar_pagos_aprobados_asm
global contar_pagos_rechazados_asm

global split_pagos_usuario_asm
global pagos_aprobados_usuario_asm
global pagos_rechazados_usuario_asm
extern malloc
extern free
extern strcmp
; COMENTARIO IMPORTANTE: LOS TEST DE ESTE EJERCICIO NO SON BUENOS. TUVE QUE CORREGIR ERRORES GROSOS Y, A PESAR DE ELLOS, LOS TEST SE APROBABAN IGUALEMENTE. POR ELLO INTENTE CORREGIR TODO LO MEJOR QUE PUDE PERO PUEDEN EXISTIR ERRORES.

;########### SECCION DE TEXTO (PROGRAMA)

; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
contar_pagos_aprobados_asm: ;rdi = list_t* pList. rsi = char* usuario.
push rbp
mov rbp, rsp
push r12
push r13
push r14
push r15 

mov r12, rdi ;r12 = list_t* pList. r13 = char* usuario.
mov r13, rsi

xor r14, r14 ; r14 = total de aprobados
mov r15, [rdi + LISTA_OFFSET_FIRST] ;r15 = indice para recorrer la lista


;utilizo r14 para guardar el total y r15 para usar como indice. En cada iteración del loop debo llamar a strcmp,
;por ende uso registros no volatiles

loop:
cmp r15, 0x0
je fin

cmp DWORD[r15 + LIST_ELEM_OFFSET_DATA], 0x0
je next
mov rdx, [r15 + LIST_ELEM_OFFSET_DATA] ;rdx = pago_t* data

mov rdi, [rdx + PAGO_OFFSET_COBRADOR] ; rdi = char* cobrador
mov rsi, r13 ;rsi = char* usuario

call strcmp

;chequeo si es el mismo usuario
cmp rax, 0
jne next 

;chequeo si el pago está aprobado
mov rdx, [r15 + LIST_ELEM_OFFSET_DATA]
mov dil, BYTE [rdx + PAGO_OFFSET_APROBADO]
cmp dil, 1
jne next

inc r14b

next:
mov rdx, [r15 + LIST_ELEM_OFFSET_NEXT]
mov r15, rdx
jmp loop

    
fin:
mov al, r14b
pop r15
pop r14
pop r13
pop r12
pop rbp
ret

; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
contar_pagos_rechazados_asm:
push rbp
mov rbp, rsp
push r12
push r13
push r14
push r15 

mov r12, rdi ;r12 = list_t* pList. r13 = char* usuario.
mov r13, rsi

xor r14, r14 ; r14 = total de aprobados
mov r15, [rdi + LISTA_OFFSET_FIRST] ;r15 = indice para recorrer la lista


;utilizo r14 para guardar el total y r15 para usar como indice. En cada iteración del loop debo llamar a strcmp,
;por ende uso registros no volatiles

loop2:
cmp r15, 0x0
je fin2

cmp DWORD[r15 + LIST_ELEM_OFFSET_DATA], 0x0
je next2
mov rdx, [r15 + LIST_ELEM_OFFSET_DATA] ;rdx = pago_t* data

mov rdi, [rdx + PAGO_OFFSET_COBRADOR] ; rdi = char* cobrador
mov rsi, r13 ;rsi = char* usuario

call strcmp

;chequeo si es el mismo usuario
cmp rax, 0
jne next2 

;chequeo si el pago está aprobado
mov rdx, [r15 + LIST_ELEM_OFFSET_DATA]
mov dil, BYTE [rdx + PAGO_OFFSET_APROBADO]
cmp dil, 0
jne next2

inc r14b

next2:
mov rdx, [r15 + LIST_ELEM_OFFSET_NEXT]
mov r15, rdx
jmp loop2

    
fin2:
mov al, r14b
pop r15
pop r14
pop r13
pop r12
pop rbp
ret


; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
split_pagos_usuario_asm: ; rdi = list_t* pList    rsi = char* usuario
push rbp
mov rbp, rsp

push r12
push r13
push r14
push r15
;preservo los parámetros
mov r12, rdi
mov r13, rsi

mov rdi, PAGO_SPLITTED_TAM
call malloc 

mov r14, rax  ; r14 = pagoSplitted_t *

mov rdi, r12
mov rsi, r13
call contar_pagos_aprobados_asm

mov BYTE[r14 + PAGO_SPLITTED_APROBADOS], al

mov rdi, r12
mov rsi, r13
mov dl, al
call pagos_aprobados_usuario_asm

mov [r14 + PAGO_SPLITTED_ARRAY_APROBADOS], rax

mov rdi, r12
mov rsi, r13
call contar_pagos_rechazados_asm

mov BYTE[R14 + PAGO_SPLITTED_RECHAZADOS], al


mov rdi, r12
mov rsi, r13
mov dl, al
call pagos_rechazados_usuario_asm

mov [r14 + PAGO_SPLITTED_ARRAY_RECHAZADOS], rax

mov rax, r14
pop r15
pop r14
pop r13
pop r12
pop rbp
ret


;pago_t** pagos_aprobados_usuario_asm(list_t* pList, char* usuario, uint8_t cantidad_pagos_aprobados) 
pagos_aprobados_usuario_asm: ;ERRORES CORREGIDOS Y EXPLICADOS EN PAGOS RECHAZADOS
push rbp
mov rbp, rsp
push rbx
push r12
push r13
push r14
push r15
sub rsp, 8


;preservo los parámetros
mov r12, [rdi + LISTA_OFFSET_FIRST]
mov r13, rsi
xor rbx, rbx
mov bl, dl

xor rax, rax
xor rcx, rcx
xor rdi, rdi
mov ax, dx     
mov cx, 8      
mul cx         
mov di, ax     
call malloc
;rax = pago_t**


mov r15, rax ;preservo el puntero


cmp bl , 0x0 ;chequeo si el array debe ser vacío
je fin3


mov r14, rax ;uso r14 como indice para recorrer el array


loop3:
cmp bl, 0x0
je fin4


;chequeo mismo usuario
mov rdi, r13

mov rdx, [r12 + LIST_ELEM_OFFSET_DATA]
mov rsi, [rdx + PAGO_OFFSET_COBRADOR]
cmp rsi, 0x0
je next3

call strcmp
cmp rax, 0
jne next3 


;chequeo si el pago está aprobado
mov rdx, [r12 + LIST_ELEM_OFFSET_DATA]
mov dil, BYTE [rdx + PAGO_OFFSET_APROBADO]
cmp dil, 1
jne next3

;copio el puntero al pago_t hallado
mov r8, [r12 + LIST_ELEM_OFFSET_DATA]
mov [r14], r8
add r14, 8
dec bl

next3:
mov rdx, [r12 + LIST_ELEM_OFFSET_NEXT]
mov r12, rdx
;add r14, 8
jmp loop3


fin3:
mov rax, r15
add rsp, 8
pop r15
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret







;pago_t** pagos_rechazados_usuario_asm(list_t* pList, char* usuario, uint8_t cantidad_pagos_rechazados) 
pagos_rechazados_usuario_asm:
push rbp
mov rbp, rsp
push rbx
push r12
push r13
push r14
push r15
sub rsp, 8

;preservo los parámetros
;mov r12, rdi TUVE QUE CORREGIR ESTA LINEA PORQUE USABA R12 PARA RECORRER LA LISTA ENLAZADA. LO CORRECTO ES HACER LO SIGUIENTE EN LA LINEA 321.
mov r12, [rdi + LISTA_OFFSET_FIRST]
mov r13, rsi
xor rbx, rbx
mov bl, dl

xor rax, rax
xor rcx, rcx
xor rdi, rdi
mov ax, dx     
mov cx, 8      
mul cx         
mov di, ax     
call malloc
;rax = pago_t**

mov r15, rax ;preservo el puntero

cmp bl , 0x0 ;chequeo si el array debe ser vacío
je fin4


mov r14, rax ;uso r14 como indice para recorrer el array

loop4:
;cmp r12, 0x0 ;EN VEZ DE RECORRER TODOS LOS PAGOS HASTA EL FINAL, FRENO EL LOOP CUANDO YA HAYA ENCONTRADO TODOS LOS PAGOS
cmp bl, 0x0
je fin4


;chequeo mismo usuario
mov rdi, r13

mov rdx, [r12 + LIST_ELEM_OFFSET_DATA]
mov rsi, [rdx + PAGO_OFFSET_COBRADOR]
cmp rsi, 0x0
je next4

call strcmp
cmp rax, 0
jne next4 


;chequeo si el pago está aprobado
mov rdx, [r12 + LIST_ELEM_OFFSET_DATA]
mov dil, BYTE [rdx + PAGO_OFFSET_APROBADO]
cmp dil, 0
jne next4

;copio el puntero al pago_t hallado
;mov r14, [r12 + LIST_ELEM_OFFSET_DATA] ESTO ESTABA MAL. PUES CON R14 ESTABA RECORRIENDO EL ARRAY DE PUNTEROS PAGO_T* . 

mov r8, [r12 + LIST_ELEM_OFFSET_DATA]
mov [r14], r8
add r14, 8
dec bl

next4:
mov rdx, [r12 + LIST_ELEM_OFFSET_NEXT]
mov r12, rdx
;add r14, 8 ESTO ESTABA MAL. SOLO QUIERO AVANZAR EN EL ARRAY CUANDO HAYA GUARDADO UN PAGO ENCONTRADO. 

jmp loop4


fin4:
mov rax, r15
add rsp, 8
pop r15
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret

