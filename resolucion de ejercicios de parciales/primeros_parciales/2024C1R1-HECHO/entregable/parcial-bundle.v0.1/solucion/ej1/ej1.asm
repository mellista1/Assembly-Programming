extern free
extern malloc
extern printf
extern strlen

section .rodata
porciento_ese: db "%s", 0

section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; El tipo de los `texto_cualquiera_t` que son cadenas de caracteres clásicas.
TEXTO_LITERAL       EQU 0
; El tipo de los `texto_cualquiera_t` que son concatenaciones de textos.
TEXTO_CONCATENACION EQU 1

; Un texto que puede estar compuesto de múltiples partes. Dependiendo del campo
; `tipo` debe ser interpretado como un `texto_literal_t` o un
; `texto_concatenacion_t`.
;
; Campos:
;   - tipo: El tipo de `texto_cualquiera_t` en cuestión (literal o
;           concatenación).
;   - usos: Cantidad de instancias de `texto_cualquiera_t` que están usando a
;           este texto.
;
; Struct en C:
;   ```c
;   typedef struct {
;       uint32_t tipo;
;       uint32_t usos;
;       uint64_t unused0; // Reservamos espacio
;       uint64_t unused1; // Reservamos espacio
;   } texto_cualquiera_t;
;   ```
TEXTO_CUALQUIERA_OFFSET_TIPO EQU 0
TEXTO_CUALQUIERA_OFFSET_USOS EQU 4 
TEXTO_CUALQUIERA_SIZE        EQU 24

; Un texto que tiene una única parte la cual es una cadena de caracteres
; clásica.
;
; Campos:
;   - tipo:      El tipo del texto. Siempre `TEXTO_LITERAL`.
;   - usos:      Cantidad de instancias de `texto_cualquiera_t` que están
;                usando a este texto.
;   - tamanio:   El tamaño del texto.
;   - contenido: El texto en cuestión como un array de caracteres.
;
; Struct en C:
;   ```c
;   typedef struct {
;       uint32_t tipo;
;       uint32_t usos;
;       uint64_t tamanio;
;       const char* contenido;
;   } texto_literal_t;
;   ```
TEXTO_LITERAL_OFFSET_TIPO      EQU 0
TEXTO_LITERAL_OFFSET_USOS      EQU 4
TEXTO_LITERAL_OFFSET_TAMANIO   EQU 8
TEXTO_LITERAL_OFFSET_CONTENIDO EQU 16
TEXTO_LITERAL_SIZE             EQU 24

; Un texto que es el resultado de concatenar otros dos `texto_cualquiera_t`.
;
; Campos:
;   - tipo:      El tipo del texto. Siempre `TEXTO_CONCATENACION`.
;   - usos:      Cantidad de instancias de `texto_cualquiera_t` que están
;                usando a este texto.
;   - izquierda: El tamaño del texto.
;   - derecha:   El texto en cuestión como un array de caracteres.
;
; Struct en C:
;   ```c
;   typedef struct {
;       uint32_t tipo;
;       uint32_t usos;
;       texto_cualquiera_t* izquierda;
;       texto_cualquiera_t* derecha;
;   } texto_concatenacion_t;
;   ```
TEXTO_CONCATENACION_OFFSET_TIPO      EQU 0
TEXTO_CONCATENACION_OFFSET_USOS      EQU 4
TEXTO_CONCATENACION_OFFSET_IZQUIERDA EQU 8
TEXTO_CONCATENACION_OFFSET_DERECHA   EQU 16
TEXTO_CONCATENACION_SIZE             EQU 24

; Muestra un `texto_cualquiera_t` en la pantalla.
;
; Parámetros:
;   - texto: El texto a imprimir.
global texto_imprimir
texto_imprimir:
	; Armo stackframe
	push rbp
	mov rbp, rsp

	; Guardo rdi
	sub rsp, 16
	mov [rbp - 8], rdi

	; Este texto: ¿Literal o concatenacion?
	cmp DWORD [rdi + TEXTO_CUALQUIERA_OFFSET_TIPO], TEXTO_LITERAL
	je .literal
