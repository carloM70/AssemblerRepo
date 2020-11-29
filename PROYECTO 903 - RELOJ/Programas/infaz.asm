.386	;habilita las instrucciones
.387	;del coprocesador matematico
if1
			include	c:mafo.asm   
			include	c:stepin.asm			
endif
;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
;	                 definicion de constantes y simbolos
;	                 -----------------------------------
longx		equ 1024
longy		equ	768
despX		equ	longx/2		;desplazamiento en el eje x
despY		equ	longy/2		;desplazamiento en el eje y
amarillo	=	6
azul		=	9
verde		=	10
celeste		=	11
amarilloB	=	14
blanco		=	15
negro		=	0
;-------------------------------------------------------------------------
pila	segment	para stack 'stack'
		dw	64 dup(?)
pila	ends
;-------------------------------------------------------------------------
datos	segment	para 'data'
;variables a considerar en el reloj

x0		dw	?	;Puntos para la macro de bresenham
y0		dw	?
x1		dw	?
y1		dw	?
colores	db	?

vx		dw	?		;delta de 'x' y 'y' respectivamente
vy		dw	?	
caso	db	?		;en esta variable guardaremos el tipo de caso que se nos presenta de los 4 posiles
e1		dw	?		;Variables relacionadas al algoritmo
e2		dw	?
e3		dw	?
pk		dw	?	
M		dw	?

radio	dw	150,140,90,0,75,75,70,70,45,45,50,50,50,50
	;Varie el radio
Hora_old	db	0h
Min_old		db	0h
Seg_old		db	0h

corX2	dw	3 dup(10),2 dup(0),2 dup(0),2 dup(0),2 dup(0)
corY2	dw	3 dup(10),2 dup(0),2 dup(0),2 dup(0),2 dup(0)

;variables a considerar en la interfaz
color   db  ? 
radio1	dw	300,250,200
corX1	dw	3 dup(10)
corY1	dw	3 dup(10)
corX21	dw	3 dup(10)
corY21	dw	3 dup(10)
noventa	dw	90
valor	dw	?
aux		dw	?	;aux hasta 360? o 0?
factor	dw	?	;factor para conversion de theta en radianes
vian	dw	?	;video antiguo
;-------------datos para los fonts--------------------------
include c:car.asm  ; incluimos los fonts, de las letras, los numeros, y la figura 'FI'
x		dw	0
y		dw	0

datos	ends
;-------------------------------------------------------------------------
codigo	segment use16	para 'code'
program	proc	far
		assume	ss:pila,ds:datos,cs:codigo,es:datos
		push	ds
		sub		ax,ax
		push	ax
		mov		ax,datos
		mov		ds,ax
		mov		es,ax
;					CAMBIAMOS AL MODO GRAFICO		
;--------------------------------------------------------------------
		mov     ah,0fh		; Obtiene modo de video
		int     10h			; y
		mov     vian,ax		; lo guarda
		mov		ax,4F02h	; selecciona modo SVGA
		mov		bx,0105h	; 1024x768x256
		int		10h
;ORIGEN
		mov     bp,0200h		; AJUSTAMOS EL 
		mov     di,0180h		; ORIGEN
;					    GRAFICO DEL PRIMER CIRCULO 
;--------------------------------------------------------------------
		mov     color,202;52;15   ; color
		mov		cx,8;270;12  ; ancho del circulo
		mov		radio1,266  ; radio del circulo del reloj
bucle2:	
		push	cx
		mov		cx,360		
		mov		factor,1	
		call    graficar
		pop		cx
		loop	bucle2
;   				  GRAFICO DEL SEGUNDO CIRCULO		
;-------------------------------------------------------------------
		mov		color,9;,11   ;color
		mov		cx,4    ; ancho del circulo
		mov		radio1,260  ; radio del circulo del reloj
bucle3:	
		push	cx
		mov		cx,360;cx,60		
		mov		factor,1	;6? por cada segundo
		call    graficar
		pop		cx
		loop	bucle3
;				   GRAFICO DEL LAS LINEAS (60 SEGUNDOS - cada segundo)		
;--------------------------------------------------------------------
		mov		color,12   ;color rojo
		mov		cx,10      ; ancho del circulo
		mov		radio1,245  ; radio del circulo del reloj
bucle4:	
		push	cx
		mov		cx,60		
		mov		factor,6	;6? por cada segundo
		call    graficar
		pop		cx
		loop	bucle4
