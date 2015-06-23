#!/usr/bin/env python
# Copyright (c) 2004 Guy Hutchison (ghutchis@opencores.org)
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

class mem_image:
    def __init__ (self):
        self.min = 100000
        self.max = -1
        self.map = {}
        self.bcount = 0

    def load_ihex (self, infile):
        ifh = open (infile, 'r')
    
        line = ifh.readline()
        while (line != ''):
            if (line[0] == ':'):
                rlen = int(line[1:3], 16)
                addr = int(line[3:7], 16)
                rtyp = int(line[7:9], 16)
                ptr = 9
                for i in range (0, rlen):
                    laddr = addr + i
                    val = int(line[9+i*2:9+i*2+2], 16)
                    self.map[laddr] = val
                    self.bcount += 1
                    if (laddr > self.max): self.max = laddr
                    if (laddr < self.min): self.min = laddr
    
            line = ifh.readline()
            
        ifh.close()

    def save_vmem (self, outfile, start=-1, stop=-1):
        if (start == -1): start = self.min
        if (stop == -1): stop = self.max

        ofh = open (outfile, 'w')
        for addr in range(start, stop+1):
            if self.map.has_key (addr):
                ofh.write ("@%02x %02x\n" % (addr-start, self.map[addr]))
        ofh.close()