.concatenacion:
	; texto_imprimir(texto->izquierda)
	mov rdi, [rdi + TEXTO_CONCATENACION_OFFSET_IZQUIERDA]
	call texto_imprimir

	; texto_imprimir(texto->derecha)
	mov rdi, [rbp - 8]
	mov rdi, [rdi + TEXTO_CONCATENACION_OFFSET_DERECHA]
	call texto_imprimir

	; Terminamos
	jmp .fin

.literal:
	; printf("%s", texto->contenido)
	mov rsi, [rdi + TEXTO_LITERAL_OFFSET_CONTENIDO]
	mov rdi, porciento_ese
	mov al, 0
	call printf

.fin:
	; Desarmo stackframe
	mov rsp, rbp
	pop rbp
	ret

; Libera un `texto_cualquiera_t` pasado por parámetro. Esto hace que toda la
; memoria usada por ese texto (y las partes que lo componen) sean devueltas al
; sistema operativo.
;
; Si una cadena está siendo usada por otra entonces ésta no se puede liberar.
; `texto_liberar` notifica al usuario de esto devolviendo `false`. Es decir:
; `texto_liberar` devuelve un booleando que representa si la acción pudo
; llevarse a cabo o no.
;
; Parámetros:
;   - texto: El texto a liberar.
global texto_liberar
texto_liberar:
	; Armo stackframe
	push rbp
	mov rbp, rsp

	; Guardo rdi
	sub rsp, 16
	mov [rbp - 8], rdi

	; ¿Nos usa alguien?
	cmp DWORD [rdi + TEXTO_CUALQUIERA_OFFSET_USOS], 0
	; Si la rta es sí no podemos liberar memoria aún
	jne .fin_sin_liberar

	; Este texto: ¿Es concatenacion?
	cmp DWORD [rdi + TEXTO_CUALQUIERA_OFFSET_TIPO], TEXTO_LITERAL
	; Si no es concatenación podemos liberarlo directamente
	je .fin
.concatenacion:
	; texto->izquierda->usos--
	mov rdi, [rdi + TEXTO_CONCATENACION_OFFSET_IZQUIERDA]
	dec DWORD [rdi + TEXTO_CUALQUIERA_OFFSET_USOS]
	; texto_liberar(texto->izquierda)
	call texto_liberar

	; texto->derecha->usos--
	mov rdi, [rbp - 8]
	mov rdi, [rdi + TEXTO_CONCATENACION_OFFSET_DERECHA]
	dec DWORD [rdi + TEXTO_CUALQUIERA_OFFSET_USOS]
	; texto_liberar(texto->derecha)
	call texto_liberar

	; Terminamos
	jmp .fin

.fin:
	; Liberamos el texto que nos pasaron por parámetro
	mov rdi, [rbp - 8]
	call free

.fin_sin_liberar:
	; Desarmo stackframe
	mov rsp, rbp
	pop rbp
	ret

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - texto_literal
;   - texto_concatenar
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Crea un `texto_literal_t` que representa la cadena pasada por parámetro.
;
; Debe calcular la longitud de esa cadena.
;
; El texto resultado no tendrá ningún uso (dado que es un texto nuevo).
;
; Parámetros:
;   - texto: El texto que debería ser representado por el literal a crear.
global texto_literal
texto_literal: ;rdi = char* contenido
push rbp
mov rbp, rsp
push r12
push r13

mov r12, rdi
mov rdi, TEXTO_LITERAL_SIZE
call malloc
mov r13, rax
mov DWORD[r13 + TEXTO_LITERAL_OFFSET_TIPO], TEXTO_LITERAL
mov QWORD[r13 + TEXTO_LITERAL_OFFSET_CONTENIDO], r12
mov DWORD[r13 + TEXTO_LITERAL_OFFSET_USOS], 0x0

mov rdi, r12
xor r8, r8
loop_contar_caracteres:
	cmp BYTE [rdi], 0
	je fin_loop_contar_caracteres
	inc r8
	inc rdi
	jmp loop_contar_caracteres

fin_loop_contar_caracteres:
	mov QWORD[r13 + TEXTO_LITERAL_OFFSET_TAMANIO], r8
	inc r8 ;por el último caracter '\0'

xor rax, rax
mov rax, r13
pop r13
pop r12
pop rbp
ret

