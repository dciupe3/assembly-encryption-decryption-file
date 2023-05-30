.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern printf: proc
extern fopen: proc
extern fscanf: proc
extern fprintf: proc
extern scanf: proc
extern gets: proc
extern fgets: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date

;text
text_calea DB "Introduceti calea absoluta catre fisierul de date! ", 13, 10, 0
text_operatie DB 13, 10, "Ce operatie doriti sa faceti cu fisierul aflat la adresa: %s ?", 13, 10, 0
text_operatie_mod1 DB "Pentru criptarea fisierului scrieti 0", 13, 10, 0
text_operatie_mod2 DB "Pentru decriptarea fisierului scrieti 1", 13, 10, 0
text_algoritm DB "Ce algoritm doriti sa folositi pentru criptarea/decriptarea fisierului?", 13, 10, 0
text_algoritm1 DB "Pentru folosirea primului algoritm scrieti 0", 13, 10, 0
text_algoritm2 DB "Pentru folosirea celui de al doilea algoritm scrieti 1", 13, 10, 0
text_cheie_criptare DB "Introduceti cheia pentru criptarea fisierului : ", 13, 10, 0
text_cheie_decriptare DB "Introduceti cheia pentru decriptarea fisierului : ", 13, 10, 0
text_final DB "Fisierul %s a fost creeat cu succes! ", 13, 10, 0
text_eroare_citire_fisier DB "EROARE: Fisierul nu exista", 13, 10, 13, 10, 0
text_eroare_citire_operatie DB "EROARE: Operatia trebuie sa fie 0 sau 1", 13, 10, 13, 10, 0
text_eroare_citire_algoritm DB "EROARE: Algoritmul trebuie sa fie 0 sau 1", 13, 10, 13, 10, 0
text_citire_cheie1 DB "Cheia este un numar de la 0 la 7", 13, 10, 0
text_citire_cheie2 DB "Cheia este pe 64 de biti, adica un sir de 8 caractere", 13, 10, 0
;variabile
operatie DD ? 
algoritm DD ? 
cheie DB ?
cheie2 DB 8 DUP(0) ;pe 64 de biti
fisier_final DB "final_criptat_decriptat.txt", 13, 10, 0
cale_fisier DB 50 DUP(0)
cale_fisier_out DB "fisier.out", 0
adresa_fisier DD ?
adresa_fisier_iesire DD ?
caracter DB ?
bloc_10oct DB 10 DUP(0) 

;format
mode_read DB "r", 0
mode_write DB "w", 0
format_caracter DB "%c", 0
format_intreg DB "%d", 0
format_string DB "%s", 0
.code

printare_text MACRO mesaj
	push mesaj
	call printf
	add ESP, 4
ENDM

printare_text_parametru MACRO mesaj, parametru	
	push parametru
	push mesaj
	call printf
	add ESP, 8
ENDM

citire_date MACRO format_citire, data
	push data
	push format_citire
	call scanf
	add ESP, 8
ENDM

;ALGORITM1 CRIPTARE
criptare_algoritm1 PROC 
	push EBP
	mov EBP, ESP
	;push dword ptr 0 ; variabila locala
	;EBP + 4 - adresa de revenire 
	;EBP + 8 - cheie  ;EBP + 12 - adresa_fisier_iesire ;EBP + 16 - adresa_fisier
	
	
;citire caracter
	;fscanf (*f_in, "%c", &caracter)
CITIRE_FISIER:
	push offset caracter
	push offset format_caracter
	push [EBP + 16]
	call fscanf
	add esp, 12
	
	cmp eax, -1 ; eax = -1 daca se ajunge la sfarsitul fisierului (eof)
	je FINAL_FISIER
	
;complement fata de 1
	not caracter
;complement fata de 2
	add caracter, 1
;rotire la dreapta cu cheia
	xor ecx, ecx 
	mov cl, [EBP + 8]
	ror caracter, cl
	
;scriere fisier
	;fprintf (*f_out, "%c", caracter);
	xor ecx, ecx
	mov cl, caracter
	push ECX
	push offset format_caracter
	push [EBP + 12]
	call fprintf
	add ESP, 12
	jmp CITIRE_FISIER
	
FINAL_FISIER:	
;sfarsit

	mov ESP, EBP
	pop EBP
	ret 12
criptare_algoritm1 ENDP



;ALGORITM1 DECRIPTARE
decriptare_algoritm1 PROC 
	push EBP
	mov EBP, ESP
	;EBP + 4 - adresa de revenire 
	;EBP + 8 - cheie  ;EBP + 12 - adresa_fisier_iesire ;EBP + 16 - adresa_fisier
	
	;sub ESP ;dimensiunea_variabilei locale
	
;citire caracter
	;fscanf (*f_in, "%c", &caracter)
CITIRE_FISIER:
	push offset caracter
	push offset format_caracter
	push [EBP + 16]
	call fscanf
	add esp, 12
	
	cmp eax, -1 ; eax = -1 daca se ajunge la sfarsitul fisierului (eof)
	je FINAL_FISIER
	
