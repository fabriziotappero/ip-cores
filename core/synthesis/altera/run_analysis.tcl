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
# File Name: run_analysis.tcl
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

# Analysis type
set analysisType SPEED
#set analysisType AREA

# Set the different FPGA architectures & models to be checked
set fpgaConfigs {{"Cyclone II"     EP2C20F484C    {6 7 8}}
                 {"Cyclone III"    EP3C55F484C    {6 7 8}}
                 {"Cyclone IV GX"  EP4CGX22CF19C  {6 7 8}}
                 {"Arria GX"       EP1AGX50CF484C {6}}
                 {"Arria II GX"    EP2AGX45DF29C  {4 5 6}}
                 {"Stratix"        EP1S10F484C    {5 6 7}}
                 {"Stratix II"     EP2S15F484C    {3 4 5}}
                 {"Stratix III"    EP3SE50F484C   {2 3 4}}}
                 
# Set the different RTL configurations to be analysed
set rtlDefines  {PMEM_AWIDTH DMEM_AWIDTH  DBG_EN  DBG_HWBRK_0 DBG_HWBRK_1 DBG_HWBRK_2 DBG_HWBRK_3 MULTIPLIER}
set rtlConfigs {{    12          10          0         0            0          0            0         0}
                {    12          10          1         0            0          0            0         0}
                {    12          10          1         1            0          0            0         0}
                {    12          10          1         1            1          0            0         0}
                {    12          10          1         1            1          1            0         0}
                {    12          10          1         1            1          1            1         0}}
set rtlConfigs {{    12          10          0         0            0          0            0         1}}


# RTL configuration files
set omspConfigFile "../../rtl/verilog/openMSP430_defines.v"
set rtlConfigFile  "./src/arch.v"


###############################################################################
#                              PERFORM ANALYSIS                               #
###############################################################################


foreach rtlConfig $rtlConfigs {

    #-------------------------------------------------------------------------#
    #                        Generate RTL configuration                       #
    #-------------------------------------------------------------------------#

    # Read original define file
    if [catch {open $omspConfigFile r} f_omspConfigFile] {
	puts "ERROR: Cannot open file $omspConfigFile"
	exit 1
    }
    set configFile [read $f_omspConfigFile]
    close $f_omspConfigFile


    # Update defines
    set idx 0
    foreach rtlDefine $rtlDefines {

	if {[regsub "`define\\s+$rtlDefine\\s+\\d+" $configFile "`define $rtlDefine [lindex $rtlConfig $idx]" configFile]} {
	} else {
	    if {[lindex $rtlConfig $idx]==0} {
		regsub "\\n`define\\s+$rtlDefine" $configFile "\n//`define $rtlDefine" configFile
	    }
	}
	set idx [expr $idx+1]
    }


    # Write the new file
    set f_configFile [open "./src/[file tail $omspConfigFile]" w]
    puts $f_configFile $configFile
    close $f_configFile


    #-------------------------------------------------------------------------#
    #                      Perform analysis for each FPGA                     #
    #-------------------------------------------------------------------------#
    foreach fpgaConfig $fpgaConfigs {
	foreach speedGrade [lindex $fpgaConfig 2] {

	    # Create verilog arch define
	    set f_configFile [open $rtlConfigFile w]
	    regsub -all {\s} [lindex $fpgaConfig 0] {_} defineName
	    set defineName [string toupper $defineName]
	    puts $f_configFile "\n`define $defineName\n"
	    close $f_configFile
	    
	    # Cleanup
	    file delete -force ./WORK
            file mkdir ./WORK
            cd ./WORK

	    # Copy Quartus tcl command file
	    if [catch {open "../openMSP430_fpga.tcl" r} f_quartus_tcl] {
		puts "ERROR: Cannot open Quartus command file file ../openMSP430_fpga.tcl"
		exit 1
	    }
	    set quartus_tcl [read $f_quartus_tcl]
	    close $f_quartus_tcl

            set fpgaName "[lindex $fpgaConfig 1]$speedGrade"

	    regsub -all {<DEVICE_NAME>}   $quartus_tcl "$fpgaName"              quartus_tcl
	    regsub -all {<DEVICE_FAMILY>} $quartus_tcl "[lindex $fpgaConfig 0]" quartus_tcl
	    regsub -all {<SPEED_AREA>}    $quartus_tcl "$analysisType"          quartus_tcl

	    set f_quartus_tcl [open "openMSP430_fpga.tcl" w]
	    puts $f_quartus_tcl $quartus_tcl
	    close $f_quartus_tcl

	    # Run synthesis
	    puts "#####################################################################################"
	    puts "#                            START SYNTHESIS ($analysisType optimized)"
	    puts "#===================================================================================="
	    puts "# [lindex $fpgaConfig 0] ([lindex $fpgaConfig 1]), speedgrade: -$speedGrade"
	    puts "#===================================================================================="
	    puts "# $rtlDefines"
	    puts "# $rtlConfig"
	    puts "#===================================================================================="
	    if {[catch "exec quartus_sh -t openMSP430_fpga.tcl | tee quartus_sh.log"]} {
		puts "ERROR: Synthesis error !!!!!!"
		exit 1
	    }

	    # Extract timing information
	    if [catch {open "openMSP430_fpga.tan.summary" r} f_timing] {
		if [catch {open "openMSP430_fpga.sta.rpt" r} f_timing] {
		    puts "ERROR: Cannot open timing file"
		    exit 1
		}
	    }
	    set timingFile [read $f_timing]
	    close $f_timing
	    if {![regexp {(Type\s+?: Clock Setup: 'dco_clk'.*?)From} $timingFile whole_match timing]} {
		regexp {([^\n]+?\n;\s+Slow .*?Model Fmax Summary[^\n]+?\n[^\n]+?\n[^\n]+?\n[^\n]+?\n[^\n]+?\n[^\n]+?\n)} $timingFile whole_match timing
	    }
	    puts $timing
	    puts "===================================================================================="

	    # Extract size information
	    if [catch {open "openMSP430_fpga.fit.summary" r} f_log] {
		puts "ERROR: Cannot open timing file openMSP430_fpga.fit.summary"
		exit 1
	    }
	    set logFile [read $f_log]
	    close $f_log
	    regexp {Timing Models[^\n]+\n(.+)} $logFile whole_match area
	    puts $area
	    puts "===================================================================================="

	    puts "#                            SYNTHESIS DONE"
	    puts "#####################################################################################"
	    puts ""
	    cd ../
	}
    }

}

exit 0
