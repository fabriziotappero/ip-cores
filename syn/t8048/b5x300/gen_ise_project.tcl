###############################################################################
#
# $Id: gen_ise_project.tcl 295 2009-04-01 19:32:48Z arniml $
#
# Based on
# Created by Phil Hays, Xilinx
# Setup Xilinx environment, then run from Unix with "xtclsh dice.tcl"
#
# This Tcl script will implement a design and load it in the S3E FPGA on
# the Spartan 3E Starter Kit Board
#
# There are two ucf files, one for pins and one for timing
#
###############################################################################
#   Contact :     e-mail  hotline@xilinx.com
#                 phone   + 1 800 255 7778
#
#   Disclaimer:   LIMITED WARRANTY AND DISCLAMER. These designs are
#                 provided to you "as is". Xilinx and its licensors make and you
#                 receive no warranties or conditions, express, implied,
#                 statutory or otherwise, and Xilinx specifically disclaims any
#                 implied warranties of merchantability, non-infringement, or
#                 fitness for a particular purpose. Xilinx does not warrant that
#                 the functions contained in these designs will meet your
#                 requirements, or that the operation of these designs will be
#                 uninterrupted or error free, or that defects in the Designs
#                 will be corrected. Furthermore, Xilinx does not warrant or
#                 make any representations regarding use or the results of the
#                 use of the designs in terms of correctness, accuracy,
#                 reliability, or otherwise.
#
#                 LIMITATION OF LIABILITY. In no event will Xilinx or its
#                 licensors be liable for any loss of data, lost profits, cost
#                 or procurement of substitute goods or services, or for any
#                 special, incidental, consequential, or indirect damages
#                 arising from the use or operation of the designs or
#                 accompanying documentation, however caused and on any theory
#                 of liability. This limitation will apply even if Xilinx
#                 has been advised of the possibility of such damage. This
#                 limitation shall apply not-withstanding the failure of the
#                 essential purpose of any limited remedies herein.
#
#   Copyright (c) 2006 Xilinx, Inc.
#   All rights reserved
#
###############################################################################
# Version 1.0 - 19-Oct-2006
# Initial version
###############################################################################

###############################################################################
# MAIN
###############################################################################
# Modify the project settings for the specific design
#
# Make sure there are no files in the build directory that you may want to
# keep, as this TCL script cleans that directory by default!
###############################################################################

# mandatory environment variable for project name: $MODULE
if {[info exists env(MODULE)]} {
    set PROJECT $env(MODULE)
    puts "Info: Setting project name from \$MODULE: $PROJECT"
} else {
    puts "Error: Environment variable MODULE not set."
    exit 1
}

# optional environment variable for build directory: $BLD
# default is 'bld'
puts -nonewline "Info: "
if {[info exists env(BLD)]} {
    set bld $env(BLD)
    puts -nonewline "Setting build directory from \$BLD"
} else {
    set bld bld
    puts -nonewline "Setting build directory to default"
}
puts ": $bld"

# optional environment variable for source file compile list: $COMPILE_LIST
# default is 'compile_list'
puts -nonewline "Info: "
if {[info exists env(COMPILE_LIST)]} {
    set compile_list $env(COMPILE_LIST)
    puts -nonewline "Setting source file compile list from \$COMPILE_LIST"
} else {
    set compile_list compile_list
    puts -nonewline "Setting source file compile list to default"
}
puts ": $compile_list"

if {[file exists $bld]} {
    puts "Deleting all existing project files in '$bld'"
    # Perhaps ask ok here??
    # Or perhaps skip project creation if project exists??
    file delete -force $bld
}
puts "Creating new project directory in '$bld'..."
file mkdir $bld

###############################################################################
# Put two ucf file into one.
# This could be made as complex as required, however for demonstration it is
# just a simple copy.
###############################################################################

puts "Creating new UCF file..."

set tempucf [file join $bld temp.ucf]
set outfile [open $tempucf "w"]
set infile [open "t8048.ucf" "r"]
while {![eof $infile]} {
    puts $outfile [gets $infile]
}
close $infile
close $outfile
#
puts "Creating new ISE project..."
cd $bld
project new $PROJECT.ise
project set family spartan2e
project set device xc2s300e
project set package pq208
project set speed -6


###############################################################################
# Modify the xfile add argument for the source files in the design
###############################################################################

puts "Adding source files..."
set infile [open "../compile_list" "r"]
while {![eof $infile]} {
    xfile add "../[gets $infile]"
}
xfile add temp.ucf


###############################################################################
# Set optional implementation options here. There is a problem with setting
# project properties that at least one source must be added to the project
# first. Therefore, the "project set" commands are after the "xfile add"
# commands.
###############################################################################

puts "Setting project properties..."

project set {Optimization Goal} Area -process {Synthesize - XST}
project set {Optimization Effort} Normal -process {Synthesize - XST}
project set {Use Synthesis Constraints File} 1 -process {Synthesize - XST}

#project set "Map Effort Level" High
#project set {Perform Timing-Driven Packing and Placement} 1
project set {Place & Route Effort Level (Overall)} Standard
#project set "Other Place & Route Command Line Options" "-intsyle xflow"
project set {Generate Post-Place & Route Static Timing Report} true
project set {Report Unconstrained Paths} 10 -process {Generate Post-Place & Route Static Timing}
project set {Report Type} {Verbose Report} -process {Generate Post-Place & Route Static Timing}
project set {Create Binary Configuration File} 1 -process {Generate Programming File}

project close
