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

; 0 -> Borra cola
; 1 -> Dcha / Izq o Arriba / Abajo
; 2 -> Movimiento X o Y
; 3 -> Manzana

bucle_juego:
	XOR A
	CALL teclado
	
	; Borraré la cola antes de copiar el cuerpo porque el valor de ix ya cambia
	CALL borraCola

	CALL cp_cuerpo

	CALL pintaSerp

	
	
	


	LD b, 100					; hace el pause b veces
	CALL pausa

	JR bucle_juego
	
;;-----------------------------------------
;;				PARTE DE TECLADO
;;-----------------------------------------
teclado:
	PUSH a
	CALL lee_teclado						; llamo a lee teclado que solo retorna cuando se ha pulsado alguna tecla


	JR Z, teclado_fin

; Compruebo qué BIT está en 1 para saber qué tecla se pulsó
; 0 -> Arriba
; 1 -> Abajo
; 2 -> Dcha
; 3 -> Izqda

chk_Arriba:
	BIT 0, a
	JR NZ, avanzaPos_arriba 					; si tiene un 1 en la posición, paso a pintar la bandera (no hace falta saltar ninguna)
	
chk_Abajo:
	BIT 1, a
	JR NZ, avanzaPos_abajo 					; si tiene un 1 en la posición, paso a saltar las banderas correspondientes
	
chk_Dcha:
	BIT 2, a
	JR NZ, avanzaPos_derecha 					; si tiene un 1 en la posición, paso a saltar las banderas correspondientes
	
chk_Izqda:
	BIT 3, a
	JR NZ, avanzaPos_izqda 					; si tiene un 1 en la posición, paso a saltar las banderas correspondientes
	
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
;;			COMPRUEBA CHOQUES
;;-----------------------------------------


chk_cabeza:

	CALL avanzaPos_derecha
	RET

chk_pos_h:
	LD a, c 				; Cargo C en A
	CP 0					; Choque pared derecha
	JP Z, fin
	CP 32					; Choque pared izqda
	JP Z, fin
	RET

chk_pos_v:
	LD a, c 				; Cargo C en A
	CP 0					; Choque pared arriba
	JP Z, fin
	CP 24					; Choque pared abajo
	JP Z, fin
	RET

;;-----------------------------------------
;;			FIN COMPRUEBA CHOQUES
;;-----------------------------------------

;;-----------------------------------------
;;			AVANZA POSICIÓN
;;-----------------------------------------

avanzaPos_derecha:
	; Coordenada Ycabeza
	; Se queda igual

	; Coordenada Xcabeza
	LD c, (iy)			; cojo la Xcabeza anterior
	INC c 					; xAnterior + 1
	LD hl, iy 
	CALL chk_pos_h
	LD (hl), c
	RET

avanzaPos_izqda:
	; Coordenada Ycabeza
	; Se queda igual

	; Coordenada Xcabeza
	LD c, (iy)			; cojo la Xcabeza anterior
	DEC c 					; xAnterior - 1
	LD hl, iy 
	CALL chk_pos_h
	LD (hl), c
	
	RET
avanzaPos_abajo:
	; Coordenada Ycabeza
	; Se queda igual

	; Coordenada Xcabeza
	LD c, (iy+1)			; cojo la Ycabeza anterior
	INC c 					; yAnterior + 1
	LD hl, iy 
	INC hl					; avanzo a yCabeza
	CALL chk_pos_v
	LD (hl), c
	
	RET

avanzaPos_arriba:
	; Coordenada Ycabeza
	; Se queda igual

	; Coordenada Xcabeza
	LD c, (iy+1)			; cojo la Ycabeza anterior
	DEC c 					; yAnterior - 1
	LD hl, iy 
	INC hl					; avanzo a yCabeza
	CALL chk_pos_v
	LD (hl), c
	
	RET


;;-----------------------------------------
;;			FIN AVANZA POSICIÓN
;;-----------------------------------------


;;-----------------------------------------
;;			PINTA SERPIENTE
;;-----------------------------------------
pintaSerp:
 	
	PUSH ix	

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