; Crea un `texto_concatenacion_t` que representa la concatenación de ambos
; parámetros.
;
; Los textos `izquierda` y `derecha` serán usadas por el resultado, por lo que
; sus contadores de usos incrementarán.
;
; Parámetros:
;   - izquierda: El texto que debería ir a la izquierda.
;   - derecha:   El texto que debería ir a la derecha.
global texto_concatenar
texto_concatenar: ;rdi = texto_cualquiera_t* izquierda, rsi = texto_cualquiera_t* derecha
push rbp
mov rbp, rsp
push r12
push r13
push r14
sub rsp, 8
mov r12, rdi
mov r13, rsi

mov rdi, TEXTO_CONCATENACION_SIZE
call malloc

mov r14, rax
mov DWORD [r14 + TEXTO_CONCATENACION_OFFSET_TIPO], TEXTO_CONCATENACION
mov DWORD [r14 + TEXTO_CONCATENACION_OFFSET_USOS], 0
mov QWORD [r14 + TEXTO_CONCATENACION_OFFSET_IZQUIERDA], r12
mov QWORD [r14 + TEXTO_CONCATENACION_OFFSET_DERECHA], r13

add DWORD[r12 + TEXTO_CUALQUIERA_OFFSET_USOS], 1
add DWORD[r13 + TEXTO_CUALQUIERA_OFFSET_USOS], 1

xor rax, rax
mov rax, r14
add rsp, 8
pop r14
pop r13
pop r12
pop rbp
ret

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - texto_tamanio_total
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Calcula el tamaño total de un `texto_cualquiera_t`. Es decir, suma todos los
; campos `tamanio` involucrados en el mismo.
;
; Parámetros:
;   - texto: El texto en cuestión.
global texto_tamanio_total
texto_tamanio_total: ;rdi = texto_cualquiera* texto
push rbp
mov rbp, rsp
push r12
push r13

mov r12, rdi
cmp DWORD [r12 + TEXTO_CUALQUIERA_OFFSET_TIPO], TEXTO_LITERAL
jne caso_texto_concatenacion
xor rax, rax
mov rax, [r12 + TEXTO_LITERAL_OFFSET_TAMANIO]
jmp fin_tamanio

caso_texto_concatenacion:
	mov rdi, [r12 + TEXTO_CONCATENACION_OFFSET_IZQUIERDA]
	call texto_tamanio_total
	mov r13, rax

	mov rdi, [r12 + TEXTO_CONCATENACION_OFFSET_DERECHA]
	call texto_tamanio_total
	add rax, r13

fin_tamanio:
pop r13
pop r12
pop rbp
ret

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - texto_chequear_tamanio
global EJERCICIO_1C_HECHO
EJERCICIO_1C_HECHO: db TRUE; Cambiar por `TRUE` para correr los tests.

; Chequea si los tamaños de todos los nodos literales internos al parámetro
; corresponden al tamaño de la cadenas que apuntadan.
;
; Es decir: si los campos `tamanio` están bien calculados.
;
; Parámetros:
;   - texto: El texto verificar.
global texto_chequear_tamanio
texto_chequear_tamanio: ; rdi = texto_cualquiera_t* texto 
push rbp
mov rbp, rsp
push r12
push r13
push r14
sub rsp, 8

mov r12, rdi
mov r13, TRUE

cmp DWORD [r12 + TEXTO_CUALQUIERA_OFFSET_TIPO], TEXTO_LITERAL
jne chequear_tamanios_texto_concatenacion
mov rdi, [r12 + TEXTO_LITERAL_OFFSET_CONTENIDO]
call strlen
cmp rax, [r12 + TEXTO_LITERAL_OFFSET_TAMANIO]
je fin_chequear_tamanios
mov r13, FALSE
jmp fin_chequear_tamanios

chequear_tamanios_texto_concatenacion:
mov rdi, [r12 + TEXTO_CONCATENACION_OFFSET_IZQUIERDA]
call texto_chequear_tamanio
mov r13, rax
mov rdi, [r12 + TEXTO_CONCATENACION_OFFSET_DERECHA]
call texto_chequear_tamanio
and r13, rax

fin_chequear_tamanios:
mov rax, r13
add rsp, 8
pop r14
pop r13
pop r12
pop rbp
ret
