.data
blank: .asciiz "\n\n"
msg1: .asciiz "----- BEM-VINDO | A CIFRA DE CÉSAR -----\n\n"
msg2: .asciiz "\nResultado do texto: "
msg5: .asciiz "\nDigite o valor do fator: "
msg6: .asciiz "\nDigite uma opção:\n(1) Criptografar\n(2) Descriptografar\nOPÇÃO: "
msg7: .asciiz "\nDigite o nome do arquivo a ser aberto: "
msg8: .asciiz "Digite uma opção:\n(1) Abrir texto e parâmetros do arquivo\n(2) Digitar texto e parâmetros\nOPÇÃO: "
msg9: .asciiz "\nDigite o texto: "
msg10: .asciiz "\nSaída impressa no arquivo output.txt\n"
filename: .space 1024                 # declara o espaço para o nome do arquivo (1024 bytes reservados)
output: .asciiz "output.txt"
texto: .space 1024           	      # declara o espaço para o texto a ser lido (1024 bytes reservados)

.text
	.globl main

main: 

li $t3, 1                    # declaração para uso de comparação nas opções
li $a3, 32                   # declaração para uso de comparação do caracter espaço

li $v0, 4                    # carrega o id 4 em $v0 para imprimir string
la $a0, msg1                 # imprime a string de boas-vindas
syscall

ler_opcao_leitura:
la $a0, msg8		        # carrega a mensagem de opções de leitura
syscall
li $v0, 5                       # carrega o id 4 em $v0 para ler um inteiro
syscall
add $s0, $v0, $zero             # guarda o inteiro recebido em $s0 (uso nas opções)
beq $s0, $t3, main_arquivo      # caso seja 1, vai para o main de leitura de arquivo
addi $t3, $t3, 1                # adiciona mais 1 para comparação
beq $s0, $t3, main_input        # caso seja 2, vá para adição de parâmetros pelo usuário

main_input:
jal ler_opcao			# lê as opções de operação do texto
jal ler_texto                   # pula para a leitura do texto
jal limpar_texto                # limpa o último caracter do texto
la $t1, texto 		        # carrega o endereço da string colocada em em $t1
jal ler_fator                   # pula para a leitura do fator
addi $t3, $zero, 1              # adiciona 1 para $t3 para fins de comparação
beq $s0, $t3, criptografa       # caso a opção em $s0 seja 1, pula para criptografia 
addi $t3, $t3, 1                # adiciona 1 ao registrador $t3 para comparação
beq $s0, $t3, descriptografa    # caso a opção em $s0 seja 2, pula para descriptografia

main_arquivo:
jal ler_arquivo                 # pula para a leitura do arquivo
jal limpar_nome		        # pula para limpar o caracter do nome
jal leitura                     # chama a função de leitura do arquivo para encriptar/desencriptar 
jal ler_opcao_arquivo           # chama a função para ler se o arquivo é para encriptar/desencriptar 
jal ler_fator_arquivo           # lê o fator do arquivo em caso de desencriptação 
jal refatorar_texto_arquivo     # retira os parâmetros do texto 
add $s5, $zero, $t3             # adiciona o valor de $t3 em $s5 para verificar mais tarde se é leitura de arquivo
addi $t3, $zero, 1              # adiciona 1 em $t3 para fins de comparação
beq $s6, $t3, criptografa       # caso opção 1: criptografar mensagem
addi $t3,$t3,1			# adiciona 1 para verificação
beq $s6, $t3, descriptografa    # caso opção 2:  descriptografa mensagem

