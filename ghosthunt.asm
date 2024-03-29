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
                            
       end_game db '       _____ _            _          ',10,13
                db '      |   __|_|_____    _| |___      ',10,13
                db '      |   __| |     |  | . | -_|     ',10,13
                db '      |__|  |_|_|_|_|  |___|___|     ',10,13
                db '                                     ',10,13
                db '                                     ',10,13
                db '          __                         ',10,13
                db '       __|  |___ ___ ___             ',10,13
                db '      |  |  | . | . | . |            ',10,13
                db '      |_____|___|_  |___|            ',10,13
                db '                |___|                ',10,13
    end_game_len  equ $-end_game
    
    options  db '                  Jogar              ',10,13,10,13
             db '                  Sair               '
    options_len equ $-options
    current_screen db 0 ; 0 - Menu, 1 - Jogo, 2 - Fim de jogo
    game_1st_render db 1H
    delay_microsecs equ 0C350h ; 50000 microsecs
    
    blank_spaces db '    '

    score_label db 'SCORE: '
    score_col db 7
    score dw 0
    
    time_label db 'TEMPO: '
    time_col db 38
    time dw 1201

    video_mem_addr equ 0A000H
    
    projectile_x dw 9FH
    projectile_y dw 0BBH
    projectile_direction db 0H ; 0H sem projetil ativo, 1H esquerda, 2H meio, 3H direita
    
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
     
     ghost_line_1_direction dw 1H ; 0H - move to right, 1H - move to left
     ghost_line_2_direction dw 0H
     ghost_line_3_direction dw 1H

     ghosts_line_1_pos_y equ 10H
     ghosts_line_2_pos_y equ 1FH
     ghosts_line_3_pos_y equ 2EH

     ghosts_line1_pos_x_l dw 1H, 22H
     ghosts_line2_pos_x_r dw 0F1H, 112H, 133H
     ghosts_line3_pos_x_l dw 1H, 22H, 43H, 64H

    ghost_line1_px_inicio       equ 1901H
    ghost_line1_px_fim          equ 207DH
    ghost_line1_px_origem_esq   equ 1402H
    ghost_line1_px_destino_esq  equ 1401H
    ghost_line1_px_origem_dir   equ 207DH
    ghost_line1_px_destino_dir  equ 207EH

    ghost_line2_px_inicio       equ 2BC1H ; 1901H + 15 linhas
    ghost_line2_px_fim          equ 333DH ; 207DH + 15 linhas
    ghost_line2_px_origem_esq   equ 26C2H ; 1402H + 15 linhas
    ghost_line2_px_destino_esq  equ 26C1H ; 1401H + 15 linhas 
    ghost_line2_px_origem_dir   equ 333DH ; 207DH + 15 linhas
    ghost_line2_px_destino_dir  equ 333EH ; 207EH + 15 linhas

    ghost_line3_px_inicio       equ 3E81H ; 2BC1H + 15 linhas
    ghost_line3_px_fim          equ 45FDH ; 333DH + 15 linhas
    ghost_line3_px_origem_esq   equ 3982H ; 26C2H + 15 linhas
    ghost_line3_px_destino_esq  equ 3981H ; 26C1H + 15 linhas 
    ghost_line3_px_origem_dir   equ 45FDH ; 333DH + 15 linhas
    ghost_line3_px_destino_dir  equ 45FEH ; 333EH + 15 linhas

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

    RENDER_END_GAME_TITLE proc
        PUSH_CONTEXT
        mov AX, @DATA 
        mov ES, AX
        
        mov BL, 0AH
        mov CX, end_game_len
        mov DH, 10
        mov DL, 0
        mov BP, offset end_game
        call PRINT_STRING
        POP_CONTEXT
        ret
    endp

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
            call PRINT_CHAR
            inc DL ; next column
            loop print_char_v_mode 
        POP_CONTEXT  
        ret
    endp

    ; recebe: DL - coluna    
    ;         AL - char
    ;         BL - cor
    PRINT_CHAR proc
        PUSH_CONTEXT
        mov  DH, 0   ; Row (fixo na 0)
        mov  BH, 0    ; Display page
        mov  AH, 02H  ; SetCursorPosition
        int  10H
        mov  BH, 0 ; Display page
        mov  AH, 0EH  ; int 10H - Teletype mode
        int  10H
        POP_CONTEXT
        ret
    endp  

    ; recebe: AX - uint
    ;         DI - offset do valor da coluna
    PRINT_GREEN_UINT16 proc 
        PUSH_CONTEXT
        
        mov BX, 10   ; divisoes sucessivas por 10
        xor CX, CX   ; contador de digitos
        
    LACO_DIV:
        xor DX, DX   ; zerar DX pois o dividendo eh DXAX
        div BX       ; divisao para separar o digito em DX
        
        push DX      ; empilhar o digito
        inc CX       ; incrementa o contador de digitos
        
        cmp AX, 0    ; AX chegou a 0?
        jnz LACO_DIV ; enquanto AX diferente de 0 salte para LACO_DIV
            
    LACO_ESCDIG:   
        pop DX       ; desempilha o digito    
        add DL, '0'  ; converter o digito para ASCII
        
        push AX
        push BX
        push DX

        mov AL, DL
        mov DL, [DI]
        mov BL, 2H ; verde
        call PRINT_CHAR
        inc byte ptr [DI]

        pop DX
        pop BX            
        pop AX

        loop LACO_ESCDIG ; decrementa o contador de digitos
        
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
        mov CX, 7
        call PRINT_STRING_V_MODE
        pop CX
        pop BX
        pop SI
        pop DX
        ret
    endp
    
    WRITE_SCORE proc
        PUSH_CONTEXT
        mov score_col, 7 ; reset na posicao
        
        mov AX, score
        mov DI, offset score_col
        call PRINT_GREEN_UINT16

        POP_CONTEXT
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
        mov CX, 7
        call PRINT_STRING_V_MODE
        pop CX
        pop BX
        pop SI
        pop DX
        ret
    endp
    
    ; recebe: AX - valor do timer
    WRITE_TIME proc
        PUSH_CONTEXT
        mov time_col, 38 ; reset na posicao
        
        cmp AX, 10
        jae PRINT_TIME 
        ; adicionando 0 (zero) a esquerda pq o time agora so tem 1 digito
        push AX
        mov DL, time_col
        mov AL, '0'
        mov BL, 2H
        call PRINT_CHAR
        inc time_col
        pop AX
        
        PRINT_TIME:
        mov DI, offset time_col
        call PRINT_GREEN_UINT16

        POP_CONTEXT
        ret
    endp
    
    UPDATE_TIME proc
        PUSH_CONTEXT
        dec time ; a cada 50ms (tempo do delay) a var time eh decrementada em 1
        cmp time, 0H
        je THE_END
        
        xor DX, DX
        
        ; Se time / 20 eh uma divisao inteira, entao atuailzar o time em tela
        mov AX, time
        mov BX, 20
        div BX
        cmp DX, 0H
        jne END_UPDATE_TIME_PROC ; se nao for divisao inteira, nao atualizar em tela
        
        call WRITE_TIME
        jmp END_UPDATE_TIME_PROC
        
        THE_END:
            call CLEAR_SCREEN
            mov current_screen, 2H
            
        END_UPDATE_TIME_PROC:
        POP_CONTEXT
        ret
    endp
    
    CLEAR_SCREEN proc
        PUSH_CONTEXT
        SET_VIDEO_MODE
        POP_CONTEXT
        ret
    endp
    
    DELAY proc  
        push CX
        push DX
        push AX
        
        xor CX, CX
        mov DX, delay_microsecs
        mov AH, 86H
        int 15H ; http://vitaly_filatov.tripod.com/ng/asm/asm_026.13.html
        
        pop AX
        pop DX
        pop CX
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
    ; BX - ghost line Y
    PRINT_GHOST proc
        push SI
        push DI
        push BX
        mov SI, offset ghost_mask
        call PRINT_CHARACTER
        pop BX
        pop DI
        pop SI
        ret
    endp

    PRINT_HUNTER proc
        PUSH_CONTEXT
        mov SI, offset hunter_mask
        mov DI, offset hunter_x_pos
        mov BX, 0BEH ; Y
        mov AL, 0EH ; hunter color
        call PRINT_CHARACTER
        POP_CONTEXT
        ret
    endp

    ; recebe: AL - cor ghost
    ;         DI - offset linha ghost X
    ;         BX - linha ghost Y
    ;         CX - qtd ghosts
    PRINT_GHOST_LINE proc
        push CX
        push DI
        push AX
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
        
        mov BX, video_mem_addr
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

    ; recebe:  CX - pos X do pixel a ser lido
    ;          DX - pos Y do pixel a ser lido
    ; retorna: BL - cor do pixel lido
    READ_PIXEL proc
        push AX
        push DI
        push ES
        push DX
        push CX

        mov BX, video_mem_addr
        mov ES, BX

        ; row + col * 320
        mov AX, DX ; AX = Y
        mov BX, 320
        mul BX ; AX = AX * 320
        add AX, CX ; AX += X
         
        mov DI, AX
        mov BL, ES:[DI]

        pop CX
        pop DX
        pop ES
        pop DI
        pop AX
        ret
    endp
    
    ; Configura a variavel ghost_line_direction indicando o sentido do movimento da linha
    ; recebe: SI - offset ghost_line_direction da ghost line em questao
    ;         AX - px inicio
    ;         BX - px fim 
    CONF_MOVE_GHOST_LINE proc
        PUSH_CONTEXT
        
        push BX ; salvando
        mov BX, video_mem_addr
        mov ES, BX
        pop BX ; restaurando
        
        ; Se px inicio != preto
            ; entao: setar movimentacao para direita
        mov DI, AX
        mov AX, 0H
        cmp ES:[DI], AX
        je NEXT_PX_TEST_LINE1
        mov word ptr [SI], 0H
        
        ; Se px fim != preto
            ; entao: setar movimentacao para esquerda
        NEXT_PX_TEST_LINE1:
        mov AX, BX ; AX = px do fim
        mov DI, AX
        mov AX, 0H
        cmp ES:[DI], AX
        je END_PROC_CONF_MOVE_GHOST_LINE
        mov word ptr [SI], 1H
        
        END_PROC_CONF_MOVE_GHOST_LINE:
        POP_CONTEXT
        ret
    endp
    
    ; Realiza o movimento conforme o valor de ghost_line_1_direction
    ; recebe: AX - pixel_origem_mov_esquerda (ex: 1402H)
    ;         BX - pixel_destino_mov_esquerda (ex: 1401H)
    ;         CX - pixel_origem_mov_direita (ex: 207DH)
    ;         DX - pixel_destino_mov_direita (ex: 207EH)
    ;         SI - offset ghost_line_direction da ghost line em questao
    MOVE_GHOST_LINE:
        push DS
        PUSH_CONTEXT
      
      
        ; Caso movimento para esquerda
        cld

        ; cmp ghost_line_1_direction, 1H
        cmp word ptr [SI], 1H

        ; mov SI, 1402H ; terceiro pixel da linha superior (ORIGEM)
        mov SI, AX ; terceiro pixel da linha superior (ORIGEM)
        ; mov DI, 1401H ; segundo pixel da linha superior (DESTINO)
        mov DI, BX ; segundo pixel da linha superior (DESTINO)

        je PRE_MOVE_GHOST_LINE ; referente ao "cmp [SI], 1H" a cima
        
        ; Caso movimento para a direita
        std
        ; mov SI, 207DH ; antepenultimo pixel da linha (ORIGEM)
        mov SI, CX ; antepenultimo pixel da linha (ORIGEM)
        ; mov DI, 207EH ; penultimo pixel da linha (DESTINO)
        mov DI, DX ; penultimo pixel da linha (DESTINO)
        
        
        PRE_MOVE_GHOST_LINE:
        
        mov BX, video_mem_addr
        mov ES, BX
        mov DS, BX
        
        mov CX, 3200 ; 10 x 320 (10 linhas)
        LOOP_MOVE_GHOST_LINE:
          movsb ; ES:DI <- DS:SI
          loop LOOP_MOVE_GHOST_LINE

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

        cmp projectile_direction, 0H
        jne END_CHECK_MOUSE_CLICK ; caso ja tenha um disparo em andamento
                                  ; agir como se nao houvesse clique no mouse
        
        shr CX, 1
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
    
    CLEAR_PREV_PROJECTILE proc
        push CX
        push DX
        push BX

        ; sobrescrevemos um quadrado de 3x3 px, onde o px do meio eh a posicao anterior do projetil.

        mov CX, projectile_x
        mov DX, projectile_y
        mov BX, 0H
        call WRITE_PIXEL ; 1,1

        dec DX
        call WRITE_PIXEL ; 1,0
        dec CX
        call WRITE_PIXEL ; 0,0
        inc DX
        call WRITE_PIXEL ; 0,1
        inc DX
        call WRITE_PIXEL ; 0,2
        inc CX
        call WRITE_PIXEL ; 1,2
        inc CX
        call WRITE_PIXEL ; 2,2
        dec DX
        call WRITE_PIXEL ; 2,1
        dec DX
        call WRITE_PIXEL ; 2,0

        pop BX
        pop DX
        pop CX
        ret
    endp

    ; retorna: CX - prox posicao X
    ;          DX - prox posicao Y
    GET_NEXT_PROJECTILE_POSITION_VALUES proc
        mov CX, projectile_x
        mov DX, projectile_y
        sub DX, 2H

        cmp projectile_direction, 2H

        je END_PROC_GNPPV ; meio
        jb PROJ_TO_LEFT
        jmp PROJ_TO_RIGHT

        PROJ_TO_LEFT:
            dec CX
            jmp END_PROC_GNPPV

        PROJ_TO_RIGHT:
            inc CX

        END_PROC_GNPPV:
            ret
    endp
    
    SHOOT proc
        PUSH_CONTEXT
        cmp projectile_direction, 0H
        je END_SHOOT_PROC ; sem disparo ativo

        ; sobrescrevendo a posicao anterior com um px preto
        call CLEAR_PREV_PROJECTILE

        ; CX e DX recebem X e Y da prox posicao do projetil
        call GET_NEXT_PROJECTILE_POSITION_VALUES

        mov projectile_x, CX
        mov projectile_y, DX

        mov BX, 0FH
        call WRITE_PIXEL

        END_SHOOT_PROC:
        POP_CONTEXT
        ret
    endp
   
    ; recebe: AX - 1H ou 0H (atirou ou nao atirou)
    ;         CX - mouse X  
    CHECK_SHOOT proc
        PUSH_CONTEXT

        cmp AX, 0H
        je SHOOT_LABEL ; nao altera a direcao do projetil
   
        cmp CX, 106
        jbe GO_TO_SHOOT_LEFT
        cmp CX, 212
        jbe GO_TO_SHOOT_MIDDLE
        jmp GO_TO_SHOOT_RIGHT
        
        GO_TO_SHOOT_LEFT:
            mov projectile_direction, 1H
            jmp SHOOT_LABEL
            
        GO_TO_SHOOT_MIDDLE:
            mov projectile_direction, 2H
            jmp SHOOT_LABEL
            
        GO_TO_SHOOT_RIGHT:
            mov projectile_direction, 3H
            jmp SHOOT_LABEL
        
        SHOOT_LABEL:
            call SHOOT    
        POP_CONTEXT
        ret    
    endp

    RESET_PROJECTILE proc
        PUSH_CONTEXT
        mov CX, projectile_x
        mov DX, projectile_y
        mov BX, 0H
        call WRITE_PIXEL
        ; resetando variaveis para o estado inicial
        mov projectile_x, 9FH
        mov projectile_y, 0BBH
        mov projectile_direction, 0H
        POP_CONTEXT
        ret
    endp 

    ; recebe: BL - cor do pixel do ghost que foi atingido
    ;         CX - posicao X do projetil
    ;         DX - posicao Y do projetil
    GHOST_HIT proc
        PUSH_CONTEXT
        ; incrementar o score com base na cor de BL
        ; verde - 10, azul - 20, vermelho - 30, roxo - 40
        cmp BL, 2H ; verde
        je GREEN_HIT
        cmp BL, 3H ; azul
        je BLUE_HIT
        cmp BL, 4H ; vermelho
        je RED_HIT
        cmp BL, 5H ; roxo
        je PURPLE_HIT
        jmp REMOVE_GHOST ; qualquer outra cor

        GREEN_HIT:
            add score, 10
            jmp REMOVE_GHOST
        BLUE_HIT:
            add score, 20
            jmp REMOVE_GHOST
        RED_HIT:
            add score, 30
            jmp REMOVE_GHOST
        PURPLE_HIT:
            add score, 40
            jmp REMOVE_GHOST

        REMOVE_GHOST:
        call WRITE_SCORE
        
        mov AX, CX ; AX = X
        sub AX, 15 ; AX = X - 12
        add DX, 8 ; Y += 8
        mov CX, 30 ; contador de cols
        LOOP_CLEAR_COL:
            push DX ; salvando o valor inicial de Y
            mov BX, 0 ; zerando o contador de rows
            LOOP_CLEAR_ROW:
                dec DX ; Y -= 1 (prox row)
                push BX ; salvando BX
                push CX ; salvando CX
                mov BX, 0H
                mov CX, AX ; CX = X
                call WRITE_PIXEL
                pop CX ; restaurando
                pop BX ; restaurando
                inc BX ; prox row
                cmp BX, 18
                jbe LOOP_CLEAR_ROW ; loop ate completar 10 rows
            inc AX ; prox col
            pop DX ; restaurando o valor inicial de Y
            loop LOOP_CLEAR_COL

        END_GHOST_HIT_PROC:
        call RESET_PROJECTILE

        POP_CONTEXT
        ret
    endp

    CHECK_COLISIONS proc
        PUSH_CONTEXT
        cmp projectile_y, 0AH
        jbe GO_TO_RESET_PROJECTILE

        call GET_NEXT_PROJECTILE_POSITION_VALUES
        call READ_PIXEL
        cmp BL, 0H
        je END_CHECK_COLISIONS_PROC ; caso o prox pixel do projetil eh preto nao houve colisao

        call GHOST_HIT
        jmp END_CHECK_COLISIONS_PROC

        GO_TO_RESET_PROJECTILE:
            call RESET_PROJECTILE

        END_CHECK_COLISIONS_PROC:
        POP_CONTEXT
        ret
    endp
    
    ; vai printar os bonecos pela primeira vez em tela
    SETUP_GAME_SCREEN proc
        PUSH_CONTEXT
        call WRITE_SCORE_LABEL
        call WRITE_SCORE

        call WRITE_TIME_LABEL
        call UPDATE_TIME
        
        call PRINT_HUNTER
        
        mov AL, 05H ; magenta
        mov DI, offset ghosts_line1_pos_x_l
        mov BX, ghosts_line_1_pos_y
        mov CX, 2
        call PRINT_GHOST_LINE

        mov AL, 3H ; ciano
        mov DI, offset ghosts_line2_pos_x_r
        mov BX, ghosts_line_2_pos_y
        mov CX, 3
        call PRINT_GHOST_LINE

        mov AL, 2H ; verde
        mov DI, offset ghosts_line3_pos_x_l
        mov BX, ghosts_line_3_pos_y
        mov CX, 4
        call PRINT_GHOST_LINE

        call SETUP_MOUSE
        POP_CONTEXT
        ret
    endp
    
    START_GAME proc
        PUSH_CONTEXT

        ; Movimento linha 1
        mov SI, offset ghost_line_1_direction
        mov AX, ghost_line1_px_inicio
        mov BX, ghost_line1_px_fim
        call CONF_MOVE_GHOST_LINE

        mov AX, ghost_line1_px_origem_esq
        mov BX, ghost_line1_px_destino_esq
        mov CX, ghost_line1_px_origem_dir
        mov DX, ghost_line1_px_destino_dir
        mov SI, offset ghost_line_1_direction
        call MOVE_GHOST_LINE

        ; Movimento linha 2
        mov SI, offset ghost_line_2_direction
        mov AX, ghost_line2_px_inicio
        mov BX, ghost_line2_px_fim
        call CONF_MOVE_GHOST_LINE

        mov AX, ghost_line2_px_origem_esq
        mov BX, ghost_line2_px_destino_esq
        mov CX, ghost_line2_px_origem_dir
        mov DX, ghost_line2_px_destino_dir
        mov SI, offset ghost_line_2_direction
        call MOVE_GHOST_LINE

        ; Movimento linha 3
        mov SI, offset ghost_line_3_direction
        mov AX, ghost_line3_px_inicio
        mov BX, ghost_line3_px_fim
        call CONF_MOVE_GHOST_LINE

        mov AX, ghost_line3_px_origem_esq
        mov BX, ghost_line3_px_destino_esq
        mov CX, ghost_line3_px_origem_dir
        mov DX, ghost_line3_px_destino_dir
        mov SI, offset ghost_line_3_direction
        call MOVE_GHOST_LINE


        call CHECK_MOUSE_CLICK
        call CHECK_SHOOT
        call CHECK_COLISIONS
        POP_CONTEXT
        ret
    endp

    RENDER_END_GAME proc
        PUSH_CONTEXT
        call RENDER_END_GAME_TITLE
        
        call WRITE_SCORE_LABEL
        call WRITE_SCORE

        POP_CONTEXT
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
            
            call RENDER_END_GAME
            jmp game_loop
            
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
                    call UPDATE_TIME
                jmp game_loop
            end_prog:
        END_PROGRAM
end main

