#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
    emulator.py
    ===========

    An Emulator for MicroBlaze INA
    
    :copyright: Copyright (c) 2010 Jian Luo
    :author-email: jian.luo.cn(at_)gmail.com
    :license: LGPL, see LICENSE for details
    :revision: $Id: emulator.py 6 2010-11-21 23:18:44Z rockee $
"""

from random import randrange
from myhdl import *

operations = """
| ADD | Rd,Ra,Rb | 000000 | Rd | Ra | Rb & 00000000000 | Rd := Rb + Ra
| RSUB | Rd,Ra,Rb | 000001 | Rd | Ra | Rb & 00000000000 | Rd := Rb + Ra + 1
| ADDC | Rd,Ra,Rb | 000010 | Rd | Ra | Rb & 00000000000 | Rd := Rb + Ra + C
| RSUBC | Rd,Ra,Rb | 000011 | Rd | Ra | Rb & 00000000000 | Rd := Rb + Ra + C
| ADDK | Rd,Ra,Rb | 000100 | Rd | Ra | Rb & 00000000000 | Rd := Rb + Ra
| RSUBK | Rd,Ra,Rb | 000101 | Rd | Ra | Rb & 00000000000 | Rd := Rb + Ra + 1
| ADDKC | Rd,Ra,Rb | 000110 | Rd | Ra | Rb & 00000000000 | Rd := Rb + Ra + C
| RSUBKC | Rd,Ra,Rb | 000111 | Rd | Ra | Rb & 00000000000 | Rd := Rb + Ra + C
| CMP | Rd,Ra,Rb | 000101 | Rd | Ra | Rb & 00000000001 | Rd := Rb + Ra + 1
                                                      Rd[0] := 0 if (Rb >= Ra) else
                                                      Rd[0] := 1
| CMPU | Rd,Ra,Rb | 000101 | Rd | Ra | Rb & 00000000011 | Rd := Rb + Ra + 1 (unsigned)
                                                      Rd[0] := 0 if (Rb >= Ra, unsigned) else
                                                      Rd[0] := 1
| ADDI | Rd,Ra,Imm | 001000 | Rd | Ra | Imm        | Rd := s(Imm) + Ra
| RSUBI | Rd,Ra,Imm | 001001 | Rd | Ra | Imm        | Rd := s(Imm) + Ra + 1
| ADDIC | Rd,Ra,Imm | 001010 | Rd | Ra | Imm        | Rd := s(Imm) + Ra + C
| RSUBIC | Rd,Ra,Imm | 001011 | Rd | Ra | Imm        | Rd := s(Imm) + Ra + C
| ADDIK | Rd,Ra,Imm | 001100 | Rd | Ra | Imm        | Rd := s(Imm) + Ra
| RSUBIK | Rd,Ra,Imm | 001101 | Rd | Ra | Imm        | Rd := s(Imm) + Ra + 1
| ADDIKC | Rd,Ra,Imm | 001110 | Rd | Ra | Imm        | Rd := s(Imm) + Ra + C
| RSUBIKC | Rd,Ra,Imm | 001111 | Rd | Ra | Imm        | Rd := s(Imm) + Ra + C
#| MUL | Rd,Ra,Rb | 010000 | Rd | Ra | Rb & 00000000000 | Rd := Ra * Rb
#| MULH | Rd,Ra,Rb | 010000 | Rd | Ra | Rb & 00000000001 | Rd := (Ra * Rb) >> 32 (signed)
#| MULHU | Rd,Ra,Rb | 010000 | Rd | Ra | Rb & 00000000011 | Rd := (Ra * Rb) >> 32 (unsigned)
#| MULHSU | Rd,Ra,Rb | 010000 | Rd | Ra | Rb & 00000000010 | Rd := (Ra, signed * Rb, unsigned) >> 32 (signed)
#| BSRA | Rd,Ra,Rb | 010001 | Rd | Ra | Rb & 01000000000 | Rd := s(Ra >> Rb)
#| BSLL | Rd,Ra,Rb | 010001 | Rd | Ra | Rb & 10000000000 | Rd := (Ra << Rb) & 0
#| MULI | Rd,Ra,Imm | 011000 | Rd | Ra | Imm        | Rd := Ra * s(Imm)
#| BSRLI | Rd,Ra,Imm | 011001 | Rd | Ra | 00000000000 & Imm5  | Rd := 0 & (Ra >> Imm5)
#| BSRAI | Rd,Ra,Imm | 011001 | Rd | Ra | 00000010000 & Imm5  | Rd := s(Ra >> Imm5)
#| BSLLI | Rd,Ra,Imm | 011001 | Rd | Ra | 00000100000 & Imm5  | Rd := (Ra << Imm5) & 0
#| IDIV | Rd,Ra,Rb | 010010 | Rd | Ra | Rb & 00000000000 | Rd := Rb/Ra
#| IDIVU | Rd,Ra,Rb | 010010 | Rd | Ra | Rb & 00000000010 | Rd := Rb/Ra, unsigned
#| TNEAGETD | Rd,Rb | 010011 | Rd | 00000 | Rb & 0N0TAE00000 | Rd := FSL Rb[28:31] (data read)
                                                      #MSR[FSL] := 1 if (FSL_S_Control = 1)
                                                      #MSR[C] := not FSL_S_Exists if N = 1
