#!/usr/bin/python

import re, elf, sys, os
from optparse import OptionParser

# May need to do something about this
toolprefix = "arm-none-linux-gnueabi-"
objdump = toolprefix + "objdump"
objcopy = toolprefix + "objcopy"
readelf = toolprefix + "readelf"
egrep = "egrep"
snames_file = "section_names.txt"

def get_section_names(path):
	rest, filename = os.path.split(path)
	sections = []
	os.system(readelf + " -l " + path + " > readelf.out")
	os.system(egrep + r' "(\.){1}(\w){1}" ' + " readelf.out > sections.out")
	for line in file('sections.out'):
		secnum, secname = str.split(line)
		sections.append((secnum,secname))
	print "Sections:\n" + str(sections)
	return sections
	
helpmsg = \
'''Usage:
	lmamove.py <filename> <[<op>]offset>
	
	Where <filename> is the file to modify, <offset> is the offset to be added,
	subtracted or assigned, depending on the <op>, which can be either + or -
	
	!!! NOTE THIS TOOL IS NOT VERY USEFUL BECAUSE IT TURNS OUT THAT SOME SECTIONS
	ARE LIKELY TO BE PUT TOGETHER INTO THE SAME SEGMENT. For example (.text with .rodata)
	and (.data with .bss) Therefore moving one sectoin's LMA confuses what to do with the
	other section. The segment layout is almost always not same as initial after LMA
	modification with objcopy. !!!
'''

def check_args():
	if len(sys.argv) < 3:
		print helpmsg
		sys.exit()
	filename = sys.argv[1]
	if not os.path.exists(filename):
		print "Given path: " + filename + " does not exist.\n"
		sys.exit()

def move_sections(path, sections, op, offset):
	for secnum, secname in sections:
		os.system(objcopy + " --change-section-lma " + secname + op + offset + " " + path)

def lmamove():
	'''
	Moves an ARM ELF executable's LMA by moving each of its sections by 
	the given offset. It uses binutils (namely readelf and objcopy)	to do
	the actual work. Normally objcopy supports a similar operation;	moving
	of VMA of the whole program by --adjust-vma switch. But it only	supports
	modifying LMAs by section. Therefore this script extracts all loadable 
	section names and moves them one by one in order to move the whole program.
	'''
	check_args()
	filename = sys.argv[1]
	offset = sys.argv[2]

	if offset[0] in "+-":
		op = offset[0]
		offset = offset[1:]
	else:
		op = "+"

	if offset[:1] == "0x":
		offset = int(offset, 16)
	section_names = get_section_names(filename)
	move_sections(filename, section_names, op, offset)
	print("Done.\n")

if __name__ == "__main__":
	lmamove()
