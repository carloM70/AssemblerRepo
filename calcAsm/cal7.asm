          page 60,132
title      calculadora
;----------------------------------------------------------
comparacion	MACRO	etiqueta
			cmp		al,'+'			;comparacion de 
			jz     etiqueta			;simbolos en la eleccion
			cmp		al,'-'			;de tecla
			jz     etiqueta
			cmp		al,'*'
			jz     etiqueta
			cmp		al,'/'
			jz     etiqueta
			cmp		al,'r'
			jz     etiqueta		
			ENDM
;----------------------------------------------------------
comparar1  	MACRO	etiqueta1
			cmp		al,30h			;limita a solo usar 
			jb     etiqueta1		;numeros 
			cmp		al,39h
			ja     etiqueta1
			ENDM
;----------------------------------------------------------
;constantes extra
;----------------------------------------------------------
pila       segment stack
           dw      32 dup('la')
pila       ends
;----------------------------------------------------------
datos      segment para 'data'
;-------------------------------------------------------
pantposi    dw		010bh,030dh,010bh,010bh,0123h,080eh
pantposf	dw		1327h,0625h,0127h,010fh,0127h,1224h
color		db		71h,?,21h,?,15h,?,4fh,?,4fh,?,00fh
cantcolor	db		7

posicion   dw       0
sup		   db		218,3 dup (196),191,20h,218,3 dup (196),191,20h,218,3 dup (196),191,20h,218,3 dup (196),191,24h
med1	   db		179,3 dup (20h),179,20h,179,3 dup (20h),179,20h,179,3 dup (20h),179,20h,179,3 dup (20h),179,24h
med2 	   db		195,3 dup (196),180,20h,195,3 dup (196),180,20h,195,3 dup (196),180,20h,195,3 dup (196),180,24h
inf		   db       192,3 dup (196),217,20h,192,3 dup (196),217,20h,192,3 dup (196),217,20h,192,3 dup (196),217,24h

numeros		db		'C',20h,251,'=','1','2','3',246,'4','5','6','*','7','8','9','-','0','+','X',' '
posnum		dw		0910h,0916h,091ch,0922h,0b10h,0b16h,0b1ch,0b22h,0d10h,0d16h,0d1ch,0d22h,0f10h,0f16h,0f1ch,0f22h,1116h,1122h,0125h,010dh
contnum		db		20
posicionm	dw		0,0020h,0,24h	
coefm		db		10
;--------------------------------------------------------
ayuda       db      218,33 dup(196),191,24h
            db      179,'       AYUDA - CALCULADORA       ',179,24h
            db      179,'Las  operaciones  que se  realiza',179,24h
            db      179,'son de numeros de hasta 9 digitos',179,24h
            db      179,'Suma:  Soporta  operaciones hasta',179,24h
            db      179,'de 9 digitos + 9 digitos.        ',179,24h
            db      179,'Resta: Soporta  operaciones hasta',179,24h
            db      179,'de 9 digitos, el primer  dato que',179,24h
            db      179,'se ingrese debe ser el mayor.    ',179,24h
            db      179,'Multiplicacion:Soporta operacions',179,24h
            db      179,'hasta de 9 digitos X 9 digitos.  ',179,24h
            db      179,'Division: El divisor no debe exe_',179,24h
            db      179,'der a 65535 y el dividendo debe  ',179,24h
            db      179,'ser  como  maximo  65535 veces el',179,24h
            db      179,'divisor.                         ',179,24h
            db      179,'Raiz Cuadrada: El numero maximo a',179,24h
            db      179,'sacar la raiz es 65025.          ',179,24h
            db      179,' SI NO CUMPLIMOS LO DETALLADO LA ',179,24h
            db      179,'CALCULADORA NOS DARA UN RESULTADO',179,24h
            db      179,'ERRONEO.!!    Elaborado por:  G04',179,24h
            db      179,' Jorge Mollericon & Inti Alarcon ',179,24h
            db      192,33 dup(196),217,24h
