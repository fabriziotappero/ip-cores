######################################################################
####                                                              ####
####  turboTop.py                                                 ####
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



from punct import punct
from iteration import iteration
from permut import abPermut
from interleaver import interleaver
from testbench import ber, randGen, siho
from misc import delayer
from clock import rstGen, clkGen, clkDiv
from coder import coder
from noiser import noiser
from limiter import limiter
from myhdl import Signal, intbv, instances

def turboTop(resFile, rate = 12, it = 5, n = 4, r = 5, p = 48, d = 0, mu = 8, sigma = 6, l = 20, m = 10, q = 8):
    """ Turbo decoder top level.
    
    resFile -- files where the results will be saved
    rate    -- code rate (e.g. 12 for rate 1/2)
    it      -- number of iterations for the turbo decoding
    n       -- number of bits for the sampling of the signals - a, b, y1, y2
    r       -- number of bits for the coding of the extrinsic information
    p       -- interleaver frame size in bit couples
    d       -- additional delay through the noiser - 0 means the noiser adds 2 clock cycles
    mu      -- mean value for the noise distribution (additive noise)
    sigma   -- standard deviation of the noise distribution (0 means no noise)
    l       -- first trellis' length
    m       -- second trellis' length
    q       -- number of bits for the coding of the accumulated distances
    
    """
    # Signal declarations:
    clk         = Signal(bool(0))
    rst         = Signal(bool(1))
    flipflop    = Signal(bool(0))
    aClean      = Signal(bool(0))
    bClean      = Signal(bool(0))
    y1Clean     = Signal(bool(0))
    y2Clean     = Signal(bool(0))
    aCleanDel   = Signal(bool(0))
    bCleanDel   = Signal(bool(0))
    y1CleanDel  = Signal(bool(0))
    y2CleanDel  = Signal(bool(0))
    y1IntDel    = Signal(bool(0))
    y2IntDel    = Signal(bool(0))
    aNoisy      = Signal(int(0))
    bNoisy      = Signal(int(0))
    y1Noisy     = Signal(int(0))
    y2Noisy     = Signal(int(0))
    y1IntNoisy  = Signal(int(0))
    y2IntNoisy  = Signal(int(0))
    y1Full      = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    y2Full      = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    y1IntFull   = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    y2IntFull   = Signal(intbv(0, -(2**(n-1)), 2**(n-1)))
    aLim        = [Signal(intbv(0, -(2**(n-1)), 2**(n-1))) for i in range(it + 1)]
    bLim        = [Signal(intbv(0, -(2**(n-1)), 2**(n-1))) for i in range(it + 1)]
    y1Lim       = [Signal(intbv(0, -(2**(n-1)), 2**(n-1))) for i in range(it + 1)]
    y2Lim       = [Signal(intbv(0, -(2**(n-1)), 2**(n-1))) for i in range(it + 1)]
    y1IntLim    = [Signal(intbv(0, -(2**(n-1)), 2**(n-1))) for i in range(it + 1)]
    y2IntLim    = [Signal(intbv(0, -(2**(n-1)), 2**(n-1))) for i in range(it + 1)]
    z           = [[Signal(intbv(0, 0, 2**r)) for i in range(4)] for i in range(it + 1)]
    zSorted     = [Signal(intbv(0, 0, 2**r)) for i in range(4)]
    aDec        = [Signal(bool(0)) for i in range(it + 1)]
    bDec        = [Signal(bool(0)) for i in range(it + 1)]
    aDel        = [Signal(bool(0)) for i in range(it + 1)]
    bDel        = [Signal(bool(0)) for i in range(it + 1)]
    abInt       = [Signal(bool(0)) for i in range(2)]
    y1Int       = Signal(bool(0))
    y2Int       = Signal(bool(0))
    abCleanPerm = [Signal(bool(0)) for i in range(2)]

    delayer_ia  = [None for i in range(it + 1)]
    delayer_ib  = [None for i in range(it + 1)]
    ber_i       = [None for i in range(it + 1)]
    iteration_i = [None for i in range(it)]
    
    # Reset and clock generation:
    rstGen_i0   = rstGen(rst)
    clkGen_i0   = clkGen(clk)

    # Random data generation:
    randGen_i0  = randGen(clk, rst, aClean, bClean)

    # Interleaving and permuting:
    clkDiv_i0   = clkDiv(clk, rst, flipflop)
    abPermut_i0 = abPermut(flipflop, aClean, bClean, abCleanPerm, 1)
    interleaver_i0 = interleaver(clk, rst, abCleanPerm, abInt, p, 0, 0, 2, 2, 0)

    # Coder:
    coder_i0    = coder(clk, rst, aClean, bClean, y1Clean, y2Clean)
    coder_i1    = coder(clk, rst, abInt[1], abInt[0], y1Int, y2Int)

    # Additional delay through the channel:
    delayer_i0  = delayer(clk, rst, aClean, aCleanDel, d, 0, 2)
    delayer_i1  = delayer(clk, rst, bClean, bCleanDel, d, 0, 2)
    delayer_i2  = delayer(clk, rst, y1Clean, y1CleanDel, d, 0, 2)
    delayer_i3  = delayer(clk, rst, y2Clean, y2CleanDel, d, 0, 2)
    delayer_i4  = delayer(clk, rst, y1Int, y1IntDel, d, 0, 2)
    delayer_i5  = delayer(clk, rst, y2Int, y2IntDel, d, 0, 2)

    # Channel noiser:
    noiser_i0   = noiser(clk, rst, aCleanDel, bCleanDel, y1CleanDel, y2CleanDel, y1IntDel, y2IntDel, aNoisy, bNoisy, y1Noisy, y2Noisy, y1IntNoisy, y2IntNoisy, n, mu, sigma)

    # Decoder:
    limiter_i0  = limiter(aNoisy, bNoisy, y1Noisy, y2Noisy, y1IntNoisy, y2IntNoisy, aLim[0], bLim[0], y1Full, y2Full, y1IntFull, y2IntFull, n)
    punct_i0    = punct(clk, rst, y1Full, y2Full, y1IntFull, y2IntFull, y1Lim[0], y2Lim[0], y1IntLim[0], y2IntLim[0], rate)
    for i in range(it):
        iteration_i[i] = iteration(clk, rst, flipflop, aLim[i], bLim[i], y1Lim[i], y2Lim[i], y1IntLim[i], y2IntLim[i], z[i], z[i + 1], aDec[i + 1], bDec[i + 1], aLim[i + 1], bLim[i + 1], y1Lim[i + 1], y2Lim[i + 1], y1IntLim[i + 1], y2IntLim[i + 1], l, m, q, p, r, n, 2 * i * (l + m + 2) + 2 * i * p + 2)

    # Bit Error Rate monitoring:
    siho_i0         = siho(aLim[0], bLim[0], aDec[0], bDec[0])
    delayer_ia[0]   = delayer(clk, rst, aClean, aDel[0], 1 + d, 0, 2)
    delayer_ib[0]   = delayer(clk, rst, bClean, bDel[0], 1 + d, 0, 2)
    ber_i[0]        = ber(clk, rst, aDel[0], bDel[0], aDec[0], bDec[0], d + 100, resFile[0])
    for i in range(it):
        delayer_ia[i + 1]   = delayer(clk, rst, aClean, aDel[i + 1], (2 * i + 1) * (l + m + 2) + 2 * i * p + d, 0, 2)
        delayer_ib[i + 1]   = delayer(clk, rst, bClean, bDel[i + 1], (2 * i + 1) * (l + m + 2) + 2 * i * p + d, 0, 2)
        ber_i[i + 1]        = ber(clk, rst, aDel[i + 1], bDel[i + 1], aDec[i + 1], bDec[i + 1], (2 * i + 1) * (l + m + 2) + 2 * i * p + d + 100, resFile[i + 1])

    return rstGen_i0, clkGen_i0, randGen_i0, clkDiv_i0, abPermut_i0, interleaver_i0, coder_i0, coder_i1, delayer_i0, delayer_i1, delayer_i2, delayer_i3, delayer_i4, delayer_i5, noiser_i0, limiter_i0, punct_i0, siho_i0, delayer_ia, delayer_ib, ber_i, iteration_i
