#!/bin/bash
# Author: Constantinos Xanthopoulos & Raul Fajardo
# This script install MinSOC tree
# under a specific directory.

# ===== CONFIGURATIONS =====
# ==========================
MINSOC_SVN_URL=http://opencores.org/ocsvn/minsoc/minsoc/trunk
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


# Selecting automated or advanced intallation modes
# Wizard
if [ -z "${AUTO}" ]
then
	while [ "${AUTO}" != "R" ] &&  [ "${AUTO}" != "A" ]
	do
	    cecho "Select installation mode.";
		cnecho "	Enter R for Resumed or A for Advanced mode or H for Help: "
	    read AUTO;
		if [ ${AUTO} == "H" ]
		then
			cecho "Advanced mode:"
			cecho "		the script only downloads and installs the required tools. Dependency libraries and tools are checked during individual tool compilation. Furthermore, the install directory is not added to the system PATH. You have to do it yourself. Libusb, libftdi and Icarus Verilog are supposed to be installed by the user.\n"
			cecho "Resumed mode:"
			cecho "		the script checks if the dependency libraries and tools are installed before doing anything. It also adds the installation directory to the system PATH variable for bash shells on HOME/.bashrc. Libusb, libftdi and Icarus Verilog are automatically installed for you.\n"
		fi
	done
    if [ "${AUTO}" == "R" ]
    then
        cecho "Resumed mode selected";
	else
		cecho "Advanced mode selected";
    fi
fi


# Testing necessary tools
if [ "${AUTO}" == "R" ]
then
	cecho "Testing if necessary tools are installed, program "whereis" is required."
	testtool wget
	testtool svn
	testtool bzip2
	testtool tar
	testtool sed
	testtool patch
	testtool gcc
	testtool make
	testtool makeinfo
	testtool libncurses
	testtool flex
	testtool bison
	testtool libz
	if [ "$ENV" == "Cygwin" ]
	then
		testtool ioperm
		testtool libusb
	fi
fi

# Wizard
if [ -z "${ALTDIR}" ]
then
    cnecho "Give full path (ex. /home/foo/) for installation directory or leave empty for "${DIR_TO_INSTALL}": ";
    read ALTDIR;
    if [ ! -z "${ALTDIR}" ]
    then
        DIR_TO_INSTALL=${ALTDIR}
    fi
    cecho "${DIR_TO_INSTALL} selected";
fi

if [ ! -d ${DIR_TO_INSTALL} ]
then
     cecho "Directory ${DIR_TO_INSTALL} doesn't exist."
     execcmd "Creating directory ${DIR_TO_INSTALL}" "mkdir -p ${DIR_TO_INSTALL}"
     if [ $? -ne 0 ]
     then
          errormsg "Connot create ${DIR_TO_INSTALL}";
     fi
fi;


#Creating directory structure
cecho "\nCreating directory structure"
cd ${DIR_TO_INSTALL}
execcmd "Creating directory ./download for downloaded packages" "mkdir -p download"
execcmd "Creating directory ./tools for package binaries" "mkdir -p tools"

#FIXME we should create an archive file of all the dependencies use a single wget
#Downloading everything we need
cecho "\nDownloading packages"
cd ${DIR_TO_INSTALL}
cecho "Download MinSoC"
svn co -q ${MINSOC_SVN_URL} minsoc	#user need to input password, execcmd omits command output and should be this way
execcmd "cd ${DIR_TO_INSTALL}/download"
if [ "$ENV" == "Cygwin" ]
then
    execcmd "Downloading GNU Toolchain" "wget http://minsoc.com/dep/trunk/or32-elf-cygwin-1.7.tar.bz2";
else
    if [ $KERNEL_ARCH == "32" ];
    then
        execcmd "Downloading GNU Toolchain" "wget http://minsoc.com/dep/trunk/or32-elf-linux-x86.tar.bz2";
    elif [ $KERNEL_ARCH == "64" ];
    then
        execcmd "Downloading GNU Toolchain" "wget http://minsoc.com/dep/trunk/or32-elf-linux-x86_64.tar.bz2";
    fi
fi
execcmd "Downloading GDB" "wget http://minsoc.com/dep/trunk/gdb-6.8a.tar.bz2"
execcmd "wget http://minsoc.com/dep/trunk/or32-gdb-6.8-patch-2.4.bz2"
execcmd "wget http://minsoc.com/dep/trunk/gdb-6.8-bz436037-reg-no-longer-active.patch"
if [ "${AUTO}" == "R" ]
then
	if [ "$ENV" != "Cygwin" ]
	then
		execcmd "Downloading libusb-0.1 for Advanced Debug System" "wget http://minsoc.com/dep/trunk/libusb-0.1.12.tar.gz"
	fi
	execcmd "Downloading libftdi for Advanced Debug System" "wget http://minsoc.com/dep/trunk/libftdi-0.19.tar.gz"
	execcmd "Downloading Icarus Verilog" "wget http://minsoc.com/dep/trunk/verilog-0.9.4.tar.gz"
fi


#Uncompressing everything
cecho "\nUncompressing packages"
if [ "$ENV" == "Cygwin" ]
then
    execcmd "tar xf or32-elf-cygwin-1.7.tar.bz2";
else
    if [ $KERNEL_ARCH == "32" ];
    then
        execcmd "tar xf or32-elf-linux-x86.tar.bz2";
    elif [ $KERNEL_ARCH == "64" ];
    then
        execcmd "tar xf or32-elf-linux-x86_64.tar.bz2";
    fi
