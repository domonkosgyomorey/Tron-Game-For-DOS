Code    Segment
    assume CS:Code, DS:Data, SS:Stack

MENU_MSG1_X equ 10
MENU_MSG1_Y equ 10
MENU_MSG2_X equ 10
MENU_MSG2_Y equ 11
MENU_MSG3_X equ 10
MENU_MSG3_Y equ 12

HELP_MENU_MSG1_X equ 0
HELP_MENU_MSG1_Y equ 5

HELP_MENU_MSG2_X equ 0
HELP_MENU_MSG2_Y equ 6

HELP_MENU_RULES_X equ 0
HELP_MENU_RULES_Y equ 8

HELP_MENU_BACK_X equ 0
HELP_MENU_BACK_Y equ 10

P1C equ 39
P1_TRAIL_C equ 41
P2C equ 31
P2_TRAIL_C equ 52

WALL_C equ 10

MIN_DT equ 1


GRAPHICS_SEG equ 0a000h

SCREEN_WIDTH equ 320
SCREEN_HEIGHT equ 200

POS_FN equ 2
PRINT_STR_FN equ 9
PRINT_CHR_FN equ 2

CONSOLE_VID_MOD equ 3
VGA_VID_MOD equ 13h

NON_BLOCK_KEY_CHECK_FN equ 1
KEY_CHECK_FN equ 0

TIMER_FN equ 0
TIMER_INT equ 1ah
TIMER_LOW_TICK_REG equ dx

WINNER_MSG_X_OFFSET equ 16
WINNER_MSG_Y_OFFSET equ 4
SCORE_MSG_X_OFFSET equ 17
SCORE_MSG_Y_OFFSET equ 2

RED_BLUE_MSG_X_OFFSET equ 15
RED_BLUE_MSG_Y_OFFSET equ 0

CONTINUE_MSG_X_OFFSET equ 0
CONTINUE_MSG_Y_OFFSET equ 22

ESCAPE_CHAR equ 27
LEFT_ARROW equ 75
RIGHT_ARROW equ 77
UP_ARROW equ 72
DOWN_ARROW equ 80

MOVE_SPEED equ 1

Start:
    mov ax, Data
    mov ds, ax

MenuLoop:
    mov ah, CONSOLE_VID_MOD
    int 10h
    call WriteMenu
    
    xor ax, ax
    int 16h
    
    cmp al, '1'
    je Game
    cmp al, '2'
    je Help
    cmp al, '3'
    je ExitGame
    
    jmp MenuLoop

Help:
    call WriteHelp

    xor ax, ax
    int 16h

    cmp al, '1'
    je MenuLoop
    
    jmp Help

ExitGame:       
    mov ah, CONSOLE_VID_MOD
    int 10h
    mov ax, 4c00h
    int 21h

Game:
    mov al, VGA_VID_MOD
    xor ah, ah
    int 10h
    
    mov ax, GRAPHICS_SEG
    mov es, ax
    
    mov p1_x, 150
    mov p1_y, 100
    mov p2_x, 170
    mov p2_y, 100
    mov p1_vx, -1
    mov p1_vy, 0
    mov p2_vx, 1
    mov p2_vy, 0

mov al, WALL_C
mov di, 0
draw_up_edge_l:
    mov al, WALL_C
    mov es:[di], al
    add di, 1
    cmp di, SCREEN_WIDTH
    jle draw_up_edge_l
mov di, (SCREEN_HEIGHT-1)*SCREEN_WIDTH
draw_bottom_edge_l:
    mov al, WALL_C
    mov es:[di], al
    add di, 1
    cmp di, SCREEN_HEIGHT*SCREEN_WIDTH+1
    jle draw_bottom_edge_l
mov di, 0
draw_left_edge_l:
    mov al, WALL_C
    mov es:[di], al
    add di, SCREEN_WIDTH
    cmp di, SCREEN_WIDTH * SCREEN_HEIGHT
    jb draw_left_edge_l
