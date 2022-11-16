.model small     
      
.stack 100H

.data
     titulo db '    ______  _                        ',10,13
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
                               
    tam_titulo  equ $-titulo
    opcoes  db '                  Jogar              ',10,13,10,13
            db '                  Sair               '
    tam_opcoes equ $-opcoes
            
.code
    SALVAR_CONTEXTO macro
        push AX
        push BX
        push CX
        push DX
        push DI
        push SI
        push BP
    endm
    RESTAURAR_CONTEXTO macro
        pop BP
        pop SI
        pop DI
        pop DX
        pop CX
        pop BX
        pop AX
    endm
    INICIALIZAR_VIDEO_MODE macro
        ;https://stanislavs.org/helppc/int_10.html
        mov AH, 00H
        mov AL, 13H
        int 10h
    endm
    ESCONDER_CURSOR macro
        mov cx, 2507h
        mov ah, 01
        int 10h
    endm
    FINALIZAR_PROGRAMA macro
        mov AH, 4CH
        mov AL, 0
        int 21H
    endm
    PRINTAR_TITULO macro
        SALVAR_CONTEXTO
        mov BL, 0AH
        mov CX, tam_titulo
        mov DH, 0
        mov DL, 0
        mov ES:BP, offset titulo
        call print_string
        RESTAURAR_CONTEXTO
    endm
    PRINTAR_OPCOES macro
        SALVAR_CONTEXTO
        mov BL, 0FH
        mov CX, tam_opcoes
        mov DH, 19
        mov DL, 0
        mov ES:BP, offset opcoes
        call print_string
        RESTAURAR_CONTEXTO
    endm
    DECORAR_OPCAO_JOGAR macro
        push DI
        mov DI, offset opcoes
        add DI, 16
        mov [DI], '['
        add DI, 8
        mov [DI], ']'
        pop DI
    endm
    REMOVER_DECORACAO_OPCAO_JOGAR macro
        push DI
        mov DI, offset opcoes
        add DI, 16
        mov [DI], ' '
        add DI, 8
        mov [DI], ' '
        pop DI
    endm
    DECORAR_OPCAO_SAIR macro
        push DI
        mov DI, offset opcoes
        add DI, 57
        mov [DI], '['
        add DI, 8
        mov [DI], ']'
        pop DI
    endm
    REMOVER_DECORACAO_OPCAO_SAIR macro
        SALVAR_CONTEXTO
        mov DI, offset opcoes
        add DI, 57
        mov [DI], ' '
        add DI, 8
        mov [DI], ' '
        RESTAURAR_CONTEXTO
    endm
    
    ; BL cor
    ; CX qtd chars da string
    ; DH linha
    ; DL coluna
    ; ES:BP offset da string
    print_string proc
        push AX
        mov AH, 13H ; set write string
        mov AL, 0 ; set write mode (https://stanislavs.org/helppc/int_10-13.html)
        mov BH, 0H ; set page number
        int 10H
        pop AX
        ret
    endp

    ; a proc atualiza o BL e BH conforme a opcao selecionada 
    verificar_tecla_precionada proc
        push AX
        xor AH, AH
        
        ; https://stanislavs.org/helppc/int_16.html
        mov AH, 01H ; Get keystroke status      
        int 16H ; AH = scan code            
           
        ; comparando somente a parte alta
        cmp AH, 1CH ; Enter
        je tecla_enter
        
        cmp AH, 48H ; Up Arrow
        je tecla_up
        
        cmp AH, 50H ; Down Arrow
        je tecla_down
        
        jmp end_proc_verificar_tecla_precionada
            
        tecla_enter:
            mov BH, 1H
            jmp end_proc_verificar_tecla_precionada
            
        tecla_up:
            mov BL, 0
            DECORAR_OPCAO_JOGAR
            REMOVER_DECORACAO_OPCAO_SAIR
            jmp end_proc_verificar_tecla_precionada
            
        tecla_down:
            mov BL, 1
            DECORAR_OPCAO_SAIR
            REMOVER_DECORACAO_OPCAO_JOGAR
            
        end_proc_verificar_tecla_precionada:
            ; limpando o buffer do teclado
            mov AH,0CH
            mov AL,0
            int 21h
            pop AX
            ret
    endp
    
    inicializar_menu proc
        SALVAR_CONTEXTO
        PRINTAR_TITULO
        DECORAR_OPCAO_JOGAR
        
        xor BX, BX
        ; BL = 0 - Jogar, 1 - Sair
        ; BH = 0 - Enter nao precionado, 1 - Enter precionado
        
        loop_render_menu:
            PRINTAR_OPCOES
            call verificar_tecla_precionada
            
            cmp BH, 0 ; loopar enquanto Enter nao for clicado
            je loop_render_menu
            
        ; nesse ponto aqui a tecla Enter ja foi clicada
        ; agora: seguir o fluxo conforme o valor de BL
        
        RESTAURAR_CONTEXTO
        ret
    endp

    inicio:       
        mov AX, @DATA 
        mov DS, AX  
        mov AX,@DATA 
        mov ES, AX  
         
        INICIALIZAR_VIDEO_MODE
        ESCONDER_CURSOR
        
        call inicializar_menu
              
        FINALIZAR_PROGRAMA
end inicio


















