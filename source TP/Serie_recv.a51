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
				
				org 	0023h									;INT serial
            LJMP	read
;---------------------------------------------------------------------------------------------------------
;Programme principal

				org   0030h
debut:      mov	SCON,#51h
				mov	A,TMOD
				anl	A,#0Fh
				orl	A,#20h
				mov	TMOD,A
				mov	R0,#40h
				clr 	RI
				clr	TI
				setb 	EA
				setb	ES
				setb	TR1
				
wait:      	sjmp  wait				
;---------------------------------------------------------------------------------------------------------
read:			
				jb		TI,ti_clr
				mov	@R0,SBUF
				clr	RI
				inc	R0
				sjmp	end_read
ti_clr:
				clr	TI		
end_read:	reti		


fin:

;---------------------------------------------------------------------------------------------------------
; Fin d'assemblage 
				end 
