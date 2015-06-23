#!/usr/bin/tclsh
#------------------------------------------------------------------------------
# Copyright (C) 2001 Authors
#
# This source file may be used and distributed without restriction provided
# that this copyright statement is not removed from the file and that any
# derivative work contains the original copyright notice and the associated
# disclaimer.
#
# This source file is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.
#
# This source is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
# License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this source; if not, write to the Free Software Foundation,
# Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
#------------------------------------------------------------------------------
# 
# File Name:   prepare_implementation.tcl
#
# Description: This script will prepare the Synplify and Libero Designer
#              working directories and scripts.
#
#                1 - The synthesis can be first started from the "work_synplify"
#                   directory by executing the "synplify.tcl" script from Synplify.
#
#                2 - The Place & Route step can be then started from the
#                   "work_designer" directory by executing the "libero_designer.tcl"
#                   script from the Libero Designer program.
# 
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#
#------------------------------------------------------------------------------
# $Rev: 17 $
# $LastChangedBy: olivier.girard $
# $LastChangedDate: 2009-08-04 23:15:39 +0200 (Tue, 04 Aug 2009) $
#------------------------------------------------------------------------------

###############################################################################
#                         SET SOME GLOBAL VARIABLES                           #
###############################################################################

# Set the FPGA:  architecture,    model,   package_syn  package_libero, speed-grade
set fpgaConfig {  ProASIC3L     M1A3P1000L  FBGA484     "484 FBGA"        Std}

# RTL Top Level module
set designTop "openMSP430_fpga"

# RTL include files
set rtlIncludeFiles "../../../rtl/verilog/openmsp430/openMSP430_defines.v            \
                     ../../../rtl/verilog/openmsp430/openMSP430_undefines.v          \
                     ../../../rtl/verilog/openmsp430/periph/omsp_timerA_defines.v    \
                     ../../../rtl/verilog/openmsp430/periph/omsp_timerA_undefines.v"

###############################################################################
#                                 CLEANUP                                     #
###############################################################################

# Cleanup
file delete -force ./work_synplify
file delete -force ./work_designer
file mkdir ./work_synplify
file mkdir ./work_designer
cd ./work_synplify

# Copy RTL include files
foreach rtlFile $rtlIncludeFiles {
	file copy $rtlFile .
}
	
###############################################################################
#                         GENERATE SYNTHESIS SCRIPT                           #
###############################################################################

# Copy Synplify tcl command files
if [catch {open "../synplify.tcl" r} f_synplify_tcl] {
    puts "ERROR: Cannot open Synplify command file file ../synplify.tcl"
    exit 1
}

set synplify_tcl [read $f_synplify_tcl]
close $f_synplify_tcl

regsub -all {<DEVICE_FAMILY>}  $synplify_tcl "[string toupper [lindex $fpgaConfig 0]]" synplify_tcl
regsub -all {<DEVICE_NAME>}    $synplify_tcl "[string toupper [lindex $fpgaConfig 1]]" synplify_tcl
regsub -all {<DEVICE_PACKAGE>} $synplify_tcl "[string toupper [lindex $fpgaConfig 2]]" synplify_tcl
regsub -all {<SPEED_GRADE>}    $synplify_tcl "[string toupper [lindex $fpgaConfig 4]]" synplify_tcl
regsub -all {<TOP_LEVEL>}      $synplify_tcl $designTop                                synplify_tcl

set f_synplify_tcl [open "synplify.tcl" w]
puts $f_synplify_tcl $synplify_tcl
close $f_synplify_tcl

###############################################################################
#                      GENERATE PLACE & ROUTE SCRIPT                          #
###############################################################################

cd ../work_designer

# Copy Libero Designer tcl command files
if [catch {open "../libero_designer.tcl" r} f_libero_designer_tcl] {
    puts "ERROR: Cannot open Libero Designer command file file ../libero_designer.tcl"
    exit 1
}
set libero_designer_tcl [read $f_libero_designer_tcl]
close $f_libero_designer_tcl

regsub -all {<DEVICE_FAMILY>}  $libero_designer_tcl "[lindex $fpgaConfig 0]" libero_designer_tcl
regsub -all {<DEVICE_NAME>}    $libero_designer_tcl "[lindex $fpgaConfig 1]" libero_designer_tcl
regsub -all {<DEVICE_PACKAGE>} $libero_designer_tcl "[lindex $fpgaConfig 3]" libero_designer_tcl
regsub -all {<SPEED_GRADE>}    $libero_designer_tcl "[lindex $fpgaConfig 4]" libero_designer_tcl

set f_libero_designer_tcl [open "libero_designer.tcl" w]
puts $f_libero_designer_tcl $libero_designer_tcl
close $f_libero_designer_tcl


exit 0
