#!/bin/bash
# Author: Constantinos Xanthopoulos & Raul Fajardo
# This script install MinSOC tree
# under a specific directory.

# ===== CONFIGURATIONS =====
# ==========================

export SCRIPT_DIR="$( cd -P "$( dirname "$0" )" && pwd )"
export DIR_TO_INSTALL=`pwd`
# Debug ?
export DEBUG=0;
. ${SCRIPT_DIR}/beautify.sh

function testtool
{
    #    is_missing=`which $1 2>&1 | grep no`
    is_missing=`whereis -b $1 2>&1 | grep :$`
    if [ -z "$is_missing" ]
    then
        cecho "$1 is installed, pass"
    else
        errormsg "$1 is not installed, install it and re-run this installation script."
    fi
}


#Setting environment
ENV=`uname -o`
if [ "$ENV" != "GNU/Linux" ] && [ "$ENV" != "Cygwin" ]
then
    errormsg "Environment $ENV not supported by this script."
fi
cecho "Building tools for ${ENV} system"

is_arch64=`uname -m | grep 64`
if [ -z $is_arch64 ]
then
    KERNEL_ARCH="32"
else
    KERNEL_ARCH="64"
fi


# User check!
if [ `whoami` = "root" ];
then
    errormsg "You shouldn't be root for this script to run.";
fi;


# Testing necessary tools
cecho "Testing if necessary tools are installed, program "whereis" is required."
testtool sed
testtool patch

# Wizard
if [ -z "${ALTDIR}" ]
then
    cnecho "Give full path (ex. /home/foo/) of the directory where minsoc is under or leave empty for "${DIR_TO_INSTALL}": ";
    read ALTDIR;
    if [ ! -z "${ALTDIR}" ]
    then
        DIR_TO_INSTALL=${ALTDIR}
    fi
    cecho "${DIR_TO_INSTALL} selected";
fi

if [ ! -d ${DIR_TO_INSTALL} ]
then
    errormsg "Directory doesn't exist. Please create it";	
fi;

bash ${SCRIPT_DIR}/configure.sh
