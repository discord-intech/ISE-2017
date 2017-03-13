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
				mov	P1,#00
				mov 	tmod,#01h
rpt:
				mov	R0,#25							
start_count:
				clr 	tr0                        ;1
				mov	A,#0C8h							;1
				add	A,tl0                      ;1
				mov	tl0,A                      ;1
				mov	A,#63h                     ;1
				addc	A,th0                      ;1
				mov	th0,A                      ;1
				clr	tf0                        ;1
				setb	tr0                       
wait:			jnb	tf0,wait                  
 				djnz	R0,start_count             
 				
 				inc	P1									
 				ljmp	rpt                        

				
fin:

;---------------------------------------------------------------------------------------------------------
; Fin d'assemblage 
				end 

