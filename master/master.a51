;soustraction et addition sur 16 bits
;commande du moteur et du servo de direction
;l'action sur un bouton poussoir met le bit a 0
;au debut les roues sont droites et le moteur est a l'arrˆt
;l'appui sur BP1 provoque(progressivement) l'acceleration et le braquage des roues a gauche la led s'allume
;l'appui sur BP0 provoque(progressivement) a deceleration et le braquage des roues a droite la led s'eteind
dir     		    bit     P1.4   ; commande de direction
mot    			 bit     p1.5   ; commande du moteur
tir    			 bit     p3.5   ; commande du tir
ledmC  			 bit     p1.0   ; indique æC en marche (led allumee si p1.0 = 0)
bp0     			 bit     p1.1   ; pour l'etalonnage et calibrage
bp1    			 bit     p1.2   ; pour calibrage
capg   			 bit     p1.7   ; capteur gauche
capd   			 bit     p1.6   ; capteur droit

;bit de flag
finint 			 bit     	7Fh    ; indicateur de preparation du timer0

; declaration des octets
; valeurs de reference a charger dans Timer0
vd1h			equ		0fah		;(65536-1500)			
vd1l			equ		24h		;
vdr1h			equ		0fch		;(65536-1000)
vdr1l			equ		70h
vmr1h			equ		0c1h		;(65536-16000)
vmr1l			equ		78h

maxspeedh		equ		0f9h
maxspeedl		equ		00h
speed_kp		equ		1

nb_ticks_odo		equ		7

servo_inc		equ		90

consigne_high		equ	 	9
consigne_low		equ		10

;memoires recevant les valeurs a charger dans Timer0 
;pour realiser les durees de:

vd2l			equ		7fh		; la direction
vd2h			equ		7eh
vdr2l			equ		7dh		; reste de la direction
vdr2h			equ		7ch
vm2l			equ		7bh		; du moteur
vm2h			equ		7ah
vmr2l			equ		79h		; reste du moteur
vmr2h			equ		78h

odoc			equ		77h		; ticks codeuse

consigne_pwm		equ		75h
lap_count		equ		74h

servostate		equ		73h		; etat servo 0=centre 1=gauche 2=droite
servo_count		equ		72h
timer_ov		equ		71h

vth0			equ		6eh		;memoire intermediaire recevant les valeurs
vtl0			equ		6fh		;a transferer dans th0 et tl0
;----------------------------------------------------------------------
; plage des interruptions

				org		0000h			;reset
				ljmp		debut
				
				org		0003h			;interruption int0
				ljmp		odo_inc

				org		000Bh			;interruption timer0
				ljmp		pinttimer0

				org		0013h			;interruption int1
				ljmp		handle_slave
                              	         
				org		001Bh			;interruption timer1 
				ljmp		timer_overflow					

				org		0023h			;interruption liaison serie

				org		0030h
						
;-------------------------------------------------------------------
;programme d'interruption du Timer0. La periode set de 20ms separee en 4 durees:
;d= direction de 1 a 2ms, /d= reste de la direction pour completer a 2,5ms,
;m= moteur de 1 a 2ms, /m= reste du moteur pour completer a 17,5ms.

pinttimer0:
				push		psw
				push		acc

tr0a0: 
				cjne		r0,#0,tr0a1		;direction
			;	djnz		servo_count,nothing
			;	mov		servo_count,#4
				mov		a,servostate
				cjne		a,#1,droite
				lcall		tournedroite
				mov		consigne_pwm,#consigne_high
				sjmp		nothing						
droite:
				cjne		a,#2,center
				lcall		tournegauche
				mov		consigne_pwm,#consigne_low
				sjmp		nothing
center:				
				jnz		nothing
				mov		vd2l,#vd1l	; chargement de la valeur de repos 1500æs
				mov		vd2h,#vd1h	; pour la direction
				mov		vdr2l,#vdr1l; chargement du complement (1000us)a 2,5ms
				mov		vdr2h,#vdr1h; pour la direction
				mov		consigne_pwm,#consigne_high 
				
nothing:
				mov		vtl0,vd2l
				mov		vth0,vd2h
				mov		r0,#1
				setb		dir
				sjmp		relancet0

tr0a1:  
				cjne		r0,#1,tr0a2		;reste de la direction 
       		mov		vtl0,vdr2l
        		mov		vth0,vdr2h
        		mov		r0,#2
       		clr     	dir
       		sjmp		relancet0

tr0a2:  
				cjne		r0,#2,tr0a3		;moteur
       		mov		vtl0,vm2l
        		mov		vth0,vm2h
        		mov		r0,#3
				setb		mot
        		sjmp		relancet0

