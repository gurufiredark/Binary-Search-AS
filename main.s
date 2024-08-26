.section .data
    menu_prompt:     .asciz "\nEscolha uma opção:\n1 - Maiores e menores com valor pivô\n2 - Buscar elemento no vetor (Busca Binária)\n3 - Sair\nOpção: "
    prompt_valor:    .asciz "Digite um valor: "
    prompt_pivo:     .asciz "Digite o valor pivô: "
    msg_menores:     .asciz "Valores menores ou iguais ao pivô: "
    msg_maiores:     .asciz "Valores maiores que o pivô: "
    prompt_qtd:      .asciz "Digite a quantidade de elementos: "
    prompt_elem:     .asciz "Digite o elemento %d: "
    prompt_busca:    .asciz "Digite o valor a ser buscado: "
    msg_encontrado:  .asciz "Elemento encontrado! Índice: %d, Valor: %f\n"
    msg_nao_encontrado: .asciz "Elemento não encontrado.\n"
    msg_ordenando:   .asciz "Ordenando o vetor...\n"
    msg_vetor_ordenado: .asciz "Vetor ordenado: "
    format_int:      .asciz "%d"
    format_float:    .asciz "%f"
    format_out:      .asciz "%f "
    newline:         .asciz "\n"

    .align 4
    valores:         .space 32    # 8 floats (4 bytes cada)
    menores:         .space 32
    maiores:         .space 32
    pivo:            .space 4     # Espaço para armazenar o pivô (float)
    qtd:             .space 4
    busca:           .space 4
    vetor:           .space 400   # Espaço para até 100 floats
    opcao:           .space 4     # Opção do menu

.section .text
.globl main

main:
    pushl %ebp
    movl %esp, %ebp

menu_loop:
    # Exibir menu e ler opção
    pushl $menu_prompt
    call printf
    addl $4, %esp

    pushl $opcao
    pushl $format_int
    call scanf
    addl $8, %esp

    # Verificar opção escolhida
    movl opcao, %eax
    cmpl $1, %eax
    je opcao_pivo
    cmpl $2, %eax
    je opcao_busca
    cmpl $3, %eax
    je fim_programa

    jmp menu_loop  # Opção inválida, voltar ao menu

opcao_pivo:
    call maiores_menores_pivo
    jmp menu_loop

opcao_busca:
    call busca_binaria
    jmp menu_loop

maiores_menores_pivo:
    pushl %ebp
    movl %esp, %ebp

    # Ler 8 valores
    movl $0, %esi
ler_loop_pivo:
    pushl $prompt_valor
    call printf
    addl $4, %esp

    leal valores(, %esi, 4), %eax
    pushl %eax
    pushl $format_float
    call scanf
    addl $8, %esp

    incl %esi
    cmpl $8, %esi
    jl ler_loop_pivo

    # Ler valor pivô
    pushl $prompt_pivo
    call printf
    addl $4, %esp

    pushl $pivo
    pushl $format_float
    call scanf
    addl $8, %esp

    # Inicializar contadores
    xorl %esi, %esi  # índice para valores
    xorl %edi, %edi  # índice para menores
    xorl %ebx, %ebx  # índice para maiores

comparar_loop:
    flds pivo
    flds valores(, %esi, 4)
    fcomip %st(1), %st
    fstp %st(0)
    jbe menor_igual

maior:
    flds valores(, %esi, 4)
    fstps maiores(, %ebx, 4)
    incl %ebx
    jmp prox_valor

menor_igual:
    flds valores(, %esi, 4)
    fstps menores(, %edi, 4)
    incl %edi

prox_valor:
    incl %esi
    cmpl $8, %esi
    jl comparar_loop

    # Imprimir valores menores ou iguais
    pushl $msg_menores
    call printf
    addl $4, %esp

    xorl %esi, %esi
print_menores:
    cmpl %edi, %esi
    jge fim_menores
    flds menores(, %esi, 4)
    subl $8, %esp
    fstpl (%esp)
    pushl $format_out
    call printf
    addl $12, %esp
    incl %esi
    jmp print_menores

fim_menores:
    pushl $newline
    call printf
    addl $4, %esp

    # Imprimir valores maiores
    pushl $msg_maiores
    call printf
    addl $4, %esp

    xorl %esi, %esi
