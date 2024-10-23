# you must put here the necessary code to deal with the interrupts

# enable interrupts
.data
ALL_INT_MASK: .word 0x0000ff00
KBD_INT_MASK: .word 0x00000100
RCR:	.word 	0xffff0000
RDR:	.word	0xffff0004
TCR:	.word	0xffff0008
TDR:	.word	0xffff000c

.text
int_enable:
	mfc0 $t0, $12
	lw $t1, ALL_INT_MASK
	not $t1, $t1
	and $t0, $t0, $t1
	lw $t1, KBD_INT_MASK
	or $t0, $t0, $t1
	mtc0 $t0, $12
	
	# now enable interrupts on the KBD
	lw $t0, RCR
	li $t1, 0x00000002
	sw $t1, 0($t0)
	jr $ra
	
	
# interrupt handler
.ktext 0x80000180

	# save all registers from the current process needed for context switching to the PCB (prepare to switch tasks)
	sw $v0, running+4
	sw $v1, running+8
	sw $a0, running+12
	sw $a1, running+16
	sw $a2, running+20
	sw $a3, running+24
	sw $t0, running+28
	sw $t1, running+32
	sw $t2, running+36
	sw $t3, running+40
	sw $t4, running+44
	sw $t5, running+48
	sw $t6, running+52
	sw $t7, running+56
	sw $s0, running+60
	sw $s1, running+64
	sw $s2, running+68
	sw $s3, running+72
	sw $s4, running+76
	sw $s5, running+80
	sw $s6, running+84
	sw $s7, running+88
	sw $t8, running+92
	sw $t9, running+96
	sw $k0, running+100
	sw $k1, running+104
	sw $gp, running+108
	sw $sp, running+112
	sw $fp, running+116
	sw $ra, running+120
	# now use k0 that has already been saved to save registers that cannot be directly saved
	mfhi $k0
	sw $k0, running+124
	mflo $ko
	sw $k0, running+128
	mfc0 $k0, $14
	sw $k0, running+132
	move $k0, $at
	sw $k0, running
	
	mfc0 $k0, $13
	srl $t1, $k0, 2
	andi $t1, $t1, 0x1f
	
	bnez $t1, non_int
	
	andi $t2, $k0, 0x00000100
	bnez $t2, tick
	b iend
	
tick:
	lw $s1, RCR
	lw $s2, RDR
	lw $t1, 0($s1)
	beqz $t1, iend
	lw $t2, 0($s2)

non_int: 
	mfc0 $k0, $14
	addiu $k0, $k0, 4
	mtc0 $k0, $14
	
iend:
	# load all the registers from the PCB of the new process in execution to finish context switching
	lw $t1, save_t1
	lw $t2, save_t2
	lw $s1, save_s1
	lw $s2, save_s2
	lw $s3, save_s3
	lw $s4, save_s4
	lw $a0, save_a0
	lw $v0, save_v0
	
	lw $k0, save_at
	move $at, $k0
	mtc0 $zero, $13
	mfc0 $k0, $12
	andi $k0, 0xfffd
	ori $k0, 0x0001
	mtc0 $k0, $12
	eret

	
