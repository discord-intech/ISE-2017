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

				org	0000h									;adresse du PC apr�s RESET materiel
            LJMP  debut


;---------------------------------------------------------------------------------------------------------
;Programme principal

				org   0030h
debut:		mov	A,#00h
				mov	P2,A
front:		JNB   P0.2,front
			   INC	A
			   DA		A
resetC:		mov	P2,A
wait:			JB		P0.2,wait
				sjmp	front

fin:

;---------------------------------------------------------------------------------------------------------
; Fin d'assemblage 
				end 
