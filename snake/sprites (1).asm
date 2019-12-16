.include "graphics.inc"

.text
.globl main
main:
  	  # CHAMA DRAW GRID
   	 li $a0, GRID_ROWS
    	 li $a1, GRID_COLS
    	 la $a2, grid_hard
    	 jal draw_grid   
     	 #hlt: b hlt 
   
   	#Habilitando a interrupção
    	la $s5, 0xffff0000
	li $s6, 0x02
	sw $s6, 0($s5)
	

	
	la $s0, snake		#$s0= estrutura animated|_sprite
main2:
	lw $a0, 4($s0)		#$a0=pos.X
	lw $a1, 8($s0)		#$a1=pos.y
	lw $a2, 0($s0)		#$a2=sprite_id
	jal draw_sprite
	
	#Recebe as interrupções do teclado
	la $t0, mov_buf			#t0=estrutura que guarda as teclas apertadas
	lw $t1, 0($t0)			#t1=valid
	beqz $t1, skip_update_move
	#apply nem mov vector
	lw $a0, 4($t0)
	lw $a1, 8($t0)
	
	lw $t1, 4($s0)
	lw $t2, 8($s0)
	
	div $t3, $t1, 7
	mfhi $t4
	div $t5, $t2, 7
	mfhi $t6
	
	bnez $t4, skip_update_move
	bnez $t6, skip_update_move
	add $a0, $a0, $t3
	add $a1, $a1, $t5
	la  $a2, grid_easy
	jal return_wall
	bnez $v0, skip_update_move
	la $t0, mov_buf
	lw $a0, 4($t0)
	lw $a1, 8($t0)
	sw $a0, 12($s0)
	sw $a1, 16($s0)
	sw $zero, 0($t0)
	
skip_update_move:	
	move $a0, $s0		#$a0 = struct snake
	jal apply_movement
	
	## DELAY(50)
        li $v0, 32
        li $a0, 25
        syscall
	
	##=========
    b main2
    
    
# draw_grid(width, height, *grid_table)
.globl draw_grid
draw_grid:
	addi $sp, $sp, -40
	sw $ra, 36($sp)
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp)
 	sw $s3, 28($sp)
	sw $s4, 32($sp)
	
	move $s0, $a0     #$s0= linhas
	move $s1, $a1     #s1 = colunas
	move $s2, $a2	  #s2= desenho
	
	li   $s3, 0
	
linha:	
	bge  $s3, $s0, exit_grid   #verificação 
	li   $s4, 0		   #verificação
coluna:	bge  $s4, $s1, exit_coluna #verificação
	lb   $a2, 0($s2)	   
	addi $a2,$a2,-64
	mulu $a1, $s3, 7 
	mulu $a0, $s4, 7 
	jal  draw_sprite
	addi $s2,$s2,1
	addi 	$s4, $s4, 1
	jal 	coluna
exit_coluna:
	addi 	$s3, $s3, 1
	jal 	linha
exit_grid:	
	lw $ra, 36($sp)
	lw $s0, 16($sp)
	lw $s1, 20($sp)
	lw $s2, 24($sp)
 	lw $s3, 28($sp)
 	lw $s4, 32($sp)
	addi $sp, $sp, 40
	jr   $ra


# draw_sprite(X, Y, sprite_id)
.globl draw_sprite
draw_sprite:
	
	addi $sp, $sp, -40
	sw $ra, 36($sp)
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp)
 	sw $s3, 28($sp)
	sw $s4, 32($sp)
	
	move $s0, $a0	#S0 = X 
	move $s1, $a1   #s1= Y
	
	la $s2, sprites #lw t0, 0(i*4+ender)
	mul $t1, $a2, 49
	add $s2, $t1, $s2

	
	la $s4, colors	
	li $s3, 0
dra:	
	bge $s3, SPRITE_SIZE, dra_end
	lbu $t3, 0($s2)
	sll $t3, $t3, 2
	add $t3, $t3, $s4
	lw  $a2, 0($t3)
	div $t5, $s3, 7 #t5 y
	mfhi $t6 #t6 X
	add $a0, $s0, $t6
	add $a1, $s1, $t5
	jal set_pixel
	
	addi $s3, $s3, 1 #div por 7 o resto vai ser x e outro y
	addi $s2, $s2, 1
	b dra
	
dra_end:
	lw $ra, 36($sp)
	lw $s0, 16($sp)
	lw $s1, 20($sp)
	lw $s2, 24($sp)
 	lw $s3, 28($sp)
 	lw $s4, 32($sp)
	addi $sp, $sp, 40
	
    	jr   $ra
	
