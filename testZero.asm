# ----------------------------------------------------------------------------------------
# testZero.asm 
#  Verifies that a calculated or loaded non-zero value onto register $zero is never
#  forwarded to any of the following instructions
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
    addi $s0, $zero, 0
    addi $s1, $zero, 1
    addi $s2, $zero, 2
    addi $s3, $zero, 3

# ----------------------------------------------------------------------------------------
# test forwarding of $zero from the previous ALU instruction. Should not happen!
# -to input A of ALU
    addi $v1,   $zero, 1     
    add  $zero, $s1,   $s2  # generate the value **not** to be forwarded (=3)
    add  $s4,   $zero, $s1  # $s4 should be == $s1, unless $zero gets forwarded here from the above instruction
    add  $t1,   $s1,   $s2  # dummy instruction
    add  $t1,   $s1,   $s2  # added 2 dummy instructions here to avoid testing if $s4 gets forwarded to branch
    beq  $s4,   $s1,   t1B  # should be taken if the fwd logic is correct. Note: bne is not implemented
    j    exit               # exit with code 1 in v1, if zero was forwarded
# ---------------------
# -to input B of ALU. Same code as above, just using the other ALU input
t1B:
    addi $v1,   $zero, 2
    add  $zero, $s1,   $s2
    add  $s4,   $s1,   $zero 
    add  $t1,   $s1,   $s2  # dummy instruction
    add  $t1,   $s1,   $s2  # dummy instruction
    beq  $s4,   $s1,   t2A
    j    exit
# ----------------------------------------------------------------------------------------
# test forwarding of $zero from ALU instruction 2 slots back. Should not happen!
#  Similar to previous test. Just adding 1 instruction between instruction writing to $zero, 
#   and instruction reading $zero
# -to input A of ALU
t2A:
    addi $v1,   $zero, 3
    add  $zero, $s1,   $s2
    add  $t1,   $s1,   $s2  # dummy instruction 
    add  $s4,   $zero, $s1  # This instruction checks $zero forwarding
    add  $t1,   $s1,   $s2  # dummy instruction
    add  $t1,   $s1,   $s2  # dummy instruction
    beq  $s4,   $s1,   t2B
    j    exit
# ---------------------
# -to input B of ALU
t2B:
    addi $v1,   $zero, 4
    add  $zero, $s1,   $s2
    add  $t1,   $s1,   $s2  # dummy instruction
    add  $s4,   $s1,   $zero 
    add  $t1,   $s1,   $s2  # dummy instruction
    add  $t1,   $s1,   $s2  # dummy instruction
    beq  $s4,   $s1,   tsw
    j    exit

# ----------------------------------------------------------------------------------------
# test forwarding of $zero to sw  rt  register, in case there is a special forwarding path
tsw:
    addi $v1,   $zero, 5
    add  $zero, $s1,   $s2
    sw   $zero, 0($a0)  # this should store 0, not 3 into memory
    lw   $t0,   0($a0)  #   load back the value from memory, to check it
    add  $t1,   $s1,   $s2  # dummy instruction
    add  $t1,   $s1,   $s2  # dummy instruction
    beq  $t0,   $s0,   tb2  # I avoid using $zero here, so I use $s0 which is set to 0
    j    exit

# ----------------------------------------------------------------------------------------
# test forwarding of $zero from ALU to branch. 
#  A dummy instruction is inserted between add $zero and beq so that beq is not stalled for 
#    one cycle (Stall pipeline logic is not tested here)
# -to input A of beq comparator
tb2:
    addi $v1,   $zero, 6
    add  $zero, $s1,   $s2
    add  $t1,   $s1,   $s2  # dummy instruction
    beq  $zero, $s3,   exit # Check if 3 is forwarded to $zero by mistake!
# --------------------- 
# -to input B of beq comparator
    addi $v1,   $zero, 7
    add  $zero, $s1,   $s2
    add  $t1,   $s1,   $s2  # dummy instruction
    beq  $s3,   $zero, exit # Check if 3 is forwarded to $zero by mistake!

# ----------------------------------------------------------------------------------------
# test forwarding of $zero from DMEM (lw) to ALU instruction. 
#  A dummy instruction is inserted between lw $zero and the consumer instruction so that
#  the consumer instr is not stalled for one cycle (Stall pipeline logic is not tested here)
# -to input B of ALU
    addi $v1,   $zero, 8
    lw   $zero, 4($a0)      # The loaded value (10) should be ignored.
    add  $t1,   $s1,   $s2  # dummy instruction
    add  $s4,   $zero, $s1  # check if $zero is wrongly forwarded here
    add  $t1,   $s1,   $s2  # dummy instruction
    add  $t1,   $s1,   $s2  # dummy instruction
    beq  $s4,   $s1,   tlwB
    j    exit
# ---------------------
# -to input B of ALU
tlwB:
    addi $v1,   $zero, 9
    lw   $zero, 4($a0)       # The loaded value (10) should be ignored.
    add  $t1,   $s1,   $s2  # dummy instruction
    add  $s4,   $s1,   $zero  # check if $zero is wrongly forwarded here
    add  $t1,   $s1,   $s2  # dummy instruction
    add  $t1,   $s1,   $s2  # dummy instruction
    beq  $s4,   $s1,   tlwbr
    j    exit

# ----------------------------------------------------------------------------------------
# test forwarding of $zero from DMEM (lw) to branch. 
#  Must have 2 instructions between lw and beq, else beq will stall for 2 cycles
# -to input A of beq comparator
tlwbr:
    addi $v1,   $zero, 10
    lw   $zero, 4($a0)
    add  $t1,   $s1,   $s2  # dummy instruction
    add  $t1,   $s1,   $s2  # dummy instruction
    beq  $zero, $s0,   tlbB
    j    exit
# ---------------------
# -to input B of beq comparator
tlbB:
    addi $v1,   $zero, 11
    lw   $zero, 4($a0)
    add  $t1,   $s1,   $s2  # dummy instruction
    add  $t1,   $s1,   $s2  # dummy instruction
    beq  $s0,   $zero, tlwsw
    j    exit

# ----------------------------------------------------------------------------------------
# test forwarding of $zero from DMEM (lw) to DMEM (sw)
tlwsw:
    addi $v1,   $zero, 12
    lw   $zero, 4($a0)
    sw   $zero, 8($a0)  # this should store 0, not 10 into memory (prev value @mem = 11)
    lw   $t0,   8($a0)  #   load back the value from memory, to check it
    add  $t1,   $s1,   $s2  # dummy instruction
    add  $t1,   $s1,   $s2  # dummy instruction
    beq  $t0,   $s0,   pass # I avoid using $zero here, so I use $s0 which is set to 0
    j    exit

pass:
    add  $v1,   $zero, $zero  # previous write to zero is too far to affect this

exit:  # Check $v1. 0 means all tests pass, any other value is a unique error
    addiu      $v0, $zero, 10    # system service 10 is exit
    syscall