ler_opcao_arquivo:
li $t8, 0                       # carrega 0 para utilizar no loop
li $t9, 1024			# carrega 1024 para utilizar no loop
ler1:
lb $s1, texto($t8)		# carrega a posição de $t8 de filename em $t4
beq $s1, $a3, L1                # caso seja encontrado um espaço, pula para L1
addi $t8, $t8, 1                # adiciona 1 para $t8 para continuar o loop
j ler1                          # caso o loop tenha terminado, pula para ler1
L1:
sub $t8, $t8, 1                 # subtrai uma posição de $t8 para usar um carácter anterior ao fim do loop
lb $s6, texto($t8)              # adiciona o texto em $s6
subi $s6, $s6, 48               # transforma o carácter de ascii para decimal 
jr $ra                          # volta para onde a função foi chamada

ler_fator_arquivo:
addi $t8, $zero, 2              # adiciona 2 ao registrador $t8 para fins de comparação
lb $s1, texto($t8)              # adiciona em $s1 a posição $t8 do texto
subi $s1, $s1, 48               # transforma o caracter de ascii para decimal
add $t4, $zero, $s1             # adiciona $s1 em $t4 para uso posterior
li $t9, 0                       # adiciona 0 para iniciar o loop
li $s7, 9                       # adiciona 9 para identificar o fim do loop
L4:
addi $t9, $t9, 1                # adiciona 1 para iniciar o loop
add $s1, $s1, $t4               # adiciona o valor de $t4 a $s1, multiplicando a casa da dezena do número
bne $t9, $s7, L4                # volta para o início do loop
L2:
add $s5,$zero,$s1               # adiciona o valor de $s1 em $s5
addi $t8, $t8, 1                # adiciona a posição 1 para $t8
lb $s1, texto($t8)              # adiciona em $s1 a posição $t8 do texto
subi $s1, $s1, 48               # transforma o caracter de ascii para decimal
add $s1, $s1, $s5               # soma a casa da dezena com a das unidades
jr $ra                          # retorna para onde a função foi chamada

refatorar_texto_arquivo:
li $t8, 0                        # adiciona 0 a $t8 para inicio do loop
li $s7, 5                        # adiciona 5 a $s7 para identificar o fim do loop
refatora:
sb $zero, texto($t8)             # Atribui zero ao byte $t8 do texto
addi $t8, $t8, 1                 # adiciona 1 para continuar o loop
bne $t8, $s7, refatora           # caso ainda esteja dentro do intervalo, continua com o loop
la $t1, texto 		         # carrega em $t1 o endereço inicial do texto
addi $t1, $t1, 5                 # adiciona 5 posições a $t1
jr $ra                           # retorna para o local onde foi chamado

ler_texto:
li $v0, 4		        # adiciona 4 ao registrador para imprimir uma mensagem
la $a0, msg9			# imprime a mensagem pedindo para colocar o texto
syscall			
li $v0, 8			# adiciona 8 ao registrador para que o usuário digite uma string
li $a1, 1024			# reserva o espaço para a string
la $a0, texto			# chama a string para digitar
syscall
jr $ra				# retorna para a função em que foi chamada

ler_arquivo:
li $v0, 4                       # adiciona 4 para imprimir uma mensagem
la $a0, msg7			# imprime a mensagem requisitando o nome do arquivo
syscall		
li $v0, 8			# adiciona 8 ao registrador para que o usuário digite uma string
la $a0, filename	 	# chama a string para a impressão
li $a1, 1024                    # reserva espaço para a string
syscall
jr $ra				# retorna para a função em que foi chamada

limpar_nome:
li $t8, 0                       # carrega 0 para utilizar no loop
li $t9, 1024			# carrega 1024 para utilizar no loop
limpar_1:
beq $t8, $t9, L5                # caso os dois registradores estejam iguais, sair do loop
lb $t4, filename($t8)		# carrega a posição de $t8 de filename em $t4
bne $t4, 0x0a, L6		# caso não ache o caracter 0x0a, pule para L6
sb $zero, filename($t8)		# caso ache, basta zerar a posição
L5:
jr $ra				# retorna para a função onde foi chamada
L6:
addi $t8, $t8, 1		# adiciona 1 para voltar ao início do loop
j limpar_1			# retorna ao loop

