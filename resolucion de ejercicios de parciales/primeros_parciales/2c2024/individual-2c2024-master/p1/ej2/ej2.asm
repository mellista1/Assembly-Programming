section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el filtro
ALIGN 16

rojos:  db 0x00,0x80,0x80,0x80,0x04,0x80,0x80,0x80 ; |r4|r3|r2|r1|
        db 0x08,0x80,0x80,0x80,0x0C,0x80,0x80,0x80


verdes:  db 0x01,0x80,0x80,0x80,0x05,0x80,0x80,0x80 
         db 0x09,0x80,0x80,0x80,0x0D,0x80,0x80,0x80


azules:  db 0x02,0x80,0x80,0x80,0x06,0x80,0x80,0x80
         db 0x0A,0x80,0x80,0x80,0x0E,0x80,0x80,0x80

mascara: db 0x00,0x80,0x80,0x80,0x04,0x80,0x80,0x80 
         db 0x08,0x80,0x80,0x80,0x0C,0x80,0x80,0x80s

mascara2:db 0x80,0x00,0x80,0x80,0x80,0x04,0x80,0x80 
         db 0x80,0x08,0x80,0x80,0x80,0x0C,0x80,0x80

mascara3:db 0x80,0x80,0x00,0x80,0x80,0x80,0x04,0x80 
         db 0x80,0x80,0x08,0x80,0x80,0x80,0x0C,0x80

cuatro_ciento_venti_ocho_de_dd: times 4 dd 128

cuatro_uno_sobre_treintaydos_de_dd: times 4 dd 0.03125

cuatro_doscientos_ciencuenta_y_cinco_de_dd: timer 4 dd 255

mascara_Alfa: times 4 db 0x00, 0x00, 0x00, 0xFF
;-----------------------------------------------------------------------------------------------------------------------------------------------------------
;mascaras para ejerb





section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 2A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej2a
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 2B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej2b
global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 2C (opcional) como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej2c
global EJERCICIO_2C_HECHO
EJERCICIO_2C_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Dada una imagen origen ajusta su contraste de acuerdo a la parametrización
; provista.
;
; Parámetros:
;   - dst:    La imagen destino. Es RGBA (8 bits sin signo por canal).
;   - src:    La imagen origen. Es RGBA (8 bits sin signo por canal).
;   - width:  El ancho en píxeles de `dst`, `src` y `mask`.
;   - height: El alto en píxeles de `dst`, `src` y `mask`.
;   - amount: El nivel de intensidad a aplicar.
global ej2a
ej2a: ;registos: dts[rdi], src[rsi], width[edx], height[ecx], amount[r8b]

;epilogo
push rbp
mov rbp, rsp

mov rax, rcx ;Muevo la altura a rax
mul rdx ; rax = rax * rdx (width * height)
mov rcx , rax  ; (width * height) / 16 tomo 4 pixeles a la vez


;Muevo mascaras
movdqu xmm0, [rojos] 
movdqu xmm1, [verdes]
movdqu xmm2, [azules]
movdqu xmm8, [cuatro_ciento_venti_ocho_de_dd]

;armo la mascara con el contraste
movd xmm9, [r8b]    
pshufd xmm9, xmm9, 0x00  ;|amount|amount|amount|amount|

movdqu xmm10, [cuatro_uno_sobre_treintaydos_de_dd]
movdqu xmm11, [cuatro_doscientos_ciencuenta_y_cinco_de_dd]



