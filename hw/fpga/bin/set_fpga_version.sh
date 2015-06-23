#/bin/sh -f
# Copy the run ID into an include file
# thats compiled into the FPGA boot loader software

FPGA_VERSION_FILE=../../../sw/boot-loader-serial/fpga-version.h
RUN_ID_FILE=$1

VERSION=`cat ${RUN_ID_FILE}`
echo '#define AMBER_FPGA_VERSION "'${VERSION}'"' > ${FPGA_VERSION_FILE}
