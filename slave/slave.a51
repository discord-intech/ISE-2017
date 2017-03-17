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
lcd		equ	P2
busy		bit	p2.7
sirene		bit	P1.3
laser		bit	P1.2
tire		bit	00h								;variable de tire, 1 signifie que l'on peux tirer, et 0 que l'on ne peux pas
tour		equ	R1
master		bit	P3.1

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
				clr	master						;Initialisation du master
											;Initialisation du lcd
				lcall	init_lcd
				
				lcall	send_idle_lcd
				
				lcall	init_serie

				clr	tire   						;Initialisation de la variable de tire

				mov	tour,#00h					;Initialisation du nombre de tour

				
				
fin:			sjmp	fin							; boucle infinie

;----------------------------------------------------------
;Code après reception

;Lecture du message recu
;In @R0, R0
;Out Void
;Use A,	C
recv:				mov 	A,SBUF
				clr	Acc.7
				CJNE	A,#30h,non_0
				mov	C,tire
				jc	same_lap
new_lap:
				mov	A,tour
				CJNE	A,#00h,first_lap
				CJNE	A,#03h,last_lap
				sjmp	end_0
first_lap:			
				setb	master
				sjmp	end_0

last_lap:			
				clr	master
				
				

end_0:				setb	tire
				inc	tour
				

same_lap:			lcall	send_0_LCD
				ret
				
non_0:				CJNE	A,#34h,non_4
				mov	C,tire
				jnc	non_tire
				clr	laser
				setb	sirene
				
non_tire:			lcall	send_4_LCD
				ret
				
non_4:				CJNE	A,#43h,non_C
				lcall	send_C_LCD
				ret

non_C:				CJNE	A,#44h,non_D
				lcall	send_D_LCD
				ret
non_D:				CJNE	A,#47h,non_G
				setb	laser
				clr	sirene
				clr	tire
				lcall	send_G_LCD
				ret

non_G:				
				lcall	send_idle_LCD
				ret




				
				

;----------------------------------------------------------
;Sous-programme du reception du "0"
recu_0:				

				lcall 	send_0_LCD
				
				ret				
;----------------------------------------------------------
;Sous-programme du reception du "4"
recu_4:				

				lcall 	send_4_LCD
				
				ret

;----------------------------------------------------------
;Sous-programme du reception du "D"
recu_D:				
				lcall 	send_D_LCD
				
				ret
;----------------------------------------------------------
;Sous-programme du reception du "C"
recu_C:				
				lcall 	send_C_LCD
				ret
				
;----------------------------------------------------------
;Sous-programme du reception du "G"
recu_G:				
				lcall 	send_G_LCD
				ret
				

;-------------------------------------------------------------------------------------------------------------
;Sous-programme timer 50 ms, entré void, sortie void, utilisé A	
;In Void
;Out Void
;Use tmod, th0, tr0, tl0, tf0			
tempo:
				clr		tr0
				clr		tf0
				mov		tmod,#01h		;comptage sur 16 bits avec horloge interne (Quartz 12 MHz)
				mov		th0,#3Ch			;(65535-15535)=40000d soit 3CB0h
				mov		tl0,#0B0h
				setb		tr0				;lance le comptage de Timer0
attent_tf0:
				jnb		tf0,attent_tf0	;attente de la fin du comptage
				clr		tr0				;remise à 0 du drapeau de fin de comptage
				ret       
 				           
 				
 				

;---------------------------------------------------------------------------------------------------------
; Sous-programmes LCD

; sortie void
;In void
;Out Void
;Use rw,rs,e
test_busy_lcd:								;test de la valeur du BUSY FLAG renvoyé sur DB7 par le LCD
				
				mov		lcd,#0ffh		;déclaration du port de communication avec LCD en lecture	
				setb		rw					;2 lignes pour autoriser la lecture de BF
				clr		rs
				setb		E					;Bf doit être lu entre un front montant et un front descendant
												;de E

check_busy:
				jb			busy,check_busy	;BF = 1 LCD occupé, BF = 0 LCD libre
				clr		E
				ret
				
;In void
;Out Void
;Use rw,rs,e
en_lcd_code:								;sous programme de validation d'une instruction 
				clr		rs					;5 lignes = séquence permettant de valider l'envoi d'une 
				clr		rw					;instruction au LCD
				clr		E
				setb		E
				clr		E
				lcall		test_busy_lcd	;appel au sous programme de test de l'état d'occupation du LCD
				ret

;In void
;Out Void
;Use rw,rs,e
en_lcd_data:
				
				setb		rs					;5 lignes = séquence permettant de valider l'envoi d'une
				clr		rw					;instruction au LCD
				clr		E
				setb		E
				clr		E
				lcall		test_busy_lcd	;appel au sous programme de test de l'état d'occupation du LCD
				ret
	
;In void
;Out Void
;Use lcd,A		
ligne_1:
				push		acc
				mov		lcd,#01h			;effacement de l'affichage et retour du curseur en début de ligne
				lcall		en_lcd_code		;appel au sous programme de validation d'une commande
				mov		lcd,#10000000b	;placement  à l'adresse 00h de la DDram du LCD, code 80h
				lcall		en_lcd_code		;appel au sous programme de validation d'une commande
				pop		acc
				ret
				