mensadivi	db		'SYNTAX ERROR',24h 
mensajeay	db		'si quiere ayuda presione a',24h 
mensaje2	db		'cuando quiera nueva operacion presione ESC o C en pantalla',24h
;--------------------------------------------------------
resultado   dw		2 dup(0) ;resultado en HEX de la suma y resta			
resultmul   dw		4 dup(0) ;resultado de la multiplicacion en HEX (mas arriba en la memo)
; datos para la division------------------------------
rforconv    db      2 dup(0) ; son 2 bytes que se debe convertir a ASCII
resultdiv   db      6 dup(0),0 ; es una ',' y 5 decimales
byte22       dw      10 ; factor de multiplicacion para, los decimales                            
;--------------------------- DATOS PARA LA RAIZ CUADRADA ----------------------------------------------
aprox       dw      1        ; valor aproximado de la raiz
aprox2      dw      1        ; valor aproximado de la raiz al cuadrado
num         dw      2 dup(0) ; numerador = aprox2+dato1 = valor aproximado al cuadrado + dato a sacar raiz
den         dw      2 dup(0) ; denominador = aprox*2 = valor aproximado por dos
resultraiz  db      4 dup(0) ; RESULTADO DE LA RAIZ
byte2       dw      10       ; factor de multiplicacion para, los decimales                            
mostrar     db      8 dup(20h),24h  ; ya listo para desplegar en pantalla
;binary		dw		270fh
bcd			db      10 dup(0)
;-----------------DATOS CONVERSION ASCII A BIANRIO -HEXADECIMAL---------------------------
dato1	dw	2 dup(?)	;FFFF FFFF = 4294967295 (maximo valor)
dato2	dw	2 dup(?)	;FFFF FFFF = 4294967295	(maximo valor)
factor	dw	0000,0001h	;maximo factor para convertir a binhex	1000000000=3B9A CA00
factor1	dw	000Ah
carry	dw	0
;-------------------------------------------------------------------------------------
prodhex	dw	4 dup(0)                   ;4 dup(?)	;producto en hexadecimal
proAsc	db	25 dup(?),24h	;producto en codigo ASCII
;factor1	dw	000Ah
;-------------------------------------------------------
esra	dw	?
pohora	dw	?
povera	dw	?
control	db	?
espacio	db	10 dup(20h),24h
;--------------------------------------------------------
posx		db		04
posy		db		14
band1		db		0				;banderas para anular condiciones
band2		db		0
band3		db		0
sgn			db		0,24h			;evaluando el sino de la operacion	
contador	dw		9				;contador de cantidad de numeros de operandos
op1			db		10 dup (30h),'$'		;primer operador en ascii
op2			db		10 dup (30h),'$'		;segundo operando enascii
datos      ends
;----------------------------------------------------------
codigo     segment para 'code'
programa   proc    far
           assume  ss:pila,cs:codigo,ds:datos,es:datos
           push    ds
           sub     ax,ax
           push    ax
           mov     ax,datos
           mov     ds,ax
		   mov		es,ax	   
			mov		cx,00
			mov		dx,184fh
			mov		bh,00
			call	bopan
           call    IniRaton				;inicializa el raton
           call    ZoDeRaton			
           call    DeCuRaton
		   call	interf					;llamada a dibujo de interfaz
inicio:		;inicializando todas las variables para evaluacion 			
			mov		posx,4				;posicion del cursor inicial
			mov		posy,14
			mov		contador,9
			mov		sgn,0
			mov		band1,0
			mov		band2,0
			mov		band3,0
			mov		aprox,word ptr 1
			mov		aprox2,word ptr 1
			mov		byte2,word ptr 10
			mov		byte22,word ptr 10
			mov		factor,0
			mov		factor+2,1
			mov		factor1,10			
			lea		di,op1
			call	borrarb
			lea		di,op2
			call	borrarb
			lea		di,dato1
			mov		cx,4
			call	borrarw	
			lea		di,num
			mov		cx,4
			call	borrarw	
			lea		di,resultado
			mov		cx,6
			call	borrarw		
			lea		di,prodhex
			mov		cx,4
			call	borrarw					
			lea		di,rforconv
			mov		cx,8
			call	borrartb	
			lea		di,resultraiz
			mov		cx,4
			call	borrartb	
			lea		di,mostrar
			mov		cx,8
			call	borrarm				
			lea		di,proAsc
			mov		cx,25
			call	borrartb	
			lea		di,bcd
			mov		cx,10
			call	borrartb		
			call	borrapan
			call	borrarayu
			mov		dx,161ah
			call	poncur
			lea		dx,mensajeay
			call	escritura
			mov		dx,1710h
			call	poncur
			lea		dx,mensaje2
			call	escritura			
;leer primer numero
main:				
			lea		si,op1
			call	lectura		;lectura de dato del PRIMER OPERANDO
			cmp		al,20h		;signo de igual
			je		resigu
			cmp		al,'e'		;salida de calculadora
			jne		progresar5
			jmp		fin
