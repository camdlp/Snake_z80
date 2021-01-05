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

