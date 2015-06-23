#!/bin/bash 

#--------------------------------------------------------------#
#                                                              #
#  amber-printk.sh                                             #
#                                                              #
#  This file is part of the Amber project                      #
#  http://www.opencores.org/project,amber                      #
#                                                              #
#  Description                                                 #
#  Parse the Amber disassembly file, amber.dis, and extract    #
#  all the characters printed to the printk log file Useful    #
#  to follow the progress of a vmlinux simulation.             #
#                                                              #
#  Author(s):                                                  #
#      - Conor Santifort, csantifort.amber@gmail.com           #
#                                                              #
#//////////////////////////////////////////////////////////////#
#                                                              #
# Copyright (C) 2010 Authors and OPENCORES.ORG                 #
#                                                              #
# This source file may be used and distributed without         #
# restriction provided that this copyright statement is not    #
# removed from the file and that any derivative work contains  #
# the original copyright notice and the associated disclaimer. #
#                                                              #
# This source file is free software; you can redistribute it   #
# and/or modify it under the terms of the GNU Lesser General   #
# Public License as published by the Free Software Foundation; #
# either version 2.1 of the License, or (at your option) any   #
# later version.                                               #
#                                                              #
# This source is distributed in the hope that it will be       #
# useful, but WITHOUT ANY WARRANTY; without even the implied   #
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      #
# PURPOSE.  See the GNU Lesser General Public License for more #
# details.                                                     #
#                                                              #
# You should have received a copy of the GNU Lesser General    #
# Public License along with this source; if not, download it   #
# from http://www.opencores.org/lgpl.shtml                     #
#                                                              #
#--------------------------------------------------------------#

VMLINUXDIS=../../sw/vmlinux/vmlinux.dis
AMBERDIS=amber.dis


if [[ -e $VMLINUXDIS ]] ; then
  ADDR=`grep '<emit_log_char>:' $VMLINUXDIS | awk '{print $1}' | sed 's/^0*//'`
  grep "to $ADDR" $AMBERDIS | awk '{print $8}' | awk -F "" '{print $7 $8}' | ../../sw/tools/amber-mem-ascii
else
  echo "Error can't find the file $VMLINUXDIS"
fi
