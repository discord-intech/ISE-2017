; Nom
; Description : 
; Auteurs : Louis-Baptiste & Discord
; Date : 2017/02/01

;---------------------------------------------------------------------------------------------------------
; Declaration des variables

; Variables du programme principal




;---------------------------------------------------------------------------------------------------------
;Implementation des adresses

;Programme principal au reset
				org	0000h									;adresse du PC après RESET materiel
            LJMP  debut
            
				org   0013h                         ; INT0
				LJMP	interrupt

;---------------------------------------------------------------------------------------------------------
;Programme principal

				org   0030h
debut:		SETB	P3.0									
				SETB	P3.1
				setb	EA
				setb	EX1
				setb	IT1

while_true:
				LCALL	print_val
				sjmp	while_true


;interruption INT0				
				
interrupt:
				LCALL	sqrt
				mov	P3.0,C
				cpl	C
				mov	P3.1,C
				

affichage:	
				push	Acc
				push	B
				mov	A,R0 ;n
				mov	B,#10
				div	AB
				swap	A
				orl	A,B
				mov 	P1,A
				pop	B
				pop	Acc
				reti
				
;sortie 		C (b ou d), R0 (sqrt)
				
sqrt:			PUSH  Acc
				PUSH	B
				mov   R0,#0FFh
				mov 	B,#0FFh
				mov   A,P0
rpt_sqrt:	INC	B
				INC	B
				INC	R0
				CLR 	C
				SUBB	A,B
				JNC	rpt_sqrt
endrtp_sqrt:		
				ADD	A,B
				JNZ	anonzero_sqrt
azero_sqrt:	
				SETB	C
				SJMP	return_sqrt
anonzero_sqrt:	
				CLR	C
return_sqrt:
				POP	B
				POP 	Acc
				RET
				
;sortie		void

print_val:
				mov   A,P0
				mov	B,#10 ;N
				div	AB
				MOV   R3,A
				MOV	A,B
				SWAP 	A
				anl	A,#0F0h
				mov	B,A
				mov	A,P3
				anl	A,#0Fh
				orl	A,B
				mov	P3,A
				mov	B,#10
				MOV   A,R3
				div	AB
				swap	A
				orl	A,B
				mov 	P2,A
				ret

;---------------------------------------------------------------------------------------------------------
; Fin d'assemblage 
				end 
				
				
				