mov di, SCREEN_WIDTH - 1
draw_right_edge_l:
    mov al, WALL_C
    mov es:[di], al
    add di, SCREEN_WIDTH
    cmp di, SCREEN_WIDTH * SCREEN_HEIGHT
    jb draw_right_edge_l

    jmp GameLoop
    
ExitGame_:
    jmp ExitGame

GameLoop:
    call Wait  
    call Input
    call Player1DrawTrail
    call Player2DrawTrail 
    call UpdatePlayers
    call Player1Draw
    call Player2Draw
    jmp GameLoop


Input:      
    mov ah, NON_BLOCK_KEY_CHECK_FN
    int 16h
    jz InputRet 
    
    mov ah, KEY_CHECK_FN
    int 16h
    
    cmp al, ESCAPE_CHAR
    je ExitGame_
    
    cmp ah, LEFT_ARROW  
    je Player1Left
    cmp ah, RIGHT_ARROW
    je Player1Right
    cmp ah, UP_ARROW
    je Player1Up
    cmp ah, DOWN_ARROW
    je Player1Down
    
    cmp al, 'a' 
    je Player2Left
    cmp al, 'd' 
    je Player2Right_
    cmp al, 'w' 
    je Player2Up_
    cmp al, 's'
    je Player2Down_
    
InputRet:
    ret

MenuLoop__:
    jmp MenuLoop

Player1Left:
    cmp p1_vx, 1
    je  InputRet
    mov p1_vx, -1
    mov p1_vy, 0
    ret
    
Player1Right:
    cmp p1_vx, -1
    je  InputRet
    mov p1_vx, 1
    mov p1_vy, 0
    ret

Player2Up_:
    jmp Player2Up

Player2Down_:
    jmp Player2Down

InputRet_:
    jmp InputRet

Player2Right_:
    jmp Player2Right

Player1Up: 
    cmp p1_vy, MOVE_SPEED
    je  InputRet_ 
    mov p1_vx, 0
    mov p1_vy, -MOVE_SPEED
    ret    
Player1Down:
    cmp p1_vy, -MOVE_SPEED
    je  InputRet_
    mov p1_vx, 0
    mov p1_vy, MOVE_SPEED
    ret
Player2Left:
    cmp p2_vx, MOVE_SPEED
    je  InputRet_ 
    mov p2_vx, -MOVE_SPEED
    mov p2_vy, 0
    ret
Player2Right:
    cmp p2_vx, -MOVE_SPEED
    je  InputRet_
    mov p2_vx, MOVE_SPEED
    mov p2_vy, 0
    ret
Player2Up:
    cmp p2_vy, MOVE_SPEED
    je  InputRet_
    mov p2_vx, 0
    mov p2_vy, -MOVE_SPEED
    ret    
Player2Down:
    cmp p2_vy, -MOVE_SPEED
    je  InputRet_
    mov p2_vx, 0
    mov p2_vy, MOVE_SPEED
    ret
Wait:
    push cx
    push TIMER_LOW_TICK_REG

    mov ah, TIMER_FN
    int TIMER_INT
    mov bx, TIMER_LOW_TICK_REG
WaitLoop:
    mov ah, TIMER_FN
    int TIMER_INT
    sub TIMER_LOW_TICK_REG, bx
    cmp TIMER_LOW_TICK_REG, MIN_DT
    jb WaitLoop
    
    pop TIMER_LOW_TICK_REG
    pop cx
    ret

MenuLoop_:
    jmp MenuLoop__