#| TNAPUTD | Ra,Rb |    010011 | 00000 | Ra |  Rb & 0N0TA000000 |  FSL Rb[28:31] := Ra (data write)
                                                      #MSR[C] := FSL_M_Full if N = 1
#| TNECAGETD | Rd,Rb | 010011 | Rd |  00000 | Rb & 0N1TAE00000  |  Rd := FSL Rb[28:31] (control read)
                                                     #MSR[FSL] := 1 if (FSL_S_Control = 0)
                                                     #MSR[C] := not FSL_S_Exists if N = 1
#| TNCAPUTD | Ra,Rb |  010011 | 00000 | Ra |  Rb & 0N1TA000000  |  FSL Rb[28:31] := Ra (control write)
                                                     #MSR[C] := FSL_M_Full if N = 1
                                                     #Rd := Rb+Ra, float1
#FADD Rd,Ra,Rb    010110  Rd    Ra   Rb   00000000000
                                                     #Rd := Rb-Ra, float1
#FRSUB Rd,Ra,Rb   010110  Rd    Ra   Rb   00010000000
                                                     #Rd := Rb*Ra, float1
#FMUL Rd,Ra,Rb    010110  Rd    Ra   Rb   00100000000
                                                     #Rd := Rb/Ra, float1
#FDIV Rd,Ra,Rb    010110  Rd    Ra   Rb   00110000000
                                                     #Rd := 1 if (Rb = NaN or Ra = NaN, float1)
#FCMP.UN Rd,Ra,Rb 010110  Rd    Ra   Rb   01000000000
                                                     #else
                                                     #Rd := 0
                                                     #Rd := 1 if (Rb < Ra, float1) else
#FCMP.LT Rd,Ra,Rb 010110  Rd    Ra   Rb   01000010000
                                                     #Rd := 0
                                                     #Rd := 1 if (Rb = Ra, float1) else
#FCMP.EQ Rd,Ra,Rb 010110  Rd    Ra   Rb   01000100000
                                                     #Rd := 0
                                                     #Rd := 1 if (Rb <= Ra, float1) else
#FCMP.LE Rd,Ra,Rb 010110  Rd    Ra   Rb   01000110000
                                                     #Rd := 0
                                                     #Rd := 1 if (Rb > Ra, float1) else
#FCMP.GT Rd,Ra,Rb 010110  Rd    Ra   Rb   01001000000
                                                     #Rd := 0
                                                     #Rd := 1 if (Rb != Ra, float1) else
#FCMP.NE Rd,Ra,Rb 010110  Rd    Ra   Rb   01001010000
                                                     #Rd := 0
                                                     #Rd := 1 if (Rb >= Ra, float1) else
#FCMP.GE Rd,Ra,Rb 010110  Rd    Ra   Rb   01001100000
                                                     #Rd := 0
                                                     #Rd := float (Ra)1
#FLT Rd,Ra        010110  Rd    Ra    0   01010000000
                                                     #Rd := int (Ra)1
#FINT Rd,Ra       010110  Rd    Ra    0   01100000000
                                                     #Rd := sqrt (Ra)1
#FSQRT Rd,Ra      010110  Rd    Ra    0   01110000000
#| TNEAGET | Rd,FSLx |  011011 |  Rd |  00000 | 0N0TAE000000 & FSLx |  Rd := FSLx (data read, blocking if N = 0)
                                                 #MSR[FSL] := 1 if (FSLx_S_Control = 1)
                                                     #MSR[C] := not FSLx_S_Exists if N = 1
#| TNAPUT | Ra,FSLx |  011011 | 00000 | Ra |  1N0TA0000000 & FSLx | FSLx := Ra (data write, blocking if N = 0)
                                                 #MSR[C] := FSLx_M_Full if N = 1
#| TNECAGET | Rd,FSLx | 011011 | Rd |  00000 | 0N1TAE000000 & FSLx |  Rd := FSLx (control read, blocking if N = 0)
                                                 #MSR[FSL] := 1 if (FSLx_S_Control = 0)
                                                     #MSR[C] := not FSLx_S_Exists if N = 1
