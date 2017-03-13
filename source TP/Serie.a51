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
debut:      mov	A,TMOD
				anl	A,#0Fh
				orl	A,#20h
				mov	TMOD,A
				mov	SCON,#42h
				mov	TH1,#0E6h
				mov	TL1,#0E6h
				setb  TR1
				mov	DPTR,#string
write:
				clr	A
				movc	A,@A+DPTR
				JZ		end_s
				mov	C,P
				mov	Acc.7,C
				clr	TI
				mov	SBUF,A
wait:			JNB	TI,wait
				inc	DPTR
				SJMP	write		

end_s:      clr 	TI 
				clr	TR1
endb:			SJMP	endb

string:		db		'SYSTEME OK'
				db    00h

fin:

;---------------------------------------------------------------------------------------------------------
; Fin d'assemblage 
				end 
