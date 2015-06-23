#!/usr/bin/env python
#
# This script simulates 'sbc' calculation and generates values for selected numbers.
# These can be compared with a real Z80 run values.
#
import sys

def printFlags(f):
    s = ''
    if f & (1 << 7):
        s += 'S'
    else:
        s += ' '
    if f & (1 << 6):
        s += 'Z'
    else:
        s += ' '
    if f & (1 << 5):
        s += 'Y'
    else:
        s += ' '
    if f & (1 << 4):
        s += 'H'
    else:
        s += ' '
    if f & (1 << 3):
        s += 'X'
    else:
        s += ' '
    if f & (1 << 2):
        s += 'P'
    else:
        s += ' '
    if f & (1 << 1):
        s += 'V'
    else:
        s += ' '
    if f & (1 << 0):
        s += 'C'
    else:
        s += ' '
    print 'Flags =                           %s' % s

def sbc(inA, op2, CYin):
    print '------------------------------------------'
    print 'Input: %0.2X SBC %0.2X  CY = %0.2X' % ( inA, op2, CYin)

    double_cpl = 0                  # Flag that we did a double 1's complement
    cplOp2 = op2 ^ 0xFF             # Bit-wise complement of OP2

    if CYin:                        # If CF was set, we'll also use complemented ACCT
        double_cpl = 1
        cplA = inA ^ 0xFF
        finalA = cplA + cplOp2 + CYin
        carry_ins = finalA ^ cplA ^ cplOp2   # Bitfield of all internal carry-ins
    else:                           # Otherwise, set CF to act as '+1' in NEG
        CYin = 1
        finalA = inA + cplOp2 + CYin
        carry_ins = finalA ^ inA ^ cplOp2    # Bitfield of all internal carry-ins
        carry_ins ^= 0xFF

    # Calculate CF while we have bit [9] available
    cf = 0
    if finalA > 255 or finalA < 0:
        cf = 1

    cf ^= 1                         # Complement CY since we used cpl(A) and not A
    if double_cpl:
        cf ^= 1

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

    print 'Out:      A -> %0.2X    Flags = %0.2X' % ( finalA, flags)
    printFlags(flags)

sbc(0, 0, 0)
print 'Should be A -> 00    Flags = 42'
printFlags(0x42)
sbc(0, 1, 0)
print 'Should be A -> FF    Flags = BB'
printFlags(0xBB)

sbc(0, 0, 1)
print 'Should be A -> FF    Flags = BB'
printFlags(0xBB)
sbc(0, 1, 1)
print 'Should be A -> FE    Flags = BB'
printFlags(0xBB)

sbc(0xAA, 0x55, 0)
print 'Should be A -> 55    Flags = 06'
printFlags(0x06)
sbc(0x55, 0xAA, 0)
print 'Should be A -> AB    Flags = BF'
printFlags(0xBF)

sbc(0xAA, 0x55, 1)
print 'Should be A -> 54    Flags = 06'
printFlags(0x06)
sbc(0x55, 0xAA, 1)
print 'Should be A -> AA    Flags = BF'
printFlags(0xBF)

sbc(0x0F, 0x03, 1)
print 'Should be A -> 0B    Flags = 0A'
printFlags(0x0A)
