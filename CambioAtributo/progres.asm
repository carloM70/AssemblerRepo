;**************************ejercicio de examen************************************
;---------------carlo inti alarcon coss coaquira----------------------------------
			page 60,132
title		CAMBIO_DEL_VECTOR_DE_INTERRUPCIONES
;=================================================================================
codeseg		segment
			assume  cs:codeseg
			org		100H
inicio:
			jmp		initze		; Salto a la inicializacion
SAVINT9		dd		? 						
atrib		db		20h
;=================================================================================
; 								   APLICACION
;=================================================================================
APPLI:
			push	ax			; Guardar registros
			push	cx
			push	ds

			in 		al,60h		; Leemos codigo de rastreo del teclado
			test	al,80h  ; Verificamos si se presiono alguna tecla
			jnz 	terminar	; Cuando no hay 'tecla pulsada'
;debemos considerar el caso de borrar la letra con atributo cambiado
;por lo cual debemos verificar el back space, si el caracter a borrar es 'c' o 'C' 
;se debe de cambiar su atributo a negro
			cmp		al,0eh		;codigo de rastreo de back space
			jne		letra
			call	obtpos		;obtenemos la posicion del cursor
			dec		dx
			call	poscur		;nos vamos a la posicion a borrar
			call	carcur		;vemos su atributo o 
			cmp		ah,atrib
			jne		volver		
			mov		al,' '
			mov		bl,07h
			call	escr
			inc		dx
			call	poscur
			jmp		terminar
volver:
			inc		dx
			call	poscur
			mov		al,0eh
			jmp		terminar
letra:			
; Si es la letra 'c' o 'C' cabiamos el atributo
			cmp		al,2eh  	; letra 'c'o 'C',codigo de rastreo
			jne		terminar
			mov		bl,atrib
			call	escr
terminar:
			pop		ds			; Restablecer registros
			pop		cx
			pop		ax
			JMP     CS:[SAVINT9]
;-------------------------------------------------------------------------------
poscur		proc
			mov		ah,02h		;posicionar el cursor
			mov		bh,0
			int		10h
			ret
poscur		endp
;--------------------------------------------------------------------------------
obtpos		proc
			mov		ah,03h		;obtener la posicion del cursor
			mov		bh,0
			int 	10h
			ret
obtpos		endp
;---------------------------------------------------------------------------------
escr		proc
			mov 	ah,09h     	; Servicio 09 de la int 10h 
			mov		bh,0    ; En 'bh' la pagina de visualizacion 
			mov		cx,1		; Cx numero de veces a imprimir el caracter
			int		10h
			ret
escr		endp
;---------------------------------------------------------------------------------
carcur		proc
			mov		ah,08h		;nos proporciona las caracteristicas del
			mov		bh,0		;caracter en la posicion del cursor
			int		10h
			ret
carcur		endp
;=================================================================================
;							INICIALIZAMOS
;=================================================================================
initze:
;Obtenemos el vector de interrupciones de la interrupcion 09h.
			cli					;deshabilitamos las interrupciones posteriores
			mov		ax,3509h
			int		21h
			mov		word ptr [SAVINT9+0],BX
			mov		word ptr [SAVINT9+2],ES
;cambiamos el vector de interrupciones de la interrupcion 09h. 
			mov		ax,2509h					
			mov		dx, OFFSET APPLI  		;caragamos nuestra aplicacion
			int		21h
;Termina y permanecer residente
			mov 	ah,31h
			mov		dx,OFFSET initze
			sti
			int		21h
codeseg		ends
			end		inicio