ciclo:
    movdqu xmm3, [rsi]  ; | r1 | g1 | b1 | a1 | r2 | g2 | b2 | a2 | r3 | g3 | b3 | a3 | r4 | g4 | b4 | a4 |
    
	;Separo color x color
    movdqu xmm5, xmm3 
    pshufb xmm5 , xmm0 ; |r1|r2|r3|r4|

    movdqu xmm6, xmm3 
    pshufb xmm6 , xmm1 ; |g1|g2|g3|g4|

    movdqu xmm7, xmm3 
    pshufb xmm7 , xmm2 ; |b1|b2|b3|b4|

	psubd xmm5, xmm8 ;|r1-128|r2-128|r3-128|r4-128|
	psubd xmm6, xmm8 ;|g1-128|g2-128|g3-128|g4-128|
	psubd xmm7, xmm8 ;|b1-128|b2-128|b3-128|b4-128|

	; los paso a float
    cvtdq2ps xmm5, xmm5
	cvtdq2ps xmm6, xmm6
	cvtdq2ps xmm7, xmm7

	divps xmm5,xmm9 
	divps xmm6, xmm9
	divps xmm7, xmm9

	;los paso a int
    cvttps2dq xmm5, xmm5
	cvttps2dq xmm6, xmm6
	cvttps2dq xmm7, xmm7


	pmulld xmm5, xmm9
	pmulld xmm6, xmm9
	pmulld xmm7, xmm9

	paddd xmm5, xmm8
	paddd xmm6, xmm8
	paddd xmm7, xmm8

	;ahora comparo con 0 y con 255
	;proceso los rojos
	xor xmm13, xmm13
	movdqu xmm12, xmm5
	pminsd xmm5, xmm12 
	pmaxsd xmm5, xmm13

	;xmm5 = |sat(r1)|sat(r2)|sat(r3)|sat(r4)|

	;proceso los verdes
	xor xmm13, xmm13
	xor xmm12, xmm12
	movdqu xmm12, xmm6
	pminsd xmm6, xmm12 
	pmaxsd xmm6, xmm13

	;xmm6 = sat(g1)|sat(g2)|sat(g3)|sat(g4)|

	;proceso los azules
	xor xmm13, xmm13
	xor xmm12, xmm12
	movdqu xmm12, xmm7
	pminsd xmm7, xmm12 
	pmaxsd xmm7, xmm13
	;xmm7 = sat(b1)|sat(b2)|sat(b3)|sat(b4)|

	;ahora ya puedo acomodar todo nuevamente
	xor xmm12, xmm12
  	movdqu xmm12, [mascara]
    pshufb xmm5, xmm12
    movdqu xmm12, [mascara2]
    pshufb xmm6, xmm12
    movdqu xmm12, [mascara3]
    pshufb xmm7, xmm12
    
    por xmm5, xmm6
    por xmm5, xmm7

    movdqu xmm12, [mascara_Alfa]
    por xmm5, xmm12

    movdqu [rdi], xmm5
    add rsi, 16
    add rdi, 16
    sub rcx, 4
    cmp rcx, 0
    jnz ciclo
    pop rbp
    ret
;----------------------------------------------------------------------------------------------------------------------------------

; Dada una imagen origen ajusta su contraste de acuerdo a la parametrización
; provista.
;
; Parámetros:
;   - dst:    La imagen destino. Es RGBA (8 bits sin signo por canal).
;   - src:    La imagen origen. Es RGBA (8 bits sin signo por canal).
;   - width:  El ancho en píxeles de `dst`, `src` y `mask`.
;   - height: El alto en píxeles de `dst`, `src` y `mask`.
;   - amount: El nivel de intensidad a aplicar.
;   - mask:   Una máscara que regula por cada píxel si el filtro debe o no ser
;             aplicado. Los valores de esta máscara son siempre 0 o 255.
global ej2b
ej2b: ;registos: dts[rdi], src[rsi], width[edx], height[ecx], amount[r8b], mask*[r9]

;ACLARACIÓN AL CORRECTOR: Presiento que no voy a llegar con el tiempo a codear todo, asi que la idea es la siguiente. 
;Para procesar varios pixeles a la vez, utilizo la misma metodología que en el ejercicio anterior. Calculo todo de la misma manera. Pero al final, solo guardo los resultados nuevos en los lugares 
;que me indique mas. Entonces mi objetivo es modificar el final del codigo, es decir, al momento de aplicar los shuffles, puedo agregar adicionalmente pblendd y mezclar lso resultados de los pixeles
;entre los resultados nuevos y los viejos valores.
;epilogo
push rbp
mov rbp, rsp

mov rax, rcx ;Muevo la altura a rax
mul rdx ; rax = rax * rdx (width * height)
mov rcx , rax  ; (width * height) / 16 tomo 4 pixeles a la vez


;Muevo mascaras
movdqu xmm0, [rojos] 
movdqu xmm1, [verdes]
movdqu xmm2, [azules]
movdqu xmm8, [cuatro_ciento_venti_ocho_de_dd]

;armo la mascara con el contraste
movd xmm9, [r8b]    
pshufd xmm9, xmm9, 0x00  ;|amount|amount|amount|amount|

movdqu xmm10, [cuatro_uno_sobre_treintaydos_de_dd]
movdqu xmm11, [cuatro_doscientos_ciencuenta_y_cinco_de_dd]



