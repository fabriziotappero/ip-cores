#
#                              .--------------. .----------------. .------------.
#                             | .------------. | .--------------. | .----------. |
#                             | | ____  ____ | | | ____    ____ | | |   ______ | |
#                             | ||_   ||   _|| | ||_   \  /   _|| | | .' ___  || |
#       ___  _ __   ___ _ __  | |  | |__| |  | | |  |   \/   |  | | |/ .'   \_|| |
#      / _ \| '_ \ / _ \ '_ \ | |  |  __  |  | | |  | |\  /| |  | | || |       | |
#       (_) | |_) |  __/ | | || | _| |  | |_ | | | _| |_\/_| |_ | | |\ `.___.'\| |
#      \___/| .__/ \___|_| |_|| ||____||____|| | ||_____||_____|| | | `._____.'| |
#           | |               | |            | | |              | | |          | |
#           |_|               | '------------' | '--------------' | '----------' |
#                              '--------------' '----------------' '------------'
#
#  openHMC - An Open Source Hybrid Memory Cube Controller
#  (C) Copyright 2014 Computer Architecture Group - University of Heidelberg
#  www.ziti.uni-heidelberg.de
#  B6, 26
#  68159 Mannheim
#  Germany
#
#  Contact: openhmc@ziti.uni-heidelberg.de
#  http://ra.ziti.uni-heidelberg.de/openhmc
#
#   This source file is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This source file is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Lesser General Public License for more details.
#
#   You should have received a copy of the GNU Lesser General Public License
#   along with this source file.  If not, see <http://www.gnu.org/licenses/>.
#
#

#!/bin/bash

if [ ! $OPENHMC_SIM ]
then
    echo "Please export OPENHMC_SIM first"
    exit 1
fi

if [ ! $OPENHMC_PATH ]
then
    echo "Please export OPENHMC_PATH first"
    exit 1
fi

export CAG_TB_DIR=${OPENHMC_SIM}/tb/bfm
export CAG_DUT="openhmc_behavioral_bfm"

#-----------------------------------------------------------------

echo ""
echo "*"
echo "*                              .--------------. .----------------. .------------. "
echo "*                             | .------------. | .--------------. | .----------. |"
echo "*                             | | ____  ____ | | | ____    ____ | | |   ______ | |"
echo "*                             | ||_   ||   _|| | ||_   \  /   _|| | | .' ___  || |"
echo "*       ___  _ __   ___ _ __  | |  | |__| |  | | |  |   \/   |  | | |/ .'   \_|| |"
echo "*      / _ \| '_ \ / _ \ '_ \ | |  |  __  |  | | |  | |\  /| |  | | || |       | |"
echo "*       (_) | |_) |  __/ | | || | _| |  | |_ | | | _| |_\/_| |_ | | |\ '.___.'\| |"
echo "*      \___/| .__/ \___|_| |_|| ||____||____|| | ||_____||_____|| | | '._____.'| |"
echo "*           | |               | |            | | |              | | |          | |"
echo "*           |_|               |  ------------  | '--------------' | '----------' |"
echo "*                              '--------------' '----------------' '------------' "
echo "*"
echo "*"
echo "*                 *******************************************************"
echo "*                 *                                                     *"
echo "*                 *      openHMC Verification Environment               *"
echo "*                 *                                                     *"
echo "*                 *                                                     *"
echo "*                 *                                                     *"
echo "*                 *******************************************************"
echo ""

${OPENHMC_SIM}/tb/run/run_files/run.sh $*

