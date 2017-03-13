; Nom

; Description : 
; Auteurs : Louis-Baptiste & Discord
; Date : 2017/02/01

;---------------------------------------------------------------------------------------------------------
; Declaration des variables

; Variables du programme principal

RS		bit	P1.5
RW		bit	P1.6
E		bit	P1.7
out	equ	P2

;---------------------------------------------------------------------------------------------------------
;Implementation des adresses

;Programme principal au reset

				org	0000h									;adresse du PC après RESET materiel
            LJMP  debut


;---------------------------------------------------------------------------------------------------------
;Programme principal

				org   0030h
debut:		
				;clr	P3.1 ???    								;Initialisation du lcd
				lcall	init_lcd
				
wait:			sjmp	wait				
			
			
			

rpt_inf:		jnc	rpt_inf							; boucle infinie
				
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

;---------------------------------------------------------------------------------------------------------
; data

line_4_a:
				db	'HORS'
				db	00h
line_4_b:
				db	'PORTEE'
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
