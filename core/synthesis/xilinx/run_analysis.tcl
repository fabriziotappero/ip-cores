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
set fpgaConfigs {{spartan3     xc3s400pq208    {4 5}      {30.0 34.0}}
                 {spartan3e    xc3s500epq208   {4 5}      {32.0 38.0}}
                 {spartan3a    xc3s700aft256   {4 5}      {31.0 36.0}}
                 {spartan3adsp xc3sd1800acs484 {4 5}      {31.0 39.0}}
                 {spartan6     xc6slx45tfgg484 {2 3 4}    {41.0 58.0 68.0}}
                 {virtex4      xc4vlx25sf363   {10 11 12} {51.0 57.0 69.0}}
                 {virtex5      xc5vlx30ff324   {1 2 3}    {75.0 82.0 97.0}}
                 {virtex6      xc6vlx75tff484  {1 2 3}    {92.0 102.0 115.0}}}


# Set the different RTL configurations to be analysed
set rtlDefines  {PMEM_AWIDTH DMEM_AWIDTH  DBG_EN  DBG_HWBRK_0 DBG_HWBRK_1 DBG_HWBRK_2 DBG_HWBRK_3 MULTIPLIER}
set rtlConfigs {{    12          10          0         0            0          0            0         0}
                {    12          10          1         0            0          0            0         0}
                {    12          10          1         1            0          0            0         0}
                {    12          10          1         1            1          0            0         0}
                {    12          10          1         1            1          1            0         0}
                {    12          10          1         1            1          1            1         0}}
set clkRatios  {1.00 0.95 0.85 0.85 0.85 0.85}
set rtlConfigs {{    12          10          0         0            0          0            0         1}}
set clkRatios  {1.00}


# RTL configuration files
set omspConfigFile "../../rtl/verilog/openMSP430_defines.v"
set rtlConfigFile  "./src/arch.v"


###############################################################################
#                              PERFORM ANALYSIS                               #
###############################################################################


foreach rtlConfig $rtlConfigs clkRatio $clkRatios {

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
	foreach speedGrade [lindex $fpgaConfig 2] clkFreq [lindex $fpgaConfig 3] {
	    
	    # Create verilog arch define
	    set f_configFile [open $rtlConfigFile w]
	    puts $f_configFile "\n`define [string toupper [lindex $fpgaConfig 0]]\n"
	    close $f_configFile
	    
	    # Cleanup
	    file delete -force ./WORK
            file mkdir ./WORK
            cd ./WORK

	    # Create links for RAM ngc files
	    file link "[lindex $fpgaConfig 0]_pmem.ngc" "../src/coregen/[lindex $fpgaConfig 0]_pmem.ngc"
	    file link "[lindex $fpgaConfig 0]_dmem.ngc" "../src/coregen/[lindex $fpgaConfig 0]_dmem.ngc"

	    # Create link to the Xilinx constraints file
	    if [catch {open "../openMSP430_fpga.ucf" r} f_ucf] {
		puts "ERROR: Cannot open constrain file ../openMSP430_fpga.ucf"
		exit 1
	    }
	    set ucf [read $f_ucf]
	    close $f_ucf
	    if {[string eq $analysisType "AREA"] || [string eq $clkFreq "-1"]} {
		regsub {<COMMENT>} $ucf "\#" ucf
	    } else {
		regsub {<COMMENT>} $ucf "" ucf
	    }
	    regsub {<PERIOD>}      $ucf "[expr 1000/($clkFreq*$clkRatio)]"     ucf
	    regsub {<HALF_PERIOD>} $ucf "[expr (1000/($clkFreq*$clkRatio))/2]" ucf
	    set f_ucf [open "openMSP430_fpga.ucf" w]
	    puts $f_ucf $ucf
	    close $f_ucf


	    # Copy synthesis configuration script
	    if [catch {open "../xst_verilog_[lindex $fpgaConfig 0].opt" r} f_xst_verilog] {
		puts "ERROR: Cannot open timing file ../xst_verilog_[lindex $fpgaConfig 0].opt"
		exit 1
	    }
	    set xst_verilog [read $f_xst_verilog]
	    close $f_xst_verilog
	    regsub {\"-opt_mode SPEED\";} $xst_verilog "\"-opt_mode $analysisType\";" xst_verilog

	    set f_xst_verilog [open "xst_verilog.opt" w]
	    puts $f_xst_verilog $xst_verilog
	    close $f_xst_verilog

	    # Run synthesis
	    puts "#####################################################################################"
	    puts "#                            START SYNTHESIS ($analysisType optimized)"
	    puts "#===================================================================================="
	    puts "# [lindex $fpgaConfig 0] ([lindex $fpgaConfig 1]), speedgrade: -$speedGrade"
	    puts "#===================================================================================="
	    puts "# $rtlDefines"
	    puts "# $rtlConfig"
	    puts "#===================================================================================="
            set fpgaName "[lindex $fpgaConfig 1]-$speedGrade"
	    if {[catch "exec xflow -p $fpgaName -implement high_effort.opt    \
                                   -config    bitgen.opt         \
                                   -synth     ./xst_verilog.opt  \
                                   ../openMSP430_fpga.prj"]} {

		puts "ERROR: Synthesis error !!!!!!"
		exit 1
	    }

	    # Extract timing information
	    if [catch {open "openMSP430_fpga.twr" r} f_timing] {
		puts "ERROR: Cannot open timing file openMSP430_fpga.twr"
		exit 1
	    }
	    set timingFile [read $f_timing]
	    close $f_timing
	    regexp {Clock to Setup on destination.*\+\n} $timingFile whole_match
	    puts $whole_match
	    puts "===================================================================================="

	    # Extract size information
	    if [catch {open "openMSP430_fpga_xst.log" r} f_log] {
		puts "ERROR: Cannot open timing file openMSP430_fpga_xst.log"
		exit 1
	    }
	    set logFile [read $f_log]
	    close $f_log
	    regexp {(Device utilization summary:.*\n)Partition Resource Summary:} $logFile whole_match area
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
