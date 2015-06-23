######################################################################
####                                                              ####
####  noiser.py                                                   ####
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



from random import gauss
from myhdl import Signal, posedge, negedge, always

def noiser(clk, rst, a, b, y1, y2, y1Int, y2Int, aNoisy, bNoisy, y1Noisy, y2Noisy, y1IntNoisy, y2IntNoisy, n = 4 , mu = 2**(4 - 1), sigma = 2**(4 - 2) + 2**(4 - 3)):
    """ Signal noiser (Gauss distribution).

    n           -- number of bits for the coding of the noisy signals (= for the sampling of the received data)
    mu          -- mean value for the distribution
    sigma       -- standard deviation for the distribution (0 means no noise)
    clk, rst    -- in  : clock and negative reset
    a, b, y1, y2, y1Int, y2Int  -- in  : original coder signals, coded with 1 bit
    aNoisy, bNoisy, y1Noisy, y2Noisy, y1IntNoisy, y2IntNoisy    -- out : noisy signals, coded with n bits and delayed by 1 clock cycle

    """
    #mu = 2**(n - 1) #8
    #sigma = 2**(n - 2) + 2**(n - 3) #6
#    cnt = Signal(int(0))
    @always(clk.posedge, rst.negedge)
    def noiserLogic():
        if rst.val == 0:
            aNoisy.next  = 0
            bNoisy.next  = 0
            y1Noisy.next = 0
            y2Noisy.next = 0
#            cnt.next = 0
        else:
#            if cnt.val < 10:
#                cnt.next = cnt.next + 1
#                aNoisy.next = ((a.val * 2) - 1) * 7
#                bNoisy.next = ((b.val * 2) - 1) * 7
#                y1Noisy.next = ((y1.val * 2) - 1) * 7
#                y2Noisy.next = ((y2.val * 2) - 1) * 7
#                y1IntNoisy.next = ((y1Int.val * 2) - 1) * 7
#                y2IntNoisy.next = ((y2Int.val * 2) - 1) * 7
#            else:
#                cnt.next = 0
#                aNoisy.next = 7
#                bNoisy.next = 7
#                y1Noisy.next = 7
#                y2Noisy.next = 7
#                y1IntNoisy.next = 7
#                y2IntNoisy.next = 7
            if a.val == 0:
                aNoisy.next  = int(round(gauss(-mu + 1, sigma)))
            else:
                aNoisy.next  = int(round(gauss(mu - 1, sigma)))
            if b.val == 0:
                bNoisy.next  = int(round(gauss(-mu + 1, sigma)))
            else:
                bNoisy.next  = int(round(gauss(mu - 1, sigma)))
            if y1.val == 0:
                y1Noisy.next = int(round(gauss(-mu + 1, sigma)))
            else:
                y1Noisy.next = int(round(gauss(mu - 1, sigma)))
            if y2.val == 0:
                y2Noisy.next = int(round(gauss(-mu + 1, sigma)))
            else:
                y2Noisy.next = int(round(gauss(mu - 1, sigma)))
            if y1Int.val == 0:
                y1IntNoisy.next = int(round(gauss(-mu + 1, sigma)))
            else:
                y1IntNoisy.next = int(round(gauss(mu - 1, sigma)))
            if y2Int.val == 0:
                y2IntNoisy.next = int(round(gauss(-mu + 1, sigma)))
            else:
                y2IntNoisy.next = int(round(gauss(mu - 1, sigma)))
    return noiserLogic
