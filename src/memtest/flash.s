################################################################################
# flash.s -- Chunk of code and data to be written to simulated FLASH
# and executed from there as part of program memtest.
#-------------------------------------------------------------------------------
# This program tests the external 8-bit static memory interface (FLASH) in
# simulation.
#
# The program assumes there's no useable r/w memory other than the XRAM so it
# does not use any memory for variables or stack.
#------------------------------------------------------------------------------- 
#
################################################################################

    #---- Test parameters 
    .ifndef FLASH_BASE
    .set FLASH_BASE,    0xb0000000          # 1st FLASH address
    .endif
    .ifndef XRAM_BASE
    .set XRAM_BASE,     0x00000000          # 1st XRAM address
    .endif


    #---- Set to >0 to enable a few debug messages
    .set DEBUG,         0

    #---- Cache parameters
    .set ICACHE_NUM_LINES, 256              # no. of lines in the I-Cache
    .set DCACHE_NUM_LINES, 256              # no. of lines in the D-Cache
    .set DCACHE_LINE_SIZE, 4                # D-Cache line size in words
    

    #---- UART stuff
    .set UART_BASE,     0x20000000          # UART base address
    .set UART_TX,       0x0000              # TX reg offset
    .set UART_STATUS,   0x0004              # status reg offset
    .set UART_TX_RDY,   0x0001              # tx ready flag mask

    #---------------------------------------------------------------------------

    .text
    .align  2
    .global flash_test
    .ent flash_test
flash_test:
    .set    noreorder

    #---- Print 'running from flash' message
    la      $a0,msg0
    jal     puts
    nop
    
    sw      $a1,0($a0)
    sw      $a2,4($a0)
    sw      $a3,8($a0)

    
    
    #---- D-Cache back-to-back loads and stores
    la      $a0,msg3
    jal     puts
    nop

    li      $a0,XRAM_BASE+4
    ori     $t8,$zero,16
    
rw_test_loop:
    li      $s0,0x10001010

    addu    $s1,$s0,$s0
    addu    $s2,$s1,$s1
    addu    $s3,$s2,$s2
    or      $s4,$zero,$s0
    or      $s5,$zero,$s1
    or      $s6,$zero,$s2
    or      $s7,$zero,$s3
    
    sw      $s0,0($a0)
    sw      $s1,4($a0)
    sw      $s2,8($a0)
    sw      $s3,12($a0)
    sw      $s4,16($a0)
    sw      $s5,20($a0)
    sw      $s6,24($a0)
    sw      $s7,28($a0)

    lw      $t0,0($a0)
    lw      $t1,4($a0)
    lw      $t2,8($a0)
    lw      $t3,12($a0)
    lw      $t4,16($a0)
    lw      $t5,20($a0)
    lw      $t6,24($a0)
    lw      $t7,28($a0)
    
    bne     $s0,$t0,rw_mismatch
    nop
    bne     $s1,$t1,rw_mismatch
    nop
    bne     $s2,$t2,rw_mismatch
    nop
    bne     $s3,$t3,rw_mismatch
    nop
    bne     $s4,$t4,rw_mismatch
    nop
    bne     $s5,$t5,rw_mismatch
    nop
    bne     $s6,$t6,rw_mismatch
    nop
    bne     $s7,$t7,rw_mismatch
    nop
    .ifgt 0
    andi    $s0,$s0,0xffff
    andi    $s1,$s1,0xff
    andi    $s2,$s2,0xffff
    andi    $s3,$s3,0xff
    andi    $s4,$s4,0xff
    andi    $s5,$s5,0xff
    andi    $s6,$s6,0xff
    andi    $s7,$s7,0xff

    sh      $s0,2($a0)
    sb      $s1,3($a0)
    sh      $s2,4($a0)
    sb      $s3,5($a0)
    sb      $s4,2($a0)
    sb      $s5,3($a0)
    sb      $s6,4($a0)
    sb      $s7,5($a0)
    sh      $s0,2($a0)
    sh      $s2,4($a0)
    sh      $s2,6($a0)
    sh      $s0,10($a0)
    
    lh      $t0,2($a0)
    lb      $t1,3($a0)
    lh      $t2,4($a0)
    lb      $t3,5($a0)
    lb      $t4,2($a0)
    lb      $t5,3($a0)
    lb      $t6,4($a0)
    lb      $t7,5($a0)
    lh      $t0,2($a0)
    lh      $t2,4($a0)
    lh      $t2,6($a0)
    lh      $t0,10($a0)
    
    bne     $s0,$t0,rw_mismatch
    nop
    bne     $s1,$t1,rw_mismatch
    nop
    bne     $s2,$t2,rw_mismatch
    nop
    bne     $s3,$t3,rw_mismatch
    nop
    bne     $s4,$t4,rw_mismatch
    nop
    bne     $s5,$t5,rw_mismatch
    nop
    bne     $s6,$t6,rw_mismatch
    nop
    bne     $s7,$t7,rw_mismatch
    nop
    .endif
    addi    $t8,$t8,-1
    bnez    $t8,rw_test_loop
    addiu   $a0,$a0,0x100 
    
    la      $a0,msg_ok
    jal     puts
    nop
    
    j       rw_done
    nop
    
