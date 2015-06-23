#-------------------------------------------------------------------------------
# opcode_emu.s -- Emulation of some mips-32 opcodes in trap handler
#
# Operation:
# 1.- If the trapped opcode is one of the emulated opcodes, it is emulated.
# 2.- Otherwise, nothing is done (as if the trapped opcode was a NOP) and a flag
#     is set in the emu_frame area (meant for debugging, mostly).
# 3.- In either case, if the trapped opcode is in a jump delay slot, the jump
#     instruction is emulated. 
#     FIXME it isn't yet
#
# Uses a small workspace in the BSS section. Does NOT use the regular stack
# nor makes any assumptions about any registers, including the sp.
#
#-------------------------------------------------------------------------------
# This is a trap handler meant to emulate those few MIPS32r1/r2 opcodes that
# gcc commonly emits even for a -mips1 target. This happens specially when using
# soft floating point.
# The opcodes chosen for emulation are those actually observed in real gcc 
# programs. This is easier, for the time being, than replacing a whole host of
# gcc support functions.
#
# Emulates the following opcodes:
#   EXT, INS, CLO, CLZ
#
# FIXME these opcodes will be emulated eventually:
#   MUL (3-reg version), LWL, LWR, SWL, SWR
#-------------------------------------------------------------------------------

    # Size of work space
    .set EMU_FRAME_SIZE, 64

    # Reserve work space in BSS segment
    .comm emu_frame, EMU_FRAME_SIZE

    .text
    .align  2
    .set    noreorder

    .global opcode_emu
    # $k0 = cp0.cause on entry, other registers have their original value
opcode_emu:
    # Save the CPU state.
    # No nested exceptions are to be allowed, so we only save the registers 
    # we're going to use and leave the CP0 registers unsaved.
    la      $k1,emu_frame+EMU_FRAME_SIZE-4
    sw      $sp,-16($k1)
    sw      $ra,-20($k1)
    sw      $t0,-24($k1)
    sw      $t1,-28($k1)
    sw      $t2,-32($k1)
    move    $sp,$k1

    mfc0    $t0,$14             # get bad opcode (or branch opcode if in DS)
    lw      $k0,0($t0)
    
    # Handle delay slot situation: emulate jump if necessary
    mfc0    $k1,$13             # Check bit 31 (BD) from C0 cause register
    bltzal  $k1,emulate_branch
    nop
    
    # decode instruction: either SPECIAL3 or SPECIAL2
    srl     $t1,$k0,26
    xori    $t0,$t1,0x01f
    beqz    $t0,mips32_special3
    xori    $t0,$t1,0x01c
    beqz    $t0,mips32_special2
    nop
    # if it was none of the above we will just ignore it
    # Write ignored opcode to some debug register for external reference
    # (this is to be used bu the SW simulator, mostly)
    li      $t0,0x20010000
    sw      $k0,1024($t0)
    # Run into opcode_emu_return
    
opcode_emu_return:
    # restore modified registers
    lw      $t2,-32($sp)
    lw      $t1,-28($sp)
    lw      $t0,-24($sp)
    lw      $ra,-20($sp)
    lw      $sp,-16($sp)
    # return to interrupted code, handling trap-in-delay-slot cases properly
    mfc0    $k1,$14             # C0_EPC=14 (Exception PC)
    mfc0    $k0,$13             # Get bit 31 (BD) from C0 cause register
    srl     $k0,31
    andi    $k0,$k0,1
    bnez    $k0,mips32_emu_return_delay_slot
    addi    $k1,$k1,4           # skip 'victim' instruction
    jr      $k1
    nop
mips32_emu_return_delay_slot:
    addi    $k1,$k1,4           # skip jump instruction too (it's been emulated)
    jr      $k1                 # (we just added 8 to epc)
    rfe

    # SPECIAL2 opcodes
    # entry: k0=opcode
mips32_special2:
    andi    $k1,$k0,0x03f
    xori    $t0,$k1,0x020
    beqz    $t0,mips32_CLZ
    xori    $t0,$k1,0x021
    beqz    $t0,mips32_CLO
    nop
    # all other special-3 opcodes go unemulated
    li      $t0,0x20010000      # Write ignored opcode to debug register
    sw      $k0,1024($t0)
    j       opcode_emu_return
    nop
    
    # SPECIAL3 opcodes
    # $k0 = opcode
