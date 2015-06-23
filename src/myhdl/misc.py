######################################################################
####                                                              ####
####  misc.py                                                     ####
####                                                              ####
####  This file is part of the turbo decoder IP core project      ####
####  http://www.opencores.org/projects/turbocodes/               ####
####                                                              ####
####  Author(s):                                                  ####
####      - David Brochart(dbrochart@opencores.org)               ####
####                                                              ####
####  All additional information is available in the README.txt   ####
####  file.                                                       ####
####                                                              ####
######################################################################
####                                                              ####
#### Copyright (C) 2005 Authors                                   ####
####                                                              ####
#### This source file may be used and distributed without         ####
#### restriction provided that this copyright statement is not    ####
#### removed from the file and that any derivative work contains  ####
#### the original copyright notice and the associated disclaimer. ####
####                                                              ####
#### This source file is free software; you can redistribute it   ####
#### and/or modify it under the terms of the GNU Lesser General   ####
#### Public License as published by the Free Software Foundation; ####
#### either version 2.1 of the License, or (at your option) any   ####
#### later version.                                               ####
####                                                              ####
#### This source is distributed in the hope that it will be       ####
#### useful, but WITHOUT ANY WARRANTY; without even the implied   ####
#### warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ####
#### PURPOSE. See the GNU Lesser General Public License for more  ####
#### details.                                                     ####
####                                                              ####
#### You should have received a copy of the GNU Lesser General    ####
#### Public License along with this source; if not, download it   ####
#### from http://www.opencores.org/lgpl.shtml                     ####
####                                                              ####
######################################################################



from myhdl import Signal, intbv, always_comb, instance, always, posedge, negedge, concat

def delayer(clk, rst, d, q, delay = 1, mi = 0, ma = 1):
    """ Delayer.

    delay       -- number of clock cycles to delay
    mi          -- minimum value of the signal to delay
    ma          -- maximum value of the signal to delay
    clk, rst    -- in  : clock and negative reset
    d           -- in  : signal to be delayed by "delay" clock cycles
    q           -- out : delayed signal

    """
    r = [Signal(intbv(0, mi, ma)) for i in range(delay)]
    @always(clk.posedge, rst.negedge)
    def delayerLogic():
        if rst.val == 0:
            q.next = 0
            for i in range(delay):
                r[i].next = 0
        else:
            r[0].next = d
            q.next = r[delay - 1].val
            for i in range(delay - 1):
                r[i + 1].next = r[i].val
    return delayerLogic

def opposite(pos, neg):
    """ Take the opposite of a number.

    pos -- in  : original number
    neg -- out : opposite number

    """
    @always_comb
    def oppositeLogic():
        neg.next = -pos.val
    return oppositeLogic

def adder(op1, op2, res):
    """ Adder.

    op1 -- in  : first operand
    op2 -- in  : second operand
    res -- out : result of the addition

    """
    @always_comb
    def addLogic():
        res.next = op1.val + op2.val
    return addLogic

def register(clk, rst, d, q):
    """ Register.

    clk, rst    -- in  : clock and negative reset
    d           -- in  : next value
    q           -- out : current value

    """
    @always(clk.posedge, rst.negedge)
    def registerLogic():
       if rst.val == 0:
           q.next = 0
       else:
           q.next = d.val
    return registerLogic

def cmp2(op1, op2, res):
    """ 2-input comparator.

    op1     -- in  : first operand
    op2     -- in  : second operand
    res     -- out : compare result (0 if op2 < op1, 1 otherwise)

    """
    @always_comb
    def cmp2Logic():
        if op1.val > op2.val:
            res.next = 0
        else:
            res.next = 1
    return cmp2Logic

def mux2(in1, in2, sel, outSel):
    """ 2-input mux.

    in1     -- in  : first input signal
    in2     -- in  : second input signal
    sel     -- in  : 1-bit control signal
    outSel  -- out : selected output signal

    """
    @always_comb
    def mux2Logic():
        if sel.val == 0:
            outSel.next = in2.val
        else:
            outSel.next = in1.val
    return mux2Logic

def orGate(op1, op2, res):
    """ 2-input OR gate.

    op1 -- in  : first operand
    op2 -- in  : second operand
    res -- out : result

    """
    @always_comb
    def orGateLogic():
        res.next = op1.val or op2.val
    return orGateLogic

def min4(op1, op2, op3, op4, res1, res2, res3, q = 8):
    """ Selects the minimum between 4 values.
    
    q       -- width of the signals to compare
    op1     -- in  : first input signal
    op2     -- in  : second input signal
    op3     -- in  : third input signal
    op4     -- in  : fourth input signal
    res1    -- out : partial code of the minimum value
    res2    -- out : partial code of the minimum value
    res3    -- out : partial code of the minimum value

    """
    op5 = Signal(intbv(0, 0, 2**q))
    op6 = Signal(intbv(0, 0, 2**q))
    cmp2_i0 = cmp2(op1, op2, res1)
    cmp2_i1 = cmp2(op3, op4, res2)
    mux2_i0 = mux2(op1, op2, res1, op5)
    mux2_i1 = mux2(op3, op4, res2, op6)
    cmp2_i2 = cmp2(op5, op6, res3)

    return cmp2_i0, cmp2_i1, mux2_i0, mux2_i1, cmp2_i2

def mux4(in1, in2, in3, in4, sel, outSel):
    """ 4-input mux.

    in1     -- in  : first input signal
    in2     -- in  : second input signal
    in3     -- in  : third input signal
    in4     -- in  : fourth input signal
    sel     -- in  : 2-bit control signal
    outSel  -- out : selected output signal

    """
    @always_comb
    def mux4Logic():
        if sel.val == 0:
            outSel.next = in1.val
        elif sel.val == 1:
            outSel.next = in2.val
        elif sel.val == 2:
            outSel.next = in3.val
        else:
            outSel.next = in4.val
    return mux4Logic

