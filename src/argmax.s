.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:
    # Error handling
    addi t0, zero, 1 # updating t0 to 1
    blt a1, t0, excpLen # check if length of arr is less than 1
    
    # Prologue
    addi sp, sp, -4 # creating space on the stack to store ra
    sw ra, 0(sp) # storing ra

    addi a4, a0, 0 # pointer
    addi a3, zero, 0 # iterate through array
    lw a2, 0(a4) # initialize max val with the first val
    addi a6, zero, 0 # result index
loop_start:
    lw a5, 0(a4) # load word into a5
    blt a5, a2, loop_continue # if curr val is less than max val, do nothing
    beq a5, a2, loop_continue # if curr val is equal to max val, do nothing
    mv a6, a3
    mv a2, a5
loop_continue:
    addi a4, a4, 4 # move to the next element
    addi a3, a3, 1 # increase count by 1
    blt a3, a1, loop_start # looping while a3 < a1
loop_end:
    mv a0, a6
    # Epilogue
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
excpLen:
    li a1, 77
    jal exit2
