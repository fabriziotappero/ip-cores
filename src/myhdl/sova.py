######################################################################
####                                                              ####
####  sova.py                                                     ####
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



from extInf import extInf
from misc import delayer
from trellis import trellis1, trellis2
from acs import acs
from myhdl import Signal, intbv, instances

def sova(clk, rst, aNoisy, bNoisy, y1Noisy, y2Noisy, zin, zout, aClean, bClean, l = 20, m = 10, q = 8, r = 5, n = 4):
    """ Soft Output Viterbi Algorithm top level.
    
    l               -- first trellis length
    m               -- second trellis length
    q               -- accumulated distance width
    r               -- extrinsic information width
    n               -- systematic data width
    clk, rst        -- in  : clock and negative reset
    aNoisy, bNoisy, y1Noisy, y2Noisy    -- in  : received decoder signals
    zin             -- in  : extrinsic information input
    zout            -- out : extrinsic information output
    aClean, bClean  -- out : decoded systematic data
    
    """
    selStateL2  = Signal(intbv(0, 0, 8))
    selStateL1  = Signal(intbv(0, 0, 8))
    selTransL2  = Signal(intbv(0, 0, 4))
    selTrans    = [Signal(intbv(0, 0, 4)) for i in range(8)]
    selState    = Signal(intbv(0, 0, 8))
    weight      = [Signal(intbv(0, 0, 2**q)) for i in range(4)]
    selTransL1  = [Signal(intbv(0, 0, 4)) for i in range(8)]
    zinDel      = [Signal(intbv(0, 0, 2**r)) for i in range(4)]
    stateL1     = [Signal(intbv(0, 0, 8)) for i in range(4)]
    llr0        = Signal(intbv(0, 0, 2**q))
    llr1        = Signal(intbv(0, 0, 2**q))
    llr2        = Signal(intbv(0, 0, 2**q))
    llr3        = Signal(intbv(0, 0, 2**q))
    aNoisyDel   = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    bNoisyDel   = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))

    delayer_i   = [None for i in range(12)]
    acs_i0      = acs(clk, rst, aNoisy, bNoisy, y1Noisy, y2Noisy, zin, selStateL2, selTransL2, selState, selTrans, weight, q, l, n, r)
    trellis1_i0 = trellis1(clk, rst, selState, selTrans, selStateL2, selStateL1, stateL1, selTransL2, l)
    trellis2_i0 = trellis2(clk, rst, selStateL1, stateL1, selTransL1, weight, llr0, llr1, llr2, llr3, aClean, bClean, m, q)
    for i in range(8):
        delayer_i[i] = delayer(clk, rst, selTrans[i], selTransL1[i], l - 1, 0, 2**2)
    for i in range(4):
        delayer_i[i + 8] = delayer(clk, rst, zin[i], zinDel[i], l + m, 0, 2**r)
    delayer_i0  = delayer(clk, rst, aNoisy, aNoisyDel, l + m, -(2**(n-1)), 2**(n-1))
    delayer_i1  = delayer(clk, rst, bNoisy, bNoisyDel, l + m, -(2**(n-1)), 2**(n-1))
    extInf_i0   = extInf(llr0, llr1, llr2, llr3, zinDel, aNoisyDel, bNoisyDel, zout, r, n, q)

    return delayer_i0, delayer_i1, extInf_i0, trellis1_i0, trellis2_i0, acs_i0, delayer_i
