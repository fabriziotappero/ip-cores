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
package require Tclx

###############################################################################
#                         SET SOME GLOBAL VARIABLES                           #
###############################################################################

# Set tools
set SYNPLICITY      "C:\\\\Actel\\\\Libero_v8.5\\\\Synplify\\\\synplify_96A\\\\bin\\\\synplify.exe"
set LIBERO_DESIGNER "C:\\\\Actel\\\\Libero_v8.5\\\\Designer\\\\bin\\\\designer.exe"

# Set the different FPGA architectures & models to be checked (it should have a FBGA484 package)
set fpgaConfigs {{"ProASIC3E"   A3PE1500   {Std -1 -2}}
                 {"ProASIC3L"   A3P1000L   {Std -1}}
                 {"ProASIC3"    A3P1000    {Std -1 -2}}
                 {"Fusion"      AFS1500    {Std -1 -2}}
                 {"IGLOOE"      AGLE600V5  {Std}}}


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
set designFiles    {../../rtl/verilog/openMSP430.v
                    ../../rtl/verilog/omsp_frontend.v
                    ../../rtl/verilog/omsp_execution_unit.v
                    ../../rtl/verilog/omsp_register_file.v
                    ../../rtl/verilog/omsp_alu.v
                    ../../rtl/verilog/omsp_mem_backbone.v
                    ../../rtl/verilog/omsp_clock_module.v
                    ../../rtl/verilog/omsp_sfr.v
                    ../../rtl/verilog/omsp_watchdog.v
                    ../../rtl/verilog/omsp_dbg.v
                    ../../rtl/verilog/omsp_dbg_uart.v
                    ../../rtl/verilog/omsp_dbg_hwbrk.v
                    ../../rtl/verilog/omsp_multiplier.v
                    ../../rtl/verilog/openMSP430_undefines.v
                    ../../rtl/verilog/timescale.v
}

###############################################################################
#                              PERFORM ANALYSIS                               #
###############################################################################
proc sleep {time} {
      after [expr $time*1000] set end 1
      vwait end
  }

# Copy design files
foreach designFile $designFiles {
	file copy -force $designFile "./src/"
}

# Create log file
file delete "./run_analysis.log"
set f_logFile [open "./run_analysis.log" w]

