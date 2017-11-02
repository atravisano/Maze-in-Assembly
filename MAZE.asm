; Anthony Travisano
; MAZE 
; -Prints the array which is our maze
; -Displays player
; -Displays goal
; -Player can use w-a-s-d to navigate through the maze
; -If the player tries to go a direction where a wall is, they will hear a beep
; -Once the player reaches the goal a message will display and the program 
;will end
; -player can also press m to become superman and can roam anywhere on the screen

include 'emu8086.inc'
org 100h

jmp CODE

maze:                       ;1 is a block, 0 is a path, and 2 is the goal
DB 1,1,1,1,1,1,1,1,1,1,1,1 
DB 1,0,0,0,1,1,0,0,0,0,1,1 
DB 1,0,1,0,0,0,0,1,1,0,1,1 
DB 1,0,1,1,1,1,0,1,1,0,1,1 
DB 1,0,0,0,0,1,0,1,1,0,1,1 
DB 1,1,0,1,1,1,1,1,1,0,1,1 
DB 1,1,0,0,0,0,0,1,1,0,1,1 
DB 1,1,0,1,0,1,0,1,1,0,1,1 
DB 1,0,0,0,0,0,0,1,1,0,1,1 
DB 1,0,1,1,0,1,0,0,0,0,1,1 
DB 1,0,1,1,0,1,2,1,1,1,1,1 
DB 1,1,1,1,1,1,1,1,1,1,1,1

mcol = 12 ; # columns in maze 
mrow = ($ - maze)/ MCOL ; # rows in maze

manx db 1 ;avatar horizontal position
many db 1 ;avatar vertical position 

sman db 0 ;used to tell whether you are superman or not


CODE:
    mov cx,mrow ;rows in the maze
    lea si,maze ;pointer to the maze
    
  DRAWMAZE:
    mov bx, cx  ;save the loop counter
    call Draw         
    mov cx, bx  ;restore loop counter
    printn      ;end of row                
  loop DRAWMAZE
    lea si,maze
    
    lea di, maze
    add di, 13 ;sets pointer to first 0(path)    
    GOTOXY manx,many
    putc 1    ;displays player at beginning of maze
     
    GOTOXY 6,10
    putc 15   ;displays goal at end of maze
    
    gotoxy 0,14  ;prints instructions for user
    print "w=up  a=left  s=down  d=right  m=superman mode"
    
    printn ;explains what super man mode is    
    print "Becoming superman means you can destroy anything to get to the goal." 
    
    
    mov ch, 32  ;hide blinking text cursor
    mov ah,1
    int 10h
                                         
MOVEPLAYER:
    call GetPlayerMove
    ;infinite loop
    loop MOVEPLAYER

GOAL:
    gotoxy 0,19  ;Put the message under the maze
    print "Congratulations! You made it to the goal!"
    INT 20h ;Ends program
    
    
     
ret                                        
;==========================================================


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure that prints out a wall(block(1)) or path(space(0))
; -prints out one column from the array  
;
Draw proc
    
    mov cx, mcol ;procedure prints out one column
    
    XCOLUMN:
    
    cmp [si], 0 ; path? 
    je p     ; yes, go to p to draw path
    PUTC 219 ; WALL - Char 219 is a white block 
    jmp nx   
    p: PUTC 32 ; PATH - draw a blank space(Char 32 is a space)
    nx: inc si ; point to next number in column
    loop XCOLUMN 
       
ret

Draw endp
    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure recieves user inputs: w a s d
;-Makes the character move left,right, up, or down depending on
; user's input
;-Moves pointer in maze to where the character is on screen
;-When user presses m he becomes superman and can destroy anything around hi,
;
GetPlayerMove proc
    mov ah,00h
    int 16h ; read character into al, bios scan code in ah
    
  right:
    cmp al, 'd' ;did user enter d?
    jne left  ;no, go to left
    cmp byte ptr[di][+1], 2 ;checks if goal
    je GOAL
 cmp sman,1 ;in superman mode it will never beep since he can go through anything 
 je sright   
    cmp byte ptr [di][+1],0 ;looks at one byte to the right, checks if path 
    jne BEEP
 sright:
    add di,1 ; go to next value(right) in maze array    
    gotoxy manx,many
    putc 32 ;put space so the player's character doesnt appear more than once
    add manx,1 ;show character on screen move to the right
    gotoxy manx,many; move character on screen
    putc 1
    jmp by
  
  left:
    cmp al,'a' ;did user enter a?
    jne up     ;no, go to up
        cmp byte ptr[di][-1], 2 ;checks if goal
        je GOAL
  cmp sman,1 ;in superman mode it will never beep since he can go through anything 
  je sleft
        cmp byte ptr[di][-1],0 ;looks at one byte to the left
        jne BEEP
  sleft:
        add di,-1 ;go back a value(left) in maze array
        gotoxy manx, many
        putc 32
        add manx,-1 ;show character move to the left
        gotoxy manx, many 
        putc 1
        jmp by
        
  up:
    cmp al, 'w'
    jne down
        cmp byte ptr[di][-12], 2 ;checks if goal
        je GOAL
  cmp sman,1
  je sup
        cmp byte ptr[di][-12],0 ;looks 12 bytes behind (above player's location)
        jne BEEP
  sup:
        add di,-12  ;goes up one in array(take 12 steps back)
        gotoxy manx, many
        putc 32
        add many,-1 ;show character move up (must use y-pos)
        gotoxy manx, many
        putc 1
        jmp by
        
  down:
    cmp al, 's'
    jne superman
        cmp byte ptr[di][+12], 2 ;checks if goal
        je GOAL
  cmp sman,1
  je sdown
        cmp byte ptr[di][+12],0  ;looks 12 bytes ahead (below player's location)
        jne BEEP
  sdown:        
        add di,12  ;goes down one in array (moves 12 forward)
        gotoxy manx, many
        putc 32
        add many,1 ;show character go down
        gotoxy manx, many
        putc 1
        jmp by
        
  superman:
    cmp al, "m"   ;if the user presses m, he may roam freely within the screen
    jne right
        mov sman, 1
        jmp by      
  
  
  BEEP:
    putc 7 ; makes a beep noise
    
 by:
    ret
GetPlayerMove endp
 
