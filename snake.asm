	; Carlos Abia Merino, Ingeniería Informática, 2B
	; Práctica realizada individualmente.

	output "prueba.bin"
	ORG $8000
	DI

;;-----------------------------------------
;;		DEFINICIÓN VARIABLES GLOBALES
;;-----------------------------------------

	LD sp, 0					; inicialización de pila
	LD ix, serp					; apunto a Xcola
	JR inicio
	INCLUDE "teclado.asm"
	INCLUDE "aleatorio.asm"

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
	
	; Genero 3 manzanas para comenzar el juego
	CALL generador
	CALL generador
	CALL generador
	LD e, 0	; Reset del byte principal
bucle_juego:
	; Resets
	RES 3, e 	; Manzana
	RES 4, e   	; Choque


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
;;			CHECK CABEZA
;;-----------------------------------------


chk_cabeza:
	BIT 2, e 							; Compruebo si el avance es en X o en Y 
	JR NZ, chk_cabeza_avanzaPos_Y
	JR Z, chk_cabeza_avanzaPos_X 		

		
	;BIT 3, e 							; Compruebo si encontré una manzana
	;JP Z, chk_cabeza_mantiene 

	;RET

; ----------------; ----------------

chk_cabeza_avanzaPos_X:
	BIT 1, e 							; Compruebo si me muevo a izqda o dcha
	JR NZ, chk_cabeza_avanzaPos_X_izqda
	JR Z, chk_cabeza_avanzaPos_X_dcha

	;RET

chk_cabeza_avanzaPos_X_dcha:
	; Coordenada Ycabeza
	; Se queda igual

	; Coordenada Xcabeza
	LD c, (iy)			; cojo la Xcabeza anterior
	INC c 					; xAnterior + 1
	LD hl, iy 
	JR chk_cabeza_chk_pos_h
	
	;RET 

; ----------------

chk_cabeza_avanzaPos_X_izqda:
	; Coordenada Ycabeza
	; Se queda igual

	; Coordenada Xcabeza
	LD c, (iy)			; cojo la Xcabeza anterior
	DEC c 					; xAnterior - 1
	LD hl, iy 
	JR chk_cabeza_chk_pos_h
	
	;RET

; ----------------; ----------------

chk_cabeza_avanzaPos_Y:
	BIT 1, e 							; Compruebo si me muevo arriba o abajo
	JR NZ, chk_cabeza_avanzaPos_Y_abajo
	JR Z, chk_cabeza_avanzaPos_Y_arriba

	RET
chk_cabeza_avanzaPos_Y_abajo:
	; Coordenada Ycabeza
	; Se queda igual

	; Coordenada Xcabeza
	LD c, (iy+1)			; cojo la Ycabeza anterior
	INC c 					; yAnterior + 1
	LD hl, iy 
	INC hl					; avanzo a yCabeza
	JR chk_cabeza_chk_pos_v
	;LD (hl), c
	
	;RET

; ----------------

chk_cabeza_avanzaPos_Y_arriba:
	; Coordenada Ycabeza
	; Se queda igual

	; Coordenada Xcabeza
	LD c, (iy+1)			; cojo la Ycabeza anterior
	DEC c 					; yAnterior - 1
	LD hl, iy 
	INC hl					; avanzo a yCabeza
	JR chk_cabeza_chk_pos_v
	;LD (hl), c
	
	;RET

; ----------------; ----------------

chk_cabeza_chk_pos_h:
	LD a, c 				; Cargo C en A
	CP 0					; Choque pared derecha
	CALL Z, chk_cabeza_choque
	CP 32					; Choque pared izqda
	CALL Z, chk_cabeza_choque
	
	PUSH de
	PUSH hl
	JR chk_cabeza_color_x ; Compruebo si la nueva cabeza está en una manzana o ha chocado con la serpiente 
	;POP hl
	;POP de

	RET

; ----------------

