#!/usr/bin/env python
#
# This script connotates fuse test files with Z80 opcode strings.
# Run it once to convert original fuse files to a new, connotated format.
#
#-------------------------------------------------------------------------------
#  Copyright (C) 2014  Goran Devic
#
#  This program is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the Free
#  Software Foundation; either version 2 of the License, or (at your option)
#  any later version.
#
#  This program is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
#  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
#  more details.
#-------------------------------------------------------------------------------
import string
import os
import sys

op = {}

# Read all available Z80 opcode strings that we have, hash them by the opcode
def load(opcodeFile):
    global op
    with open(opcodeFile) as fIn:
        for line in fIn:
            (opcode, mnemonic) = (line.split()[0], line[12:])
            # Special case with ddcb and fdcb where our two formats slightly differ
            if opcode=="DDCB" or opcode=="FDCB":
                (opcode, mnemonic) = (line.split()[0]+line.split()[2], line[12:])
            op[opcode] = mnemonic.rstrip()

load("opcodes-xx.txt")
load("opcodes-cb-xx.txt")
load("opcodes-dd-cb.txt")
load("opcodes-dd-xx.txt")
load("opcodes-ed-xx.txt")
load("opcodes-fd-cb.txt")
load("opcodes-fd-xx.txt")

if len(sys.argv)!=2:
    print "Usage: " + sys.argv[0] + " <fuse-test-file>"
    exit(0)
file = sys.argv[1]

with open(file) as f, open(file+".out", "wt") as f2:
    for line in f:
        line = line.rstrip()
        if line is None: break
        parts = line.split()
        note = ""
        if len(parts)==1 and parts[0]!="-1":
            index = parts[0].split("_")[0].upper()
            if index in op:
                note = " " + " "*(7-len(parts[0])) + op[index.upper()]
        f2.write(line + note + "\n")
        print line + note