limpar_texto:
li $t8, 0                       # carrega 0 para utilizar no loop
li $t9, 1024			# carrega 1024 para utilizar no loop
limpar_2:
beq $t8, $t9, L5_2              # caso os dois registradores estejam iguais, sair do loop
lb $t4, texto($t8)		# carrega a posição de $t8 de filename em $t4
bne $t4, 0x0a, L6_2		# caso não ache o caracter 0x0a, pule para L6
sb $zero, texto($t8)		# caso ache, basta zerar a posição
L5_2:
jr $ra				# retorna para a função onde foi chamada
L6_2:
addi $t8, $t8, 1		# adiciona 1 para voltar ao início do loop
j limpar_2			# retorna ao loop

ler_fator:
li $v0, 4		        # adiciona 4 ao registrador para imprimir uma mensagem
la $a0, msg5                    # imprime a pergunta sobre o fator
syscall
li $v0, 5                       # carrega a leitura sobre o fator
syscall
add $s1, $v0, $zero             # adiciona o fator em $s1
jr $ra			        # retorna para a função que foi chamada

ler_opcao:
li $v0,4                        # carrega a impressão de string
la $a0, msg6 		        # imprime a mensagem de opções
syscall
li $v0, 5                       # carrega o id 4 em $v0 para ler um inteiro
syscall
add $s0, $v0, $zero             # guarda o inteiro recebido em $s0 (uso nas opções)
jr $ra

leitura:
li $v0, 13          	      # move o id 13 no registrador para abrir o arquivo
li $a1, 0           	      # flag de "read" para o arquivo
la $a0, filename              # load no nome do arquivo
add $a2, $zero, $zero         # modo de arquivo (não utilizado)
syscall
move $a0, $v0       	      # load no descritor de arquivos
li $v0, 14                    # move o id 14 no registrador para ler o arquivo
la $a1, texto                 # aloca espaço para os bytes lidos
li $a2, 1024                  # número de bytes a serem lidos
syscall  
la $t1, texto 		      # carrega o endereço da string colocada em em $t1
jr $ra                        #retorna para o endereço de memória onde a função foi chamada

descriptografa: 
addi $t0, $zero, -94               # utilizado para voltar quando atingir o final da tabelas ascii
addi $s6, $zero, -26               # negativa os registradores de contagem de letras para fins de descriptografia
addi $s7, $zero, -10		   # negativa os registradores de contagem de números para fins de descriptografia

sub $s1, $zero, $s1                # negativa o fator 
add $a2, $zero, $s1                # armazena o fator em $a2 para ser utilizado na comparação com números

arruma_fator_negativo:
slti $t7, $s1, -27	    		           # compara se o fator está dentro do intervalo dos negativos de -27 à -99
slti $t6, $s1, -99	   		           # compara se o fator está dentro do intervalo dos negativos de -27 à -99
beq $t7, $t6, arruma_fator_numero_negativo         # caso esteja, pula para arrumar o fator dos números negativos
addi $s1, $s1, 26                                  # adiciona-se 26 para que o fator possa operar no alfabeto
j arruma_fator_negativo

arruma_fator_numero_negativo:
add $s4, $zero, $a2                                # utiliza-se do fator guardando em $a2
arruma_2:
slti $t7, $s4, -11	    		           # compara se o fator está dentro do intervalo dos negativos de -11 à -99
slti $t6, $s4, -99                                 # compara se o fator está dentro do intervalo dos negativos de -11 à -99
beq $t7, $zero, criptografa_1                      # caso esteja, pula para a criptografia
addi $s4, $s4, 10                                  # caso não, adiciona-se 10 para que possa operar nos numerais
j arruma_2


