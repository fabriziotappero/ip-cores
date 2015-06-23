#! /usr/bin/env python2.6
# -*- mode: python; coding: utf-8; -*-
#
#  Codezero -- Virtualization microkernel for embedded systems.
#
#  Copyright © 2009  B Labs Ltd
#
import os, sys
from optparse import OptionParser
from os.path import join
from os import path
import elf, sys

def conv_hex(val):
    hexval = hex(val)
    if hexval[-1:] == 'L':
        hexval = hexval[:-1]
    return hexval

def next_available_lma(srcfile):
    elffile = elf.ElfFile.from_file(srcfile)
    paddr_max = 0
    p_align = 0
    for pheader in elffile.pheaders:
        x = pheader.ai
        if str(x.p_type) == "LOAD":
            paddr = x.p_paddr + x.p_memsz
            p_align = x.p_align
            if paddr > paddr_max:
                paddr_max = paddr
    paddr_aligned = paddr_max & ~(p_align.value - 1)
    #print "paddr_max %s " % hex(paddr_max)
    #print "paddr_aligned %s " % hex(paddr_aligned)
    if paddr_max & (p_align.value - 1):
        paddr_aligned += p_align.value
    return conv_hex(paddr_aligned)

