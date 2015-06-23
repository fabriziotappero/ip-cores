#-------------------------------------------------------------------------------
# startup.s -- C startup code common to all C programs.
#
# This code does the following:
# 1.- Initialize the stack at the end of the bss area
# 2.- Clear the bss area
# 3.- Move the data section from FLASH to RAM (if applicable)
# 4.- Call main()
# 5.- Freeze in endless loop after main() returns, if it does
#
# The code does not initialize the caches or the hardware and does not include
# the reset or trap vectors.
#
# This code was inherited from OpenCores' Plasma project.
#-------------------------------------------------------------------------------

    # The stack size can be defined from the assembler command line
    # FIXME should use info from the link script
    .ifndef STACK_SIZE
    .set    STACK_SIZE,         1024        # by default, reserve 1KB
    .endif

    # Reserve space for regular stack (BSS segment)
    .comm init_stack, STACK_SIZE

    .text
    .align 2
    .global entry
    .ent    entry
entry:
    .set noreorder
    
    # (The linker script defined these symbols)
    la      $gp, _gp                # initialize global pointer
    la      $5, __bss_start         # $5 = .sbss_start
    la      $4, _end                # $2 = .bss_end
    la      $sp, init_stack+STACK_SIZE-24 #initialize stack pointer
    
    # Clear BSS area
$BSS_CLEAR:
    sw      $0, 0($5)
    slt     $3, $5, $4
    bnez    $3, $BSS_CLEAR
    addiu   $5, $5, 4

    # Move data section image from flash to RAM, if necessary.
    la      $a0,data_start
    la      $a1,data_load_start
    beq     $a1,$a0,move_data_section_done
    nop
    la      $s0,data_size
    beqz    $s0,move_data_section_done
    nop
move_data_section_loop:
    lw      $t0,0($a1)
    addiu   $a1,$a1,4
    sw      $t0,0($a0)
    addiu   $a0,$a0,4
    bgtz    $s0,move_data_section_loop
    addiu   $s0,$s0,-4
move_data_section_done:
    
    jal     main                    # init done; call main()
    nop
$L1:
    j       $L1
    nop

    .end     entry
   
