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
    
    score_label db 'Score: '$
    score dw 0H
    
    time_label db 'Tempo: '$
    time db 60
    
    hunter dw 099H,0BBH ;x,y
    hunter_pos dw 99H,0BEH ;x,y
    hunter_mask db 0DH,0DH,0DH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0DH,0DH
                db 0DH,0DH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH
                db 0DH,0EH,0EH,0DH,0DH,0EH,0EH,0EH,0EH,0EH,0EH,0DH
                db 0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0DH,0DH,0DH
                db 0EH,0EH,0EH,0EH,0EH,0EH,0DH,0DH,0DH,0DH,0DH,0DH
                db 0EH,0EH,0EH,0EH,0EH,0EH,0DH,0DH,0DH,0DH,0DH,0DH
                db 0EH,0EH,0EH,0EH,0EH,0EH,0EH,0DH,0DH,0DH,0DH,0DH
                db 0DH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0DH,0DH,0DH
                db 0DH,0DH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH
                db 0DH,0dH,0DH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0DH
     
     ghost_pos dw 10H,10H
     ghost_mask db 0DH,0DH,0DH,0EH,0EH,0EH,0EH,0EH,0EH,0DH,0DH,0DH
                db 0DH,0DH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0DH,0DH
                db 0DH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0DH
                db 0EH,0EH,0EH,0DH,0DH,0EH,0EH,0DH,0DH,0EH,0EH,0EH
                db 0EH,0EH,0EH,0DH,0DH,0EH,0EH,0DH,0DH,0EH,0EH,0EH
                db 0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH
                db 0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH
                db 0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH,0EH
                db 0EH,0EH,0EH,0DH,0EH,0EH,0EH,0EH,0DH,0EH,0EH,0EH
                db 0DH,0EH,0DH,0DH,0DH,0EH,0EH,0DH,0DH,0DH,0EH,0DH            
                
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
        mov ES:BP, offset game_title
        call PRINT_STRING
        POP_CONTEXT
    endm
    RENDER_OPTIONS macro
        PUSH_CONTEXT
        mov BL, 0FH
        mov CX, options_len
        mov DH, 19
        mov DL, 0
        mov ES:BP, offset options
        call PRINT_STRING
        POP_CONTEXT
    endm
    MARK_PLAY_OPTION macro
        push DI
        mov DI, offset options
        add DI, 16
        mov [DI], '['
        add DI, 8
        mov [DI], ']'
        pop DI
    endm
    UNMARK_PLAY_OPTION macro
        push DI
        mov DI, offset options
        add DI, 16
        mov [DI], ' '
        add DI, 8
        mov [DI], ' '
        pop DI
    endm
    MARK_QUIT_OPTION macro
        push DI
        mov DI, offset options
        add DI, 57
        mov [DI], '['
        add DI, 8
        mov [DI], ']'
        pop DI
    endm
    UNMARK_QUIT_OPTION macro
        push DI
        mov DI, offset options
        add DI, 57
        mov [DI], ' '
        add DI, 8
        mov [DI], ' '
        pop DI
    endm

    ; SI - mask offset
    ; DX - Y
    ; CX - X
    PRINT_CHARACTER_LINE proc
        PUSH_CONTEXT
        
        mov BX, 0A000H
        mov ES, BX
        
        ; row + col * 320
        mov AX, DX ; AX = Y
        mov BX, 320
        mul BX ; AX = AX * 320
        add AX, CX ; AX += X
    
        mov CX, 12
        mov DI, AX
        loop_str:       
            lodsb           ; AL = SI 
            mov ES:[DI],AL  ; write pixel
            inc DI
            
            loop loop_str 
        POP_CONTEXT
        ret
    endp
    
    ; DI - pos offset
    ; SI - mask offset
    PRINT_CHARACTER proc
        push CX
        push DX
        
        mov CX, [DI] ; x
        mov DX, [DI+2] ; y
        call PRINT_CHARACTER_LINE ; line 1
        inc DX
        add SI, 12
        call PRINT_CHARACTER_LINE ; line 2
        inc DX
        add SI, 12
        call PRINT_CHARACTER_LINE ; line 3
        inc DX
        add SI, 12
        call PRINT_CHARACTER_LINE ; line 4
        inc DX
        add SI, 12
        call PRINT_CHARACTER_LINE ; line 5
        inc DX
        add SI, 12
        call PRINT_CHARACTER_LINE ; line 6
        inc DX
        add SI, 12
        call PRINT_CHARACTER_LINE ; line 7
        inc DX
        add SI, 12
        call PRINT_CHARACTER_LINE ; line 8
        inc DX
        add SI, 12
        call PRINT_CHARACTER_LINE ; line 9
        inc DX
        add SI, 12
        call PRINT_CHARACTER_LINE ; line 10
        inc DX
        add SI, 12
        
        pop DX
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
    
    CLEAR_SCREEN proc ; TODO
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
        mov dx, 0C350h ; 50000 microsecs
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
            
        end_render_menu:
        POP_CONTEXT
        ret
    endp
    
    CHECK_MOUSE_CLICK proc ; TODO
        push CX
        push AX
        push BX
        push DX
        xor CX, CX ; mouse X
        mov AX, 03H
        int 33H ; https://stanislavs.org/helppc/int_33-3.html
        test BL, 2
        jnz RIGHT_BTN_CLICK
        jmp end_CHECK_MOUSE_CLICK
        
        RIGHT_BTN_CLICK:
            SHR CX, 1 ; https://stackoverflow.com/questions/51001655/how-to-get-mouse-position-in-assembly-tasm 
            mov BX, 0DH
            mov DX, 50H
            call WRITE_PIXEL
            inc hunter_pos
            
        end_CHECK_MOUSE_CLICK:
        pop DX
        pop BX
        pop AX
        pop CX
        ret
    endp
    
    RENDER_GAME proc
        PUSH_CONTEXT
        
        mov SI, offset ghost_mask
        mov DI, offset ghost_pos
        call PRINT_CHARACTER
        
        mov SI, offset hunter_mask
        mov DI, offset hunter_pos
        call PRINT_CHARACTER
        
        call CHECK_MOUSE_CLICK
        
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
                call CLEAR_SCREEN
                call RENDER_GAME
                call DELAY
                jmp game_loop

            end_prog:
        END_PROGRAM
end main