print_maiores:
    cmpl %ebx, %esi
    jge fim_maiores
    flds maiores(, %esi, 4)
    subl $8, %esp
    fstpl (%esp)
    pushl $format_out
    call printf
    addl $12, %esp
    incl %esi
    jmp print_maiores

fim_maiores:
    pushl $newline
    call printf
    addl $4, %esp

    leave
    ret

busca_binaria:
    pushl %ebp
    movl %esp, %ebp

    # Solicitar quantidade de elementos
    pushl $prompt_qtd
    call printf
    addl $4, %esp

    pushl $qtd
    pushl $format_int
    call scanf
    addl $8, %esp

    # Ler elementos do vetor
    movl $0, %esi    # contador
ler_loop_busca:
    pushl %esi
    pushl $prompt_elem
    call printf
    addl $8, %esp

    leal vetor(, %esi, 4), %eax
    pushl %eax
    pushl $format_float
    call scanf
    addl $8, %esp

    incl %esi
    cmpl qtd, %esi
    jl ler_loop_busca

    # Avisar que está ordenando
    pushl $msg_ordenando
    call printf
    addl $4, %esp

    # Ordenar o vetor (bubble sort)
    movl qtd, %ecx
    decl %ecx        # número de passagens
    
outer_loop:
    pushl %ecx       # Salvar o contador de passagens
    movl $0, %esi    # índice atual
    
inner_loop:
    movl %esi, %edi
    incl %edi        # próximo índice
    cmpl qtd, %edi
    jge next_outer
    
    flds vetor(, %esi, 4)
    flds vetor(, %edi, 4)
    fcomip %st(1), %st  # Compara vetor[i+1] com vetor[i]
    fstp %st(0)
    jae no_swap         # Se vetor[i+1] >= vetor[i], não troca
    
    # Trocar elementos
    flds vetor(, %esi, 4)
    flds vetor(, %edi, 4)
    fstps vetor(, %esi, 4)
    fstps vetor(, %edi, 4)
    
no_swap:
    incl %esi
    jmp inner_loop

next_outer:
    popl %ecx        # Restaurar o contador de passagens
    loop outer_loop

    # Imprimir vetor ordenado
    pushl $msg_vetor_ordenado
    call printf
    addl $4, %esp

    xorl %esi, %esi
imprimir_vetor:
    cmpl qtd, %esi
    jge fim_imprimir_vetor
    flds vetor(, %esi, 4)
    subl $8, %esp
    fstpl (%esp)
    pushl $format_out
    call printf
    addl $12, %esp
    incl %esi
    jmp imprimir_vetor

fim_imprimir_vetor:
    pushl $newline
    call printf
    addl $4, %esp

    # Solicitar valor a ser buscado
    pushl $prompt_busca
    call printf
    addl $4, %esp

    pushl $busca
    pushl $format_float
    call scanf
    addl $8, %esp

    # Realizar busca binária
    movl $0, %esi        # início
    movl qtd, %edi
    decl %edi            # fim

busca_loop:
    cmpl %edi, %esi
    jg nao_encontrado

    movl %esi, %eax
    addl %edi, %eax
    shrl $1, %eax        # meio = (início + fim) / 2

    # Comparação de floats
    flds vetor(, %eax, 4)
    flds busca
    fcomip %st(1), %st
    fstp %st(0)
    je encontrado        # Se igual, encontramos
    ja maior_busca

    # Se for menor
    leal -1(%eax), %edi   # fim = meio - 1
    jmp busca_loop

maior_busca:
    leal 1(%eax), %esi    # início = meio + 1
    jmp busca_loop

encontrado:
    # Elemento encontrado, preparar para imprimir
    flds vetor(, %eax, 4)
    subl $8, %esp
    fstpl (%esp)     # Valor encontrado
    pushl %eax       # Índice encontrado
    pushl $msg_encontrado
    call printf
    addl $16, %esp
    jmp fim_busca

nao_encontrado:
    pushl $msg_nao_encontrado
    call printf
    addl $4, %esp

fim_busca:
    leave
    ret

fim_programa:
    # Syscall para sair
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
    