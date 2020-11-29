;title	MACROS PARA HORA
;******************************************************************

;-------------------------------------------------------------------
horario		macro	tiempo,multi1,dezd
			mov		dh,tiempo
			xor		ax,ax
			mov		ah,dh
			mov		cl,4
			shr		ah,cl
			mov		al,dh
			and		ax,0F0Fh	
			aad					;En AL los segundos en hexadecimal
			mov		valor,ax
			mov		si,dezd		;para los segundos
			mov		factor,multi1	;6ยบ por cada segundo
			call	polarxy	
		;	mov		audit,ax
			endm
;-------------------------------------------------------------------	
rombo		macro	zeta1,desde
			push	ax
			mov		factor,zeta1
			dec		ax
			mov		valor,ax
			mov		si,desde		;para los segundos
			call	polarxy			
			add		ax,2
			mov		valor,ax
			mov		si,desde+2		;para los segundos
			call	polarxy		
			pop		ax
			endm
;-------------------------------------------------------------------			
;******************************************************************
;*********************Pone modo de video***************************
;Parametros: modo de Video
pmovi		macro	video
			mov		ax,4f02h
			mov  	bx,video			
			int  	10h				; Pone modo grafico
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
;*********************************************************************
;----------------------------------------------------------------------------
;***********DIBUJA UNA LINEA*************************************************
;*******bresen [Xinicio],[Yinicio],[Xfin],[Yfin],[color]**********************

bresen	macro	xi,yi,xf,yf,color
		local	ini,interc,deltax,cas1o2,absol,abso1,caso1,caso2,caso3,caso4,inter,dat,compa,dos,tres,cuatro,si1,no1,si2,no2,si3,incre,incre1,dib,fin
		mov	x0,xi
		mov	y0,yi
		mov	cx,xf
		mov	dx,yf
		mov	x1,cx
		mov	y1,dx
ini:	mov	ax,y1		
		mov	dx,y0
		sub	ax,dx		;calculamos 'delta y'
		mov	vy,ax		;guardamos
		cmp	ax,0		;comparamos si 'delta y' es menor a cero 
		jge	deltax		;si no es vamos a comparar 'delta x'
		jmp	interc		;si no hacemos intercambios de puntos, esto se aplica 
				;a puntos que no esten en ninguno de los 4 casos
interc:	mov	ax,y1		;aca intercambiamos los puntos y volvemos a la comparacion
		xchg	ax,dx
		mov	y1,ax
		mov	y0,dx
		mov	ax,x0
		mov	dx,x1
		xchg	ax,dx
		mov	x0,ax
		mov	x1,dx
		jmp	ini
deltax:	mov	ax,x1		
		mov	dx,x0		;calculamos 'delta x'
		sub	ax,dx		
		mov	vx,ax
		cmp	ax,0		;'delta x'mayor igual a 0
		jge	cas1o2		;si, entonces puede ser caso 1 o 2
		jmp	absol		;no, pasamos revisar si son otros casos, y a obtener el absoluto,
					;ya que 'delta x' es menor que 0
cas1o2:	mov	dx,vy				
		cmp	ax,dx		;'delta x' >= 'delta y'
		jge	caso1		;si caso1
		jmp	caso2		;no caso2
absol:	neg	ax		;absoluto de 'delta x'
		mov	vx,ax		;guardamos
		mov	dx,vy
		cmp	ax,dx		;'abs delta x'>='delta y'
		jge	caso3		;si, caso3
		jmp	caso4		;no, caso4
caso1:	mov	caso,1		;dependiendo del caso mov el dato a la variable 'caso'
		jmp	dat
caso2:	mov	caso,2
		jmp	inter
caso3:	mov	caso,3
		jmp	dat
caso4:	mov	caso,4
		jmp	inter		 
inter:	xchg	ax,dx		;aca ajustamos 'delta x' y 'delta y'para los casos 2 y 4 intercambiando los deltas
				;y asi evitarnos el calculo por demas 	
dat:	mov	m,ax		;realizamos los calculos de e1,e2,e3 y pk para los distintos
		add	ax,ax		;casos
		add	dx,dx
		mov	e1,dx
		mov	e2,ax;
		sub	dx,ax
		mov	e3,dx
		mov	dx,e1
		sub	dx,vx
		mov	pk,dx
compa:	cmp	caso,1		;comparamos el valor de caso para realizar la rutina   
		jne	dos		;respectiva y calcular los puntos adecuados que uniran 
		cmp	pk,0		;los puntos que se quiern unir
		jl	si1
		jmp	no1	
dos:	cmp	caso,2
		jne	tres
		cmp	pk,0
		jl	si2
		jmp	no1
tres:	cmp	caso,3
		jne	cuatro
		cmp	pk,0
		jl	si3
		jmp	no2	
cuatro:	cmp	pk,0
		jl	si2
		jmp	no2
si1:	mov	ax,x0		;rutinas que se seguiran dependiendo del caso y de la comparacion de pk
		inc	ax
		mov	x0,ax
		jmp	incre
no1:	mov	ax,y0
		inc	ax
		mov	y0,ax
		mov	ax,x0
		inc	ax
		mov	x0,ax
		jmp	incre1
si2:	mov	ax,y0
		inc	ax
		mov	y0,ax
		jmp	incre
si3:	mov	ax,x0
		dec	ax
		mov	x0,ax
		jmp	incre
no2:	mov	ax,x0
		dec	ax
		mov	x0,ax
		mov	ax,y0
		inc	ax
		mov	y0,ax	
		jmp	incre1
incre:	mov	ax,pk		;se calcula el nuevo pk para volver a realizar el calculo de nuevo
		mov	dx,e1
		add	ax,dx
		mov	pk,ax
		jmp	dib
incre1:	mov	ax,pk
		mov	dx,e3
		add	ax,dx
		mov	pk,ax
dib:	mov	ax,m		;se dibuja el punto calculado y se pasa a calcular el siguiente
		dec	ax
		mov	m,ax
		cmp	m,0
		je	fin
		mov	cx,x0	;columna
		mov	dx,y0	;fila
		mov	al,color
		cuadrado	y0,x0,2,2,color ;Dibuja un "pixel" de 3x3
		jmp	compa
fin:				
			endm
			