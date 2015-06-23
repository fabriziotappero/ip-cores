#!/usr/bin/env python
#
# This script reads a binary file and writes it out in the ASCII format
# that lists each 8-bit word in a hex format without 0x.
#
# This format can be read by SystemVerilog function $readmemh()
#
# Usage:  python bindump.py <input-file> [<output-file>]
#
# If the output file is not given, "out.hex" will be created.
#
import sys

filename = sys.argv[1]
outfile = "out.hex"
col = 0;
if len(sys.argv) > 2:
    outfile  = sys.argv[2]
with open(filename, "rb") as f, open(outfile, "w") as o:
    block = f.read(65536)
    for ch in block:
        #print '{0:02X}'.format(ord(ch))
        o.write('{0:02X} '.format(ord(ch)))
        col = col + 1
        if col==16:
            o.write("\n")
            col = 0;
print "Created " + outfile
