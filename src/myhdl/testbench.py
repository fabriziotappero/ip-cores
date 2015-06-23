######################################################################
####                                                              ####
####  testbench.py                                                ####
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



from random import randrange
from myhdl import Signal, posedge, negedge, always, instance

def randGen(clk, rst, a, b):
    """ Random signal generator.

    clk, rst    -- in  : clock and negative reset
    a, b        -- out : generated random signals

    """
#    x = Signal(int(0))
    @always(clk.posedge, rst.negedge)
    def randGenLogic():
        if rst.val == 0:
            a.next = 0
            b.next = 0
#            x.next = 0
        else:
            a.next = randrange(2)
            b.next = randrange(2)

#            a.next = 1
#            b.next = 1
            
#            if x.val == 0:
#                a.next = 1
#                b.next = 0
#                x.next = 1
#            if x.val == 1:
#                a.next = 0
#                b.next = 1
#                x.next = 2
#            if x.val == 2:
#                a.next = 0
#                b.next = 0
#                x.next = 0

#            if x.val == 0:
#                a.next = 0
#                b.next = 1
#                x.next = 1
#            else:
#                a.next = 0
#                b.next = 1
    return randGenLogic

def ber(clk, rst, aOrg, bOrg, aDec, bDec, wait, resFile):
    """ Bit Error Rate monitor.

    it          -- iteration number (0 is before decoding)
    clk, rst    -- in  : clock and negative reset
    aOrg, bOrg  -- in  : original data
    aDec, bDec  -- in  : decoded data
    wait        -- in  : number of clock cycles to wait before computing the BER
    resFile     -- out : file where the BER is saved

    """
    ber = Signal(0.0)
    cnt = Signal(0)
    diffCnt = Signal(0)
    waitCnt = Signal(0)
    @always(clk.posedge, rst.negedge)
    def berLogic():
        if rst.val == 0:
            orgCnt = 0
            j = 0
            waitCnt.next = 0
        else:
            if waitCnt == wait:
                cnt.next = cnt + 1
                if aOrg.val != aDec.val:
                    diffCnt.next = diffCnt + 1
                if bOrg.val != bDec.val:
                    diffCnt.next = diffCnt + 1
                ber.next = float(diffCnt.next) / float(2 * cnt.next)
                resFile.write('%1.10f\n' % ber.next)
                if (cnt.next % 100) == 0:
                    resFile.flush()
            else:
                waitCnt.next = waitCnt + 1
    return berLogic

def siho(aSoft, bSoft, aHard, bHard):
    """ Soft Input Hard Output decision.
    
    aSoft, bSoft    -- in  : soft inputs
    aHard, bHard    -- out : hard outputs
    
    """
    @instance
    def sihoLogic():
        while 1:
            if aSoft.val < 0:
                aHard.next = 0
            else:
                aHard.next = 1
            if bSoft.val < 0:
                bHard.next = 0
            else:
                bHard.next = 1
            yield aSoft, bSoft
    return sihoLogic

def monitor(clk, rst, *args):
    """ Signal monitor.
    
    clk, rst    -- in  : clock and negative reset
    args        -- in  : list of signals to monitor
    
    """
    @always(clk.posedge, rst.negedge)
    def monitorLogic():
        if rst.val != 0:
            for arg in args:
                print "%3d" % int(arg),
            print
    return monitorLogic

def sorter(clk, rst, *args):
    """ Sorter.
    
    clk, rst    -- in  : clock and negative reset
    args        -- in/out : arguments to be sorted / sorted arguments (first half is input / second half is output)

    """
    argNb = len(args) / 2
    @always(clk.posedge, rst.negedge)
    def sorterLogic():
        if rst.val == 0:
            for i in range(argNb):
                args[i + argNb].next = 0
        else:
            arr = []
            for i in range(argNb):
                arr.append(int(args[i].val))
            arr.sort()
            for i in range(argNb):
                args[i + argNb].next = arr[i]
    return sorterLogic

def sorter(*args):
    """ Sorter.
    
    args    -- in/out : data to be sorted / sorted data (first half is input / second half is output)

    """
    argNb = len(args) / 2
    @instance
    def sorterLogic():
        while 1:
            arr = []
            for i in range(argNb):
                arr.append(int(args[i].val))
            arr.sort()
            for i in range(argNb):
                args[i + argNb].next = arr[i]
            yield args
    return sorterLogic

def delta(*args):
    """ Removes the minimum value from all values.
    
    args    -- in/out : original data / delta data (first half is input / second half is output)

    """
    argNb = len(args) / 2
    @instance
    def deltaLogic():
        while 1:
            arr = []
            for i in range(argNb):
                arr.append(int(args[i].val))
            minimum = min(arr)
            for i in range(argNb):
                args[i + argNb].next = arr[i] - minimum
            yield args
    return deltaLogic