mips32_special3:
    andi    $k1,$k0,0x03f
    xori    $t0,$k1,0x0
    beqz    $t0,mips32_EXT
    xori    $t0,$k1,0x04
    beqz    $t0,mips32_INS
    nop
    # all other special-3 opcodes go unemulated
    li      $t0,0x20010000      # Write ignored opcode to debug register
    sw      $k0,1024($t0)    
    j       opcode_emu_return
    nop

    # Get the branch opcode, decode it and emulate it
    # entry: $k0 = opcode, $t0 = address of branch
    # exit: $k0 = opcode that triggered exception (in branch delay)
emulate_branch:
    
    # FIXME branch emulation is missing!
    lw      $k0,4($t0)          # read actual guilty opcode
    jr      $ra
    nop
    
    #---- Branch emulation routines --------------------------------------------
    # FIXME branch emulation missing
    
    #---- Opcode emulation routines --------------------------------------------
    
    # CLZ: rd <- count leading zeros on rs
mips32_CLZ:
    jal     get_source_register             # $k1 = source register (Rs)
    lui     $t2,0x8000                      # $t2 = bit mask
    
    move    $t0,$zero                       # $t0 = counter
mips32_clz_loop:
    and     $t1,$k1,$t2
    bnez    $t1,mips32_clz_done
    srl     $t2,$t2,1
    bnez    $t2,mips32_clz_loop
    addiu   $t0,$t0,1
mips32_clz_done:
    j       mips32_save_result              # put result in dest reg and return
    move    $k1,$t0
    
    # CLO: rd <- count leading ones on rs
mips32_CLO:
    jal     get_source_register             # $k1 = source register (Rs)
    lui     $t2,0x8000                      # $t2 = bit mask
    
    move    $t0,$zero                       # $t0 = counter
mips32_clo_loop:
    and     $t1,$k1,$t2
    beqz    $t1,mips32_clo_done
    srl     $t2,$t2,1
    bnez    $t2,mips32_clo_loop
    addiu   $t0,$t0,1
mips32_clo_done:
    j       mips32_save_result              # put result in dest reg and return
    move    $k1,$t0
    
    # EXT:
mips32_EXT:
    jal     get_source_register             # $k1 = source register (Rs)
    nop
    srl     $t0,$k0,6                       # $t0 = pos
    andi    $t0,$t0,0x1f
    srl     $t1,$k0,11
    andi    $t1,$t1,0x1f                    # $t1 = size-1

    addu    $t2,$t0,$t1                     # ...by shifting left and then right
    subu    $t2,$zero,$t2
    addiu   $t2,$t2,31
    sllv    $k1,$k1,$t2
    srlv    $k1,$k1,$t2
    j       mips32_save_result              # put result in dest reg and return
    srlv    $k1,$k1,$t0                     # k1 = bit field, zero extended

    # INS:
mips32_INS:
    jal     get_source_register             # $k1 = source register (Rs)
    nop

    srl     $t0,$k0,6                       # $t0 = pos
    andi    $t0,$t0,0x1f
    srl     $t1,$k0,11
    andi    $t1,$t1,0x1f                    # $t1 = pos+size-1
    subu    $t1,$t1,$t0                     # $t1 = size-1

    subu    $t3,$zero,$t1                   # $t1 = source bit field, shifted 
    addiu   $t3,$t3,31
    sllv    $t1,$k1,$t0

    lui     $t2,0xffff                      # $t2 = target mask (0 for bitfield)
    ori     $t2,$t2,0xffff
    sllv    $t2,$t2,$t3 
    srlv    $t2,$t2,$t3 
    sllv    $t2,$t2,$t0
    and     $t1,$t1,$t2                     # $t1 = source bit field, masked
    not     $t2,$t2
    
    # ok, we're done with the source register, and we have the following:
    # $t0=pos, $t1=size-1, $t3=left shift amount, $t4=bitfield, $t2=mask

    # (uses $k1 and $t0)
    jal     get_source_register             # $k1 = target register
    sll     $k0,$k0,5
    srl     $k0,$k0,5                       # restore field Rt of opcode
    
    and     $k1,$k1,$t2                     # insert bit field in Rt...
    or      $k1,$k1,$t1

    j       mips32_save_result              # ...and put result back in register
    nop

    
    #---- Common utility routines ----------------------------------------------

    # entry: $k0 = opcode, $k1 = result
