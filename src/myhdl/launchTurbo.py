######################################################################
####                                                              ####
####  launchTurbo.py                                              ####
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



from math import sqrt
from turboTop import turboTop
from args import getArgs
from myhdl import Simulation, traceSignals

args    = getArgs('-rate', '-iter', '-vcd', '-time', '-snr', '-help', '-sig', '-ext', '-trel1', '-trel2', '-dist', '-int', '-delay')
rate    = args['-rate']
vcd     = args['-vcd']
time    = args['-time']
snr     = args['-snr']
help    = args['-help']
sig     = args['-sig']
ext     = args['-ext']
trel1   = args['-trel1']
trel2   = args['-trel2']
dist    = args['-dist']
inter   = args['-int']
dela    = args['-delay']
iter    = args['-iter']
if help == 'on':
    print "python launchTurbo.py"
    print "    [-help]        : prints this message"
    print "    [-iter val]    : number of iterations for the turbo decoding (default: 5)"
    print "    [-snr val]     : specifies the signal-to-noise ratio in dB (default: 5.1 dB)"
    print "    [-vcd on/off]  : turns on/off the signal logging into a VCD file (default: off)"
    print "    [-time val]    : time to run the simulation (default: forever)"
    print "    [-sig val]     : number of bits for the quantization of the signals - a, b, y1, y2 (default: 4)"
    print "    [-ext val]     : number of bits for the coding of the extrinsic information (default: 5)"
    print "    [-trel1 val]   : first trellis' length (default: 24)"
    print "    [-trel2 val]   : second trellis' length (default: 12)"
    print "    [-dist val]    : number of bits for the coding of the accumulated distances (default: 9)"
    print "    [-int val]     : interleaver frame size in bit couples - valid values are 48, 64, 212, 220, 228, 424, 432, 440, 848, 856, 864, 752 (default: 64)"
    print "    [-delay val]   : additional delay through the noiser - 0 means the noiser adds 1 clock cycle (default: 0)"
    print "    [-rate val]    : code rate (e.g. 13 for rate 1/3) - valid values are 13, 25, 12, 23, 34, 45, 67 (default is 12)"
else:
    if rate != None:
        rate = int(rate)    # code rate (e.g. 13 for rate 1/3)
    else:
        rate = 12
    if iter != None:
        it = int(iter)
    else:
        it = 5  # number of iterations for the turbo decoding
    if sig != None:
        n = int(sig)
    else:
        n = 4   # number of bits for the quantization of the signals - a, b, y1, y2
    if ext != None:
        r = int(ext)
    else:
        r = 5   # number of bits for the coding of the extrinsic information
    if trel1 != None:
        l = int(trel1)
    else:
        l = 24  # first trellis' length
    if trel2 != None:
        m = int(trel2)
    else:
        m = 12  # second trellis' length
    if dist != None:
        q = int(dist)
    else:
        q = 9   # number of bits for the coding of the accumulated distances
    if inter != None:
        p = int(inter)
    else:
        p = 64  # interleaver frame size in bit couples
    if dela != None:
        d = int(dela) + 1
    else:
        d = 1   # additional delay through the noiser - 0 means the noiser adds 2 clock cycles
    if snr == None:
        snr = 5.1   # signal-to-noise ratio in dB
    sigma = sqrt(((2 ** (n - 1) - 1) ** 2)/(10 ** (float(snr) / 10)))   # standard deviation of the noise distribution
    if time != None:
        time = int(time)    # time to run the simulation
    else:
        time = None
    mu = 2**(n - 1) # mean value of the noise distribution (additive noise)
    print "Parameters of the simulation:"
    print "-----------------------------"
    print
    print it, "iterations for the turbo decoding"
    print n, "bits for the quantization of the signals - a, b, y1, y2"
    print r, "bits for the coding of the extrinsic information"
    print "The length of the first trellis is", l
    print "The length of the second trellis is", m
    print q, "bits for the coding of the accumulated distances"
    print "The interleaver has a frame size of", p, "bit couples"
    print "There is an additional delay through the noiser of", (d - 1), "clock cycle(s) - 0 means the noiser adds 2 clock cycles"
    print "The signal-to-noise ratio is", snr, "dB"
    print "The code rate is", str(rate)[0], "/", str(rate)[1]
    print
    print
    print
    resFile = [None for i in range(it + 1)]
    for i in range(it + 1):
        resFile[i] = open('./turbo' + str(i) + '.txt', 'w')
    if vcd == 'on':
        turbo = traceSignals(turboTop, resFile, rate, it, n, r, p, d, mu, sigma, l, m, q)
    else:
        turbo = turboTop(resFile, rate, it, n, r, p, d, mu, sigma, l, m, q)
    sim = Simulation(turbo)
    sim.run(time)
    for i in range(it + 1):
        resFile[i].close
