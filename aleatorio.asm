;--------------------------------------------------------------------------------------------
; Funcion aleatorio - Recibe en A el rango y devuelve en A un numero entre [0,Rango)
;--------------------------------------------------------------------------------------------
aleatorio:
		push hl
		push bc

		ld b,a 							; Guarda valor del rango
		ld a,r							; Carga el registro R	
		ld l,a		
		and $2F							; Acude a una dirección de la ROM para coger un dato
		ld h,a							
buscaRND:
		inc hl
		ld a, (hl)	
		cp b
		jr nc, buscaRND 				; Busca el siguiente hasta que sea menor que Rango
		
		pop bc	
		pop hl
		ret				