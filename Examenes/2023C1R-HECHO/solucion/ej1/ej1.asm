global acumuladoPorCliente_asm
global en_blacklist_asm
global blacklistComercios_asm
global totalDePagosBlacklist_asm

PAGO_TAM EQU 24
PAGO_OFFSET_MONTO EQU 0
PAGO_OFFSET_COMERCIO EQU 8
PAGO_OFFSET_CLIENTE EQU 16
PAGO_OFFSET_APROBADO EQU 17

;########### SECCION DE TEXTO (PROGRAMA)
section .text

extern calloc
extern strcmp

;uint32_t* acumuladoPorCliente_asm(uint8_t cantidadDePagos, pago_t* arr_pagos)
acumuladoPorCliente_asm: ; dil = cantidadDePagos, rsi = arr_pagos
push rbp
mov rbp, rsp
push r14
push r15

xor r14, r14
mov r14b, dil
mov r15, rsi

mov rdi, 10
mov rsi, 4
call calloc
mov r8, rax
loop: 
	cmp r14b, 0x0
	je fin

	cmp BYTE[r15 + PAGO_OFFSET_APROBADO], 1
	jne siguiente

	xor rcx, rcx
	mov cl, [r15 + PAGO_OFFSET_MONTO]
	xor rsi, rsi
	mov sil, [r15 + PAGO_OFFSET_CLIENTE]
	mov rax, 4
	mul sil

	add BYTE [r8 + rax], cl

siguiente:
	dec r14b
	add r15, PAGO_TAM
	jmp loop

fin:
mov rax, r8
pop r15
pop r14
pop rbp
ret

;uint8_t en_blacklist_asm(char* comercio, char** lista_comercios, uint8_t n);
en_blacklist_asm: ;rdi = char* comercio rsi = char** lista_comercios , dl uint8_t n
push rbp
mov rbp, rsp
push r12
push r13
push r14
sub rsp, 8

mov r12, rdi ;r12 = char* comercio
mov r13, rsi ; r13 = char** lista_comercios
xor r14, r14
mov r14b, dl
xor rax, rax
loop_lista_comercios:	
	cmp r14b, 0x0
	je fin_loop_lista_comercios

	mov rdi, r12
	mov rcx, QWORD [r13]
	mov rsi, rcx
	call strcmp

	cmp ax, 0x0
	jne char_siguiente

	mov rax, 1
	jmp fin_loop_lista_comercios

char_siguiente:
	dec r14b
	add r13, 8
	xor rax, rax
	jmp loop_lista_comercios


fin_loop_lista_comercios:
add rsp, 8
pop r14
pop r13
pop r12
pop rbp
ret


;pago_t** blacklistComercios_asm(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios);
blacklistComercios_asm: ;dil = uint8_t cantidad_pagos, rsi = pago_t* pagos, rdx = char** arr_comercios, cl = uint8_t size_comercios
push rbp
mov rbp, rsp
push rbx
push r12
push r13
push r14
push r15
sub rsp, 8

;preservo los parámetros
xor r12, r12
mov r12b, dil ;r12b = uint8_t cantidad_pagos
mov r13, rsi ; r13 =  pago_t* pagos
mov r14, rdx ; r14 = char** arr_comercios
xor r15, r15 
mov r15b, cl ;r15b = uint8_t size_comercios

call totalDePagosBlacklist_asm

mov rdi, rax
mov rsi, 8
call calloc

mov rbx, rax
mov r8, rax ;uso r8 para recorrer la lista e ir guardando los punteros
loop_pagos:
	cmp r12b, 0x0
	je fin_loop_pagos

	push r8
	sub rsp, 8
	mov rdi, [r13 + PAGO_OFFSET_COMERCIO]
	mov rsi, r14
	xor rdx, rdx
	mov dl, r15b
	call en_blacklist_asm
	add rsp, 8
	pop r8
	cmp ax, 1
	jne siguiente_loop_pagos
	mov [r8], r13
	add r8, 8

siguiente_loop_pagos:
dec r12b
add r13, PAGO_TAM
jmp loop_pagos


fin_loop_pagos:
mov rax, rbx

add rsp, 8
pop r15
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret

;uint32_t totalDePagosBlacklist_asm(uint8_t cantidad_pagos, pago_t* arr_pagos, char** arr_comercios, uint8_t size_comercios) 
;funcion auxiliar que devuelve el total de pagos hechos por algun comercio de la lista pasada por parámetro
totalDePagosBlacklist_asm:
push rbp
mov rbp, rsp
push rbx
push r12
push r13
push r14
push r15
sub rsp, 8

xor r12, r12
mov r12b, dil ;r12b = uint8_t cantidad_pagos
mov r13, rsi ; r13 =  pago_t* pagos
mov r14, rdx ; r14 = char** arr_comercios
xor r15, r15 
mov r15b, cl ;r15b = uint8_t size_comercios

xor rbx, rbx ; rbx = resultado total
loop_lista_pagos:
	cmp r12b, 0x0
	je fin_loop_lista_pagos

	mov rdi, [r13 + PAGO_OFFSET_COMERCIO]
	mov rsi, r14
	xor rdx, rdx
	mov dl, r15b
	
	call en_blacklist_asm

	cmp ax, 1
	jne siguiente_loop_lista_pagos
	inc rbx

siguiente_loop_lista_pagos:
	dec r12b
	add r13, PAGO_TAM
	jmp loop_lista_pagos


fin_loop_lista_pagos:
mov rax, rbx
add rsp, 8
pop r15
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret
