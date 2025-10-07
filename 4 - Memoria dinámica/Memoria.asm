extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b) -> *a = rdi , *b = rsi
strCmp:
	push rbp
	mov rbp, rsp

loop:
	mov dl, BYTE [rdi] ; a
	mov cl, BYTE [rsi] ; b

	cmp dl, cl
	je equal
	jg greater
	jl lower

greater: ;(A > B)
	mov rax,-1
	jmp end


lower: ;(A < B)
	mov rax,1
	jmp end
	
equal: ;(A == B)
	cmp dl,0 ;Me fijo si dl es el final del string, recordar que dl=cl debido al jump
	je equalStrings
	inc rdi
	inc rsi
	jmp loop

equalStrings: ;(A[] == B[])
	mov rax,0
	jmp end

end:
	pop rbp
	ret

; char* strClone(char* a) *a = [rdi]
strClone: 
	push rbp
	mov rbp, rsp
	push r12
	push r13 ;pila alineada.

	mov r12, rdi ;preservo el puntero a.
	
	;calculo la longitud del array
	xor rsi, rsi ;rsi = total de elementos
	
	loop2:
		cmp BYTE[rdi], 0
		je clonar_array
		
		inc rsi

		add rdi, 1
		jmp loop2


	;hago la copia del array
	clonar_array:
		inc rsi
		xor rdi, rdi
		mov rdi, rsi ;usando la convensión de llamadas, paso el valor del tamaño a través de rdi. 
		call malloc 
		mov r13, rax ;usando la convensión de llamadas, en rax = puntero al nuevo array. Preservo la dirección que debo retornar al final.
	
	copiar_chars:
		cmp BYTE[r12], 0
		je fin2

		mov dl, BYTE[r12] 
		mov BYTE[rax], dl

		inc rax
		inc r12
		jmp copiar_chars


	fin2:
	mov dl, BYTE[r12]
	mov BYTE[rax], dl
	mov rax, r13

	pop r13
	pop r12
	pop rbp
	ret

; void strDelete(char* a) -> *a = [rdi]
strDelete:
	push rbp
	mov rbp, rsp

	call free

	pop rbp
	ret

; void strPrint(char* a, FILE* pFile) -> *a = [rdi] , *pFile = [rsi]
strPrint:
	push rbp
	mov rbp, rsp

	mov rcx, rdi
	mov rdx, rsi

	mov rdi, rcx
	mov rsi, rdx
	
	call fprintf

	pop rbp
	ret
	

; uint32_t strLen(char* a)
strLen:
	push rbp
	mov rbp, rsp

	xor eax, eax

	loop4:
		cmp BYTE[rdi], 0
		je fin4		
		inc eax
		add rdi, 1
		jmp loop4

	fin4:

	pop rbp
	ret


