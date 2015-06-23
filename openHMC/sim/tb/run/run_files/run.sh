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

function print_help {
	printf "Usage: %s: [-c] [-d DUT] [-f FPW] [-g] [-l NUM_LANES] [o] [-q] [-p] [-s SEED] [-t TEST_NAME] [-v UVM_VERBOSITY] -?\n" $(basename $0) >&2
}

#-----------------------------------------------------------------
# set defaults
if [ ! $CAG_DUT ]
then
	CAG_DUT="default"
fi

#-- Controller params
num_lanes="default"
log_num_lanes="3"
fpw="default"
log_fpw="2"

do_clean_up=
tflag="0"
dflag="0"
test_name=
verbosity="UVM_LOW"
use_gui=
input_file="-input ${CAG_TB_DIR}/build/ncsim.tcl"
seed=""
num_axi_bytes="64"
enable_coverage=""


#-- parse options
while getopts 'cgot:v:d:s:l:f:q?' OPTION
do
	case $OPTION in
		c)	do_clean_up=1
			;;
		d)	export CAG_DUT=${OPTARG}
			dflag="1"
			;;
		f)  fpw="${OPTARG}"
			;;
		g)	use_gui="+gui"
			;;
		l)	num_lanes="${OPTARG}"
			;;
		s)  seed="+svseed+${OPTARG}"
			;;
		t)	tflag="1"
			test_name="$OPTARG"
			;;
		v)	verbosity="$OPTARG"
			;;
		o)	enable_coverage="-coverage all -covoverwrite"
			;;
		q)	input_file=""
			verbosity="UVM_NONE"
			;;
		?)	print_help
			exit 2
			;;
		esac
done
shift $(($OPTIND - 1))

printf "****************************************************\n"
printf "****************************************************\n"

#-- Set up controller
if [ $num_lanes == "default" ]
then
	printf "No link-width specified. Defaulting to 8 lanes \n"
else
	if [ $num_lanes != "8" -a $num_lanes != "16" ]
	then
		printf "Unsupported link-width specified. Defaulting to 8 lanes\n"
	else
		if [ $num_lanes == "16" ]
		then
			log_num_lanes="4"
			export X16
		fi
		printf "Link width set: $num_lanes lanes\n"
	fi
fi

if [ $fpw == "default" ]
then
	printf "No FPW specified. Defaulting to FPW=4 (512bit datapath)\n"
	fpw="4"
else
	if [ $fpw != "2" -a $fpw != "4" -a $fpw != "6" -a $fpw != "8" ]
	then
		printf "Unsupported FPW specified. Defaulting to FPW=4 (512bit datapath)\n"
		fpw="4"
	else
		printf "FPW set: $fpw\n"
		case $fpw in
			2)
			log_fpw="1"
			num_axi_bytes="32"
			;;
			4)
			log_fpw="2"
			;;
			6)
			log_fpw="3"
			num_axi_bytes="96"
			;;
			8)
			log_fpw="3"
			num_axi_bytes="128"
			;;
		esac
	fi
fi

#-- check test
if [ "$tflag" == "0" ]
then
	printf "Test defaulted to simple_test.\n"
	test_name="simple_test"
fi

#-- select DUT
if [ "$dflag" == "0" ]
then
	printf "DUT is default: ${CAG_DUT}\n"
else
	echo "DUT used: ${CAG_DUT}"
fi
CAG_TB_COMPILE_IUS="${CAG_TB_DIR}/build/compile_ius_${CAG_DUT}.f"

printf "****************************************************\n"
printf "****************************************************\n"

#-- do some clean up
if [ "$do_clean_up" ]
then
	echo "Removing old build files..."
	${CAG_TB_DIR}/../run/clean_up.sh
fi

#-- all other stuff
echo "Starting the verification environment..."
irun ${input_file} \
	-f ${CAG_TB_COMPILE_IUS} \
	${enable_coverage} \
	-access +rwc \
	${use_gui} "+UVM_TESTNAME=${test_name}" "+UVM_VERBOSITY=${verbosity}" ${seed} \
	"-define LOG_NUM_LANES=$log_num_lanes -define FPW=$fpw -define LOG_FPW=$log_fpw -define AXI4BYTES=$num_axi_bytes" $*