tr0a3:  
				mov		vtl0,vmr2l		;reste du moteur
				mov		vth0,vmr2h
				clr		mot
				mov		r0,#0
				setb		finint    		;pp peut traiter des nouvelles valeurs 
        
relancet0:
				clr		tr0      ; arret du timer
				mov		a,tl0    ; lecture de la valeur … charger
				add		a,#08		; addition avec le reste du timer
				addc		a,vtl0   ; valeur … ajuster
				mov		tl0,a    ; chargement du poids faible du timer0
				mov		a,vth0   ; lecture de la valeur … charger dans th0
				addc		a,th0    ; pour tenir compte du d‚bordement
				mov		th0,a    ; chargement du poids fort du timer0
				setb		tr0      ; lancement du timer

restit:
				pop		acc
				pop		psw

				reti
;-----------------------------------------------

;augmentation de la durée moteur selon R7
sousmot: 								 
						
				clr		c
				mov		a,vm2l
				subb		a,r7
				mov		vm2l,a
				mov		a,vm2h
				subb		a,#00h
				mov		vm2h,a 
restmot2:
				clr		c
				mov		a,vmr2l
				add		a,r7
				mov		vmr2l,a
				mov		a,vmr2h
				addc		a,#00h
				mov		vmr2h,a
				ret
;-------------------------------------------------------------------
;diminution de la duree moteur selon r7
addmot:
				clr		c
				mov		a,vm2l
				add		a,r7
				mov		vm2l,a
				mov		a,vm2h
				addc		a,#00h
				mov		vm2h,a
restmot3:
				clr		c
				mov		a,vmr2l
				subb		a,r7
				mov		vmr2l,a
				mov		a,vmr2h
				subb		a,#00h
				mov		vmr2h,a
				ret 
;--------------------------------------------------------------------
;virage a gauche selon R6
virgauche:
				clr		c
				mov		a,vd2l
				add		a,r6
				mov		vd2l,a
				mov		a,vd2h
				addc		a,#00h
				mov		vd2h,a
restdir3:
				clr		c
				mov		a,vdr2l
				subb		a,r6
				mov		vdr2l,a
				mov		a,vdr2h
				subb		a,#00h
				mov		vdr2h,a
				ret
;----------------------------------------------------------------------
;virage a droite selon R6
virdroite:
				clr		c
				mov		a,vd2l
				subb		a,r6
				mov		vd2l,a
				mov		a,vd2h
				subb		a,#00h
				mov		vd2h,a 
restdir4:
				clr		c
				mov		a,vdr2l
				add		a,r6
				mov		vdr2l,a
				mov		a,vdr2h
				addc		a,#00h
				mov		vdr2h,a
				ret
;----------------------------------------------------------------------
; gestion esclave

handle_slave:			clr		ex1
				clr		tr1
				clr		et1
				djnz		lap_count,stop_and_restart
				lcall		stop_motor
				setb		ledmC
				sjmp		handle_slave_reti

stop_and_restart:		
				lcall		stop_motor
				setb		ledmC
				mov		r1,#150
				lcall		durecom								
				mov		r1,#1
				lcall		start_motor
				setb		tr1
				setb		et1
				setb		ex1
				clr		ledmC

handle_slave_reti:
				reti 


;----------------------------------------------------------------------
;asservissement vitesse
asservissement_vitesse:
				push 		psw
				push		Acc
				push		B

				mov		a,timer_ov				
				clr 		c
				subb		a,consigne_pwm
				jz		check_pwm
				jnc		over
				cpl		a
		;		mov		b,#2
		;		div		ab
			;	mov		b,#speed_kp
			;	mul		ab
				mov		r7,#speed_kp
				lcall		addmot
				sjmp		check_pwm				

over:
		;		mov		b,#2
		;		div		ab
			;	mov		b,#speed_kp
			;	mul		ab
				mov		r7,#speed_kp
				lcall		sousmot
				
check_pwm:			mov		a,vm2h
				clr		c
				subb		a,#maxspeedh
				jc		too_fast
				jnz		no_underflow
				mov		a,vm2l
				clr		c
				subb		a,#maxspeedl
				jc		too_fast
				sjmp		no_overflow

too_fast:			
				mov		vm2h,#maxspeedh
				mov		vm2l, #maxspeedl
				mov		vmr2h,#0c2h
				mov		vmr2l,#78h
				

no_overflow:
				mov		a,vm2h
				clr		c
				subb		a,#vd1h
				jnc		too_slow
				jnz		no_underflow
				mov		a,vm2l
				clr		c
				subb		a,#vd1l
				jnc		too_slow
				sjmp		no_underflow
