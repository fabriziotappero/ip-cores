#!/usr/bin/env python
#------------------------------------------------------------------------------#
# BDF character set to VHDL converter                                          #
#------------------------------------------------------------------------------#
# Copyright (C) 2011 Mathias Hoertnagl, <mathias.hoertnagl@student.uibk.ac.at> #
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
import string

if len(sys.argv) == 2:

   inp = open(sys.argv[1], 'r')
   outp = open('./rtl/rom.vhd', 'w')

   i = 0
   b = 0

   outp.write('library ieee;\n')
   outp.write('use ieee.std_logic_1164.all;\n')
   outp.write('use ieee.numeric_std.all;\n\n')

   outp.write('entity rom is\n')
   outp.write('   port(\n')
   outp.write('      clk      : in  std_logic;\n')
   outp.write('      rom_addr : in  std_logic_vector(11 downto 0);\n')
   outp.write('      rom_word : out std_logic_vector(7 downto 0)\n')
   outp.write('   );\n')
   outp.write('end rom;\n\n')

   outp.write('architecture rtl of rom is\n')
   outp.write('begin\n')
   outp.write('   chrs : process(clk)\n')
   outp.write('   begin\n')
   outp.write('      if rising_edge(clk) then\n')
   outp.write('         case to_integer(unsigned(rom_addr)) is\n')

   for l in inp:
      l2 = string.strip(l)
      if l2 == 'ENDCHAR':
         b = 0
      if b == 1:
         if l2 != '00':
            # Transform hex-string into 8bit zero padded bin-string without
            # preceeding 'b0'.
            s = bin(int(l2, 16))[2:].zfill(8)
            # Reverse binary number. [not x(2 downto 0)]
            s = s[::-1]
            # Rotate binary number 2 digits to the right. [x(2 downto 0) - 2]
            s = s[2:] + s[:2]
            outp.write( '            ' )
            outp.write( 'when %4d => rom_word <= "%8s";\n' % (i, s) )
         i = i+1
      if l2 == 'BITMAP':
         b = 1

   outp.write('            when others => rom_word <= X"00";\n')
   outp.write('         end case;\n')
   outp.write('      end if;\n')
   outp.write('   end process;\n')
   outp.write('end rtl;')

   outp.close()
   inp.close()

else:
   print "Usage: python", sys.argv[0], "<*.bdf file>"