criptografa: 
li $s6, 26		                        # declaração para uso na criptografia de letras
li $s7, 10		                        # declaração para uso na criptografia de números
li $t0, 94                                      # usado para avançar quando atingir o começo da tabela ascii
add $a2, $zero, $s1                             # armazena o fator em $a2 para ser utilizado na comparação com números         
arruma_fator:
slti $t7, $s1, 27                               # verificar se o fator está acima de 26
bne $t7, $zero, arruma_fator_numero             # caso não, pula para arrumar o fator para numerais
subi $s1, $s1, 26                               # caso sim, subtrai-se 26 para que possa operar no alfabeto 
j arruma_fator

arruma_fator_numero: 
add $s4, $zero, $a2                            # utiliza-se do fator guardando em $a2
arruma:
slti $t7, $s4, 11                              # verifica se o fator está acima de 10
bne $t7, $zero, criptografa_1                  # caso não, pula para criptografia
subi $s4, $s4, 10                              # caso sim, subrai-se 10 para que possa operar nos numerais
j arruma

criptografa_1:
lb $t2, 0($t1)		   		   # carrega o endereço de memória de $t1 em $t2
beq $t2, $zero, imprime_1 	           # pula para o fim do FOR quando o contador for 0
beq $t2, $a3, parte2        		   # caso o caracter for um espaço, pula para parte2	
slti $t7, $t2, 58	    		   # compara se o caracter está dentro do espaço de números da tabela
slti $t6, $t2, 48	   		   # compara se o caracter está dentro do espaço de números da tabela
bne $t7, $t6, numeros	    		   # caso esteja, pula para numeros													
slti $t7, $t2, 123		           # compara se o caracter está dentro do espaço de letras minúsculas da tabela
slti $t6, $t2, 97			   # compara se o caracter está dentro do espaço de letras minúsculas da tabela
bne $t7, $t6, letras_minusculas            # caso esteja, pula para letras_minusculas
slti $t7, $t2, 65			   # compara se o caracter está dentro do espaço de letras maiúsculas da tabela
slti $t6, $t2, 91		           # compara se o caracter está dentro do espaço de letras maiúsculas da tabela
bne $t7, $t6, letras_maiusculas	           # caso esteja, pula para letras_maiusculas

add $t2, $t2, $s1                          # caso não seja nenhum dos acimas, é um caracter especial, logo adiciona-se um fator ao
                                           # caracter

slti $t7, $t2, 58       # caso esteja entre nos números cardiais   
slti $t6, $t2, 48       # pula-se para a função
bne $t7, $t6, add1      # add1

slti $t7, $t2, 123      # caso esteja entre as letras minúsculas 
slti $t6, $t2, 97       # pula-se para a função
bne $t7, $t6, add2      # add2
 
slti $t7, $t2, 91      # caso esteja entre as letras maiúsculas 
slti $t6, $t2, 65      # pula-se para a função
bne $t7, $t6, add2     #add2

slti $t7, $t2, 126     # caso tenha atingido o final dos caractéres imprimiveis 
slti $t6, $t2, 250     # pula-se para a função
bne $t7, $t6, add3     # add3

slti $t7, $t2, 1       # caso antes do intervalo dos caracteres imprimiveis 
slti $t6, $t2, 33      # pula-se para a função
bne $t7, $t6, add3     # add3

j parte2

add1:
add $t2, $t2, $s7      # soma-se ou subtrai-se 10 do caracter
j parte2               # pula para parte2

add2:
add $t2, $t2, $s6      # soma-se ou subtrai-se 26 do caracter
j parte2               # pula para parte2

add3:
sub $t2, $t2, $t0      # soma-se ou subtrai-se 94 do caracter
j parte2               # pula para parte2

letras_maiusculas:
add $t2, $t2, $s1         		  # adicione 3 posições ao registrador
slti $t7, $t2, 91			  # verífica se o caracter passou de Z
beq $t7, $zero, diminui_maiuscula         # caso tenha passado, pula para diminui_maiuscula
slti $t7, $t2, 65			  # verifica se a letra está antes de A
li $t3, 1			          # registrador setado para 1 para fins comparativos
beq $t7, $t3, diminui_maiuscula		  # caso a letra esteja antes de A, vai para diminui_letra para fazer o processo inverso
j parte2 				  # caso não, pula para parte2

