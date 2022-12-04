.model small     
      
.stack 100H

.data
     game_title db '    ______  _                        ',10,13
                db '   / _____)| |                  _    ',10,13
                db '  | /  ___ | | _    ___    ___ | |_  ',10,13
                db '  | | (___)| || \  / _ \  /___)|  _) ',10,13
                db '  | \____/|| | | || |_| ||___ || |__ ',10,13
                db '   \_____/ |_| |_| \___/ (___/  \___)',10,13
                db '                                     ',10,13
                db '       _     _                       ',10,13
                db '      | |   | |               _      ',10,13
                db '      | |__ | | _   _  ____  | |_    ',10,13
                db '      |  __)| || | | ||  _ \ |  _)   ',10,13
                db '      | |   | || |_| || | | || |__   ',10,13
                db '      |_|   |_| \____||_| |_| \___)  ',10,13                  
    title_len  equ $-game_title
    options  db '                  Jogar              ',10,13,10,13
             db '                  Sair               '
    options_len equ $-options
    current_screen db 0 ; 0 - Menu, 1 - Jogo, 2 - Fim de jogo]
    game_1st_render db 1H
    
    score_label db 'Score: 50' ; TODO
    score dw 0
    
    time_label db 'Tempo: 60' ; TODO
    time db 60

    video_mem_addr equ 0A000H
    
    hunter dw 099H,0BBH ;x,y
    hunter_x_pos dw 99H ;x
    hunter_mask db 00H,00H,00H,0EH,0EH,0EH,0EH,0EH,0EH,0EH,00H,00H
                db 00H,00H,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH
                db 00H,0EH,0EH,00H,00H,0EH,0EH,0EH,0EH,0EH,0EH,00H
                db 0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,00H,00H,00H
                db 0EH,0EH,0EH,0EH,0EH,0EH,00H,00H,00H,00H,00H,00H
                db 0EH,0EH,0EH,0EH,0EH,0EH,00H,00H,00H,00H,00H,00H
                db 0EH,0EH,0EH,0EH,0EH,0EH,0EH,00H,00H,00H,00H,00H
                db 00H,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,00H,00H,00H
                db 00H,00H,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH
                db 00H,00H,00H,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,00H
     
     ghost_line_1_direction db 1H ; 0H - move to right, 1H - move to left
     ghosts_line_1_pos_y equ 10H
     ghosts_line_1_pos_x_r dw 11FH, 133H ; esse eh o da diraita
     ghosts_line_1_pos_x_l dw 1H, 14H ; TA TROCADO! esse eh o da esquerda
     ghost_mask db 00H,00H,00H,0EH,0EH,0EH,0EH,0EH,0EH,00H,00H,00H
                db 00H,00H,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,00H,00H
                db 00H,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,00H
                db 0EH,0EH,0EH,00H,00H,0EH,0EH,00H,00H,0EH,0EH,0EH
                db 0EH,0EH,0EH,00H,00H,0EH,0EH,00H,00H,0EH,0EH,0EH
                db 0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH
                db 0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH
                db 0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH
                db 0EH,0EH,0EH,00H,0EH,0EH,0EH,0EH,00H,0EH,0EH,0EH
                db 00H,0EH,00H,00H,00H,0EH,0EH,00H,00H,00H,0EH,00H            
                