too_slow:
				mov		vm2l,#vd1l	; chargement de la valeur de repos 1500æs
				mov		vm2h,#vd1h	; pour le moteur
				mov		vmr2l,#vmr1l; complement moteur
				mov		vmr2h,#vmr1h
		

no_underflow:	
				pop		B
				pop		Acc
				pop		psw
				ret

;----------------------------------------------------------------------
;start/stop motors

start_motor:
				mov		vm2h,#0f9h	;chargement de la valeur min 
				mov		vm2l,#0d4h	;(65536-2000)=63536d=f830h
				mov		vmr2h,#0c1h	;reste de l'impulsion 
				mov		vmr2l,#0c8h	;(65536-15500)=50036d=c374h
				ret

stop_motor:		
				mov		vm2l,#vd1l	; chargement de la valeur de repos 1500æs
				mov		vm2h,#vd1h	; pour le moteur
				mov		vmr2l,#vmr1l; complement moteur
				mov		vmr2h,#vmr1h
				ret
				
;----------------------------------------------------------------------
;timer overflow

timer_overflow:
				inc		timer_ov
			;	cpl		ledmC
			;	clr		tf1
				reti

;----------------------------------------------------------------------
;nombre de fois 20ms
durecom:										 ; gère r1 =  Nb de commandes soit r1*20ms 
				jnb		finint,durecom
				clr		finint
				djnz		r1,durecom 		 ; r1 contient le Nb de commandes 
				ret
;----------------------------------------------------------------------
;incrémentation codeuse

odo_inc:
				djnz		odoc,odo_inc_reti
				clr		tr1
				;cpl		ledmC
				mov		odoc,#nb_ticks_odo
				lcall		asservissement_vitesse
				mov		timer_ov,#0
				mov		th1,#0	
				mov		tl1,#0	
				setb		tr1
odo_inc_reti:			reti		


;------------------------------------------
debut:
				mov		sp,#30h		;pour sortir de la zone de banque
				mov		tmod,#11h	
				mov		th1,#0	
				mov		tl1,#0	 
			;	mov		scon,#52h	; mode 1 10 bits, ren=1,ti=1
			;	setb		tr1			; lancement timer1 pour diviser fqz (baudrate)
				clr		dir 
				clr		mot
				clr		finint		; pas de fin d'interruption
; validation des interruptions du timer 0
				setb		et0			; enable timer0
				setb		ex0
				setb		it0          
        			setb		et1
				setb		ea				; enable all ,validation generale
        			setb		pt0			; interruption timer0 en priorit‚ 0
				clr		px0
        			mov		r6,#2			; increment pour la direction
        			mov		r7,#1			; increment pour la vitesse
				mov		vd2l,#vd1l	; chargement de la valeur de repos 1500æs
				mov		vd2h,#vd1h	; pour la direction
				mov		vdr2l,#vdr1l; chargement du complement (1000us)a 2,5ms
				mov		vdr2h,#vdr1h; pour la direction 
			
				mov		vm2l,#vd1l	; chargement de la valeur de repos 1500æs
				mov		vm2h,#vd1h	; pour le moteur
				mov		vmr2l,#vmr1l; complement moteur
				mov		vmr2h,#vmr1h
				
				mov		servostate,#0
				mov		servo_count,#10
				mov		odoc,#nb_ticks_odo			
				mov		consigne_pwm,#consigne_high
				mov		lap_count,#3
					
				mov		r0,#0			; debut du traitement des signaux dir et mot
				mov		th0,#0FFh	; pour lancement du timer 0 premiŠre fois
				mov		tl0,#0F0h	; pour lancement du timer 0 premiŠre fois
				setb		tr0			; lancement du timer0
											; ensuite le timer se relance tout seul
	
				mov		r1,#200      ; 200x20ms = 4s
				lcall		durecom
				mov		r1,#1
				setb		ledmC

wait_start:			jb		p3.3,wait_start
				clr		ledmC				

				lcall		start_motor
				setb   		tr1
				setb		it1
				setb		ex1    
main:
				jb		capd,test_g
				jnb		capg,main
				;mov		a,servostate
				;subb		a,#1
				;jz		main	
				;lcall 		tournegauche
				mov		servostate,#2
				sjmp		main

test_g:				jb		capg,reset_orient
				;mov		a,servostate
				;subb		a,#2
				;jz		main
				;lcall		tournedroite
				mov		servostate,#1
				sjmp		main

