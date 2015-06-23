#!/usr/bin/env python

from aistruct import AIStruct
import elf, sys
from optparse import OptionParser
from os import path

class AfterBurner(AIStruct):
	def __init__(self, *args, **kwargs):
		AIStruct.__init__(self, AIStruct.SIZE32)
		self.setup(
			('UINT32', 'addr')
		)

        def __str__(self):
            return "0x%x" % self.ai.addr.get()

def main():
    parser = OptionParser(add_help_option=False)
    parser.add_option("-h", "--file-header",
                      action="store_true", dest="header", default=False,
                      help="Display the ELF file header")
    parser.add_option("-l", "--program-headers",
                      action="store_true", dest="program_headers", default=False,
                      help="Display the program headers")
    parser.add_option("-S", "--section-headers",
                      action="store_true", dest="section_headers", default=False,
                      help="Display the section headers")
    parser.add_option("--afterburn",
                      action="store_true", dest="afterburn", default=False,
                      help="Display the afterburn relocations")
    parser.add_option("--first-free-page", 
		      action="store_true", dest="ffpage", default=False,
		      help="Prints out (in .lds format) the address of the first free physical" + \
		      	   "page after this image at load time. Using this information at link" + \
			   "time, images can be compiled and linked consecutively and loaded in" + \
		      	   "consecutive memory regions at load time.")
    parser.add_option("--lma-start-end", action="store_true", dest="lma_boundary", default=False,
		      help="Prints out the start and end LMA boundaries of an image." + \
		      	   "This is useful for autogenerating a structure for the microkernel" + \
			   "to discover at run-time where svc tasks are loaded.")
    (options, args) = parser.parse_args()
    if len(args) != 1:
        parser.print_help()
        return
    elffile = elf.ElfFile.from_file(args[0])

    if options.header:
        print elffile.header
    if options.program_headers:
        print elffile.pheaders
    if options.section_headers:
        print elffile.sheaders
    if options.afterburn:
        burnheader = elffile.sheaders[".afterburn"]
        burns = burnheader.container(AfterBurner)
        print "There are %d afterburn entry points" % len(burns)
        print "Afterburn:"
        for burn in burns:
            print " ", burn

if __name__ == "__main__":
    main()