;				   GRAFICO DEL LAS LINEAS (cada 5 SEGUNDOS)		
;--------------------------------------------------------------------
		mov		color,52    ; color celeste
		mov		cx,25      ; ancho del circulo
		mov		radio1,245  ; radio del circulo del reloj
bucle5:	
		push	cx
		mov		cx,12;cx,60		
		mov		factor,30	;6? por cada segundo
		call    graficar
		pop		cx
		loop	bucle5
;-----Preparamos para el simbolo de la Facultad de Ingenieria 'FI'------
;Circulo verde		
		mov     bp,0036ch	; AJUSTAMOS EL 
		mov     di,60h		; ORIGEN,
		mov		color,240  ;Verde color
		mov		cx,58   ; ancho del circulo
		mov		radio1,58  ; radio del circulo del reloj
bucle6:	
		push	cx
		mov		cx,360;cx,60		
		mov		factor,1	;6? por cada segundo
		call    graficar
		pop		cx
		loop	bucle6
; circulo blanco
		mov		color,15  ;BLAnco
		mov		cx,1  ; ancho del circulo
		mov		radio1,52  ; radio del circulo del reloj
bucle7:	
		push	cx
		mov		cx,360;cx,60		
		mov		factor,1	;6? por cada segundo
		call    graficar
		pop		cx
		loop	bucle7

		include c:fonts.asm  ;incluimos las llamadas a las MACROS para imprimir todos los fonts necesarios
;----------------------------------------------------------------------------------------------------------
inicio:		
		mov		ah,02		;interrupcion
		int		1Ah			;para determnar hora en 
		cmp		ch,Hora_old	;tiempo real
		je		no_negro	;condicion de no cambio de horero
		
		mov		Hora_old,ch
		bresen	despX,despY,corX2+4,corY2+4,negro		;dibujo de
		bresen	despX,despY,corX2+12,corY2+12,negro		;rombo
		bresen	despX,despY,corX2+14,corY2+14,negro		;en cada manilla
		mov		cx,corX2+12								;ademas
		mov		dx,corY2+12								;de una recta al medio 
		bresen	cx,dx,corX2+4,corY2+4,negro				;para adquirir 
		mov		cx,corX2+14								;direccion
		mov		dx,corY2+14								;pero es en caso de	
		bresen	cx,dx,corX2+4,corY2+4,negro				;borrado de manilla
		horario	Hora_old,30,4
		mov		bl,5
		mul		bl
		rombo	6,12									;generacion de esquinas	
no_negro:	
		bresen	despX,despY,corX2+4,corY2+4,amarilloB	;dibujo de 
		bresen	despX,despY,corX2+12,corY2+12,amarilloB	;rombo
		bresen	despX,despY,corX2+14,corY2+14,amarilloB	;en cada manilla	
		mov		cx,corX2+12								;ademas
		mov		dx,corY2+12								;de una recta al medio	
		bresen	cx,dx,corX2+4,corY2+4,amarilloB			;para adquirir
		mov		cx,corX2+14								;direccion	
		mov		dx,corY2+14								;pero en caso de 
		bresen	cx,dx,corX2+4,corY2+4,amarilloB			;escritura de pantalla
		mov		ah,02									;adquiriendo la hora de nuevo
		int		1Ah
		
		cmp		cl,Min_old								;para el caso del
		je		no_negro2								;minutero
		
		mov		Min_old,cl
		bresen	despX,despY,corX2+2,corY2+2,negro		;borrado de rombo
		bresen	despX,despY,corX2+8,corY2+8,negro		;de minutero
		bresen	despX,despY,corX2+10,corY2+10,negro		
		mov		cx,corX2+10
		mov		dx,corY2+10
		bresen	cx,dx,corX2+2,corY2+2,negro
		mov		cx,corX2+8
		mov		dx,corY2+8
		bresen	cx,dx,corX2+2,corY2+2,negro		
		horario	Min_old,6,2
		rombo	6,8										;generacion de esquinas de rombo
no_negro2:
		bresen	despX,despY,corX2+2,corY2+2,azul		;escritura del rombo en la pantalla
		bresen	despX,despY,corX2+8,corY2+8,azul		;mediante la ubicacion de puntos
		bresen	despX,despY,corX2+10,corY2+10,azul	
		mov		cx,corX2+10
		mov		dx,corY2+10
		bresen	cx,dx,corX2+2,corY2+2,azul
		mov		cx,corX2+8
		mov		dx,corY2+8
		bresen	cx,dx,corX2+2,corY2+2,azul				;aplicado al minutero
		mov		ah,02									;interrupcion de adquisicion
		int		1Ah										;de tiempo real
		
		cmp		dh,Seg_old								;ciclo de borrado y 
		je		no_negro3								;escritura
		mov		Seg_old,dh								;para la manecilla del
		bresen	despX,despY,corX2+0,corY2+0,negro		;segundero
		horario	Seg_old,6,0								;ademas de borrado de posicion
														;anterior de segundero	
