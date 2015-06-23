#!/bin/bash 

#--------------------------------------------------------------#
#                                                              #
#  amber-jumps.sh                                              #
#                                                              #
#  This file is part of the Amber project                      #
#  http://www.opencores.org/project,amber                      #
#                                                              #
#  Description                                                 #
#  Parse the Amber disassembly file, amber.dis, and extract    #
#  all the function jumps, using the test disassembly file     #
#  to get the function names and addresses.                    #
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

show_usage() {
    echo " Usage:"
    echo "$0 <test-name>"
    exit
}


MINARGS=1

case $1 in
	""|"-h"|"--help") show_usage ;;
esac

if [[ $# -lt $MINARGS ]] ; then
 echo "Too few arguments given (Minimum:$MINARGS)"
 echo
 show_usage
fi


#--------------------------------------------------------
# Find the test
#--------------------------------------------------------
TEST_NAME=$1

# First check if its an assembly test
if [ -f ../tests/${TEST_NAME}.S ]; then
    TEST_DIS=../tests/${TEST_NAME}.dis 
elif [ -d ../../sw/${TEST_NAME} ]; then
    TEST_DIS=../../sw/${TEST_NAME}/${TEST_NAME}.dis 
else    
    echo "Test ${TEST_NAME} not found"
    exit
fi


grep jump amber.dis | awk '{print $1, $4, $6, $8, $10}' | sed 's/,//g' > /tmp/jumps

grep '>:' $TEST_DIS  | sed 's/<//' | sed 's/>://' > /tmp/funcsx

sort /tmp/funcsx > /tmp/funcs

# Remove some very common linux function jumps
../../sw/tools/amber-func-jumps /tmp/jumps /tmp/funcs \
  | grep -v "cpu_idle -" \
  | grep -v "cpu_idle <" \
  | grep -v "default_idle -" \
  | grep -v "default_idle <"

