extern malloc
extern calloc


section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
ITEM_SIZE EQU 28
ITEM_OFFSET_NOMBRE EQU 0
ITEM_OFFSET_FUERZA EQU 20
ITEM_OFFSET_DURABILIDAD EQU 24


section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE; Cambiar por `TRUE` para correr los tests.

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.

global es_indice_ordenado
es_indice_ordenado: ;item_t** inventario = [rdi], uint16_t* indice = rsi, uint16_t tamanio = dx, comparador_t comparador = rcx
push rbp
mov rbp, rsp 
push rbx
push r12
push r13
push r14
push r15
;preservo los parámetros
mov r12, rdi
mov r13, rsi
xor r14, r14
mov r14w, dx
mov r15, rcx

xor rbx, rbx
mov rbx, TRUE
xor r9, r9 ;uso r9 para recorrer indice
loop_sobre_indice: 
    cmp r14w, 0
    je fin_loop_sobre_indice
    inc r9w ;pues el último elemento a comparar es el anteultimo
    cmp r9w, r14w
    je fin_loop_sobre_indice
    dec r9w
    
    mov rdi, r12
    mov rsi, r12
    xor rcx, rcx
    mov cx, WORD [r13 + r9*2] ;en cx tengo el indice
    mov ax, 8
    mul cx
    mov cx, ax
    add rdi, rcx 
    mov cx, WORD [r13 + r9*2 + 2]
    mov ax, 8
    mul cx
    mov cx, ax
    add rsi, rcx
    
    ;ahora debo pasarle el puntero a item
    xor r8, r8
    mov r8, [rsi]
    mov rsi, r8
    xor r8, r8
    mov r8, [rdi]
    mov rdi, r8

    push r9
    call r15
    pop r9
    
    cmp rax, 0x0
    je la_vista_no_esta_ordenada

    inc r9
    jmp loop_sobre_indice

la_vista_no_esta_ordenada:
    mov rbx, FALSE

fin_loop_sobre_indice:
mov rax, rbx
pop r15
pop r14
pop r13
pop r12
pop rbx
pop rbp
ret



;------------------------------------------------------------------------------------------------------------------------------------------------------




;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**

global indice_a_inventario
indice_a_inventario: ;rdi = item_t** inventario,rsi = uint16_t* indice, dx = uint16_t tamanio
push rbp
mov rbp, rsp
push r12
push r13
push r14
push r15

mov r12, rdi
mov r13, rsi
xor r14, r14
mov r14w, dx

xor rax, rax
mov ax, 8
mul dx
mov rdi, rax
call malloc

mov r15, rax
xor r9, r9
xor r8, r8
mov r8, r15
loop_creando_vista:
    cmp r9w, r14w
    je fin_loop_creando_vista 
    
    mov rdi, r12
    
    ;obtengo el indice en cx
    xor rcx, rcx
    mov cx, WORD [r13 + r9*2] 
    mov ax, 8
    mul cx
    xor rcx, rcx
    mov cx, ax
    add rdi, rcx

    mov rcx, [rdi]
    mov [r8], rcx 

    inc r9w
    add r8, 8
    jmp loop_creando_vista


fin_loop_creando_vista:
mov rax, r15
pop r15
pop r14
pop r13
pop r12
pop rbp
ret
