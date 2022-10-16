###############################################################################
# Simple exception handling in Mips. 
###############################################################################
        .data

start_of_data: .space 1
unaligned:     .byte  0xa, 0, 0, 0x1


###############################################################################
# USER TEXT SEGMENT
###############################################################################

	.globl main
	.text
main:
       	# The largest 32 bit positive two's complement number.
	li $s0, 0x7fffffff  
	
	# Trigger an arithmetic overflow exception. 
	addi $s1, $s0, 1
	
	la   $a1, unaligned
	# Trigger a bad data address (on load) exception.
	lw $a0, 0($a1)
	
infinite_loop: 
	addi $s0, $s0, 0
	j infinite_loop


###############################################################################
# KERNEL DATA SEGMENT
###############################################################################

	.kdata

save:                   .word 0:2
		
UNHANDLED_EXC_MSG:	.asciiz "===>UNHANDLED EXCEPTION<==========\n\n"
OVERFLOW_MSG: 		.asciiz "===>ARITHMETIC OVERFLOW<==========\n\n" 
BAD_ADDRESS_MSG: 	.asciiz "===>BAD DATA ADDRESS EXCEPTION<===\n\n"
		
###############################################################################
# KERNEL TEXT SEGMENT 
# 
# For simplicity, this kernel will save and retore only registers at, a0, v0 
# It will also use $k0, $k1 but not restore them
#
###############################################################################

   	# The exception handler address for MIPS
   	.ktext 0x80000180  
   
__handler_entry:
        add  $k1, $zero, $at  # save at in k1
        la   $at, save
        sw   $v0, 0($at)     # Not re-entrant and we can't trust $sp
        sw   $a0, 4($at)     #  but we need to use these registers

	mfc0 $k0, $13   # Get Cause register
	andi $k0, $k0, 0x00007c  # Keep the exception code (bits 2 - 6).
	srl  $k0, $k0, 2
	############################################
	mfc0 $t1, $14   # Get exception program counter register
	addi $t1, $t1, 4  # incrent value by 4 to get the next address
	mtc0 $t1, $14     # move the address to the coprocessor 0 and set the exception program counter register to the increamented value
        ############################################
	# For simplicity, we don't check for interrupts (k == 0)
__exception:
	# Branch on value of the the exception code in $k1. 
	addi $v0, $zero, 12
	beq  $k0, $v0, __overflow_exception
	
	###############################################################################
	# TODO: Add code here to detect bad address exception
	addi $v0, $zero, 4
	beq  $k0, $v0, __bad_address_exception
	###############################################################################
	
__unhandled_exception: 
  	#  Use the MARS built-in system call 4 (print string) to print error messsage.
	li $v0, 4
	la $a0, UNHANDLED_EXC_MSG
	syscall
 
 	j __resume_from_exception
	
__overflow_exception:
  	#  Use the MARS built-in system call 4 (print string) to print error messsage.
	li $v0, 4
	la $a0, OVERFLOW_MSG
	syscall
 
 	j __resume_from_exception
 	
__bad_address_exception: 	
	###############################################################################
        # TODO: Add code here to print messages for bad address exception
        li $v0, 4  #print string
	la $a0, BAD_ADDRESS_MSG  
	syscall
	li $v0, 34      # print integer in hexadecimal
	mfc0 $a0, $14   # Get exception program counter register
	addi $a0, $a0, -4
	syscall         
	###############################################################################


__resume_from_exception: 
	
	# When an exception or interrupt occurs, the value of the program counter 
	# ($pc) of the user level program is automatically stored in the exception 
	# program counter (EPC), the $14 in Coprocessor 0. 

__resume:
	# Restore registers at, v0, a0
	la   $at, save
        lw   $v0, 0($at)     # restore v0
        lw   $a0, 4($at)     #  a0
	add  $at, $k1, $zero #  and at (from k1)

	# Use the eret (Exception RETurn) instruction to set the program counter
	# (PC) to the value saved in the EPC register (register 14 in coporcessor 0).
	eret # Look at the value of $14 in Coprocessor 0 before single stepping.

