#!/usr/bin/env python
#
# This script simulates 'daa' calculation and generates values for numbers 0-255.
# These can be compared with a real Z80 run values.
#
import sys

# Open opcode file and read opcode + mnemonics
with open('daa-concise.txt') as tmpFile:
    testVectors = [line.rstrip('\n') for line in tmpFile]

for line in testVectors:
    # F:00 A:00 -> 00 F:44
    inF = int(line[2:4], 16)
    inA = int(line[7:9], 16)
    outA = int(line[13:15], 16)
    outF = int(line[18:20], 16)
    #print 'F:' + ("%0.2X" % inF) + ' A:' + ("%0.2X" % inA) + ' -> ' + ("%0.2X" % outA) + ' F:' + ("%0.2X" % outF)

    # Get the flags that will determine daa operation
    hf = (inF>>4) & 1
    nf = (inF>>1) & 1
    cf = (inF>>0) & 1

    correction = 0x00               # Initial correction byte
    low_nibble_flag = 0             # Flag to keep the compare state of the low nibble
    if (inA & 0x0F) > 9:
        low_nibble_flag = 1

    if low_nibble_flag or hf:
        correction |= 0x06          # Setup lower nibble

    # if inA > 0x99 or cf:
    upperA = (inA >> 4) & 0xF       # Simulate ALU: get the upper nibble
    if (upperA == 9 and low_nibble_flag) or upperA > 9 or cf:
        correction |= 0x60          # Setup upper nibble
        cf = 1
    else:
        cf = 0

    if nf:
        finalA = inA - correction
    else:
        finalA = inA + correction
    finalA &= 0xFF                  # Formality

    #-------------------------------------------------------------------------------
    # Flag calculation: SF, ZF, YF, HF, XF, VF/PF, NF, CF
    #-------------------------------------------------------------------------------
    sf = (finalA>>7) & 1            # Copy of [7]
    zf = finalA==0                  # Set if the final value is zero
    yf = (finalA>>5) & 1            # Copy of [5]
    hf = 0                          # Standard way to compute HF
    if (inA&0x10)!=(finalA&0x10):
        hf = 1
    xf = (finalA>>3) & 1            # Copy of [3]
    pf = (((finalA>>7)^(finalA>>6)^(finalA>>5)^(finalA>>4)^(finalA>>3)^(finalA>>2)^(finalA>>1)^(finalA>>0))&1)^1
    nf = (inF>>1) & 1               # Always unchanged

    flags = (sf<<7) | (zf<<6) | (yf<<5) | (hf<<4) | (xf<<3) | (pf<<2) | (nf<<1) | (cf<<0)

    print 'F:' + ("%0.2X" % inF) + ' A:' + ("%0.2X" % inA) + ' -> ' + ("%0.2X" % finalA) + ' F:' + ("%0.2X" % flags)
