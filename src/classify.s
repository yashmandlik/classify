.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    # Error handling
    li t0, 5
    bne a0, t0, error_cmd

    # Prologue
    addi sp, sp, -52
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

    mv s0, a1
    mv s1, a2

	# =====================================
    # LOAD MATRICES
    # =====================================
    # pointers to matrix sizes
    li a0, 4
    jal malloc
    beq a0, zero, error_malloc
    mv s2, a0 # num rows of m0

    li a0, 4
    jal malloc
    beq a0, zero, error_malloc
    mv s3, a0 # num cols of m0

    # Load pretrained m0
    lw a0, 4(s0) # file path for m0
    mv a1, s2
    mv a2, s3
    jal read_matrix
    mv s4, a0 # ptr to m0

    li a0, 4
    jal malloc
    beq a0, zero, error_malloc
    mv s5, a0 # num rows of m1

    li a0, 4
    jal malloc
    beq a0, zero, error_malloc
    mv s6, a0 # num cols of m1

    # Load pretrained m1
    lw a0, 8(s0) # file path for m1
    mv a1, s5
    mv a2, s6
    jal read_matrix
    mv s7, a0 # ptr to m1

    li a0, 4
    jal malloc
    beq a0, zero, error_malloc
    mv s8, a0 # num rows of input

    li a0, 4
    jal malloc
    beq a0, zero, error_malloc
    mv s9, a0 # num cols of input

    # Load input matrix
    lw a0, 12(s0) # file path for input matrix
    mv a1, s8
    mv a2, s9
    jal read_matrix
    mv s10, a0 # ptr to input

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # matrix multiplication
    lw t0, 0(s2)
    lw t1, 0(s9)
    mul t0, t0, t1
    slli a0, t0, 2
    jal malloc
    beq a0, zero, error_malloc
    mv s11, a0
    
    mv a0, s4 # ptr to m0
    lw a1, 0(s2)
    lw a2, 0(s3)
    mv a3, s10 # ptr to input
    lw a4, 0(s8)
    lw a5, 0(s9)
    mv a6, s11
    jal matmul

    # relu
    mv a0, s11 # relu on result
    lw t0, 0(s2)
    lw t1, 0(s9)
    mul a1, t0, t1
    jal relu

    # matrix multiplication
    lw t0, 0(s5)
    lw t1, 0(s9)
    mul t0, t0, t1 
    slli a0, t0, 2
    jal malloc
    beq a0, zero, error_malloc
    addi sp, sp, -4
    sw a0, 0(sp)
    
    mv a0, s7 # ptr to m1
    lw a1, 0(s5)
    lw a2, 0(s6)
    mv a3, s11 # ptr to relu-ed vector
    lw a4, 0(s2)
    lw a5, 0(s9)
    lw a6, 0(sp)
    jal matmul

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    lw a0, 16(s0)
    lw a1, 0(sp)
    lw a2, 0(s5)
    lw a3, 0(s9)
    jal write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    lw a0, 0(sp)
    lw t0, 0(s5)
    lw t1, 0(s9)
    mul a1, t0, t1
    jal argmax
    addi sp, sp, -4
    sw a0, 0(sp)
    # Print classification
    bne s1, zero, skip_print
    mv a1, a0
    jal print_int
    # Print newline afterwards for clarity
    addi a1, zero, '\n'
    jal print_char
skip_print:
    lw a0, 0(sp)
    addi sp, sp, 8

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

error_cmd:
    li a1, 89
    jal exit2
error_malloc:
    li a1, 88
    jal exit2