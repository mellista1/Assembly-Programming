extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_using_c
global alternate_sum_4_using_c_alternative
global alternate_sum_8
global product_2_f
global product_9_f

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4:
  sub EDI, ESI
  add EDI, EDX
  sub EDI, ECX

  mov EAX, EDI
  ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4_using_c:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  push R12
  push R13	; preservo no volatiles, al ser 2 la pila queda alineada

  mov R12D, EDX ; guardo los parámetros x3 y x4 ya que están en registros volátiles
  mov R13D, ECX ; y tienen que sobrevivir al llamado a función

  call restar_c 
  ;recibe los parámetros por EDI y ESI, de acuerdo a la convención, y resulta que ya tenemos los valores en esos registros
  
  mov EDI, EAX ;tomamos el resultado del llamado anterior y lo pasamos como primer parámetro
  mov ESI, R12D
  call sumar_c

  mov EDI, EAX
  mov ESI, R13D
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  pop R13 ;restauramos los registros no volátiles
  pop R12
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


alternate_sum_4_using_c_alternative:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  sub RSP, 16 ; muevo el tope de la pila 8 bytes para guardar x4, y 8 bytes para que quede alineada

  mov [RBP-8], RCX ; guardo x4 en la pila

  push RDX  ;preservo x3 en la pila, desalineandola
  sub RSP, 8 ;alineo
  call restar_c 
  add RSP, 8 ;restauro tope
  pop RDX ;recupero x3
  
  mov EDI, EAX
  mov ESI, EDX
  call sumar_c

  mov EDI, EAX
  mov ESI, [RBP - 8] ;leo x4 de la pila
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  add RSP, 16 ;restauro tope de pila
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9], x7[pila], x8[pila]
alternate_sum_8:
	push rbp
  mov rbp, rsp

  sub rdi, rsi
  add rdi, rdx
  sub rdi, rcx
  add rdi, r8
  sub rdi, r9

  mov esi, [rbp + 16]
  add rdi, rsi
  mov esi, [rbp + 24]
  sub rdi, rsi

  mov rax, rdi

  pop rbp
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[rdi], x1[esi], f1[xmm0]
product_2_f:

    CVTSI2SD xmm1, esi         
    CVTSS2SD xmm0, xmm0
    mulsd xmm0, xmm1           
    CVTSD2SI eax, xmm0       
    ;dec eax
    mov [rdi], eax             
    ret

  ;CONSULTAAAAAARRRRRRRRRs


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[esi], f1[xmm0], x2[edx], f2[xmm1], x3[ecx], f3[xmm2], x4[r8], f4[xmm3]
;	, x5[r9], f5[xmm4], x6[pila], f6[xmm5], x7[pila], f7[xmm6], x8[pila], f8[xmm7],
;	, x9[pila], f9[pila]


;pila
;+48     f9 
;+40     x9
;+32     x8
;+24     x7
;+16     x6 
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en doubles
	CVTSS2SD xmm0, xmm0
  CVTSS2SD xmm1, xmm1
  CVTSS2SD xmm2, xmm2
  CVTSS2SD xmm3, xmm3
  CVTSS2SD xmm4, xmm4
  CVTSS2SD xmm5, xmm5
  CVTSS2SD xmm6, xmm6
  CVTSS2SD xmm7, xmm7


	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	mulsd xmm0, xmm1
  mulsd xmm0, xmm2
  mulsd xmm0, xmm3
  mulsd xmm0, xmm4
  mulsd xmm0, xmm5
  mulsd xmm0, xmm6
  mulsd xmm0, xmm7
  

  ;convierto el que faltaba
	cvtss2sd xmm1, [rbp+0x30] ;48 = 0x30
	;multiplico el que faltaba
	mulsd xmm0, xmm1 

	; convertimos los enteros en doubles y los multiplicamos por xmm0.
  pxor xmm1, xmm1
  CVTSI2SD xmm1, esi
  mulsd xmm0, xmm1 

  pxor xmm1, xmm1
  CVTSI2SD xmm1, edx
  mulsd xmm0, xmm1 

  pxor xmm1, xmm1
  CVTSI2SD xmm1, ecx
  mulsd xmm0, xmm1 

  pxor xmm1, xmm1
  CVTSI2SD xmm1, r8
  mulsd xmm0, xmm1 

  pxor xmm1, xmm1
  CVTSI2SD xmm1, r9
  mulsd xmm0, xmm1 

  pxor xmm1, xmm1
  CVTSI2SD xmm1, [rbp + 16]
  mulsd xmm0, xmm1 

  pxor xmm1, xmm1
  CVTSI2SD xmm1, [rbp + 24]
  mulsd xmm0, xmm1 

  pxor xmm1, xmm1
  CVTSI2SD xmm1, [rbp + 32]
  mulsd xmm0, xmm1 

  pxor xmm1, xmm1
  CVTSI2SD xmm1, [rbp + 40]
  mulsd xmm0, xmm1 

  movq [rdi], xmm0 

	; epilogo
	pop rbp
	ret