.code
    PUSH_CONTEXT macro
        push AX
        push BX
        push CX
        push DX
        push DI
        push SI
        push BP
    endm
    POP_CONTEXT macro
        pop BP
        pop SI
        pop DI
        pop DX
        pop CX
        pop BX
        pop AX
    endm
    SET_VIDEO_MODE macro
        ;https://stanislavs.org/helppc/int_10.html
        mov AH, 00H
        mov AL, 13H
        int 10h
    endm
    HIDE_CURSOR macro
        mov cx, 2507h
        mov ah, 01
        int 10h
    endm
    END_PROGRAM macro
        mov AH, 4CH
        mov AL, 0
        int 21H
    endm
    RENDER_TITLE macro
        PUSH_CONTEXT
        mov BL, 0AH
        mov CX, title_len
        mov DH, 0
        mov DL, 0
        mov BP, offset game_title
        call PRINT_STRING
        POP_CONTEXT
    endm
    RENDER_OPTIONS macro
        PUSH_CONTEXT
        mov BL, 0FH
        mov CX, options_len
        mov DH, 19
        mov DL, 0
        mov BP, offset options
        call PRINT_STRING
        POP_CONTEXT
    endm
    MARK_PLAY_OPTION macro
        push DI
        push AX
        mov DI, offset options
        add DI, 16
        mov AX, '['
        mov [DI], AX
        add DI, 8
        mov AX, ']'
        mov [DI], AX
        pop AX
        pop DI
    endm
    UNMARK_PLAY_OPTION macro
        push DI
        push AX
        mov DI, offset options
        add DI, 16
        mov AX, ' '
        mov [DI], AX
        add DI, 8
        mov [DI], AX
        pop AX
        pop DI
    endm
    MARK_QUIT_OPTION macro
        push DI
        push AX
        mov DI, offset options
        add DI, 57
        mov AX, '['
        mov [DI], AX
        add DI, 8
        mov AX, ']'
        mov [DI], AX
        pop AX
        pop DI
    endm
    UNMARK_QUIT_OPTION macro
        push DI
        push AX
        mov DI, offset options
        add DI, 57
        mov AX, ' '
        mov [DI], AX
        add DI, 8
        mov [DI], AX
        pop AX
        pop DI
    endm

    ; SI - mask offset
    ; DX - X
    ; BX - Y
    ; AL - pixel color
    PRINT_CHARACTER_LINE proc
        PUSH_CONTEXT
        mov CL, AL ; CL = pixel color

        ; row + col * 320
        mov AX, BX ; AX = Y
        
        mov BX, video_mem_addr
        mov ES, BX
        
        mov BX, 320
        push DX ; mul altera o valor de DX
        mul BX ; AX = AX * 320
        pop DX
        add AX, DX ; AX += X

        mov BL, CL ; BL = pixel color

        mov CX, 12
        mov DI, AX
        loop_str_v2:       
            lodsb           ; AL = SI
            cmp AL, 0H
            je SKIP_CUSTOM_COLOR
            mov AL, BL ; AL = pixel color
            SKIP_CUSTOM_COLOR:
            mov ES:[DI],AL  ; write pixel
            inc DI
            loop loop_str_v2 
        POP_CONTEXT
        ret
    endp
    
    ; DI - X pos offset
    ; BX - Y
    ; SI - mask offset
    ; AL - pixel color
    PRINT_CHARACTER proc
        PUSH_CONTEXT
        mov DX, [DI] ; x
        mov CX, 10
        draw_line:
            call PRINT_CHARACTER_LINE ; line 1
            inc BX
            add SI, 12
            loop draw_line
            
        POP_CONTEXT
        ret
    endp

    ; BL cor
    ; CX qtd chars da string
    ; DH linha
    ; DL coluna
    ; ES:BP offset da string
    PRINT_STRING proc
        push AX
        mov AH, 13H ; set write string
        mov AL, 0 ; set write mode (https://stanislavs.org/helppc/int_10-13.html)
        mov BH, 0H ; set page number
        int 10H
        pop AX
        ret
    endp
    
    ; print string video mode
    ; DL - coluna
    ; SI - string offset
    ; BL - color
    ; CX - qtd chars
    PRINT_STRING_V_MODE proc
        PUSH_CONTEXT
        print_char_v_mode:
            mov  DH, 0   ; Row (fixo na 0)
            mov  BH, 0    ; Display page
            mov  AH, 02H  ; SetCursorPosition
            int  10H
            
            lodsb ; AL <- [SI] ; SI++
            mov  BH, 0 ; Display page
            mov  AH, 0EH  ; int 10H - Teletype mode
            int  10H
            inc DL ; next column
            loop print_char_v_mode 
        POP_CONTEXT  
        ret
    endp
    
    WRITE_SCORE_LABEL proc
        push DX
        push SI
        push BX
        push CX
        mov DL, 0
        mov SI, offset score_label
        mov BL, 0FH
        mov CX, 9
        call PRINT_STRING_V_MODE
        pop CX
        pop BX
        pop SI
        pop DX
        ret
    endp
    
    WRITE_TIME_LABEL proc
        push DX
        push SI
        push BX
        push CX
        mov DL, 31
        mov SI, offset time_label
        mov BL, 0FH
        mov CX, 9
        call PRINT_STRING_V_MODE
        pop CX
        pop BX
        pop SI
        pop DX
        ret
    endp
    
    CLEAR_SCREEN proc
        PUSH_CONTEXT
        SET_VIDEO_MODE
        POP_CONTEXT
        ret
    endp
    
    DELAY proc  
        push cx
        push dx
        push ax
        
        xor cx, cx
        mov dx, 0C350h ; 50000 microsegundos
        mov ah, 86h
        int 15h ; http://vitaly_filatov.tripod.com/ng/asm/asm_026.13.html
        
        pop ax
        pop dx
        pop cx
        ret
    endp 

    ; a proc atualiza o BL e BH conforme a opcao selecionada 
    CHECK_KEYPRESS proc
        push AX
        xor AH, AH
        
        ; https://stanislavs.org/helppc/int_16.html
        mov AH, 01H ; Get keystroke status      
        int 16H ; AH = scan code            
           
        ; comparando somente a parte alta
        cmp AH, 1CH ; Enter
        je enter_key
        
        cmp AH, 48H ; Up Arrow
        je arrow_up_key
        
        cmp AH, 50H ; Down Arrow
        je arrow_down_key
        
        jmp end_check_kreypress
            
        enter_key:
            mov BH, 1H
            jmp end_check_kreypress
            
        arrow_up_key:
            mov BL, 0
            MARK_PLAY_OPTION
            UNMARK_QUIT_OPTION
            jmp end_check_kreypress
            
        arrow_down_key:
            mov BL, 1
            MARK_QUIT_OPTION
            UNMARK_PLAY_OPTION
            
        end_check_kreypress:
            ; clearing keyboard buffer
            mov AH,0CH
            mov AL,0
            int 21h
            pop AX
        ret
    endp
    
    ; essa proc altera o valor de BX
    RENDER_MENU proc
        PUSH_CONTEXT
        RENDER_TITLE
        
        ; BL = 0 - Jogar, 1 - Sair
        ; BH = 0 - Enter nao selecionado, 1 - Enter selecionado
        
        RENDER_OPTIONS
        call CHECK_KEYPRESS
        
        cmp BH, 0
        je end_render_menu
        
        cmp BL, 0
        je play_opt_selected
        
        ; Sair foi selecionado
        call CLEAR_SCREEN
        END_PROGRAM
        
        play_opt_selected:
            mov current_screen, 1H
            call CLEAR_SCREEN
            
        end_render_menu:
        POP_CONTEXT
        ret
    endp

    ; AL - ghost color (02H verde, 03H ciano, 04H vermelho, 05H magenta)
    ; DI - ghost X pos offset
    PRINT_GHOST proc
        push SI
        push DI
        push BX
        mov SI, offset ghost_mask
        ;mov DI, offset ghost_x_pos
        mov BX, ghosts_line_1_pos_y ; Y
        call PRINT_CHARACTER
        pop BX
        pop DI
        pop SI
        ret
    endp

    PRINT_HUNTER proc
        push SI
        push DI
        push AX
        mov SI, offset hunter_mask
        mov DI, offset hunter_x_pos
        mov BX, 0BEH ; Y
        mov AL, 0EH ; hunter color
        call PRINT_CHARACTER
        pop AX
        pop DI
        pop SI
        ret
    endp

    PRINT_GHOST_LINE_1 proc
        push CX
        push DI
        push AX
        mov CX, 2H
        mov DI, offset ghosts_line_1_pos_x_l
        mov AL, 05H ; ghost color TODO!
        print_ghost_line1:
            call PRINT_GHOST
            add DI, 2 ; next ghost X pos
            loop print_ghost_line1
        pop AX
        pop DI
        pop CX
        ret 
    endp

     ; CX - x
    ; DX - y
    ; BX - color
    WRITE_PIXEL proc
        PUSH_CONTEXT
        push BX
        
        mov BX, 0A000H
        mov ES, BX
        
        ; row + col * 320
        mov AX, DX ; AX = Y
        mov BX, 320
        mul BX ; AX = AX * 320
        add AX, CX ; AX += X
        
        pop BX ; to get color value
        
        mov DI, AX
        mov ES:[DI], BL
        POP_CONTEXT
        ret
    endp
    
    ; Configura a variavel ghost_line_1_direction indicando o sentido do movimento
    CONF_MOVE_GHOST_LINE1:
        push BX
        push ES
        push AX
        push DI
        mov BX, video_mem_addr
        mov ES, BX
        
        ; Se px inicio != preto
            ; entao: setar movimentacao para direita
        mov AX, 1901H
        mov DI, AX
        cmp ES:[DI], 0H
        je NEXT_PX_TEST_LINE1
        mov ghost_line_1_direction, 0H
        
        ; Se px fim != preto
            ; entao: setar movimentacao para esquerda
        NEXT_PX_TEST_LINE1:
        mov AX, 207EH
        mov DI, AX
        cmp ES:[DI], 0H
        je END_PROC_CONF_MOVE_GHOST_LINE1
        mov ghost_line_1_direction, 1H
        
        END_PROC_CONF_MOVE_GHOST_LINE1:
        pop DI
        pop AX
        pop ES
        pop BX
        ret
    endp
    
    ; Realiza o movimento conforme o valor de ghost_line_1_direction
    MOVE_GHOST_LINE1:
        push DS
        PUSH_CONTEXT
      
        ; Caso movimento para esquerda
        cld
        mov SI, 1402H ; terceiro pixel da linha superior (ORIGEM)
        mov DI, 1401H ; segundo pixel da linha superior (DESTINO)

        cmp ghost_line_1_direction, 1H
        je PRE_MOVE_GHOST_LINE1
        
        ; Caso movimento para a direita
        std
        mov SI, 207DH ; antepenultimo pixel da linha (ORIGEM)
        mov DI, 207EH ; penultimo pixel da linha (DESTINO)
        
        
        PRE_MOVE_GHOST_LINE1:
        
        mov BX, video_mem_addr
        mov ES, BX
        mov DS, BX
        
        mov CX, 3200 ; 10 x 320 (10 linhas)
        LOOP_MOVE_GHOST_LINE1:
          movsb ; ES:DI <- DS:SI
          loop LOOP_MOVE_GHOST_LINE1
        
          dbg:
        POP_CONTEXT
        pop DS
        ret
    endp
    
    SETUP_MOUSE proc
        push AX
        mov  AX, 1H  ; show mouse
        int  33H
        pop AX
        ret
    endp
    
    ; retorna: CX - mouse X, AX = 1 clicou, AX = 0 nao clicou
    CHECK_MOUSE_CLICK proc
        push DX
        push BX
        mov AX, 3
        int 33H ; https://stanislavs.org/helppc/int_33-3.html
        
        cmp BX, 2
        jne END_CHECK_MOUSE_CLICK
        
        SHR CX, 1
        mov AX, 1H
        pop BX
        pop DX
        ret
        
        END_CHECK_MOUSE_CLICK:
            xor AX, AX
            pop BX
            pop DX
            ret
    endp
    
    ; TODO
    ; recebe: AX - 1H esquerda, 2H meio, 3H direita
    SHOOT proc
        ret
    endp
   
    ; recebe: AX - 1H ou 0H (atirou ou nao atirou)
    ;         CX - mouse X  
    CHECK_SHOOT proc
        cmp AX, 0H
        je END_SHOOT_PROC
   
        cmp CX, 106
        jbe GO_TO_SHOOT_LEFT
        cmp CX, 212
        jbe GO_TO_SHOOT_MIDDLE
        jmp GO_TO_SHOOT_RIGHT
        
        GO_TO_SHOOT_LEFT:
            mov AX, 1H
            jmp SHOOT_LABEL
            
        GO_TO_SHOOT_MIDDLE:
            mov AX, 2H
            jmp SHOOT_LABEL
            
        GO_TO_SHOOT_RIGHT:
            mov AX, 3H
            jmp SHOOT_LABEL
        
        SHOOT_LABEL:
            call SHOOT    
    
        END_SHOOT_PROC:
        ret    
    endp
    
    ; vai printar os bonecos pela primeira vez em tela
    SETUP_GAME_SCREEN proc
        call WRITE_SCORE_LABEL
        call WRITE_TIME_LABEL
        call PRINT_HUNTER
        call PRINT_GHOST_LINE_1
        call SETUP_MOUSE
        ret
    endp
    
    START_GAME proc
        call CONF_MOVE_GHOST_LINE1
        call MOVE_GHOST_LINE1
        call CHECK_MOUSE_CLICK
        call CHECK_SHOOT
        ret
    endp
    
    main:       
        mov AX, @DATA 
        mov DS, AX  
        mov AX, @DATA 
        mov ES, AX

        SET_VIDEO_MODE
        HIDE_CURSOR
        
        MARK_PLAY_OPTION ; menu inicia com a opcao Jogar selecionada
        xor BX, BX ; inicializar valor de BX para a proc do render_menu
                
        game_loop:
            cmp current_screen, 0H
            je menu
            
            cmp current_screen, 1H
            je game
            
            ; call RENDER_END_GAME
            ;jmp game_loop
            jmp end_prog
            
            menu:
                call RENDER_MENU
                jmp game_loop
                
           game:
                cmp game_1st_render, 01H
                jne game_
                mov game_1st_render, 00H
                call SETUP_GAME_SCREEN
                game_: 
                    call START_GAME
                    call DELAY
                jmp game_loop
            end_prog:
        END_PROGRAM
end main

; [] movimentacao do tiro (lifespan, direcao, colisao, pontuacao)
; [] movimentacao da linha de ghosts na tela inicial
; [] tres linhas de ghosts de linhas diferentes na tela do jogo
; [] mostrar pontuacao real em tela
; [] timer
;       timer inicialmente comeca com 120
;       a cada tick do jogo (500ms em 500ms) o timer ? decrementado em 1
;       quando timer == 0: fim de jogo
; [] tela de fim de jogo
