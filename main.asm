#this is the entry point of the program
	.data
PCB: .space 1440 # 36*4 bytes per PCB for 10 PCBs
freepcb: .word
running: .word
ready: .word
lastready: .word

pcbstack: .space 320 # 8*4 bytes per stack for 10 tasks
	
STRING_done: .asciiz "Multitask started\n"
STRING_main: .asciiz "Task Zero\n"

	.text
main:
# prepare the structures
	jal prep_multi
	
# newtask (t0)
	#la $a0,t0
	#li $a1, 1
	#jal newtask
	
# newtask(t1)	
	#la $a0,t1
	#li $a1,2
	#jal newtask
	
# newtask(t2)
	#la $a0,t2
	#l1 $a2, 3
	#jal newtask

# startmulti() and continue to 
# the infinit loop of the main function
	jal start_multi
	
	la $a0, STRING_done
	li $v0, 4
	syscall
	
infinit: 
	# Reapeatedly print a string
	la $a0, STRING_main
	li $v0, 4
	syscall
	b infinit

# the support functions	
prep_multi:
	# write your code here
	la $t1, PCB
	sw $t1, freepcb
	sw $t1, running
	sw $zero, ready
	sw $zero, lastready
	addi $t1, $t1, 144
	sw $t1, freepcb
	jr $ra
	
newtask:
	# write your code here
	#jr $ra
    
start_multi:
	move $s0, $ra
	jal int_enable
	move $ra, $s0
	jr $ra 

	.globl main
	.include "t0.asm"
	.include "t1.asm"
	.include "t2.asm"
	.include "interrupt.asm"
#END
