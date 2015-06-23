######################################################################
####                                                              ####
####  punct.py                                                    ####
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



from myhdl import Signal, intbv, always_comb, always, posedge, negedge

def punct(clk, rst, y1, y2, y1Int, y2Int, y1Punct, y2Punct, y1IntPunct, y2IntPunct, rate = 13):
    """ Puncturing mechanism.
    
    rate                                        -- code rate (e.g. 13 for rate 1/3)
    clk, rst                                    -- in  : clock and negative reset
    y1, y2, y1Int, y2Int                        -- in  : original data
    y1Punct, y2Punct, y1IntPunct, y2IntPunct    -- out : punctured data
    
    """
    y1Sel = Signal(bool(0))
    y2Sel = Signal(bool(0))
    punctSel_i0 = punctSel(clk, rst, y1Sel, y2Sel, rate)
    punctMux_i0 = punctMux(y1Sel, y2Sel, y1, y2, y1Int, y2Int, y1Punct, y2Punct, y1IntPunct, y2IntPunct)

    return punctSel_i0, punctMux_i0

def punctSel(clk, rst, y1Sel, y2Sel, rate = 13):
    """ Puncturing selection (between original data (1) and 0 (0)).
    
    clk, rst        -- in  : clock and negative reset
    y1Sel, y2Sel    -- out : selection signals (1 -> original data, 0 -> 0)
    
    """
    if rate == 13:
        pattern = [[1], [1]]
    elif rate == 25:
        pattern = [[1, 1], [1, 0]]
    elif rate == 12:
        pattern = [[1], [0]]
    elif rate == 23:
        pattern = [[1, 0], [0, 0]]
    elif rate == 34:
        pattern = [[1, 0, 0], [0, 0, 0]]
    elif rate == 45:
        pattern = [[1, 0, 0, 0], [0, 0, 0, 0]]
    elif rate == 67:
        pattern = [[1, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
    else:
        print "ERROR: the code rate you specified is not valid!"
    cntMax = len(pattern[0])
    cnt = Signal(intbv(0, 0, cntMax))
    @always(clk.posedge, rst.negedge)
    def punctSelLogic():
        if rst.val == 0:
            y1Sel.next = 0
            y2Sel.next = 0
            cnt.next = 0
        else:
            if cnt.val < cntMax - 1:
                cnt.next = cnt.val + 1
            else:
                cnt.next = 0
            y1Sel.next = pattern[0][int(cnt.val)]
            y2Sel.next = pattern[1][int(cnt.val)]
    return punctSelLogic

def punctMux(y1Sel, y2Sel, y1, y2, y1Int, y2Int, y1Punct, y2Punct, y1IntPunct, y2IntPunct):
    """ Puncturing mux.
    
    y1Sel, y2Sel                                -- in  : selection signals (1 -> original data, 0 -> 0)
    y1, y2, y1Int, y2Int                        -- in  : original data
    y1Punct, y2Punct, y1IntPunct, y2IntPunct    -- out : punctured data
    
    """
    @always_comb
    def punctMuxLogic():
        if y1Sel.val == 1:
            y1Punct.next = y1.val
            y1IntPunct.next = y1Int.val
        else:
            y1Punct.next = 0
            y1IntPunct.next = 0
        if y2Sel.val == 1:
            y2Punct.next = y2.val
            y2IntPunct.next = y2Int.val
        else:
            y2Punct.next = 0
            y2IntPunct.next = 0
    return punctMuxLogic
