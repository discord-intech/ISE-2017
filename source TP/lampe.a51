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
debut:		
				MOV   C,P1.7
				MOV   P1.0,C
				sjmp  debut

fin:

;---------------------------------------------------------------------------------------------------------
; Fin d'assemblage 
				end
				 
