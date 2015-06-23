#!/bin/bash
# Xanthopoulos Constantinos
# Installing OR GNU Toolchain.
# Only tested in Debian Squeeze.


# ===== CONFIGURATIONS =====
# ==========================

# Where will I put the binaries?
# ex. /opt/openrisc/bin
DIR_TO_INSTALL="";

# Debian's kernel architecture {32,64}
# ex. KERNEL_ARCH="32"
KERNEL_ARCH=""

# ===== SCRIPT ======
# ===================
export DEBUG=0;
. conxshlib.sh

if [ `whoami` == "root" ];
then
	errormsg "You shouldn't be root for this script to run.";
fi;

if [ ! -d $DIR_TO_INSTALL ]
then
	errormsg "Directory doesn't exist. Please create it";	
fi;

execcmd "Change permissions" "chmod 777 $DIR_TO_INSTALL";

cd $DIR_TO_INSTALL;

if [ $KERNEL_ARCH == "32" ];
then
	execcmd "Download toolchain (it may take a while)" "wget ftp://ocuser:oc@opencores.org/toolchain/or32-elf-linux-x86.tar.bz2";
elif [ $KERNEL_ARCH == "64"];
then
	execcmd "Download toolchain (it may take a while)" "wget ftp://ocuser:oc@opencores.org/toolchain/or32-elf-linux-x86_64.tar.bz2";
else
	errormsg "Not a correct architecture. Check Configurations";
fi

execcmd "Un-tar" "tar xf *bz2";

execcmd "Adding toolchain to PATH" "echo \"PATH=\\\$PATH:$DIR_TO_INSTALL/or32-elf/bin/\" >> /home/$(whoami)/.bashrc;";

cecho "Install completed"
