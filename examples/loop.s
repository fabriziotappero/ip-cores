/*
 * Description: Simple loop
 * Autor: Christian Walter <e0225458@student.tuwien.ac.at>
 */

    .text
    .org    0x0000

reset:
    ld      r3, addrlo(loop_start)
    ldhb    r3, addrhi(loop_start)
    ld      r4, addrlo(loop_middle)
    ldhb    r4, addrhi(loop_middle)
    ld      r5, addrlo(loop_end)
    ldhb    r5, addrhi(loop_end)
loop_start:
    ld      r1, r0
    ld      r1, #5
loop_middle:
    tst     r1
    jmpz    r5
    sub     r1, #1
    jmp     r4
loop_end:
    jmp     r3  
    
