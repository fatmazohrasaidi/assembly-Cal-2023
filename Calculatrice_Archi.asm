PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM
data segment 
    
    ba db   'Entrez la base des operandes (2 pour binaire,10 pour decimal,16 pour hexa) :$'
    msg db  'Entrez le premier operande : $'
    msg1 db 'Entrez le deuxieme operande : $'
    msg2 db 'Entrez un operateur arithmetique (1->+, 2->-, 3->* , 4->/) :$'
    msg3 db 'Le resultat est : $'             
    msg4 db 'operateur arithmetique invalide$'
    msg5 db 'erreur $'
    sautLigne db 0Dh,0Ah,'$';retour chariot.sautligne
    type db 20 dup('$')  
    op1 dw ?
    op2 dw ?
    base dw ? 
    operateur dw ?
    resultat dw ?  
    
ends
stack segment
    dw 128 dup(0) 
ends
 
code segment 
assume cs:code,ds:data,ss:stack

start: 
mov ax,data
mov ds,ax
mov ax,stack
mov ss,ax    
                ;la saisie de la base          
        mov dx,offset ba
        mov ah ,09h ;service affichage de chaine base
        int 21h
        
        Call SCAN_NUM                           
        mov base,cx 
         
        mov dx,offset sautLigne ; afficher msg
        mov ah ,09h ;service affichage de chaine pour sauter la ligne
        int 21h 
        
        mov ah,09h
        mov dl,offset msg2
        int 21h
        
        call SCAN_NUM 
        
        mov operateur,cx 
        mov dx,offset sautLigne ;afficher msg
        mov ah ,09h ;service affichage de chaine pour sauter la ligne
        int 21h
        cmp base,10
        je Decimal
        cmp base,2
        je binaire
        cmp base,16
        je Hexa 
        jmp saut
        
          ;les operandes
             
Decimal: mov ah,09h
         mov dl,offset msg
         int 21h 
        
         call SCAN_NUM 
         mov bx,cx

         mov dx,offset sautLigne;afficher msg
         mov ah ,09h ;service affichage de chaine pour sauter la ligne
         int 21h
        
         mov ah,09h
         mov dl,offset msg1
         int 21h
        
         call SCAN_NUM 
         mov op2,cx

         mov dx,offset sautLigne;afficher msg
         mov ah ,09h ;service affichage de chaine pour sauter la ligne
         int 21h 
         
 
           
addition:       cmp operateur,1 
                jne soustraction
                ADD bx,op1
                mov resultat,bx
                jmp fin

          
soustraction:   cmp operateur,2
                jne Multiplication      ;******** complemant a 2 *******
                sub bx,op2
                mov resultat,bx 
                jmp fin
               
Multiplication: cmp operateur,3
                jne division 
                mov ax,op1 
                mul bx
                mov resultat,ax    ;le resultat de mul est toujours affecte a ax
                jmp fin
                        
division:       cmp operateur,4
                jne invalid_opera
                cmp bx, 0
                jne deci_div
                mov dx, offset msg5 
                jmp afficher_msg

deci_div:       mov ax,op1
                mov bx,bx
                xor dx,dx
                div bx                ;le reste dans dx le quotion dans ax
                mov resultat,ax
                jmp fin 
            
invalid_opera:  mov dx, offset msg4
                jmp afficher_msg

afficher_msg:   mov ah, 09h
                int 21h
                jmp saut
                
                
binaire:  mov dx,offset msg
          mov ah,09h
          int 21h
       
          mov bx,0
          mov cx,16  
       
again:  mov ah,01h
        int 21h 
        cmp al,13
        je printout
        ;49--->0011 0001 48-->00110000
        ;convert ascii to decimal
        and al,0FH  
        shl bx,1 ;rotate bx to left by 1 bit
        or bl,al ;bl=0000 0010 al=0000 0001 bl=0000 0001
        loop again
        
printout: mov ah,09h
          lea dx,msg
          int 21H
          mov op1,bx
          mov cx,16
      
disp: shl bx,1
      jnc again1
      mov dl,49
      mov ah,02H
      int 21h 
      jmp display
     
again1: mov ah,02H 
        mov dl,48
        int 21h
           
display: loop disp
         mov dx,offset sautLigne
         mov ah,09H
         int 21h 
         mov dx,offset msg1
         mov ah,09h
         int 21h 
   
      ;lecture du deuxieme nombre
        mov bx,0
        mov cx,16
        
