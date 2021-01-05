; Carlos Abia Merino, Ingeniería Informática, 2B
; Práctica realizada individualmente.
; 
; PRÁCTICA FINAL - SNAKE_Z80
; Instrucciones de uso:
; - La serpiente se mueve con las flechas del teclado. 
; - La partida termina cuando la serpiente se choca con una de las paredes o consigo misma
; - El juego realmente nunca acaba sino que se reinicia automáticamente tras perder.
; 
; Consideraciones generales: 
; - He intentado crear un código legible, ordenado y escalable.
; - Está desarrollado íntegramente en paper.
; - En esta versión que se presenta no he encontrado ningún bug.
; - El juego consta de 3 archivos:
;	+ snake.asm: principal
; 	+ teclado.asm: lectura del teclado.
; 	+ chk_cabeza: comprueba la siguiente cabeza que se añadirá a la serpiente.
; 	+ pinta_serp: pinta el array que compone la serpiente en pantalla.
; - El programa viene controlado por un byte auxiliar, este se guardará en el registro E:
;	+ 0: Borra cola / Crece
;	+ 1: Derecha | Izquierda || Arriba | Abajo
;	+ 2: Eje X | Eje Y
;	+ 3: Manzana
;	+ 4: Choque
;	Todos estos bits permiten a las diferentes funciones conocer el estado de cualquier parámetro  
;	de la serpiente en caso de necesitarlo. Asimismo aún hay bits libres por lo que se podrían 
;	añadir más parámetros en caso de requerirlo.
;   

	output "snake.bin"
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
	INCLUDE "pinta_serp.asm"



inicio:
	; Posiciono el registro IY en la posición x de la cabeza.
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
	POP iy						; apunta a la IYXcabeza
	

	
	; Añado un marco azul para mejorar la visibilidad de los límites
	LD a, 1
	out ($FE),a

	; Genero 3 manzanas para comenzar el juego. En caso de querer modificar el número de manzanas simultáneas
	; bastaría con eliminar o añadir un CALL generador
	PUSH de
	CALL generador
	CALL generador
	CALL generador
	POP de
	
	LD e, 0	; Reset del byte principal

;;-----------------------------------------
;;	FIN DEFINICIÓN VARIABLES GLOBALES
;;-----------------------------------------

;;-----------------------------------------
;;			BUCLE DEL JUEGO
;;-----------------------------------------
bucle_juego:
	
	; Resets de bits del byte principal
	RES 3, e 	; Manzana
	; El resto los dejo para saber de dónde viene la serpiente.

	; Llamo a la función teclado de teclado.asm, esta, devolverá un BYTE en A codificado
	; de la siguiente manera (si el bit está a 1 es que se pulsó esa tecla)
	; 		0        1        2        3
	; 	 "Arriba" "Abajo"   "Dcha"   "Izda"
	CALL teclado
	
	; Llamo a la función chk_cabeza, esta, usa el byte principal para determinar
	; dónde irá la siguiente cabeza. Además, cambia el array de la serpiente, 
	; borra la cola, mueve el cuerpo y posiciona la nueva cabeza. 
 	CALL chk_cabeza

 	; Llamo a la función pintaSerp, esta, usa el array de la serpiente y su extensión para pintarla 
 	; en pantalla.
	CALL pintaSerp

	; Hago una pausa entre movimientos. Se puede usar para determinar la dificultad. Está puesto en
	; un punto intermedio 100 pero se podría modificar en el intervalo [40-255] 
	LD b, 100					; hace el pause b veces
	CALL pausa

	; Bucle
	JR bucle_juego

;;-----------------------------------------
;;			FIN BUCLE DEL JUEGO
;;-----------------------------------------

;;-----------------------------------------
;;				PARTE DE TECLADO
;;-----------------------------------------

teclado:
	PUSH de
	CALL lee_teclado						; llamo a lee teclado que me devolverá las pulsaciones en A
	POP de

; Dependiendo de en qué dirección me estuviera moviendo previamente (BIT 2 del byte principal), escucharé o no las pulsaciones.
; Esto evita que la serpiente quiera volver sobre sus propios pasos o iterar innecesariamente para acabar moviéndome en la 
; misma dirección

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
	RET

;;-----------------------------------------
;;				FIN PARTE DE TECLADO
;;-----------------------------------------

