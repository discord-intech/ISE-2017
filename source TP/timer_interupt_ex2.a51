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
				
				org	000Bh									;TIMER0
				ljmp	interrupt0
				
				org	0013h									;INT1
				mov	P2,tl0				;3 
				mov	P1,tl1				;3 
				reti				

				org	001Bh									;TIMER1
				ljmp	interrupt1
				
				
				
;---------------------------------------------------------------------------------------------------------
;Programme principal

				org   0030h
debut:		mov	tmod,#11h
				mov	P1,#00h
				mov	th0,#0FFh
				mov   tl0,#0E7h
				setb	IT1
				setb	EA
				setb	EX1
				setb  ET1
				setb 	ET0
				setb	PX1
				setb  tr0
				
boucle:		sjmp	boucle
				
				
interrupt0:	
				clr 	tr0
				clr 	tf0
				mov	th1,#0FFh
				mov   tl1,#0D7h
				setb	tr1
				reti

interrupt1:
				clr 	tr1
				clr 	tf1
				mov	th0,#0FFh
				mov   tl0,#0E7h
				setb	tr0
				reti
fin:			

;---------------------------------------------------------------------------------------------------------
; Fin d'assemblage 
				end 