progresar5:	cmp		al,61h		;pedida de ayuda	
			jne		progresar
			call	help
			jmp		main			
progresar:	cmp		al,1bh
			jne		proceder		;reiniciar calculadora
			jmp		inicio
proceder:	cmp		sgn,'r'			;raiz cuadrada
			jne		progresar1
			jmp		operaciones
;lee segundo numero
progresar1:	mov		posx,4
			mov		posy,14
			mov		band2,1
			mov		contador,9
			mov		band1,0
			lea		si,op2		
			call	lectura		;lectura de dato del SEGUNDO OPERANDO			
			cmp		al,'e'
			jne		progresar2
			jmp		fin
progresar2:	cmp		al,1bh			;reinicio de calculadora
			jne		proceder12
			jmp		inicio
proceder12:	cmp		al,20h
			je		operaciones
resigu:			
				jmp		main
operaciones:	
				call	borrapan		;borrar visor de calculadora

;------------------CONVERSION:  ASCII  -  HEXADECIMAL--------------------------		
			lea	si,op1+8
			lea	di,dato1+2
			call	Aschex		;convierte de ASCII a binario-hexadecimal

			lea     bx,factor
			mov     ax,0000h
			mov      [bx],ax 
			mov      ax,0001h
			mov      [bx+2],ax
            
			lea	    si,op2+8
			lea	    di,dato2+2
			call	Aschex		;convierte de ASCII a binario-hexadecimal	
;--------------------------------------------------------------------------
	
;-------------------------------------------------------------------------		
			mov    al,sgn			
			cmp    al,'+'
			je     opsuma ; operacion suma
			cmp    al,'-'
			je	   opresta		;operacion resta
			cmp    al,'*'
			je	   opmultiplicacion		;operacion de multiplicacion
			cmp    al,'/'
			je	   opdivision			;operacion de division
			cmp    al,'r' ; r para la raiz
			je     opraizcua			
;--------------------------------------------------------------------------			
opsuma:			
			lea		si,dato1   ; dato2=dato1+4 y resultado=dato1+8 
			lea		di,resultado
			call	sumar
			jmp     convertir   ; lleva el resultado en "resultado" en HEX
opresta:			
			lea		si,dato1   ; solo utilizaremos 'si'			
			lea		di,resultado
			call	restar
			jmp     convertir   ; lleva el resultado en "resultado" en HEX
opmultiplicacion:			
			lea		si,dato1 ; dato2=dato1+4 y resultado=dato1+8
			lea     di,dato2 ;
			lea     bx,resultmul
			call	mpcion
			jmp     convertir1   ; lleva el resultado en "resultmul" en HEX
opdivision:
            lea     si,dato1
            lea     di,dato2
			call 	dividir
			cmp		band3,1
			je		saverdiv
			jmp     convertir2   ; lleva el resultado en "resultdiv" la coma y los decimales en ASCCI
			                    ; y la parte entera en "rforconv" se debe conretir de HEX a ASCII
opraizcua:			
			lea     si,dato1+2  ; apunta los 2 bytes menos significativo de dato1
			lea     di,aprox
			call	raiz
			jmp     mostrarres   ; lleva en resultado en "mostrar" YA en ASCII  ; mostar resultado								
;-----------------------------------------------------------------------
saverdiv:	
			mov		dx,040eh
			call	poncur
			lea		dx,mensadivi				;despliegue en pantalla de resultado
			call	escritura
			jmp		main										
square:			
			jmp		main
convertir:
			mov		factor,0				;reiniciando constantes
			mov		factor+2,1				;y convirtiendo datos 
			mov		factor1,10				;de hexadecimal
			lea		si,prodhex				;a ascii
			mov		[si+2],word ptr 0
			mov		[si],word ptr 0
			mov		ax,resultado+2
			mov		[si+6],ax
			mov		ax,resultado
			mov		[si+4],ax			
			call	h_asc
			mov		dx,040eh
			call	poncur
			lea		dx,proAsc				;despliegue en pantalla de resultado
			call	escritura				
			jmp		main
convertir1:
			mov		factor,0				;reiniciando constantes y
			mov		factor+2,1				;arreglando datos para la conversion
			mov		factor1,10
			lea		si,prodhex
			mov		ax,resultmul
			mov		[si],ax
			mov		ax,resultmul+2
			mov		[si+2],ax
			mov		ax,resultmul+4
			mov		[si+4],ax
			mov		ax,resultmul+6
			mov		[si+6],ax			
			call	h_asc
			mov		dx,040eh
			call	poncur
			lea		dx,proAsc
			call	escritura					;despliegue en pantalla
			jmp		main
