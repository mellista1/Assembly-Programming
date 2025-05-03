extern malloc

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
mascara_period: times 4 dd 0x00

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - unwrap
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

global modps
modps:
	;n-floor(n/m)*m
	push rbp
	mov rbp, rsp
	
	movdqu xmm2, xmm0
	divps xmm2, xmm1
	roundps xmm2, xmm2, 1
	mulps xmm2, xmm1
	subps xmm0, xmm2
	
	pop rbp
	ret

global unwrap
unwrap: ;void unwrap(float* A, float* B, uint32_t size, float period);`
	;rdi = A
	;rsi = B
	;rdx = size
	;rcx = period 

	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx 
	sub rsp,8

	;voy a hacer llamados a la funcion asi que mecesito preservar las variables
	mov r12, rdi
	mov r13, rsi
	mov r14, rdx 
	mov r15, rcx


;dejo el primer byte identico
	add r12, 1
	add r13, 1
	

	;xmm11 = acumulador de correciones
	xorps xmm11, xmm11
	pxor rbx, rbx

	ciclo:
	cmp r14, rbx
	je fin

	;1. hago la resta
	movaps xmm0, [r12 + rbx*4] 
	movapd xmm1, [r12 + rbx*3]
    movaps xmm2, xmm0 
    subps xmm2, xmm1    ;xmm2 =  A[i] - A[i-1]
	

	movaps xmm3, r15
	movaps xmm4, [mascara_period]
	shufps xmm3, xmm4 ; xmm3 = period|period|period|period|
	movaps xmm5, xmm3 ; xmm 5 = copio period

	psrld xmm3, 1 ; xmm3 = period/2|period/2|period/2|period/2|

	movaps xmm4, xmm2; copio xmm4 =  A[i] - A[i-1] = dd
	
	ADDPS xmm2, xmm3 ;xmm2 = (dd + period/2)
	
	;2. calculo mod periodo
	movaps xmm7, xmm2 ;porque lo voy a perder
	
	movaps xmm0, xmm2 ;suma
	movaps xmm1, xmm5 ;period

    call modps               ; xmm0 = (dd + period/2) mod period

    ;3. calculo correcion de fase
	subps xmm0, xmm3         ; xmm0 = ddmod - period/2

	;4. corrijo ph_correct
    movaps xmm4, xmm0        
    xorps xmm4, xmm4         
    cmpps xmm4, xmm7, 0x02   ; comparo dd con period/2 nota: creo que es 0x02 pero no estoy segura. 
    andps xmm3, xmm4  

	;5. acumulo las correciones en xmm11 
	addps xmm11, xmm3 

    addps xmm0, xmm11 ; 

	;6. guardamos `B[i] = A[i] + ph_cumsum[i]`
    movaps [r13 + rbx * 4], xmm0       ; Guardar en B

	add r9, 4
	jmp ciclo
    

	fin:
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp	

	ret

