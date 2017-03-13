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
            
				org   0003h                         ; INT0/
				LJMP	affichage

;---------------------------------------------------------------------------------------------------------
;Programme principal

				org   0030h
debut:		SETB	P3.0
				SETB	P3.1
				LJMP	affichage
;sub:			JNB   P3.2,sub
precalcul:	mov   R0,#00
				mov 	R1,#01
				mov   A,P0
				CLR	P3.0
				SETB	P3.1
calcul:		CLR 	C
				SUBB	A,R1
				INC	R1
				INC	R1
				JC		affichage
				JZ		preaff
				INC	R0
				SJMP	calcul

preaff:		INC	R0
				SETB	P3.0
				CLR	P3.1
affichage:	mov   A,P0
				mov	B,#10 ;N
				div	AB
				MOV   R3,A
				MOV	A,B
				SWAP 	A
				mov	P3,A
				mov	B,#10
				MOV   A,R3
				div	AB
				swap	A
				orl	A,B
				mov 	P2,A
				
				mov	A,R0 ;n
				mov	B,#10
				div	AB
				swap	A
				orl	A,B
				mov 	P1,A
				
;ssub:			JB   P3.2,ssub
fin:			
				LJMP  affichage

;---------------------------------------------------------------------------------------------------------
; Fin d'assemblage 
				end 
