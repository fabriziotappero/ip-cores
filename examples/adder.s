/*
 * 
 *
 */


    .text
    .org    0x0000

reset:
    ld      r1, #0x03
    ldhb    r1, #0x01
    ld      r2, #0x30
    ld      r2, #0x33
    add     r1, r2
    
    ld      r8, addrlo(reset)
    ldhb    r8, addrhi(reset)
    jmp     r8
    
