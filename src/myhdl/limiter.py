######################################################################
####                                                              ####
####  limiter.py                                                  ####
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



from myhdl import Signal, always_comb

def limiter(a, b, y1, y2, y1Int, y2Int, aLim, bLim, y1Lim, y2Lim, y1IntLim, y2IntLim, n = 4):
    """ Limiter [-2**(n - 1) + 1, 2**(n - 1) - 1].

    n                                               -- number of bits for the coding of the decoder input signals
    a, b, y1, y2, y1Int, y2Int                      -- in  : decoder input signals, coded with n bits
    aLim, bLim, y1Lim, y2Lim, y1IntLim, y2IntLim    -- out : limited signals

    """
    @always_comb
    def limitLogic():
        if a.val <= -2**(n - 1):
            aLim.next = -2**(n - 1) + 1
        elif a.val >= 2**(n - 1):
            aLim.next = 2**(n - 1) - 1
        else:
            aLim.next = a.val
        if b.val <= -2**(n - 1):
            bLim.next = -2**(n - 1) + 1
        elif b.val >= 2**(n - 1):
            bLim.next = 2**(n - 1) - 1
        else:
            bLim.next = b.val
        if y1.val <= -2**(n - 1):
            y1Lim.next = -2**(n - 1) + 1
        elif y1.val >= 2**(n - 1):
            y1Lim.next = 2**(n - 1) - 1
        else:
            y1Lim.next = y1.val
        if y2.val <= -2**(n - 1):
            y2Lim.next = -2**(n - 1) + 1
        elif y2.val >= 2**(n - 1):
            y2Lim.next = 2**(n - 1) - 1
        else:
            y2Lim.next = y2.val
        if y1Int.val <= -2**(n - 1):
            y1IntLim.next = -2**(n - 1) + 1
        elif y1Int.val >= 2**(n - 1):
            y1IntLim.next = 2**(n - 1) - 1
        else:
            y1IntLim.next = y1Int.val
        if y2Int.val <= -2**(n - 1):
            y2IntLim.next = -2**(n - 1) + 1
        elif y2Int.val >= 2**(n - 1):
            y2IntLim.next = 2**(n - 1) - 1
        else:
            y2IntLim.next = y2Int.val
    return limitLogic
