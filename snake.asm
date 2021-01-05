	; Carlos Abia Merino, Ingeniería Informática, 2B
	; Práctica realizada individualmente.

	output "prueba.bin"
	ORG $8000
	;DI

;;-----------------------------------------
;;		DEFINICIÓN VARIABLES GLOBALES
;;-----------------------------------------

declaracion:

	LD sp, 0					; inicialización de pila
	LD ix, serp					; apunto a Xcola
	JP inicio
	INCLUDE "teclado.asm"
	INCLUDE "aleatorio.asm"
	INCLUDE "chk_cabeza.asm"

inicio:
	LD a, (n_serp)				; hago la cuenta (n-1)*2 para apuntar al x de la cabeza
	DEC a
	LD h, 0
	LD l, a
	ADD hl, hl
	PUSH hl
	POP bc
	LD hl, serp
	ADD hl, bc
	PUSH hl
	POP iy						; apunta a la Xcabeza
	
;;-----------------------------------------
;;	FIN DEFINICIÓN VARIABLES GLOBALES
;;-----------------------------------------

; BYTE PRINCIPAL
; 0 -> Borra cola
; 1 -> Dcha / Izq o Arriba / Abajo
; 2 -> Movimiento X o Y
; 3 -> Manzana
; 4 -> Choque
	
	; Añado un marco para mejorar la visibilidad
	LD a, 1
	out ($FE),a
	; Genero 3 manzanas para comenzar el juego
	
	PUSH de
	CALL generador
	CALL generador
	CALL generador
	POP de
	
	LD e, 0	; Reset del byte principal
bucle_juego:
	
	; Compruebo que no venga de un choque
	BIT 4, e
	JP NZ, fin

	; Resets
	RES 3, e 	; Manzana
	;RES 4, e   	; Choque


	CALL teclado
	
 	CALL chk_cabeza

	CALL pintaSerp

	LD b, 100					; hace el pause b veces
	CALL pausa

	JR bucle_juego
	
;;-----------------------------------------
;;				PARTE DE TECLADO
;;-----------------------------------------

teclado:
	PUSH de
	CALL lee_teclado						; llamo a lee teclado que solo retorna cuando se ha pulsado alguna tecla
	POP de

; Compruebo qué BIT está en 1 para saber qué tecla se pulsó
; 0 -> Arriba
; 1 -> Abajo
; 2 -> Dcha
; 3 -> Izqda

	BIT 2, e 								; Comprubelo si en el byte principal, pone que se mueve en vertical(1) u horizontal(0)
	JR Z, chk_Y  							; y buscaré una pulsación en el eje contrario

; ----------------
chk_X:

chk_X_Dcha:
	BIT 2, a
	JR Z, chk_X_Izqda
	; Se ha pulsado la tecla correspondiente
	RES 2, e 								; Indico que nos movemos en horizontal
	RES 1, e 								; Indico que nos movemos hacia la derecha

chk_X_Izqda:
	BIT 3, a
	JR Z, teclado_fin 						
	; Se ha pulsado la tecla correspondiente
	RES 2, e 								; Indico que nos movemos en horizontal
	SET 1, e 								; Indico que nos movemos hacia la izquierda
	JR teclado_fin

; ----------------

chk_Y:

chk_Y_Arriba:
	BIT 0, a
	JR Z, chk_Y_Abajo
	; Se ha pulsado la tecla correspondiente
	SET 2, e 								; Indico que nos movemos en vertical
	RES 1, e 								; Indico que nos movemos hacia Arriba

chk_Y_Abajo:
	BIT 1, a
	JR Z, teclado_fin
	; Se ha pulsado la tecla correspondiente
	SET 2, e 								; Indico que nos movemos en vertical
	SET 1, e 								; Indico que nos movemos hacia Abajo
	
; ----------------
	
teclado_fin:
	;CALL avanzaPos_derecha
	RET

;;-----------------------------------------
;;				FIN PARTE DE TECLADO
;;-----------------------------------------


;;-----------------------------------------
;;			AVANZA POSICIÓN SERPIENTE
;;-----------------------------------------
borraCola:
	LD e, (ix)
	LD d, (ix+1)
	CALL calculaCuadro
	LD (hl), 0					; Pongo el recuadro en negro

	RET

;;-----------------------------------------
;;			COPIA CUERPO
;;-----------------------------------------

cp_cuerpo:				; (n_serp - 1)*2
	LD a, (n_serp)
	DEC a
	LD h, 0
	LD l, a
	ADD hl, hl
	PUSH hl
	POP BC


cp_cuerpo_ldir:
	PUSH ix
	POP hl
	INC hl
	INC hl
	PUSH ix
	POP de
	LDIR
	
	RET

;;-----------------------------------------
;;			FIN COPIA CUERPO
;;-----------------------------------------