again2: mov ah,01h
        int 21h 
        cmp al,13
        je printout2
        ;49--->0011 0001 48-->00110000
        ;convert ascii to decimal
        and al,0FH  
        shl bx,1 ;rotate bx to left by 1 bit
        or bl,al ;bl=0000 0010 al=0000 0001 bl=0000 0001
        loop again2
        
printout2: mov ah,09h
           lea dx,msg1
           int 21H 
           mov op2,bx
           mov cx,16 
     
disp2: shl bx,1
       jnc again12
       mov dl,49
       mov ah,02H
       int 21h 
       jmp display2
     
again12:  mov ah,02H 
          mov dl,48
          int 21h 
              
display2: loop disp2
          mov dx, offset sautLigne
          mov ah, 09h
          int 21h
               
          cmp operateur,4
          jne multi
 
          mov ax,op1
          mov bx,op2
          mov bx,bx
          xor dx,dx
          div bx 
          mov bx,ax
    
print_result4:  mov ah, 09h
                lea dx, msg3
                int 21h
                mov bx,bx
                mov cx, 16
    
print_binary4: shl bx, 1
               jnc binary_digit_04
               mov dl, '1'
               jmp print_digit4
               
binary_digit_04:mov dl, '0'

print_digit4: mov ah, 02h
              int 21h
              loop print_binary4
              jmp saut   
                     
multi: cmp operateur,3
       jne soustr
       mov ax, op1
       mov bx, op2     
       mul bx
       mov bx, ax 
       ; move high word to ax for display purposes
    
print_result3:  mov ah, 09h
                lea dx, msg3
                int 21h 
                mov bx,bx
                mov cx, 16
                
print_binary3: shl bx, 1
               jnc binary_digit_03
               mov dl, '1'
               jmp print_digit3
               
binary_digit_03: mov dl, '0'

print_digit3:  mov ah, 02h
               int 21h
               loop print_binary3
               jmp saut
        
soustr: cmp operateur,2
        jne addit
        mov bx,op1
        sub bx,op2
  
print_result2:  mov ah, 09h
                lea dx, msg3
                int 21h
                mov cx, 16
                
print_binary2:  shl bx, 1
                jnc binary_digit_02
                mov dl, '1'
                jmp print_digit2
    
binary_digit_02: mov dl, '0' 

print_digit2:  mov ah, 02h
               int 21h
               loop print_binary2
               jmp saut
             
addit:    cmp operateur,1
          jne invalid_opera
          mov bx,op2
          add op1,bx
   
print_result: mov ah, 09h
              lea dx, msg3    ;afficher message
              int 21h 
              mov bx, op1
              mov cx, 16
              
print_binary: shl bx, 1
              jnc binary_digit_0
              mov dl, '1'
              jmp print_digit
    
binary_digit_0: mov dl, '0'

print_digit:   mov ah, 02h
               int 21h
               loop print_binary
               jmp saut 
               
Hexa:     mov operateur,cx
          cmp operateur,1
          je addition_hex
          
          
          cmp operateur,2
          je soustraction_hex
          
          cmp operateur,3
          je multiplication_hex
          
          cmp operateur,4
          je division_hex
          
          
addition_hex:
          ;saut de la ligne
          mov ah,09h
          mov dx,offset sautLigne
          int 21h

          mov ah,09h
          mov dx,offset msg
          int 21h
       
          call SCAN_hex    ;met la valeur dans cx
          
          mov op1,cx
         
          
          ;saut de la ligne
          mov ah,09h
          mov dx,offset sautLigne
          int 21h
          
          mov ah,09h
          mov dx,offset msg1
          int 21h
          
          call SCAN_hex ;met la valeur dans cx
          mov ax,cx
                  
          add op1,ax
          
          ;saut de la ligne
          mov ah,09h
          mov dx,offset sautLigne
          int 21h
          
          mov ah,09h
          mov dx,offset msg3
          int 21h
                  
          mov ax,op1        
          CALL print_hex         
soustraction_hex:
          ;saut de la ligne
          mov ah,09h
          mov dx,offset sautLigne
          int 21h

          mov ah,09h
          mov dx,offset msg
          int 21h
       
          call SCAN_hex    ;met la valeur dans cx
          ;sauvgarder la premiere valeur dans a
          mov op1,cx
          
          
          ;saut de la ligne
          mov ah,09h
          mov dx,offset sautLigne
          int 21h
          
          mov ah,09h
          mov dx,offset msg1
          int 21h
          
          call SCAN_hex ;met la valeur dans cx
          ;sauvgarder la deuxieme valeur dans b
          mov op2,cx
          ;mov la premiere valeur dans bx
          mov bx,op1      
          sub bx,op2; fait la soustraction et sauvgarder le resultat dans bx
      
          mov op1,bx;copier le resultat dans a
          
          ;saut de la ligne
          mov ah,09h
          mov dx,offset sautLigne
          int 21h 
          
          mov ah,09h
          mov dx,offset msg3
          int 21h
          
          mov ax,op1;copier le resultat dans ax pour afficher
          CALL print_hex  
          
          
