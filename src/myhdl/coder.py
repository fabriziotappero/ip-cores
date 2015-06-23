######################################################################
####                                                              ####
####  coder.py                                                    ####
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



from myhdl import Signal, posedge, negedge, always_comb, always

def coderState(clk, rst, a, b, q1, q2, q3):
    """ Coder state registers.

    clk, rst    -- in  : clock and negative reset
    a, b        -- in  : original data
    q1, q2, q3  -- out : coder registers

    """
    @always(clk.posedge, rst.negedge)
    def coderStateLogic():
        if rst.val == 0:
            q1.next = 0
            q2.next = 0
            q3.next = 0
        else:
            q1.next = a.val ^ b.val ^ q1.val ^ q3.val
            q2.next = q1.val ^ b.val
            q3.next = q2.val ^ b.val
    return coderStateLogic

def coderY1Y2(a, b, q1, q2, q3, y1, y2):
    """ Coder redundant output generation.

    a, b        -- in  : original data signals
    q1, q2, q3  -- in  : coder registers
    y1, y2      -- out : coder redundant data signals

    """
    @always_comb
    def coderY1Y2Logic():
        y1.next = a.val ^ b.val ^ q1.val ^ q3.val ^ q2.val ^ q3.val
        y2.next = a.val ^ b.val ^ q1.val ^ q3.val ^ q3.val
    return coderY1Y2Logic

def coder(clk, rst, a, b, y1, y2):
    """ Coder top level.

    clk, rst    -- in  : clock and negative reset
    a, b        -- in  : original data signals (= systematic data)
    y1, y2      -- out : coder redundant data signals

    """
    q1 = Signal(bool(0))
    q2 = Signal(bool(0))
    q3 = Signal(bool(0))
    coderState_i0 = coderState(clk, rst, a, b, q1, q2, q3)
    coderY1Y2_i0  = coderY1Y2(a, b, q1, q2, q3, y1, y2)

    return coderState_i0, coderY1Y2_i0
