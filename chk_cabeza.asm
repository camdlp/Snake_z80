;;-----------------------------------------
;;			CHECK CABEZA
;;-----------------------------------------


chk_cabeza:
	BIT 2, e 							; Compruebo si el avance es en X o en Y 
	JR NZ, chk_cabeza_avanzaPos_Y
	;JR Z, chk_cabeza_avanzaPos_X 		

; ----------------; ----------------

chk_cabeza_avanzaPos_X:
	BIT 1, e 							; Compruebo si me muevo a izqda o dcha
	JR NZ, chk_cabeza_avanzaPos_X_izqda
	JR Z, chk_cabeza_avanzaPos_X_dcha


chk_cabeza_avanzaPos_X_dcha:
	; Coordenada Ycabeza
	; Se queda igual

	; Coordenada Xcabeza
	LD c, (iy)			; cojo la Xcabeza anterior
	INC c 					; xAnterior + 1
	LD hl, iy 
	JR chk_cabeza_chk_pos_h


; ----------------

chk_cabeza_avanzaPos_X_izqda:
	; Coordenada Ycabeza
	; Se queda igual

	; Coordenada Xcabeza
	LD c, (iy)			; cojo la Xcabeza anterior
	DEC c 					; xAnterior - 1
	LD hl, iy 
	JR chk_cabeza_chk_pos_h


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

; ----------------; ----------------

chk_cabeza_chk_pos_h:
	LD a, c 				; Cargo C en A
	CP 255					; Choque pared derecha
	CALL Z, chk_cabeza_choque
	CP 32					; Choque pared izqda
	CALL Z, chk_cabeza_choque
	
	PUSH de
	PUSH hl
	JR chk_cabeza_color_x ; Compruebo si la nueva cabeza está en una manzana o ha chocado con la serpiente 

	RET

; ----------------

chk_cabeza_chk_pos_v:
	LD a, c 				; Cargo C en A
	CP 0					; Choque pared arriba
	CALL Z, chk_cabeza_choque
	CP 25					; Choque pared abajo
	CALL Z, chk_cabeza_choque
	
	PUSH de
	PUSH hl
	JR chk_cabeza_color_y ; Compruebo si la nueva cabeza está en una manzana o ha chocado con la serpiente
	
	RET

; ----------------
chk_cabeza_choque:
	JP fin
	SET 4, e


chk_cabeza_color_y:
	LD e, (iy)				; Coordenada x
	LD d, c 				; Coordenada y
	CALL calculaCuadro
	LD a, (hl)
	CP 64+16	 			; Encontró una manzana
	JR Z, chk_cabeza_aumenta_y
	CP 32+7					; Encontró su propio cuerpo
	JP Z, fin
	
	; Si no ha chocado ni con paredes ni con el cuerpo y tampoco crece, se mantiene
	POP hl
	POP de 
	JR chk_cabeza_mantiene


chk_cabeza_color_x:
	LD e, c					; Coordenada x
	LD d, (iy+1) 			; Coordenada y
	CALL calculaCuadro
	LD a, (hl) 				; Cojo el color de la nueva baldosa
	CP 64+16				; Encontró una manzana
	JR Z, chk_cabeza_aumenta_x
	CP 32+7					; Encontró su propio cuerpo
	JP Z, fin 
	
	; Si no ha chocado ni con paredes ni con el cuerpo y tampoco crece, se mantiene
	POP hl
	POP de 
	JR chk_cabeza_mantiene


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
	PUSH de
	CALL generador
	POP DE

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
	PUSH de
	CALL generador
	POP de

	RET
;;-----------------------------------------
;;			FIN CHECK CABEZA
;;-----------------------------------------