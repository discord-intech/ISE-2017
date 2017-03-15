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
busy		bit		p2.7
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

											;Initialisation du lcd
				lcall	init_lcd
				
				lcall	send_idle_lcd
				
				lcall	init_serie
				
fin:			sjmp	fin							; boucle infinie

;----------------------------------------------------------
;Code après reception

;Lecture du message recu	
recv:			mov 	A,@R0
				clr	C
				subb	A,#0B4h
				jz	recu_4 
				
				mov 	A,@R0
				clr	C
				subb	A,#44h
				jz	recu_D 
				
				mov 	A,@R0
				clr	C
				subb	A,#0C3h
				jz	recu_C 

				mov 	A,@R0
				clr	C
				subb	A,#47h
				jz	recu_G 


				
				lcall   send_idle_lcd
				
				
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
				
; sortie	void
en_lcd_code:								;sous programme de validation d'une instruction 
				clr		rs					;5 lignes = séquence permettant de valider l'envoi d'une 
				clr		rw					;instruction au LCD
				clr		E
				setb		E
				clr		E
				lcall		test_busy_lcd	;appel au sous programme de test de l'état d'occupation du LCD
				ret

; sortie void
en_lcd_data:
				
				setb		rs					;5 lignes = séquence permettant de valider l'envoi d'une
				clr		rw					;instruction au LCD
				clr		E
				setb		E
				clr		E
				lcall		test_busy_lcd	;appel au sous programme de test de l'état d'occupation du LCD
				ret
	
; sortie void			
ligne_1:
				push		acc
				mov		lcd,#01h			;effacement de l'affichage et retour du curseur en début de ligne
				lcall		en_lcd_code		;appel au sous programme de validation d'une commande
				mov		lcd,#10000000b	;placement  à l'adresse 00h de la DDram du LCD, code 80h
				lcall		en_lcd_code		;appel au sous programme de validation d'une commande
				pop		acc
				ret
				
; sortie void			
ligne_2:
				push		acc
				mov		lcd,#0C0h		;adresse dans la DDRAM (40h) correspondant au debut de la ligne 2
				lcall		en_lcd_code
				pop 		acc
				ret
				
; sortie P2 ; entrée : char dans Acc					
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


;envoie du idle
send_idle_LCD:												;  Envoie du 4 aux LCD
				mov      DPTR,#line_idle_a
		   		lcall    ligne_1
		   		lcall    emission
		   		mov      DPTR,#line_idle_b
		   		lcall    ligne_2
		   		lcall    emission
				
				
				clr	C
				ret


				
;envoie du 4
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
send_G_LCD:												;  Envoie du G aux LCD
				mov      DPTR,#line_gauche
		   		lcall    ligne_1
		   		lcall    emission
		   		
				
				clr	C
				ret

;envoie de G
send_D_LCD:												;  Envoie du D aux LCD
				mov      DPTR,#line_droit
		   		lcall    ligne_1
		   		lcall    emission
				
				clr	C
				ret
				
;envoie de G
send_C_LCD:												;  Envoie du C aux LCD
				mov      DPTR,#line_centre
		   		lcall    ligne_1
		   		lcall    emission
				
				clr	C
				ret		

;---------------------------------------------------------------------------------------------------------------------
;initialisation de la liaison serie TSOP 1738	
init_serie:
							
				mov	SCON,#51h								;Mode asynchrone + REN
				mov	A,TMOD
				anl	A,#0Fh
				orl	A,#20h
				mov	TMOD,A
				mov	R0,#40h
				mov	TH1,#0E6h
				mov	TL1,#0E6h
				clr 	RI
				clr	TI
				setb 	EA
				setb	ES
				setb	TR1
				ret

;sous-programme de la lecture serie sur le recepteur TSOP 1738
read:			
				setb  TR1
				clr	TI
				clr	RI
wait:			JNB	RI,wait
				mov	@R0,SBUF
				clr	RI
				setb  TR1
				
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



;---------------------------------------------------------------------------------------------------------
; Fin d'assemblage 
				end 

