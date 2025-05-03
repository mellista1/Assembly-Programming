extern malloc
extern free
extern strcpy

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
ATTACKUNIT_SIZE EQU 16
ATTACKUNIT_OFFSET_CLASE EQU 0
ATTACKUNIT_OFFSET_COMBUSTIBLE EQU 12
ATTACKUNIT_OFFSET_REF EQU 14


section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - optimizar
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contarCombustibleAsignado
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - modificarUnidad
global EJERCICIO_1C_HECHO
EJERCICIO_1C_HECHO: db TRUE; Cambiar por `TRUE` para correr los tests.

global optimizar
optimizar:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	
	;rdi = mapa_t mapa, rsi = attackunit_t* compartida, rdx = uint32_t (*fun_hash)(attackunit_t*)
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8

	mov r12, rdi
	mov r13, rsi
	mov r14, rdx

	xor r15, r15
	mov r15, 255
	imul r15, 255
	
	mov rdi, r13
	call r14
	mov ebx, eax ;ebx = hash compartida

	loop_sobre_mapa:
		cmp r15, 0
		je fin_loop_sobre_mapa

		cmp QWORD [r12], 0
		je siguiente_pos_del_mapa
		
		;comparo hashes
		xor rdi, rdi
		mov rdi, QWORD [r12]
		call r14
		cmp ebx, eax
		jne siguiente_pos_del_mapa

		;chequeo no limpiar el attackunit que me pasan por parámetro
		cmp r13, QWORD [r12]
		je siguiente_pos_del_mapa

		add BYTE [r13 + ATTACKUNIT_OFFSET_REF], 1
		mov rdi, QWORD [r12] 
		sub BYTE [rdi + ATTACKUNIT_OFFSET_REF], 1

		mov QWORD [r12], r13
		
		cmp BYTE [rdi + ATTACKUNIT_OFFSET_REF], 0
		jne siguiente_pos_del_mapa		
		
		call free

	siguiente_pos_del_mapa:
		dec r15
		add r12, 8
		jmp loop_sobre_mapa

	fin_loop_sobre_mapa:
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret

global contarCombustibleAsignado
contarCombustibleAsignado: ;rdi = mapa_t mapa, rsi = uint16_t (*fun_combustible)(char*)
push rbp
mov rbp, rsp
push r12
push r13
push r14
push r15

mov r12, rdi
mov r13, rsi

xor r15, r15
mov r15, 255
imul r15, 255

xor r14, r14 ;r14 = total combustible asignado

loop_calcular_combustible:
	cmp r15, 0
	je fin_loop_calcular_combustible

	mov rdi, [r12]
	cmp rdi, 0
	je siguiente_iteracion

	call r13
	
	xor rcx, rcx
	mov rdi, [r12]
	mov cx, word [rdi + ATTACKUNIT_OFFSET_COMBUSTIBLE]

	cmp ax, cx
	je siguiente_iteracion

	sub cx, ax
	add r14, rcx

siguiente_iteracion:
	dec r15
	add r12, 8
	jmp loop_calcular_combustible

fin_loop_calcular_combustible:
mov eax, r14d
pop r15
pop r14
pop r13
pop r12
pop rbp
ret

global modificarUnidad
modificarUnidad: ;rdi = mapa_t mapa, sil = uint8_t x, dl = uint8_t y, rcx = void (*modificar_t)(attackunit_t*)
push rbp
mov rbp, rsp
push rbx
push r12
push r13
push r14
push r15
sub rsp, 8

mov r12, rdi
mov r15, rcx
xor rbx, rbx
mov bl, dl

;avanzo las filas correspondientes
xor rcx, rcx
mov cl, sil
mov rax, 255
mul ecx
imul rax, 8
add r12, rax
;avanzo las columnas correspondientes
imul rbx, 8
add r12, rbx

mov rdi, [r12]

;chequeo si no hay unidad en la pos
cmp rdi, 0
je fin

;ahora chequeo si la unidad tiene más de una ref
cmp BYTE [rdi + ATTACKUNIT_OFFSET_REF], 1

je modificar_unidad

;armo una nueva instancia
mov rdi, ATTACKUNIT_SIZE
call malloc

mov r14, rax
mov r13, [r12]
;asigno referencias
sub BYTE [r13 + ATTACKUNIT_OFFSET_REF], 1 
mov BYTE [r14 + ATTACKUNIT_OFFSET_REF], 1
;copio el combustible
mov cx, WORD [r13 + ATTACKUNIT_OFFSET_COMBUSTIBLE]
mov WORD [r14 + ATTACKUNIT_OFFSET_COMBUSTIBLE], cx
;copio el string
mov rdi, r14
mov rsi, [r12]
call strcpy
;reemplazo la unidad por la nueva instancia
mov [r12], r14

;y ahora ya puedo modificar la instancia
mov rdi, [r12]
modificar_unidad:
call r15

fin:
add rsp, 8
pop r15
pop r14
pop r13
pop r12
pop rbx
pop rbp
	ret
