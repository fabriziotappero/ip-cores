/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */
    
    la  $t0, 0f
    jr  $t0
0:

    la      $t0, __bss_start     # clear .bss
    la      $t1, __bss_stop
    beq     $t0, $t1, 2f
    
1:
    sw      $zero, ($t0)
    addiu   $t0, 4
    bne     $t0, $t1, 1b

2:
    li      $sp, 0xBFC01000     # setup $sp and jump to C code
    j       start_bootloader
    nop
