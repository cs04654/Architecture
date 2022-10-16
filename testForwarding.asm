# ----------------------------------------------------------------------------------------
# testForwarding.asm 
#  Verify correctness of forwarding logic of the 5-stage pipelined MIPS processor
#    used in MYY505
# At exit, v1 will be 0 when all tests pass. Any other number indicates a mistake in pipeline control
# ----------------------------------------------------------------------------------------

.data
storage:
    .word 1
    .word 10
    .word 11
.text
# ----------------------------------------------------------------------------------------
# prepare register values.
# ----------------------------------------------------------------------------------------
#  DO NOT USE li as it breaks into 2 instructions and requires forwarding $at between them.
#  I use la here, but I should have assigned the address to $a0 differently 
    la   $a0, storage
    addi $s0, $zero, 1
    addi $s1, $zero, 2
    addi $s2, $zero, 3
    addi $s3, $zero, 0

# ----------------------------------------------------------------------------------------
# test if the execute stage of an R-type instruction forwards a value to be decoded to another R-type instruction
# -to input A of ALU
  addi $v1, $zero, 2 
  #the value of $s1 and $s2 and $s3 gets forwarded without problems because already a cyrcle past because of the instruction **addi $v1, $zero, 1** 
  add  $t0, $s1, $s2  #generate a value to t0 which equals to 5 
  add  $t1, $t0, $s3  #in this instruction there is a dependency to $t0.So we use forwarding. The instruction pass in the third circle, in which the previous **add  $t0, $s1, $s2** has calculated the value.Because of the forwarding there is no need for a nop("no operation") instruction between them.The value of $t1 should be 5 + 0 = 5
  add  $t2, $t2, $t2  #there is a need for a no operation instruction or a dummy instruction so the beq doesnt wait
  beq  $t0, $t1, t1B  # should be taken if the fwd logic is correct. 
  j    exit           # exit with code 1 in v1, if the value to $t0 doesnt get forwarded right to t1 in which case $t1 would equal 5

# ---------------------
# -to input B of ALU.Same code as above, just using the other ALU input
t1B:
  addi $v1, $zero, 3 
  #the value of $s1 and $s2 gets forwarded without problems because already a cyrcle past because of the instruction **addi $v1, $zero, 1** 
  add  $t0, $s1, $s2  # generate a value to t0 which equals to 5 
  add  $t1, $s3, $t0  # in this instruction there is a dependency to $t0.So we use forwarding. The instruction pass in the third circle, in which the previous **add  $t0, $s1, $s2** has calculated the value.Because of the forwarding there is no need for a nop instruction between them.The value of $t1 should be  5 + 0 = 5
  add  $t2, $t2, $t2  # there is a need for a no operation instruction or a dummy instruction so the beq doesnt wait
  beq  $t0, $t1, t2A  # should be taken if the fwd logic is correct. 
  j    exit           # exit with code 1 in v1, if the value to $t0 doesnt get forwarded right to t1 in which case $t1 would equal 5
  

# ----------------------------------------------------------------------------------------
#  Similar to previous test. Just adding 1 instruction between instruction writing to $t1
t2A:
  addi $v1, $zero, 4 
  # the value of $s1 and $s2 gets forwarded without problems because already a cyrcle past because of the instruction **addi $v1, $zero, 1** 
  add  $t0, $s1, $s2  # generate a value to t0 which equals to 5 
  add  $t2, $t2, $t2  # nop (dummy)
  add  $t1, $t0, $s3  # in this instruction there is a dependency to $t0.So we use forwarding. The instruction pass in the third circle, in which the previous **add  $t0, $s1, $s2** has calculated the value.Because of the forwarding there is no need for a nop instruction between them.The value of $t1 should be  5 + 0 = 5
  add  $t2, $t2, $t2  # there is a need for a no operation instruction or a dummy instruction so the beq doesnt wait
  beq  $t0, $t1, t2B  # should be taken if the fwd logic is correct.   
  j    exit           # exit with code 1 in v1, if the value to $t0 doesnt get forwarded right to t1 in which case $t1 would equal 5
  
