################################################################################
# bootstrap.s -- Reset code and trap handlers.
#
# This is the boot code for all applications, includes reset code and basic trap 
# handler with calls for all the trap causes.
#
# Initializes the caches and jumps to 'entry' in kernel mode and with interrupts
# disabled.
#
# This code is meant to be placed at the reset vector address (0xbfc00000).
#-------------------------------------------------------------------------------
# FIXME: exception handling is incomplete (nothing is done on exception).
################################################################################

    #---- Cache parameters -----------------------------------------------------
    .set ICACHE_NUM_LINES, 256              # no. of lines in the I-Cache
    .set DCACHE_NUM_LINES, 256              # no. of lines in the D-Cache
    .set DCACHE_LINE_SIZE, 4                # D-Cache line size in words

    #---------------------------------------------------------------------------

    .text
    .align  2
    .global reset
    .ent    reset
reset:
    .set    noreorder

    b       start_boot
    nop

    #--- Trap handler ----------------------------------------------------------
    
    # We have three trap sources: syscall, break and unimplemented opcode
    # Plus we have to account for a faulty cause code; that's 4 causes.
    # Besides, we have to look out for the branch delay flag (BD).
    .org    0x0180
interrupt_vector:
    mfc0    $k0,$13             # Get trap cause code
    srl     $k0,$k0,2
    andi    $k0,$k0,0x01f
    ori     $k1,$zero,0x8       # was it a syscall?
    beq     $k0,$k1,trap_syscall
    addi    $k1,$k1,0x1         # was it a break?
    beq     $k0,$k1,trap_break
    addi    $k1,$k1,0x1         # was it a bad opcode?
    bne     $k0,$k1,trap_invalid
    nop
    
    # Unimplemented instruction
trap_unimplemented:
    .ifdef  NO_EMU_MIPS32
    j       trap_return         # FIXME should flag the bad opcode?
    nop
    .else
    j       opcode_emu
    nop
    .endif

    # Break instruction
trap_break:
    j       trap_return         # FIXME no support for break opcode
    nop
    
    # Syscall instruction
trap_syscall:
    j       trap_return         # FIXME no support for syscall opcode
    nop

    # Invalid trap cause code, most likely hardware bug
trap_invalid:
    j       trap_return         # FIXME should do something about this
    nop

trap_return:
    mfc0    $k1,$14             # C0_EPC=14 (Exception PC)
    mfc0    $k0,$13             # Get bit 31 (BD) from C0 cause register
    srl     $k0,31
    andi    $k0,$k0,1
    bnez    $k0,trap_return_delay_slot
    addi    $k1,$k1,4           # skip trap instruction
    jr      $k1
    nop
trap_return_delay_slot:
    addi    $k1,$k1,4           # skip jump instruction too
    jr      $k1                 # (we just added 8 to epc)
    rfe
    
    
#-------------------------------------------------------------------------------

start_boot:
    mfc0    $a0,$12
    andi    $a0,$a0,0xfffe
    mtc0    $a0,$12             # disable interrupts, disable cache

    jal     setup_cache         # Initialize the caches
    nop

    # Hardware initialization done. Now we should jump to the main program.
    # Note that if this file was linked separately from the main program (for
    # example to be loaded in different memory areas) then the makefile will
    # have to provide a suitable value for symbol 'entry'.
    la      $a0,entry
    jr      $a0
    nop
    # We won't be coming back...


#---- Functions ----------------------------------------------------------------

# void setup_cache(void) -- invalidates all I-Cache lines (uses no RAM)
setup_cache:
    lui     $a1,0x0001      # Disable cache, enable I-cache line invalidation
    mfc0    $a0,$12
    andi    $a0,$a0,0xffff
    or      $a1,$a0,$a1
    mtc0    $a1,$12
    
    # In order to invalidate a I-Cache line we have to write its tag number to 
    # any address while bits CP0[12].17:16=01. The write will be executed as a
    # regular write too, as a side effect, so we need to choose a harmless 
    # target address.
    
    li      $a0,XRAM_BASE
    li      $a2,0
    li      $a1,ICACHE_NUM_LINES-1
    
inv_i_cache_loop:
    sw      $a2,0($a0)
    blt     $a2,$a1,inv_i_cache_loop
    addi    $a2,1
    
    # Now, the D-Cache is different. To invalidate a D-Cache line you just 
    # read from it (by proper selection of a dummy target address)  while bits 
    # CP0[12].17:16=01. The data read is undefined and should be discarded.

    li      $a0,0               # Use any base address that is mapped
    li      $a2,0
    li      $a1,DCACHE_NUM_LINES-1
    
inv_d_cache_loop:
    lw      $zero,0($a0)
    addi    $a0,DCACHE_LINE_SIZE*4
    blt     $a2,$a1,inv_d_cache_loop
    addi    $a2,1    
    
    lui     $a1,0x0002          # Leave with cache enabled
    mfc0    $a0,$12
    andi    $a0,$a0,0xffff
    or      $a1,$a0,$a1
    jr      $ra
    mtc0    $a1,$12

    .set    reorder
    .end    reset