convertir2:
			mov		factor,0					;reiniciando constantes
			mov		factor+2,1					;y arreglando los 
			mov		factor1,10					;resultados
			lea		si,prodhex
			mov		ax,word ptr rforconv
			mov		[si+6],ax
			mov		ax,0
			mov		[si+2],ax
			mov		[si+4],ax
			mov		[si],ax			
			call	h_asc
			mov		resultdiv+5,24h		
			mov		dx,040eh
			call	poncur
			lea		dx,proAsc
			call	escritura
			lea		dx,resultdiv
			call	escritura					;desplegando resultado
			jmp		main						
mostrarres: 
			mov		dh,4
			mov		dl,14
			call	poncur
            lea     dx,mostrar				;desplegando resultado de raiz cuadrada
            call    escritura		
			jmp		main
		
fin:		call	OcCuRaton
			mov		cx,00
			mov		dx,184fh
			mov		bh,00
			call	bopan
			ret					
programa   endp
;------------------------------------------------
;	lectura de datos por teclado
lectura	proc
lee_num:
	mov		dh,posx
	mov		dl,posy
	call	poncur
	mov	ah,0Bh
	int	21h
	cmp	al,0FFh
	je	tecla
	jmp	notecla
tecla:
	call	lsecho		;sin eco
comprobar:	
	comparacion	siguiente						;discriminando					
	cmp	al,20h									;entre teclas o
	je	otrosusos								;botones de la pantalla
	cmp	al,1bh
	je 	otrosusos
	cmp	al,61h
	je 	otrosusos	
	cmp	al,'e'
	je	otrosusos
	cmp		band1,1
	je		lee_num
	comparar1	lee_num
	call	escribir
	jmp		desarrollo
notecla:						;revisado el mouse
	call	Nmouse
	cmp	control,0
	je	lee_num
	jmp		comprobar
desarrollo:
	mov		[si+9],al
	sub		bx,bx
mover:	
	mov ah,[bx+si+1]
	mov [bx+si],ah
	inc bx
	cmp bx,0009h
	jne mover
;-----------------------------------
	inc		posy
	dec		contador
	jne		lee_num
	mov	band1,1
	jmp		lee_num	
siguiente:
	cmp		band2,1
	jne		formal
	jmp		lee_num
formal:	
	mov		sgn,al				;guardado el signo de la operacion
	call	borrapan			;limpia pantalla de calculadora
otrosusos:	
	ret
lectura	endp
;------------------------------------------------------------------
bopan		proc
			mov		ax,0600h			;rutina para generar bloques de
			int		10h					;colores en pantalla
			ret
bopan		endp
;----------------------------------------------------------
borrapan		proc
			mov		ax,0600h			;borrando solo pantalla de calculadora
			mov		bh,21h
			mov		cx,030dh
			mov		dx,0625h
			int		10h
			ret
borrapan		endp
;----------------------------------------------------------
borrarayu		proc				;borrando sector de ayuda a usuario
			mov		ax,0600h
			mov		bh,07h
			mov		cx,0029h
			mov		dx,184fh
			int		10h
			ret
borrarayu		endp
;----------------------------------------------------------
lsecho		proc			;lectura de datos sin echo
			mov		ah,07h
			int		21h
			ret
lsecho		endp			
;----------------------------------------------------------
escritura	proc			;escritura de cadena de caracteres
		   mov		ah,09h
		   int		21h
		   ret
escritura	endp	   
;------------------------------------------------------------------
escribir	proc				;escribir un solo caracter
			mov		ah,0ah
			mov		bh,0
			mov		cx,1
			int		10h
			ret
escribir	endp		
;------------------------------------------------------------------
poncur		proc				;poner cursor en posicion
			mov		ah,02h
			mov		bh,00h
			int		10h
			ret
poncur		endp
;------------------------------------------------------------------
poscur		proc			;poner curso en pantalla para interfz
		   mov		ah,02h
		   mov		dx,posicion
		   mov		bh,0
		   xchg		dh,dl
		   int		10h
		   ret
poscur		endp
;------------------------------------------------------------------
borrarb		proc	;borrar grupo de bytes
			mov		al,30h
			mov		cx,10
			rep		stosb
			ret
borrarb		endp
;------------------------------------------------------------------
borrarw		proc	;borrar grupo de words
			mov		ax,0
			rep		stosw
			ret