; Egyszerűség kedvéért használtam convert byte to word-et
UpdatePlayers:

    ; P1 pozicio frissit
    mov al, p1_vx
    cbw
    add p1_x, ax
    mov al, p1_vy
    cbw
    add p1_y, ax

    ; P2 pozicio frissit
    mov al, p2_vx
    cbw
    add p2_x, ax

    mov al, p2_vy
    cbw
    add p2_y, ax

    mov ax, p1_y
    mov bx, SCREEN_WIDTH
    mul ax
    add ax, p1_x
    push ax
    
    mov ax, p2_y
    mov bx, SCREEN_WIDTH
    mul ax
    add ax, p2_x
    pop bx

    cmp ax, bx
    je  draw__

    ; A Piros veszitett-e
    mov ax, p1_y
    mov bx, SCREEN_WIDTH
    mul bx
    add ax, p1_x
    mov di, ax
    mov al, 0
    cmp es:[di], al
    jne P1_lost__
    cmp p1_x, 320
    je  P1_lost__
    cmp p1_x, 0
    je  P1_lost__
    cmp p1_y, 200
    je  P1_lost__
    cmp p1_y, 0
    je  P1_lost__

    ; A Kék veszitett-e
    mov ax, p2_y
    mov bx, SCREEN_WIDTH
    mul bx
    add ax, p2_x
    mov di, ax
    mov al, 0
    cmp es:[di], al
    jne P2_lost_
    cmp p2_x, 320
    je  P2_lost_
    cmp p2_x, 0
    je  P2_lost_
    cmp p2_y, 200
    je  P2_lost_
    cmp p2_y, 0
    je  P2_lost_

    ret
draw__:
    jmp draw_

P1_lost__:
    jmp P1_lost_
P2_lost_:
    jmp P2_lost

Player1DrawTrail:
    mov ax, SCREEN_WIDTH
    mov bx, p1_y
    mul bx
    add ax, p1_x
    mov di, ax
    mov al, P1_TRAIL_C
    mov es:[di], al 

    ret

Player1Draw:
    mov ax, SCREEN_WIDTH
    mov bx, p1_y
    mul bx
    add ax, p1_x
    mov di, ax
    mov al, P1C
    mov es:[di], al 

    ret

draw_:
    jmp draw
P1_lost_:
    jmp P1_lost

Player2DrawTrail:
    mov ax, SCREEN_WIDTH
    mov bx, p2_y
    mul bx
    add ax, p2_x
    mov di, ax
    mov al, P2_TRAIL_C
    mov es:[di], al 

    ret

Player2Draw:
    mov ax, SCREEN_WIDTH
    mov bx, p2_y
    mul bx
    add ax, p2_x
    mov di, ax
    mov al, P2C
    mov es:[di], al 

    ret

P1_lost:
    ; return address törlese
    pop bx
    mov ah, CONSOLE_VID_MOD
    int 10h
    
    mov ah, POS_FN
    mov dh, WINNER_MSG_Y_OFFSET
    mov dl, WINNER_MSG_X_OFFSET
    int 10h

    mov dx, offset p2_won
    mov ah, PRINT_STR_FN
    int 21h
    
    ; Player 2 score növelése, mert Player 1 vesztett
    mov al, 1
    add p2_score, al

    jmp Print_after_loss

P2_lost:
    ; return address törlese
    pop bx
    mov ah, CONSOLE_VID_MOD
    int 10h
    

    mov ah, POS_FN
    mov dh, WINNER_MSG_Y_OFFSET
    mov dl, WINNER_MSG_X_OFFSET
    int 10h

    mov dx, offset p1_won
    mov ah, PRINT_STR_FN
    int 21h

    ; Player 1 score növelése, mert Player 2 vesztett
    mov al, 1
    add p1_score, al 

    jmp Print_after_loss

draw:
    ; return address törlese
    pop bx
    mov ah, CONSOLE_VID_MOD
    int 10h
    
    mov ah, POS_FN
    mov dh, WINNER_MSG_Y_OFFSET
    mov dl, WINNER_MSG_X_OFFSET
    int 10h

    mov dx, offset draw_msg
    mov ah, PRINT_STR_FN
    int 21h

    jmp Print_after_loss

MenuLoop___:
    jmp MenuLoop__

