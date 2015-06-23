#!/usr/bin/python
import os
import sys

from configure import *
config = configuration_retrieve()

objdump = "objdump"
command = "-t"
image_name = "inittask.axf"
linkoutput_file_suffix = "-linkinfo.txt"
linkoutput_file = image_name + linkoutput_file_suffix

def generate_bootdesc():
	command = config.toolchain_userspace + objdump + \
		  " -t " + image_name + " > " + linkoutput_file
	print command
	os.system(command)
	f = open(linkoutput_file, "r")

	while True:
		line = f.readline()
		if len(line) is 0:
			break
		if "_start" in line or "_end" in line:
			print line
	f.close()

if __name__ == "__main__":
	generate_bootdesc()

