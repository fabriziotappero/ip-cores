######################################################################
####                                                              ####
####  README.txt                                                  ####
####                                                              ####
####  This file is part of the turbo decoder IP core project      ####
####  http://www.opencores.org/projects/turbocodes/               ####
####                                                              ####
####  Author(s):                                                  ####
####      - David Brochart(dbrochart@opencores.org)               ####
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



Turbo Decoder Release 0.3
=========================

MAIN FEATURES
-------------

* Double binary, DVB-RCS code
* Soft Output Viterbi Algorithm
* MyHDL cycle/bit accurate model
* Synthesizable VHDL model

MyHDL MODEL
-----------
For help                : python launchTurbo.py -help
For default execution   : python launchTurbo.py
It writes the Bit Error Rate for each iteration into a file:
    turbo0.txt <- BER before decoding
    turbo1.txt <- BER for iteration #1
    turbo2.txt <- BER for iteration #2
    turbo3.txt <- BER for iteration #3

VHDL MODEL
----------
The top-level entity is "turboDec".
All the turbo decoder parameters are stored in the "turbopack.vhd" file.
You can modify:
    - the code rate (RATE)
    - the number of decoding iterations (IT)
    - the interleaver frame size (FRSIZE)
    - the trellis' length (TREL1_LEN and TREL2_LEN)
    - the received decoder signal width (SIG_WIDTH)
    - the extrinsic information signal width (Z_WIDTH)
    - the accumulated distance signal width (ACC_DIST_WIDTH)

AUTHOR
------
David Brochart <dbrochart@opencores.org>
