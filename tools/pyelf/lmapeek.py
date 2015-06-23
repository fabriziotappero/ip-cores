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


lds_header = \
'''
/*
 * The next free p_align'ed LMA base address
 *
 * Usually in ARM p_align == 16K
 *
 * p_align = %s
 */
'''


def main():
    usage = "usage: %prog [options] arg"
    parser = OptionParser(usage)

    parser.add_option("--first-free-page",
                      action = "store_true", dest = "ffpage",
                      default = False,
                      help = "Prints out the first free loadable page "
                             "available after the image in "
                             "linker script format")
    parser.add_option("--lma-start-end", action = "store_true",
                      dest = "lma_boundary", default = False,
	                  help = "Prints out the start and end LMA boundaries "
                             "of an image. Useful for aligining images in "
                             "physical memory.")

    (options, args) = parser.parse_args()

    if len(args) != 1:
        parser.print_help()

    elffile = elf.ElfFile.from_file(args[0])

    if options.lma_boundary:
        paddr_first = 0
        paddr_start = 0
        paddr_end = 0
        for pheader in elffile.pheaders:
            x = pheader.ai
            if str(x.p_type) != "LOAD":
                continue
            if paddr_first == 0:
                paddr_first = 1
                paddr_start = x.p_paddr.value
            if paddr_start > x.p_paddr.value:
                paddr_start = x.p_paddr.value
            if paddr_end < x.p_paddr + x.p_memsz:
                paddr_end = x.p_paddr + x.p_memsz

        rest, image_name = path.split(args[0])
        if image_name[-4] == ".":
            image_name = image_name[:-4]

        print image_name
        if hex(paddr_start)[-1] == "L":
            print "image_start " + hex(paddr_start)[:-1]
        else:
            print "image_start " + hex(paddr_start)
        if hex(paddr_end)[-1] == "L":
            print "image_end " + hex(paddr_end)[:-1]
        else:
            print "image_end " + hex(paddr_end)


if __name__ == "__main__":
    main()
