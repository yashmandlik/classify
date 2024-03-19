.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:
    # Error checks
    li t0, 1                    # set t0 to 1
    blt a1, t0, dim_m0          # checking dimensions of m0
    blt a2, t0, dim_m0          # checking dimensions of m0
    blt a4, t0, dim_m1          # checking dimensions of m1
    blt a5, t0, dim_m1          # checking dimensions of m1
    bne a2, a4, dim_mismatch    # checking if # of cols of m0 equal # of rows on m1
    
    # Prologue
    addi sp, sp, -52    # storing register values
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)
    sw s10, 44(sp)
    sw s11, 48(sp)
    
    mv s0, a0           # s0 points to m0
    mv s1, a1           # s1 is the # of rows of m0
    mv s2, a2           # s2 is the # of columns of m0
    mv s3, a3           # s3 points to m1
    mv s4, a4           # s4 is the # of rows for m1
    mv s5, a5           # s5 is the # of cols for m1
    mv s6, a6           # s6 is the pointer to d

    li s7, 0            # counter for m0
    li s8, 0            # counter for m1
    mv s9, a0           # iterator for m0
    mv s10, a3          # iterator for m1
    mv s11, a6          # iterator for result

    # Preparing to call dot.s
    mv a0, s0           # a0 is v0
    mv a1, s3           # a1 is v1
    mv a2, s2           # length of vector
    li a3, 1            # stride for v0
    mv a4, s5           # stride for v1 (equals the # of cols)
    j inner_loop_start

outer_loop_start:
    li t0, 4 
    mul t1, t0, s2      # memory address of next row
    add s9, s9, t1      # move to next row
    li s8, 0            # reset counter for m1
    mv a0, s9           # set a0 to next row
    mv s10, s3          # set s10 to first col
    mv a1, s10          # set a1 to s10
    mv a2, s2           # set length of vectors to s2
    li a3, 1            # set stride of v0 to 1
    mv a4, s5           # set stride of v1 to # of cols
    addi s7, s7, 1      # increment s7
    bge s7, s1, outer_loop_end
inner_loop_start:
    jal dot             # multiply the two vectors
    sw a0, 0(s11)       # store result in s11
    mv a0, s9           # restore a0 to v0
    addi s10, s10, 4    # move t1 to next element
    mv a1, s10          # set a1 to t1
    mv a2, s2           # restore a2
    li a3, 1            # restore a3
    mv a4, s5           # restore a4
    addi s11, s11, 4    # move result pointer to next address
    addi s8, s8, 1      # counter++
    blt s8, s5, inner_loop_start
inner_loop_end:
    j outer_loop_start
outer_loop_end:
    mv a6, s6

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    lw s10, 44(sp)
    lw s11, 48(sp)
    addi sp, sp, 52
    ret

dim_m0:
    li a1, 72
    jal exit2
dim_m1:
    li a1, 73
    jal exit2
dim_mismatch:
    li a1, 74
    jal exit2