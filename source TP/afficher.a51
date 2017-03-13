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


;---------------------------------------------------------------------------------------------------------
;Programme principal

				org   0030h
debut:		JNB   P0.2,debut
				mov	A,P1
				mov	B,#10
				div	AB
				mov	P3,B
				mov	B,#10
				div	AB
				swap	A
				orl	A,B
				mov 	P2,A
wait:			JB		P0.2,wait		
				sjmp	debut
				
				



fin:

;---------------------------------------------------------------------------------------------------------
; Fin d'assemblage 
				end 