# ----------------------------------------------------------------------------------------  
#-to input B of ALU
t2B:
  addi $v1, $zero, 5 
  # the value of $s1 and $s2 gets forwarded without problems because already a cyrcle past because of the instruction **addi $v1, $zero, 1** 
  add  $t0, $s1, $s2  # generate a value to t0 which equals to 5 
  add  $t2, $t2, $t2  # nop (dummy)
  add  $t1, $s3, $t0  # in this instruction there is a dependency to $t0.So we use forwarding. The instruction pass in the third circle, in which the previous **add  $t0, $s1, $s2** has calculated the value.Because of the forwarding there is no need for a nop instruction between them.The value of $t1 should be  5 + 0 = 5. However i followed the testzero example and added a nop
  add  $t2, $t2, $t2  # there is a need for a no operation instruction or a dummy instruction so the beq doesnt wait
  beq  $t0, $t1, tsw  # should be taken if the fwd logic is correct.   
  j    exit           # exit with code 1 in v1, if the value to $t0 doesnt get forwarded right to t1 in which case $t1 would equal 5

# ----------------------------------------------------------------------------------------  
# check the forwarding of the sw instruction
tsw:
  addi $v1, $zero, 6
  add  $t0, $s1, $zero  # generate a value to t0 which equals to 2
  sw   $t0, 0($a0)    # we generated in the previous instruction the value 2 to $t0 which will be ready to be passed in the third stage after the alu. So the sw which needs it in the fourth stage will not have any problem.For this reason there is no need to put a nop instruction between them.   
  lw   $t1, 0($a0)    # load back the value from memory, to check it
  # between the lw and the beq instructions there is a need for two no operation instructions.
  # beacause the lw instruction wont produce the result until the end of the memory stage we need to stall for 2 circles the decode of the branch istruction
  add  $t2, $t2, $t2  # nop (dummy)
  add  $t2, $t2, $t2  # nop (dummy)
  beq  $t0, $t1, tb2  # should be taken if the fwd logic is correct.   
  j    exit

# ----------------------------------------------------------------------------------------  
# check the forwarding of branch instruction 
tb2:
  addi $v1, $zero, 7
  add  $t0, $zero, $zero  # generate a value to t0 which equals to 0
  # i decided to individually check the beq instruction although it is tested before
  # the beq instruction needs to be stalled for a circle at the decode stage before it get the value from the add instruction from the execute stage.
  add  $t2, $t2, $t2  # nop (dummy)
  beq  $t0, $zero, tb1  # should be taken if the fwd logic is correct.
  j    exit
  
# ----------------------------------------------------------------------------------------  
# -to input B of beq comparator
tb1:
  addi $v1, $zero, 8
  add  $t0, $zero, $zero  # generate a value to t0 which equals to 0
  # i decided to individually check the beq instruction although it is tested before
  # the beq instruction needs to be stalled for a circle at the decode stage before it get the value from the add instruction from the execute stage.
  add  $t2, $t2, $t2  # nop (dummy)
  beq  $zero, $t0, tlwA  # should be taken if the fwd logic is correct.
  j    exit
  
# ----------------------------------------------------------------------------------------  
## check the forwarding of the lw instruction
# -to input A of ALU
tlwA:
  addi $v1, $zero, 9
  lw   $t0, 0($a0)
  #the lw instruction doesnt produce its results until the memory stage so we have to stall one cyrcle
  add  $t2, $t2, $t2  # nop (dummy)
  add  $t1, $t0, $zero
  add  $t2, $t2, $t2  # nop (dummy) 
  #stall for beq
  beq  $t1, $t0, tlwB  # should be taken if the fwd logic is correct.
  j    exit

# -to input B of ALU
tlwB:
  addi $v1, $zero, 10
  lw   $t0, 0($a0)
  #the lw instruction doesnt produce its results until the memory stage so we have to stall one cyrcle
  add  $t2, $t2, $t2  # nop (dummy)
  add  $t1, $zero, $t0
  add  $t2, $t2, $t2  # nop (dummy) 
  #stall for beq
  beq  $t1, $t0, tlwlw  # should be taken if the fwd logic is correct.
  j    exit

# ----------------------------------------------------------------------------------------  
## check the forwarding of the lw instruction followed by another load word
tlwlw:
  addi $v1, $zero, 11
  lw   $t0, 0($a0)
  add  $t4, $t4, $t4  # nop (dummy)
  #the lw instruction doesnt produce its results until the memory stage so we have to stall one cyrcle
  # because the next load word has to use it for the increment in the exe stage (similar to the previous test).
  lw   $t1, 4($a0)
  add  $t4, $t4, $t4  # nop (dummy)
  add  $t2, $zero, $t0
  add  $t3, $zero, $t1
  add  $t4, $t4, $t4  # nop (dummy)
  #stall for beq
  beq  $t2, $t0, tlwlw2  # should be taken if the fwd logic is correct.
  j    exit
