.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:

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

    mv s0, a0 # storing a0
    mv s1, a1 # storing a1
    mv s2, a2 # storing a2
    mv s3, a3 # storing a3

    # preparing call to fopen
    mv a1, a0
    li a2, 1
    jal fopen
    li t0, -1
    beq a0, t0, error_fopen
    mv s4, a0 # store file descriptor to s4

    mul s5, s2, s3 # total number of elements

    li s6, 1

    mv a1, s4
    addi sp, sp, -4
    sw s2, 0(sp)
    mv a2, sp
    li a3, 1
    li a4, 4
    jal fwrite
    addi sp, sp, 4
    bne a0, s6, error_fwrite

    mv a1, s4
    addi sp, sp, -4
    sw s3, 0(sp)
    mv a2, sp
    li a3, 1
    li a4, 4
    jal fwrite
    addi sp, sp, 4
    bne a0, s6, error_fwrite

    mv s6, s5
    mv a1, s4
    mv a2, s1
    mv a3, s5
    li a4, 4
    jal fwrite
    bne a0, s6, error_fwrite

    mv a1, s4
    jal fclose
    bne a0, zero, error_fclose

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

error_fopen:
    li a1, 93
    jal exit2
error_fwrite:
    li a1, 94
    jal exit2
error_fclose:
    li a1, 95
    jal exit2
