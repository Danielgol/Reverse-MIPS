
.data
	localArquivo: .asciiz "C:\\Users\\danro\\Downloads\\arquivo.txt"
	input:	.space	512
	output:	.space	512

.text
.globl main
main:

	li $v0, 13 				# abrir arquivo
	la $a0, localArquivo 			# caminho do arquivo
	li $a1, 0 				# arquivo para leitura
	syscall 				# descritor(REGISTRADOR/buffer QUE GUARDA O ARQUIVO) em $v0
	
	move $s0, $v0				# Colocar o descritor em $a0

	li $v0, 14 				# ler o conteudo referenciado por $a0
	move $a0, $s0
	la $a1, input 				# buffer que armazena o conteudo
	li $a2, 1024 				# tamanho do buffer = deve ser maior que o tam do arq
	syscall 				# leitura de TODO o arquivo, colocando a informação no buffer

	move $a0, $a1
	
	jal	strlen				# JAL to strlen function, saves return address to $ra
	
	add	$t1, $zero, $v0			# Copy some of our parameters for our reverse function
	add	$t2, $zero, $a0			# We need to save our input string to $t2, it gets
	add	$a0, $zero, $v0			# butchered by the syscall.
	li	$v0, 1				# This prints the length that we found in 'strlen'
	syscall
	
reverse:
	li	$t0, 0				# Set t0 to zero to be sure
	li	$t3, 0				# and the same for t3
	
	reverse_loop:
		add	$t3, $t2, $t0		# $t2 is the base address for our 'input' array, add loop index
		lb	$t4, 0($t3)		# load a byte at a time according to counter
		beqz	$t4, exit		# We found the null-byte
		sb	$t4, output($t1)	# Overwrite this byte address in memory	
		subi	$t1, $t1, 1		# Subtract our overall string length by 1 (j--)
		addi	$t0, $t0, 1		# Advance our counter (i++)
		j	reverse_loop		# Loop until we reach our condition
	
exit:
	li	$v0, 4				# Print
	la	$a0, output			# the string!
	syscall
	
	li $v0, 16
	move $a0, $s0 				#Devolve pra a0 o descritor, necessário pra fechar o arquivo
	syscall					#fechar o arquivo
		
	li	$v0, 10				# exit()
	syscall
	

strlen:
	li 	$t0, 0 				# int t0 = 0
	li 	$t2, 0 				# char t2 = 0
	li	$t4, 0
	li	$t5, 11			
	
	strlen_loop:
		add	$t2, $a0, $t0		# t2 = inicio_palavra + t0
		lb	$t1, 0($t2)		# t1 = palavra[t0]
		
		slt	$t4, $t1, $t5		# t4 = 0 ou 1 (t1 < 65)
		beq	$t4, 1, strlen_exit	
		#beqz	$t1, strlen_exit	# if (t1 == null) {sair}
		
		addiu	$t0, $t0, 1 		# t0++
		j	strlen_loop		# volta pro loop
		
	strlen_exit:
		subi	$t0, $t0, 1		# t0 -= 1
		add	$v0, $zero, $t0		# v0 = t0 (tamanho da palavra)
		add	$t0, $zero, $zero	# limpa t0
		jr	$ra			# return;