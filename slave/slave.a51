; Nom

; Description : 
; Auteurs : Louis-Baptiste & Discord
; Date : 2017/02/01

;---------------------------------------------------------------------------------------------------------
; Declaration des variables

; Variables du programme principal

RS		bit	P0.5
RW		bit	P0.6
E		bit	P0.7
out		equ	P2
sirene		bit	P1.3
laser		bit	P1.2

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
debut:		
				;clr	P3.1 ???    								;Initialisation du lcd
				lcall	init_lcd
				lcall	send_idle_lcd
				
;-------------------------------------------------------;
;initialisation de la liaison serie TSOP 1738				
				mov	SCON,#51h								;Mode asynchrone + REN
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
				
				
				
			
			
				clr 	C
			

rpt_inf:			jnc	rpt_inf							; boucle infinie

;----------------------------------------------------------
;Code après reception

;Lecture du message reçu	
				mov 	A,@R0
				clr	C
				subb	A,#0B4h
				jz	reçu_4 
				
				mov 	A,@R0
				clr	C
				subb	A,#44h
				jz	reçu_D 
				
				mov 	A,@R0
				clr	C
				subb	A,#0C3h
				jz	reçu_C 

				mov 	A,@R0
				clr	C
				subb	A,#47h
				jz	reçu_G 


				clr   	laser
				clr	sirene
				lcall   send_idle_lcd
				clr	C
				sjmp	rpt_inf

;----------------------------------------------------------
;Sous-programme du reception du "4"
reçu_4:				

				lcall 	send_4_LCD
				setb	laser
				setb	sirene
				clr	C
				ljmp	rpt_inf

;----------------------------------------------------------
;Sous-programme du reception du "D"
reçu_D:				
				lcall 	send_D_LCD
				setb	laser
				setb	sirene
				clr	C
				ljmp	rpt_inf
;----------------------------------------------------------
;Sous-programme du reception du "C"
reçu_C:				
				lcall 	send_C_LCD
				setb	laser
				setb	sirene
				clr	C
				ljmp	rpt_inf
;----------------------------------------------------------
;Sous-programme du reception du "G"
reçu_G:				
				lcall 	send_G_LCD
				setb	laser
				setb	sirene
				clr	C
				ljmp	rpt_inf

;-------------------------------------------------------------------------------------------------------------
;Sous-programme timer 40 ms, entré void, sortie void, utilisé A				
timer_40:													
				push	Acc
				mov 	tmod,#01h

				clr 	tr0                        ;1
				mov	A,#0B0h							;1
				add	A,tl0                      ;1
				mov	tl0,A                      ;1
				mov	A,#0Ch                     ;1
				addc	A,th0                      ;1
				mov	th0,A                      ;1
				clr	tf0                        ;1
				setb	tr0                
wait_40:		jnb	tf0,wait_40     
				pop   Acc   
				ret          
 				           
 				
 				

;---------------------------------------------------------------------------------------------------------
; Sous-programmes LCD

; sortie void
test_busy_lcd:
				clr 	RS
				setb	RW
				setb	E
				
check_busy:
				jb			P2.7,check_busy
			
				clr	E
				ret
				
; sortie	void
en_lcd_code:
				clr	RW
				clr	RS
				clr	E
				setb		E
				clr	E
				lcall	test_busy_lcd
				ret

; sortie void
en_lcd_data:
				clr	RW
				setb	RS
				clr	E
				setb		E
				clr	E
				lcall	test_busy_lcd
				ret
	
; sortie void			
ligne_1:
				push	Acc
				mov	out,#01h
				lcall	en_lcd_code
				
				mov	out,#80h
				lcall	en_lcd_code
				pop	Acc
				ret
				
; sortie void			
ligne_2:
				push	Acc
				clr	RS
				clr	RW
				setb	E
				clr	E
				mov	out,#0C0h
				lcall	en_lcd_code
				pop	Acc
				ret
				
; sortie P2 ; entrée : char dans Acc					
write_char:
 				push	Acc
 				clr	RW
 				setb	RS
 				clr	E
 				
 				mov	out,A
 				
 				lcall en_lcd_data
 				
 				pop	Acc
 				ret

; sortie DPTR modifié ; entrée addr ligne dans DPTR
write_line:
				push	Acc
				clr	RW
 				setb	RS
 				clr	E
rpt_line:				                              ; Bouclage d'écriture des char
				clr	A
				movc	A,@A+DPTR
				jz		write_line_ret							; fin du sous-prog quand le char à écrire vaut '/0'
				lcall write_char

				inc 	DPTR
				sjmp	rpt_line
				
write_line_ret:
				clr	RS
				pop	Acc
				ret

; sortie void, entré void, utilisé P2
init_lcd:
				push	out
				
				clr	RS
				clr	RW
				clr	E

				lcall	timer_40
				
				
				mov	out,#3Ch                    ; affichage deux lignes
				lcall en_lcd_code
				
				mov	out,#0Ch							 ; allumage
				lcall	en_lcd_code 
			
				mov	out,#01h                    ; clean affichage
				lcall en_lcd_code
				
				mov	out,#06h                    ; curseur incrémentage auto
				lcall en_lcd_code
				
				mov	out,#3Ch                    ; affichage deux lignes
				lcall en_lcd_code
				
				pop 	out
				ret


;envoie du idle
send_idle_LCD:												;  Envoie du 4 aux LCD
				lcall ligne_1
				mov	DPTR,#line_idle_a
				lcall	write_line
				
				lcall ligne_2
				mov	DPTR,#line_idle_b
				lcall	write_line
				
				;setb	P3.1 ???
				
				clr	C
				ret


				
;envoie du 4
send_4_LCD:												;  Envoie du 4 aux LCD
				lcall ligne_1
				mov	DPTR,#line_4_a
				lcall	write_line
				
				lcall ligne_2
				mov	DPTR,#line_4_b
				lcall	write_line
				
				;setb	P3.1 ???
				
				clr	C
				ret
				
;envoie de G
send_G_LCD:												;  Envoie du G aux LCD
				lcall ligne_1
				mov	DPTR,#line_gauche
				lcall	write_line
				
				clr	C
				ret

;envoie de G
send_D_LCD:												;  Envoie du D aux LCD
				lcall ligne_1
				mov	DPTR,#line_droit
				lcall	write_line
				
				clr	C
				ret
				
;envoie de G
send_C_LCD:												;  Envoie du C aux LCD
				lcall ligne_1
				mov	DPTR,#line_centre
				lcall	write_line
				
				clr	C
				ret		

;---------------------------------------------------------------------------------------------------------------------
;sous-programme de la lecture serie sur le recepteur TSOP 1738
read:			
				jb		TI,ti_clr
				mov	@R0,SBUF
				clr	RI
				sjmp	end_read
ti_clr:
				clr	TI
				setb	C
end_read:	reti	

;---------------------------------------------------------------------------------------------------------
; data

line_idle_a:
				db	'HORS'
				db	00h
line_idle_b:
				db	'PORTEE'
				db	00h




line_4_a:
				db	'IT IS OVER'
				db	00h
line_4_b:
				db	'9000'
				db	00h
line_droit:
				db	'DROITE'
				db	00h
line_centre:
				db 'CENTRE'
            db 00h
line_gauche:
				db 'GAUCHE'
				db 00h

fin:

;---------------------------------------------------------------------------------------------------------
; Fin d'assemblage 
				end 
