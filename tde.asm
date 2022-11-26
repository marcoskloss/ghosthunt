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
    current_screen db 0 ; 0 - Menu, 1 - Jogo, 2 - Fim de jogo
    screen_width dw 13FH
    screen_height dw 0C7H
    
    score_label db 'Score: 50' ; TODO
    score dw 0
    
    time_label db 'Tempo: 60' ; TODO
    time db 60
    
    hunter dw 099H,0BBH ;x,y
    hunter_pos dw 99H,0BEH ;x,y
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
     
     ghost_pos dw 10H,10H
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
    PRINT_CHARACTER_LINE proc
        PUSH_CONTEXT
        ; row + col * 320
        mov AX, BX ; AX = Y
        
        mov BX, 0A000H
        mov ES, BX
        
        mov BX, 320
        push DX ; mul altera o valor de DX
        mul BX ; AX = AX * 320
        pop DX
        add AX, DX ; AX += X
    
        mov CX, 12
        mov DI, AX
        loop_str_v2:       
            lodsb           ; AL = SI 
            mov ES:[DI],AL  ; write pixel
            inc DI
            loop loop_str_v2 
        POP_CONTEXT
        ret
    endp
    
    ; DI - pos offset
    ; SI - mask offset
    PRINT_CHARACTER proc
        PUSH_CONTEXT
        mov DX, [DI] ; x
        mov BX, [DI+2] ; y
        mov CX, 12
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
    
    WRITE_SCORE_LABEL proc ; TODO
    endp
    
    WRITE_TIME_LABEL proc ; TODO
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
        int 15h
        
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
    
    ; retorna: CX - mouse X, DX - mouse Y, AX = 1 clicou, AX = 0 nao clicou
    ; TODO
    CHECK_MOUSE_CLICK proc ; TODO
    endp

    PRINT_GHOST proc
        push SI
        push DI
        mov SI, offset ghost_mask
        mov DI, offset ghost_pos
        call PRINT_CHARACTER
        pop DI
        pop SI
        ret
    endp

    PRINT_HUNTER proc
        push SI
        push DI
        mov SI, offset hunter_mask
        mov DI, offset hunter_pos
        call PRINT_CHARACTER
        pop DI
        pop SI
        ret
    endp
    
    START_GAME proc
        PUSH_CONTEXT
        
        ;call PRINT_GHOST
        ;call PRINT_HUNTER
        ;call CHECK_MOUSE_CLICK

        POP_CONTEXT
        ret
    endp
    
    main:       
        mov AX, @DATA 
        mov DS, AX  
        mov AX,@DATA 
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
                ;call START_GAME
                ;call DELAY
                ; printando o SCORE LABEL
                mov DL, 0
                mov SI, offset score_label
                mov BL, 0FH
                mov CX, 9
                call PRINT_STRING_V_MODE
                ; printando o TIME LABEL
                mov DL, 31
                mov SI, offset time_label
                call PRINT_STRING_V_MODE
                call PRINT_HUNTER
                call PRINT_GHOST
                jmp game_loop
            end_prog:
        END_PROGRAM
end main
; PARA FAZER A MOVIMEMTACAO DOS GHOSTS:
; NAO EH NECESSARIO UMA PROC PRA APAGAR A TELA INTEIRA!
; fazer: DI recebe a prox posicao (x) e SI tem a posicao atual (x)]
; EX: DI = 50 SI = 51 (escrever todos os ghosts partindo de DI=50, andar?o 1px pra tr?s
; para fazer isso ? necess?rio mover todas as 10 linhas de 320px cada para SI
; EX: mov CX, 3200 (os 3200 px das 10 linhas da tela onde est?o os ghosts)
;     rep stosw ou loadsw seil? qual (o certo eh aquele que faz [DI] = [SI]