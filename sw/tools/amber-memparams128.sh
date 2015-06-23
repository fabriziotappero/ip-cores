#!/bin/bash 

#--------------------------------------------------------------#
#                                                              #
#  amber-memparams128.sh                                       #
#                                                              #
#  This file is part of the Amber project                      #
#  http://www.opencores.org/project,amber                      #
#                                                              #
#  Description                                                 #
#  Create a memparams file. Used to seed the boot_mem SRAM     #
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

grep '@' $1 | awk '{print $2}'  |  awk 'NR%4==1' |\
paste -d" "  - - - - - - - - | \
awk '{ if      (NR<=64)  { printf "    .SRAM0_INIT_" NR-1  " ( 256%ch", 39 }  \
       else if (NR<=128) { printf "    .SRAM4_INIT_" NR-65 " ( 256%ch", 39 }} \
     $8==""  {printf "00000000"} \
     $7==""  {printf "00000000"} \
     $6==""  {printf "00000000"} \
     $5==""  {printf "00000000"} \
     $4==""  {printf "00000000"} \
     $3==""  {printf "00000000"} \
     $2==""  {printf "00000000"} \
     {print $8 $7 $6 $5 $4 $3 $2 $1 " )," } '  \
     > $2

grep '@' $1 | awk '{print $2}'  |  awk 'NR%4==2' |\
paste -d" "  - - - - - - - - | \
awk '{ if      (NR<=64)  { printf "    .SRAM1_INIT_" NR-1  " ( 256%ch", 39 }  \
       else if (NR<=128) { printf "    .SRAM5_INIT_" NR-65 " ( 256%ch", 39 }} \
     $8==""  {printf "00000000"} \
     $7==""  {printf "00000000"} \
     $6==""  {printf "00000000"} \
     $5==""  {printf "00000000"} \
     $4==""  {printf "00000000"} \
     $3==""  {printf "00000000"} \
     $2==""  {printf "00000000"} \
     {print $8 $7 $6 $5 $4 $3 $2 $1 " )," } '  \
     >> $2

grep '@' $1 | awk '{print $2}'  |  awk 'NR%4==3' |\
paste -d" "  - - - - - - - - | \
awk '{ if      (NR<=64)  { printf "    .SRAM2_INIT_" NR-1  " ( 256%ch", 39 }  \
       else if (NR<=128) { printf "    .SRAM6_INIT_" NR-65 " ( 256%ch", 39 }} \
     $8==""  {printf "00000000"} \
     $7==""  {printf "00000000"} \
     $6==""  {printf "00000000"} \
     $5==""  {printf "00000000"} \
     $4==""  {printf "00000000"} \
     $3==""  {printf "00000000"} \
     $2==""  {printf "00000000"} \
     {print $8 $7 $6 $5 $4 $3 $2 $1 " )," } '  \
     >> $2


grep '@' $1 | awk '{print $2}'  |  awk 'NR%4==0' |\
paste -d" "  - - - - - - - - | \
awk '{ if      (NR<=64)  { printf "    .SRAM3_INIT_" NR-1  " ( 256%ch", 39 }  \
       else if (NR<=128) { printf "    .SRAM7_INIT_" NR-65 " ( 256%ch", 39 }} \
     $8==""  {printf "00000000"} \
     $7==""  {printf "00000000"} \
     $6==""  {printf "00000000"} \
     $5==""  {printf "00000000"} \
     $4==""  {printf "00000000"} \
     $3==""  {printf "00000000"} \
     $2==""  {printf "00000000"} \
     {print $8 $7 $6 $5 $4 $3 $2 $1 " )," } '  \
     >> $2

echo "    .UNUSED       ( 1'd0 ) " >> $2