fi
execcmd "tar -jxf gdb-6.8a.tar.bz2"
execcmd "bzip2 -d or32-gdb-6.8-patch-2.4.bz2"
if [ "${AUTO}" == "R" ]
then
	if [ "$ENV" != "Cygwin" ]
	then
		execcmd "tar zxf libusb-0.1.12.tar.gz"
	fi
	execcmd "tar zxf libftdi-0.19.tar.gz"
	execcmd "tar zxf verilog-0.9.4.tar.gz"
fi


#Compiling and Installing all packages
cecho "\nCompiling and installing packages"
# Installing the GNU Toolchain
if [ "$ENV" == "Cygwin" ]
then
    execcmd "Installing GNU Toolchain" "tar xf or32-elf-cygwin-1.7.tar.bz2 -C $DIR_TO_INSTALL/tools";
else
    if [ $KERNEL_ARCH == "32" ];
    then
        execcmd "Installing GNU Toolchain" "tar xf or32-elf-linux-x86.tar.bz2 -C $DIR_TO_INSTALL/tools";
    elif [ $KERNEL_ARCH == "64" ];
    then
        execcmd "Installing GNU Toolchain" "tar xf or32-elf-linux-x86_64.tar.bz2 -C $DIR_TO_INSTALL/tools";
    fi
fi
PATH="$PATH:$DIR_TO_INSTALL/tools/or32-elf/bin"


#Installing GDB
execcmd "cd gdb-6.8"
execcmd "patch -p1 < ../or32-gdb-6.8-patch-2.4"
execcmd "patch -p1 < ../gdb-6.8-bz436037-reg-no-longer-active.patch"

execcmd "mkdir -p build"
execcmd "cd build"
execcmd "../configure --target=or32-elf --disable-werror --prefix=$DIR_TO_INSTALL/tools"
execcmd "Compiling GDB" "make"
make install 1>>${SCRIPT_DIR}/progress.log 2>>${SCRIPT_DIR}/error.log   #avoid Fedora failing due to missing Makeinfo
PATH="$PATH:${DIR_TO_INSTALL}/tools/bin"


#Installing Advanced JTAG Bridge support libraries
if [ "${AUTO}" == "R" ]
then
	if [ "$ENV" != "Cygwin" ]
	then
		execcmd "cd ${DIR_TO_INSTALL}/download/libusb-0.1.12"
		execcmd "./configure --prefix=${DIR_TO_INSTALL}/tools"
		execcmd "Installing libusb-0.1" "make"
		execcmd "make install"
	fi

	execcmd "cd ${DIR_TO_INSTALL}/download/libftdi-0.19"
	execcmd "PATH=\"$PATH:${DIR_TO_INSTALL}/tools/bin\" ./configure --prefix=${DIR_TO_INSTALL}/tools CPPFLAGS=-I${DIR_TO_INSTALL}/tools/include"
	execcmd "Compiling libftdi" "make"
	execcmd "make install"
fi


#Installing Advanced JTAG Bridge
execcmd "cd ${DIR_TO_INSTALL}/minsoc/rtl/verilog/adv_debug_sys/Software/adv_jtag_bridge"
execcmd "./autogen.sh"
execcmd "./configure --enable-jsp-server=yes --prefix=${DIR_TO_INSTALL}/tools CFLAGS=-I${DIR_TO_INSTALL}/tools/include LIBS=-L${DIR_TO_INSTALL}/tools/lib LDFLAGS=-Wl,-R${DIR_TO_INSTALL}/tools/lib"
execcmd "Compiling Advanced JTAG Bridge" "make"
execcmd "make install"


#Installing Icarus Verilog
if [ "${AUTO}" == "R" ]
then
	execcmd "cd ${DIR_TO_INSTALL}/download/verilog-0.9.4"
	execcmd "./configure --prefix=${DIR_TO_INSTALL}/tools"
	execcmd "Compiling Icarus Verilog" "make"
	execcmd "make install"
fi


#Configuring MinSoC, Advanced Debug System and patching OpenRISC
bash ${SCRIPT_DIR}/configure.sh


#Setting-up new variables
if [ "${AUTO}" == "R" ]
then
	cecho "\nSystem configurations"
	execcmd "Adding MinSoC tools to PATH" "echo \"PATH=\\\"\\\$PATH:$DIR_TO_INSTALL/tools/bin\\\"\" >> /home/$(whoami)/.bashrc;";
	execcmd "Adding OpenRISC toolchain to PATH" "echo \"PATH=\\\"\\\$PATH:$DIR_TO_INSTALL/tools/or32-elf/bin/\\\"\" >> /home/$(whoami)/.bashrc;";

	cecho "\nInstallation Complete!"
	cecho "Before using the system, load the new environment variables doing this: source /home/$(whoami)/.bashrc"
	cecho "You may remove the ${DIR_TO_INSTALL}/download directory if you wish."
else
	cecho "\nInstallation Complete!\n"
	cecho "Remember to add the two following directories in the following order to the PATH system variable."
	cecho "1) $DIR_TO_INSTALL/tools/bin "
	cecho "2) $DIR_TO_INSTALL/tools/or32-elf/bin "
	cecho "You may remove the ${DIR_TO_INSTALL}/download directory if you wish."
fi