# set_pixel(X, Y, color)
.globl set_pixel
set_pixel:
   	la  $t0, FB_PTR
   	mul $a1, $a1, FB_XRES #(I*LINHAS)+J)*4 + ENDEREÃ‡O
   	add $a0, $a0, $a1
   	sll $a0, $a0, 2
   	add $a0, $a0, $t0
   	sw  $a2, 0($a0)
   	jr  $ra
   	
 .globl stop_sprite
 stop_sprite:
 
 	sw $zero, 12($a0)
 	sw $zero, 16($a0)
 	jr $ra
 	
 	#move_sprite(*struct,mov_x, mov_y)
  .globl move_sprite
 move_sprite:
 	sw $a1, 12($a0) #MOVE SPRITE
 	sw $a2, 16($a0)
 	jr $ra
 #------------------------------------------------------
 #Apply_moviment (*pacman)
 .globl apply_movement
 apply_movement:addi $sp, $sp, -40
	sw $ra, 36($sp)
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	sw $s2, 24($sp)
	sw $s3, 28($sp)
	sw $s4, 32($sp)
	
	move $s0, $a0		#s0= struct snake
 
 	lw $t0, 4($s0)		#t0=pos.x
 	lw $t1, 8($s0)		#t1=pos.y
 	lw $t2, 12($s0)		#t2=mov.x
	lw $t3, 16($s0)		#t3=mov.y
	
	li $t5, 7 
	
	#Divide a posição pelo tamanho do pixel
	divu $t0, $t5
	mflo $a0
	mfhi $t4
	divu $t1, $t5
	mflo $a1
	mfhi $t5
	
	
	
	beq $t3, -1, subir	# Movimento de subida
	beq $t3, 1, descer 	# Movimento de decida
	beq $t2, -1, esquerda	#movimento para esquerda
	beq $t2, 1, direita  	#movimento para direita
	b end_apply

subir:	
	bnez $t4, end_apply
	bnez $t5, exit_moviment
	add $a1, $a1, $t3
	b exit_moviment
descer:
	bnez $t4, end_apply
	bnez $t5, exit_moviment
	add $a1, $a1, $t3
	b exit_moviment
esquerda:
	bnez $t5, end_apply
	bnez $t4, exit_moviment
	add $a0, $a0, $t2
	b exit_moviment			
direita:
	bnez $t5, end_apply
	bnez $t4, exit_moviment
	add $a0, $a0, $t2
	
exit_moviment:
	la $a2, grid_hard
	move $s1, $a0 
	move $s2, $a1
	jal return_wall #(Posição x do grid, posição Y do grid, *grid)
	bnez $v0, end_apply
	
	move $a0, $s1 
	move $a1, $s2
	la   $a2, grid_hard
	
	
	
	move $a0, $s1 
	move $a1, $s2
	la   $a2, grid_hard
	add $s3, $t0, $t2	
	add $s4, $t1, $t3
       #jal print_black
	
	
	la $s0, snake
	sw $s3, 4($s0)	#grava a proxima posição para imprimir o sprite
	sw $s4, 8($s0)	#grava a proxima posição para imprimir o sprite
	#b apply_final
end_apply:

#apply_final:
	
	lw $ra, 36($sp)
	lw $s0, 16($sp)
	lw $s1, 20($sp)
	lw $s2, 24($sp)
	lw $s3, 28($sp)
	lw $s4, 32($sp)
	addi $sp, $sp, 40
	jr $ra
	
 # (X,Y, *gride)
 # Mult por linha, soma coluna, mult por 4 e soma com endereço base
 .globl return_id
return_id:
	addi $sp, $sp, -32
	sw $ra, 24($sp)
	sw $s0, 16($sp)
	sw $s1, 20($sp)
	
	move $s0, $a1
	move $s1, $a0

	mulu $s0, $s0, GRID_COLS
	add $s1, $s1, $s0
	add  $s1,$s1, $a2
	lb   $s1, 0($s1)
	addi $v0, $s1, -64
		
	lw $ra, 24($sp)
	lw $s0, 16($sp)
	lw $s1, 20($sp)
	
	addi $sp, $sp, 32
	jr $ra
#---------------------------------------------------
#Return_wall
 # (X,Y, *gride)
.globl return_wall 
return_wall:
	addi $sp, $sp, -24
	sw $ra, 16($sp)
	
	jal return_id
	bge $v0, 5, ret_true
ret_11:	
	li $v0, 0
	b endd
	
ret_true:
	beq $v0, 20, ret_11
	li $v0, 1
 endd: 	
 	lw $ra, 16($sp)
 	


	addi $sp, $sp, 24
	jr $ra