;operatii inverse
;rotire la stanga
	xor ecx, ecx
	mov cl, [EBP + 8]
	rol caracter, cl
;complement fata de 1	
	sub caracter, 1
;revenire la normal
	not caracter

;scriere fisier
	;fprintf (*f_out, "%c", caracter);
	xor ecx, ecx
	mov cl, caracter
	push ECX
	push offset format_caracter
	push [EBP + 12]
	call fprintf
	add ESP, 12
	jmp CITIRE_FISIER
	
FINAL_FISIER:	
;sfarsit

	mov ESP, EBP
	pop EBP
	ret 12
decriptare_algoritm1 ENDP



;ALGORITM2_CRIPTARE
criptare_algoritm2 PROC
	push EBP
	mov EBP, ESP
	;EBP + 4 - adresa de revenire 
	;EBP + 8 - cheie  ;EBP + 12 - adresa_fisier_iesire ;EBP + 16 - adresa_fisier
	
	;fgets(char *bloc_10oct, 10, FILE* f)
CITESTE_FISIER:
	;citim blocul de 10 octeti
	xor ebx, ebx
	mov ebx, 11 ;ultimul caracter este terminatorul
	
	push [EBP + 16]
	push ebx 
	push offset bloc_10oct
	call fgets
	add ESP, 12
	
	cmp eax, 0 ; eax = 0 daca fgets nu mai are de citit din fisier
	je FINALUL_FISIERULUI
	
	
	;complement fata de 1
	xor edi, edi
	
	parcurgere:
	cmp edi, 10
	je gata_parcurgere
	;cmp bloc_10oct[edi], 0 ;daca blocul este mai mic de 10 octeti
	;je gata_parcurgere
		not bloc_10oct[edi]
		inc edi
		jmp parcurgere
	gata_parcurgere:	
	
	;xor
	mov EBX, [EBP + 8] ;adresa la cheie2
	mov DL, [EBX]
	xor bloc_10oct(2), DL 
	mov DL, [EBX + 1]
	xor bloc_10oct(3), DL
	mov DL, [EBX + 2]
	xor bloc_10oct(4), DL
	mov DL, [EBX + 3]
	xor bloc_10oct(5), DL
	mov DL, [EBX + 4]
	xor bloc_10oct(6), DL
	mov DL, [EBX + 5]
	xor bloc_10oct(7), DL
	mov DL, [EBX + 6]
	xor bloc_10oct(8), DL
	mov DL, [EBX + 7]
	xor bloc_10oct(9), DL
	
	;scriem in fisierul de iesire
	push offset bloc_10oct
	push offset format_string
	push [EBP + 12] 
	call fprintf
	add ESP, 12
	
	jmp CITESTE_FISIER
	
FINALUL_FISIERULUI:	
;sfarsit
	mov ESP, EBP
	pop EBP
	ret 12
criptare_algoritm2 ENDP



;ALGORITM2_DECRIPTARE
decriptare_algoritm2 PROC
	push EBP
	mov EBP, ESP
	;EBP + 4 - adresa de revenire 
	;EBP + 8 - cheie  ;EBP + 12 - adresa_fisier_iesire ;EBP + 16 - adresa_fisier
	
	;fgets(char *bloc_10oct, 10, FILE* f)
CITESTE_FISIER2:
	;citim blocul de 10 octeti
	xor ebx, ebx
	mov ebx, 11 ;ultimul caracter este terminatorul
	
	push [EBP + 16]
	push ebx 
	push offset bloc_10oct
	call fgets
	add ESP, 12
	
	cmp eax, 0 ; eax = 0 daca fgets nu mai are de citit din fisier
	je FINALUL_FISIERULUI2
		
	;xor
	mov EBX, [EBP + 8] ;adresa la cheie2
	mov DL, [EBX]
	xor bloc_10oct(2), DL 
	mov DL, [EBX + 1]
	xor bloc_10oct(3), DL
	mov DL, [EBX + 2]
	xor bloc_10oct(4), DL
	mov DL, [EBX + 3]
	xor bloc_10oct(5), DL
	mov DL, [EBX + 4]
	xor bloc_10oct(6), DL
	mov DL, [EBX + 5]
	xor bloc_10oct(7), DL
	mov DL, [EBX + 6]
	xor bloc_10oct(8), DL
	mov DL, [EBX + 7]
	xor bloc_10oct(9), DL
	
	;complement fata de 1
	xor edi, edi
	
	parcurgere:
	cmp edi, 10 
	je gata_parcurgere2
	;cmp bloc_10oct[edi], 0 ;daca blocul este mai mic de 10 octeti
	;je gata_parcurgere2
		not bloc_10oct[edi]
		inc edi
		jmp parcurgere
	gata_parcurgere2:
	
	;scriem in fisierul de iesire
	push offset bloc_10oct
	push offset format_string
	push [EBP + 12] 
	call fprintf
	add ESP, 12
	
	jmp CITESTE_FISIER2
	
