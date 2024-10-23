#this is the entry point of the program
	.data
PCB: .space 1440 # 36*4 bytes per PCB for 10 PCBs
freepcb: .word
running: .word
ready: .word
lastready: .word

pcbstack: .space 320 # 8*4 bytes per stack for 10 tasks
freestack: .word
	
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
	# part 1: initialize the process ID and next PCB pointer in each PCB
	la $t1, PCB
	li $t2, 0
	li $t3, 10
	
init_loop:
	sw $t2, 136($t1)
	sw $zero, 140($t1)
	
	addiu $t1, $t1, 144
	addiu $t2, $t2, 1
	bne $t2, $t3, init_loop
	
	# part 2: fill the first PCB with relevant information ($sp and epc) and adjust the structures and pointers accordingly
	la $t1, PCB
	sw $t1, running # put pcb of main task in execution
	sw $zero, ready # ready list starts empty since main task is already in execution
	sw $zero, lastready
	
	la $t2, pcbstack # store stack pointer and EPC
	la $t3, main
	sw $t2, 112($t1)
	sw $t3, 132($t1)
	
	addiu $t1, $t1, 144 # increment 1 position in PCB and stack
	addiu $t2, $t2, 32 
	sw $t1, freepcb # store new freepcb and freestack addresses
	sw $t2, freestack
	
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
