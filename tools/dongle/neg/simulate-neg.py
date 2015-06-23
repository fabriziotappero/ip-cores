#!/usr/bin/env python
#
# This script simulates 'neg' calculation and generates values for numbers 0-255.
# These can be compared with a real Z80 run values.
#
import sys

for inA in range(0, 256):
    # neg is: 0 - A
    # or:     255 - inA + 1
    # or:     255 - -(cpl(A)+1) + 1   (second complement of A; can change the sign)
    # or:     255 + cpl(A)+1 + 1
    # or:     cpl(A) + 255 + 1 + 1
    # or:     cpl(A) + 0 + 1      (+CY)
#    cplA = inA ^ 0xFF;              # Bit-wise complement of A
#    CYin = 1                        # Carry in force to 1
#    op2  = 0                        # Load operand 2 with a constant value of 0
#    finalA = cplA + op2 + CYin

    acct = inA                      # ACCT is always loaded with A
    op2 = inA                       # Load A again into OP2
    mux1 = 0                        # MUX1 selects 0 instead of ACCT
    mux2 = op2 ^ 0xFF               # MUX2 selects complement of OP2
    CYin = 1                        # Carry in force to 1
    finalA = mux1 + mux2 + CYin
    carry_ins = finalA ^ mux1 ^ mux2  # Bitfield of all internal carry-ins
    carry_ins ^= 0x90   # !?!?! Need to invert both H and V carry-ins?

    # Calculate CF while we have bit [9] available
    cf = 0
    if finalA > 255 or finalA < 0:
        cf = 1

    cf ^= 1                         # Complement CY since we used cpl(A) and not A
    nf = 1                          # 1 for SUB operation

    finalA = finalA & 0xFF          # Clamp final value to 8 bits

    #-------------------------------------------------------------------------------
    # Flag calculation: SF, ZF, YF, HF, XF, VF/PF, NF, CF
    #-------------------------------------------------------------------------------
    # Carry and Overflow calculation on Z80 require us to use internal carry-ins
    # http://stackoverflow.com/questions/8034566/overflow-and-carry-flags-on-z80
    #carry_ins = finalA ^ inA ^ op2  # Bitfield of all internal carry-ins

    sf = (finalA>>7) & 1            # SF = Copy of [7]
    zf = finalA==0                  # ZF = Set if all result bits are zero
    yf = (finalA>>5) & 1            # YF = Copy of [5]
    hf = (carry_ins>>4)&1           # HF = Internal carry from bit [3] to [4]
    xf = (finalA>>3) & 1            # XF = Copy of [3]
    #                               # PF = XOR all final bits to get odd parity value
    pf = (((finalA>>7)^(finalA>>6)^(finalA>>5)^(finalA>>4)^(finalA>>3)^(finalA>>2)^(finalA>>1)^(finalA>>0))&1)^1
    vf = (carry_ins>>7)&1           # VF = Internal carry from bit [6] to [7]
    vf ^= cf                        # XOR'ed with the final carry out

    flags = (sf<<7) | (zf<<6) | (yf<<5) | (hf<<4) | (xf<<3) | (vf<<2) | (nf<<1) | (cf<<0)

    print '%0.2X -> %0.2X  Flags = %0.2X' % ( inA, finalA, flags)