#| TNCAPUT | Ra,FSLx | 011011 | 00000 |  Ra  | 1N1TA0000000 & FSLx |  FSLx := Ra (control write, blocking if N = 0)
                                                 #MSR[C] := FSLx_M_Full if N = 1
| OR | Rd,Ra,Rb | 100000 | Rd | Ra | Rb & 00000000000 | Rd := Ra or Rb
| AND | Rd,Ra,Rb | 100001 | Rd | Ra | Rb & 00000000000 | Rd := Ra and Rb
| XOR | Rd,Ra,Rb | 100010 | Rd | Ra | Rb & 00000000000 | Rd := Ra xor Rb
| ANDN | Rd,Ra,Rb | 100011 | Rd | Ra | Rb & 00000000000 | Rd := Ra and Rb
#| PCMPBF | Rd,Ra,Rb | 100000 | Rd | Ra | Rb & 10000000000 | Rd := 1 if (Rb[0:7] = Ra[0:7]) else
                                                  Rd := 2 if (Rb[8:15] = Ra[8:15]) else
                                                  Rd := 3 if (Rb[16:23] = Ra[16:23]) else
                                                  Rd := 4 if (Rb[24:31] = Ra[24:31]) else
                                                  Rd := 0
#PCMPEQ Rd,Ra,Rb 100010  Rd   Ra Rb    10000000000 Rd := 1 if (Rd = Ra) else
                                                  #Rd := 0
#PCMPNE Rd,Ra,Rb 100011  Rd   Ra Rb    10000000000 Rd := 1 if (Rd != Ra) else
                                                  #Rd := 0
| SRA | Rd,Ra | 100100 | Rd | Ra | 0000000000000001  | Rd := s(Ra >> 1)
                                                  C := Ra[31]
| SRC | Rd,Ra | 100100 | Rd | Ra | 0000000000100001  | Rd := C & (Ra >> 1)
                                                  C := Ra[31]
| SRL | Rd,Ra | 100100 | Rd | Ra | 0000000001000001  | Rd := 0 & (Ra >> 1)
                                                  C := Ra[31]


| SEXT8 | Rd,Ra | 100100 | Rd | Ra | 0000000001100000  | Rd := s(Ra[24:31])
| SEXT16 | Rd,Ra | 100100 | Rd | Ra | 0000000001100001  | Rd := s(Ra[16:31])
    
#WIC Ra,Rb       100100 00000 Ra Rb      01101000  ICache_Line[Ra >> 4].Tag := 0 if
                                                  #(C_ICACHE_LINE_LEN = 4)
                                                  #ICache_Line[Ra >> 5].Tag := 0 if
                                                  #(C_ICACHE_LINE_LEN = 8)
#WDC Ra,Rb       100100 00000 Ra Rb      01100100  DCache_Line[Ra >> 4].Tag := 0 if
                                                  #(C_DCACHE_LINE_LEN = 4)
                                                  #DCache_Line[Ra >> 5].Tag := 0 if
                                                  #(C_DCACHE_LINE_LEN = 8)
#| MTS | Sd,Ra | 100101 | 00000 | Ra | 11 & Sd      | SPR[Sd] := Ra, where:
                                                  #•  SPR[0x0001] is MSR
                                                  #•  SPR[0x0007] is FSR
                                                  #•  SPR[0x1000] is PID
                                                  #•  SPR[0x1001] is ZPR
                                                  #•  SPR[0x1002] is TLBX
                                                  #•  SPR[0x1003] is TLBLO
                                                  #•  SPR[0x1004] is TLBHI
                                                  #•  SPR[0x1005] is TLBSX
#| MFS | Rd,Sa | 100101 | Rd | 00000 | 10 & Sa      | Rd := SPR[Sa], where:
                                                   #• SPR[0x0000] is PC
                                                   #• SPR[0x0001] is MSR
                                                   #• SPR[0x0003] is EAR
                                                   #• SPR[0x0005] is ESR
                                                   #• SPR[0x0007] is FSR
                                                   #• SPR[0x000B] is BTR
                                                   #• SPR[0x000D] is EDR
                                                   #• SPR[0x1000] is PID
                                                   #• SPR[0x1001] is ZPR
                                                   #• SPR[0x1002] is TLBX
                                                   #• SPR[0x1003] is TLBLO
                                                   #• SPR[0x1004] is TLBHI
                                                   #• SPR[0x2000 to 0x200B] is PVR[0 to 11]
#| MSRCLR | Rd,Imm | 100101 | Rd | 00001 | 00 & Imm14     | Rd := MSR
                                                   #MSR := MSR and Imm14