diminui_maiuscula:
sub $t2, $t2, $s6                         # volta 26 posições para adequar ao alfabeto
j parte2                                  # pula para parte 2

numeros:
add $t2, $t2, $s4         		  # adicione posições do fator ao registrador
slti $t7, $t2, 58			  # verífica se o caracter passou de 9
beq $t7, $zero, diminui_numero            # caso tenha passado, pula para diminui_numero
slti $t7, $t2, 48			  # verifica se o número está antes de 0
li $t3, 1				  # registrador setado para 1 para fins comparativos
beq $t7, $t3, diminui_numero     	  # caso o número esteja antes de 0, vai para diminui_numero para fazer o processo inverso
j parte2                                  # caso não, pula para parte2

diminui_numero:
sub $t2, $t2, $s7                         # volta o caracter 10 posições
j parte2                                  # pula para parte2

letras_minusculas:
add $t2, $t2, $s1                         # adiciona 3 posições ao registrador
slti $t7, $t2, 123                        # verifica se o caracter passou de z
beq $t7, $zero, diminui_letra             # caso tenha passado, pula para diminui_letra
slti $t7, $t2, 97                         # verifica se a letra está antes de a
li $t3, 1                                 # registrador setado para 1 para fins comparativos
beq $t7, $t3, diminui_letra               # caso a letra esteja antes de a, vai para diminui_letra para fazer o processo inverso
j parte2                                  # caso não, pula para parte2

diminui_letra:
sub $t2, $t2, $s6                         # volta o caracter 26 posições para adequar-se aos minúsculos
j parte2				  # pula para parte2 para terminar o processo de criptografia

parte2:
sb $t2, 0($t1)                            # armazena o valor de $t1 em $t2
addi $t1, $t1, 1                          # adiciona 1 posição para $t1
j criptografa_1                           # retorna ao início do loop

imprime_1: 
addi $t3, $zero, 1                   # adiciona 1 ao $t3 para fins de comparação
beq $s5, $t3, imprime_arquivo        # caso seja 1, pula para impressão do arquivo
li $v0, 4                  	     # carrega o id 4 em $v0 para imprimir string
la $a0, msg2              	     # imprime a mensagem de recebimento
syscall	
la $a0, texto                        # carrega a string em texto para ser impressa
imprime_2:
syscall
li $v0, 4                  	     # carrega o id 4 em $v0 para imprimir string
la $a0, blank              	     # imprime uma linha vaga para questões estéticas
syscall
j exit			             # pula para o fim do programa

imprime_arquivo:
  li $v0, 4          # carrega o id 4 em $v0 para imprimir string
  la $a0, msg10      # imprime a mensagem de sucesso
  syscall
  li   $v0, 13       # chama o sistema para abertura de arquivo
  la   $a0, output   # insere o nome do arquivo
  li   $a1, 1        # abre o arquivo para escrita
  li   $a2, 0        # modo é ignorado 
  syscall            # abre o arquivo (descritor é retornado em $v0)
  move $s6, $v0      # salva o descritor em $s6
  li   $v0, 15       # chama o sistema para escrever no arquivo
  move $a0, $s6      # move o escritor para $a0
  la   $a1, texto    # endereço do texto a ser escrito
  addi $a1, $a1, 5   # adiciona 5 posições para pular os caracteres de parâmetro
  li   $a2, 1024       # tamanho do texto
  syscall            # chama escrita
  li   $v0, 16       # sistema chama para fechar o arquivo
  move $a0, $s6      # move o descritor
  syscall            # fecha o arquivo
  j exit	     # pula para o final

exit:
li $v0, 10                    # exit
syscall
