######################################################################
####                                                              ####
####  extInf.py                                                   ####
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



from myhdl import Signal, intbv, instance

def extInf(llr0, llr1, llr2, llr3, zin, a, b, zout, r = 5, n = 4, q = 8):
    """ Extrinsic information.
    
    r       -- extrinsic information width
    n       -- systematic data width
    q       -- accumulated distance width
    llr0    -- in  : LLR for (a, b) = (0, 0)
    llr1    -- in  : LLR for (a, b) = (0, 1)
    llr2    -- in  : LLR for (a, b) = (1, 0)
    llr3    -- in  : LLR for (a, b) = (1, 1)
    zin     -- in  : extrinsic information input signal
    a, b    -- in  : decoder systematic input signals
    zout    -- out : extrinsic information output signal
    
    """
    a_plus_b = intbv(0, -(2**(n-1)), 2**(n-1))
    a_min_b = intbv(0, -(2**(n-1)), 2**(n-1))
    tmp = [intbv(0, -(2**(n-1)) - (2**r), 2**q + 2**(n-1)) for i in range(7)]
    tmp2 = [intbv(0, 0, 2**q + 2**(n-1) + (2**(n-1)) + (2**r)) for i in range(4)]
    @instance
    def extInfLogic():
        while 1:
            a_plus_b = (a.val + b.val) / 2
            a_min_b = (a.val - b.val) / 2
            tmp[0] = llr0.val - a_plus_b - zin[0].val
            tmp[1] = llr1.val - a_min_b  - zin[1].val
            tmp[2] = llr2.val + a_min_b  - zin[2].val
            tmp[3] = llr3.val + a_plus_b - zin[3].val
            if tmp[0] < tmp[1]:
                tmp[4] = tmp[0]
            else:
                tmp[4] = tmp[1]
            if tmp[2] < tmp[3]:
                tmp[5] = tmp[2]
            else:
                tmp[5] = tmp[3]
            if tmp[4] < tmp[5]:
                tmp[6] = tmp[4]
            else:
                tmp[6] = tmp[5]
            tmp2[0] = intbv(tmp[0] - tmp[6])
            tmp2[1] = intbv(tmp[1] - tmp[6])
            tmp2[2] = intbv(tmp[2] - tmp[6])
            tmp2[3] = intbv(tmp[3] - tmp[6])
            if tmp2[0] >= 2**r:
                zout[0].next = 2**r - 1
            else:
                zout[0].next = tmp2[0]
            if tmp2[1] >= 2**r:
                zout[1].next = 2**r - 1
            else:
                zout[1].next = tmp2[1]
            if tmp2[2] >= 2**r:
                zout[2].next = 2**r - 1
            else:
                zout[2].next = tmp2[2]
            if tmp2[3] >= 2**r:
                zout[3].next = 2**r - 1
            else:
                zout[3].next = tmp2[3]
            yield llr0, llr1, llr2, llr3, zin[0], zin[1], zin[2], zin[3], a, b
    return extInfLogic
