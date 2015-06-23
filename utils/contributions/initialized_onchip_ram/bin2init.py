"""
*****************************************************************************
                                                                            *
                    H E A D E R   I N F O R M A T I O N                     *
                                                                            *
*****************************************************************************
Project Name                   : SysPy (System Python) 
				 http://cgi.di.uoa.gr/~evlog/syspy.html

File Name                      : bin2init.py

Created by	               : Evangelos Logaras


*****************************************************************************
                                                                            *
                      C O P Y R I G H T   N O T I C E                       *
                                                                            *
*****************************************************************************

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; 
  version 2.1 of the License, a copy of which is available from
  http://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA


*****************************************************************************
                                                                            *
                           D E S C R I P T I O N                            *
                                                                            *
*****************************************************************************

 Generates block_ram.init file from binary images. Binary images are first converted in hex files
 using bin2hex.c file, provided with the ORPSoC v2 project. bin2hex executable must exist in the same folder with this script.

 Currently init file is generated for Xilinx's RAMB16_S9 BRAMs

 Usage: python bin2init.py <file.bin> (Python 2.6)
"""

import commands
import sys

       
# Python's variable declarations
#----------------------------------------------------------------------------------------------------------------------------------
y = '  '
mem_arr = []
block_ram_num = 4
block0 = []
block1 = []
block2 = []
block3 = []
block_ram = [block3, block2, block1, block0]
init_arr = []
mem_size2 = 8192
mem_count = 0
bram_count = -1
init_count = -1
hex_count = 0
zero_pad = ''
filename = ''
#----------------------------------------------------------------------------------------------------------------------------------

# Exceptions' class
#----------------------------------------------------------------------------------------------------------------------------------
class MyExceptions(Exception):
       def __init__(self, value):
              self.value = value
       def __str__(self):
              return repr(self.value)
#----------------------------------------------------------------------------------------------------------------------------------

# Raising exception if a *.bin file is not provided as an argument
#----------------------------------------------------------------------------------------------------------------------------------
filename = sys.argv[len(sys.argv) - 1]

if (filename.find(".bin") == -1):
       raise MyExceptions("*.bin file required")
#----------------------------------------------------------------------------------------------------------------------------------

i = filename.find(".bin")

filename = filename[:i]

# Deleting old *.hex and *.bin files
#----------------------------------------------------------------------------------------------------------------------------------
commands.getoutput("rm " + filename + ".hex")
commands.getoutput("rm " + filename + ".init")
#----------------------------------------------------------------------------------------------------------------------------------

## Calling bin2hex executable to convert *.bin file to *.hex
commands.getoutput("./bin2hex " + filename + ".bin 4 > "+ filename + ".hex")

# Opening the *.hex and the *.init file
#----------------------------------------------------------------------------------------------------------------------------------
hexFile = open(filename + ".hex", 'r')
initFile = open(filename + ".init", 'w')
#----------------------------------------------------------------------------------------------------------------------------------

# Reading the *.hex file and appending its contents to mem_arr[]
#----------------------------------------------------------------------------------------------------------------------------------
y = ' ' 
hex_count = 0
while(y):
       hex_count = hex_count + 1
       if (hex_count == 127):
              mem_arr.append("00000000")
           
       y = hexFile.readline()
       mem_arr.append(y)
#----------------------------------------------------------------------------------------------------------------------------------

# Reading mem_arr[] and creating the contents of BRAMs
#----------------------------------------------------------------------------------------------------------------------------------
for i in range(len(mem_arr)):
       bram_count = bram_count + 1
       if (bram_count < 32):
              block_ram[0].append(mem_arr[i][6:8])
              block_ram[1].append(mem_arr[i][4:6])
              block_ram[2].append(mem_arr[i][2:4])
              block_ram[3].append(mem_arr[i][0:2])
                            
       elif (bram_count >= 32):
              bram_count = 0
              
              init_count = init_count + 1

              if (init_count >= 64):
                     init_count = 0
                     mem_count = mem_count + 1
              
              hex_init_count = str(hex(init_count))
              hex_init_count = hex_init_count[2:]
              hex_init_count = hex_init_count.upper()
              if (init_count < 16):
                     hex_init_count = '0' + hex_init_count
              
              
              for j in range((block_ram_num - 1), -1, -1):
                     if (j == (block_ram_num - 1)):
                            init_arr.append(";\ndefparam MEM[" + str(mem_count) + "].block_ram_" + str(j) + ".INIT_" + hex_init_count + " = 256'h")
                            block_ram[j].reverse()
                            for k in range(len(block_ram[j])):
                                   init_arr.append(block_ram[j][k].replace("\n", ''))
                     else:
                            init_arr.append(";\ndefparam MEM[" + str(mem_count) + "].block_ram_" + str(j) + ".INIT_" + hex_init_count + " = 256'h")
                            block_ram[j].reverse()
                            for k in range(len(block_ram[j])):
                                   init_arr.append(block_ram[j][k].replace("\n", ''))

              block_ram[0] = []
              block_ram[1] = []
              block_ram[2] = []
              block_ram[3] = []
              
              block_ram[0].append(mem_arr[i][6:8])
              block_ram[1].append(mem_arr[i][4:6])
              block_ram[2].append(mem_arr[i][2:4])
              block_ram[3].append(mem_arr[i][0:2])

                         
if (bram_count != -1):
       init_count = init_count + 1
       hex_init_count = str(hex(init_count))
       hex_init_count = hex_init_count[2:]
       hex_init_count = hex_init_count.upper()
       if (init_count < 16):
              hex_init_count = '0' + hex_init_count
              
       if (init_count == 0):
              for j in range(64 - 2 * bram_count):
                     zero_pad = zero_pad + '0'
       else:
              for j in range(64 - 2 * bram_count):
                     zero_pad = zero_pad + '0'

       for j in range((block_ram_num - 1), -1, -1):
              init_arr.append(";\ndefparam MEM[" + str(mem_count) + "].block_ram_" + str(j) + ".INIT_" + hex_init_count + " = 256'h")
              block_ram[j].reverse()
              init_arr.append(zero_pad)
              for k in range(len(block_ram[j])):
                     init_arr.append(block_ram[j][k].replace("\n", ''))
              
init_arr.append(';')
#----------------------------------------------------------------------------------------------------------------------------------

# Writing BRAMs contetns to *.init file
#----------------------------------------------------------------------------------------------------------------------------------
i = init_arr[0].find(";/n")

init_arr[0] = init_arr[0][i + 2:]

for i in range(len(init_arr)):
       initFile.write(init_arr[i])
#----------------------------------------------------------------------------------------------------------------------------------
                            
# Closing the *.hex and the *.init file
#----------------------------------------------------------------------------------------------------------------------------------       
hexFile.close()
initFile.close()
#----------------------------------------------------------------------------------------------------------------------------------
