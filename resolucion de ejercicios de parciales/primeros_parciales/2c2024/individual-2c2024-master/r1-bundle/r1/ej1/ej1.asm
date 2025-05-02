extern malloc

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

TAM_FILA_MAPA EQU 255
TAM_PUNTERO EQU 8
TAM_STRUCT EQU 16
OFFSET_CLASE EQU 0
OFFSET_COMBUSTIBLE EQU 12
OFFSET_REFERENCES EQU 14



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
EJERCICIO_1C_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global optimizar
optimizar:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi = mapa_t           mapa
	; rsi = attackunit_t*    compartida
	; rdx = uint32_t*        fun_hash(attackunit_t*)


	;NOTA: La implementación en asm está basada en la implementación en C. Los comentarios usan C como guía

	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	push rsi ;pusheo compartida -> lo necesito en la pila, porque no me alcanzan los registros no volatiles
			;faltando 20 minutos para entregar noté que no era necesario tantos ciclo. No llego a corregirilo, pero puedo hacer un único ciclo de 255*255 iteraciones en total. 
			;cada posicion guarda un puntero. Así que podía avanzar de 8 bytes. 
	mov r12, rdi ; r12 = mapa_t mapa
	mov r13, rsi ; r13 = attackunit_t* compartida
	mov r14, rdx ; r14 = uint32_t (*fun_hash)(attackunit_t*)

	mov rbx, 255
	mov r15, 255

	ciclo1: 
	xor rcx, rcx
	cmp rbx, rcx ; rbx = i
	je fin

	ciclo2:
	xor rcx, rcx
	cmp r15, rcx ; r15 = j
	je siguiente_i 

	xor rcx, rcx
	cmp r12, rcx ; if (mapa[i][j] != NULL)
	je siguiente 

	call r14
	;rax = h
	mov r13, rax
	mov rdi, [rsp]
	call r14
	;rax = fun_hash(compartida);

	cmp r14, rax
	jne siguiente

	mov rcx, [rsp]
	cmp r12, rcx  ;if (mapa[i][j] != compartida)
	jne siguiente

	mov r12, [rsp]
	mov cl, byte [r12 + OFFSET_REFERENCES]
	inc cl
	mov byte [r12 + OFFSET_REFERENCES], cl

	siguiente:
	dec r15
	add r12, 8
	jmp ciclo2

	siguiente_i:
	dec rbx
	mov r15, 255
	jmp ciclo1


	fin:
	pop rsi
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

global contarCombustibleAsignado
contarCombustibleAsignado:
	; rdi = mapa_t           mapa
	; rsi = uint16_t*        fun_combustible(char*)

	push rbp
	mov rbp, rsp

	push rbx
	push r12
	push r13
	push r14


	mov rbx, rdi ; rbx = mapa
	mov r12, rsi ; r12 = (*fun_combustible)(char*)

	xor r13, r13 ; r13 = res ->todavia no uso rax porque haré llamados a la función

	mov r14, 255
	mov rax, 255
	mul r14 ;me di cuenta que son todas posiciones una al lado de la otra. Así que puedo usar un unico ciclo

	ciclo3:
	xor rcx, rcx
	cmp r14, rcx
	je fin3

	xor rcx, rcx
	cmp rbx, rcx
	je siguiente3

	mov rdi, [rbx+OFFSET_CLASE]
	call r12
	;rax = uint16_t base
	mov cx, word [rbx + OFFSET_COMBUSTIBLE]
	cmp ax, cx
	jg siguiente
	sub cx, ax
	add r13, rcx

	siguiente3:
	dec r14
	add rbx, 8
	jmp ciclo3

	fin3:
	mov rax, r13
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret

global modificarUnidad
modificarUnidad:
	; rdi = mapa_t           mapa
	; rsi  = uint8_t          x
	; rdx  = uint8_t          y
	; rcx = void*            fun_modificar(attackunit_t*)

	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8

	mov rbx, rdi ; rbx = mapa
	mov r12, rsi ; r12 = x
	mov r13, rdx ; r13 = y
	mov r14, rcx ; r14 = (*fun_modificar)(attackunit_t*)


	;tengo que hacer esto cada vez para acceder a mapa[x][y] no lo guardé en un registro no volatil.
	mov rax, TAM_FILA_MAPA
	mov r8, r12
	mul r8
	mov rdi, [rbx + r8] ;rdi = mapa[x]
	mov r9, r13
	mov rax, TAM_PUNTERO
	mul r9
	add rdi, r9 ;rdi = mapa[x][y]
	
	
	
	xor rcx, rcx
	cmp rdi, rcx
	je fin4

	mov bl, 1
	mov cl, byte [rdi + OFFSET_REFERENCES]
	cmp bl, cl
	jg caso_else

	mov rdi, TAM_STRUCT
	call malloc
	
	mov r15, rax ;r15 = attackunit_t* nueva_unidad

	xor rcx, rcx
	ciclo4:
	cmp rcx, 11
	je fin_ciclo

	mov rax, TAM_FILA_MAPA
	mov r8, r12
	mul r8
	mov rdi, [rbx + r8] ;rdi = mapa[x]
	mov r9, r13
	mov rax, TAM_PUNTERO
	mul r9
	add rdi, r9 ;rdi = mapa[x]
	
	mov r8b, byte [rdi + OFFSET_CLASE]
	add r8, rcx ;r8 =  mapa[x][y]->clase[i]

	add cl, OFFSET_CLASE
	mov [r15 + rcx], r8 ; nueva_unidad->clase[i] = mapa[x][y]->clase[i];
	
	inc rcx
	jmp ciclo4


	fin_ciclo:
	mov sil, 1
	mov byte [r15 + OFFSET_REFERENCES], sil
	mov esi, [rdi + OFFSET_COMBUSTIBLE] ;esi =  mapa[x][y]->combustible
	mov [r15 + OFFSET_COMBUSTIBLE], esi

	mov rdi, r15
	call r14

	
	mov rax, TAM_FILA_MAPA
	mov r8, r12
	mul r8
	mov rdi, [rbx + r8] ;rdi = mapa[x]
	mov r9, r13
	mov rax, TAM_PUNTERO
	mul r9
	add rdi, r9 ;rdi = mapa[x][y]

	mov sil, [rdi + OFFSET_REFERENCES]
	dec sil
	mov [rdi + OFFSET_REFERENCES], sil
	mov [rdi], r15
	jmp fin4
	
	caso_else:


	mov rax, TAM_FILA_MAPA
	mov r8, r12
	mul r8
	mov rdi, [rbx + r8] ;rdi = mapa[x]
	mov r9, r13
	mov rax, TAM_PUNTERO
	mul r9
	add rdi, r9 ;rdi = mapa[x][y]
	
	call r14

	fin4:
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret
