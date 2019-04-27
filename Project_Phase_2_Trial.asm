DELAY  MACRO  v1 , v2     
        
        MOV AL,0H
        MOV AH,86H    
        MOV CX,V1
        MOV DX,V2    
        INT 15H 
   
ENDM    DELAY

;-------------------------------------------------------------------------------------------------------------------
        
        .MODEL SMALL
        .STACK 64
        .DATA                                                     
      
      ;players intial health
         
p1health      DB  4H
p2health      DB  4H   
      
      ;fire intial position     
      
;bullet status (=0) if the bullet doesn't exist, (=1) if exists
;bullet direction is 0 for right, 1 for left
;Each player has oe bullet at a time  
;bulletrw , bulletcl are the x and y for the bullet
;typebul identifies the type of the bullet for level 2 of the game (0 for type1 , 1 for type2)  
    
    ;Left player 
          
bulletrw1     DW  ?         
bulletcl1     DW  ?
statbul1      DB  0H
dirbul1       DB  0H
typebul1      DB  0H
    
    ;Right player  
    
bulletrw2     DW  ?
bulletcl2     DW  ?
statbul2      DB  0H
dirbul2       DB  1H
typebul2      DB  0H
    
    ;bullet selector (a variable to select which bullet will be moved from the 2 bulets
    ;if 1, then we move the first bullet, if 2, then we move the second one
    
bulselect db 1          

      ;the main menu text.

MES1          DB  'Please enter the username: $'
MES2          DB  'Please press enter to continue $'
PRESS1        DB  '-To start chating press F1 $'
PRESS2        DB  '-To start the game press F2 $'
PRESS3        DB  '-To end the program press Esc $' 
PRESS4        DB  'Press F4 to end the game with $'
NOT1          DB  'You sent a chat invitation to $'  
NOT2          DB  'Sent you a game invitation to accept press F2 $'
NOT3          DB  'You sent a game invitation to $'
NOT4          DB  'Sent you a chat invitation to accept press F1 $' 
NOT5          DB  ' is selecting the level now please wait $'
PWIN          DB  'Wins $'   
PLOS          DB  'lost $'
GAV           DB  'GAME OVER $'
PRESSN1       DB  'PRESS 1 TO SELECT LEVEL1 $'
PRESSN2       DB  'PRESS 2 TO SELECT LEVEL2 $'
INVITE        DB  'b'
INVITE2       DB   ?
indicator     dW   0H
indicator1    dW   0H   

;FOR LEVEL ONE 
GOUP_P2       DB   'U' 
GODOWN_P2     DB   'D'
GOFIRE        DB   'F' 
GOFIRE1       DB   'f'
pause_tab     DB   'e'
free_pause    DB   'q'  
bara          DB   'x'
      ;player names 
      
USERNAME1     DB  17,?,17 DUP('$')  
USERNAME2     DB  17,?,17 DUP('$') 

bool          DB 0H                         ; this bool will determine the first person who press f2 and allow him to select the level 
                                            ; and show to the second one window to told him that the first one pressed the f2 is selecting the level
                                            ; then call the level for him and start the game 
          
numOflevel    DB  1H
numOflevel2   DB  2H         

      ;Chatting variables    
         
    ;chatting positions on screen 
                    
X_Write       DB  00H
Y_Write       DB  01H 
X_Read        DB  00H
Y_Read        DB  0BH    
   
    ;messages contents
     
value_write   DB  ? 
value_read    DB  ? 
SPACE         DB  ' '
                         
      ;barrier intial position (X , Y) 
      
BARRIERX      DW  0A0H     
BARRIERY      DW  1AH   

      ;barrier condition ( 1: up , 0: down ) 
      
BARRCASE      DB  0H

      ;barrier pause status
      
BARRPAUSE     DB 0H      

      ;players body
X1            DW  16D                       ;intial X for player 1 
Y1            DW  66D                       ;intial Y for player 1
X2            DW  307D                      ;intial X for player 2
Y2            DW  66D                       ;intial Y for player 2
    
   ; PLAYER1 TYPING POSITION   
P1XW          DB 01H                             
P1YW          DB 11H  

   ; PLAYER 2 TYPING POSITION
P2XW          DB 01H                             
P2YW          DB 13H                             

P1VW          DB ? 
P2VW          DB ?  

NEWL          DB 0H                     
NEWW          DB 0H     
;--------------------------------------------------------------------------------------------------------------------
               
        .CODE
Main    PROC FAR  
    
        MOV AX, @DATA
        MOV DS, AX 
        
        CALL MENU                           ;draw the main menu to take the players' names
        
MENUM:  
CLBUF1:
        MOV AH,1H
        INT 16H
        JZ CSER1
        MOV AH,0H
        INT 16H
        JMP CLBUF1
CSER1:                
        MOV BOOL,0H
        CALL MMENU                          ;print the options of the game (game,chat,end)

           
     ;check for the pressed key to choose the desired action
           
CHECK:  CALL SERIALCONFIG   

        MOV AH,1
        INT 16H   
        
        JZ RECIEVE      ;hwa mdas4 tyb galo 7aga ? 
        
        CMP AH,3CH                          ;if the player pressed F2
        JZ INVITATION  ;playing mode
        
        CMP AH,3BH
        JZ CINVITATION
        
        CMP AH,01H                          ;if the player end the game
        JZ ESCK 
        
RECIEVE:
                                
        mov dx , 3FDH	                    ;Line Status Register?
        in  al , dx
        AND al , 1H
        JZ CHECK        ;mgalo4 7aga tyb das ?
        
                                            ;If Ready read the VALUE in Receive data register?
        mov dx , 03F8H                    
        in al , dx 
        mov OFFSET INVITE2,al 
        CMP INVITE2,62H   ;b like invite1 by check lw galo b yb2a hyl3b ; y3ny k2nha f2 bs waleed ksl y check b f2
        JZ GOTINVITE 
        CMP INVITE2,01H    ;for esc                                                                  
        JZ  ESC 
        CMP INVITE2,9AH
        JZ CGOTINVITE 
        
        MOV AH,0H
        int 16H
        JMP CHECK   
 
       
    ;--------------------------------------------------------
        
CHECK2: 
        MOV AH,0                 ;3l4an yfdy el buffer w lw hwa 2ly byb3t 
        INT 16H 
        CMP AH,3BH
        JZ  CH_SEND_H2
        CMP AH,3CH
        JZ CH_SEND_N2
        CMP AH,01H
        JZ ESC 
        jmp CHECK2                          ;if the player pressed random key                    
        

CINVITATION:  

        mov ah,0
        int 16h 
        CALL SERIALCONFIG
        CH_SEND_T:
        mov dx , 3FDH	                      ; Line Status Register?
        In al , dx                            ;Read Line Status?
        AND al , 00100000b
        JZ CH_SEND_T
                                              ; send the data if valid
        mov dx, 3F8H	                      ; Transmit data register?
        mov al, 9AH 
                                              ; test to show the number in the terminal
        out dx , al
        mov BH,0H
        mov DX,01700H
        mov AH,2H                           ;displaying the status bar msg
        INT 10H
        
        MOV DX,OFFSET NOT1
        MOV AH,9H
        INT 21h 
        
        MOV DX,OFFSET USERNAME2+2
        MOV AH,9H
        INT 21H  
  
 ;----------------THIS PART TO DISPLAY THE NAME WHICH WE ARE SENDING AND RECIEVING---------- 
       
       ;CALL SERIALCONFIG                                 THEM TO CHECK THE CODE 
       CH_RECIEVE_N:
        mov dx , 3FDH	                ; Line Status Register?
        in al , dx
        AND al , 1
        JZ CH_RECIEVE_N
                    ;If Ready read the VALUE in Receive data register?
        mov dx , 03F8H                    
        IN al , dx 
        mov OFFSET INVITE2,al 
        CMP INVITE2,9AH
        JNZ CH_RECIEVE_N    
                    
        jmp F1                          ;if the player pressed random key 
        
        CGOTINVITE:
                 ;printing the status bar message  
      
        mov BH,0H
        mov DX,01700H
        mov AH,2H
        INT 10H
        
        MOV DX,OFFSET USERNAME2+2
        MOV AH,9H
        INT 21H      
        
        MOV DX,OFFSET NOT4
        MOV AH,9H
        INT 21h
        
        jmp CHECK2
        
CH_SEND_H2: 
        CALL SERIALCONFIG
        mov dx , 3FDH	                      ; Line Status Register?
        In al , dx                            ;Read Line Status?
        AND al , 00100000b
        JZ CH_SEND_H2 
                                              ; send the data if valid
        mov dx, 3F8H	                      ; Transmit data register?
        mov al, 9AH 
                                              ; test to show the number in the terminal
        out dx , al 
        JMP F1
;----------------------------------------------------------------------------------------



        
INVITATION:
         ; PUT THE SIZE OF THE FIRST NAME IN BP
        mov ah,0
        int 16h 
        CALL SERIALCONFIG
        CH_SEND_N:
        mov dx , 3FDH	                      ; Line Status Register?
        In al , dx                            ;Read Line Status?
        AND al , 00100000b
        JZ CH_SEND_N 
                                              ; send the data if valid
        mov dx , 3F8H	                      ; Transmit data register?
        mov  al,INVITE 
                                              ; test to show the number in the terminal
        out dx , al
                                              ;Check that Data Ready?
                    
        mov BH,0H
        mov DX,01700H
        mov AH,2H                           ;displaying the status bar msg
        INT 10H
        
        MOV DX,OFFSET NOT3
        MOV AH,9H
        INT 21h 
        
        MOV DX,OFFSET USERNAME2+2
        MOV AH,9H
        INT 21H  
        mov bool,1
  
 ;----------------THIS PART TO DISPLAY THE NAME WHICH WE ARE SENDING AND RECIEVING---------- 
       
       ;CALL SERIALCONFIG                                 THEM TO CHECK THE CODE 
       CH_RECIEVE_H:
        mov dx , 3FDH	                ; Line Status Register?
        in al , dx
        AND al , 1
        JZ CH_RECIEVE_H
                    ;If Ready read the VALUE in Receive data register?
        mov dx , 03F8H                    
        IN al , dx 
        mov OFFSET INVITE2,al 
        CMP INVITE2,62H
        JNZ CH_RECIEVE_H    
                    
   
        jmp F2                          ;if the player pressed random key 
        
        GOTINVITE:
                 ;printing the status bar message  
      
        mov BH,0H
        mov DX,01700H
        mov AH,2H
        INT 10H
        
        MOV DX,OFFSET USERNAME2+2
        MOV AH,9H
        INT 21H      
        
        MOV DX,OFFSET NOT2
        MOV AH,9H
        INT 21h
        
        jmp CHECK2
        
CH_SEND_N2: 

        CALL SERIALCONFIG
        mov dx , 3FDH	                      ; Line Status Register?
        In al , dx                            ;Read Line Status?
        AND al , 00100000b
        JZ CH_SEND_N2 
                                              ; send the data if valid
        mov dx, 3F8H	                      ; Transmit data register?
        mov al, INVITE 
                                              ; test to show the number in the terminal
        out dx , al
                    
         
;----------------------------------------- GAMING MODE -------------------------------------------------------------
 
                                            
    F2: CALL SETV                           ;reset the variable to reload the game

     ;printing the status bar message  
        cmp bool,1
        jz boolqeualone
        jmp boolnotequalone
        
     ;start the video mode for gaming  
boolqeualone:
        CALL lvlsel 
boolnotequalone:
        call showlvlsel
       
;----------------------------------------- CHATTING MODE -----------------------------------------------------------  
                                       ;[TO BE ADDED LATER]
 
    F1:
       CALL CHAT    
JMP F1
;----------------------------------------- END GAME ----------------------------------------------------------------        
ESCK :
        mov ah,0
        int 16h 
        CALL SERIALCONFIG
        CH_SEND_Q:
        mov dx , 3FDH	                      ; Line Status Register?
        In al , dx                            ;Read Line Status?
        AND al , 00100000b
        JZ CH_SEND_Q 
                                              ; send the data if valid
        mov dx , 3F8H	                      ; Transmit data register?
        mov  al,01H 
                                                      ; test to show the number in the terminal
        out dx , al
                                               
        ;JMP ESC 
                    
   ESC:
     
        MOV AX,0600h
        MOV BH,07H
        MOV CX,0H
        MOV DX,184FH
        INT 10H                               ;clear the screen of the dosbox
        
        mov ah,0x4C                           ;use DOS "terminate" function
        int 0x21                                ;to close the program
                                     
        HLT
Main    ENDP

;----------------------------------------- USED FUNCTIONS ----------------------------------------------------------
;-------------------------------------------------------------------------------------------------------------------


;----------------------------------- game screen -----------------------------------------

overlay PROC  
          
        MOV AL,0FH                          ;first set the drawing color to white
        MOV CX,0H                           ;second set the inline chat bar dimensions
        MOV DX,84H        
        MOV AH,0CH                          ;drawing command

Lp1:    INT 10H                             ;first draw the inline bar
        ADD DX,2AH                          ;set the status bar position
        INT 10H                             ;draw the status bar
        SUB DX,2AH 
        SUB DX,6FH
        INT 10H                             ;draw the health bar dimensions
        ADD DX,6FH
        INC CX
        CMP CX,140H                         ;draw the full lines
        JNZ Lp1  
                                            ;set 
       ; MOV AL,0FH                          
        MOV CX,13H                          ;set the health borders dimensions
        MOV DX,02H  
        MOV AH,0CH
                                            ;here we draw the horizontal lines of the borders
Lp2:    INT 10H 
        ADD DX,0FH
        INT 10H
        ADD CX,0DAH
        INT 10H
        SUB DX,0FH
        INT 10H
        SUB CX,0DAH
        INC CX
        CMP CX,53H
        JNZ Lp2  
         
        MOV CX,13H
        MOV DX,03H
        
Lp3:    INT 10H
        ADD CX,3FH                          ;here we draw the vertical lines of the borders
        INT 10H 
        ADD CX,0DAH
        INT 10H
        SUB cx,3fh
        INT 10h
        MOV cx,13h
        INC dx
        CMP dx,11H
        JNZ Lp3
        
        MOV al,12                           ;set the color of the health
        MOV cx,14H                          ;set the first position of the health
        MOV dx,03H  
        MOV ah,0CH   
        
FILL:   int 10h                             ;draw the health line by line
        add cx, 0dah
        int 10h
        sub cx, 0dah
        inc cx
        cmp cx, 52h
        jnz FILL
        cmp dx, 10h
        jnz NEXT
        jz EXT

NEXT:   inc dx            
        MOV cx,14h
        jmp FILL
        
EXT:   ; CALL INChat                           ;write the players' names in the inline chat block
        CALL tempo 
        MOV DX, OFFSET PRESS4               ;write the status bar message
        MOV AH, 9H
        INT 21H   
        MOV DX, OFFSET USERNAME2 + 2
        INT 21H
        RET
         
overlay endp 
                  
;----------------------------------- left player health decrement ------------------------
                 
dechth1 proc
        
        MOV DI, OFFSET p1health             ;get the left player health value
        DEC [DI]                            ;decrease the health by 1

        MOV AL, 0H                          ;delete a squere from the left player health bar
        MOV CX, 51H                           ;by drawing a black squere with dimensions (51H*03H)
        MOV DX, 03H  
        MOV AH, 0CH
                    
                                            ;check the health to get the position where to draw the black quere
        CMP [DI], 3H                        
        JZ HB13
        CMP [DI], 2H
        JZ HB12
        CMP [DI], 1H
        JZ HB11
        CMP [DI], 0H
        JZ HB10
        
HB13:   INT 10H                             ;if the health became 3 draw over the last square the health bar
        DEC CX                              ;the technique used is to delete line by line
        CMP CX, 43H
        JNZ HB13
        cmp dx, 10H
        JNZ NEXT1                           ;to get the next line
        JMP RTN 
        
NEXT1:  INC DX
        MOV CX, 51H
        JMP HB13                      

HB12:   INT 10H                             ;if the health became 2 draw over the third square the health bar
        DEC CX
        CMP CX, 34H
        JNZ HB12
        CMP DX, 10H
        JNZ NEXT2
        JMP RTN  
        
NEXT2:  INC DX
        MOV CX, 51H
        JMP HB12                      

HB11:   INT 10H                             ;if the health became 1 draw over the second square the health bar
        dec cx
        cmp cx, 24H
        jnz HB11
        CMP DX, 10H
        JNZ NEXT3
        JMP RTN 
        
NEXT3:  INC DX
        MOV CX, 51H
        JMP HB11                      

HB10:   INT 10H                             ;if the health became 0 draw over the first square the health bar
        DEC CX
        CMP CX, 14H
        JNZ HB10
        CMP DX, 10H
        JNZ NEXT4
        JMP RTN  
        
NEXT4:  INC DX
        MOV CX, 51H
        JMP HB10                      
        
RTN:    CALL CHEALTH
        RET

dechth1 endp                          
        
;----------------------------------- right player health decrement -----------------------

dechth2 proc
        
        MOV di, offset p2health             ;get the right player health value
        dec [di]                            ;decrease the health by 1

        MOV al, 0H                          ;delete a squere from the left player health bar
        MOV cx, 12bh                          ;by drawing a black squere with dimensions (51H*03H)
        MOV dx, 03h  
        MOV ah, 0ch
                                            
                                            ;check the health to get the position where to draw the black quere
        cmp [di], 3H
        jz HB23
        cmp [di], 2H
        jz HB22
        cmp [di], 1H
        jz HB21
        cmp [di], 0H
        jz HB20
        
HB23:   int 10h                             ;if the health became 3 draw over the last square the health bar
        dec cx                              ;the technique used is to delete line by line
        cmp cx, 11dh
        jnz HB23
        cmp dx, 10h
        jnz NEXTT1
        jmp RTNN     
        
NEXTT1: inc dx                              ;to get the next line
        MOV cx, 12bh
        jmp HB23                      

HB22:   int 10h                             ;if the health became 2 draw over the third square the health bar
        dec cx
        cmp cx, 10eh
        jnz HB22
        cmp dx, 10h
        jnz NEXTT2
        jmp RTNN
NEXTT2: inc dx
        MOV cx, 12bh
        jmp HB22                      

HB21:   int 10h                             ;if the health became 1 draw over the second square the health bar
        dec cx
        cmp cx, 0feh
        jnz HB21
        cmp dx, 10h
        jnz NEXTT3
        jmp RTNN
NEXTT3: inc dx
        MOV cx, 12bh
        jmp HB21                      

HB20:   int 10h                             ;if the health became 0 draw over the first square the health bar
        dec cx                           
        cmp cx, 0eeh
        jnz HB20
        cmp dx, 10h
        jnz NEXTT4
        jmp RTNN
NEXTT4: inc dx
        MOV cx, 12bh
        jmp HB20                      
        
RTNN:   CALL CHEALTH
        RET

dechth2 endp

;----------------------------------- Move bullet type1 in right direction ----------------------
                                                                                         
movbulr proc
        
        mov bx, offset bulselect            ;get the selected bullet to be moved
        cmp [bx], 1
        jz BUL1
        jnz BUL2

BUL1:   MOV BL, statbul1                    ;case bullet 1 is selected
        CMP BL, 0H                          ;load bullet 1 position, if it exists    
        JZ XC
        mov di, offset bulletrw1
        mov dx, [di]
        
        mov di, offset bulletcl1
        mov cx, [di]
        
        jmp MOVEON
        
BUL2:   MOV BL, statbul2                    ;case bullet 2 is selected
        CMP BL, 0H                          ;load bullet 2 position, if it exists
        JZ XC
        mov di, offset bulletrw2
        mov dx, [di]
        
        mov di, offset bulletcl2
        mov cx, [di]
        
        jmp MOVEON                
                
MOVEON: mov bx, offset bulselect            ;compare the adjacent pixel to the bullet to decide the next step
        add cx, 2
        MOV ah, 0dh
        int 10h
        
        cmp cx, 307D                        ;check if the bullet exceeds the player position
        jae DEST1
        
        cmp cx, 16D
        jbe DEST1
        
        cmp al, 2                           ;check if the adjacent pixel is green, then the bullet bounces
        jz BOUNCE
        
        cmp al, 4                           ;check if the adjacent pixel is red, then decrease first player's health
        jz DECH1
        
        cmp al, 1                           ;check if the adjacent pixel is blue, then decrease second player's health
        jz DECH2  
        
        INC DX                              ;repeat the same checks on the pixel below
        MOV ah, 0dh
        int 10h
        DEC DX 
        
        cmp al, 2
        jz BOUNCE
        
        cmp al, 4
        jz DECH1
        
        cmp al, 1
        jz DECH2
                                                 
        jMP DCONT                            ;if none of the above is correct, the bullet moves normally
                 
BOUNCE: cmp [bx], 1                         ;Bounce checks for the selected bullet and then check whether 
        jz BNC1                             ;the pixel on the other sides is also green, then the bullet gets destroyed 
        jnz BNC2                            ;if not, then it calls move left
        
BNC1:   sub cx, 3h
        MOV ah, 0dh
        int 10h
        cmp al, 2
        jz DEST1
        inc dx
        MOV ah, 0dh
        int 10h
        cmp al, 2
        jz DEST1
        mov bx, offset dirbul1
        mov [bx], 1         
        call movbull                 
        RET 

BNC2:   sub cx, 3h
        MOV ah, 0dh
        int 10h
        cmp al, 2
        jz DEST1
        inc dx
        MOV ah, 0dh
        int 10h
        cmp al, 2
        jz DEST1
        mov bx, offset dirbul2
        mov [bx], 1         
        call movbull                 
        RET                     
           
DECH1:  cmp [bx], 1                         ;check the selected bullet and decreases the first player health
        jz DECH11                           ;then destroy the bullet
        jnz DECH12
        
DECH11: mov bx, offset statbul1
        mov [bx], 0
        jmp DECH1G
        
DECH12: mov bx, offset statbul2
        mov [bx], 0 
        jmp DECH1G
                        
DECH1G: sub cx, 2                           ;destroy the bullet by drawing it black and set the state variable to 0
        MOV al, 0
        MOV ah, 0ch
        int 10h
        inc cx
        int 10h
        dec cx
        inc dx
        int 10h
        inc cx
        int 10h
        call dechth1
        RET
        
DECH2:  cmp [bx], 1                         ;check the selected bullet and decreases the second player health
        jz DECH21                           ;then destroy the bullet
        jnz DECH22
        
DECH21: mov bx, offset statbul1
        mov [bx], 0
        jmp DECH2G
        
DECH22: mov bx, offset statbul2
        mov [bx], 0 
        jmp DECH2G
        
                                
DECH2G: sub cx, 2                           ;destroy the bullet by drawing it black and set the state variable to 0
        MOV al, 0
        MOV ah, 0ch
        int 10h
        inc cx
        int 10h
        dec cx
        inc dx
        int 10h
        inc cx
        int 10h
        call dechth2
        RET
          
DCONT:  sub cx, 2                           ;move bullet normally
        MOV BL, 8H
        call drwbulr          
        RET

DEST1:  cmp [bx], 1
        jz DEST11
        jnz DEST12

DEST11: mov bx, offset statbul1             ;select the bullet, then destroy it
        mov [bx], 0
        jmp DEST1G

DEST12: mov bx, offset statbul2
        mov [bx], 0
        jmp DEST1G        
                
DEST1G: sub cx, 2
        MOV al, 0
        MOV ah, 0ch
        int 10h
        inc cx
        int 10h
        dec cx
        inc dx
        int 10h
        inc cx
        int 10h
XC:     RET       
                        
movbulr endp

;----------------------------------- move bullet type1 in left direction -----------------------
                                                                                         
movbull proc 
    
        mov bx, offset bulselect            ;get the selected bullet to be moved
        cmp [bx], 1
        jz BULL1
        jnz BULL2

BULL1:  MOV BL, statbul1                    ;case bullet 1 is selected
        CMP BL, 0H                          ;load bullet 1 position, if it exists
        JZ XCC
        mov di, offset bulletrw1
        mov dx, [di]
        
        mov di, offset bulletcl1
        mov cx, [di]
        
        jmp MOVEONN
        
BULL2:  MOV BL, statbul2                    ;case bullet 2 is selected
        CMP BL, 0H                          ;load bullet 2 position, if it exists
        JZ XCC
        mov di, offset bulletrw2
        mov dx, [di]
        
        mov di, offset bulletcl2
        mov cx, [di]
        
        jmp MOVEONN    
        
MOVEONN:mov bx, offset bulselect            ;compare the adjacent pixel to the bullet to decide the next step
        sub cx, 1
        mov ah, 0dh
        int 10h
        
        cmp cx, 16D                         ;check if the bullet exceeds the player position
        jbe DEST2   
        
        cmp cx, 307D
        jae DEST2
        
        cmp al, 2                           ;check if the adjacent pixel is green, then the bullet bounces
        jz BNC
        
        cmp al, 4                           ;check if the adjacent pixel is red, then decrease first player's health
        jz DCH1
        
        cmp al, 1                           ;check if the adjacent pixel is blue, then decrease second player's health
        jz DCH2
        
        INC DX                              ;repeat the same checks on the pixel below
        mov ah, 0dh
        int 10h
        DEC DX
        
        cmp al, 2
        jz BNC
        
        cmp al, 4
        jz DCH1
        
        cmp al, 1
        jz DCH2
                                  
        jmp DCNT                             ;if none of the above is correct, the bullet moves normally                
                 
BNC:    cmp [bx], 1                         ;Bounce checks for the selected bullet and then check whether
        jz BNC11                            ;the pixel on the other sides is also green, then the bullet gets destroyed
        jnz BNC22                           ;if not, then it calls move right
        
BNC11:  add cx, 3h
        MOV ah, 0dh
        int 10h
        cmp al, 2
        jz DEST2
        inc dx
        MOV ah, 0dh
        int 10h
        cmp al, 2
        jz DEST2
        mov bx, offset dirbul1
        mov [bx], 0         
        call movbulr                 
        RET 

BNC22:  add cx, 3h
        MOV ah, 0dh
        int 10h
        cmp al, 2
        jz DEST2
        inc dx
        MOV ah, 0dh
        int 10h
        cmp al, 2
        jz DEST2
        mov bx, offset dirbul2
        mov [bx], 0         
        call movbulr                 
        RET                 
        
DCH1:   cmp [bx], 1                         ;check the selected bullet and decreases the first player health
        jz DCH11                            ;then destroy the bullet
        jnz DCH12
        
DCH11:  mov bx, offset statbul1
        mov [bx], 0
        jmp DCH1G
        
DCH12:  mov bx, offset statbul2
        mov [bx], 0 
        jmp DCH1G
                        
DCH1G:                                      ;destroy the bullet by drawing it black and set the state variable to 0
        ADD CX,1H
        MOV AL,0H
        MOV AH,0CH
        INT 10H
        INC CX
        INT 10H
        DEC CX
        INC DX
        INT 10H
        INC CX
        INT 10H
        CALL dechth1
        RET        
                
DCH2:   CMP [BX],1H                         ;check the selected bullet and decreases the second player health
        JZ  DCH21                           ;then destroy the bullet
        JNZ DCH22
        
DCH21:  
        MOV BX,OFFSET statbul1
        MOV [BX],0H
        JMP DCH2G
        
DCH22: 
        MOV BX,OFFSET statbul2
        MOV [BX],0H 
        JMP DCH2G
                                            ;destroy the bullet by drawing it black and set the state variable to 0
DCH2G:
        ADD CX,1H
        MOV AL,0H
        MOV AH,0CH
        INT 10H
        INC CX
        INT 10H
        DEC CX
        INC DX
        INT 10H
        INC CX
        INT 10H
        CALL dechth2
        RET
          
DCNT:                                       ;move bullet normally
        ADD CX,1H                    
        MOV BL, 8H
        CALL DRWBULL          
        RET

DEST2:                                      ;select the bullet, then destroy it
        CMP [BX],1H
        JZ  DEST21
        JNZ DEST22

DEST21:
        MOV BX,OFFSET statbul1
        MOV [BX],0H
        JMP DEST2G

DEST22: 
        MOV BX,OFFSET statbul2
        MOV [BX],0H
        JMP DEST2G        
                
DEST2G: 
        ADD CX,1H
        MOV AL,0H
        MOV AH,0CH
        INT 10H
        INC CX
        INT 10H
        DEC CX
        INC DX
        INT 10H
        INC CX
        INT 10H            
XCC:    RET
        
MOVBULL ENDP

;----------------------------------- move bullet type2 in right direction -----------------------
                                                                                         
MOVBLTR proc 
    
        MOV BL, statbul1                    ;case bullet 1 is selected
        CMP BL, 0H                          ;load bullet 1 position, if it exists
        JZ XXXCC
        mov di, offset bulletrw1
        mov dx, [di]
        
        mov di, offset bulletcl1
        mov cx, [di]
        
        add cx, 2
        mov ah, 0dh
        int 10h
        
        cmp cx, 307D
        jae DSR21
        
        cmp cx, 16D                         ;check if the bullet exceeds the player position
        jbe DSR21   
        
        cmp al, 2                           ;check if the adjacent pixel is green, then the bullet pauses the barrier
        jz PUSS
        
        cmp al, 4                           ;check if the adjacent pixel is red, then decrease first player's health
        jz DC21
        
        cmp al, 1                           ;check if the adjacent pixel is blue, then decrease second player's health
        jz DC22
        
        INC DX                              ;repeat the same checks on the pixel below
        mov ah, 0dh
        int 10h
        DEC DX
        
        cmp al, 2
        jz PUSS
        
        cmp al, 4
        jz DC21
        
        cmp al, 1
        jz DC22
                                 
        jmp DCRTT                            ;if none of the above is correct, the bullet moves normally                
                 
PUSS:   sub cx, 3h
        MOV ah, 0dh
        int 10h 
        add cx, 3h
        cmp al, 2
        jz DSR21
        sub cx, 3h
        inc dx
        MOV ah, 0dh
        int 10h 
        add cx, 3h
        dec dx
        cmp al, 2
        jz DSR21
        mov bx, offset BARRPAUSE
        cmp [bx], 0
        JNZ DSR21
        MOV [bx], 15D                                  
        JMP DSR21
        RET
        
DC21:   mov bx, offset statbul1
        mov [bx], 0
        sub cx, 2                           ;destroy the bullet by drawing it black and set the state variable to 0
        MOV al, 0
        MOV ah, 0ch
        int 10h
        inc cx
        int 10h
        dec cx
        inc dx
        int 10h
        inc cx
        int 10h
        call dechth1
        call dechth1
        RET        
        
DC22: 
        MOV BX,OFFSET statbul1
        MOV [BX],0H
        sub cx, 2                           ;destroy the bullet by drawing it black and set the state variable to 0
        MOV al, 0
        MOV ah, 0ch
        int 10h
        inc cx
        int 10h
        dec cx
        inc dx
        int 10h
        inc cx
        int 10h
        call dechth2
        call dechth2
        RET
          
DCRTT:                                      ;move bullet normally
        SUB CX,2H 
        MOV BL, 13
        CALL DRWBULR          
        RET

DSR21:  MOV BX,OFFSET statbul1
        MOV [BX],0H    
        sub cx,2h
        MOV AL,0H
        MOV AH,0CH
        INT 10H
        INC CX
        INT 10H
        DEC CX
        INC DX
        INT 10H
        INC CX
        INT 10H            
XXXCC:  RET
        
MOVBLTR ENDP

;----------------------------------- move bullet type2 in left direction -----------------------
                                                                                         
MOVBLTL proc 
        
        MOV BL, statbul2                    ;case bullet 2 is selected
        CMP BL, 0H                          ;load bullet 2 position, if it exists
        JZ XXCC
        mov di, offset bulletrw2
        mov dx, [di]
        
        mov di, offset bulletcl2
        mov cx, [di]

        
        Mov bx, offset bulselect            ;compare the adjacent pixel to the bullet to decide the next step
        sub cx, 1
        mov ah, 0dh
        int 10h
        
        cmp cx, 16D                         ;check if the bullet exceeds the player position
        jbe DESR2   
        
        cmp cx, 307D
        jae DESR2
        
        cmp al, 2                           ;check if the adjacent pixel is green, then the bullet pauses the barrier
        jz PUS
        
        cmp al, 4                           ;check if the adjacent pixel is red, then decrease first player's health
        jz ECH21
        
        cmp al, 1                           ;check if the adjacent pixel is blue, then decrease second player's health
        jz ECH22
        
        INC DX                              ;repeat the same checks on the pixel below
        mov ah, 0dh
        int 10h
        DEC DX
        
        cmp al, 2
        jz PUS
        
        cmp al, 4
        jz ECH21
        
        cmp al, 1
        jz ECH22
        
                         
        jmp DCNTT                             ;if none of the above is correct, the bullet moves normally                
                 
PUS:    add cx, 3h
        MOV ah, 0dh
        int 10h 
        sub cx, 3h
        cmp al, 2
        jz DESR2 
        add cx, 3h
        inc dx
        MOV ah, 0dh
        int 10h
        sub cx, 3h
        dec dx
        cmp al, 2
        jz DESR2
        mov bx, offset BARRPAUSE
        cmp [bx], 0
        JNZ DESR2
        MOV [bx], 15D                                  
        JMP DESR2
        RET                                   
        
ECH21:  mov bx, offset statbul2
        mov [bx], 0 
        ADD CX,1H
        MOV AL,0H
        MOV AH,0CH
        INT 10H
        INC CX
        INT 10H
        DEC CX
        INC DX
        INT 10H
        INC CX
        INT 10H
        CALL dechth1
        CALL dechth1
        RET        
                
ECH22:  MOV BX,OFFSET statbul2
        MOV [BX],0H 
        ADD CX,1H
        MOV AL,0H
        MOV AH,0CH
        INT 10H
        INC CX
        INT 10H
        DEC CX
        INC DX
        INT 10H
        INC CX
        INT 10H
        CALL dechth2
        CALL dechth2
        RET
          
DCNTT:                                      ;move bullet normally
        ADD CX,1H 
        MOV BL, 13
        CALL DRWBULL          
        RET

DESR2:  MOV BX,OFFSET statbul2
        MOV [BX],0H
        ADD CX,1H
        MOV AL,0H
        MOV AH,0CH
        INT 10H
        INC CX
        INT 10H
        DEC CX
        INC DX
        INT 10H
        INC CX
        INT 10H 
                   
XXCC:   RET
        
MOVBLTL ENDP

;----------------------------------- Drawing the right bullet ----------------------------
                                                                                         
DRWBULR PROC
          
        INC CX                              ;change the bullet position variable
        MOV [DI],CX
        
        DEC CX                              ;draw black over the old position
        MOV AL,0H
        MOV AH,0CH
        INT 10H
        INC CX
        INT 10H
        DEC CX
        INC DX
        INT 10H
        INC CX
        INT 10H
        
        DEC DX                              ;draw the bullet in the new position (dark grey)
        MOV AL,BL
        INT 10H
        INC CX
        INT 10H
        DEC CX
        INC DX
        INT 10H
        INC CX
        INT 10H
               
        RET
DRWBULR ENDP

;----------------------------------- drawing the left bullet -----------------------------
                                                                                         
DRWBULL PROC  
        
        DEC CX                              ;change the bullet position variable
        MOV [DI],CX
        
        INC CX                              ;draw black over the old position
        MOV AL,0H
        MOV AH,0CH
        INT 10H
        INC CX
        INT 10H
        DEC CX
        INC DX
        INT 10H
        INC CX
        INT 10H
        
        DEC DX                              ;draw the bullet in the new position (dark grey)
        SUB CX,2H
        MOV AL,BL
        INT 10H
        INC CX
        INT 10H
        DEC CX
        INC DX
        INT 10H
        INC CX
        INT 10H
                
        RET
DRWBULL ENDP   
 
;----------------------------------- movement of the barrier -----------------------------
                                                                                         
MoveBarrier   proc
          
          MOV DI,OFFSET BARRIERY 
          MOV BX,OFFSET BARRCASE            ;get the barrier case 
          CMP [Bx],0H                       ;check the barrier case (up or down)
          JNZ UP        
          MOV AH,0CH                        ;drawing command
          MOV AL,0H                         ;color: black
          CALL drawBarrier                  ;first remove the barrier 
          ADD [DI],2H          
          MOV AL,2H                         ;color: green   
          MOV AH,0CH                        ;drawing command
          call drawBarrier                  ;draw the barrier after updating its dimensions 
          CMP [DI],5BH
          jb  ESC0  
          MOV [BX],1H    
          JMP ESC0
          
     UP:
          MOV AH,0CH                        ;if the barrier was up 
          MOV AL,0H                         ;same as the previous technique but sub the dimensions
          CALL drawBarrier                    ;to go up 
          SUB [DI],2H          
          MOV AL,2H
          MOV AH,0CH
          CALL drawBarrier  
          CMP [DI],1Ah
          JA  ESC0
          MOV [BX],0H
                
   ESC0:  RET  
   
MoveBarrier   ENDP 

;----------------------------------- drawing the barrier ---------------------------------
                                                                                         
drawBarrier   proc 
          MOV DI, OFFSET BARRIERX           ;get the X value of the barrier top
          MOV CX, [DI]
          MOV DI, OFFSET BARRIERY
          MOV DX, [DI]                      ;get the Y value of the barrier top
          mov si,0H 
          mov ah, 0ch
    again:                                  ;draw the barrier 
          int 10h                             ;barrier consists of 12 verticle lines
          dec cx                              ;its lengh = 25H
          int 10h
          dec cx 
          int 10h
          dec cx
          int 10h 
          dec cx 
          int 10h  
          dec cx
          int 10h
          dec cx
          int 10h
          dec cx
          int 10h
          add cx,8h
          int 10h
          inc cx
          int 10h 
          inc cx
          int 10h
          inc cx
          int 10h
          inc cx 
          int 10h
          sub cx,5h
          inc dx    
          inc si
          cmp si,25h
          jnz again  
              
          RET
drawBarrier   endp   

;----------------------------------- gaming inline chat ----------------------------------
                                                                                         
inChat    proc
          
          MOV BH,0H
          MOV AH,2H                           ;DL:X , DH:Y
          MOV DH,13H 
          MOV DL,USERNAME2 +1
          INC DL              
          INT 10H        
         
          CALL CLEARL
          
          MOV BH,0h
          MOV AH,2H                           ;DL:X , DH:Y
          MOV DH,11H 
          MOV DL,USERNAME1 +1
          INC DL              
          INT 10H        
         
          CALL CLEARL
        

    ;------------ POSITION INTIALIZATION -------------- 
        
          MOV DL,USERNAME1+1
          INC DL
          MOV P1XW,DL 
          MOV P1YW,11H
          
          MOV DL,USERNAME2 +1
          INC DL
          MOV P2XW,DL        
          MOV P2YW,13H
        
        ;--------------------------------------------------
              
          MOV DX,3FBH                   ; Line Control Register?
          MOV AL,10000000B	          ;Set Divisor Latch Access Bit
          OUT DX,AL
        
          MOV DX,3F8H
          MOV AL,0CH
          OUT DX,AL
        
          MOV DX,3F9H
          MOV AL,00H
          OUT DX,AL
        
          MOV DX,3FBH
          MOV AL,00011011B
          OUT DX,AL
        
P1WRITING:

          MOV AH,1H
          INT 16H
          JZ P2WRITING   

          CMP AH,3FH                       ;f5
          JZ  BKLEV
          
          CMP AH,3EH
          JZ  TM
 
          MOV AH,2H
          MOV BH,0H                          
          MOV DH,P1YW                         ;DL:X , DH:Y
          MOV DL,P1XW             
          INT 10H
                            
          CMP NEWL,0H
          JZ CONTL 
          
          CMP AL, 08H
          JZ CONTL
        
        
          MOV AH,2H                           ;DL:X , DH:Y
          MOV DH,11H 
          MOV DL,USERNAME1 +1
          INC DL              
          INT 10H        
         
          CALL CLEARL
        
          MOV AH,2H                           ;DL:X , DH:Y
          MOV DH,11H 
          MOV DL,USERNAME1 +1
          INC DL 
          MOV P1XW,DL             
          INT 10H 
                
 CONTL: 
          MOV NEWL,0H      
          MOV AH,0H
          INT 16H
          MOV P1VW,AL    
          
          CMP AH,0FH
          JZ  P2WRITING 
          
          CMP P1VW,8H
          JB  P2WRITING  
          
          CMP P1VW,7DH
          JA  P2WRITING     
          
          CMP P1VW,9H
          JZ  P2WRITING  
          
          MOV DX,3FDH  
        
 READY: 
          IN AL,DX
          AND AL,00100000B
          JZ READY
        
             
          MOV DX,3F8H
          MOV AL,P1VW
          OUT DX,AL
          
                    
          CMP P1VW,8H                      ;CHECK THE BACK_SPACE
          JNZ CKENTR                       ; ---- CHECK ENTER KEYS ----
          MOV BL,USERNAME1 + 1
          INC BL
          CMP P1XW,BL                      ;START POSITION TO WRITE NOT 0H
          JZ P2WRITING
          DEC P1XW 
          MOV AH,2H 
          MOV DH,P1YW
          MOV DL,P1XW
          INT 10H
          MOV AH,2H
          MOV DL, SPACE
          INT 21H
        
          MOV AH,2H
          MOV DL,P1XW
          MOV DH,P1YW
          INT 10H
        
          JMP REST
        
 CKENTR: 
          CMP P1VW,0DH
          JNZ ORDN                            ;--- CHECK THIS ---      
         
          MOV AH,2H                           ;DL:X , DH:Y
          MOV DH,11H 
          MOV DL,USERNAME1 +1
          INC DL              
          INT 10H        
         
          CALL CLEARL
        
          MOV AH,2H                           ;DL:X , DH:Y
          MOV DH,11H 
          MOV DL,USERNAME1 +1
          INC DL 
          MOV P1XW,DL             
          INT 10H
 
          JMP P2WRITING 
     
   ORDN:
          MOV AH,2H
          MOV DL,P1VW
          INT 21H     
        
   REST:
   
          MOV AH,3H
          MOV BH,0H
          INT 10H
          MOV P1XW,DL
          
          CMP P1XW,27H              ;change this value to the max number of chars. can be written in gfx mode 
          JNZ P2WRITING
          MOV NEWL,1H                
 
          JMP P1WRITING            
                  
        
        
P2WRITING:
        
          MOV DX,3FDH
          IN AL,DX 
          AND AL,1H
          JZ P1WRITING
        
          MOV DX,03F8H
          IN AL,DX
          MOV P2VW , AL 
          
          
          CMP AL ,0E4H
          JZ  FN
          
          CMP AL, 3EH
          JZ  FN1
          
                
          CMP NEWW,0H
          JZ ACTW 
        
          CMP AL,08H
          JZ ACTW
        
          MOV AH,2H                           ;DL:X , DH:Y
          MOV DH,13H 
          MOV DL,USERNAME2 +1
          INC DL              
          INT 10H        
         
          CALL CLEARL
        
          MOV AH,2H                           ;DL:X , DH:Y
          MOV DH,13H 
          MOV DL,USERNAME2 +1
          INC DL 
          MOV P2XW,DL             
          INT 10H
        
 ACTW:  
          MOV NEWW,0H                
          MOV AH,2H
          MOV BH,0H 
          MOV DH,P2YW 
          MOV DL,P2XW
          INT 10H
          
          CMP P2VW,9H
          JZ  P1WRITING
          CMP P2VW,08H
          JB  P1WRITING
          CMP P2VW,7DH
          JA  P1WRITING
        
          CMP P2VW,8H
          JNZ CHENTER2                        ;--- CHECK ENTER ---
          MOV BL,USERNAME2 + 1
          INC BL
          CMP P2XW,BL                         ;change this value to the intial value 
          JZ  P1WRITING 
        
          DEC P2XW
          MOV DL,P2XW
          MOV DH,P2YW
          MOV AH,2H
          MOV BH,0H
          INT 10H
          MOV AH,2H
          MOV DL, SPACE
          INT 21H
        
          MOV DL,P2XW
          MOV DH,P2YW
          MOV AH,2H
          MOV BH,0H
          INT 10H
          JMP REST2
        
 CHENTER2:     
        
          CMP P2VW,0DH
          JNZ ORDN2 
          MOV AH,2H                           ;DL:X , DH:Y
          MOV DH,13H  
          MOV BH,0H
          MOV DL,USERNAME2 +1
          INC DL              
          INT 10H        
         
          CALL CLEARL
        
          MOV AH,2H                           ;DL:X , DH:Y
          MOV DH,13H
          MOV BH,0H 
          MOV DL,USERNAME2 +1
          INC DL 
          MOV P2XW,DL             
          INT 10H
 
          JMP P1WRITING                      ;RESET THE INTIAL POSITION OF WRITTING
        
  ORDN2:
          MOV AH,2H
          MOV DL,P2VW
          INT 21H
   
  REST2: 
  
          MOV AH,3H
          MOV BH,0H
          INT 10H 

          MOV P2XW,DL
        
          CMP P2XW,27H        
          JNZ P1WRITING
        
          MOV NEWW,1H
 
          JMP P2WRITING

BKLEV:    MOV AH,0H
          INT 16H 
 READY3: 
          IN AL,DX
          AND AL,00100000B
          JZ READY3
           
          MOV DX,3F8H
          MOV AL,0E4H
          OUT DX,AL
          
          RET 
                      
TM:       
          MOV AH,0H
          INT 16H 
          
 READY4: 
          IN AL,DX
          AND AL,00100000B
          JZ READY4
           
          MOV DX,3F8H
          MOV AL,3EH
          OUT DX,AL     
          
FN1:      DELAY 15H , 11H
          JMP MENUM
                
FN:        RET
inChat    endp
               
;-------------------------------- drawing the left player --------------------------------
                                                                                         
PERSON  PROC
        
        
        CMP Y1,25D                          ;first check the X,Y value of the player to be bounded by specific values
        JG TRYA
        MOV BX,24D
        MOV Y1,BX
        JMP GOAHEAD
        
TRYA:   CMP Y1,105D                         
        JNG GOAHEAD
        MOV BX,105D
        MOV Y1,BX
    
GOAHEAD:MOV BX,X1                           ;first set dimensions to draw the head
        ADD BX,4D                           ;BX TO CHECK FOR X
        MOV SI,Y1       
        ADD SI,5D                           ;SI TO CHECK FOR Y
        
        
        MOV DX,Y1
        MOV AH,0CH
        
H2:     MOV CX,X1                           

H1:     INT 10H                             ;drawing the head line by line
        INC CX
        CMP CX,BX
        JNZ H1
        INC DX
        CMP DX,SI
        JNZ H2
        
        PUSH DX                             ;keep the last Y to draw the arms
        
        MOV BX,X1                           ;set the max dimensions of the body
        ADD BX,8D
        ADD SI,10D 
        
B2:     MOV CX,X1                           ;set the intial body dimensions
        SUB CX,4D  
        
B1:     INT 10H                             ;draw the body line by line
        INC CX
        CMP CX,BX
        JNZ B1
        INC DX
        CMP DX,SI
        JNZ B2
        
        PUSH DX                             ;keep the last body dimension to draw the leg
        
        MOV BX,X1                           ;keep the max dimension of the first leg
        ADD SI,10D
        
L2:     MOV CX,X1                           ;set the intial position of the first leg
        SUB CX,4D   
                                            
L1:     INT 10H                             ;draw the first leg line by line
        INC CX
        CMP CX,BX
        JNZ L1
        INC DX
        CMP DX,SI
        JNZ L2
        
        POP DX                              ;get the last y of the body to draw the other leg
                                            
        ADD BX,8D                           ;set the intial dimension of the other leg
        
L4:     MOV CX,X1                           ;keep the max dimension of the leg
        ADD CX,4D 
        
L3:     INT 10H                             ;draw the other leg line by line
        INC CX
        CMP CX,BX
        JNZ L3
        INC DX
        CMP DX,SI
        JNZ L4
        
        POP DX                              ;get the last value of the head to draw the arms
        
        MOV SI,DX
        ADD SI,4H                           ;set the arm dimensions
        
        MOV BX,X1
        ADD BX,16D
        
HAND2:  MOV CX,X1                           ;set the intial dimension for the arm
        ADD CX,8D       
        
HAND:   INT 10H                             ;draw the arm line by line
        INC CX
        CMP CX,BX
        JNZ HAND
        INC DX
        DEC BX
        CMP DX,SI
        JNZ HAND2
        
        MOV DX,Y1                           ;set the Y second arm first part dimensions
        ADD DX,5D
        MOV SI,DX
        ADD SI,5D
        
        MOV DI,X1                           ;keep the x dimension to draw the other part of the arm
        
HAND4:  MOV CX,DI                           ;set the X second arm first part dimensions
        SUB CX,5D
        MOV BX,CX
        ADD BX,5D 
        
HAND3:  INT 10H                             ;draw the first part of the second arm line by line
        INC CX
        CMP CX,BX
        JNZ HAND3
        INC DX
        DEC DI
        CMP DX,SI
        JNZ HAND4
        
        ADD SI,5D
        
        
        MOV BX,DI
        SUB BX,5D
        ADD BX,4
        
HAND6:  MOV CX,DI                           ;set the second part dimensions
        SUB CX,4D   
        
HAND5:  INT 10H                             ;draw the second part of the second arm
        INC CX
        CMP CX,BX
        JNZ HAND5
        INC DX
        CMP DX,SI
        JNZ HAND6
        
        MOV DX,Y1                           ;set the gun dimensions
        ADD DX,3D
        MOV CX,X1
        ADD CX,14D
        MOV BX,CX
        ADD BX,9H
        
G:      INT 10H                             ;draw the gun's first line
        INC CX
        CMP CX,BX
        JNZ G
        
        INC DX
        MOV CX,X1
        ADD CX,13D
        
G1:     INT 10H                             ;draw the gun's second line
        INC CX
        CMP CX,BX
        JNZ G1
        
        
        
        RET
    
PERSON  ENDP 

;----------------------------------- drawing the right player ----------------------------
                                                                                         
PERSON1 PROC
    
        
        CMP Y2,25D                          ;first check the X,Y value of the player to be bounded by specific values
        JG  TRYA1
        MOV BX,24D
        MOV Y2,BX
        JMP GOAHEAD1
        
TRYA1:  CMP Y2,105D                       
        JNG GOAHEAD1
        MOV BX,105D
        MOV Y2,BX 
    
GOAHEAD1:                                   ;first set dimensions to draw the head 
        MOV BX,X2                           ;BX TO CHECK FOR X
        SUB BX,4D
        MOV SI,Y2                           ;SI TO CHECK FOR Y
        ADD SI,5D
        
        
        MOV DX,Y2                           ; Y value
        MOV AH,0CH                          ;drawing command
        
H21:    MOV CX,X2                           ;drawing the head line by line 
H11:    INT 10H                  
        DEC CX
        CMP CX,BX
        JNZ H11
        INC DX
        CMP DX,SI
        JNZ H21
        
        PUSH DX                             ;keep the last Y of the head to draw the arms
        
        MOV BX,X2                           ;set the max dimensions of the body                           
        SUB BX,8D
        ADD SI,10D  
         
      
B21:    MOV CX,X2                           ;set the intial body dimensions
        ADD CX,4D    
        
B11:    INT 10H                             ;draw the body line by line                   
        DEC CX
        CMP CX,BX
        JNZ B11
        INC DX
        CMP DX,SI
        JNZ B21
        
        PUSH DX                             ;keep the last body dimension to draw the leg            
      
        MOV BX,X2                           ;keep the max dimension of the first leg
        ADD SI,10D
        
L21:    MOV CX,X2                           ;set the intial position of the first leg
        ADD CX,4D  
        
L11:    INT 10H                             ;draw the first leg line by line
        DEC CX
        CMP CX,BX
        JNZ L11 
        INC DX
        CMP DX,SI
        JNZ L21
        
        POP DX                              ;get the last y of the body to draw the other leg
        
        SUB BX,8D                           ;set the intial dimension of the other leg 
        
L41:    MOV CX,X2                           ;keep the max dimension of the leg 
        SUB CX,4D                           
                                            
L31:    INT 10H                             ;draw the other leg line by line
        DEC CX
        CMP CX,BX
        JNZ L31
        INC DX
        CMP DX,SI
        JNZ L41
        
        POP DX                              ;get the last value of the head to draw the arms
        
                                            
        MOV SI,DX                           ;set the first arm Y dimension
        ADD SI,4H
                                            ;keep the max X arm dimension
        MOV BX,X2                           
        SUB BX,16D
        
HAND21: MOV CX,X2                           ;set the intial dimension for the arm
        SUB CX,8D    
        
HAND1:  INT 10H                             ;draw the arm line by line
        DEC CX
        CMP CX,BX
        JNZ HAND1
        INC DX
        INC BX
        CMP DX,SI
        JNZ HAND21
        
        MOV DX,Y2
        ADD DX,5D                           ;set the Y second arm first part dimensions
        MOV SI,DX
        ADD SI,5D
        
        MOV DI,X2                           ;keep the x dimension to draw the other part of the arm 
        
HAND41: MOV CX,DI                           ;set the X second arm first part dimensions
        ADD CX,5D
        MOV BX,CX
        SUB BX,5D 
        
HAND31: INT 10H                             ;draw the first part of the second arm line by line
        DEC CX
        CMP CX,BX
        JNZ HAND31
        INC DX
        INC DI
        CMP DX,SI
        JNZ HAND41
        
        ADD SI,5D
        
        
        MOV BX,DI
        ADD BX,5D
        SUB BX,4H
        
HAND61: MOV CX,DI                           ;set the second part dimensions
        ADD CX,4D 
        
HAND51: INT 10H                             ;draw the second part of the second arm 
        DEC CX
        CMP CX,BX
        JNZ HAND51
        INC DX
        CMP DX,SI
        JNZ HAND61
        
        MOV DX,Y2                           ;set the gun dimensions
        ADD DX,3D
        MOV CX,X2
        SUB CX,14D
        MOV BX,CX
        SUB BX,9H
        
G111:   INT 10H                             ;draw the gun's first line
        DEC CX
        CMP CX,BX
        JNZ G111
        
        INC DX
        MOV CX,X2
        SUB CX,13D
        
G11:    INT 10H                             ;draw the gun's second line
        DEC CX
        CMP CX,BX
        JNZ G11
        
        RET
        
PERSON1 ENDP    
               
;--------------------- the starting menu to get the players' names -----------------------
                                                                                         
MENU    PROC                                                                                                     
                           
          
N:      MOV AH,0H                           
        MOV AL,3H                            
        INT 10H                             ;ENTER THE TEXT MODE 
        
        
;-- get the first player name --
    
   
   
        MOV DX,0A19H                        ;CHANGE THE CURSOR POSITION 
        MOV AH,2H     
        INT 10H              
     
        MOV DX,OFFSET MES1                  ;asking the first user for his/her name
        MOV AH,9H
        INT 21h 
      
        MOV DX,0C1EH
        MOV AH,2H                           ;change the cursor position and read the name
        INT 10H
        
        MOV DX,OFFSET USERNAME1             ;get the user name
        MOV AH,0AH                          ;HAS DX AS PARAMATER (OFFSET)
        INT 21H
        
      
     
        MOV DI,OFFSET USERNAME1 + 2         ;check the validity of the name
        CMP [DI], 41H                       ;first check if the first char is letter 
        JB CRR
        CMP [DI], 7AH
        JA CRR
        CMP [DI], 5AH
        JA SW
        JMP CT
SW:     CMP [DI], 61H
        JB CRR
        JMP CT     

CRR:    MOV CX, 17D                         ;if the first char was not letter clear the name and repeat the previous process
        MOV DI,OFFSET USERNAME1 + 2
LP:     MOV [DI], '$'
        INC DI
        LOOP LP
        JMP N  

CT:     MOV DI,OFFSET USERNAME1 + 2         ;check if the user name 15 char max, if not clear the name and repeat the previous process 
        ADD DI, 16D
        CMP [DI], '$'
        JNZ CRR      
        
        MOV DX,0E19H                        ;CHANGE THE CURSOR POSITION DX(Y,X)
        MOV AH,2H     
        INT 10H           
    
        MOV DX,OFFSET MES2                  ;waiting the user to confirm his/her name and start the game 
        MOV AH,9H
        INT 21H     
        
                                            ;check if the player pressed enter 
        
 ENTERT:
        MOV AH,0H
        INT 16H        
        CMP AH,1CH                          ;the scancode of the enter click   
        JNZ ENTERT
        
 CLBUF:
        
        MOV AH,1H
        INT 16H 
        JZ CSER
        MOV AH,0H
        INT 16H
        JMP CLBUF               
;-- get the second player name --

CSER:
                                     
        CALL SERIALCONFIG
                                     
                
      ;FIRST WE SEND  THE SIZE FOR  EACH USER TO THE OTHER 
                    
CH_SEND_S: 

        mov dx , 3FDH	                    ;Line Status Register?
        In al , dx                          ;Read Line Status?
        AND al , 00100000b
        JZ CH_SEND_S

                                            ; RECIEVE THE SIZE 
        mov dx , 3F8H	                    ; Transmit data register?
        mov al,USERNAME1 + 1  
        out dx , al
                    
                      
                    
      ;Check that Data Ready?       
      
CH_RECIEVE_S:   

        mov dx , 3FDH	                    ;Line Status Register?
        in al , dx 
        AND al , 1
        JZ CH_RECIEVE_S

      ;If Ready read the VALUE in Receive data register?

        mov dx , 03F8H
        in al , dx 
        mov offset USERNAME2 + 1  , al
                     
;-------------------------------------------------------                   
                  

     ;PUT THE SIZE OF THE FIRST NAME IN BP  
     
        mov di,2   
        MOV BX,0
        MOV BL,USERNAME1+1
        MOV BP,BX
                    
     ;PUT THE SIZE OF THE SECOND NAME IN SI 
     
        MOV BX,0
        MOV BL,USERNAME2+1
        MOV SI,BX
        MOV BX,2
                    
;------ THIS PART TO DISPLAY THE NAME WHICH WE ARE SENDING AND RECIEVING THEM TO CHECK THE CODE ----- 
                        
CH_SEND_NF:

        cmp indicator,BP
        jz CH_RECIEVE_NF
        mov dx , 3FDH	                      ; Line Status Register?
        In  al , dx                            ;Read Line Status?
        AND al , 00100000b
        JZ CH_SEND_NF   
        
    ; send the data if valid 
    
        mov  dx,3F8H	                      ; Transmit data register?
        mov  al,USERNAME1[bx]  
        
    ; test to show the number in the terminal
    
        out dx , al                           
        
        inc bx
        inc indicator 
        
    ;Check that Data Ready?

CH_RECIEVE_NF: 

        CMP INDICATOR1,SI
        JZ HENAF
        mov dx , 3FDH	                     ; Line Status Register?
        in al , dx
        AND al , 1
        JZ CH_RECIEVE_NF
        
    ;If Ready read the VALUE in Receive data register? 
                    
        mov dx , 03F8H                    
        in al , dx 
        mov offset USERNAME2[DI],al
        INC DI
        INC INDICATOR1
                     
HENAF:  CMP INDICATOR,BP
        JNZ CH_SEND_NF
        CMP INDICATOR1,SI
        JNZ CH_SEND_NF
                              
                                  
        RET
MENU    ENDP

;----------------------------------- the main menu of the game ---------------------------
                                                                                         
MMENU   PROC   
        
        MOV AH,0H    
        MOV AL,3H    
        INT 10H                             ;ENTER THE TEXT MODE 
              
     
        MOV BH,0H
        MOV DX,01400H
        MOV AH,2H                           ;CHANGE CURSOR POSITION
        INT 10H   
      
        MOV AH,9H                           ;DRAW THE STATUS BAR LINE FROM A CERTAIN POSITION
        MOV BH,0H
        MOV AL,'='
        MOV CX,80D
        MOV BL,00FH
        INT 10H 
     
        MOV BH,0H
        MOV DX,919H   
        MOV AH,2H    
        INT 10H                 
                  
       
        MOV DX,OFFSET press1                ;press F1 to start the chat
        MOV AH,9H
        INT 21H      
      
        MOV BH,0H
        MOV DX,0B19H
        MOV AH,2H    
        INT 10H

        MOV DX,OFFSET press2                ;press F2 to start the game
        MOV AH,9H
        INT 21H 
        
        MOV BH,0H
        MOV DX,0D19H
        MOV AH,2H    
        INT 10H     
         
        MOV DX,OFFSET press3                ;press esc to close the game
        MOV AH,9H
        INT 21H    
    
        RET
MMENU   ENDP                                                                                             
        
;---------------------- set the left player bullet intial position -----------------------        
                                                                                         
FIRE1   PROC
    
    ;set the position of the bullet at the end of the gun for the left player
    
        
        MOV BX,X1
        ADD BX,23D    
        MOV BULLETCL1,BX                    ;set the X of the bullet to the X of the left player gun
         
        MOV BX,Y1
        ADD BX,03H     
        MOV BULLETRW1,BX                    ;set the Y of the bullet to the Y of the left player gun
        MOV BX,1H
        MOV STATBUL1,BL                     ;set the state of the bullet to 1 (exists)
        MOV BX,0H
        MOV DIRBUL1, BL                     ;set the direction to 0 ( right )
        
        RET
FIRE1   ENDP

;---------------------- set the right player bullet intial position ----------------------        

FIRE2   PROC
    
    ;set the position of the bullet at the end of the gun for the right player
    

        MOV BX,X2
        SUB BX,23D                          ;set the X of the bullet to X of the right player gun 
        MOV BULLETCL2,BX  
        
        MOV BX,Y2
        ADD BX,03H                          
        MOV BULLETRW2,BX                    ;set the Y of the bullet to Y of the right player gun
        
        MOV BX,1H                           ;set the state of the bullet to 1 (exists)
        MOV STATBUL2,BL
        MOV BX,1H
        MOV DIRBUL2, BL                     ;set the direction to 1 ( left )
        
        RET
FIRE2   ENDP

;-------------------- reset the intial values for the used variables --------------------- 
                                                                                         
SETV    PROC
    
        MOV BX,4H                           ;intialize the health of both players by 4
        MOV P1HEALTH,BL
        MOV P2HEALTH,BL
    
        MOV BX, 0H                          ;set the bullet state & left bullet direction to 0
        MOV statbul1,BL
        MOV dirbul1,BL
        MOV statbul2,BL
        MOV BARRCASE ,BL                    ;set the barrier case to 0 (moving down) 
        MOV BARRPAUSE,BL
        MOV TYPEBUL1,BL
        MOV TYPEBUL2,BL
        
        
        MOV BX,1H                           ;set the right bullet direction to 1
        MOV dirbul2,BL                      ;intialize the bullet select to 1
        MOV bulselect,BL
        
        MOV BX, 0A0H                        ;set the intial position of the barrier
        MOV BARRIERX,BX
        MOV BX,1AH
        MOV BARRIERY,BX
        
        MOV BX,16D                          ;set the intial position of the left player
        MOV X1,BX
        MOV BX,66D 
        MOV Y1,BX
        
        MOV BX,307D                         ;set the intial position of the right player
        MOV X2,BX
        MOV BX,66D
        MOV Y2,BX
        
    
        RET 
SETV    ENDP  

;------------------------ check the health of the two players ----------------------------
                                                                                         
                                                                                         
CHEALTH PROC
        
        CMP P1HEALTH,0H                     ;check the health of the left player 
        JNZ TE2                             ;if still alive check the other player
        
        CMP P2HEALTH,0H                     ;check the health of the right player
        JZ GOV                              ;if both dead print game over 
     
    ;if only the first player dead 
     
        MOV DX,1700H                        ;first clear the status bar by drawing spaces in it
        MOV BH,0H
        MOV AH,2H
        INT 10H  
        
        MOV CX,45H                          ;interrupt used to clear the status bar 
        MOV AH,9H                           ;drawing 45 space on the status bar
        MOV BH,0H
        MOV AL,20H 
        MOV BL,0H
        INT 10H
    
    ;writing the winning message 
                                            
        MOV BH,0H 
        MOV AH,3H
        INT 10H  
           
        MOV AH,2H
        MOV BH,0H 
        MOV DX,1700H                        ;set the cursor position at the beginnig of the status bar
        INT 10H   
        
        MOV DX,OFFSET USERNAME2 + 2         ;print the right player name (the alive player)
        MOV AH,9H
        INT 21H
        
        MOV BH,0H
        MOV AH,3H
        INT 10H
        
        MOV AH,USERNAME2 + 1                ;set the position of the next word ( wins )
        ADD DL,AH
        INC DL
        MOV AH,2H
        INT 10H
                
        MOV DX,OFFSET PWIN                  ;print wins
        MOV AH,9H
        INT 21H
        
        MOV BH,0H
        MOV AH,3H
        INT 10H
        
        ADD DL,5H
        MOV AH,3H
        INT 10H
        
        MOV DX,OFFSET USERNAME1 + 2         ;print the left player name (loser player)
        MOV AH,9H
        INT 21H
        
        MOV BH,0H
        MOV AH,3H
        INT 10H
        
        MOV AH,USERNAME1 + 1   
        ADD AH,USERNAME2 + 1
        ADD DL,AH
        ADD DL,8H
        MOV AH,2H                           ; set the cursor position to write lost 
        INT 10H
        
        
        MOV DX,OFFSET PLOS                  ;print that he lost 
        MOV AH,9H
        INT 21H         
 
        JMP EG                              ;back to the main menu to choose action in the game ( playing or chat )
        
   TE2:    
        CMP P2HEALTH,0H                     ;check if the right player dead (the left still alive)
        JNZ FL
        
        MOV DX,1700H                        ;if dead clear the status bar by the same previous technique
        MOV BH,0H
        MOV AH,2H
        INT 10H  
        
        MOV CX,45H
        MOV AH,9H
        MOV BH,0H
        MOV AL,20H 
        MOV BL,0H
        INT 10H

        MOV BH,0H
        MOV AH,3H
        INT 10H
                 
        MOV AH,2H
        MOV BH,0H 
        MOV DX,1700H 
        INT 10H 
        
        MOV DX,OFFSET USERNAME1 + 2         ;print the left player name ( the winner)
        MOV AH,9H
        INT 21h
        
        MOV BH,0H
        MOV AH,3H
        INT 10H
        
        MOV AH,USERNAME1 + 1
        ADD DL,AH
        INC DL
        MOV AH,2H
        INT 10H                             ;set the cusror position to write the next word (wins)
               
        MOV DX,OFFSET PWIN                  ;print wins
        MOV AH,9H
        INT 21H
        
        MOV BH,0H
        MOV AH,3H
        INT 10H
        
        ADD DL,5H
        MOV AH,3H                           ;set the cursor position to write the loser name
        INT 10H

        MOV DX,OFFSET USERNAME2 + 2         ;write the right player name ( the loser )
        MOV AH,9H
        INT 21H

        MOV BH,0H
        MOV AH,3H
        INT 10H
        
        MOV AH,USERNAME2 + 1 
        ADD AH,USERNAME1 + 1
        ADD DL,AH
        ADD DL,8H
        MOV AH,2H
        INT 10H                             ;set the cursor position to wrtie lost
                
        MOV DX,OFFSET PLOS                  ;write lost
        MOV AH,9H
        INT 21H  
        
        JMP EG                              ;back to the main menu to choose action in the game ( playing or chat )
                
        
  GOV: 
        MOV DX,1700H                        ;if both dead clear the screen then print game over
        MOV BH,0H
        MOV AH,2H
        INT 10H  
        
        MOV CX,45H                          ;write spaces over the status bar to delete it
        MOV AH,9H
        MOV BH,0H
        MOV AL,20H 
        MOV BL,0H
        INT 10H
        
        MOV BH,0H
        MOV AH,3H
        INT 10H
         
        MOV AH,2H
        MOV BH,0H 
        MOV DX,1700H 
        INT 10H 
        

        MOV DX,OFFSET GAV
        MOV AH,9H
        INT 21H 
        
        JMP EG                              ;back to the main menu to choose action in the game ( playing or chat )
        
   FL:  RET  
   
CHEALTH ENDP

;----------------------------------------- LEVEL #1 ----------------------------------------------------------------

LEVEL1  PROC 
    
        MOV AL, 13H
        MOV AH, 0H
        INT 10H
                                            
        call overlay                        ;Draw the border of the game and the health bars
        
        mov al, 2h        
        call drawBarrier                    ;draw a green barrier 
        MOV AL,4H
        call Person                         ;draw the left player in red
        MOV AL,1H
        call Person1                        ;draw the right player in blue
          
     ;enter the gaming mode  
          
   PL:                                      ;Game Main Loop
        CALL MoveBarrier                    ;first move the barrier 
        DELAY 2H, 1100H                     ;delay for 0.4 second 
                
        CALL CHEALTH                        ;check the health of the players 
                                            ;if anyone health =0 the game ends then back to the main menu

CH_RECIEVE_P2:

        CALL SERIALCONFIG    
                    
        mov dx , 3FDH	; Line Status Register?
        in al , dx
        AND al , 1
        JZ CHK
                    ;If Ready read the VALUE in Receive data register?
        mov dx , 03F8H                    
        in al , dx  
                    
        CMP AL,55H            ;u
        JZ P2UP 
        
        CMP AL,44H
        JZ P2DOWN 
        
        CMP AL,46H
        JZ P2F 
        
        cmp al,65h
        jz CH_RECIEVE_Pause2
        
        cmp al,78h
        jz barabaa 
                     
   CHK:    
        MOV AH, 1H                          ;check if the user pressed a key 
        INT 16H
        JNZ CR                              ;if key pressed (ZF=1) remove it from keyboard buffer then do its action
        
        JMP MOVEBUL                          ;if not we continue the game ( if bullet exists they move the loop again)
                                            
                                            ;key actions used : 
                                                         ;1)up /down arrows, left player movement 
                                                         ;2)left/right arrows, right player movement
                                                         ;3) Q : left player fire
                                                         ;4) W : right player fire
                                                         ;5) F5 : to pause the game for inline chat
                                                         ;5) F4 : end the game and back to the main menu
     ;actions we need
                                                             
     E:                                        
        CMP AH, 10H                         ;player1 fire
        JZ P1F
        
        CMP AH, 48H                         ;up arrow
        JZ P1UP
        
        CMP AH, 50H                         ;down arrow
        JZ P1DOWN

        CMP AH, 3FH                         ;pause (TAB)
        JZ PAUSE        
        
        CMP AH,3EH                          ;end the game
        JZ EG       
        
        JMP MOVEBUL                         ;Non of the above ignore the key and continue playing
  
     
     ;fire of the left player
     
    P1F:   
       
        MOV BL,statbul1
        CMP BL,0H                           ;check the state of the bullet if not exist player can fire
        JNZ MOVEBUL
        CALL FIRE1                          ;left player can fire if he has no bullets in the game  
         CH_SEND_F1: 
                    CALL SERIALCONFIG
                    mov dx , 3FDH	; Line Status Register?
                    In al , dx ;Read Line Status?
                    AND al , 00100000b
                    JZ CH_SEND_F1 
                    ; send the data if valid
                    mov dx , 3F8H	; Transmit data register?
                    mov  al,GOFIRE 
                    ; test to show the number in the terminal
                    out dx , al
        JMP MOVEBUL                         ;then continue the game
     
     
     ;fire of the right player  
     
    P2F:    

        MOV BL, statbul2
        CMP BL, 0H                          ;check the state of the bullet 
        JNZ MOVEBUL
        CALL FIRE2                          ;right player can fire if he has no bullet in the game
        JMP CHK                         ;then continue the game
        
     
     ;left player moving down
        
 P1DOWN: 

        MOV AL, 0H                          ;first remove the existing body
        CALL PERSON                           ;by drawing it black
        MOV BX, Y1
        ADD BX, 2H                          ;increase his Y value by 2 to go down 2 pixels 
        MOV Y1, BX
        MOV AL, 4H                          ;redraw him in red with the updated dimensions
        CALL PERSON                              
        CH_SEND_P2: 
                    CALL SERIALCONFIG
                    mov dx , 3FDH	; Line Status Register?
                    In al , dx ;Read Line Status?
                    AND al , 00100000b
                    JZ CH_SEND_P2 
                    ; send the data if valid
                    mov dx , 3F8H	; Transmit data register?
                    mov  al,GODOWN_P2 
                    ; test to show the number in the terminal
                    out dx , al
        JMP MOVEBUL                         ;continue the game 
     
     ;left player moving up
        
   P1UP:   

        MOV AL, 0H                          ;first remove the existing body
        CALL PERSON                           ;by drawing it black
        MOV BX, Y1
        SUB BX, 2H                          ;decrease his Y value by 2 to go up 2 pixels
        MOV Y1, BX
        MOV AL, 4H
        CALL PERSON                         ;redarw him in red with the updated dimensions 
        CH_SEND_P1: 
                    CALL SERIALCONFIG
                    mov dx , 3FDH	; Line Status Register?
                    In al , dx ;Read Line Status?
                    AND al , 00100000b
                    JZ CH_SEND_P1 
                    ; send the data if valid
                    mov dx , 3F8H	; Transmit data register?
                    mov  al,GOUP_P2 
                    ; test to show the number in the terminal
                    out dx , al
        JMP MOVEBUL                         ;continue the game
        
     
     ;right player moving down ( right arrow )
     
 P2DOWN: 

        MOV AL, 0H                          ;first remove the existing body 
        CALL PERSON1                          ;by drawing it black
        MOV BX, Y2
        ADD BX, 2H                          ;increase his Y value by 2 to go down 2 pixels
        MOV Y2, BX
        MOV AL, 1H
        CALL PERSON1                        ;redraw him in blue with the updated dimensions
        JMP CHK                         ;continue the game
                            
                            
     ;right player moving up ( left arrow )
     
P2UP:   

        MOV AL, 0H                          ;first remove the existing body
        CALL PERSON1                          ;by drawing it black
        MOV BX, Y2
        SUB BX, 2H                          ;decrease his Y value by 2 to go up 2 pixels
        MOV Y2, BX
        MOV AL, 1H
        CALL PERSON1                        ;redraw him in blue with the updated dimensions
        JMP CHK                         ;continue the game
   
        
     ;tab pressed to pause (used for inline chat)
                           
   PAUSE:  
         CH_SEND_Pause: 
                    CALL SERIALCONFIG
                    mov dx , 3FDH	; Line Status Register?
                    In al , dx ;Read Line Status?
                    AND al , 00100000b
                    JZ CH_SEND_Pause 
                    ; send the data if valid
                    mov dx , 3F8H	; Transmit data register?
                    mov  al,pause_tab 
                    ; test to show the number in the terminal
                   out dx , al    
                   
CH_RECIEVE_Pause2:
                     
            CALL INCHAT                                          ;wait the user to enter a key
     ;if bullets exist they move.   bullet strategy :
                                          ;1) if the bullet hit a player his health decreases by 1 ( intial health =4)
                                          ;2) if the bullet hit the barrier it bounce and may hurt its player :)
                                          ;3) if the bullet entred the barrier it destroyed  
MOVEBUL:
     
     ;movement of the left player bullet 
     
        MOV BL, statbul1
        CMP BL, 0H                          ;first check if the bullet exists or not
        JZ GOON                             
        MOV BX, 01H                         ;if exists
        MOV BULSELECT, BL                   ;select the first bullet to be moved
        MOV BL, dirbul1
        CMP BL, 0H                          ;check the direction of the bullet 
        JZ MR1                              ;if NOT 0 (left) ,it bounced 
        CALL MOVBULL                        ;move the bullet by 2 pixels in the left direction
        CALL MOVBULL  
        CALL MOVBULL
        JMP GOON
MR1:    CALL MOVBULR                        ;if 0 (right) 
        CALL MOVBULR                        ;move the bullet by 2 pixels in the right direction 
        CALL MOVBULR
        JMP GOON
     
     ;movement of the right player bullet 
                
GOON:   MOV BL, statbul2
        CMP BL, 0H                          ;first check if the bullet exists or not
        JZ PL                               ;if not exists continue the game
        MOV BX, 02H
        MOV BULSELECT, BL                   ;select the second bullet to be moved
        MOV BL, dirbul2                     ;check the direction of the bullet
        CMP BL, 0H                          ;if NOT 0 (left)
        JZ MR2                              ;move the bullet by 3 pixels in the left direction
        CALL MOVBULL
        CALL MOVBULL
        CALL MOVBULL
        JMP PL
MR2:    CALL MOVBULR                        ;if 0 (right),it bounced 
        CALL MOVBULR                        ;move the bullet by 3 pixels in the right direction
        CALL MOVBULR
        JMP PL                              ;then continue the game     
      
        
     ;get the user key pressed from the keyboard buffer    
      
     CR:     
        MOV BL,AH                           ;save the scancode of the key pressed in BL
        MOV AH,0H
        INT 16H                             ;remove the key from the buffer
        MOV AH,BL                           ;reload the scandcode to the AH again 
        JMP E                               ;jmp to check the pressed value and choose the action needed
         
     ;if any player press F4 the game ends in 5 seconds the back to the main menu    
     EG:  
        CH_SEND_x: 
                    CALL SERIALCONFIG
                    mov dx , 3FDH	; Line Status Register?
                    In al , dx ;Read Line Status?
                    AND al , 00100000b
                    JZ CH_SEND_x
                    ; send the data if valid
                    mov dx , 3F8H	; Transmit data register?
                    mov  al,bara 
                    ; test to show the number in the terminal
                    out dx , al
        barabaa:
        DELAY 4DH, 0H     
        JMP MENUM   
    
        RET
LEVEL1  ENDP                                                                                                        

;-------------------------------------------- LEVEL #2 ------------------------------------------------------------------

LEVEL2  PROC  
    
        MOV AL, 13H
        MOV AH, 0H
        INT 10H
                                            
        call overlay                        ;Draw the border of the game and the health bars
        
        mov al, 2h        
        call drawBarrier                    ;draw a green barrier 
        MOV AL,4H
        call Person                         ;draw the left player in red
        MOV AL,1H
        call Person1                        ;draw the right player in blue
          
     ;enter the gaming mode      
                                            ;Game Main Loop
PL1:    CMP BARRPAUSE,0H
        JZ CONTU
          
        MOV SI,OFFSET BARRPAUSE
        DEC [SI]
        JMP DEL
                                 
CONTU:  CALL MoveBarrier                    ;first move the barrier        
        
DEL:    DELAY 2H, 1100H                     ;delay for 0.01 second 
                
        CALL CHEALTH                        ;check the health of the players 
                                            ;if anyone health =0 the game ends then back to the main menu

CH_RECIEVE_P2_2:
        CALL SERIALCONFIG
        mov dx , 3FDH	; Line Status Register?
        in al , dx
        AND al , 1
        JZ CHK1
    ;If Ready read the VALUE in Receive data register?
        mov dx , 03F8H                    
        in al , dx  
        CMP AL,55H
        JZ P2UPT 
        CMP AL,44H
        JZ P2DOWNT
        CMP AL,46H
        JZ P2FT 
        cmp al,66h
        jz P2F2    
        ;lw received pause yb2a hnot l el inline chat
        cmp al,65h
        jz CH_RECIEVE_Pauset2   
        cmp al,78h
        jz barabaa1 
  
   CHK1:    
        MOV AH, 1H                          ;check if the user pressed a key 
        INT 16H
        JNZ CRL                             ;if key pressed (ZF=1) remove it from keyboard buffer then do its action
        JZ MOVBUL                           ;if not we continue the game ( if bullet exists they move the loop again)
                                            
                                            ;key actions used : 
                                                         ;1)up /down arrows, left player movement 
                                                         ;2)left/right arrows, right player movement
                                                         ;3) Q : left player fire
                                                         ;4) W : right player fire
                                                         ;5) tab : to pause the game for inline chat
                                                         ;5) F4 : end the game and back to the main menu
     ;actions we need
                                                             
     C:                                        
        CMP AH, 10H                         ;player1 fire bullet type 1
        JZ P1FT
     
        CMP AH, 20H                         ;player1 fire bullet type 2
        JZ P1F2
        
        CMP AH, 48H                         ;up arrow
        JZ P1UPT
        
        CMP AH, 50H                         ;down arrow
        JZ P1DOWNT
                
        CMP AH, 3FH                         ;pause (F5)
        JZ PAUSET        
        
        CMP AH,3EH                          ;end the game
        JZ EGG 
        
        JMP MOVBUL                         ;Non of the above ignore the key and continue playing
  
     
     ;fire of the left player bullet type 1
     
    P1FT:   
       
        MOV BL,statbul1
        CMP BL,0H                          ;check the state of the bullet if not exist player can fire
        JNZ MOVBUL   
        MOV SI,OFFSET TYPEBUL1
        MOV [SI],0H
        CALL FIRE1                         ;left player can fire if he has no bullets in the game 
CH_SEND_F1_1: 
        CALL SERIALCONFIG
        mov dx , 3FDH	; Line Status Register?
        In al , dx ;Read Line Status?
        AND al , 00100000b
        JZ CH_SEND_F1_1 
      ; send the data if valid
        mov dx , 3F8H	; Transmit data register?
        mov  al,GOFIRE 
         ; test to show the number in the terminal
        out dx , al
        JMP MOVBUL                         ;then continue the game
     
     
     ;fire of the right player bullet type 1 
     
    P2FT:    

        MOV BL, statbul2
        CMP BL, 0H                          ;check the state of the bullet 
        JNZ MOVBUL  
        MOV SI,OFFSET TYPEBUL2
        MOV [SI],0H
        CALL FIRE2                          ;right player can fire if he has no bullet in the game
        JMP MOVBUL                         ;then continue the game   
        
        
     ;fire of the left player bullet type 2
     
    P1F2:   
       
        MOV BL,statbul1
        CMP BL,0H                           ;check the state of the bullet if not exist player can fire
        JNZ MOVBUL
        MOV SI,OFFSET TYPEBUL1
        MOV [SI],1H
        CALL FIRE1                          ;left player can fire if he has no bullets in the game 
        CH_SEND_F1_2: 
                    CALL SERIALCONFIG
                    mov dx , 3FDH	; Line Status Register?
                    In al , dx ;Read Line Status?
                    AND al , 00100000b
                    JZ CH_SEND_F1_2 
                    ; send the data if valid
                    mov dx , 3F8H	; Transmit data register?
                    mov  al,GOFIRE1 
                    ; test to show the number in the terminal
                    out dx , al
        JMP MOVBUL                         ;then continue the game
     
     
     ;fire of the right player bullet type 2 
     
    P2F2:    

        MOV BL, statbul2
        CMP BL, 0H                          ;check the state of the bullet 
        JNZ MOVBUL  
        MOV SI,OFFSET TYPEBUL2
        MOV [SI],1H
        CALL FIRE2                          ;right player can fire if he has no bullet in the game
        JMP MOVBUL                         ;then continue the game        
        
     
     ;left player moving down
        
 P1DOWNT: 

        MOV AL, 0H                          ;first remove the existing body
        CALL PERSON                           ;by drawing it black
        MOV BX, Y1
        ADD BX, 2H                          ;increase his Y value by 2 to go down 2 pixels 
        MOV Y1, BX
        MOV AL, 4H                          ;redraw him in red with the updated dimensions
        CALL PERSON 
        
        CH_SEND_P2_2: 
                    CALL SERIALCONFIG
                    mov dx , 3FDH	; Line Status Register?
                    In al , dx ;Read Line Status?
                    AND al , 00100000b
                    JZ CH_SEND_P2_2 
                    ; send the data if valid
                    mov dx , 3F8H	; Transmit data register?
                    mov  al,GODOWN_P2 
                    ; test to show the number in the terminal
                    out dx , al
        JMP MOVBUL                         ;continue the game 
     
     ;left player moving up
        
   P1UPT:   

        MOV AL, 0H                          ;first remove the existing body
        CALL PERSON                           ;by drawing it black
        MOV BX, Y1
        SUB BX, 2H                          ;decrease his Y value by 2 to go up 2 pixels
        MOV Y1, BX
        MOV AL, 4H
        CALL PERSON                         ;redarw him in red with the updated dimensions 
        CH_SEND_P1_1: 
                    CALL SERIALCONFIG
                    mov dx , 3FDH	; Line Status Register?
                    In al , dx ;Read Line Status?
                    AND al , 00100000b
                    JZ CH_SEND_P1_1 
                    ; send the data if valid
                    mov dx , 3F8H	; Transmit data register?
                    mov  al,GOUP_P2 
                    ; test to show the number in the terminal
                    out dx , al
        JMP MOVBUL                         ;continue the game
        
     
     ;right player moving down ( right arrow )
     
 P2DOWNT: 

        MOV AL, 0H                          ;first remove the existing body 
        CALL PERSON1                          ;by drawing it black
        MOV BX, Y2
        ADD BX, 2H                          ;increase his Y value by 2 to go down 2 pixels
        MOV Y2, BX
        MOV AL, 1H
        CALL PERSON1                        ;redraw him in blue with the updated dimensions
        JMP MOVBUL                         ;continue the game
                            
                            
     ;right player moving up ( left arrow )
     
P2UPT:   

        MOV AL, 0H                          ;first remove the existing body
        CALL PERSON1                          ;by drawing it black
        MOV BX, Y2
        SUB BX, 2H                          ;decrease his Y value by 2 to go up 2 pixels
        MOV Y2, BX
        MOV AL, 1H
        CALL PERSON1                        ;redraw him in blue with the updated dimensions
        JMP MOVBUL                         ;continue the game
   
                   
    PAUSET:  
         CH_SEND_Pauset: 
                    CALL SERIALCONFIG
                    mov dx , 3FDH	; Line Status Register?
                    In al , dx ;Read Line Status?
                    AND al , 00100000b
                    JZ CH_SEND_Pauset 
                    ; send the data if valid
                    mov dx , 3F8H	; Transmit data register?
                    mov  al,pause_tab 
                    ; test to show the number in the terminal
                    out dx , al 
                    
CH_RECIEVE_Pauset2:                                                      ;wait the user to enter a key
         CALL INCHAT
     
           
                                          ;1) if the bullet hit a player his health decreases by 1 ( intial health =4)
                                          ;2) if the bullet hit the barrier it bounce and may hurt its player :)
                                          ;3) if the bullet entred the barrier it destroyed  
MOVBUL:
     
     ;movement of the left player bullet 
     
        MOV BL, statbul1
        CMP BL, 0H                          ;first check if the bullet exists or not
        JZ GOON5                             
        MOV BX, 01H                         ;if exists
        MOV BULSELECT, BL                   ;select the first bullet to be moved
        MOV BL, dirbul1
        CMP BL, 0H                          ;check the direction of the bullet 
        JZ MR12                             ;if NOT 0 (left) ,it bounced 
         
        CALL MOVBULL                        ;move the bullet by 2 pixels in the left direction
        CALL MOVBULL  
        CALL MOVBULL
        JMP GOON5
                 
MR12:   
        MOV BL,TYPEBUL1
        CMP BL,0H
        JNZ NORM1
        CALL MOVBULR                        ;if 0 (right) 
        CALL MOVBULR                        ;move the bullet by 2 pixels in the right direction 
        CALL MOVBULR
        JMP GOON5
NORM1:  CALL MOVBLTR
        CALL MOVBLTR
        CALL MOVBLTR
        JMP GOON5
             
     ;movement of the right player bullet 
                
GOON5:  MOV BL, statbul2
        CMP BL, 0H                          ;first check if the bullet exists or not
        JZ PL1                              ;if not exists continue the game
        MOV BX, 02H
        MOV BULSELECT, BL                   ;select the second bullet to be moved
        MOV BL, dirbul2                     ;check the direction of the bullet
        CMP BL, 0H                          ;if NOT 0 (left)
        JZ MR21                             ;move the bullet by 3 pixels in the left direction
        MOV BL,TYPEBUL2
        CMP BL,0H
        JNZ NORM2
        CALL MOVBULL
        CALL MOVBULL
        CALL MOVBULL
        JMP PL1
NORM2:  CALL MOVBLTL
        CALL MOVBLTL
        CALL MOVBLTL
        JMP PL1        
MR21:   CALL MOVBULR                        ;if 0 (right),it bounced 
        CALL MOVBULR                        ;move the bullet by 3 pixels in the right direction
        CALL MOVBULR
        JMP PL1                              ;then continue the game     
      
        
     ;get the user key pressed from the keyboard buffer    
      
     CRL:     
        MOV BL,AH                           ;save the scancode of the key pressed in BL
        MOV AH,0H
        INT 16H                             ;remove the key from the buffer
        MOV AH,BL                           ;reload the scandcode to the AH again 
        JMP C                               ;jmp to check the pressed value and choose the action needed
         
     ;if any player press F4 the game ends in 5 seconds the back to the main menu    
     EGG:  
        CH_SEND_x1: 
                    CALL SERIALCONFIG
                    mov dx , 3FDH	; Line Status Register?
                    In al , dx ;Read Line Status?
                    AND al , 00100000b
                    JZ CH_SEND_x1
                    ; send the data if valid
                    mov dx , 3F8H	; Transmit data register?
                    mov  al,bara 
                    ; test to show the number in the terminal
                    out dx , al
barabaa1:
        DELAY 4DH, 0H     
        JMP MENUM   
        
        RET