multiplication_hex:
          ;saut de la ligne
          mov ah,09h
          mov dx,offset sautLigne
          int 21h

          mov ah,09h
          mov dx,offset msg
          int 21h
       
          call SCAN_hex    ;met la valeur dans cx
          ;sauvgarder la premiere valeur dans a
          mov op1,cx
          
          
          ;saut de la ligne
          mov ah,09h
          mov dx,offset sautLigne
          int 21h
          
          mov ah,09h
          mov dx,offset msg1
          int 21h
          
          call SCAN_hex ;met la valeur dans cx
          ;sauvgarder la deuxieme valeur dans b
          mov op2,cx
          ;mov la premiere valeur dans ax
          mov ax,op1      
          mul op2; fait la multiplication et sauvgarder le resultat dans ax(par default)
          
          
          mov op1,ax;mov le resultat dans a
          
          ;saut de la ligne
          mov ah,09h
          mov dx,offset sautLigne
          int 21h 
          
          mov ah,09h
          mov dx,offset msg3
          int 21h
          
          mov ax,op1;copier le resultat dans ax pour afficher
          CALL print_hex           
division_hex:
          ;saut de la ligne
          mov ah,09h
          mov dx,offset sautLigne
          int 21h

          mov ah,09h
          mov dx,offset msg
          int 21h
       
          call SCAN_hex    ;met la valeur dans cx
          ;sauvgarder la premiere valeur dans a
          mov op1,cx
          
          
          ;saut de la ligne
          mov ah,09h
          mov dx,offset sautLigne
          int 21h
          
          mov ah,09h
          mov dx,offset msg1
          int 21h
          
          call SCAN_hex ;met la valeur dans cx
          ;sauvgarder la deuxieme valeur dans b
          mov op2,cx
          
          mov ax,op1
          mov bx,op2
          mov bx,bx
          xor dx,dx
          div bx
          mov bx,ax
          
          
          ;saut de la ligne
          mov ah,09h
          mov dx,offset sautLigne
          int 21h
          
          mov ah,09h
          mov dx,offset msg3
          int 21h
          
          mov ax,bx;copier le resultat dans ax pour afficher
          CALL print_hex        

;---------------------------------------------------------------------------------------------------------------------------   
;print_hex affiche la valeur en hexadicimale de registre ax  
print_hex        PROC    NEAR 
   
          mov cx,0
          mov dx,0
          mov bx,10h
          
          empilerh:
          div bx     ;diviser ax par bx 
          cmp dx,1010b;tester avec 10
          je turnL
          cmp dx,1011b ;tester avec11
          je turnL
          cmp dx,1100b;tester avec 12 
          je turnL
          cmp dx,1101b;tester avec 13
          je turnL
          cmp dx,1110b;tester avec 14
          je turnL
          cmp dx,1111b;tester avec 15
          je turnL 
          jmp continue
          
    turnL: add dx,7;ajouter 7 si la nombre >9
          
 continue:add dx,48  ;ajouter au reste de la division 48 pour convertir le nb en dicimal
          push dx     ; empiler dx
          mov dx,0    ; rendre dx a 0
          inc cx       ; inc cx "cobient d'iter
          cmp ax,0
          jne empilerh
          
          depilerh:
          pop dx       ; depiler dans dx
          mov ah,02h
          int 21h
          loop depilerh ; dec cx <> 0 loop 
print_hex        ENDP           
           
      
;---------------------------------------------------------------------------------------------------------------------------          
;scan_hex read un nombre hexadecimale MAIs les caractere MAJISCULE seulement          
SCAN_hex        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI        
        MOV     CX, 0
        ; reset flag:
        MOV     CS:make_minus, 0

next_digit:
        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h
        INT     16h
        ; and print it:
        MOV     AH, 0Eh
        INT     10h
        ; check for ENTER key:
        CMP     AL, 13  ; carriage return?
        JNE     not_cr
        JMP     stop_input