Print_after_loss:
    mov ah, POS_FN
    mov dh, RED_BLUE_MSG_Y_OFFSET
    mov dl, RED_BLUE_MSG_X_OFFSET
    int 10h
    
    mov ah, 9
    mov dx, offset score_msg
    int 21h

    mov ah, POS_FN
    mov dh, SCORE_MSG_Y_OFFSET
    mov dl, SCORE_MSG_X_OFFSET
    int 10h
    
    mov ah, PRINT_CHR_FN
    mov dl, p1_score
    add dx, '0'
    int 21h

    mov ah, POS_FN
    mov dh, SCORE_MSG_Y_OFFSET
    mov dl, SCORE_MSG_X_OFFSET+2
    int 10h

    mov ah, PRINT_CHR_FN
    mov dx, ':'
    int 21h

    mov ah, POS_FN
    mov dh, SCORE_MSG_Y_OFFSET
    mov dl, SCORE_MSG_X_OFFSET+4
    int 10h

    mov ah, PRINT_CHR_FN
    mov dl, p2_score
    add dx, '0'
    int 21h
    
    mov ah, POS_FN
    mov dh, CONTINUE_MSG_Y_OFFSET
    mov dl, CONTINUE_MSG_X_OFFSET
    int 10h
    
    mov ah, PRINT_STR_FN
    mov dx, offset press_key2c
    int 21h

    xor ax, ax
    mov ah, KEY_CHECK_FN
    int 16h
    cmp al, ' '
    je  MenuLoop___
    jmp Print_after_loss

WriteMenu:
    mov ax, CONSOLE_VID_MOD
    int 10h
    
    mov ah, POS_FN
    xor bx, bx
    mov dl, MENU_MSG1_X
    mov dh, MENU_MSG1_Y
    int 10h
    
    mov ah, PRINT_STR_FN
    mov dx, offset menumsg1
    int 21h
    
    mov ah, POS_FN
    xor bx, bx
    mov dl, MENU_MSG2_X
    mov dh, MENU_MSG2_Y
    int 10h
    
    mov ah, PRINT_STR_FN
    mov dx, offset menumsg2
    int 21h

    mov ah, POS_FN
    xor bx, bx
    mov dl, MENU_MSG3_X
    mov dh, MENU_MSG3_Y
    int 10h
    
    mov ah, PRINT_STR_FN
    mov dx, offset menumsg3
    int 21h
    ret

WriteHelp:
    mov ax, CONSOLE_VID_MOD
    int 10h

    mov ah, POS_FN
    xor bx, bx
    mov dl, HELP_MENU_MSG1_X
    mov dh, HELP_MENU_MSG1_Y
    int 10h

    mov ah, PRINT_STR_FN
    mov dx, offset helpmsg_1
    int 21h

    mov ah, POS_FN
    xor bx, bx
    mov dl, HELP_MENU_MSG2_X
    mov dh, HELP_MENU_MSG2_Y
    int 10h

    mov ah, PRINT_STR_FN
    mov dx, offset helpmsg_2
    int 21h

    mov ah, POS_FN
    xor bx, bx
    mov dl, HELP_MENU_RULES_X
    mov dh, HELP_MENU_RULES_Y
    int 10h

    mov ah, PRINT_STR_FN
    mov dx, offset rules_msg
    int 21h

    mov ah, POS_FN
    xor bx, bx
    mov dl, HELP_MENU_BACK_X
    mov dh, HELP_MENU_BACK_Y
    int 10h

    mov ah, PRINT_STR_FN
    mov dx, offset back_msg
    int 21h

    ret

Code    Ends

Data    Segment
    menumsg1 db "(1) Play$"
    menumsg2 db "(2) Help$"
    menumsg3 db "(3) Exit$"
    
    p1_won db "Red Won$"
    p2_won db "Blue Won$"
    draw_msg db "Draw$"

    score_msg db "Red   Blue$"
    
    press_key2c db "Press space to continue...$"
    
    helpmsg_1 db "Red player controll ( arrows ).$"
    helpmsg_2 db "Blue player controll ( w, a, s, d ).$"
    rules_msg db "Don't collide with wall and don't collide with any trail.$"
    back_msg  db "(1) Back.$"

    p1_score db 0
    p2_score db 0
    
    p1_x    dw 0
    p1_y    dw 0

    p2_x    dw 0
    p2_y    dw 0

    p1_vx   db 0
    p1_vy   db 0
    
    p2_vx   db 0
    p2_vy   db 0
Data    Ends

Stack   Segment
Stack   Ends

    End Start
