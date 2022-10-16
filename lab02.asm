
# lab02.asm - Pairwise swap in an array of 32bit integers
#   coded in  MIPS assembly using MARS
# for MYΥ-505 - Computer Architecture, Fall 2021
# Department of Computer Science and Engineering, University of Ioannina
# Instructor: Aris Efthymiou

        .globl swapArray # declare the label as global for munit
        
###############################################################################
        .data
array: .word 5, 6, 7, 8, 1, 2, 3, 4

###############################################################################
        .text 
# label main freq. breaks munit, so it is removed...
        la         $a0, array
        li         $a1, 8


swapArray:
###############################################################################
# Write you code here.
# Any code above the label swapArray is not executed by the tester! 
###############################################################################

        add	   $t0, $zero, $zero       #set $t0 to zero
        add	   $t1, $zero, $zero       #set $t1 to zero
        add	   $t2, $zero, $zero       #set $t2 to zero
        add        $t3, $zero, $zero       #set $t3 to zero
        add	   $a2, $zero, $zero       #set $a2 to zero
   	add        $a3, $zero, $zero       #set $a3 to zero
   	beq        $a1, $t0, end           #if the size is zero get to the label
   	srl        $t3, $a1, 1             #shift right the length of the array.Our example $t3=4 
        sll        $a2, $t3, 2             #shift left twice the value of $a2.Our example $a2=16
        add        $a3, $a2, $a0           #add $a2 and $a0.Middle of the array.Our example $a3=16+5

loop:                                      #label for the loop
	lw         $t0, 0($a0)             #load word to $t2.Our example $t0=5
        lw         $t1, 0($a3)             #load word to $t3.Our example $t1=1
        sw         $t0, 0($a3)             #store word to $t2.Our example $t0=1
        sw         $t1, 0($a0)             #store word to $t3.Our example $t1=5
        addi       $a0, $a0, 4             #get to the next item of the array.Our example $a0=6
        addi       $a3, $a3, 4             #get to the next item of the array.Our example $a3=2
        addi	   $t2, $t2, 1             #add 1 to $t2.Our example $t2=1
        bne        $t2, $t3, loop          #if t2 not equal t3 then go to loop.Our example t2!=t3 then loop
end:                                       #label to get to the end if the size is 0
        

###############################################################################
# End of your code.
###############################################################################
exit:
        addiu      $v0, $zero, 10    # system service 10 is exit
        syscall                      # we are outta here.