reset_orient:			;mov		a,servostate
				;jz		main	
				;mov		vd2l,#vd1l	; chargement de la valeur de repos 1500æs
				;mov		vd2h,#vd1h	; pour la direction
				;mov		vdr2l,#vdr1l; chargement du complement (1000us)a 2,5ms
				;mov		vdr2h,#vdr1h; pour la direction 
				mov		servostate,#0
				sjmp		main		; attente de l'appui sur un bouton
ralentir:
				;cpl		ledmc
				lcall		decelere		; sous prog de decelaration
				lcall		tournedroite	;sous prog de virage a droite
				mov		r1,#1
				lcall		durecom
				sjmp		main	
augmenter:
				;cpl		ledmc
				lcall		accelere		; sous prog d'acceleration
				lcall		tournegauche	;sous prog de virage a gauche
				mov		r1,#1
				lcall		durecom
				sjmp		main	
;--------------------------------------------------------------------
;deceleration: diminuer la duree m de l'impulsion moteur revient a augmenter
;la valeur vm a charger dans Timer 0: vm=(65536-m)
decelere:			
				lcall		addmot			;calcul des valeurs a charger dans T0
				mov		a,vm2h			; test a la valeur max de vm
				cjne		a,#0fch,diffh2	; saut si vm2h different de 0fch
				mov		a,vm2l
				cjne		a,#18h,diffl2
				ljmp		sortie_dec
diffl2:
				jc			sortie_dec
				sjmp		suph2
diffh2:
				jc			sortie_dec
suph2:
				mov		vm2h,#0fch	;chargement des valeurs max
				mov		vm2l,#18h	;(65536-1000)=64536d=fc18h
				mov		vmr2h,#0bfh	;reste du moteur
				mov		vmr2l,#8ch	;(65536-16500)=49036d=bf8ch
												
sortie_dec:	            																	
				ret
;-------------------------------------------------------------
;acceleration: augmenter la duree m de l'impulsion moteur revient a
;diminuer la valeur vm a charger dans Timer0: vm=(65536-m)

accelere:
				lcall		sousmot		;calcul des valeurs a charger dans T0
				mov		a,vm2h		; test a la valeur min de vm
				cjne		a,#0f8h,diffh1
				mov		a,vm2l
				cjne		a,#30h,diffl1

diffh1:
				jc			infh1
				ljmp		sortie_acc
diffl1:
				jc			infh1
				ljmp		sortie_acc
infh1:
				mov		vm2h,#0f8h	;chargement de la valeur min 
				mov		vm2l,#30h	;(65536-2000)=63536d=f830h
				mov		vmr2h,#0c3h	;reste de l'impulsion 
				mov		vmr2l,#74h	;(65536-15500)=50036d=c374h
				
sortie_acc:												
        		ret
;------------------------------------------------------------------------
tournegauche:
				mov		r6,#servo_inc
       				lcall		virgauche		;calcul des valeurs a charger dans T0
			        mov		a,vd2h
            			cjne		a,#0fbh,diffh3
            			mov		a,vd2l
            			cjne		a,#0b4h,diffl3
            			ljmp		sortie_droite3
diffh3:
				clr 		c
				mov		a,vd2h
				subb		a,#0fbh
				jnc		suph3
				sjmp		sortie_droite3
diffl3:
				clr 		c
				mov		a,vd2l
				subb		a,#0b4h
				jnc		suph3
				sjmp		sortie_droite3

suph3:
				mov		vd2h,#0fbh	;chargement des valeurs max
				mov		vd2l,#0b4h
				mov		vdr2h,#0bfh
				mov		vdr2l,#0f0h
			;	setb		ledmC
				 
sortie_droite3:
		;		mov		servostate,#2
			;	setb		ledmC
				ret
;-------------------------------------------------------------------------					
tournedroite:
				mov		r6,#servo_inc
				lcall		virdroite	;calcul des valeurs a charger dans T0
				mov		a,vd2h
				cjne		a,#0f8h,diffh4
				mov		a,vd2l
				cjne		a,#84h,diffl4
				ljmp		sortie_gauche2
diffh4:
				clr 		c
				mov		a,vd2h
				subb		a,#0f8h
				jc		infh4
				sjmp		sortie_gauche2
diffl4:
				clr 		c
				mov		a,vd2l
				subb		a,#84h
				jc		infh4
				sjmp		sortie_gauche2
infh4:
				mov		vd2h,#0f8h	;chargement de la valeur max de l'impulsion
				mov		vd2l,#84h	;07d0h=2000d
				mov		vdr2h,#0c3h	;reste de l'impulsion 3c8ch=15500d
				mov		vdr2l,#20h
			;	clr		ledmC	

sortie_gauche2:
			;	clr		ledmC
			;	mov		servostate,#1
				ret
;--------------------------------------------------------------------------				
        		end



				