;;-----------------------------------------
;;				BORRA COLA
;;-----------------------------------------

; Borro la cola, posicionada en IX
borraCola:
	LD e, (ix)
	LD d, (ix+1)
	; Paso IXx e IXy a calculaCuadro que me devuelve en HL la dirección que representan
	CALL calculaCuadro
	LD (hl), 0					; Pongo el recuadro en negro

	RET

;;-----------------------------------------
;;				FIN BORRA COLA
;;-----------------------------------------

;;-----------------------------------------
;;			COPIA CUERPO
;;-----------------------------------------
; En el array de la serpiente, muevo los datos hacia la izquierda desde la cabeza hasta la cola.

; Calculo (n_serp - 1)*2 para sacar BC (número de datos que se transfieren)
cp_cuerpo:				
	LD a, (n_serp)
	DEC a
	LD h, 0
	LD l, a
	ADD hl, hl
	PUSH hl
	POP BC

; Hago ldir (transferencia de memoria a memoria).
cp_cuerpo_ldir:
	PUSH IX
	POP HL 				
	INC HL 
	INC HL  		; Fuente: IX + 2
	PUSH IX
	POP DE 			; Destino: IX
	LDIR
	
	RET

;;-----------------------------------------
;;			FIN COPIA CUERPO
;;-----------------------------------------



;;-----------------------------------------
;;		CALCULA CUADRO
;;-----------------------------------------
; Calcula la posición de memoria en el área de atributos a partir de coordenadas X,Y dadas
; Le paso en E la coordenada X y en D la coordenada Y a calcular

calculaCuadro:
	PUSH de 					; Lo copio a la pila para poder machacarlo

calculaCuadro_calcY:
	LD a, d
	LD b, a 					; b es ahora la coordenada y
	LD de, 32					; de vale 32 (una "fila" del paper)
	LD hl, dir_atributos-32 	; Compenso el desfase que se produce en el bucle calculaCuadro_calcYbucle

calculaCuadro_calcYbucle:			; multiplico por 32*y para situarme en la fila indicada por y
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
; Mi generador de manzanas.
generador:
	; Saco 2 números aleatorios sin salirme de la pantalla
	LD a, 32 ; X
	CALL aleatorio
	LD e, a
	
	LD a, 24; Y
	CALL aleatorio
	LD d, a

	; Traduzco las coordenadas. Me devuelve la posición de memoria en HL.
	CALL calculaCuadro

	; Compruebo si la dirección de pantalla está "en negro"
	LD a, (hl)					
	CP 0
	JR NZ, generador 

	; Si está en negro pongo una manzana en dicha dirección
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


; Recibe en B el número de pausas "cortas" que debe hacer.
pausa_larga: 
	PUSH bc
	LD b, 255
	CALL pausa
	POP bc
	DJNZ pausa_larga
	
	RET

;------------------------------------------
;               FIN PAUSA
;------------------------------------------

; Creo una animación que haga entender al usuario que la partida ha terminado
; y reseteo el juego. 

fin:	
	LD a, 2 					; Cambio de color el marco a rojo
	out ($FE),a

	LD hl, color_serp
	LD (hl), 128+32 			; La serpiente parpadea indicando un choque
	CALL pintaSerp
	
	LD b, 5
	CALL pausa_larga

	LD b, 255
	CALL pausa

	; Paso la información de la ROM a dir_atributos. Esto hará que se pongan colores "aleatorios" en pantalla,
	; una especie de simulación de pantalla de carga.
	LD HL, 0         			; Origen: la ROM
  	LD DE, dir_atributos     	; Destino: atributos
  	LD BC, 768      			; Todo el área de atributos
  	LDIR             			; Copia
  	
  	LD b, 3
	CALL pausa_larga

  	; Limpio toda la pantalla 
  	LD HL, dir_atributos        ; Origen: atributos
  	LD (hl), 0
  	LD DE, dir_atributos+1     	; Destino: atributos+1
  	LD BC, 768      
  	LDIR 

  	
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


; Dirección del área de atributos en memoria
dir_atributos EQU $5800

; Color de la serpiente
color_serp: db 32+7
; Color de la manzana
color_manz: db 64+16
; Tamaño de la serpiente
n_serp: db 2
; Array de la serpiente
serp: db 0, 4, 1, 4