FINALUL_FISIERULUI2:	
;sfarsit
	mov ESP, EBP
	pop EBP
	ret 12
decriptare_algoritm2 ENDP




start:
	;aici se scrie codul
	
citire_fisier:
	printare_text offset text_calea
	;citesc calea fisierului
	push offset cale_fisier
	call gets
	add ESP, 4 
	
	;fopen_fisier_citire
	push offset mode_read
	push offset cale_fisier
	call fopen
	add ESP, 8
	mov adresa_fisier, EAX ;memoram adresa fisierului
	
	;daca adresa este nula citim alta adresa
	cmp EAX, 0
je eroare_fisier
	
	jmp CONTINUARE1

eroare_fisier:
	printare_text offset text_eroare_citire_fisier
	jmp citire_fisier 
	
CONTINUARE1:
	
	;fopen_fisier_scriere
	push offset mode_write
	push offset cale_fisier_out
	call fopen
	add ESP, 8
	mov adresa_fisier_iesire, eax
	
CITIRE_OPERATIE:
	printare_text_parametru offset text_operatie, offset cale_fisier
	printare_text offset text_operatie_mod1
	printare_text offset text_operatie_mod2
	
	citire_date offset format_intreg, offset operatie
	
	; daca e diferit de 0 sau 1 citeste iar
	cmp operatie, 0
	je CONTINUARE_CITIRE_ALGORITM
	
	cmp operatie, 1
	je CONTINUARE_CITIRE_ALGORITM
	
	;daca a ajuns aici atunci operatia nu este buna 
	printare_text offset text_eroare_citire_operatie
	jmp CITIRE_OPERATIE		
	
CONTINUARE_CITIRE_ALGORITM:
	
	printare_text offset text_algoritm
	printare_text offset text_algoritm1
	printare_text offset text_algoritm2
	; trebuie sa mai aleg ce sa scrie intre criptare / decriptare 
	citire_date offset format_intreg, offset algoritm

	; daca e diferit de 0 sau 1 citeste iar	
	cmp algoritm, 0
	je CONTINUARE_CITIRE_CHEIE
	
	cmp algoritm, 1
	je CONTINUARE_CITIRE_CHEIE
	
	;daca a ajuns aici atunci algoritmul nu este bun
	printare_text offset text_eroare_citire_algoritm
	jmp CONTINUARE_CITIRE_ALGORITM
	
CONTINUARE_CITIRE_CHEIE:	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; trebuie sa vad ce algoritm a ales ca sa citesc cheia buna
	
	cmp operatie, 0
	je AFISARE_CRIPTARE
	
	printare_text offset text_cheie_decriptare
	jmp SARI_AFISARE
	
	AFISARE_CRIPTARE:
	printare_text offset text_cheie_criptare
	
SARI_AFISARE:
	
	; if ( alg1 ) cheie1 else cheie2
	
	cmp algoritm, 1
	je ALGORITM_2
	
;aici avem algoritmul 1
	;putem sa spunem ca, cheia trebuie sa fie mai mica decat 8 --- de facut
	printare_text offset text_citire_cheie1
	citire_date offset format_intreg, offset cheie
	cmp operatie, 1
	je DECRIPTARE_FISIER
	
		;aici avem criptarea  ;criptare_algoritm1(int cheie, FILE* f_in, FILE* f_out);
		push adresa_fisier
		push adresa_fisier_iesire
		push dword ptr cheie ;cheia este pe 8 biti 
		call criptare_algoritm1
		jmp AFARA
	
	DECRIPTARE_FISIER:
	
		;aici apelam decriptarea ;criptare_algoritm1(int cheie, FILE* f_in, FILE* f_out);
		push adresa_fisier
		push adresa_fisier_iesire
		push dword ptr cheie ;cheia este pe 8 biti
		call decriptare_algoritm1
	jmp AFARA
	
ALGORITM_2:
;algoritmul 2
	;citim cheia pe 64 de biti (8 caractere) --- Pot sa afisez un mesaj ca trebuie citite 8 caractere --- de facut!!!
	printare_text offset text_citire_cheie2
	push offset cheie2
	push offset format_string
	call scanf
	add ESP, 8
	
	cmp operatie, 1
	je DECRIPTARE_FISIER2
	
		;aici avem criptarea ;criptare_algoritm2(long int cheie2, FILE* f_in, FILE* f_out);
		push adresa_fisier
		push adresa_fisier_iesire
		push offset cheie2  
		call criptare_algoritm2
		jmp AFARA
		
	DECRIPTARE_FISIER2:
	
		;aici avem decriptarea ;decriptare_algoritm2(long int cheie2, FILE* f_in, FILE* f_out);
		push adresa_fisier
		push adresa_fisier_iesire
		push offset cheie2
		call decriptare_algoritm2
		jmp AFARA
	
AFARA:
	
	;printare_text_parametru offset text_final, offset fisier_fina
	;terminarea programului
	push 0
	call exit
end start
