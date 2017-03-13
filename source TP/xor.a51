; XOR

; Description : Un pitit XOR
; Auteurs : Louis-Baptiste & Rémi
; Date : 2017/02/01

;---------------------------------------------------------------------------------------------------------
; Declaration des variables


; Variables du programme principal

VarA			bit	ACC.0
VarB			bit	ACC.1
VarS			bit	P1.2
VarTemp		bit	F0

;---------------------------------------------------------------------------------------------------------
;Implementation des adresses

;Programme principal au reset

				org	0000h									;adresse du PC après RESET materiel
            LJMP  debut


;---------------------------------------------------------------------------------------------------------
;Programme principal

				org   0030h
debut:		MOV   A,P1								;1 1 ; Deplacement de P1 dans A
				MOV   C,VarB						   ;2 1 ;
si :		   JNB   VarA,fsi							;3 2 ; si A=1 on vas à sinon
	  		   CPL   C     						   ;1 1 ;
fsi:			MOV   VarS,C							;2 2 ;
				SJMP  debut                      ;2 2;
				;cycle :  8 ou 7
				
				;old
				;MOV   A,P1								;1 1 Deplacement de P1 dans A
				;MOV   C,VarB                    ;2 1 A291h  ;	
				;ANL	C,/VarA							;2 2 B090h 	; ET logique entre a barre et b 
				;MOV   VarTemp,C						;2	2 92D5h 	; On stocke la valeur dans F0
				;MOV   C,VarA                    ;2 1 A290h  ;
				;ANL   C,/VarB							;2	2 B091h  ; ET logique entre a et b barre
				;ORL	C,VarTemp						;2	2 72D5h	; OU logique entre (a.b barre) et (a barre.b)
 				;MOV   VarS,C							;2	2 9292h  ; Deplacement le résultat dans P1.2
				;SJMP  debut                     ;2 2 80F0h  ;
				;15 cycles

fin:

;---------------------------------------------------------------------------------------------------------
; Fin d'assemblage 
				end 