LEVEL2  ENDP        
;----------------------------------------- CHATTING PART ----------------------------------------------------------------
CHAT    PROC

     ;clear the screen of the dosbox 
        MOV AX,0600H
        MOV BH,07H
        MOV CX,0H
        MOV DX,184FH
        INT 10H         

        MOV AH,2H 
        MOV BH,00H
        MOV DX,0900H
        INT 10H  
        MOV CX,50H
  DLINE:
        MOV AH,2H
        MOV DL,'-'
        INT 21H
        LOOP DLINE         
        
        mov ah,2H
        mov dx,1300h
        int 10h         
        mov CX,50H
  NLINE:
        mov ah,2h
        mov dl,'-'
        int 21h
        LOOP NLINE
                    
        
        mov ah,2h 
        mov bh,0h
        mov dx,00h
        int 10h
                             
  ;write the name of the first player 
        mov bh,0h
        mov ah, 9h
        mov dx,offset USERNAME1+2
        int 21h 
      
                         
        mov ah,2h 
        mov bh,0h
        mov dx,0A00h
        int 10h
                                 
    ;write  the name of the second player 
        mov bh,0h
        mov ah, 9h
        mov dx,offset USERNAME2+2
        int 21h 
        

                    mov dx,3fbh ; Line Control Register?

                    mov al,10000000b	;Set Divisor Latch Access Bit?

                    out dx,al	;Out it?

                    ;Set LSB byte of the Baud Rate Divisor Latch register.?

                    mov dx,3f8h	

                    mov al,0ch	

                    out dx,al

                    ;Set MSB byte of the Baud Rate Divisor Latch register.?

                    mov dx,3f9h

                    mov al,00h

                    out dx,al

                    ;Set port configuration
        
                    mov dx,3fbh

                    mov al,00011011b

                    ;0:Access to Receiver buffer, Transmitter buffer


                    out dx,al
                    
                                        
                    
       ;//////////////////////////////////// the chat ///////////////////////////////////////////
                    ;   sending part 
                    Main_Loop_write:
                    ; mov the cursor to these positions  
                    mov ah,2
                    mov bh,0
                    mov dl,X_Write
                    mov dh,Y_Write
                    int 10h
                    
                    ; this will get keystroke from keyboard and not wait for this and the loop is very fast 
                    ; it will work good and store the result in value_write 
                    mov ah,1        
                    int 16h
                    jz Main_Loop_read
                    mov value_write,al
                    
                          
                    mov ah,0        
                    int 16h 
                    mov value_write,al 
                    
                    CMP AH,3DH
                    jz  GOUTN  
                    
                    cmp value_write,09h
                    jz Main_Loop_read    
                    
                    cmp value_write ,08h
                    jb Main_Loop_read
                    cmp value_write,7Dh
                    ja Main_Loop_read
                                                           
                    mov dx , 3FDH	; Line Status Register?

                   check_ready: In al , dx ;Read Line Status?

                    AND al , 00100000b

                    JZ check_ready

                    mov dx , 3F8H	; Transmit data register?

                    mov  al,value_write

                    out dx , al 
                     
                    cmp value_write ,08h
                    jnz MO  
                    cmp X_Write,00
                    jz  Main_Loop_read
                    dec X_Write
                    
                    mov dl,X_Write
                    mov dh,Y_Write
                    mov ah,2
                    mov bh,0
                    int 10h 
                    mov ah,2
                    mov dl,space
                    int 21h
                    ;inc X_Write
                    mov dl,X_Write
                    mov dh,Y_Write
                    mov ah,2
                    mov bh,0
                    int 10h 
                    
                    jmp goo
                    
                    MO:cmp value_write ,0Dh
                    jnz M_1
                    mov X_Write,00
                    inc Y_Write 
                    cmp Y_Write,08h
                    jz enter_2        
                    mov dl,X_Read
                    mov dh,Y_Read 
                    mov ah,2
                    mov bh,0
                    int 10h 
                    jmp Main_Loop_read
                    ; print this character on yoour screen also to now what are you writing 
                    ; mov the cursor to these positions  
                    M_1:mov ah,2
                    mov dl,value_write
                    int 21h 
                    
                    
                    ;now t get the cursor posotion and save it in a variables  X_Write&Y_Write 
                    goo:mov ah,3h
                    mov bh,0h
                    int 10h
                    mov X_Write,DL
                    MOV Y_Write,DH
                    
                    ;if you reach to the end of the line make a new line 
                    cmp X_Write,78
                    jz  newline_write 
                    jmp Main_Loop_read
                    ; end of the sending part
                    ;*******************************************************************************************
                     ;write for now
                    Main_Loop_read:  
                    mov ah,2  
                    mov bh,0
                    mov dl,X_Read
                    mov dh,Y_Read
                    int 10h 
                     
                        
                    
                    ;Check that Data Ready?

                    mov dx , 3FDH	; Line Status Register?

                    in al , dx 

                    AND al , 1

                    JZ Main_Loop_write

                    ;If Ready read the VALUE in Receive data register?

                     mov dx , 03F8H

                     in al , dx 

                     mov value_read , al
                     
                     
                            
                     CMP value_read, 9FH
                     JZ JK

                    cmp value_read ,08h
                    jb Main_Loop_write
                    cmp value_read,7Dh
                    ja Main_Loop_write

                    ;//////enter
                    cmp  value_read,08h
                    jnz MO1
                    cmp X_Read,00
                    jz  Main_Loop_write
                    dec X_Read
                    mov dl,X_Read
                    mov dh,Y_Read
                    mov ah,2
                    mov bh,0
                    int 10h 
                    mov ah,2
                    mov dl,space
                    int 21h
                    ;inc X_Write
                    mov dl,X_Read
                    mov dh,Y_Read
                    mov ah,2
                    mov bh,0
                    int 10h 
                    
                    jmp goo1
                     
                    MO1:cmp value_read ,0Dh
                    jnz M
                    mov X_Read,00
                    inc Y_Read 
                    cmp Y_Read,12h
                    jz enter
                    mov dl,X_Read
                    mov dh,Y_Read 
                    mov ah,2
                    mov bh,0
                    int 10h 
                    jmp Main_Loop_write
                     
                    
                      
                    
                    M:mov ah,2
                    mov dl,value_read 
                    int 21h   
                    
                    
                    goo1:mov ah,3h
                    mov bh,0h
                    int 10h 
                    
                    mov X_Read,DL
                    MOV Y_Read,DH
                    cmp X_Read,78
                    jz newline_read
                    jmp Main_Loop_write
                     
                    ;*******************************************************************************************
                    ; make anew line and scrolling the screen 
                    newline_write:
                    inc Y_Write
                    mov X_Write,00h 
                    cmp Y_Write,8h
                    jz scroll_write
                    jmp  Main_Loop_read  
                    
                    scroll_write:
                    mov al,01h
                    mov bh,07h
                    mov ch,01h
                    mov cl,00h
                    mov dh,07h
                    mov dl,78
                    mov ah,06h
                    int 10h  
                    mov ah,2
                    mov bh,0 
                    mov X_Write,00h
                    mov Y_Write,07h
                    int 10h
                    jmp  Main_Loop_read 
                    ;********************************************************************************************
                    newline_read:
                    inc Y_Read
                    mov X_Read,00h 
                    cmp Y_Read,12h
                    jz scroll_read
                    jmp Main_Loop_write
                    
                    scroll_read:
                    mov al,01h
                    mov bh,07h
                    mov ch,0Bh
                    mov cl,00h
                    mov dh,11h
                    mov dl,4Fh
                    mov ah,06h
                    int 10h  
                    mov ah,2
                    mov bh,0 
                    mov X_Read,00h
                    mov Y_Read,11h
                    int 10h
                    jmp Main_Loop_write 
                    ;******************************************************************************************** 
                    enter:  
                    mov al,01h
                    mov bh,07h
                    mov ch,0Bh
                    mov cl,00h
                    mov dh,11h
                    mov dl,4Fh
                    mov ah,06h
                    int 10h  
                    mov X_Read,00
                    mov Y_Read,11h
                    mov dl,X_Read
                    mov dh,Y_Read 
                    mov ah,2
                    mov bh,0
                    int 10h 
                    jmp Main_Loop_write
                    
                    enter_2:
                    mov al,01h
                    mov bh,07h
                    mov ch,01h
                    mov cl,00h
                    mov dh,07h
                    mov dl,78
                    mov ah,06h
                    int 10h  
                    mov X_Write,00
                    mov Y_Write,07h
                    mov dl,X_Write
                    mov dh,Y_Write
                    mov ah,2
                    mov bh,0
                    int 10h 
                    jmp Main_Loop_read 
                            
        
 GOUTN:
       
    COREADY: 
        IN AL,DX
        AND AL,00100000B
        JZ COREADY
       
        MOV DX,3F8H
        MOV AL,9FH
        OUT DX,AL

JK:      
        JMP MENUM
                   
        RET
CHAT    ENDP

;----------------------------------------- level selection menu-------------------------------------------------
                                                            
LVLSEL  proc
        
        MOV AH, 0H
        MOV AL, 03H
        INT 10H
        
        MOV DX,0A19H                        ;CHANGE THE CURSOR POSITION 
        MOV AH,2H     
        INT 10H
        
        MOV AH,9
        MOV DX,OFFSET PRESSN1
        INT 21H                             ;PRINT FIRST MESS PRESSN1
        
        MOV DX,0C19H
        MOV AH,2H                           ;change the cursor position and read the name
        INT 10H                                                                           
        
        MOV AH,9
        MOV DX,OFFSET PRESSN2
        INT 21H                             ;PRINT FIRST MESS PRESSN2
        
        MOV DX,01400H
        MOV AH,2H    
        INT 10H
        
        MOV AH,9H                           ;DRAW THE STATUS BAR LINE FROM A CERTAIN POSITION
        MOV BH,0H
        MOV AL,'='
        MOV CX,80D
        MOV BL,00FH
        INT 10H
        
GETKEY:
        MOV AH,0
        INT 16H
        
        CMP AH,02
        JNZ SEEHERE 
        
CH_SEND_L:  
        CALL SERIALCONFIG
        mov dx , 3FDH	        ;Line Status Register?
        In al , dx              ;Read Line Status?
        AND al , 00100000b
        JZ CH_SEND_L 
                                           ; send the data if valid
        mov dx , 3F8H	        ; Transmit data register?
        mov  al,numOflevel 
                                            ; test to show the number in the terminal
        out dx , al
        
        CALL LEVEL1
        
        JMP CON
        
SEEHERE:
        CMP AH,03
        JNZ GETKEY
        
CH_SEND_L2: 
        CALL SERIALCONFIG
        mov dx , 3FDH	        ;Line Status Register?
        In al , dx              ;Read Line Status?
        AND al , 00100000b
        JZ CH_SEND_L2 
                                            ; send the data if valid
        mov dx , 3F8H	        ; Transmit data register?
        mov  al,numOflevel2 
                                            ; test to show the number in the terminal
        out dx , al
        
        CALL LEVEL2
        
        CON:
        
        RET  
          
endp LVLSEL

;----------------------------------------------------------------------------------------

showlvlsel proc
        
        MOV AH, 0H
        MOV AL, 03H
        INT 10H
        
        MOV DX,0A11H                        ;CHANGE THE CURSOR POSITION 
        MOV AH,2H     
        INT 10H
        
        MOV DX,OFFSET USERNAME2+2
        MOV AH,9H
        INT 21H      
        
        MOV DX,OFFSET NOT5
        MOV AH,9H
        INT 21h 
        
        MOV DX,1500H                        ;CHANGE THE CURSOR POSITION 
        MOV AH,2H     
        INT 10H
        
        MOV AH,9H                           ;DRAW THE STATUS BAR LINE FROM A CERTAIN POSITION
        MOV BH,0H
        MOV AL,'='
        MOV CX,80D
        MOV BL,00FH
        INT 10H 
      
      
CH_RECIEVE_L:
        
        CALL SERIALCONFIG
        mov dx , 3FDH	; Line Status Register?
        in al , dx
        AND al , 1
        jZ CH_RECIEVE_L   
        
    ;If Ready read the VALUE in Receive data register?  
    
        mov dx , 03F8H                    
        in al , dx  
        cMP al,numOflevel
        JZ callinglevel1   
        
        cmp al,numOflevel2
        jz callinglevel2  
        
        jmp CH_RECIEVE_L     
        

callinglevel1:  
        CALL LEVEL1
        
        JMP CON1
        
        
callinglevel2:         
        CALL LEVEL2
        
        CON1:
        
        RET  
          
endp showlvlsel

;----------------------------- Intializations used for connection ------------------------------------------------------------

SERIALCONFIG    PROC 
    
                mov dx,3fbh                   ; Line Control Register?
                mov al,10000000b	          ;Set Divisor Latch Access Bit?
                out dx,al	                  ;Out it?
                                              ;Set LSB byte of the Baud Rate Divisor Latch register.?  
                mov dx,3f8h	
                mov al,0ch	
                out dx,al
                                              ;Set MSB byte of the Baud Rate Divisor Latch register.?
                mov dx,3f9h
                mov al,00h
                out dx,al
                                              ;Set port configuration
                mov dx,3fbh
                mov al,00111011b
                out dx,al 
                ret
ENDP SERIALCONFIG
 
;------------------------------------------- remove line function ----------------------------------------------------------------------------

; IN THIS FUNCTION YOU HAVE TO SET THE CURSOR POSITION BEFORE CALLING IT

CLEARL  PROC  
        
        MOV CX,40H                          ;interrupt used to clear the status bar 
        MOV AH,9H                           ;drawing 45 space on the status bar
        MOV BH,0H
        MOV AL,20H 
        MOV BL,0H
        INT 10H
        
        RET
CLEARL  ENDP


;----------------------------------------- END OF THE PROGRAMM ----------------------------------------------------------------
tempo   proc
           
      ;write the players names in the chat block      
        
        MOV ah,2h
        MOV BX,0h 
        MOV DX,1100H      
        INT 10H
        MOV AH,9H                              
        MOV DX,OFFSET USERNAME1 + 2       ;USERNAME 1
        int 21h
        
        
        MOV ah,2h
        MOV BX,0h 
        MOV DX,1300H      
        INT 10H
        MOV AH,9H
        MOV DX,OFFSET USERNAME2 + 2       ;USERNAME 2
        int 21h 
        MOV AH, 2H
        MOV BX, 0H
        MOV DX, 1701H
        INT 10H   
              
        ret
tempo   endp        
       
;----------------------------------------- END OF THE PROGRAMM ----------------------------------------------------------------

        END MAIN        