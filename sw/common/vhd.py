#!/usr/bin/env python
#------------------------------------------------------------------------------#
# BIN to VHD converter                                                         #
#------------------------------------------------------------------------------#
# Copyright (C) 2011 Mathias Hoertnagl, mathias.hoertnagl@gmail.com            #
#                                                                              #
# This program is free software; you can redistribute it and/or modify it      #
# under the terms of the GNU General Public License as published by the Free   #
# Software Foundation; either version 3 of the License, or (at your option)    #
# any later version.                                                           #
# This program is distributed in the hope that it will be useful, but WITHOUT  #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or        #
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for     #
# more details.                                                                #
# You should have received a copy of the GNU General Public License along with #
# this program; if not, see <http://www.gnu.org/licenses/>.                    #
#------------------------------------------------------------------------------#
import sys

header = "\
library ieee;\n\
use ieee.std_logic_1164.all;\n\
use ieee.numeric_std.all;\n\
\n\
library work;\n\
use work.imem.all;\n\
\n\
package data is\n\
\n\
   constant data : mem_block_t := (\n"


if len(sys.argv) != 3:
   print "Usage: python", sys.argv[0], "<*.bin file>", "<destination folder>"
   sys.exit()

outp = {}
data = {}

data[0] = "      0 => (\n         "
data[1] = "      1 => (\n         "
data[2] = "      2 => (\n         "
data[3] = "      3 => (\n         "

print ""
print "************************************************************************"
print "* Memory File Generation                                               *"
print "************************************************************************"

print "Loading:", sys.argv[1]

inp = open(sys.argv[1], 'rb')
bin = inp.read()
inp.close()

# Outout name is fixed to make it automatically loadable.
outp = open(sys.argv[2] + 'data.vhd', 'w')
outp.write(header)

print "Writing memory file ..."

i = 3
j = 39
for c in bin:
   data[i] = data[i] + ('x"%02X", ' % ord(c))

   if j == 0:
      j = 39
      for k in range(4):
         data[k] = data[k] + "\n         "
   else:
      j = j - 1

   if i == 0:
      i = 3
   else:
      i = i-1

for i in range(3):
   data[i] = data[i] + 'others => x"00"\n      ),\n'

data[3] = data[3] + 'others => x"00"\n      )\n   );\n\nend data;'

for i in range(4):
   outp.write(data[i])

outp.close()

print "Done!"