chk_cabeza_chk_pos_v:
	LD a, c 				; Cargo C en A
	CP 0					; Choque pared arriba
	CALL Z, chk_cabeza_choque
	CP 24					; Choque pared abajo
	CALL Z, chk_cabeza_choque
	
	PUSH de
	PUSH hl
	JR chk_cabeza_color_y ; Compruebo si la nueva cabeza está en una manzana o ha chocado con la serpiente
	;POP hl
	;POP de
	
	RET

; ----------------
chk_cabeza_choque:
	SET 4, e
	RET

chk_cabeza_color_y:
	LD e, (iy)				; Coordenada x
	LD d, c 				; Coordenada y
	CALL calculaCuadro
	LD a, (hl)
	CP 16 					; Encontró una manzana
	JR Z, chk_cabeza_aumenta_y
	CP 32 					; Encontró su propio cuerpo
	JP Z, fin
	
	; Si no ha chocado ni con paredes ni con el cuerpo y tampoco crece, se mantiene
	POP hl
	POP de 
	JR chk_cabeza_mantiene
	;RET

chk_cabeza_color_x:
	LD e, c					; Coordenada x
	LD d, (iy+1) 			; Coordenada y
	CALL calculaCuadro
	LD a, (hl) 				; Cojo el color de la nueva baldosa
	CP 16 					; Encontró una manzana
	JR Z, chk_cabeza_aumenta_x
	CP 32 					; Encontró su propio cuerpo
	JP Z, fin 
	
	; Si no ha chocado ni con paredes ni con el cuerpo y tampoco crece, se mantiene
	POP hl
	POP de 
	JR chk_cabeza_mantiene
	;RET

chk_cabeza_mantiene:
	; Cuando no encuentra una manzana paso la nueva coordenada a la cabeza actual

	PUSH bc
	PUSH hl
	PUSH de
	CALL borraCola
	CALL cp_cuerpo
	POP de
	POP hl
	POP bc
	LD (hl), c

	RET

chk_cabeza_aumenta_x:
	; Cuando encuentra una manzana aumenta de tamaño, nueva cabeza
	; Muevo IY y le asigno los nuevos valores
	POP hl
	POP de

	INC iy
	LD a, (iy) 				; Me sitúo en yIYantigua y la guardo
	INC iy 					; Me sitúo en xIYnueva y le asigno el nuevo valor
	LD (iy), c
	INC iy
	LD (iy), a 				; Me sitúo en yIYnueva y le asigno el valor guardado anteriormente
	DEC iy 					; Dejo IY en la posición x
	; Aumento n_serp
	LD hl, n_serp
	INC (hl)
	; Genero otra manzana
	CALL generador

	RET
chk_cabeza_aumenta_y:
	; Cuando encuentra una manzana aumenta de tamaño, nueva cabeza
	; Muevo IY y le asigno los nuevos valores
	POP hl
	POP de

	LD a, (iy) 				; Me sitúo en xIYantigua y la guardo
	INC iy 					; Me sitúo en xIYnueva y le asigno el valor guardado
	INC iy
	LD (iy), a
	INC iy
	LD (iy), c 				; Me sitúo en yIYnueva y le asigno el nuevo valor
	DEC iy 					; Dejo IY en la posición x
	; Aumento n_serp
	LD hl, n_serp
	INC (hl)
	; Genero otra manzana
	CALL generador

	RET
;;-----------------------------------------
;;			FIN CHECK CABEZA
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

	LD (hl), 32					; Pinto el cuadro devuelto

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
	LD hl, dir_atributos

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
	PUSH de
	
	LD a, 32
	CALL aleatorio
	LD e, a
	
	LD a, 24
	CALL aleatorio
	LD d, a

	CALL calculaCuadro

	LD a, (hl)
	INC a
	DEC a 
	JR NZ, generador 

	LD (hl), 16

	POP de
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
	JR fin

dir_atributos EQU $5800

ult_mov: db 4
n_serp: db 4
serp: db 0, 4, 1, 4, 2, 4, 3, 4