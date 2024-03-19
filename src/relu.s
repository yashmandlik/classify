.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    # Error handling
    addi t0, zero, 1 # updating t0 to 1
    blt a1, t0, excpLen # check if length of arr is less than 1
    
    # Prologue
    addi sp, sp, -4 # creating space on the stack to store ra
    sw ra, 0(sp) # storing ra
    
    addi a4, a0, 0 # pointer to each element in array
    addi a3, zero, 0 # counter for every element in array
loop_start:
    lw a5, 0(a4) # load the value at address into a5
    bge a5, zero, loop_continue # check if value is greater that zero
    mv a5, zero # if less than zero, set it to zero
    sw a5, 0(a4) # store the value back at the address
loop_continue:
    addi a4, a4, 4 # increment the pointer by 4 to go to the next element
    addi a3, a3, 1 # increment the num elements by 1
    blt a3, a1, loop_start # if curr num elements is less than total num elements, continue
loop_end:
    lw ra, 0(sp) 
    addi sp, sp, 4
	ret
excpLen:
    li a1, 78 # error code 78
    jal exit2