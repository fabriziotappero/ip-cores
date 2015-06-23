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

grep '@' $1 | awk '{print $2}' | awk -F '' '{print $1 $2}' |\
paste -d" "  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - | \
awk '{ if      (NR<=64)  { printf "    .SRAM0_INIT_" NR-1  " ( 256%ch", 39 }  \
       else if (NR<=128) { printf "    .SRAM4_INIT_" NR-65 " ( 256%ch", 39 }} \
     $32=="" {printf "00"} \
     $31=="" {printf "00"} \
     $30=="" {printf "00"} \
     $29=="" {printf "00"} \
     $28=="" {printf "00"} \
     $27=="" {printf "00"} \
     $26=="" {printf "00"} \
     $25=="" {printf "00"} \
     $24=="" {printf "00"} \
     $23=="" {printf "00"} \
     $22=="" {printf "00"} \
     $21=="" {printf "00"} \
     $20=="" {printf "00"} \
     $19=="" {printf "00"} \
     $18=="" {printf "00"} \
     $17=="" {printf "00"} \
     $16=="" {printf "00"} \
     $15=="" {printf "00"} \
     $14=="" {printf "00"} \
     $13=="" {printf "00"} \
     $12=="" {printf "00"} \
     $11=="" {printf "00"} \
     $10=="" {printf "00"} \
     $9==""  {printf "00"} \
     $8==""  {printf "00"} \
     $7==""  {printf "00"} \
     $6==""  {printf "00"} \
     $5==""  {printf "00"} \
     $4==""  {printf "00"} \
     $3==""  {printf "00"} \
     $2==""  {printf "00"} \
     {print $32 $31 $30 $29 $28 $27 $26 $25 $24 $23 $22 $21 $20 $19 $18 $17 $16 $15 $14 $13 $12 $11 $10 $9 $8 $7 $6 $5 $4 $3 $2 $1 " )," } '  \
     > $2


grep '@' $1 | awk '{print $2}' | awk -F '' '{print $3 $4}' |\
paste -d" "  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - | \
awk '{ if      (NR<=64)  { printf "    .SRAM1_INIT_" NR-1  " ( 256%ch", 39 }  \
       else if (NR<=128) { printf "    .SRAM5_INIT_" NR-65 " ( 256%ch", 39 }} \
     $32=="" {printf "00"} \
     $31=="" {printf "00"} \
     $30=="" {printf "00"} \
     $29=="" {printf "00"} \
     $28=="" {printf "00"} \
     $27=="" {printf "00"} \
     $26=="" {printf "00"} \
     $25=="" {printf "00"} \
     $24=="" {printf "00"} \
     $23=="" {printf "00"} \
     $22=="" {printf "00"} \
     $21=="" {printf "00"} \
     $20=="" {printf "00"} \
     $19=="" {printf "00"} \
     $18=="" {printf "00"} \
     $17=="" {printf "00"} \
     $16=="" {printf "00"} \
     $15=="" {printf "00"} \
     $14=="" {printf "00"} \
     $13=="" {printf "00"} \
     $12=="" {printf "00"} \
     $11=="" {printf "00"} \
     $10=="" {printf "00"} \
     $9==""  {printf "00"} \
     $8==""  {printf "00"} \
     $7==""  {printf "00"} \
     $6==""  {printf "00"} \
     $5==""  {printf "00"} \
     $4==""  {printf "00"} \
     $3==""  {printf "00"} \
     $2==""  {printf "00"} \
     {print $32 $31 $30 $29 $28 $27 $26 $25 $24 $23 $22 $21 $20 $19 $18 $17 $16 $15 $14 $13 $12 $11 $10 $9 $8 $7 $6 $5 $4 $3 $2 $1 " )," } '  \
     >> $2
     
     
grep '@' $1 | awk '{print $2}' | awk -F '' '{print $5 $6}' |\
paste -d" "  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - | \
awk '{ if      (NR<=64)  { printf "    .SRAM2_INIT_" NR-1  " ( 256%ch", 39 }  \
       else if (NR<=128) { printf "    .SRAM6_INIT_" NR-65 " ( 256%ch", 39 }} \
     $32=="" {printf "00"} \
     $31=="" {printf "00"} \
     $30=="" {printf "00"} \
     $29=="" {printf "00"} \
     $28=="" {printf "00"} \
     $27=="" {printf "00"} \
     $26=="" {printf "00"} \
     $25=="" {printf "00"} \
     $24=="" {printf "00"} \
     $23=="" {printf "00"} \
     $22=="" {printf "00"} \
     $21=="" {printf "00"} \
     $20=="" {printf "00"} \
     $19=="" {printf "00"} \
     $18=="" {printf "00"} \
     $17=="" {printf "00"} \
     $16=="" {printf "00"} \
     $15=="" {printf "00"} \
     $14=="" {printf "00"} \
     $13=="" {printf "00"} \
     $12=="" {printf "00"} \
     $11=="" {printf "00"} \
     $10=="" {printf "00"} \
     $9==""  {printf "00"} \
     $8==""  {printf "00"} \
     $7==""  {printf "00"} \
     $6==""  {printf "00"} \
     $5==""  {printf "00"} \
     $4==""  {printf "00"} \
     $3==""  {printf "00"} \
     $2==""  {printf "00"} \
     {print $32 $31 $30 $29 $28 $27 $26 $25 $24 $23 $22 $21 $20 $19 $18 $17 $16 $15 $14 $13 $12 $11 $10 $9 $8 $7 $6 $5 $4 $3 $2 $1 " )," } '  \
     >> $2

     
grep '@' $1 | awk '{print $2}' | awk -F '' '{print $7 $8}' |\
paste -d" "  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - | \
awk '{ if      (NR<=64)  { printf "    .SRAM3_INIT_" NR-1  " ( 256%ch", 39 }  \
       else if (NR<=128) { printf "    .SRAM7_INIT_" NR-65 " ( 256%ch", 39 }} \
     $32=="" {printf "00"} \
     $31=="" {printf "00"} \
     $30=="" {printf "00"} \
     $29=="" {printf "00"} \
     $28=="" {printf "00"} \
     $27=="" {printf "00"} \
     $26=="" {printf "00"} \
     $25=="" {printf "00"} \
     $24=="" {printf "00"} \
     $23=="" {printf "00"} \
     $22=="" {printf "00"} \
     $21=="" {printf "00"} \
     $20=="" {printf "00"} \
     $19=="" {printf "00"} \
     $18=="" {printf "00"} \
     $17=="" {printf "00"} \
     $16=="" {printf "00"} \
     $15=="" {printf "00"} \
     $14=="" {printf "00"} \
     $13=="" {printf "00"} \
     $12=="" {printf "00"} \
     $11=="" {printf "00"} \
     $10=="" {printf "00"} \
     $9==""  {printf "00"} \
     $8==""  {printf "00"} \
     $7==""  {printf "00"} \
     $6==""  {printf "00"} \
     $5==""  {printf "00"} \
     $4==""  {printf "00"} \
     $3==""  {printf "00"} \
     $2==""  {printf "00"} \
     {print $32 $31 $30 $29 $28 $27 $26 $25 $24 $23 $22 $21 $20 $19 $18 $17 $16 $15 $14 $13 $12 $11 $10 $9 $8 $7 $6 $5 $4 $3 $2 $1 " )," } '  \
     >> $2

echo "    .UNUSED       ( 1'd0 ) " >> $2