;;-----------------------------------------
;;			PINTA SERPIENTE
;;-----------------------------------------
pintaSerp:
 	
	PUSH ix
	PUSH de	

	LD ix, serp
	LD a, (n_serp)
	LD c, a 					; cargo el número de elementos en c (HASTA 255 CUADROS DE SERPIENTE)

pintaSerp_bucle:	
	LD d, (ix+1)				; Coordenada Y a calcular
	LD e, (ix)					; Coordenada X a calcular
	CALL calculaCuadro

	LD a, (color_serp)
	LD (hl), a 					; Pinto el cuadro devuelto

pintaSerp_bucle_sig:
	INC ix						; Paso a la siguiente posición
	INC ix
	DEC c 						; Decremento el número de elementos
	JR NZ, pintaSerp_bucle 		; Si quedan elementos sigo

	POP de
	POP ix
	
	RET

;;-----------------------------------------
;;		FIN PINTA SERPIENTE
;;-----------------------------------------


;;-----------------------------------------
;;		CALCULA CUADRO
;;-----------------------------------------
; Calcula la posición de memoria en el paper a partir de coordenadas X,Y dadas
; Le paso en E la coordenada X y en D la coordenada Y a calcular

calculaCuadro:
	PUSH de 					; Lo copio a la pila para poder machacarlo

calculaCuadro_calcY:
	LD a, d
	LD b, a 					; b es ahora la coordenada y
	LD de, 32					; de vale 32 (una "fila" del paper)
	LD hl, dir_atributos-32 	; Compenso el desfase que se produce en el bucle calculaCuadro_calcYbucle

calculaCuadro_calcYbucle:			; multiplico por 32*y para situarme en la fila indicarda por y
	ADD hl, de
	DJNZ calculaCuadro_calcYbucle

calculaCuadro_sumaX:
	POP de 						; Recupero DE para obtener el valor que se pasó al inicio y que había machacado
	LD d, 0				
	;LD e, (ix)					; pongo en de mi coordenada x
	ADD hl, de					; sumo la coordenada x

	RET 						; Devuelvo en HL la dirección del cuadro pasado en el paper


;;-----------------------------------------
;;		FIN CALCULA CUADRO
;;-----------------------------------------

;;-----------------------------------------
;;				GENERA MANZANAS
;;-----------------------------------------

generador:
	
	
	LD a, 32
	CALL aleatorio
	LD e, a
	
	LD a, 24
	CALL aleatorio
	LD d, a

	CALL calculaCuadro

	LD a, (hl)					; Compruebo si el cuadrado está en negro
	CP 0
	JR NZ, generador 

	LD a, (color_manz)
	LD (hl), a

	RET

;;-----------------------------------------
;;				FIN DE GENERA MANZANAS
;;-----------------------------------------

;------------------------------------------
;               PAUSA - codigo extraido de la plantilla banderas_extendido aunque modificado para una pausa más corta
;------------------------------------------
pausa: 	
	PUSH af									; Salva registros utilizados en la pila
	PUSH de
	PUSH bc


paus0:  
	LD e, 0 								; Inicializa E a 0 para ciclar 2e8 (256) en el bucle interno
paus1:	
	DEC e 									; Decrementa E. En la primera vuelta, E valdrá 255
	LD a,e 									
	JR NZ, paus1							; Si E no es 0, sigue el bucle inteno
	DJNZ paus0                      		; B=B-1 y cicla a bucle externo hasta que B sea 0

	POP bc
	POP de 									; Recupera registros utilizados desde la pila
	POP af
											
	RET 									; Retorna al punto de llamada

;------------------------------------------
;               FIN PAUSA
;------------------------------------------

fin:	
	LD hl, color_serp
	LD (hl), 128+32 						; La serpiente parpadea indicando un choque
	CALL pintaSerp
	LD b, 255
	
	CALL pausa
	LD b, 255
	CALL pausa
	LD HL, 0         			; Origen: la ROM
  	LD DE, dir_atributos     	; Destino: atributos
  	LD BC, 768      			; toda la pantalla
  	LDIR             			; copiar
  	
  	LD b, 255
  	CALL pausa

  	; Limpio toda la pantalla 
  	LD HL, dir_atributos        ; Origen: atributos
  	LD (hl), 0
  	LD DE, dir_atributos+1     	; Destino: atributos+1
  	LD BC, 768      
  	LDIR 

  	LD b, 255
  	CALL pausa
  	
  	; Restauro el color de la serpiente
  	LD hl, color_serp
  	LD (hl), 32+7

  	; Restauro la serpiente original
  	LD hl, serp
  	LD (hl), 0
  	INC hl
  	LD (hl), 4
  	INC hl
  	LD (hl), 1
  	INC hl
  	LD (hl), 4

  	; Restauro el tamaño original de la serpiente
  	LD hl, n_serp
  	LD (hl), 2

  	; Reinicio el juego
  	JP declaracion

	;JR fin

dir_atributos EQU $5800

color_serp: db 32+7
color_manz: db 64+16
n_serp: db 2
serp: db 0, 4, 1, 4