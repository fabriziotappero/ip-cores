#!/bin/sh -f

#--------------------------------------------------------------#
#                                                              #
#  set_timeout.sh                                              #
#                                                              #
#  This file is part of the Amber project                      #
#  http://www.opencores.org/project,amber                      #
#                                                              #
#  Description                                                 #
#  Set a timeout value for a test in the file                  #
#    ../tests/timeouts.txt                                     #
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

TOFILE=../tests/timeouts.txt
TEST=$1
TICKS=$2

# is test already in list ?
if [ -e $TOFILE ]; then
    egrep "^${TEST} " $TOFILE > /dev/null
    TEST_LISTED=$?

    # If the test is already in the list
    if [ $TEST_LISTED == 0 ]; then
        egrep -v "^${TEST} " $TOFILE > ${TOFILE}1
        mv ${TOFILE}1 $TOFILE
    fi
else
    echo "Creating $TOFILE"
fi
echo "${TEST} ${TICKS}" >> ${TOFILE}

