title	macros para el programa principal
;MACp2.asm-----------------------------
;**************DIBUJA UN CUADRADO**********************************
;Se introducen variables fila, columna de inicio, alto y ancho del cuadro y su color
cuadrado	macro	fila,columna,alto,ancho,color
			Local	cc					;etiquetas locales
			mov		dx,fila				;inicio coordenada fila y el alto que tendra el cuadro
			mov		cx,alto
cc:
			push	cx
			linhor	dx,columna,color,ancho	;Dibujo una linea horizontal
			pop		cx
			inc		dx						;Dibujo 'cx' lineas horizontales
			loop	cc
			endm
;**************DIBUJA UNA LINEA HORIZONTAL**********************************
;Se introducen variables (FILA,COLUMNA) de inicio, COLOR y el TAMANIO de la linea		
linhor     	macro	fila,columna,color,tamadelinea
			local	eje
			mov		bx,tamadelinea
			mov		cx,columna		;dibujara 'cx' pixeles en horizontal
			mov 	dx,fila
eje:
			push	bx           
			mov		al,color		;Especifico el color
			pixelx	color			;Macro que dibuja un pixel en cx,dx
			pop 	bx
			inc		cx				;Incremento columna
			dec		bx				;Decremento tamanio de linea
			cmp		bx,0			
			jne		eje
			endm
;**********************************************************************
;**********************DIBUJA UN PIXEL EN CX,DX************************
;EL parametro a introducir es COLOR del pixel
pixelx		macro	color
			push	bx
			push	ax
			mov		ah,0Ch			;0Ch escribe pixel punto
			mov		al,color		;al=color del pixel
			mov		bh,00h			;Pagina
			int		10h
			pop		ax
			pop		bx
			endm

;-----------------------------------------------------------------------------
;macro pra diobujar los pixeles
dibujar    	macro   pcol,pfil,letra,tamano,coloor
			local   loopcol,loopfil,nodibu,yadibu;,tamhor,tamver
			mov     cx,8
			mov     bp,tamano
			mov     x,pcol   ; posicion columna
			mov     y,pfil    ; posicion fila
			lea     di,letra
loopcol:	
			push    cx
			mov     al,[di]
			mov     cx,8	
loopfil:					
			push    cx
			rol     al,1
			push    ax

			jnc     nodibu  ; si es cero (C=0) salta y no dibuja
			push    cx			
			tamanio	x,y,coloor     ; vamos al MACRO 'tamanio' enviando los parametros 'x' (columna),'y' (fila)
			pop 	cx
			jmp		yadibu  ; como se imprimio salta directo para ir volver al loopfil
nodibu:		
			add		x,bp	;'bp' numero de veces a ampliar (horizontal (columna))
yadibu:			
			pop     ax
			pop     cx
			loop	loopfil
			add     y,bp 	 ; 'bp' numero de veces a ampliar (vertical ( filas ))
			mov     x,pcol   ; reiniciamos en x lka posicion de la columnna para la sigueitne fila
			inc     di       ; incrementamos la letra  ;   F - A - C - U - L - T - A - D , etc
			pop     cx
			loop    loopcol
			endm
;-----------------------------------------------------------------------------------------------------
tamanio		macro	xx,yy,colors   ; recibimos la posiciones de la columna(xx) y fila (yy), y el color para cada letra o numero
			local   tamhor   ; definimo variables locales
			mov			cx,bp
tamhor:
			push		cx
			mov		ah,0ch
			mov     al,colors ;Color a utilizar
			mov     bh,00     ; pagina de visualizacion
			mov		cx,xx     ;dir columna
			mov		dx,yy     ;dir fila
			int   	10h
			inc     xx
			pop		cx
			loop    tamhor
			endm			