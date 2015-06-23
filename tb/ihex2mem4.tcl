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
# File Name: ihex2mem.tcl
# 
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#
#------------------------------------------------------------------------------
# $Rev: 17 $
# $LastChangedBy: olivier.girard $
# $LastChangedDate: 2009-08-04 14:15:39 -0700 (Tue, 04 Aug 2009) $
#------------------------------------------------------------------------------

###############################################################################
#                            PARAMETER CHECK                                  #
###############################################################################

if {$argc != 6} {
  puts "ERROR   : wrong number of arguments"
  puts "USAGE   : ihex2mem.tcl -ihex <input file> -out <output file> -mem_size <memory size>"
  puts "Example : ihex2mem.tcl -ihex rom.ihex     -out rom.mem       -mem_size 2048"
  exit 1
}

# default values
set ihex      empty.in
set out       empty.out
set mem_size  -1

# parse arguments
for {set i 0} {$i < $argc} {incr i} {
    switch -exact -- [lindex $argv $i] {
        -ihex     {set ihex     [lindex $argv [expr $i+1]]; incr i}
        -out      {set out      [lindex $argv [expr $i+1]]; incr i}
        -mem_size {set mem_size [lindex $argv [expr $i+1]]; incr i}
    }
}

# Make sure arugments were specified
if {[string eq $ihex empty.in]} {
    puts "IHEX input file isn't specified"
    exit 1   
}
if {[string eq $out empty.out]} {
    puts "MEMH output file isn't specified"
    exit 1   
}
if {[string eq $mem_size -1]} {
    puts "Memory size isn't specified"
    exit 1   
}


###############################################################################
#                            CONVERSION PROCEDURE                             #
###############################################################################

#-----------------------------------------------------------------------------#
#                                 OPEN FILES                                  #
#-----------------------------------------------------------------------------#

# IHEX Input
if [catch {open $ihex r} f_ihex] {
    puts "ERROR Cannot open input file $ihex"
    exit 1
}

# MEMH Output
set f_out [open code.mem w]

#-----------------------------------------------------------------------------#
#                                 CONVERSION                                  #
#-----------------------------------------------------------------------------#


# Conversions procedure
proc hex2dec { val  } {
  set val [format "%u" 0x[string trimleft $val]]
  return $val 
}


# Initialize memory array (8 bit words)
set num_word [expr ($mem_size)-1]
for {set i 0} {$i <= $num_word} {incr i} {
    set mem_arr($i) 90909090
}


# Calculate Address offset (offset=(0x10000-memory_size))
set mem_offset 0
set segment    0    


# Process input file 
while {[gets $f_ihex line] >= 0} {

    # Process line
    set byte_count [hex2dec [string range $line 1 2]]
    set start_addr [expr ([hex2dec [string range $line 3 6]] + $mem_offset)]
    set rec_type   [string range $line 7 8]
    if {[string compare $rec_type "02"] == 0} { set segment [expr $segment + 16384 ] } 

    if {[string compare $rec_type "00"] == 0} {
        for {set i 0} {$i < $byte_count*2} {set i [expr $i+2]} {
            set mem_l  [string range $line [expr $i+9] [expr $i+10]]

	    if {[string length $mem_l] == 0} {set mem_l "90"}

            set addr     [expr ($start_addr+$i/2) + $segment]
            set mem_arr($addr) "$mem_l"
	    #puts "$addr $mem_l"
        }
    }
}
close $f_ihex


# Writing memory array to file
for {set i 0} {$i <= $num_word} {incr i} { 

    puts $f_out " [format "%02s" [string range $mem_arr($i) 0 1] ]"
}

puts  $f_out "\n"


if { "$out"!="-"} {
  close $f_out

}

exit 0
Show details

