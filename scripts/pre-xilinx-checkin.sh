#!/bin/sh
#
# pre-xilinx-checkin.sh
#
# Michael J. Lyons, 2012
#
# Deletes temporary files left over, even after xilinx tools do a 'clean'
#

VSPI_ROOT=..

RM="rm -f"


$RM $VSPI_ROOT/projnav/xps/pcores/spiifc_v1_00_a/devl/projnav/iseconfig/*.xreport

$RM $VSPI_ROOT/projnav/xps/pcores/spiifc_v1_00_a/devl/projnav/*.html
$RM $VSPI_ROOT/projnav/xps/pcores/spiifc_v1_00_a/devl/projnav/webtalk_impact.xml
$RM $VSPI_ROOT/projnav/xps/pcores/spiifc_v1_00_a/devl/projnav/*.xrpt
$RM $VSPI_ROOT/projnav/xps/pcores/spiifc_v1_00_a/devl/projnav/*.xreport

