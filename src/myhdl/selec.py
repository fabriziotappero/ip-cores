######################################################################
####                                                              ####
####  select.py                                                   ####
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



from misc import min4, cod2, mux4, min8, cod3
from myhdl import Signal, instances

def accDistSel(accDist, accDistCod, accDistOut, q = 8):
    """ Accumulated distance selection (one out of four, per state)

    accDist     -- in  : array of 32 (q+1)-bit accumulated distances
    accDistCod  -- out : array of 8 2-bit selection signals
    accDistOut  -- out : array of 8 (q+1)-bit selected accumulated distances

    """
    min4_i = [None for i in range(8)]
    cod2_i = [None for i in range(8)]
    mux4_i = [None for i in range(8)]
    comp = [Signal(bool(0)) for i in range(24)]
    from2to = [0, 25, 6, 31,   8, 17, 14, 23,   20, 13, 18, 11,   28, 5, 26, 3,   4, 29, 2, 27,   12, 21, 10, 19,   16, 9, 22, 15,   24, 1, 30, 7]
    for i in range(8):
        min4_i[i] = min4(accDist[from2to[4*i]], accDist[from2to[4*i+1]], accDist[from2to[4*i+2]], accDist[from2to[4*i+3]], comp[3*i], comp[3*i+1], comp[3*i+2], q)
    for i in range(8):
        cod2_i[i] = cod2(comp[3*i], comp[3*i+1], comp[3*i+2], accDistCod[i])
    for i in range(8):
        mux4_i[i] = mux4(accDist[from2to[4*i]], accDist[from2to[4*i+1]], accDist[from2to[4*i+2]], accDist[from2to[4*i+3]], accDistCod[i], accDistOut[i])

    return min4_i, cod2_i, mux4_i

def stateSel(stateDist, selState, q = 8):
    """ State selection (one out of eight).

    q           -- accumulated distance width
    stateDist   -- in  : state accumulated distance
    selState    -- out : selected state code

    """
    tmp = [Signal(bool(0)) for i in range(7)]
    min8_i0 = min8(stateDist, tmp, q)
    cod3_i0 = cod3(tmp, selState)

    return min8_i0, cod3_i0
