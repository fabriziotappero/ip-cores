######################################################################
####                                                              ####
####  clock.py                                                    ####
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



from myhdl import Signal, delay, posedge, negedge, instance, always

def clkGen(clk, duration_1 = 10, duration_2 = 10):
    """ Clock signal generator.

    duration_1  -- first level duration
    duration_2  -- second level duration
    clk         -- out : generated clock signal

    """
    @instance
    def clkGenLogic():
        while 1:
            yield delay(duration_1)
            clk.next = not clk.val
            yield delay(duration_2)
            clk.next = not clk.val
    return clkGenLogic

def rstGen(rst, start = 5, duration = 10):
    """ Reset signal generator.

    start       -- reset pulse start time
    duration    -- reset pulse duration
    rst         -- out : generated reset signal

    """
    @instance
    def rstGenLogic():
        yield delay(start)
        rst.next = not rst.val
        yield delay(duration)
        rst.next = not rst.val
    return rstGenLogic

def clkDiv(clk, rst, clkout):
    """ Clock divider (freq/2).
    
    clk, rst    -- in  : clock and negative reset
    clkout      -- out : clock which frequency is half of the input clock
    
    """
    @always(clk.posedge, rst.negedge)
    def clkDivLogic():
        if rst.val == 0:
            clkout.next = False
        else:
            clkout.next = not clkout.val
    return clkDivLogic
