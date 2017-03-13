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
				
				org	0003h
				clr	tr0					;2
				mov	P1,tl0				;3
				setb	tr0					;2
				reti							;1

;---------------------------------------------------------------------------------------------------------
;Programme principal

				org   0030h
debut:		mov	tmod,#01h
				mov	P1,#00h
				setb	IT0
				setb	EA
				setb	EX0
				setb  tr0
				
boucle:		sjmp	boucle
				
fin:			

;---------------------------------------------------------------------------------------------------------
; Fin d'assemblage 
				end 