#| MSRSET | Rd,Imm | 100101 | Rd | 00000 | 00 & Imm14     | Rd := MSR
                                                   #MSR := MSR or Imm14
| BR | Rb | 100110 | 00000 | 00000 | Rb & 00000000000 | PC := PC + Rb
| BRD | Rb | 100110 | 00000 | 10000 | Rb & 00000000000 | PC := PC + Rb
| BRLD | Rd,Rb | 100110 | Rd | 10100 | Rb & 00000000000 | PC := PC + Rb
                                                   Rd := PC
| BRA | Rb | 100110 | 00000 | 01000 | Rb & 00000000000 | PC := Rb
| BRAD | Rb | 100110 | 00000 | 11000 | Rb & 00000000000 | PC := Rb
| BRALD | Rd,Rb | 100110 | Rd | 11100 | Rb & 00000000000 | PC := Rb
                                                   Rd := PC
| BRK | Rd,Rb | 100110 | Rd | 01100 | Rb & 00000000000 | PC := Rb
                                                   Rd := PC
                                                   MSR[BIP] := 1
| BEQ | Ra,Rb | 100111 | 00000 | Ra | Rb & 00000000000 | PC := PC + Rb if Ra = 0
| BNE | Ra,Rb | 100111 | 00001 | Ra | Rb & 00000000000 | PC := PC + Rb if Ra != 0
| BLT | Ra,Rb | 100111 | 00010 | Ra | Rb & 00000000000 | PC := PC + Rb if Ra < 0
| BLE | Ra,Rb | 100111 | 00011 | Ra | Rb & 00000000000 | PC := PC + Rb if Ra <= 0
| BGT | Ra,Rb | 100111 | 00100 | Ra | Rb & 00000000000 | PC := PC + Rb if Ra > 0
| BGE | Ra,Rb | 100111 | 00101 | Ra | Rb & 00000000000 | PC := PC + Rb if Ra >= 0
| BEQD | Ra,Rb | 100111 | 10000 | Ra | Rb & 00000000000 | PC := PC + Rb if Ra = 0
| BNED | Ra,Rb | 100111 | 10001 | Ra | Rb & 00000000000 | PC := PC + Rb if Ra != 0
| BLTD | Ra,Rb | 100111 | 10010 | Ra | Rb & 00000000000 | PC := PC + Rb if Ra < 0
| BLED | Ra,Rb | 100111 | 10011 | Ra | Rb & 00000000000 | PC := PC + Rb if Ra <= 0
| BGTD | Ra,Rb | 100111 | 10100 | Ra | Rb & 00000000000 | PC := PC + Rb if Ra > 0
| BGED | Ra,Rb | 100111 | 10101 | Ra | Rb & 00000000000 | PC := PC + Rb if Ra >= 0
| ORI | Rd,Ra,Imm | 101000 | Rd | Ra | Imm         | Rd := Ra or s(Imm)
| ANDI | Rd,Ra,Imm | 101001 | Rd | Ra | Imm         | Rd := Ra and s(Imm)
| XORI | Rd,Ra,Imm | 101010 | Rd | Ra | Imm         | Rd := Ra xor s(Imm)
| ANDNI | Rd,Ra,Imm | 101011 | Rd | Ra | Imm         | Rd := Ra and s(Imm)
        

| IMM | Imm | 101100 | 00000 | 00000 | Imm         | Imm[0:15] := Imm
| RTSD | Ra,Imm | 101101 | 10000 | Ra | Imm         | PC := Ra + s(Imm)
| RTID | Ra,Imm | 101101 | 10001 | Ra | Imm         | PC := Ra + s(Imm)
                                                  MSR[IE] := 1
| RTBD | Ra,Imm | 101101 | 10010 | Ra | Imm         | PC := Ra + s(Imm)
                                                  MSR[BIP] := 0
| RTED | Ra,Imm | 101101 | 10100 | Ra | Imm         | PC := Ra + s(Imm)
                                                  MSR[EE] := 1, MSR[EIP] := 0
                                                  ESR := 0
| BRI | Imm | 101110 | 00000 | 00000 | Imm         | PC := PC + s(Imm)
| BRID | Imm | 101110 | 00000 | 10000 | Imm         | PC := PC + s(Imm)
| BRLID | Rd,Imm | 101110 | Rd | 10100 | Imm         | PC := PC + s(Imm)
                                                 Rd := PC
| BRAI | Imm | 101110 | 00000 | 01000 | Imm         | PC := s(Imm)
| BRAID | Imm | 101110 | 00000 | 11000 | Imm         | PC := s(Imm)
| BRALID | Rd,Imm | 101110 | Rd | 11100 | Imm         | PC := s(Imm)
                                                 Rd := PC