#------------------------------------------------------------

	
#Print_black(X dogrid, Y do gride, *grid) 
#.globl print_black	
#print_black:
	
#	addi $sp, $sp, -32
#	sw $ra, 24($sp)
#	sw $s0, 16($sp)
#	sw $s1, 20($sp)
	
#	jal return_id
#	beq $v0, 20, end_ra

#	move $s0, $a1
#	move $s1, $a0
	
#	mulu $s0, $s0, GRID_COLS
#	add  $s1, $s1, $s0
#	add  $s1,$s1, $a2
#	li   $s0, 84 # Salva o id do spreite preto ja somando com 64
#	sb   $s0, 0($s1) 
	
	#print na tela
#	mulu $a0, $a0, 7 
#	mulu $a1, $a1, 7 
#	li $a2, 20
#	jal draw_sprite
#end_ra:		
#	lw $ra, 24($sp)
 #	lw $s0, 16($sp)
 #	lw $s1, 20($sp)
 #	addi $sp, $sp, 32
#	jr $ra 
	
								
#animaÃ§Ã£o + teclado + mov + stop + strcut

.ktext 0x80000180
  move  $k0, $at      # $k0 = $at 
  la    $k1, _regs    # $k1 = address of _regs 
  
  sw    $k0, 0($k1)   #at
  sw    $v0, 4($k1)
  sw    $v1, 8($k1)
  sw    $a0, 16($k1)
  sw    $a1, 20($k1)
  sw    $a2, 24($k1)
  sw    $a3, 28($k1)
  sw    $t0, 32($k1)
  sw    $t1, 36($k1) 
  sw    $t2, 40($k1)
  sw    $t3, 44($k1)
  sw    $t4, 48($k1)
  sw    $t5, 52($k1)
  sw    $t6, 56($k1)
  sw    $t7, 60($k1)
  sw    $s0, 64($k1)
  sw    $s1, 68($k1)
  sw    $s2, 72($k1)
  sw    $s3, 76($k1) 
  sw    $s4, 80($k1)
  sw    $s5, 84($k1)
  sw    $s6, 88($k1)
  sw    $s7, 92($k1)
  sw    $t8, 96($k1)
  sw    $t9, 100($k1)
  sw    $gp, 104($k1)
  sw    $sp, 108($k1)
  sw    $fp, 112($k1)
  sw    $ra, 116($k1)
  mfhi  $k0
  sw    $k0, 120($k1)
  mflo  $k0
  sw    $k0, 124($k1)
  

  #la    $a0, _msg1    # $a0 = address of _msg1 
  #i    $v0, 4        # $v0 = service 4 
  #syscall             # Print _msg3


  mfc0  $a0, $13
  la 	$a1, jtable	#load andress of vector
  andi  $a0,$a0,0x007C
  add 	$a1, $a1, $a0 	# EndereÃ§o do elemento na jtable
  lw    $a1, 0($a1)	# Carrego valor do elemento em $t0
  jr 	$a1
  
case0:
    #print hardware interrupt 
    
    
   #li $v0, 4
   # la $a0, hardware_interrupt 
   # syscall
    mfc0  $a0, $14
    addi $a0, $a0, -4
    mtc0  $a0, $14
    
    la $a2, 0xffff0000  #Carregando endereï¿½o com as informaï¿½ï¿½es do teclado
    lw $a1, 4($a2)	#Carregando dados lidos pelo teclado
    bne $a1, 100, mov_01
    li  $a1, 1
    li  $a2, 0
    la  $a0, mov_buf
    li  $t0, 1
    sw  $t0, 0($a0)
    sw  $a1, 4($a0)
    sw  $a2, 8($a0)
    j   switch_case_exit
mov_01:
    bne $a1, 97, mov_02
    li  $a1, -1
    li  $a2, 0
    la  $a0, mov_buf
    li  $t0, 1
    sw  $t0, 0($a0)
    sw  $a1, 4($a0)
    sw  $a2, 8($a0)
    j   switch_case_exit
mov_02:
    bne $a1, 32, mov_03
    li  $a1, 0
    li  $a2, 0
    la  $a0, mov_buf
    li  $t0, 1
    sw  $t0, 0($a0)
    sw  $a1, 4($a0)
    sw  $a2, 8($a0)
    j   switch_case_exit
mov_03:
    bne $a1, 119, mov_04
    li  $a1, 0
    li  $a2, -1
    la  $a0, mov_buf
    li  $t0, 1
    sw  $t0, 0($a0)
    sw  $a1, 4($a0)
    sw  $a2, 8($a0)
    j   switch_case_exit