rw_mismatch:
    la      $a0,msg_fail
    jal     puts
    nop

rw_done:
    la      $a0,crlf
    jal     puts
    nop
    

test_xram:
    la      $a0,msg1
    jal     puts
    nop
    
    li      $t0,XRAM_BASE
    li      $t1,256
    li      $t2,0x12345678
    
xram_fill_loop:
    sw      $t2,0($t0)
    addi    $t0,$t0,4
    addi    $t2,$t2,0x0333
    bgtz    $t1,xram_fill_loop
    addi    $t1,$t1,-1
    
    li      $t0,XRAM_BASE
    li      $t1,256
    li      $t2,0x12345678
    li      $t3,0x12345678
    
xram_test_loop:
    lw      $t3,0($t0)
    bne     $t2,$t3,xram_test_failed
    addi    $t0,$t0,4
    addi    $t2,$t2,0x0333
    bgtz    $t1,xram_test_loop
    addi    $t1,$t1,-1

    la      $a0,msg_ok
    jal     puts
    nop
    j       xram_test_end
    nop
    
xram_test_failed:
    la      $a0,msg_fail
    jal     puts
    nop
    
xram_test_end:
    la      $a0,crlf
    jal     puts
    nop


    la      $a0,msg2
    jal     puts
    nop
        
$DONE:
    j       $DONE               # freeze here
    nop


#--- Special functions that do not use any RAM ---------------------------------
# WARNING: Not for general use!
# All parameters in $a0..$a4, stack unused. No attempt to comply with any ABI
# has been made.
# Since we can't use any RAM, registers have been used with no regard for 
# intended usage -- have to share reg bank with calling function.
   
# void puts(char *s) -- print zero-terminated string
puts: 
    la      $a2,UART_BASE       # UART base address
puts_loop:
    lb      $v0,0($a0)
    beqz    $v0,puts_end
    addiu   $a0,1
puts_wait_tx_rdy:    
    lw      $v1,UART_STATUS($a2)
    andi    $v1,$v1,UART_TX_RDY
    beqz    $v1,puts_wait_tx_rdy
    nop
    sw      $v0,UART_TX($a2)
    b       puts_loop
    nop
    
puts_end:
    jr      $ra
    nop    

# void put_hex(int n, int d) -- print integer as d-digit hex
put_hex:
    la      $a2,UART_BASE
    la      $a3,put_hex_table
    addi    $a1,-1
    add     $a1,$a1,$a1
    add     $a1,$a1,$a1

put_hex_loop:
    srlv    $v0,$a0,$a1
    andi    $v0,$v0,0x0f
    addu    $s2,$a3,$v0
    lb      $v0,0($s2)
put_hex_wait_tx_rdy:
    lw      $v1,UART_STATUS($a2)
    andi    $v1,$v1,UART_TX_RDY
    beqz    $v1,put_hex_wait_tx_rdy
    nop
    sw      $v0,UART_TX($a2)
    
    bnez    $a1,put_hex_loop
    addi    $a1,-4

    jr      $ra
    nop
    

#---- Constant data (note we keep it in the text section) ----------------------

put_hex_table:
    .ascii  "0123456789abcdef"

msg1:
    .asciz "Testing 16-bit static R/W... "
msg2:
    .asciz "End of test, program frozen.\n\r"
msg3:
    .asciz "Testing bursts of back-to-back R/W... "
msg_ok: 
    .asciz "OK"
msg_fail:
    .asciz "FAIL"
crlf:
    .asciz "\n\r"
space:
    .asciz "  "
msg0: 
    .asciz "\n\rNow running from 8-bit static memory.\n\r"
    
    .set    reorder
    .end    flash_test
 