;In void
;Out Void
;Use lcd,A			
ligne_2:
				push		acc
				mov		lcd,#0C0h		;adresse dans la DDRAM (40h) correspondant au debut de la ligne 2
				lcall		en_lcd_code
				pop 		acc
				ret
				
;In DPTR
;Out Void
;Use A			
emission:
            CLR		 A
            movc      A,@A+DPTR
            JZ        sortie
            mov       P2,A
            lcall     en_lcd_data
            inc       DPTR
           
            sJMP      emission
sortie:     ret

; sortie void, entré void, utilisé P2
;In void
;Out Void
;Use lcd
init_lcd:
				mov		r6,#4
init1:				lcall		tempo
				mov		lcd,#38h			;affiche sur 2 lignes en 5x8 points
				lcall		en_lcd_code		;sous programme de validation d'une commande
				djnz     r6, init1
				lcall		tempo
				mov		lcd,#08h			;extinction
				lcall		en_lcd_code
				lcall    tempo
				mov		lcd,#01h
				lcall		en_lcd_code
				lcall		tempo
				mov		lcd,#06h
				lcall		tempo
				mov		lcd,#0Ch			;allumage de l'afficheur
				lcall		en_lcd_code		;sous programme de validation d'une commande
				lcall		tempo 
				mov		lcd,#01h			;effacement de l'affichage
				lcall		en_lcd_code		;sous programme de validation d'une commande
				lcall		tempo
				mov		lcd,#06h			;incrémente le curseur
				lcall		en_lcd_code		;sous programme de validation d'une commande
				mov		lcd,#38h			;affiche sur 2 lignes en 5x8 points
				lcall		en_lcd_code		;sous programme de validation d'une commande
				ret


;envoie de la valeur stocké à l'adresse 40h

send_r_lcd:			lcall ligne_1
				CLR	  A
            			mov       A,@R0
            			mov       lcd,A
            			lcall     en_lcd_data
            			
	 			ret

;envoie de la valeur stocké dans sbuf

send_sbuf_lcd:			lcall 		ligne_1
				CLR	  	A
            			mov       	A,SBUF
				clr		ACC.7
            			mov      	lcd,A
            			lcall     	en_lcd_data
            			
	 			ret

;envoie du idle
;In void
;Out Void
;Use DPTR
send_idle_LCD:												;  Envoie du 4 aux LCD
				mov      DPTR,#line_idle_a
		   		lcall    ligne_1
		   		lcall    emission
		   		mov      DPTR,#line_idle_b
		   		lcall    ligne_2
		   		lcall    emission
				
				
				clr	C
				ret


;envoie du 0
;In void
;Out Void
;Use DPTR
send_0_LCD:												;  Envoie du 4 aux LCD
				mov      DPTR,#line_0_a
		   		lcall    ligne_1
		   		lcall    emission
		   		mov      DPTR,#line_0_b
		   		lcall    ligne_2
		   		lcall    emission
				
				
				
				clr	C
				ret			
;envoie du 4
;In void
;Out Void
;Use DPTR
send_4_LCD:												;  Envoie du 4 aux LCD
				mov      DPTR,#line_4_a
		   		lcall    ligne_1
		   		lcall    emission
		   		mov      DPTR,#line_4_b
		   		lcall    ligne_2
		   		lcall    emission
				
				
				
				clr	C
				ret
				
;envoie de G
;In void
;Out Void
;Use DPTR
send_G_LCD:												;  Envoie du G aux LCD
				mov      DPTR,#line_gauche
		   		lcall    ligne_1
		   		lcall    emission
		   		
				
				clr	C
				ret

;envoie de G
;In void
;Out Void
;Use DPTR
send_D_LCD:												;  Envoie du D aux LCD
				mov      DPTR,#line_droit
		   		lcall    ligne_1
		   		lcall    emission
				
				clr	C
				ret
				
;envoie de G
;In void
;Out Void
;Use DPTR
send_C_LCD:												;  Envoie du C aux LCD
				mov      DPTR,#line_centre
		   		lcall    ligne_1
		   		lcall    emission
				
				clr	C
				ret		

;---------------------------------------------------------------------------------------------------------------------
;initialisation de la liaison serie TSOP 1738	
;In void
;Out SCON,TMOD,TH1,TL1,RI,TI,EA,ES,TR1
;Use A

init_serie:
							
				mov	SCON,#51h								;Mode asynchrone + REN
				mov	A,TMOD
				anl	A,#0Fh
				orl	A,#20h
				mov	TMOD,A
				mov	TH1,#0E6h
				mov	TL1,#0E6h
				clr 	RI
				clr	TI
				setb 	EA
				setb	ES
				setb	TR1
				ret

;sous-programme de la lecture serie sur le recepteur TSOP 1738
;In TI,RI
;Out @R0
;Use SBUF
read:			
				
				clr	TI
				clr	RI
wait:				JNB	RI,wait
				clr	RI
				


				
				
				lcall	recv
				
				reti	

;---------------------------------------------------------------------------------------------------------
; data

line_idle_a:
				db	'HORS'
				db	00h
line_idle_b:
				db	'PORTEE'
				db	00h

line_0_a:
				db	'DEMARRAGE'
				db	00h
line_0_b:
				db	'IMMINENT'
				db	00h


line_4_a:
				db	'PRET'
				db	00h
line_4_b:
				db	'A TIRER'
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



;---------------------------------------------------------------------------------------------------------
; Fin d'assemblage 
				end 