mips32_save_result:
    srl     $t1,$k0,16
    andi    $t1,$t1,0x1f
    la      $t0,set_target_table
    sll     $t1,$t1,3
    add     $t0,$t1
    jr      $t0
    nop
set_target_done:
    j       opcode_emu_return
    nop

set_target_table:
    j       set_target_done
    ori     $0,$k1,0
    j       set_target_done
    ori     $1,$k1,0
    j       set_target_done
    ori     $2,$k1,0
    j       set_target_done
    ori     $3,$k1,0
    j       set_target_done
    ori     $4,$k1,0
    j       set_target_done
    ori     $5,$k1,0
    j       set_target_done
    ori     $6,$k1,0
    j       set_target_done
    ori     $7,$k1,0
    j       set_target_done
    sw      $k1,-24($sp)
    j       set_target_done
    sw      $k1,-28($sp)
    j       set_target_done
    sw      $k1,-32($sp)
    j       set_target_done
    ori     $11,$k1,0
    j       set_target_done
    ori     $12,$k1,0
    j       set_target_done
    ori     $13,$k1,0
    j       set_target_done
    ori     $14,$k1,0
    j       set_target_done
    ori     $15,$k1,0
    j       set_target_done
    ori     $16,$k1,0
    j       set_target_done
    ori     $17,$k1,0
    j       set_target_done
    ori     $18,$k1,0
    j       set_target_done
    ori     $19,$k1,0
    j       set_target_done
    ori     $20,$k1,0
    j       set_target_done
    ori     $21,$k1,0
    j       set_target_done
    ori     $22,$k1,0
    j       set_target_done
    ori     $23,$k1,0
    j       set_target_done
    ori     $24,$k1,0
    j       set_target_done
    ori     $25,$k1,0
    j       set_target_done
    ori     $26,$k1,0
    j       set_target_done
    ori     $27,$k1,0
    j       set_target_done
    ori     $28,$k1,0
    j       set_target_done
    sw      $k1,-20($sp)
    j       set_target_done
    ori     $30,$k1,0
    j       set_target_done
    sw      $k1,-16($sp)

    # get value of register rs (field 25..21)
    # entry: $k0=opcode
    # exit: $k1=source
get_source_register:
    sw      $ra,0($sp)
    srl     $k1,$k0,21
    andi    $k1,$k1,0x1f
    la      $t0,get_source_table
    sll     $k1,$k1,3
    add     $t0,$t0,$k1
    jalr    $t0
    nop
    lw      $ra,0($sp)
    jr      $ra
    nop

    # exit: $k1=source reg
get_source_table:
    jr      $ra
    ori     $k1,$0,0
    jr      $ra
    ori     $k1,$1,0
    jr      $ra
    ori     $k1,$2,0
    jr      $ra
    ori     $k1,$3,0
    jr      $ra
    ori     $k1,$4,0
    jr      $ra
    ori     $k1,$5,0
    jr      $ra
    ori     $k1,$6,0
    jr      $ra
    ori     $k1,$7,0
    jr      $ra
    lw      $k1,-24($sp)
    jr      $ra
    lw      $k1,-28($sp)
    jr      $ra
    lw      $k1,-32($sp)
    jr      $ra
    ori     $k1,$11,0
    jr      $ra
    ori     $k1,$12,0
    jr      $ra
    ori     $k1,$13,0
    jr      $ra
    ori     $k1,$14,0
    jr      $ra
    ori     $k1,$15,0
    jr      $ra
    ori     $k1,$16,0
    jr      $ra
    ori     $k1,$17,0
    jr      $ra
    ori     $k1,$18,0
    jr      $ra
    ori     $k1,$19,0
    jr      $ra
    ori     $k1,$20,0
    jr      $ra
    ori     $k1,$21,0
    jr      $ra
    ori     $k1,$22,0
    jr      $ra
    ori     $k1,$23,0
    jr      $ra
    ori     $k1,$24,0
    jr      $ra
    ori     $k1,$25,0
    jr      $ra
    ori     $k1,$26,0
    jr      $ra
    ori     $k1,$27,0
    jr      $ra
    ori     $k0,$28,0
    jr      $ra
    lw      $k1,-16($sp)
    jr      $ra
    ori     $k1,$30,0
    jr      $ra
    lw      $k1,-20($sp)