borrarw		endp
;------------------------------------------------------------------
borrartb		proc	;borrar grupo de bytes
			mov		al,0
			rep		stosb
			ret
borrartb		endp
;------------------------------------------------------------------
borrarm		proc	;borrar cantidad de bytes
			mov		al,20h
			rep		stosb
			ret
borrarm		endp
;subrutinas de manejo de mouse
;------------------------------------------------------------------
;------------------------------------------------------------------
;                    Inicializa driver del raton
;                    ---------------------------
IniRaton      proc
              mov     ax,0
              int     33h
              ret
IniRaton      endp
;------------------------------------------------------------------
;                  Despliega el cursor del raton
;                  -----------------------------
DeCuRaton     proc
              mov     ax,1
              int     33h
              ret
DeCuRaton     endp
;------------------------------------------------------------------
;                   Oculta el cursor del raton
;                   --------------------------
OcCuRaton     proc
              mov     ax,2
              int     33h
              ret
OcCuRaton     endp
;------------------------------------------------------------------
;              Lee la posicion y el estado del raton
;              -------------------------------------
PyERaton      proc
              mov     ax,3
              int     33h
              ret
pyERaton      endp
;------------------------------------------------------------------
;            Define la Zona de desplazamiento del raton
;            ------------------------------------------
ZoDeRaton     proc
              mov     ax,7      ;horizontal
              mov     cx,0
              mov     dx,79*8
              int     33h
              mov     ax,8      ;vertical
              mov     cx,0
              mov     dx,25*8
              int     33h
              ret
ZoDeRaton     endp
;------------------------------------------------
;------------------------------------------------------------------

;------------------------------------------------
Nmouse	proc
	call    PyERaton       ;Posicion y estado del raton
              mov     esra,bx        ;se guardan si bx=1 hay click de mouse
              mov     pohora,cx	;cx=columna
              mov     povera,dx	;dx=fila
              mov     cx,3
              shr     pohora,cl      ;divide entre 8 para tener
              shr     povera,cl      ;posiciones de pantalla

	cmp	esra,1
	je	valor12
	jmp	sale
valor12:
	cmp	pohora,15
	jae	paso1n
	jmp	sale
paso1n:
	cmp	pohora,17
	jbe	paso2n
	jmp	opcion1
paso2n:	;compara para numero 1
	cmp	povera,11
	je	uno2
	jmp	saltos
uno2:
	mov	al,'1'
	push	ax
	jmp	retorno
saltos:	;compara para numero 4
	cmp	povera,13
	je	cuatro2
	jmp	saltos1
cuatro2:
	mov	al,'4'
	push	ax
	jmp	retorno
saltos1:	;compara para numero 7
	cmp	povera,15
	je	siete2
	jmp	saltos2
siete2:
	mov	al,'7'
	push	ax
	jmp	retorno
saltos2:	;compara para clear
	cmp	povera,9
	je	clear2
	jmp	sale
clear2:
	mov	al,1bh
	push	ax
	jmp	retorno
;********************************************
opcion1:
	cmp	pohora,21
	jae	paso1m
	jmp	sale
paso1m:
	cmp	pohora,23
	jbe	paso2m
	jmp	opcion2
paso2m:
	;compara para numero 2
	cmp	povera,11
	je	dos2
	jmp	salto4
dos2:
	mov	al,'2'
	push	ax
	jmp	retorno
salto4:	;compara para numero 5
	cmp	povera,13
	je	cinco2
	jmp	salto5
cinco2:
	mov	al,'5'
	push	ax
	jmp	retorno
salto5:	;compara para numero 8
	cmp	povera,15
	je	ocho2
	jmp	salto6
ocho2:
	mov	al,'8'
	push	ax
	jmp	retorno
;compara	para numero 0	
salto6:
	cmp	povera,17
	je	igual2
	jmp	sale
igual2:
	mov	al,'0'
	push	ax
	jmp	retorno
;************************************************	
opcion2:	;compare con otros numeros falta
	cmp	pohora,27
	jae	paso3m
	jmp	sale
paso3m:
	cmp	pohora,29
	jbe	paso4m
	jmp	opcion3
paso4m:	;compara para numero 3
	cmp	povera,11
	je	tres2
	jmp	salto7
tres2:
	mov	al,'3'
	push	ax
	jmp	retorno
salto7:	;compara para numero 6
	cmp	povera,13
	je	seis2
	jmp	salto8
seis2:
	mov	al,'6'
	push	ax
	jmp	retorno
