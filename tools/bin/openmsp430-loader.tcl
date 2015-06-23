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
# File Name: openmsp430-loader.tcl
#
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#
#------------------------------------------------------------------------------
# $Rev: 158 $
# $LastChangedBy: olivier.girard $
# $LastChangedDate: 2012-10-15 23:49:09 +0200 (Mon, 15 Oct 2012) $
#------------------------------------------------------------------------------

global omsp_conf
global omsp_info

###############################################################################
#                            SOURCE LIBRARIES                                 #
###############################################################################

# Get library path
set current_file [info script]
if {[file type $current_file]=="link"} {
    set current_file [file readlink $current_file]
}
set lib_path [file dirname $current_file]/../lib/tcl-lib

# Source library
source $lib_path/dbg_functions.tcl
source $lib_path/dbg_utils.tcl


###############################################################################
#                            PARAMETER CHECK                                  #
###############################################################################
#proc GetAllowedSpeeds

proc help {} {
    puts ""
    puts "USAGE   : openmsp430-loader.tcl \[-device   <communication port>\]"
    puts "                                \[-adaptor  <adaptor type>\]"
    puts "                                \[-speed    <communication speed>\]"
    puts "                                \[-i2c_addr <cpu address>\]           <elf/ihex-file>"
    puts ""
    puts "DEFAULT : <communication port>  = /dev/ttyUSB0"
    puts "          <adaptor type>        = uart_generic"
    puts "          <communication speed> = 115200 (for UART) / I2C_S_100KHZ (for I2C)"
    puts "          <core address>        = 42"
    puts ""
    puts "EXAMPLES: openmsp430-loader.tcl -device /dev/ttyUSB0 -adaptor uart_generic -speed 9600  leds.elf"
    puts "          openmsp430-loader.tcl -device COM2:        -adaptor i2c_usb-iss  -speed I2C_S_100KHZ -i2c_addr 75 ta_uart.ihex"
    puts ""
}

# Default values
set omsp_conf(interface)  uart_generic
set omsp_conf(device)     /dev/ttyUSB0
set omsp_conf(baudrate)   [lindex [GetAllowedSpeeds] 1]
set omsp_conf(0,cpuaddr)  42
set elf_file              -1
set bin_file              "[clock clicks].bin"

# Parse arguments
for {set i 0} {$i < $argc} {incr i} {
    switch -exact -- [lindex $argv $i] {
        -device   {set omsp_conf(device)    [lindex $argv [expr $i+1]]; incr i}
        -adaptor  {set omsp_conf(interface) [lindex $argv [expr $i+1]]; incr i}
        -speed    {set omsp_conf(baudrate)  [lindex $argv [expr $i+1]]; incr i}
        -i2c_addr {set omsp_conf(0,cpuaddr) [lindex $argv [expr $i+1]]; incr i}
        default   {set elf_file             [lindex $argv $i]}
    }
}

# Make sure arugments were specified
if {[string eq $elf_file -1]} {
    puts "\nERROR: ELF/IHEX file isn't specified"
    help
    exit 1   
}

# Make sure the elf file exists
if {![file exists $elf_file]} {
    puts "\nERROR: Specified ELF/IHEX file doesn't exist"
    help
    exit 1   
}

# Make sure the selected adptor is valid
if {![string eq $omsp_conf(interface) "uart_generic"] &
    ![string eq $omsp_conf(interface) "i2c_usb-iss"]} {
    puts "\nERROR: Specified adaptor is not valid (should be \"uart_generic\" or \"i2c_usb-iss\")"
    help
    exit 1   
}

# Make sure the I2C address is an integer
if {![string is integer $omsp_conf(0,cpuaddr)]} {
    puts "\nERROR: Specified I2C address is not an integer"
    help
    exit 1   
}

# Make sure the I2C address is valid
if {($omsp_conf(0,cpuaddr)<8) | ($omsp_conf(0,cpuaddr)>119)} {
    puts "\nERROR: Specified I2C address should lay between 7 and 120"
    help
    exit 1   
}

