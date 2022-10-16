# lab03.asm - Recursive palindrome string tester
#   coded in  MIPS assembly using MARS
# for MYΥ-505 - Computer Architecture, Fall 2021
# Department of Computer Science and Engineering, University of Ioannina
# Instructor: Aris Efthymiou

.globl pdrome

###############################################################################
.data
anna:  .asciiz "anna"
bobob: .asciiz "bobob"

###############################################################################
.text
  la    $a0, anna
  addi  $a1, $zero, 4
  jal   pdrome
  add   $s0, $v0, $zero  # keep the return value

  la    $a0, bobob
  addi  $a1, $zero, 5
  jal   pdrome
  add   $s1, $v0, $zero  # keep the return value
  # both s1 and s0 must be 1 here

  addiu   $v0, $zero, 10    # system service 10 is exit
  syscall                   # we are outa here.


pdrome:
###############################################################################
# Write you code here.
# Any code above the label swapArray is not executed by the tester! 
###############################################################################

  #the algorithm checks recursively if a string is a palidrome
  #it starts by assinging space to the stack 
  #it checks if the fisrt and last letters are equal 
  #until it gets to the case where the length is smaller than two
  
  
recursion:

  beq  $a1,$zero,stop
  
  addi  $t0,$zero,1
  beq	$t0, $a1,stop  
  
  lb	$t0, 0($a0)
  addi	$t1, $a1, -1
  add	$t1, $t1, $a0
  lb	$t2, 0($t1)
  beq	$t0, $t2, return_true      
              
return_false:
  addi $v0, $zero, 0
  
repeat:  
  addi  $a0,$a0,1
  addi $a1,$a1,-2
  addi $sp,$sp,-16
  sw   $ra, 0($sp)
  sw   $a0, 4($sp)
  sw   $a1, 8($sp)
  sw   $v0, 12($sp)
  jal  recursion
  bne  $v0,$zero,stop
  sw   $v0,28($sp)
  
stop:
 lw   $ra, 0($sp)                      
 lw   $ra, 0($sp)
 lw   $a0, 4($sp)
 lw   $a1, 8($sp)                             
 lw   $v0, 12($sp)
 addi $sp,$sp,16                                               
                                                                                                                                                                       
return_true:
  addi $v0,$zero,1  


  
###############################################################################
# End of your code.
###############################################################################
  jr $ra

