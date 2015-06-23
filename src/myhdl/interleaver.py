######################################################################
####                                                              ####
####  interleaver.py                                              ####
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



from myhdl import Signal, intbv, posedge, negedge, always

def interleaver(clk, rst, d, q, frSize = 48, delay = 0, minVal = 0, maxVal = 2, dim = 2, way = 0):
    """ DVB-RCS (de)interleaver.

    frSize          -- frame size
    delay           -- number of clock cycles to wait before starting the (de)interleaver
    minVal, maxVal  -- min and max values of the stored signals
    dim             -- number of dimensions of the stored signals
    way             -- 0 for interleaving, 1 for deinterleaving
    clk, rst        -- in  : clock and negative reset
    d               -- in  : input data
    q               -- out : interleaved data

    """
    array1 = [[Signal(intbv(0, minVal, maxVal)) for l in range(dim)] for k in range(frSize)]
    array2 = [[Signal(intbv(0, minVal, maxVal)) for l in range(dim)] for k in range(frSize)]
    full = Signal(bool(0))
    i = Signal(intbv(0, 0, frSize))
    j = Signal(intbv(0, 0, frSize))
    iTmp = Signal(intbv(0, 0, frSize))
    iTmp1 = intbv(0, 0, 2 * frSize)
    iTmp2 = intbv(0, 0, 2 * frSize)
    iTmp3 = intbv(0, 0, 2 * frSize)
    cnt = Signal(intbv(0, 0, delay + 1))
    if frSize == 48:
        p0 = 11
        p1 = 24
        p2 = 0
        p3 = 24
    elif frSize == 64:
        p0 = 7
        p1 = 34
        p2 = 32
        p3 = 2
    elif frSize == 212:
        p0 = 13
        p1 = 106
        p2 = 108
        p3 = 2
    elif frSize == 220:
        p0 = 23
        p1 = 112
        p2 = 4
        p3 = 116
    elif frSize == 228:
        p0 = 17
        p1 = 116
        p2 = 72
        p3 = 188
    elif frSize == 424:
        p0 = 11
        p1 = 6
        p2 = 8
        p3 = 2
    elif frSize == 432:
        p0 = 13
        p1 = 0
        p2 = 4
        p3 = 8
    elif frSize == 440:
        p0 = 13
        p1 = 10
        p2 = 4
        p3 = 2
    elif frSize == 848:
        p0 = 19
        p1 = 2
        p2 = 16
        p3 = 6
    elif frSize == 856:
        p0 = 19
        p1 = 428
        p2 = 224
        p3 = 652
    elif frSize == 864:
        p0 = 19
        p1 = 2
        p2 = 16
        p3 = 6
    elif frSize == 752:
        p0 = 19
        p1 = 376
        p2 = 224
        p3 = 600
    else:
        print "ERROR: interleaver does not have a valid DVB-RCS frame size!"
    @always(clk.posedge, rst.negedge)
    def interleaverLogic():
        if rst.val == 0:
            iTmp.next = 0
            i.next = 0
            j.next = 0
            cnt.next = 0
            full.next = 0
            for l in range(dim):
                q[l].next = 0
            for k in range(frSize):
                for l in range(dim):
                    array1[k][l].next = 0
                    array2[k][l].next = 0
        else:
            if cnt.val < delay:
                cnt.next = cnt.val + 1
            else:
                if j.val[2:0] == 0:
                    p = 0
                elif j.val[2:0] == 1:
                    p = frSize / 2 + p1
                elif j.val[2:0] == 2:
                    p = p2
                else:   # if j.val[2:0] == 3:
                    p = frSize / 2 + p3
                iTmp1 = iTmp.val + p0
                if iTmp1 >= frSize:
                    iTmp2 = iTmp1 - frSize
                else:
                    iTmp2 = iTmp1
                iTmp.next = iTmp2
                iTmp3 = iTmp2 + p + 1
                if iTmp3 >= 2 * frSize:
                    i.next = iTmp3 - 2 * frSize
                elif iTmp3 >= frSize:
                    i.next = iTmp3 - frSize
                else:
                    i.next = iTmp3
#                i.next = intbv((p0 * j.val + p + 1) % frSize)
                if j.val == (frSize - 1):
                    j.next = 0
                    full.next = not full.val
                else:
                    j.next = j.val + 1
                if way == 0:
                    ii = i.val
                    jj = j.val
                else:
                    ii = j.val
                    jj = i.val
                if full.val == 0:
                    for l in range(dim):
                        array1[int(jj)][l].next = d[l].val
                        q[l].next = array2[int(ii)][l].val
                else:
                    for l in range(dim):
                        array2[int(jj)][l].next = d[l].val
                        q[l].next = array1[int(ii)][l].val
    return interleaverLogic