# Perform analysis
foreach rtlConfig $rtlConfigs {

    #-------------------------------------------------------------------------#
    #                        Generate RTL configuration                       #
    #-------------------------------------------------------------------------#

    # Read original define file
    if [catch {open $omspConfigFile r} f_omspConfigFile] {
	puts $f_logFile "ERROR: Cannot open file $omspConfigFile"
	close $f_logFile
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
		
	    # Cleanup
	    file delete -force ./WORK
        file mkdir ./WORK
        cd ./WORK

	    # Copy Synplify tcl command files
	    if [catch {open "../synplify.tcl" r} f_synplify_tcl] {
		puts $f_logFile "ERROR: Cannot open Synplify command file file ../synplify.tcl"
		close $f_logFile
		exit 1
	    }
	    set synplify_tcl [read $f_synplify_tcl]
	    close $f_synplify_tcl

	    regsub -all {<DEVICE_NAME>}   $synplify_tcl "[string toupper [lindex $fpgaConfig 1]]" synplify_tcl
	    regsub -all {<DEVICE_FAMILY>} $synplify_tcl "[string toupper [lindex $fpgaConfig 0]]" synplify_tcl
	    regsub -all {<SPEED_GRADE>}   $synplify_tcl "$speedGrade"                             synplify_tcl

	    set f_synplify_tcl [open "synplify.tcl" w]
	    puts $f_synplify_tcl $synplify_tcl
	    close $f_synplify_tcl

		# Copy Libero Designer tcl command files
	    if [catch {open "../libero_designer.tcl" r} f_libero_designer_tcl] {
		puts $f_logFile "ERROR: Cannot open Libero Designer command file file ../libero_designer.tcl"
		close $f_logFile
		exit 1
	    }
	    set libero_designer_tcl [read $f_libero_designer_tcl]
	    close $f_libero_designer_tcl

	    regsub -all {<DEVICE_NAME>}   $libero_designer_tcl "[lindex $fpgaConfig 1]" libero_designer_tcl
	    regsub -all {<DEVICE_FAMILY>} $libero_designer_tcl "[lindex $fpgaConfig 0]" libero_designer_tcl
	    regsub -all {<SPEED_GRADE>}   $libero_designer_tcl "$speedGrade"            libero_designer_tcl

	    set f_libero_designer_tcl [open "libero_designer.tcl" w]
	    puts $f_libero_designer_tcl $libero_designer_tcl
	    close $f_libero_designer_tcl

	    # Run synthesis
	    puts $f_logFile "#####################################################################################"
	    puts $f_logFile "#                            START SYNTHESIS"
	    puts $f_logFile "#===================================================================================="
	    puts $f_logFile "# [lindex $fpgaConfig 0] ([lindex $fpgaConfig 1]), speedgrade: $speedGrade"
	    puts $f_logFile "#===================================================================================="
	    puts $f_logFile "# $rtlDefines"
	    puts $f_logFile "# $rtlConfig"
	    puts $f_logFile "#===================================================================================="
		flush $f_logFile

		# Run synthesis
		set synplify_done 0
		while {[string eq $synplify_done 0]} {

			sleep 10
			eval exec $SYNPLICITY synplify.tcl
			sleep 30

			# Wait until EDIF file is generated
			set synplify_timeout 0

#			puts  $f_logFile "START LOOP: $synplify_timeout ($synplify_done)"
#			flush $f_logFile

			while {!([file exists "./rev_1/design_files.edn"] | ($synplify_timeout==100))} {
				sleep 6
#				puts  $f_logFile "YOPYOP: $synplify_timeout"
#				flush $f_logFile
				set synplify_timeout [expr $synplify_timeout+1]
			}
			if ($synplify_timeout<100) {
			   set synplify_done 1
			}
#			puts  $f_logFile "DONE: $synplify_timeout ($synplify_done)"
#			flush $f_logFile

			# Kill the Synplify task with taskkill since it can't be properly closed with the synplify.tcl script
			sleep 10
			eval exec taskkill /IM synplify.exe
			sleep 20
			if {[string eq $synplify_done 0]} {
				sleep 180
			}
		}
#		puts  $f_logFile "SYNPLIFY DONE: $synplify_timeout ($synplify_done)"
#		flush $f_logFile
				
		# Run place & route
		eval exec $LIBERO_DESIGNER script:libero_designer.tcl logfile:libero_designer.log

		
		# Extract timing information
	    if [catch {open "report_timing_max.txt" r} f_timing] {
		    puts $f_logFile "ERROR: Cannot open timing file"
			close $f_logFile
		    exit 1
	    }
	    set timingFile [read $f_timing]
	    close $f_timing
		regexp {SUMMARY(.*)END SUMMARY} $timingFile whole_match timing
	    puts $f_logFile $timing
	    puts $f_logFile "===================================================================================="

	    # Extract size information
	    if [catch {open "report_status.txt" r} f_area] {
		puts $f_logFile "ERROR: Cannot open status file: report_status.txt"
		close $f_logFile
		exit 1
	    }
	    set areaFile [read $f_area]
	    close $f_area
	    regexp {(Compile report:.*?)Total:} $areaFile whole_match area1
	    regexp {(Core Information:.*?)I/O Function:} $areaFile whole_match area2
	    puts $f_logFile $area1
	    puts $f_logFile $area2
	    puts $f_logFile "===================================================================================="

	    puts $f_logFile "#                            SYNTHESIS DONE"
	    puts $f_logFile "#####################################################################################"
	    puts $f_logFile ""
		flush $f_logFile
	    cd ../
		sleep 3
	}
    }

}
puts $f_logFile ""
puts $f_logFile "#####################################################################################"
puts $f_logFile "#                            ANALYSIS DONE"
puts $f_logFile "#####################################################################################"
puts $f_logFile ""
close $f_logFile
exit 0
