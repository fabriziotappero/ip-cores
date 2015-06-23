######################################################################
####                                                              ####
####  acs.py                                                      ####
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



from selec import accDistSel, stateSel
from misc import opposite, delayer, mux8, mux4, sub
from distances import distances, accDist
from myhdl import Signal, instances, intbv

def acs(clk, rst, a, b, y1, y2, z, selStateL, selDistL, selState, stateDist, weight, q = 8, l = 20, n = 4, r = 5):
    """ Add-Compare-Select top level.

    q               -- accumulated distance width
    l               -- first trellis length
    n               -- received decoder signal width
    r               -- extrinsic information width
    clk, rst        -- in  : clock and negative reset
    a, b, y1, y2    -- in  : received decoder signals
    z               -- in  : extrinsic information
    selStateL       -- in  : selected state at t = L
    selDistL        -- in  : selected transition at selStateL
    selState        -- out : selected state
    stateDist       -- out : selected accumulated distances (per state)
    weight          -- out : four weights sorted by transition code

    """
    from2to = [0, 25, 6, 31,   8, 17, 14, 23,   20, 13, 18, 11,   28, 5, 26, 3,   4, 29, 2, 27,   12, 21, 10, 19,   16, 9, 22, 15,   24, 1, 30, 7]
    distance16 = [Signal(intbv(0, 0, 4*(2**(n-1))+(2**r))) for i in range(16)]
    accDist8 = [Signal(intbv(0, 0, 2**q)) for i in range(8)]
    accDist32 = [Signal(intbv(0, 0, 2**q)) for i in range(32)]
    accDistDel32 = [[Signal(intbv(0, 0, 2**q)) for i in range(4)] for j in range(8)]
    accDistDel4 = [Signal(intbv(0, 0, 2**q)) for i in range(4)]
    selAccDistL = Signal(intbv(0, 0, 2**q))
    delayer_i = [None for i in range(32)]
    distances_i0 = distances(a, b, y1, y2, z, distance16)
    accDist_i0 = accDist(clk, rst, accDist8, distance16, accDist32, q)
    for i in range(8):
        for j in range(4):
            delayer_i[i * 4 + j] = delayer(clk, rst, accDist32[from2to[i * 4 + j]], accDistDel32[i][j], l - 1, 0, 2**(q+1))
    mux8_i0 = mux8(accDistDel32[0], accDistDel32[1], accDistDel32[2], accDistDel32[3], accDistDel32[4], accDistDel32[5], accDistDel32[6], accDistDel32[7], selStateL, accDistDel4)
    mux4_i0 = mux4(accDistDel4[0], accDistDel4[1], accDistDel4[2], accDistDel4[3], selDistL, selAccDistL)
    sub_i0 = sub(accDistDel4[0], selAccDistL, weight[0])
    sub_i1 = sub(accDistDel4[1], selAccDistL, weight[1])
    sub_i2 = sub(accDistDel4[2], selAccDistL, weight[2])
    sub_i3 = sub(accDistDel4[3], selAccDistL, weight[3])
    accDistSel_i0 = accDistSel(accDist32, stateDist, accDist8, q)
    stateSel_i0 = stateSel(accDist8, selState, q)

    return distances_i0, accDist_i0, mux8_i0, mux4_i0, sub_i0, sub_i1, sub_i2, sub_i3, accDistSel_i0, stateSel_i0, delayer_i
