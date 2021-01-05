;--------------------------------------------------------------------------------------------
; Funcion aleatorio - Recibe en A el rango y devuelve en A un numero entre (0,Rango)
;--------------------------------------------------------------------------------------------
aleatorio:
	PUSH hl
	PUSH bc

	LD b,a 							; Guarda valor del rango
	LD a,r							; Carga el registro R	
	LD l,a		
	AND $2F							; Acude a una dirección de la ROM para coger un dato
	LD h,a							
buscaRND:
	INC hl
	LD a, (hl)	
	CP b
	JR NC, buscaRND 				; Busca el siguiente hasta que sea menor que Rango
	CP 0 							; Evita que devuelva 0
	JR Z, buscaRND
	POP bc	
	POP hl
	RET				