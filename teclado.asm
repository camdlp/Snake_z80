	;output "prueba.bin"
	;ORG $8000

	; Creo un byte auxiliar que me servirá para indicar al programa auxiliar qué teclas de las
	; que me interesan están pulsadas.
	; Lo he codificado de la siguiente manera
	; 		0        1        2        3
	; 	 "Arriba" "Abajo"   "Dcha"   "Izda"
	; 
	; Mi byte auxiliar estará contenido en el registro D aunque devolveré el A
lee_teclado:
	
	XOR A

comprueba_Arriba:
	LD BC, $EFFE			; me posiciono en la fila correspondiente
	IN A, (C)				; leo del puerto
	BIT 3, A				; compruebo si está el bit de mi letra
	JR NZ, comprueba_Abajo	; si no lo está paso al siguiente
	LD D, 0 				; Si he pulsado una tecla borro la anterior
	SET 0, D				; si lo está pongo su bit del byte auxiliar a 1
comprueba_Abajo:
	; ya estoy en la fila correcta
	BIT 4, A				; compruebo si está el bit de mi letra a 0 
	JR NZ, comprueba_Dcha		; si no lo está paso al siguiente
	LD D, 0 				; Si he pulsado una tecla borro la anterior
	SET 1, D				; si lo está pongo su bit del byte auxiliar a 1
comprueba_Dcha:
	; ya estoy en la fila correcta
	IN A, (C)				; leo del puerto
	BIT 2, A				; compruebo si está el bit de mi letra 
	JR NZ, comprueba_Izqda		; si no lo está paso al siguiente
	LD D, 0 				; Si he pulsado una tecla borro la anterior
	SET 2, D				; si lo está pongo su bit del byte auxiliar a 1
comprueba_Izqda:
	LD BC, $F7FE			; me posiciono en la fila correspondiente
	IN A, (C)				; leo del puerto
	BIT 4, A				; compruebo si está el bit de mi letra 
	JR NZ, copia_nuevo		; si no lo está paso al siguiente
	LD D, 0 				; Si he pulsado una tecla borro la anterior
	SET 3, D				; si lo está pongo su bit del byte auxiliar a 1
 
copia_nuevo:
	LD A, D

	INC A
	DEC A					; fuerzo la detección del flag Z
	;JR Z, lee_teclado		; si no he pulsado nada vuelvo a detectar teclas
	;LD (ult_mov), A
	RET
