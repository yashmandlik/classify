.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
read_matrix:
    # Prologue
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)

    # storing a0, a1, a2
    mv s0, a0 # ptr to string rep filename
    mv s1, a1 # ptr to num rows
    mv s2, a2 # ptr to num cols

    # preparing to call fopen
    mv a1, s0 
    li a2, 0
    jal fopen # returns file descriptor to a0
    li t0, -1
    beq a0, t0, error_fopen
    mv s3, a0 # store file descriptor

    # preparing call to fread
    # read matrix dimensions
    mv a1, s3 # a1 is the file descriptor
    li a0, 8 # assigning 8 bytes for malloc
    jal malloc # returns ptr to allocated memory to a0
    beq a0, zero, error_malloc
    mv s5, a0 # store ptr to memory
    mv a1, s3
    mv a2, a0
    li a3, 8 # specify number of bytes to be read from file
    jal fread
    li a3, 8
    bne a0, a3, error_fread
    
    # read matrix elements
    lw t1, 0(s5)
    lw t2, 4(s5)
    sw t1, 0(s1) # store num rows
    sw t2, 0(s2) # store num cols
    mul t3, t1, t2 # total number of elements
    li t4, 4
    mul t3, t3, t4 # size of t3 elements
    mv s6, t3 # store number of bytes
    mv a0, t3 # number of bytes to be allocated
    jal malloc # returns ptr to allocated memory to a0
    beq a0, zero, error_malloc
    mv s4, a0 # store ptr to matrix elements
    mv a1, s3
    mv a2, a0
    mv a3, s6
    jal fread
    bne a0, s6, error_fread
    mv a1, s3
    jal fclose
    bne a0, zero, error_fclose 
    mv a1, s1
    mv a2, s2
    mv a0, s4
    
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    addi sp, sp, 32

    ret

error_malloc:
    li a1, 88
    jal exit2
error_fopen:
    li a1, 90
    jal exit2
error_fread:
    li a1, 91
    jal exit2
error_fclose:
    li a1, 92
    jal exit2