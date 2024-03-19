.globl dot

.data
msg: .string "Stride greater than array length"

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:
    # Error handling
    addi t0, zero 1 # updating t0 to 1
    blt a2, t0, excpLen # check if length of the arrays is less than 1
    blt a3, t0, excpStride # check if stride of v0 is less than 1
    blt a4, t0, excpStride # check if stride of v1 is less than 1
    blt a2, a3, excpError # check if stride of v0 is greater than length of vector
    blt a2, a4, excpError # check if stride of v1 is greater than length of vector

    # Prologue
    addi sp, sp, -4 # creating space on the stack to store ra
    sw ra, 0(sp) # storing current value in ra
    
    addi a5, a0, 0 # pointer for v0
    addi a6, a1, 0 # pointer for v1
    addi a7, zero, 0 # iterator
    addi t0, zero, 0 # return value

    slli t4, a3, 2 # stride for v0 (bytes)
    slli t5, a4, 2 # stride for v1 (bytes)
    
loop_start:
    lw t1, 0(a5) # load val from v0
    lw t2, 0(a6) # load val from v1
    mul t3, t1, t2 # multiply t1 and t2
    add t0, t0, t3 # add it to t0
    add a5, a5, t4 # move to next elem based on stride
    add a6, a6, t5 # move to next elem based on stride
    addi a7, a7, 1 # increment counter
    blt a7, a2, loop_start
loop_end:
    mv a0, t0 # store result in a0
    # Epilogue
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
excpLen:
    li a1, 75
    jal exit2
excpStride:
    li a1, 76
    jal exit2
excpError:
    la a1, msg
    jal print_str
    jal exit