mov_04:
    bne $a1, 115, mov_05
    li  $a1, 0
    li  $a2, 1
    la  $a0, mov_buf
    li  $t0, 1
    sw  $t0, 0($a0)
    sw  $a1, 4($a0)
    sw  $a2, 8($a0)
    j   switch_case_exit
mov_05:
    #sw $t1, 12($t2)	#Gravando dado no local para imprimir no display

    j   switch_case_exit
case1:
case2:
case3:
case11:
case14:

    #print invalid exception 
    li $v0, 4
    la $a0, invalid
    syscall
    j   switch_case_exit
case4:
#print ADDRL
    li $v0, 4
    la $a0, addrl
    syscall
    j   switch_case_exit
case5:
#print ADDRS 
    li $v0, 4
    la $a0, addrs
    syscall
    j   switch_case_exit
case6:
#print IBUS
    li $v0, 4
    la $a0, ibus
    syscall
    j   switch_case_exit
case7:
#print Bus error on dara load or store
    li $v0, 4
    la $a0, dbus
    syscall
    j   switch_case_exit
case8:
#print syscal instruction
    li $v0, 4
    la $a0, syscall_invalid
    syscall
    j   switch_case_exit
case9:
#print Breakpoint instruction
    li $v0, 4
    la $a0, bkpt
    syscall
    j   switch_case_exit
case10:
#print Reserved instructoin exception
    li $v0, 4
    la $a0, reserved_instr
    syscall
    j   switch_case_exit

case12:
    #Arithmetic overflow wxception

    li $v0, 4
    la $a0, arithmetic
    syscall
    j   switch_case_exit
case13:
#print Excection caused by trap instruction
    li $v0, 4
    la $a0, trap
    syscall
    j   switch_case_exit
case15:
#print Floating point
    li $v0, 4
    la $a0, float_error
    syscall
    j   switch_case_exit



default:
    #print out_of_range
    li $v0, 4
    la $a0, s_range
    syscall
switch_case_exit:

  la    $k1, _regs    # $k1 = address of _regs 
  lw    $k0, 0($k1)   #at
  lw    $v0, 4($k1)
  lw    $v1, 8($k1)
  lw    $a0, 16($k1)
  lw    $a1, 20($k1)
  lw    $a2, 24($k1)
  lw    $a3, 28($k1)
  lw    $t0, 32($k1)
  lw    $t1, 36($k1) 
  lw    $t2, 40($k1)
  lw    $t3, 44($k1)
  lw    $t4, 48($k1)
  lw    $t5, 52($k1)
  lw    $t6, 56($k1)
  lw    $t7, 60($k1)
  lw    $s0, 64($k1)
  lw    $s1, 68($k1)
  lw    $s2, 72($k1)
  lw    $s3, 76($k1) 
  lw    $s4, 80($k1)
  lw    $s5, 84($k1)
  lw    $s6, 88($k1)
  lw    $s7, 92($k1)
  lw    $t8, 96($k1)
  lw    $t9, 100($k1)
  lw    $gp, 104($k1)
  lw    $sp, 108($k1)
  lw    $fp, 112($k1)
  lw    $ra, 116($k1)
  lw    $k0, 120($k1)
  mthi  $k0
  lw    $k0, 124($k1)
  mtlo  $k0
  
  mfc0  $k0, $14      # $k0 = EPC 
  addiu $k0, $k0, 4   # Increment $k0 by 4 
  mtc0  $k0, $14      # EPC = point to next instruction 
  eret

.kdata
jtable: .word case0, case1, case2, case3, case4, case5, case6, case7, case8, case9, case10, case11, case12, case13, case14, case15, default

# Declarar todas as variaveis da tabela de exceï¿½ï¿½o

invalid: 		.asciiz "Exceï¿½ï¿½o nï¿½o encontrad a" 
arithmetic:	 	.asciiz "Erro de overflow" 
hardware_interrupt:	.asciiz "hardware interrupt "  
s_range: 		.asciiz "out_of_range"
addrl: 			.asciiz "Address Error caused by load or instruction fetch"
addrs: 			.asciiz "Address Error caused by store instruction"
ibus: 			.asciiz "Bus error on instruction fetch"
dbus: 			.asciiz "Bus error on data load or store"
syscall_invalid: 	.asciiz "Error caused by Systecall"
bkpt: 			.asciiz "Error caused by Break instruction"
reserved_instr: 	.asciiz "Reserved instruction error"
trap: 			.asciiz "Error caused by trap instruction"
float_error: 		.asciiz "Error caused by floating_point instruction"
_msg1: 			.asciiz   "\n!! Ocorreu uma exceÃ§Ã£o !!\n "
.align 2
_regs: .space    128
