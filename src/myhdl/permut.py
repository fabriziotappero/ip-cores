######################################################################
####                                                              ####
####  permut.py                                                   ####
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



from myhdl import Signal, instance

def zPermut(flipflop, z, zPerm, flip = 0):
    """ Extrinsic information permutation.
    
    flip        -- initialisation (permutation on/off)
    flipflop    -- in  : permutation control signal (on/off)
    z           -- in  : original extrinsic information
    zPerm       -- out : permuted extrinsic information
    
    """
    @instance
    def zPermutLogic():
        while 1:
            if flipflop.val == bool(flip):
                zPerm[0].next = z[0].val
                zPerm[1].next = z[1].val
                zPerm[2].next = z[2].val
                zPerm[3].next = z[3].val
            else:
                zPerm[0].next = z[0].val
                zPerm[1].next = z[2].val
                zPerm[2].next = z[1].val
                zPerm[3].next = z[3].val
            yield flipflop, z[0], z[1], z[2], z[3]
    return zPermutLogic

def abPermut(flipflop, a, b, abPerm, flip = 0):
    """ Systematic information permutation.
    
    flip        -- initialisation (permutation on/off)
    flipflop    -- in  : permutation control signal (on/off)
    a, b        -- in  : original systematic information
    abPerm      -- out : permuted systematic information
    
    """
    @instance
    def abPermutLogic():
        while 1:
            if flipflop.val == bool(flip):
                abPerm[1].next = a.val
                abPerm[0].next = b.val
            else:
                abPerm[1].next = b.val
                abPerm[0].next = a.val
            yield flipflop, a, b
    return abPermutLogic