tlwlw2:
  add  $t4, $t4, $t4  # nop (dummy)
  add  $t4, $t4, $t4  # nop (dummy)
  beq  $t1, $t3, tlwbr  # should be taken if the fwd logic is correct.
  j    exit
  
# ----------------------------------------------------------------------------------------  
### test forwarding from DMEM (lw) to branch  (this test already checked also before)
tlwbr:  
  addi $v1, $zero, 12
  lw   $t0, 0($a0)
  # between the lw and the beq instructions there is a need for two no operation instructions.
  # beacause the lw instruction won't produce the result until the end of the memory stage we need to stall for 2 circles the decode of the branch istruction
  add  $t4, $t4, $t4  # nop (dummy)
  add  $t4, $t4, $t4  # nop (dummy)
  beq  $t0, $s1, tlbB
  j    exit
# ---------------------
# -to input B of beq comparator
tlbB:
  addi $v1, $zero, 13
  lw   $t0, 0($a0)
  add  $t4, $t4, $t4  # nop (dummy)
  add  $t4, $t4, $t4  # nop (dummy)
  beq  $s1, $t0, tlwsw
  j    exit

# ----------------------------------------------------------------------------------------  
# test forwarding from DMEM (lw) to DMEM (sw)
tlwsw:  
  addi $v1, $zero, 14
  lw   $t0, 0($a0) 
  #there is no need to stall 
  sw   $t0, 8($a0)   # this should store 2,(prev value @mem = 11)
  lw   $t1, 8($a0)   # load back the value from memory, to check it
  add  $t4, $t4, $t4  # nop (dummy)
  add  $t4, $t4, $t4  # nop (dummy)
  beq  $t0, $t1, tlzero
  j    exit

# ----------------------------------------------------------------------------------------  
#  check fwr of $zero register
tlzero:
  addi $v1, $zero, 15
  add  $zero, $s1,   $s2  # generate the value **not** to be forwarded (=5)
  add  $s4,   $zero, $s1  # $s4 should be == $s1, unless $zero gets forwarded here from the above instruction
  add  $t4, $t4, $t4  # nop (dummy)
  add  $t4, $t4, $t4  # nop (dummy)
  beq  $s4,   $s1, tzerosw  # should be taken if the fwd logic is correct. Note: bne is not implemented
  j    exit  
# ----------------------------------------------------------------------------------------  
# test forwarding of $zero to sw  rt  register, in case there is a special forwarding path
tzerosw:  
  addi $v1,   $zero, 16
  add  $zero, $s1,   $s2
  sw   $zero, 0($a0)  # this should store 0, not 2 into memory
  lw   $t0,   0($a0)  # load back the value from memory, to check it
  add  $t4, $t4, $t4  # nop (dummy)
  add  $t4, $t4, $t4  # nop (dummy)
  beq  $t0,   $s3, tzerolw  # I avoid using $zero here, so I use $s3 which is set to 0
  j    exit  
  
# ----------------------------------------------------------------------------------------                
#test forwarding of $zero from DMEM (lw) to ALU instruction                       
tzerolw:                               
  addi $v1,   $zero, 17
  lw   $zero, 4($a0)      # The loaded value (10) should be ignored.
  add  $t4, $t4, $t4  # nop (dummy)
  add  $s4,   $zero, $s1  # check if $zero is wrongly forwarded here
  add  $t4, $t4, $t4  # nop (dummy)
  add  $t4, $t4, $t4  # nop (dummy)
  beq  $s4,   $s1, jump
  j    exit                                      
         
# ----------------------------------------------------------------------------------------                                                                       
#test forwarding of jump instruction
jump:
  addi $v1,   $zero, 18
  #here we have the branch instruction fetched and then decode
  #in parallel the addi instruction is been fetched
  #because there is no branch delay .The addi must be stalled from execution in order for the jump to be executed first
  #for the above reason a nop is between them
  j pass                                                                                                                                                   
  add  $t4, $t4, $t4  # nop (dummy)
  addi $t0, $zero, 1  #this instruction doesnt execute,nor decoded only gets fetched.
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
pass:    
  add  $v1,$zero, $zero  # previous write to zero is too far to affect this
  
#exit all went well
exit:  # Check $v1. 0 means all tests pass, any other value is a unique error
    addiu      $v0, $zero, 10    # system service 10 is exit
    syscall