def cod2(in1, in2, in3, outCod):
    """ 2-bit coder.

    in1     -- in  : 1-bit first input signal
    in2     -- in  : 1-bit second input signal
    in3     -- in  : 1-bit third input signal
    outCod  -- out : 2-bit coded value

    """
    tmp = intbv(0, 0, 8)
    @always_comb
    def cod2Logic():
        tmp = concat(bool(in1.val), bool(in2.val), bool(in3.val))
        if tmp == 5:
            outCod.next = 0
        elif tmp == 7:
            outCod.next = 0
        elif tmp == 1:
            outCod.next = 1
        elif tmp == 3:
            outCod.next = 1
        elif tmp == 2:
            outCod.next = 2
        elif tmp == 6:
            outCod.next = 2
        elif tmp == 0:
            outCod.next = 3
        else:
            outCod.next = 3
    return cod2Logic

def cod3(inSig, outCod):
    """ 3-bit coder.

    inSig   -- in  : 7 1-bit input signals
    outCod  -- out : 3-bit coded value

    """
    tmp = intbv(0, 0, 8)
    @instance
    def cod3Logic():
        while 1:
            tmp[0] = ((not inSig[6].val) and (not inSig[5].val) and (not inSig[3].val)) or ((not inSig[6].val) and inSig[5].val and (not inSig[2].val)) or (inSig[6].val and (not inSig[4].val) and (not inSig[1].val)) or ((inSig[6].val) and (inSig[4].val) and (not inSig[0].val));
            tmp[1] = ((not inSig[6].val) and (not inSig[5].val)) or (inSig[6].val and (not inSig[4].val));
            tmp[2] = not inSig[6].val
            outCod.next = tmp
            yield inSig[0], inSig[1], inSig[2], inSig[3], inSig[4], inSig[5], inSig[6]
    return cod3Logic

def min8(op, res, q = 8):
    """ Selects the minimum between 8 values.

    q   -- accumulated distance width
    op  -- in  : input signals
    res -- out : code of the minimum value

    """
    tmp = [Signal(intbv(0, 0, 2**q)) for i in range(6)]
    cmp2_i0 = cmp2(op[0], op[1], res[0])
    cmp2_i1 = cmp2(op[2], op[3], res[1])
    cmp2_i2 = cmp2(op[4], op[5], res[2])
    cmp2_i3 = cmp2(op[6], op[7], res[3])
    mux2_i0 = mux2(op[0], op[1], res[0], tmp[0])
    mux2_i1 = mux2(op[2], op[3], res[1], tmp[1])
    mux2_i2 = mux2(op[4], op[5], res[2], tmp[2])
    mux2_i3 = mux2(op[6], op[7], res[3], tmp[3])
    cmp2_i4 = cmp2(tmp[0], tmp[1], res[4])
    cmp2_i5 = cmp2(tmp[2], tmp[3], res[5])
    mux2_i4 = mux2(tmp[0], tmp[1], res[4], tmp[4])
    mux2_i5 = mux2(tmp[2], tmp[3], res[5], tmp[5])
    cmp2_i6 = cmp2(tmp[4], tmp[5], res[6])

    return cmp2_i0, cmp2_i1, cmp2_i2, cmp2_i3, mux2_i0, mux2_i1, mux2_i2, mux2_i3, cmp2_i4, cmp2_i5, mux2_i4, mux2_i5, cmp2_i6

def mux8(in1, in2, in3, in4, in5, in6, in7, in8, sel, outSel):
    """ 8-input mux (4 bits per input).

    in1     -- in  : first input signals
    in2     -- in  : second input signals
    in3     -- in  : third input signals
    in4     -- in  : fourth input signals
    in5     -- in  : fifth input signals
    in6     -- in  : sixth input signals
    in7     -- in  : seventh input signals
    in8     -- in  : eighth input signals
    sel     -- in  : 3-bit control signal
    outSel  -- out : selected output signals

    """
    @instance
    def mux8Logic():
        while 1:
            if sel.val == 0:
                for i in range(4):
                    outSel[i].next = in1[i].val
            elif sel.val == 1:
                for i in range(4):
                    outSel[i].next = in2[i].val
            elif sel.val == 2:
                for i in range(4):
                    outSel[i].next = in3[i].val
            elif sel.val == 3:
                for i in range(4):
                    outSel[i].next = in4[i].val
            elif sel.val == 4:
                for i in range(4):
                    outSel[i].next = in5[i].val
            elif sel.val == 5:
                for i in range(4):
                    outSel[i].next = in6[i].val
            elif sel.val == 6:
                for i in range(4):
                    outSel[i].next = in7[i].val
            else:
                for i in range(4):
                    outSel[i].next = in8[i].val
            yield in1[0], in1[1], in1[2], in1[3], in2[0], in2[1], in2[2], in2[3], in3[0], in3[1], in3[2], in3[3], in4[0], in4[1], in4[2], in4[3], in5[0], in5[1], in5[2], in5[3], in6[0], in6[1], in6[2], in6[3], in7[0], in7[1], in7[2], in7[3], in8[0], in8[1], in8[2], in8[3], sel
    return mux8Logic

def sub(op1, op2, res):
    """ Substracter.

    op1 -- in  : first operand
    op2 -- in  : second operand
    res -- out : result of the substraction

    """
    @instance
    def subLogic():
        while 1:
            if op1.val >= op2.val:  # remove that when translate into Verilog (Python expects a positive result)
                res.next = op1.val - op2.val
            yield op1, op2
    return subLogic