salto8:	;compara para numero 9
	cmp	povera,15
	je	nueve2
	jmp	roote
nueve2:
	mov	al,'9'
	push	ax
	jmp	retorno
;simbolo de raiz cuadrada	
roote:	;compara para raiz
	cmp	povera,9
	je	rot2
	jmp	sale
rot2:
	mov	al,'r'
	push	ax
	jmp	retorno	
;********************************************
opcion3:
	cmp	pohora,33
	jae	paso5m
	jmp	sale
paso5m:
	cmp	pohora,35
	jbe	paso6m
	jmp	opcion4
paso6m:	;compara para simbolo =
	cmp	povera,9
	je	igu2
	jmp	salto10
igu2:
	mov	al,20h
	push	ax
	jmp	retorno
salto10:	;compara para simbolo division
	cmp	povera,11
	je	divi2
	jmp	salto11
divi2:
	mov	al,'/'
	push	ax
	jmp	retorno
salto11:	;compara para simbolo por
	cmp	povera,13
	je	pors2
	jmp	salto12
pors2:
	mov	al,'*'
	push	ax
	jmp	retorno
salto12:	;compara para menos
	cmp	povera,15
	je	rest2
	jmp	salto13
rest2:
	mov	al,'-'
	push	ax
	jmp	retorno	
salto13:	;compara	signo	+
	cmp	povera,17
	je	mas2
	jmp	salto14
mas2:
	mov	al,'+'
	push	ax
	jmp	retorno
opcion4:	
salto14:	;compara con X
	cmp	pohora,35
	jae	pasof1m
	jmp	sale
pasof1m:
	cmp	pohora,39
	jbe	pasof2m
	jmp	opcion5
pasof2m:	;compara para simbolo X
	cmp	povera,1
	je	equis
	jmp	sale
equis:
	mov	al,'e'
	push	ax
	jmp	retorno
opcion5:
	cmp	pohora,11
	jae	pasof100m
	jmp	sale
pasof100m:
	cmp	pohora,15
	jbe	pasof200m
	jmp	opcion7
pasof200m:	;compara para simbolo ?
	cmp	povera,1
	je	helptt
	jmp	sale
helptt:
	mov	al,61h
	push	ax
	jmp	retorno
opcion7:	
sale:
	mov	control,0
	jmp	final
retorno:
	call    PyERaton       ;Posicion y estado del raton
	cmp	bx,0
	jne	retorno
	pop	ax
	mov	control,1
final:
	ret
Nmouse	endp
;------------------------------------------------
interf		proc
		   mov		si,0
poni:		   
		   mov		cx,pantposi[si]	;dibujo de 
		   mov		dx,pantposf[si]	;interfaz
		   mov		bh,color[si]	;agregando color
		   call	    bopan			;con rutina de borrado a pantalla
		   add		si,2		
		   dec		cantcolor
		   jnz		poni
		   
		   mov		posicion,0e08h
		   call		poscur
		   lea 		dx,sup				;poniendo fin colores
		   call		escritura
		   mov		cx,5
otro13:
		   inc		posicion			;dibujando las teclas
		   call		poscur
		   lea		dx,med1
		   call		escritura
		   inc		posicion
		   call		poscur
		   lea		dx,med2
		   call		escritura

		   loop		otro13
		   call		poscur
		   lea 		dx,inf
		   call		escritura		   
	;;;dibu	   
		   mov	  si,0
		   mov	  di,0			  
nindic:			  
       	   mov	  dx,posnum[si]
	       call	  poncur
	       mov	  al,numeros[di]
		   call	  escribir
		   add	  si,2
		   inc	  di
		   dec     contnum
		   jnz	  nindic
		   ret
interf		endp		   
;--------------------------------------------------
;------------------------------------------------
;------------------------------------------------
;	convierte de codigo ASCII a Binhexadecimal
Aschex	proc
	mov	cx,9
convierte:
	push	cx
	xor	dx,dx
	xor	cx,cx
	mov	cl,[si]
	and	cl,0Fh	;cx=factor de multiplicacion
	lea	bx,factor+2
	xor	dx,dx
	mov	ax,[bx]
	mul	cx
	add	[di],ax
	jnc	nada
	mov	carry,1
	jmp	seguir
nada:
	mov	carry,0
