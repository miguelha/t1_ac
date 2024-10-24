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
	mflo $k0
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
	lw $t1, 0($s1)
	beqz $t1, iend
	
	# switching logic
	lw $t1, running
	lw $t2, ready
	
	lw $t3, 140($t2) # remove the first element in the ready list
	sw $t3, ready
	
	lw $t4, lastready
	sw $t1, 140($t4)
	sw $t1, lastready
	sw $zero, 140($t1)
	
	sw $t2, running
	b iend

non_int:
	mfc0 $k0, $14
	addiu $k0, $k0, 4
	mtc0 $k0, $14
	
iend:
	# the new task must be changed to execution (running) before restoring the register values
	
	# use k0 before it has been loaded to load registers that cannot be directly loaded
	lw $k0, running+124
	mthi $k0
	lw $k0, running+128
	mtlo $k0
	lw $k0, running+132
	mtc0 $k0, $14
	lw $k0, running
	move $at, $k0
	# now load the rest of the registers directly
	lw $v0, running+4
	lw $v1, running+8
	lw $a0, running+12
	lw $a1, running+16
	lw $a2, running+20
	lw $a3, running+24
	lw $t0, running+28
	lw $t1, running+32
	lw $t2, running+36
	lw $t3, running+40
	lw $t4, running+44
	lw $t5, running+48
	lw $t6, running+52
	lw $t7, running+56
	lw $s0, running+60
	lw $s1, running+64
	lw $s2, running+68
	lw $s3, running+72
	lw $s4, running+76
	lw $s5, running+80
	lw $s6, running+84
	lw $s7, running+88
	lw $t8, running+92
	lw $t9, running+96
	lw $k0, running+100
	lw $k1, running+104
	lw $gp, running+108
	lw $sp, running+112
	lw $fp, running+116
	lw $ra, running+120

	mtc0 $zero, $13
	mfc0 $k0, $12
	andi $k0, 0xfffd
	ori $k0, 0x0001
	mtc0 $k0, $12
	eret

	