| BRKI | Rd,Imm | 101110 | Rd | 01100 | Imm         | PC := s(Imm)
                                                  Rd := PC
                                                  MSR[BIP] := 1
| BEQI | Ra,Imm | 101111 | 00000 | Ra | Imm         | PC := PC + s(Imm) if Ra = 0
| BNEI | Ra,Imm | 101111 | 00001 | Ra | Imm         | PC := PC + s(Imm) if Ra != 0
| BLTI | Ra,Imm | 101111 | 00010 | Ra | Imm         | PC := PC + s(Imm) if Ra < 0
| BLEI | Ra,Imm | 101111 | 00011 | Ra | Imm         | PC := PC + s(Imm) if Ra <= 0
| BGTI | Ra,Imm | 101111 | 00100 | Ra | Imm         | PC := PC + s(Imm) if Ra > 0
| BGEI | Ra,Imm | 101111 | 00101 | Ra | Imm         | PC := PC + s(Imm) if Ra >= 0
| BEQID | Ra,Imm | 101111 | 10000 | Ra | Imm         | PC := PC + s(Imm) if Ra = 0
| BNEID | Ra,Imm | 101111 | 10001 | Ra | Imm         | PC := PC + s(Imm) if Ra != 0
| BLTID | Ra,Imm | 101111 | 10010 | Ra | Imm         | PC := PC + s(Imm) if Ra < 0
| BLEID | Ra,Imm | 101111 | 10011 | Ra | Imm         | PC := PC + s(Imm) if Ra <= 0
| BGTID | Ra,Imm | 101111 | 10100 | Ra | Imm         | PC := PC + s(Imm) if Ra > 0
| BGEID | Ra,Imm | 101111 | 10101 | Ra | Imm         | PC := PC + s(Imm) if Ra >= 0
| LBU | Rd,Ra,Rb | 110000 | Rd | Ra | Rb & 00000000000 | Addr := Ra + Rb
                                              Rd[0:23] := 0
                                              Rd[24:31] := *Addr[0:7]
| LHU | Rd,Ra,Rb | 110001 | Rd | Ra | Rb & 00000000000 | Addr := Ra + Rb
                                              Rd[0:15] := 0
                                              Rd[16:31] := *Addr[0:15]
| LW | Rd,Ra,Rb | 110010 | Rd | Ra | Rb & 00000000000 | Addr := Ra + Rb
                                              Rd := *Addr
| SB | Rd,Ra,Rb | 110100 | Rd | Ra | Rb & 00000000000 | Addr := Ra + Rb
                                              *Addr[0:8] := Rd[24:31]
| SH | Rd,Ra,Rb | 110101 | Rd | Ra | Rb & 00000000000 | Addr := Ra + Rb
                                              *Addr[0:16] := Rd[16:31]
| SW | Rd,Ra,Rb | 110110 | Rd | Ra | Rb & 00000000000 | Addr := Ra + Rb
                                              *Addr := Rd
| LBUI | Rd,Ra,Imm | 111000 | Rd | Ra | Imm         | Addr := Ra + s(Imm)
                                              Rd[0:23] := 0
                                              Rd[24:31] := *Addr[0:7]
| LHUI | Rd,Ra,Imm | 111001 | Rd | Ra | Imm         | Addr := Ra + s(Imm)
                                              Rd[0:15] := 0
                                              Rd[16:31] := *Addr[0:15]
| LWI | Rd,Ra,Imm | 111010 | Rd | Ra | Imm         | Addr := Ra + s(Imm)
                                              Rd := *Addr
| SBI | Rd,Ra,Imm | 111100 | Rd | Ra | Imm         | Addr := Ra + s(Imm)
                                              *Addr[0:7] := Rd[24:31]
| SHI | Rd,Ra,Imm | 111101 | Rd | Ra | Imm         | Addr := Ra + s(Imm)
                                              *Addr[0:15] := Rd[16:31]
| SWI | Rd,Ra,Imm | 111110 | Rd | Ra | Imm         | Addr := Ra + s(Imm)
                                                *Addr := Rd