seguir:	
	push	dx
	xor	dx,dx
	mov	ax,[bx-2]
	mul	cx
	pop	dx
	add	ax,dx
	add	ax,carry
	add	[di-2],ax
	dec	si
	;cambia factor*****
	lea	bx,factor+2
	xor	dx,dx
	mov	ax,[bx]
	mul	factor1
	mov	[bx],ax
	push	dx
	xor	dx,dx
	mov	ax,[bx-2]
	mul	factor1
	pop	dx
	add	ax,dx
	mov	[bx-2],ax
	pop	cx
	loop	convierte
	ret
Aschex	endp
; --------- suma (lo que esta apuntado por si) -----------
sumar		proc  
			clc               ; ponemos en cero la bandera carri 			
			mov 	ax,[si+2] ; dato1 
			mov     bx,[si+6] ; dato2
			add		ax,bx     ; suma 
			mov		[di+2],ax
			mov 	ax,[si] ; dato1 
			mov     bx,[si+4] ; dato2
			adc		ax,bx     ; suma con acarreo
			mov		[di],ax
			ret
sumar		endp
; ---- resta ---------------------------------------------------
restar		proc			
			clc               ; ponemos en cero la bandera carri 			
			mov 	ax,[si+2] ; dato1 
			mov     bx,[si+6] ; dato2
			sub		ax,bx     ; resta 
			mov		[di+2],ax
			mov 	ax,[si] ; dato1 
			mov     bx,[si+4] ; dato2
			sbb		ax,bx     ; resta final
			mov		[di],ax
			ret
restar		endp
;-------------------------------------------------------------			
mpcion		proc
           mov     ax,[si+2]  ; mulcnd(MULTIPLICANDO)
           mul     word ptr[di+2]     ; mulcdr(MULTIPLICADOR)
           mov     [bx+6],ax
           mov     [bx+4],dx
    
           mov     ax,[si+2]
           mul     word ptr [di]
           add     [bx+4],ax
           adc     [bx+2],dx
           adc     word ptr[bx],00
           
           mov     ax,[si]
           mul     word ptr [di+2]
           add     [bx+4],ax
           adc     [bx+2],dx
           adc     word	ptr[bx],00
     
           mov     ax,[si]
           mul     word ptr [di]
           add     [bx+2],ax
           adc     word ptr[bx],dx ;producto(RESULTADO DE LA MULTIPLICACION)
		   ret
mpcion		endp	
;-------------------------------------------------------------			
dividir		proc
            mov     dx,[si]     ; dividendo
            mov     ax,[si+2]   ;     "     
            mov     bx,[di+2]   ; divisor :"para la division: 'BX' divisor y 'DX:AX' dividendo"
			cmp		bx,0
			jne		divi100
			mov		band3,1
			jmp		divi200
divi100:			
;---------------------------------------------------------
;                        Parte entera
;                        ------------
           mov     cx,4         ;numero de digitos  
     	   div     bx
		   lea     si,resultdiv ;dir. de resultado
		   mov     [si],ax      ;almacena parte entera
           inc     si
           inc     si
           mov     ax,dx        ;dividendo=resto
           and     dx,00h
;----------------------------------------------------------
;                       Parte decimal
;                       -------------
otroo:
           mul     byte22        ;dividendo=dividendo*10
           div     bx           ;entre divisor
           mov     [si],ax      ;almacena parte decimal
           inc     si
           mov     ax,dx        ;el resto es ahora dividendo
           and     dx,00h
           loop    otroo         ;otro digito  
              
;---------- entera en hex, y decimal en ASCII --------------

           lea     si,resultdiv
           lea     di,rforconv
           mov     ax,[si]
           mov     [di],ax 
           
		   mov     bl,2ch
           mov     [si],bl ; Coma 
           mov     cx,5
decimm:           mov     al,[si+2]
           or      al,30h
           mov     [si+1],al
           inc     si
           loop    decimm
divi200:		   
			ret
dividir		endp
;-------------------------------------------------------------			
raiz		proc
			mov     cx,10          
			mov     ax,[di] ; aprox
			mov     bx,[si] ; dato a sacar la raiz cuadrada
			mov     cx,ax
aproximado:			
			cmp     ax,bx     ; buscamos el valor aproximado de la raiz
			je      cuadrado  ; cuando la raiz es exacta
			jc      aument    
			dec     cx        ; cx valor aproximado
            jmp     salir25
			
aument:     inc     cx  
            mov     ax,cx     
            mul     cx
            jmp    aproximado