# If the selected interface is a UART, make sure the selected speed is an integer
if {[string eq $omsp_conf(interface) "uart_generic"]} {
    if {![string is integer $omsp_conf(baudrate)]} {
        puts "\nERROR: Specified UART communication speed is not an integer"
        help
        exit 1   
    }
} elseif {[string eq $omsp_conf(interface) "i2c_usb-iss"]} {
    if {[lsearch [lindex [GetAllowedSpeeds] 2] $omsp_conf(baudrate)]==-1} {
        puts "\nERROR: Specified I2C communication speed is not valid."
        puts "         Allowed values are:"
        foreach allowedVal [lindex [GetAllowedSpeeds] 2] {
            puts "                              - $allowedVal"
        }
        puts ""
        exit 1   
    }
}


###############################################################################
#                  CREATE AND READ BINARY EXECUTABLE FILE                     #
###############################################################################

# Detect the file format depending on the fil extention
set fileType [file extension $elf_file]
set fileType [string tolower $fileType]
regsub {\.} $fileType {} fileType
if {![string eq $fileType "ihex"] & ![string eq $fileType "hex"] & ![string eq $fileType "elf"]} {
    puts "\nERROR: [string toupper $fileType] file format not supported"
    return 0
}
if {[string eq $fileType "hex"]} {
    set fileType "ihex"
}
if {[string eq $fileType "elf"]} {
    set fileType "elf32-msp430"
}

# Generate binary file
if {[catch {exec msp430-objcopy -I $fileType -O binary $elf_file $bin_file} errMsg]} {
    puts $errMsg
    exit 1
}

# Wait until bin file is present on the filesystem
set timeout 100
for {set i 0} {$i <= $timeout} {incr i} {
    after 500
    if {[file exists $bin_file]} {
        break
    }
}
if {$i>=$timeout} {
    puts "\nTimeout: ELF to BIN file conversion problem with \"msp430-objcopy\" executable"
    puts "$errMsg"
    exit 1
}

# Read file
set fp [open $bin_file r]
fconfigure $fp -translation binary
binary scan [read $fp] H* hex_data yop
close $fp

# Cleanup
file delete $bin_file

# Get program size
set hex_size  [string length $hex_data]
set byte_size [expr $hex_size/2]
set word_size [expr $byte_size/2]

# Format data
for {set i 0} {$i < $hex_size} {set i [expr $i+4]} {
    set hex_msb "[string index $hex_data [expr $i+2]][string index $hex_data [expr $i+3]]"
    set hex_lsb "[string index $hex_data [expr $i+0]][string index $hex_data [expr $i+1]]"
    lappend DataArray "0x$hex_msb$hex_lsb"
}


###############################################################################
#                      LOAD PROGRAM TO OPENMSP430 TARGET                      #
###############################################################################

# Connect to target and stop CPU
puts            ""
puts -nonewline "Connecting with the openMSP430 ($omsp_conf(device), $omsp_conf(baudrate)\ bps)... "
flush stdout
if {![GetDevice 0]} {
    puts "failed"
    puts "Could not open $omsp_conf(device)"
    puts "Available serial ports are:"
    foreach port [utils::uart_port_list] {
    puts "                             -  $port"
    }
    if {[string eq $omsp_conf(interface) "i2c_usb-iss"]} {
        puts "\nMake sure the specified I2C device address is correct: $omsp_conf(0,cpuaddr)\n"
    }
    exit 1
}
ExecutePOR_Halt 0
puts "done"
set sizes [GetCPU_ID_SIZE 0]

if {$omsp_info(0,alias)!=""} {
    puts "Connected: target device identified as $omsp_info(0,alias)."
}
puts "Connected: target device has [lindex $sizes 0]B Program Memory and [lindex $sizes 1]B Data Memory"
puts ""

# Make sure ELF program size is the same as the available program memory
if {[lindex $sizes 0] != [expr $hex_size/2]} {
    puts "ERROR: ELF program size ($byte_size B) is different than the available program memory ([lindex $sizes 0] B)"
    exit 1
}

# Load Program Memory
set StartAddr [format "0x%04x" [expr 0x10000-$byte_size]]
puts -nonewline "Load Program Memory... "
flush stdout
WriteMemQuick 0 $StartAddr $DataArray
after 500
puts "done"

# Check Data
puts -nonewline "Verify Program Memory... "
flush stdout
if {[VerifyMem 0 $StartAddr $DataArray 1]} {
    puts "done"
} else {
    puts "ERROR"
    exit 1
}

# Release device
ReleaseDevice 0 0xfffe
