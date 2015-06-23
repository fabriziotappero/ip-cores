#!/bin/bash
# Author: Constantinos Xanthopoulos
# This script install MinSOC tree
# under a specific directory.

# ===== CONFIGURATIONS =====
# ==========================

# Where should I put the dir. minsoc?
# ex. /home/conx/Thesis/
DIR_TO_INSTALL=""

# This variable should be set to trunk
# or to stable.
VERSION=""

# This variable should take one of
# the following values depending
# to your system: linux, cygwin, freebsd
ENV=""

# !!! DO NOT EDIT BELLOW THIS LINE !!!
# ===================================

# ===== SCRIPT ======
# ===================

# Debug ?
export DEBUG=0;
. beautify.sh

# User check!
if [ `whoami` = "root" ];
then
	errormsg "You shouldn't be root for this script to run.";
fi;

# Wizard
if [ -z ${DIR_TO_INSTALL} ]
then
	cnecho "Give full path (ex. /home/foo/): ";
	read DIR_TO_INSTALL;
fi

# Directory exists?
if [ ! -d ${DIR_TO_INSTALL} ]
then
	errormsg "Directory doesn't exist. Please create it";	
fi;

cd ${DIR_TO_INSTALL}

# Which Version?
if [ -z ${VERSION} ]
then
	while [ "$VERSION" != "trunk" -a   "$VERSION" != "stable" ]
	do
		cnecho "Select MinSOC Version [stable/trunk]: "
		read VERSION;
	done
fi

if [ -z ${ENV} ]
then
	while [ "$ENV" != "linux" -a "$ENV" != "cygwin" -a "$ENV" != "freebsd" ]
	do
		cnecho "Select build environment [linux/cygwin/freebsd]: "
		read ENV;
	done
fi



# Checkout MinSOC
if [ "${VERSION}" = "trunk" ]
then
	execcmd "Download minsoc" "svn co -q http://opencores.org/ocsvn/minsoc/minsoc/trunk/ minsoc"
else
	execcmd "Download minsoc" "svn co -q http://opencores.org/ocsvn/minsoc/minsoc/tags/release-0.9/ minsoc"
fi

cd minsoc/rtl/verilog

execcmd "Checkout adv_jtag_bridge" "svn co -q http://opencores.org/ocsvn/adv_debug_sys/adv_debug_sys/trunk adv_debug_sys"
execcmd "Checkout ethmac" "svn co -q http://opencores.org/ocsvn/ethmac/ethmac/trunk ethmac"
execcmd "Checkout openrisc" "svn co -q  http://opencores.org/ocsvn/openrisc/openrisc/trunk/or1200 or1200"
execcmd "Checkout uart" "svn co -q http://opencores.org/ocsvn/uart16550/uart16550/trunk uart16550"

cecho "I will now start to compile everything that's needed";

cd ${DIR_TO_INSTALL}/minsoc/sw/utils

echo $PWD

execcmd "Make utils" "make"

cd ../support

execcmd "Make support tools" "make"

cd ../drivers

execcmd "Make drivers" "make"


cd ../uart

execcmd "Make UART" "make"

# adv_jtag_bridge install
cd ${DIR_TO_INSTALL}/minsoc/rtl/verilog/adv_debug_sys/Software/adv_jtag_bridge

# FIXME: install FTDI headers for all build environments
#cecho "Installing FTDI headers! You will be asked to give root pass"

#execcmd "Install FTDI headers" "su -c \"aptitude install libftdi-dev\"";

if [ `grep "INCLUDE_JSP_SERVER=true" Makefile` != "" ]
then
	cecho "Switching off the adv_jtag_bridge JSP_SERVER option";
	sed 's/INCLUDE_JSP_SERVER=true/INCLUDE_JSP_SERVER=false/' Makefile > TMPFILE && mv TMPFILE Makefile
fi

if [ "${ENV}" != "cygwin" ] 
then
	cecho "Setting the right build environment";
	sed "s/BUILD_ENVIRONMENT=cygwin/BUILD_ENVIRONMENT=${ENV}/" Makefile > TMPFILE && mv TMPFILE Makefile
fi

execcmd "Make adv_jtag_bridge" "make"

cecho "Installation Finised"