no_negro3:	
		bresen	despX,despY,corX2+0,corY2+0,verde		;escritura en la pantalla de segundero		

; 							SALIDA DEL PROGRAMA	
;----------------------------------------------------------------------------
salto:
		mov	 ah,0Bh	;Verifico si detecto una tecla presionada
		int	 21h
		cmp	 al,0	;Si es '0', no se presiono una tecla
		jne	 skip	;por tanto no es necesario verificar que tecla se presiono
				
		jmp		inicio
skip:
;-------------------------------------------------------------	
		mov		ah,07h		; espera una tecla para terminar
		int		21h
		mov		ax,vian		; retorna a video antiguo
		mov     ah,00
		int     10h
		ret
program	endp
;----------------------------------------------------------------------------
graficar proc
bucle:	
		push	cx
		mov		valor,cx
		mov		si,0		;para los segundos
		call	polarxy2
		cuadrado	corY21,corX21,5,5,color ; cambiado  ; gropsor  de las lineas
		pop		cx
		loop	bucle
		dec		radio1
		ret
graficar endp
;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
;      calcula las coordenadas X e Y a partir del radio y el theta
;      -----------------------------------------------------------
polarXY2	proc
		finit				;inicializa todo ST
		fild	valor
		fild	factor
		fmul	
		fild	noventa
		fsubr	
		fldpi				;carga pi=3.14159.. a ST(0)
		fmul				;multiplica ST(0)*ST(1)=ST(0)
		mov		aux,180
		fidiv	aux			;ang*pi/180
		fsincos				;calcula coseno y seno de ST(0)
		fimul	radio1[si]	;multiplica ST(0)*ST(1)=ST(0)
		frndint				;pone a entero ST(0)
		fistp	corX21[si]	;deposita a coorX ST(0) apuntado por DI
		fimul	radio1[si]	;carga radio a ST(0) apuntado por SI
		frndint				;pone a entero ST(0)
		fistp	corY21[si]	;deposita a coorY ST(0) apuntado por DI
		
		mov		cx,corX21[si]		; Cambia el origen

		add		corX21[si],bp
		;add		corX2[si],despX
		neg		corY21[si]			; izquierdo al
		add		corY21[si],di ; dentro de la pantalla
		;add		corY2[si],despY	; dentro de la pantalla
		ret
polarXY2	endp
;-------------------------------------------------------------------------
;-------------------------------------------------------------------------
;      calcula las coordenadas X e Y a partir del radio y el theta
;      -----------------------------------------------------------
polarXY	proc
		finit				;inicializa todo ST
		fild	valor
		fild	factor
		fmul	
		fild	noventa
		fsubr	
		fldpi				;carga pi=3.14159.. a ST(0)
		fmul				;multiplica ST(0)*ST(1)=ST(0)
		mov		aux,180
		fidiv	aux			;ang*pi/180
		fsincos				;calcula coseno y seno de ST(0)
		fimul	radio[si]	;multiplica ST(0)*ST(1)=ST(0)
		frndint				;pone a entero ST(0)
		fistp	corX2[si]	;deposita a coorX ST(0) apuntado por DI
		fimul	radio[si]	;carga radio a ST(0) apuntado por SI
		frndint				;pone a entero ST(0)
		fistp	corY2[si]	;deposita a coorY ST(0) apuntado por DI
		
		mov		cx,corX2[si]		; Cambia el origen
		add		corX2[si],despX
		neg		corY2[si]			; izquierdo al
		add		corY2[si],despY	; dentro de la pantalla
		ret
polarXY	endp
;-------------------------------------------------------------------------
;--------------------------------------------------------------
;            Pone el cursor para desplegar mensaje
;            -------------------------------------
poner   proc
        mov     ah,02
        int     10h
        ret
poner   endp
;--------------------------------------------------------------
;                    Despliega el mensaje
;                    --------------------
texto   proc
        mov     ah,09
        int     21h
        ret
texto   endp
;----------------------------------------------------------------
codigo	ends
		end	program