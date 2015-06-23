######################################################################
####                                                              ####
####  distances.py                                                ####
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



from misc import opposite, adder, register
from myhdl import Signal, intbv, always_comb, instance

def partDistance(a, b, y1, y2, res, ref = intbv(0, 0, 8)):
    """ Partial distance from (a, b, y1, y2) = ref.

    ref             -- reference to compute the distance from
    a, b, y1, y2    -- in  : decoder input signals, coded with n bits
    res             -- out : partial distance signal, coded with (n + 2) bits

    """
    @instance
    def partDistanceLogic():
        while 1:
            if ref[2] == 0:
                bSigned = b.val
            else:
                bSigned = -b.val
            if ref[1] == 0:
                y1Signed = y1.val
            else:
                y1Signed = -y1.val
            if ref[0] == 0:
                y2Signed = y2.val
            else:
                y2Signed = -y2.val
            res.next = a.val + bSigned + y1Signed + y2Signed
            yield a, b, y1, y2
    return partDistanceLogic

def distance(partDist, z, dist, n = 4):
    """ Distance computation.

    n           -- number of bits for the coding of the decoder input signals
    partDist    -- in  : sum of the decoder input signals
    z           -- in  : extrinsic information
    dist        -- out : distance

    """
    @always_comb
    def distanceLogic():
        dist.next = (4 * (2 ** (n - 1) - 1) + partDist.val) / 2 + z.val
    return distanceLogic

def distances(a, b, y1, y2, z, distance16, n = 4):
    """ Computes the 16 distances from the decoder input signals.

    n               -- number of bits for the coding of the decoder input signals
    a, b, y1, y2    -- in  : decoder input signals, coded with n bits
    z               -- in  : extrinsic information signals (x4), coded with m bits
    distance16      -- out : distance signals (x16)

    """
    partDist = [Signal(intbv(0, -(2**(n+1)), 2**(n+1))) for i in range(16)]
    opposite_i = [None for i in range(8)]
    distance_i = [None for i in range(16)]
    partDistance_i = [None for i in range(8)]
    for i in range(8):
        partDistance_i[i] = partDistance(a, b, y1, y2, partDist[i], intbv(i, 0, 8))
    for i in range(8):
        opposite_i[i] = opposite(partDist[i], partDist[15 - i])
    for i in range(16):
        distance_i[i] = distance(partDist[i], z[i / 4], distance16[i], n)

    return partDistance_i, opposite_i, distance_i

def reduction(org, chd, q = 8):
    """ (Reduction: if anyone's q(th) bit is set, divide everyone by 2.)
        Temporary test: when everyone's q(th) bit is set, reset everyone's q(th) bit.

    q   -- accumulated distance width
    org -- in  : original array of 8 q-bit accumulated distances
    chd -- out : reduced array of 8 q-bit accumulated distances

    """
#    tmp = intbv(0, 0, 2**q)
    @instance
    def reductionLogic():
        while 1:
#        msb = bool(0)
            msb = bool(1)
            for i in range(8):
#            msb = msb or org[i].val[q-1]
                msb = msb and org[i].val[q - 1]
            for i in range(8):
                chd[i].next[q-1:0] = org[i].val[q-1:0]
                chd[i].next[q - 1] = (not msb) and org[i].val[q - 1]
#            if msb == 1:
#                tmp[q-1:0] = org[i].val[q:1]
#            else:
#                tmp = org[i].val
#            chd[i].next = tmp
            yield org[0], org[1], org[2], org[3], org[4], org[5], org[6], org[7]
    return reductionLogic

def accDist(clk, rst, accDistReg, dist, accDistNew, q = 8):
    """ Accumulated distances.

    q           -- in  : accumulated distance width
    clk, rst    -- in  : clock and negative reset
    accDistReg  -- in  : original array of 8 q-bit accumulated distance registers
    dist        -- in  : array of 16 distances
    accDistNew  -- out : array of 32 (q+1)-bit accumulated distances

    """
    adder_i     = [None for i in range(32)]
    register_i  = [None for i in range(8)]
    accDistOld  = [Signal(intbv(0, 0, 2**q)) for i in range(8)]
    accDistRed  = [Signal(intbv(0, 0, 2**q)) for i in range(8)]
    accDistRegSorted    = [Signal(intbv(0, 0, 2**q)) for i in range(8)]
    accDistRegDelta     = [Signal(intbv(0, 0, 2**q)) for i in range(8)]
    distIndex   = [0, 7, 11, 12,   0, 7, 11, 12,   2, 5, 9, 14,   2, 5, 9, 14,    3, 4, 8, 15,   3, 4, 8, 15,   1, 6, 10, 13,   1, 6, 10, 13]
    for i in range(32):
        adder_i[i] = adder(accDistOld[i/4], dist[distIndex[i]], accDistNew[i])
    reduction_i0 = reduction(accDistReg, accDistRed, q)
    for i in range(8):
        register_i[i] = register(clk, rst, accDistRed[i], accDistOld[i])

    return adder_i, register_i, reduction_i0
