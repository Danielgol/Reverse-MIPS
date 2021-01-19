
.data
	localArquivo: .asciiz "C:\\Users\\danro\\Downloads\\arquivo.txt"
	arqSaida: .asciiz "C:\\Users\\danro\\Downloads\\arquivoSaida.txt"
	input:	.space	512
	output:	.space	512

.text
.globl main
main:

	li $v0, 13 					# Abrir arquivo
	la $a0, localArquivo 				# Caminho do arquivo
	li $a1, 0 					# Arquivo para leitura
	syscall 					# Descritor(REGISTRADOR/buffer QUE GUARDA O ARQUIVO) em $v0
	
	move $s0, $v0					# Colocar o descritor em $a0

	li 	$v0, 14 				# Ler o conteudo referenciado por $a0
	move 	$a0, $s0
	la 	$a1, input 				# Buffer que armazena o conteudo
	li 	$a2, 1024 				# Tamanho do buffer = deve ser maior que o tam do arq
	syscall 					# Leitura de TODO o arquivo, colocando a informação no buffer
	la 	$a0, input				# a0 = palavra
	
	li 	$t7, 0					# int t7 = tamanho das palavras até ele
	
	loop:
		jal 	find_word
	
		add	$t6, $zero, $v0			# t6 = tamanho da palavra atual + \n
		add	$t7, $t7, $t6
		add	$t1, $zero, $t7			# t1 = length
		add	$t2, $zero, $a0			# t2 = palavra
	
		jal	reverse_word
	
		addi	$t6, $t6, 1			# inicio da prox palavra
		addi	$t7, $t7, 1
		add	$a0, $a0, $t6
		
		li	$t0, 0
		li	$t2, 0
		add	$t2, $a0, $t0			# t2 = inicio_palavra + t0
		lb	$t1, 0($t2)
		beqz	$t1, exit			# We found the null-byte
		j	loop

	exit:	
		li	$v0, 4				# Print
		la	$a0, output			# the string!
		syscall
		
    		li $v0, 13 				# abrir arquivo Saida
    		la $a0, arqSaida 			# caminho do arquivo
    		li $a1, 1 				# arquivo para escrita
    		syscall 				# descritor(REGISTRADOR/buffer QUE GUARDA O ARQUIVO) em $v0
	
    		move $t0, $v0				# Copia do descritor
	
		li $v0, 15 				# ler o conteudo referenciado por $a0
    		move $a0, $t0 				# descritor em $a0
    		la $a1, output 				# conteudo a ser escrito
    		li $a2, 512 				# tamanho do buffer = deve ser maior que o tam do arq
    		syscall 				# leitura de TODO o arquivo, colocando a informação no buffer

    		li $v0, 16
    		move $a0, $t0 				# Devolve pra a0 o descritor, necessário pra fechar o arquivo
    		syscall
	
		li 	$v0, 16
		move 	$a0, $s0 			# Devolve pra a0 o descritor, necessário pra fechar o arquivo
		syscall					# Fechar o arquivo
		
		li	$v0, 10				# exit()
		syscall
	
	find_word:
		li	$t0, 0
		li	$t2, 0
		li	$t4, 0
		
		find_loop:
			add	$t2, $a0, $t0		# t2 = inicio_palavra + t0
			lb	$t1, 0($t2)		# t1 = palavra[t0]
			slti	$t4, $t1, 11		# t4 = 0 ou 1 (t1 <= 10)
			beq	$t4, 1, found		# if (t1<10){strlen_exit}
			addiu	$t0, $t0, 1 		# s1++
			j	find_loop		# volta pro loop
			
		found:
			#subi 	$t0, $t0, 1
			add	$v0, $zero, $t0
			add	$t0, $zero, $zero
			jr	$ra
	
	reverse_word:
		li	$t0, 0				# t0 = primeiro caracter
		li	$t3, 0				# t3 vai ser o caracter
		li	$t5, 0				# Resultado IF
		
		li	$t4, 10
		sb	$t4, output($t1)
		subi	$t1, $t1, 1
		
		reverse_loop:
			add	$t3, $t2, $t0		# t3 = palavra(t2) + t0
			lb	$t4, 0($t3)		# t4 = palavra[t0]
			
			slti	$t5, $t4, 11		# t5 = 0 ou 1 (t1 <= 10)
			beq	$t5, 1, reversed	# if (t1<10){strlen_exit}
			
			sb	$t4, output($t1)	# output[t1] = t4	
			subi	$t1, $t1, 1		# t1--
			addi	$t0, $t0, 1		# t0++
			j	reverse_loop		# Loop until we reach our condition
	
		reversed:
			jr	$ra
