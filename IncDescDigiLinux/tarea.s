#---grupo 04-----
#carlo inti ALARCON COSS COAQUIRA
#jorge luis MOLLERICON GARCIA

#-----------------------------MACROS PARA NCURSES----------------
#ejemplo >> init_pair(1,COLOR_WHITE,COLOR_BLUE);

.MACRO	_init_pair pair foreground background
	pushl	\background
	pushl	\foreground
	pushl	\pair
	call	init_pair
	addl	$12,%esp
.ENDM
#----------------------------------------
.MACRO	_use_pair pair
#ejemplo >> attron(COLOR_PAIR(1));
	movl	\pair,%eax
	pushl	%eax
	movl	stdscr,%eax
	pushl	%eax
	call	wattr_on
	addl	$8,%esp
.ENDM
#--------------------------------------------
.MACRO	_bkgd pair
#fondo de pantalla
	movl	\pair,%eax
	pushl	%eax
	movl	stdscr,%eax
	pushl	%eax
	call	wbkgd
	addl	$8,%esp
.ENDM
#-----------------------------------------------
.MACRO	_mvadd_str fil col mensaj
	pushl	\col			#posiciona cursor y 
	pushl	\fil			#escribe cadena de 
	movl	stdscr,%eax		#caracteres
	pushl	%eax
	call	wmove
	addl	$12,%esp
	pushl	$\mensaj
	call	printw
	addl	$4,%esp
.ENDM
#--------------------------------------------------------------
.MACRO	_pocur fil col
	pushl	\col		#posiciona el cursor
	pushl	\fil
	movl	stdscr,%eax
	pushl	%eax
	call	wmove
	addl	$12,%esp
.ENDM
#----------------------------------------------------------------
.macro	desplegar car1 car2 car3 car4 car5 car6
	_mvadd_str $10,$20,\car1	#despliega cadena de 
	_mvadd_str $11,$20,\car2	#caracteres por filas
	_mvadd_str $12,$20,\car3
	_mvadd_str $13,$20,\car4
	_mvadd_str $14,$20,\car5
	_mvadd_str $15,$20,\car6
.endm
#----------------------------------------------------------------
.section .data		
	texto:	.asciz	" vanzar    etroceder    alir"
	tex2:	.asciz	"A"
	tex3:	.asciz	"R"
	tex4:	.asciz	"S"
	tenis:	.asciz	"_"
	tenis1:	.asciz	"|"
	PosX:	.int	1
	PosY:	.int	2
	cont:	.byte	0
	cade1:	.asciz	"   o"
	cade2:	.asciz	"  o "
	cade3:	.asciz	" o  "
	cade4:	.asciz	"o   "
	cade5:	.asciz	" oo "
	cade6:	.asciz	"o  o"
	cade7:	.asciz	"o o "
	cade8:	.asciz	"oooo"
	cade9:	.asciz	"ooo "
	cade10:	.asciz	" ooo"
#----------------------------------------------------------------
.section .text		
.globl _start		
_start:
#------------------------------------------------------
	call	initscr
        call    start_color
#inicializamos los formatos de atributos 1 y 2
	_init_pair $1 $7 $4	#pair color_primer_plano color_fondo
	_init_pair $2 $1 $4	
#Definimos fondo de la ventana con pair 2
	_bkgd $0x00000100		#fondo azul	
#Imprimimos texto
        _use_pair $0x00000200		# pair 2 (antes de imprimir algo debemos asignar atributo, o sea pair)
#posicionamos las lineasverticales y horzontales
	call	horiz
	movl	$5,PosY
	movl	$1,PosX
	call	horiz
	movl	$19,PosY
	movl	$1,PosX
	call	horiz
	movl	$3,PosY
	movl	$76,PosX
	call	vert
	movl	$3,PosY
	movl	$1,PosX
	call	vert