salir25: 			
			mov     [di],cx   ; cx valor aproximado
			mov     ax,cx
			mul     cx   
			mov     [aprox2],ax ; valor aproximado al cuadrado
			add     ax,[si]
			adc     dx,0h ; carry
			mov     [num],dx     ; DIVISOR
			mov     [num+1],ax   ;  DX:AX
			mov     bx,[di]
			mov     cl,1
			shl     bx,cl    
			mov     [den],bx   ; para la division: 'BX' divisor y 'DX:AX' dividendo
;---------------------------------------------------------
;                        Parte entera
;                        ------------
           mov     cx,4         ;numero de digitos  
     	   div     bx
		   lea     si,resultraiz ;dir. de resultado
		   mov     [si],ax      ;almacena parte entera
           inc     si
           mov     ax,dx        ;dividendo=resto
           and     dx,00h
;----------------------------------------------------------
;                       Parte decimal
;                       -------------
otro26:
           mul     byte2        ;dividendo=dividendo*10
           div     bx           ;entre divisor
           mov     [si],ax      ;almacena parte decimal
           inc     si
           mov     ax,dx        ;el resto es ahora dividendo
           and     dx,00h
           loop    otro26         ;otro digito  
           jmp     nocuadrado
           
cuadrado:            
           lea     si,resultraiz
           mov     [si],cx
;------------------------------------------------------------			
;-------------------- binario a ASCCI -----------------------
nocuadrado:			
            lea     si, bcd
            lea     di, resultraiz

			mov     cx,5
genbcd:     push    cx
	
			mov     ax,00h    ; solo se lee dato en AL  
			mov     al,[di]   ; resultado
			inc     di
			mov 	cl,64h  ;100 en decimal
			div     cl      ;divisione en al 
			mov     bh,ah   ;resto en bh
			aam
			or      ax,3030h
			mov     [si+0],ah
			mov     [si+1],al
			xchg    al,bh
			aam     
			or      ax,3030h
			mov     [si+2],ah
			mov     [si+3],al
            add     si,4    ; incrementamos bcd 4 veces
            pop     cx
            loop    genbcd 
;------- ordenamos en 'mostrar', para desplegar el resultado en patalla (ASCII)-----
            lea     si,bcd 
            lea     di,mostrar  
            
            mov     al,[si+1]
            mov     [di],al
            mov     al,[si+2]           
            mov     [di+1],al
            mov     al,[si+3]           
            mov     [di+2],al    
            
            mov     bl,2ch
            mov     [di+3],bl ; coma
            
            mov     al,[si+7]
            mov     [di+4],al
            mov     al,[si+11]           
            mov     [di+5],al
            mov     al,[si+15]           
            mov     [di+6],al
            mov     al,[si+19]           
            mov     [di+7],al 

            lea     si,mostrar
            mov     cx,3
            
arregloo:   
            mov     al,[si]   ;para borrar
            cmp     al,30h    ;los ceros
            jne     listooo   ;de adelante 
            mov     ah,20h    ;del resultado
            mov     [si],ah   ;ejemplo:
            inc     si        ;067,87500 ->
            loop    arregloo  ;-> 67,87500
listooo:            			
			
			ret
raiz		endp
;-------------------------------------------------------------	
;----------------------------------------------------------------
;	convertir de binario-hexadecimal a codigo ASCII
h_asc	proc
	lea	di,proAsc
	mov	cx,20
paso2:
	push	cx
	lea	si,prodhex
	xor	dx,dx
	mov	cx,4
paso1:
	mov	ax,[si]
	div	factor1	; dx:ax
			;------- = dx(residuo "DL"):ax(cociente)
			;factor1
	mov	[si],ax
	inc	si
	inc	si
	loop	paso1
	pop	cx
	push	dx
	loop	paso2

	mov	cx,20
numero:
	pop	dx
	cmp	dl,0
	jne	valor
	dec	cx
	cmp	cx,0
	je	salir1
	jmp	numero
salir1:
	mov	dl,30h
	mov	[di],dl
	inc	di
	jmp	dolar
numero1:
	pop	dx
valor:
	or	dl,30h
	mov	[di],dl
	inc	di
	loop	numero1
dolar:
	mov	dl,24h
	mov	[di],dl

	ret
h_asc	endp	
;--------------------------------------------------------
help		proc
			mov     cx,22 			;desplegando mensaje de ayuda 
			mov     si,002ah		;a usuario
			lea     di,ayuda
despayuda:				
			mov     dx,si
			call    poncur
     		add     si,0100h
			
			mov     dx,di
			call    escritura
            add     di,36 ; # de caracteres por fila
			loop    despayuda			
			ret
help		endp				
;---------------------------------------------------------
codigo     ends
           end     programa