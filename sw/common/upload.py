#!/usr/bin/env python
#------------------------------------------------------------------------------#
# Serial Upload Tool                                                           #
#------------------------------------------------------------------------------#
# Uses pySerial visit [1] for the module.                                      #
#                                                                              #
# REFERENCES                                                                   #
#  [1] pySerial, http://pyserial.sourceforge.net/                              #
#  [2] Fabio Varesano, http://www.varesano.net/blog/fabio/                     #
#      serial%20rs232%20connections%20python                                   #
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
import sys, struct, time
import serial

if len(sys.argv) != 2:
   print "Usage: python", sys.argv[0], "<*.bin file>"
   sys.exit()

# Set up serial port object.
s = serial.Serial(
   port = 4, # 'COM5',
   baudrate = 19200
)

# Load binary file.
inp = open(sys.argv[1], 'rb')
bin = inp.read()
inp.close()

print ""
print "************************************************************************"
print "* Upload                                                               *"
print "************************************************************************"

size = len(bin)
print "File size of '{0}' is: {1} bytes.".format(sys.argv[1], size)

if s.isOpen():
   s.write(struct.pack('>I', size))

   # void echoes the image size, after it has erased the flash.
   # Check if it is the correct size.
   esize = struct.unpack('>I', s.read(4))[0]

   if esize != size:
      print "ERROR: Size echo is {0}. Expected: {1}.".format(esize, size)
      sys.exit()

   print "Flash ready. Size echo correct."

   print "Sending data ..."

   # NOTE: Writing the entire file with s.write(bin) does not work. Possibly
   #       due to limited buffer size.
   for c in bin:
      s.write(c)

   s.close()

   print "Done!"