ciclo:
    movdqu xmm3, [rsi]  ; | r1 | g1 | b1 | a1 | r2 | g2 | b2 | a2 | r3 | g3 | b3 | a3 | r4 | g4 | b4 | a4 |
    movdqu xmm4, [rsi] ;aquí preservo los valores!!

	;Separo color x color
    movdqu xmm5, xmm3 
    pshufb xmm5 , xmm0 ; |r1|r2|r3|r4|

    movdqu xmm6, xmm3 
    pshufb xmm6 , xmm1 ; |g1|g2|g3|g4|

    movdqu xmm7, xmm3 
    pshufb xmm7 , xmm2 ; |b1|b2|b3|b4|

	psubd xmm5, xmm8 ;|r1-128|r2-128|r3-128|r4-128|
	psubd xmm6, xmm8 ;|g1-128|g2-128|g3-128|g4-128|
	psubd xmm7, xmm8 ;|b1-128|b2-128|b3-128|b4-128|

	; los paso a float
    cvtdq2ps xmm5, xmm5
	cvtdq2ps xmm6, xmm6
	cvtdq2ps xmm7, xmm7

	divps xmm5,xmm9 
	divps xmm6, xmm9
	divps xmm7, xmm9

	;los paso a int
    cvttps2dq xmm5, xmm5
	cvttps2dq xmm6, xmm6
	cvttps2dq xmm7, xmm7


	pmulld xmm5, xmm9
	pmulld xmm6, xmm9
	pmulld xmm7, xmm9

	paddd xmm5, xmm8
	paddd xmm6, xmm8
	paddd xmm7, xmm8

	;ahora comparo con 0 y con 255
	;proceso los rojos
	xor xmm13, xmm13
	movdqu xmm12, xmm5
	pminsd xmm5, xmm12 
	pmaxsd xmm5, xmm13

	;xmm5 = |sat(r1)|sat(r2)|sat(r3)|sat(r4)|

	;proceso los verdes
	xor xmm13, xmm13
	xor xmm12, xmm12
	movdqu xmm12, xmm6
	pminsd xmm6, xmm12 
	pmaxsd xmm6, xmm13

	;xmm6 = sat(g1)|sat(g2)|sat(g3)|sat(g4)|

	;proceso los azules
	xor xmm13, xmm13
	xor xmm12, xmm12
	movdqu xmm12, xmm7
	pminsd xmm7, xmm12 
	pmaxsd xmm7, xmm13
	;xmm7 = sat(b1)|sat(b2)|sat(b3)|sat(b4)|

	;Ahora debo estar atenta al momento de acomodar, pues la mask me indicará cuando aplicar el filtro, y cuando no.
	xor xmm12, xmm12
  	movdqu xmm12, [mascara]
    pshufb xmm5, xmm12
    movdqu xmm12, [mascara2]
    pshufb xmm6, xmm12
    movdqu xmm12, [mascara3]
    pshufb xmm7, xmm12
    
    por xmm5, xmm6
    por xmm5, xmm7

    movdqu xmm12, [mascara_Alfa]
    por xmm5, xmm12

	;en xmm5 tengo los valores como si hubiera aplicado el filtro a todos los pixeles.
	;en xmm4 tengo los valores como si no le hubiera aplicado el filtro a ninguno.
	xor xmm12, xmm12
	movdqu xmm12, [r9]
	;en xmm12 tengo la mask 
	pandd xmm12, xmm11
	;en xmm12 tengo 1s donde habia 255 y 0 si lo contrario
	pblendd xmm0, xmm5, xmm4, xmm12 ; mezclo los dos registros usando como criterio mask

    movdqu [rdi], xmm0 ; 
    add rsi, 16
    add rdi, 16
    sub rcx, 4
    cmp rcx, 0
    jnz ciclo
    pop rbp
    ret
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------
; [IMPLEMENTACIÓN OPCIONAL]
; El enunciado sólo solicita "la idea" de este ejercicio.
;
; Dada una imagen origen ajusta su contraste de acuerdo a la parametrización
; provista.
;
; Parámetros:
;   - dst:     La imagen destino. Es RGBA (8 bits sin signo por canal).
;   - src:     La imagen origen. Es RGBA (8 bits sin signo por canal).
;   - width:   El ancho en píxeles de `dst`, `src` y `mask`.
;   - height:  El alto en píxeles de `dst`, `src` y `mask`.
;   - control: Una imagen que que regula el nivel de intensidad del filtro en
;              cada píxel. Es en escala de grises a 8 bits por canal.
global ej2c
ej2c:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = rgba_t*  dst
	; r/m64 = rgba_t*  src
	; r/m32 = uint32_t width
	; r/m32 = uint32_t height
	; r/m64 = uint8_t* control

	ret





;Respuesta: Se puede modificar el ejercicio anterior eliminando toda la parte que decide si habilitar el filtro, o no hacerlo. Y luego, se debe realizar el recorrido por 
;control de la misma forma que se hace por la imagen. Así como separe ; |r1|r2|r3|r4|, |g1|g2|g3|g4| , |b1|b2|b3|b4| tambien puedo generar |amount1|amount2|amount3|amount4| 
;y hacer la multiplicacion segun estos datos. 