"""

OPC_SFT = 26
OPC_MSK = 0x3f
REG_MSK = 0x1f
RD_SFT  = 21
RA_SFT  = 16
RB_SFT  = 11
IMM_MSK = 0xffff

# mask
OPC_IMM = 0x08
ADDSUB_K   = 0x04
ADDSUB_C   = 0x02
SUB_CMP = 0x01
SUB_CMPU = 0x02

import sys

QUIET=1
def log(string, params, file=sys.stdout):
    if QUIET:
        return
    params.update(
        rd = params['r'][params['d']],
        ra = params['r'][params['a']],
        rb = params['r'][params['b']],
    )
    print >>file, string.format(**params)

def log_gpr(params, file=sys.stdout):
    if QUIET:
        return
    print >>file, '\tGPRF:\t',
    for i, v in enumerate(params['r']):
        print >>file, '%8x' % v,
        if i%8 == 7:
            print >>file, '\n\t\t',
    print >>file, ''

def log_spr(params, file=sys.stdout):
    if QUIET:
        #print '{pc:x}'.format(**params)
        return

    print >>file, '{steps}:\tPC={pc:#x}\tCarry={m[0]:d}'.format(**params)

__max = 0x7fffffff
__min = 0x80000000

def _signed32(v):
    return (v & __max) - (v & __min)

def _signed16(v):
    return (v % (2**15)) - (v & (1<<15))

_umax = 0xffffffff
_max = _signed32(__max)
_min = _signed32(__min)

class MyBlazeEmulator(object):

    def __init__(self, filename='rom.vmem', max_steps=1000):
        ram = read_vmem(filename)
        print 'size=%d' % len(ram)
        fetch(ram, max_steps=max_steps)

def addi(d, a, i, k, c, r, m, **kw):
    x = _signed32(r[a]) + _signed32(i) + (bool(c) & m[0])
    r[d] = _signed32(x)
    m[0] = m[0] if k else not (_min <= x <= _max)

def add(b, r, i=None, **kw):
    addi(i=r[b], r=r, **kw)

def rsubi(d, a, i, k, c, r, m, **kw):
    x = _signed32(i) - _signed32(r[a]) - (bool(c) & m[0])
    r[d] = _signed32(x)
    m[0] = m[0] if k else not (_min <= x <= _max)

def rsub(b, r, i=None, **kw):
    rsubi(i=r[b], r=r, **kw)

def cmp(d, a, b, u, r, m, **kw):
    rsub(d=d, a=a, b=b, k=True, c=False, r=r, m=m, **kw)
    #if u:
        #if (r[a] & _umax) > (r[b] & _umax):
            #r[d] |= __min
        #else:
            #r[d] &= __max
        #r[d] = _signed32(r[d])
    if u and (r[a] & __min) ^ (r[b] & __min):
        msb = r[a] & __min
        r[d] = _signed32((r[d]&__max) | msb)

def sra(d, a, r, m, **kw):
    msb = (bool(r[a]&__min)) << 31
    m[0] = r[d] & 1
    r[d] = _signed32(msb | (r[d] >> 1))

def src(d, r, m, **kw):
    msb = m[0] << 31
    m[0] = r[d] & 1
    r[d] = _signed32(msb | (r[d] >> 1))

def srl(d, r, m, **kw):
    m[0] = r[d] & 1
    r[d] = _signed32((r[d] >> 1))

def sext8(d, a, r, **kw):
    if (r[a] & 0x80):
        r[d] = _signed32(0xffffff00 | r[a])
    else:
        r[d] = _signed32(0xff & r[a])

def sext16(d, a, r, **kw):
    if (r[a] & 0x8000):
        r[d] = _signed32(0xffff0000 | r[a])
    else:
        r[d] = _signed32(0xffff & r[a])

def bri(d, i, ab, ln, pc, r, **kw):
    if ln:
        r[d] = pc
    return i if ab else pc + i

def br(b, r, i=None, **kw):
    return bri(i=r[b], r=r, **kw)

def logici(d, a, i, op, r, **kw):
    ra = r[a]
    r[d] = _signed32([ra | i, ra & i, ra ^ i, ~ra & i][op])

def logic(b, r, i=None, **kw):
    logici(i=r[b], r=r, **kw)

def bcci(a, i, op, pc, r, **kw):
    ra = _signed32(r[a])
    branch = [ra == 0,
              ra != 0,
              ra < 0,
              ra <= 0,
              ra > 0,
              ra >= 0][op]
    return pc+i if branch else None

def bcc(b, r, i=None, **kw):
    return bcc(i=r[b], r=r, **kw)

def loadi(d, a, i, op, r, ram, **kw):
    addr = r[a] + i
    if op == 0:
        r[d] = ram[addr]
    elif op == 1:
        r[d] = (ram[addr]<<8) + ram[addr+1]
    else:
        r[d] = _signed32((ram[addr]<<24) +(ram[addr+1]<<16)
                        +(ram[addr+2]<<8) +ram[addr+3])
        #print 'load@r[%d]: %s' % (d,r[d])

def load(b, r, i=None, **kw):
    loadi(i=r[b], r=r, **kw)

def storei(d, a, i, op, r, ram, **kw):
    addr = r[a] + i
    if addr<0:
        # UART Emulation
        if addr == -64:
            sys.stdout.write(chr(r[d] & 0xff))
            sys.stdout.flush()
        #else:
            #print 'store@%#x <- r[%d]=%d' % (addr&_umax, d, r[d])
        return
    if op == 0:
        ram[addr] = r[d] & 0xff
    elif op == 1:
        ram[addr] = (r[d] >> 8) & 0xff
        ram[addr+1] = r[d] & 0xff
    else:
        ram[addr] = (r[d] >> 24) & 0xff
        ram[addr+1] = (r[d] >> 16) & 0xff
        ram[addr+2] = (r[d] >> 8) & 0xff
        ram[addr+3] = r[d] & 0xff

def store(b, r, i=None, **kw):
    storei(i=r[b], r=r, **kw)

def dec_store(opcode, **kw):
    op = opcode & 0x03
    kw.update(
        op_name = ['sb', 'sh', 'sw'][op],
        op = op,
    )
    if opcode & OPC_IMM:
        storei(**kw)
        log('\t\t{op_name}i\tr{d}({rd}), r{a}({ra}), {i}', kw)
    else:
        store(**kw)
        log('\t\t{op_name}\tr{d}({rd}), r{a}({ra}), r{b}({rb})', kw)

def dec_load(opcode, **kw):
    op = opcode & 0x03
    kw.update(
        op_name = ['lbu', 'lhu', 'lw'][op],
        op = op,
    )
    if opcode & OPC_IMM:
        loadi(**kw)
        log('\t\t{op_name}i\tr{d}({rd}), r{a}({ra}), {i}', kw)
    else:
        load(**kw)
        log('\t\t{op_name}\tr{d}({rd}), r{a}({ra}), r{b}({rb})', kw)
        

def dec_add(opcode, **kw):
    kw.update(
        k = ['','k'][bool(opcode & ADDSUB_K)],
        c = ['','c'][bool(opcode & ADDSUB_C)],
    )
    if opcode & OPC_IMM:
        addi(**kw)
        log('\t\taddi{k}{c}\tr{d}({rd}), r{a}({ra}), {i}', kw)
    else:
        add(**kw)
        log('\t\tadd{k}{c}\tr{d}({rd}), r{a}({ra}), r{b}({rb})', kw)

def dec_sub(opcode, **kw):
    i = kw['i']
    kw.update(
        k = ['','k'][bool(opcode & ADDSUB_K)],
        c = ['','c'][bool(opcode & ADDSUB_C)],
        u = ['','u'][bool(i & SUB_CMPU)],
    )
    if opcode & OPC_IMM:
        rsubi(**kw)
        log('\t\trsubi{k}{c}\tr{d}({rd}), r{a}({ra}), {i}', kw)
    elif not i & SUB_CMP:
        rsub(**kw)
        log('\t\trsub{k}{c}\tr{d}({rd}), r{a}({ra}), r{b}({rb})', kw)
    else:
        cmp(**kw)
        log('\t\tcmp{u}\tr{d}({rd}), r{a}({ra}), r{b}({rb})', kw)

def dec_logic(opcode, **kw):
    op = opcode & 0x03
    kw.update(
        op=op,
        op_name=['or', 'and', 'xor', 'andn'][op]
    )
    if opcode & OPC_IMM:
        logici(**kw)
        log('\t\t{op_name}i\tr{d}({rd}), r{a}({ra}), {i}', kw)
    else:
        logic(**kw)
        log('\t\t{op_name}\tr{d}({rd}), r{a}({ra}), r{b}({rb})', kw)

EXT_MAPPING = dict(
    sra   = (0b0000001, 0b1111111, sra),
    src   = (0b0100001, 0b1111111, src),
    srl   = (0b1000001, 0b1111111, srl),
    sext8 = (0b1100000, 0b1111111, sext8),
    sext16= (0b1100001, 0b1111111, sext16),
)

def dec_extended(opcode, **kw):
    i = kw['i']
    for op_name, (value, mask, func) in EXT_MAPPING.items():
        if (i & mask) == value:
            func(**kw)
            kw['op_name'] = op_name
            log('\t\t{op_name}\tr{d}({rd}), r{a}({ra})', kw)
    
def dec_ret(**kw):
    a = kw['a']
    r = kw['r']
    i = kw['i']
    next = r[a] + i
    log('\t\trtsd\tr{a}({ra}), {i}', kw)
    return next, True

def dec_br(opcode, **kw):
    a = kw['a']
    dl = ['', 'd'][bool(a & 0b10000)]
    kw.update(
        ln = ['', 'l'][bool(a & 0b00100)],
        ab = ['', 'a'][bool(a & 0b01000)],
        dl = dl,
    )
    if opcode & OPC_IMM:
        next = bri(**kw)
        if kw['ln']:
            log('\t\tbr{ab}li{dl}\tr{d}({rd}), {i}', kw)
        else:
            log('\t\tbr{ab}i{dl}\t{i}', kw)
    else:
        next = br(**kw)
        if kw['ln']:
            log('\t\tbr{ab}l{dl}\tr{d}({rd}), {i}', kw)
        else:
            log('\t\tbr{ab}{dl}\t{i}', kw)
    return next, bool(dl)

def dec_bcc(opcode, **kw):
    d = kw['d']
    a = kw['a']
    b = kw['b']
    i = kw['i']
    r = kw['r']
    op = d & 0b111
    dl = ['', 'd'][bool(d & 0b10000)]
    kw.update(
        op_name = ['beq', 'bne', 'blt', 'ble', 'bgt', 'bge'][op],
        op = op,
        dl = dl,
    )
    #print dl, d
    if opcode & OPC_IMM:
        next = bcci(**kw)
        log('\t\t{op_name}i{dl}\tr{a}({ra}), {i}', kw)
    else:
        next = bcc(**kw)
        log('\t\t{op_name}{dl}\tr{a}({ra}), r{b}({rb})', kw)
    if next:
        return next, bool(dl)

def dec_imm(i, imm, **kw):
    imm[0] = i
    kw.update(i=i)
    log('\t\timm\t{i}', kw)

# value, mask
OPGROUP_MAPPING = dict(
    DEC_ADD = (     0b0, 0b110001, dec_add),
    DEC_SUB = (     0b1, 0b110001, dec_sub),
    DEC_LOG = (0b100000, 0b110100, dec_logic),
    DEC_IMM = (0b101100, 0b111111, dec_imm),
    DEC_EXT = (0b100100, 0b111111, dec_extended),
    DEC_RET = (0b101101, 0b111111, dec_ret),
    DEC_BR  = (0b100110, 0b110111, dec_br),
    DEC_BCC = (0b100111, 0b110111, dec_bcc),
    DEC_LD  = (0b110000, 0b110100, dec_load),
    DEC_ST  = (0b110100, 0b110100, dec_store),
)

def decode(instruction, pc, r, m, imm, ram, steps):
    opcode = (instruction >> OPC_SFT) & OPC_MSK

    # Process immediate
    i = instruction & IMM_MSK
    if imm[0] is not None:
        i += imm[0]<<16
        imm[0] = None
        i = _signed32(i)
    else:
        #if (i & 0x8000):
            #i |= 0xffff0000
        #else:
            #i &= 0xffff
        i = _signed16(i)

    kw = dict(
        instruction=instruction,
        opcode = opcode,
        d = (instruction >> RD_SFT) & REG_MSK,
        a = (instruction >> RA_SFT) & REG_MSK,
        b = (instruction >> RB_SFT) & REG_MSK,
        i = i,
        pc = pc,
        r = r,
        m = m,
        imm = imm,
        ram = ram,
        steps = steps,
    )
    for value, mask, func in OPGROUP_MAPPING.values():
        if (opcode & mask) == value:
            log_spr(kw)
            result = func(**kw)
            log_gpr(kw)
            return result

def fetch(ram, pc=0, max_steps=-1, single=False):
    r = [0]*32 # gprf
    m = [0]*32 # msr
    imm = [None]  # immediate
    steps = 0
    delayed = False
    while steps != max_steps:
        instruction = (ram[pc]<<24) +(ram[pc+1]<<16) +(ram[pc+2]<<8) +ram[pc+3]
        kw = dict(
            r=r,m=m,imm=imm,pc=pc,
            ram=ram,
            instruction=instruction,
            steps=steps,
        )
        result = decode(**kw)
        if result is not None:
            next, delay = result
            #print next, delay

        if single:
            raw_input('Press [Any-Key] to continue ;)')
        steps += 1

        if delayed:
            pc = branch_target
            delayed = False
            #print 'delayed'
        elif result is None:
            pc += 4
            delayed = False
            #print 'normal'
        elif delay:
            pc += 4
            delayed = True
            branch_target = next
            #print 'delay'
        else:
            pc = next
            delayed = False
            #print 'branch'
        #print '%x, %s' % (pc, delay)
    
def read_vmem(filename, bank=4, width=8):
    print filename
    source = open(filename).readlines()
    ram = []
    for line in source:
        value = int(line.strip(), 16)
        for i in range(bank):
            ram.append((value >> (width*(bank-1-i))) % (2**width))
    return ram



import sys
if __name__ == '__main__':
    MyBlazeEmulator(sys.argv[1], max_steps=2000)

### EOF ###
# vim:smarttab:sts=4:ts=4:sw=4:et:ai:tw=80:

