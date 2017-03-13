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
            LJMP	interrupt0
            
            org	0013h
            LJMP	interrupt1


;---------------------------------------------------------------------------------------------------------
;Programme principal

				org   0030h
debut:
				setb	EA
				setb	EX0
				setb	IT0
				setb	EX1
				setb	PX1
				setb	IT1
				mov	P1,#00
				mov 	tmod,#01h
				mov	R1,#00h
				mov	R2,#00h
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
 				
 				inc	R1
 				cjne	R1,#60,inf_60					; 60sec -> 1min
 				mov	R1,#00h
 				inc	R2
 				cjne	R2,#60,inf_60              ; 60min -> 1h
 				mov	R2,#00h
inf_60: 		lcall	print_time								
 				ljmp	rpt                        



print_time:
				push	Acc
				push	B
				mov	A,R1
				mov	B,#10
				div	AB
				swap	A
				orl	A,B
				mov 	P2,A
				
				mov	A,R2
				mov	B,#10
				div	AB
				swap	A
				orl	A,B
				mov 	P1,A
				pop	B
				pop	Acc
				ret
				
				
interrupt0:
				jnb	P3.2,interrupt0
				reti
				
interrupt1:
				mov	R1,#00h
				mov	R2,#00h
wait_3:		jnb	P3.3,wait_3

fin:

;---------------------------------------------------------------------------------------------------------
; Fin d'assemblage 
				end 