#desplegamos textos
	_mvadd_str $4,$3,texto	# y recien imprimir		
	_use_pair $0x00200100		#pair 1 
	_mvadd_str $4,$3,tex2		#imprimimos por separado 
	_mvadd_str $4,$13,tex3		#letras de atributo diferente
	_mvadd_str $4,$26,tex4
        _use_pair $0x00000200		# pair 2  		     		call	refresh
	#call	getch	# espera un caracter en teclado	
	movl	stdscr, %eax
	movl	%eax, (%esp)
	call	noecho
#deshabilitamos eco al usar "getch" 	
	pushl	$0
	call	curs_set
	addl	$4,%esp
	desplegar cade5,cade6,cade6,cade6,cade6,cade5
.seguir:
	call	wgetch
	cmpl	$115, %eax	#Tecla 's'?
	je	.terminar
	cmpl	$0x53, %eax	#Tecla 'S'?
	je	.terminar
	cmpl	$0x61,%eax	#tecla 'a'
	je	avanzar
	cmpl	$0x41,%eax	#tecla 'A'
	je	avanzar
	cmpl	$0x72,%eax	#tecla 'r'
	je	retroceder
	cmpl	$0x52,%eax	#tecla 'R'
	je	retroceder	
	jmp	.seguir
avanzar:
	movb	cont,%al
	incb	%al
	cmpb	$9,%al
	ja	.seguir
	call	compa
	jmp	.seguir	
retroceder:
	movb	cont,%al
	decb	%al
	cmpb	$255,%al
	jne	zor
	mov	$0,%al
	jmp	.seguir
zor:
	cmpb	$0,%al
	call	compa
	jmp	.seguir
.terminar:
	call	endwin	#finalizamos 

	movl	$1,%eax	# fin del programa
	movl	$0,%ebx
	int	$0x80
#---------------------------------------------------
#--------------------------------------
.type	compa,	@function
compa:
	movb	%al,cont
	cmpb	$0,cont
	jne	nex0
	desplegar cade5,cade6,cade6,cade6,cade6,cade5
	jmp	final
nex0:	
	cmpb	$1,cont
	jne	nex1
	desplegar cade2,cade5,cade7,cade2,cade2,cade8
	jmp	final	
nex1:
	cmpb	$2,cont
	jne	nex2
	desplegar cade5,cade6,cade1,cade2,cade4,cade8
	jmp	final	
nex2:
	cmpb	$3,cont
	jne	nex3
	desplegar cade9,cade1,cade5,cade1,cade6,cade5
	jmp	final
nex3:
	cmpb	$4,cont
	jne	nex4
	desplegar cade1,cade6,cade6,cade8,cade1,cade1
	jmp	final
nex4:
	cmpb	$5,cont
	jne	nex5
	desplegar cade8,cade4,cade9,cade1,cade1,cade9
	jmp	final
nex5:
	cmpb	$6,cont
	jne	nex6
	desplegar cade10,cade4,cade9,cade6,cade6,cade5
	jmp	final
nex6:
	cmpb	$7,cont
	jne	nex7
	desplegar cade8,cade1,cade2,cade3,cade3,cade3
	jmp	final
nex7:
	cmpb	$8,cont
	jne	nex8
	desplegar cade5,cade6,cade5,cade6,cade6,cade5
	jmp	final
nex8:
	cmpb	$9,cont
	jne	final
	desplegar cade5,cade6,cade6,cade10,cade1,cade9
final:
	ret
#---------------------------------------------------------
.type	vert,	@function
vert:
	call	lineasv	# escribe texto en una posicion de pantalla
	incl	PosY
	cmpl	$20,PosY
	jne	vert
	ret	
#------------------------------------
.type	horiz,	@function
horiz:
	call	lineas	# escribe texto en una posicion de pantalla
	incl	PosX
	cmpl	$77,PosX
	jne	horiz
	ret	
#------------------------------------
.type	lineas,	@function
lineas:
	pushl	PosX
	pushl	PosY
	call	move
	addl	$8,%esp
	pushl	$tenis
	call	printw
	addl	$4,%esp
	ret
#------------------------------------
.type	lineasv,	@function
lineasv:
	pushl	PosX
	pushl	PosY
	call	move
	addl	$8,%esp
	pushl	$tenis1
	call	printw
	addl	$4,%esp
	ret

