################################################################
#
#  Pseudocode:
#     int rSize = 4;
#     int cSize = 4;
#     int[rSize][cSize] data;
#     int value = 1;
#     for (int col = 0; col < cSize; col++) {
#        for (int row = 0; row < rSize; row++) }
#           data[row][col] += value;
#        }
#     }
#
        .data
data:   .word     0 : 256       # max 16x16 matrix of words

        .text
        addi $a0, $zero, 2         # $a0 = log2(number of columns)
        addi $a1, $zero, 4         # $a1 = number of columns
        addi $a2, $zero, 4         # $a2 = number of rows
        la   $s7, data             # $s7 = &data
        addi $s3, $zero, 1         # 

        add  $s0, $zero, $zero      # columnwCounter = 0
cLoop:  beq  $s0, $a1,   done
        add  $s1, $zero, $zero      # rowCounter = 0
rLoop:  beq  $s1, $a2,   nextR
        # Calculate address of data[rowCounter][columnCounter]
        #  &data + (rowCounter * #cols + columnCounter) * 4
        sllv $t0, $s1,   $a0  # rowCounter * #cols  -- a0 is log2(a1)
        add  $t0, $t0,   $s0  # + columnCounter
        sll  $t0, $t0,   2    # *4
        add  $t0, $t0,   $s7  # + &data
        lw   $t1, 0($t0)
        add  $t1, $t1,   $s3
        sw   $t1, 0($t0)
        addi $s1, $s1,   1   # rowCounter += 1
        j    rLoop
nextR:
        addi $s0, $s0,   1   # columnCounter += 1
        j    cLoop
done:
        li       $v0,   10     # system service 10 is exit
        syscall                # we are outta here.
