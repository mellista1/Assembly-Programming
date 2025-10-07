; /** defines bool y puntero **/
%define NULL 0
%define TRUE 1
%define FALSE 0

section .data

NODO_TAM EQU 32
NODO_OFFSET_NEXT EQU 0
NODO_OFFSET_PREVIOUS EQU 8
NODO_OFFSET_TYPE EQU 16
NODO_OFFSET_HASH EQU 24

LIST_TAM EQU 16
LIST_OFFSET_FIRST EQU 0
LIST_OFFSET_LAST EQU 8

section .text

global string_proc_list_create_asm
global string_proc_node_create_asm
global string_proc_list_add_node_asm
global string_proc_list_concat_asm

; FUNCIONES auxiliares que pueden llegar a necesitar:
extern malloc
extern free
extern str_concat


string_proc_list_create_asm: ;string_proc_list* string_proc_list_create(void)
push rbp
mov rbp, rsp
mov rdi, LIST_TAM
call malloc
mov QWORD [rax + LIST_OFFSET_FIRST], 0x0
mov QWORD [rax + LIST_OFFSET_LAST], 0x0
pop rbp
ret


;string_proc_node* string_proc_node_create_asm(uint8_t type, char* hash) 
string_proc_node_create_asm: ;dil = uint8_t type, rsi = char* hash
push rbp
mov rbp, rsp
push r14
push r15

xor r14, r14
mov r14b, dil
mov r15, rsi

mov rdi, NODO_TAM
call malloc

mov [rax + NODO_OFFSET_HASH], r15
mov BYTE [rax + NODO_OFFSET_TYPE], r14b
mov QWORD [rax + NODO_OFFSET_NEXT], 0x0
mov QWORD [rax + NODO_OFFSET_PREVIOUS], 0x0
pop r15
pop r14
pop rbp
ret


;void string_proc_list_add_node_asm(string_proc_list* list, uint8_t type, char* hash);
string_proc_list_add_node_asm: ;rdi = list, sil = type, rdx = hash
push rbp
mov rbp, rsp
push r14
sub rsp, 8 ;necesito alinear la pila a 16 para hacer un call

mov r14, rdi

xor rdi, rdi
mov dil, sil
mov rsi, rdx

call string_proc_node_create_asm

mov r8, [r14 + LIST_OFFSET_LAST]

cmp r8, 0x0
je agregar_primero

mov [r8 + NODO_OFFSET_NEXT], rax
mov [rax + NODO_OFFSET_PREVIOUS], r8
mov [r14 + LIST_OFFSET_LAST], rax
jmp fin

agregar_primero:
mov [r14 + LIST_OFFSET_LAST], rax
mov [r14 + LIST_OFFSET_FIRST], rax

fin:
add rsp, 8
pop r14
pop rbp
ret

;char* string_proc_list_concat_asm(string_proc_list* list, uint8_t type, char* hash)
string_proc_list_concat_asm: ;rdi = list , sil = type, rdx = hash
push rbp
mov rbp, rsp
push r13
push r14
push r15


mov r13, [rdi + LIST_OFFSET_FIRST]
xor r14, r14
mov r14b, sil
mov r15, rdx

loop: 
    cmp r13, 0x0
    je fin2
    
    xor rsi, rsi
    mov sil, [r13 + NODO_OFFSET_TYPE]
    cmp sil, r14b
    jne siguiente
    
   
    mov rsi, [r13 + NODO_OFFSET_HASH]
    mov rdi, r15
    call str_concat
    mov r15, rax

siguiente:
    mov rdx, [r13 + NODO_OFFSET_NEXT]
    mov r13, rdx
    jmp loop


fin2:
mov rax, r15
pop r15
pop r14
pop r13
pop rbp
ret
