######################################################################
####                                                              ####
####  iteration.py                                                ####
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



from misc import delayer
from interleaver import interleaver
from permut import zPermut, abPermut
from sova import sova
from myhdl import Signal, intbv, instances

def iteration(clk, rst, flipflop, a, b, y1, y2, y1Int, y2Int, zin, zout, aDec, bDec, aDel, bDel, y1Del, y2Del, y1IntDel, y2IntDel, l = 20, m = 10, q = 8, p = 48, r = 5, n = 4, delay = 0):
    """ Decoding iteration top level (two SOVAs).
    
    l               -- first trellis length
    m               -- second trellis length
    q               -- accumulated distance width
    p               -- interleaver frame size in bit couples
    r               -- extrinsic information width
    n               -- systematic data width
    delay           -- additional delay created by the previous iterations
    clk, rst        -- in  : clock and negative reset
    flipflop        -- in  : permutation control signal (on/off)
    a, b, y1, y2, y1Int, y2Int  -- in  : received decoder signals
    zin             -- in  : extrinsic information from the previous iteration
    zout            -- out : extrinsic information to the next iteration
    aDec, bDec      -- out : decoded signals
    aDel, bDel, y1Del, y2Del, y1IntDel, y2IntDel    -- out : delayed received decoder signals
    
    """
    # Signal declarations:
    aDecInt     = Signal(bool(0))
    bDecInt     = Signal(bool(0))
    zoutInt1    = [Signal(intbv(0, 0, 2**r)) for i in range(4)]
    zout1Perm   = [Signal(intbv(0, 0, 2**r)) for i in range(4)]
    aDel1       = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    bDel1       = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    aDel2       = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    bDel2       = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    y1Del1      = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    y2Del1      = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    y1Del2      = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    y2Del2      = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    y1IntDel1   = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    y2IntDel1   = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    y1IntDel3   = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    y2IntDel3   = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    y1IntDel4   = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    y2IntDel4   = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    aDel3       = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    bDel3       = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    abDel1Perm  = [Signal(intbv(0, -(2**(n-1)), 2**(n-1))) for i in range(2)]
    abDel1PermInt = [Signal(intbv(0, -(2**(n-1)), 2**(n-1))) for i in range(2)]
    y1Del3      = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    y2Del3      = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    zout1       = [Signal(intbv(0, 0, 2**r)) for i in range(4)]
    zout2       = [Signal(intbv(0, 0, 2**r)) for i in range(4)]
    zout2Int    = [Signal(intbv(0, 0, 2**r)) for i in range(4)]

    # Instanciations:
    sova_i0     = sova(clk, rst, a, b, y1, y2, zin, zout1, aDec, bDec, l, m, q, r, n)
    zPermut_i0  = zPermut(flipflop, zout1, zout1Perm, (l + m + 2 + delay + 1) % 2)
    interleaver_i0  = interleaver(clk, rst, zout1Perm, zoutInt1, p, l + m + 2 + delay, 0, 2**r, 4, 0)
    delayer_i0  = delayer(clk, rst, a, aDel1, (l + m), -(2**(n-1)), 2**(n-1))
    delayer_i1  = delayer(clk, rst, b, bDel1, (l + m), -(2**(n-1)), 2**(n-1))
    delayer_i2  = delayer(clk, rst, y1, y1Del1, (l + m), -(2**(n-1)), 2**(n-1))
    delayer_i3  = delayer(clk, rst, y2, y2Del1, (l + m), -(2**(n-1)), 2**(n-1))
    delayer_i4  = delayer(clk, rst, y1Int, y1IntDel1, (l + m), -(2**(n-1)), 2**(n-1))
    delayer_i5  = delayer(clk, rst, y2Int, y2IntDel1, (l + m), -(2**(n-1)), 2**(n-1))
    abPermut_i0 = abPermut(flipflop, aDel1, bDel1, abDel1Perm, (l + m + 2 + delay + 1) % 2)
    interleaver_i1  = interleaver(clk, rst, abDel1Perm, abDel1PermInt, p, l + m + 2 + delay, -(2**(n-1)), 2**(n-1), 2, 0)
    delayer_i6  = delayer(clk, rst, aDel1, aDel2, p, -(2**(n-1)), 2**(n-1))
    delayer_i7  = delayer(clk, rst, bDel1, bDel2, p, -(2**(n-1)), 2**(n-1))
    delayer_i8  = delayer(clk, rst, y1Del1, y1Del2, p, -(2**(n-1)), 2**(n-1))
    delayer_i9  = delayer(clk, rst, y2Del1, y2Del2, p, -(2**(n-1)), 2**(n-1))
    sova_i1     = sova(clk, rst, abDel1PermInt[1], abDel1PermInt[0], y1IntDel1, y2IntDel1, zoutInt1, zout2, aDecInt, bDecInt, l, m, q, r, n)
    deinterleaver_i0    = interleaver(clk, rst, zout2, zout2Int, p, 2 * (l + m + 2) + p + delay, 0, 2**r, 4, 1)
    zPermut_i1  = zPermut(flipflop, zout2Int, zout, (2 * (l + m + 2) + p + delay) % 2)
    delayer_i10 = delayer(clk, rst, aDel2, aDel3, (l + m), -(2**(n-1)), 2**(n-1))
    delayer_i11 = delayer(clk, rst, bDel2, bDel3, (l + m), -(2**(n-1)), 2**(n-1))
    delayer_i12 = delayer(clk, rst, y1Del2, y1Del3, (l + m), -(2**(n-1)), 2**(n-1))
    delayer_i13 = delayer(clk, rst, y2Del2, y2Del3, (l + m), -(2**(n-1)), 2**(n-1))
    delayer_i14 = delayer(clk, rst, y1IntDel1, y1IntDel3, (l + m), -(2**(n-1)), 2**(n-1))
    delayer_i15 = delayer(clk, rst, y2IntDel1, y2IntDel3, (l + m), -(2**(n-1)), 2**(n-1))
    delayer_i16 = delayer(clk, rst, aDel3, aDel, p, -(2**(n-1)), 2**(n-1))
    delayer_i17 = delayer(clk, rst, bDel3, bDel, p, -(2**(n-1)), 2**(n-1))
    delayer_i18 = delayer(clk, rst, y1Del3, y1Del, p, -(2**(n-1)), 2**(n-1))
    delayer_i19 = delayer(clk, rst, y2Del3, y2Del, p, -(2**(n-1)), 2**(n-1))
    delayer_i20 = delayer(clk, rst, y1IntDel3, y1IntDel4, p, -(2**(n-1)), 2**(n-1))
    delayer_i21 = delayer(clk, rst, y2IntDel3, y2IntDel4, p, -(2**(n-1)), 2**(n-1))
    delayer_i22 = delayer(clk, rst, y1IntDel4, y1IntDel, p, -(2**(n-1)), 2**(n-1))
    delayer_i23 = delayer(clk, rst, y2IntDel4, y2IntDel, p, -(2**(n-1)), 2**(n-1))

    return sova_i0, zPermut_i0, interleaver_i0, delayer_i0, delayer_i1, delayer_i2, delayer_i3, delayer_i4, delayer_i5, abPermut_i0, interleaver_i1, delayer_i6, delayer_i7, delayer_i8, delayer_i9, sova_i1, deinterleaver_i0, zPermut_i1, delayer_i10, delayer_i11, delayer_i12, delayer_i13, delayer_i14, delayer_i15, delayer_i16, delayer_i17, delayer_i18, delayer_i19, delayer_i20, delayer_i21, delayer_i22, delayer_i23
