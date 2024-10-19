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
.kdata
save_t1: .word
save_t2: .word
save_s1: .word
save_s2: .word
save_s3: .word
save_s4: .word
save_a0: .word
save_v0: .word
save_at: .word

.ktext 0x80000180

# save every used register as needed
	move $k0, $at
	sw $k0, save_at
	
	sw $t1, save_t1
	sw $t2, save_t2
	sw $s1, save_s1
	sw $s2, save_s2
	sw $s3, save_s3
	sw $s4, save_s4
	sw $a0, save_a0
	sw $v0, save_v0
	
	mfc0 $k0, $13
	srl $t1, $k0, 2
	andi $t1, $t1, 0x1f
	
	bnez $t1, non_int
	
	andi $t2, $k0, 0x00000100
	bnez $t2, tick
	#andi $t2, $t1, 0x00000200
	#bnez $t2, transmit
	b iend
	
tick:
	lw $s1, RCR
	lw $s2, RDR
	lw $t1, 0($s1)
	beqz $t1, iend
	lw $t2, 0($s2)

#transmit:
	#lw $s3, TCR
	#lw $s4, TDR
	#lw $t1, 0($s3)
	#beqz $t1, iend
	#sw $t2, 0($s4)
	#b iend

non_int: 
	mfc0 $k0, $14
	addiu $k0, $k0, 4
	mtc0 $k0, $14
	
iend:
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

	