not_cr:
        CMP     AL, 8                   ; 'BACKSPACE' pressed?
        JNE     backspace_checked
        MOV     DX, 0                   ; remove last digit by
        MOV     AX, CX                  ; division:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        PUTC    ' '                     ; clear position.
        PUTC    8                       ; backspace again.
        JMP     next_digit
backspace_checked:
        ; allow only digits:
        CMP     AL, '0'
        JAE     ok_AE_0;jump if above or equal
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:
        CMP     AL, 'F'
        JBE     ok_digit  ;jump if bellow or equal       
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered not digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for next input.            
ok_digit:
        ; multiply CX by 10 (first time the result is zero)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten_hex                  ; DX:AX = AX*10h
        MOV     CX, AX
        POP     AX

        ; check if the number is too big
        ; (result should be 16 bits)
        CMP     DX, 0
        JNE     too_big

        ; convert from ASCII code:
        CMP     AL, '9'
        JBE     min_num;jump if above or equal
      
        SUB     AL, 7h       
min_num:SUB     AL, 30h
 
        ;add AL to CX:
        MOV     AH, 0
        MOV     DX, CX      ;backup, in case the result will be too big.
        ADD     CX, AX
        JC      too_big2    ;jump if the number is too big. 
        JMP     next_digit
too_big2:
        MOV     CX, DX      ; restore the backuped value before add.
        MOV     DX, 0       ; DX was zero before backup!
too_big:
        MOV     AX, CX
        DIV     CS:ten  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for Enter/Backspace.        
stop_input:
        ; check flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:
        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; used as a flag. 
ten_hex         DW      10h      ; used as multiplier.
ten             DW      10
SCAN_hex        ENDP          
  
           
fin:        mov ah,09h
            mov dl,offset msg3
            int 21h
            mov ax,resultat  ;metter la somme dans ax 
            mov cx,0
            mov dx,0
            jmp Affichage

Affichage: mov bx,10 
           empiler:
           div bx    ;res=ax deviser ax par bx
           add dx,48
           PUSH dx
           mov dx,0
           inc cx
           cmp ax,0
           jne empiler
      
           depiler:
           pop dx 
           mov ah,02h
           int 21h
           loop depiler ;dec cx<> 0 loop
           
                       
saut:   mov dx,offset sautLigne ; afficher msg
        mov ah ,09h ;service affichage de chaine pour sauter la ligne
        int 21h 
        

        mov ah,4ch;exit
        int 21H 
        
     
SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        
        MOV     CX, 0

        ; reset flag:
        MOV     CS:make_minus, 0

next_digit1:

        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h
        INT     16h
        ; and print it:
        MOV     AH, 0Eh
        INT     10h

        ; check for MINUS:
        CMP     AL, '-'
        JE      set_minus1

        ; check for ENTER key:
        CMP     AL, 13  ; carriage return?
        JNE     not_cr1
        JMP     stop_input1
not_cr1:


        CMP     AL, 8                   ; 'BACKSPACE' pressed?
        JNE     backspace_checked1
        MOV     DX, 0                   ; remove last digit by
        MOV     AX, CX                  ; division:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        PUTC    ' '                     ; clear position.
        PUTC    8                       ; backspace again.
        JMP     next_digit1
backspace_checked1:


        ; allow only digits:
        CMP     AL, '0'
        JAE     ok_AE_01
        JMP     remove_not_digit1
ok_AE_01:        
        CMP     AL, '9'
        JBE     ok_digit1
remove_not_digit1:       
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered not digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit1 ; wait for next input.       
ok_digit1:


        ; multiply CX by 10 (first time the result is zero)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten1                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; check if the number is too big
        ; (result should be 16 bits)
        CMP     DX, 0
        JNE     too_big1

        ; convert from ASCII code:
        SUB     AL, 30h

        ; add AL to CX:
        MOV     AH, 0
        MOV     DX, CX      ; backup, in case the result will be too big.
        ADD     CX, AX
        JC      too_big12    ; jump if the number is too big.

        JMP     next_digit1

set_minus1:
        MOV     CS:make_minus1, 1
        JMP     next_digit1

too_big12:
        MOV     CX, DX      ; restore the backuped value before add.
        MOV     DX, 0       ; DX was zero before backup!
too_big1:
        MOV     AX, CX
        DIV     CS:ten  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit1 ; wait for Enter/Backspace.
        
        
stop_input1:
        ; check flag:
        CMP     CS:make_minus1, 0
        JE      not_minus1
        NEG     CX
not_minus1:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus1      DB      ?       ; used as a flag.
ten1             DW      10      ; used as multiplier.
SCAN_NUM   ENDP
   
ends

end start