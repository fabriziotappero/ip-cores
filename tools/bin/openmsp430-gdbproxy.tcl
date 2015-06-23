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
# File Name: openmsp430-gdbproxy.tcl
# 
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#
#------------------------------------------------------------------------------
# $Rev: 198 $
# $LastChangedBy: olivier.girard $
# $LastChangedDate: 2014-10-07 21:30:05 +0200 (Tue, 07 Oct 2014) $
#------------------------------------------------------------------------------

###############################################################################
#                                                                             #
#                            SOURCE LIBRARIES                                 #
#                                                                             #
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

# Source remaining files
source [file dirname $current_file]/../openmsp430-gdbproxy/server.tcl
source [file dirname $current_file]/../openmsp430-gdbproxy/commands.tcl


###############################################################################
#                                                                             #
#                            GLOBAL VARIABLES                                 #
#                                                                             #
###############################################################################

global omsp_conf
global omsp_info

global omsp_nr

global mem_mapping

global gui_dbg_if
global gui_adapter
global clients
global server
global verbose
global shell
global breakSelect
global mspgcc_compat_mode

# Initialize to default values
set omsp_nr                1
set omsp_conf(interface)  uart_generic
set omsp_conf(device)     [lindex [utils::uart_port_list] end]
set omsp_conf(baudrate)   [lindex [GetAllowedSpeeds] 1]
set omsp_conf(0,cpuaddr)  50
set omsp_conf(1,cpuaddr)  51
set omsp_conf(2,cpuaddr)  52
set omsp_conf(3,cpuaddr)  53

set server(0,port)      2000
set server(1,port)      2001
set server(2,port)      2002
set server(3,port)      2003

set mem_mapping(0)         0
set mem_mapping(1)         0
set mem_mapping(2)         0
set mem_mapping(3)         0

set breakSelect            0

set shell                  0
set verbose                0
set mspgcc_compat_mode     0

###############################################################################
#                                                                             #
#                            PARAMETER CHECK                                  #
#                                                                             #
###############################################################################

proc help {} {
    puts ""
    puts "USAGE   : openmsp430-gdbproxy.tcl \[-device   <communication port>\]"
    puts "                                  \[-adaptor  <adaptor type>\]"
    puts "                                  \[-speed    <communication speed>\]"
    puts "                                  \[-i2c_addr <cpu address>\]"
    puts "                                  \[-port     <server port>\]"
    puts "                                  \[-shell]"
    puts "                                  \[-verbose\]"
    puts "                                  \[-mspgcc_compat_mode\]"
    puts "                                  \[-help\]"
    puts ""
    puts "Examples: openmsp430-gdbproxy.tcl -device /dev/ttyUSB0 -adaptor uart_generic -speed  115200  -port 2000"
    puts "          openmsp430-gdbproxy.tcl -device COM2:        -adaptor i2c_usb-iss  -speed  I2C_S_100KHZ -i2c_addr 75 -port 2000"
    puts ""
}

# Parse arguments
for {set i 0} {$i < $argc} {incr i} {
    switch -exact -- [lindex $argv $i] {
        -device             {set omsp_conf(device)    [lindex $argv [expr $i+1]]; incr i}
        -adaptor            {set omsp_conf(interface) [lindex $argv [expr $i+1]]; incr i}
        -speed              {set omsp_conf(baudrate)  [lindex $argv [expr $i+1]]; incr i}
        -i2c_addr           {set omsp_conf(0,cpuaddr) [lindex $argv [expr $i+1]]; incr i}
        -port               {set server(0,port)       [lindex $argv [expr $i+1]]; incr i}
        -shell              {set shell   1}
        -verbose            {set verbose 1}
        -mspgcc_compat_mode {set mspgcc_compat_mode 1}
        -h                  {help; exit 0}
        -help               {help; exit 0}
        default             {}
    }
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

# Source additional library for graphical interface
if {!$shell} {
    source $lib_path/combobox.tcl
    package require combobox 2.3
    catch {namespace import combobox::*}
}

# Small functions to display messages
proc putsLog {string {nonewline 0}} {
    global server
    global shell
    if {$shell} {
        if {$nonewline} {
            puts -nonewline $string
        } else {
            puts $string
        }
    } else {
        if {$nonewline} {
            $server(log) insert end "$string"
        } else {
            $server(log) insert end "$string\n"
        }
        $server(log) see end
    }
}
proc putsVerbose {string} {
    global verbose
    if {$verbose} {
        putsLog "$string"
    }
}

###############################################################################
#                               SHELL MODE                                    #
###############################################################################
if {$shell} {

    # Connect to device
    if {![GetDevice 0]} {
        puts "ERROR: Could not open $omsp_conf(device)"
        puts "INFO:  Available serial ports are:"
        foreach port [utils::uart_port_list] {
            puts "INFO:                               -  $port"
        }
        if {[string eq $omsp_conf(interface) "i2c_usb-iss"]} {
            puts "\nMake sure the specified I2C device address is correct: $omsp_conf(0,cpuaddr)\n"
        }
        exit 1
    }

    # Display info
    if {$omsp_info(0,alias)==""} {
        puts "INFO: Sucessfully connected with the openMSP430 target."
    } else {
        puts "INFO: Sucessfully connected with the openMSP430 target ($omsp_info(0,alias))."
    }
    set sizes [GetCPU_ID_SIZE 0]
    if {$omsp_info(0,asic)} {
        puts "INFO: CPU Version              - $omsp_info(0,cpu_ver) / ASIC"
    } else {
        puts "INFO: CPU Version              - $omsp_info(0,cpu_ver) / FPGA"
    }
    puts "INFO: User Version             - $omsp_info(0,user_ver)"
    if {$omsp_info(0,cpu_ver)==1} {
        puts "INFO: Hardware Multiplier      - --"
    } elseif {$omsp_info(0,mpy)} {
        puts "INFO: Hardware Multiplier      - Yes"
    } else {
        puts "INFO: Hardware Multiplier      - No"
    }
    puts "INFO: Program Memory Size      - $omsp_info(0,pmem_size) B"
    puts "INFO: Data Memory Size         - $omsp_info(0,dmem_size) B"
    puts "INFO: Peripheral Address Space - $omsp_info(0,per_size) B"
    puts "INFO: $omsp_info(0,hw_break) Hardware Brea/Watch-point unit(s) detected"
    puts ""

    # Reset & Stop CPU
    ExecutePOR_Halt 0

    # Start server for GDB
    if {![startServer 0]} {
        exit 1
    }

    vwait forever
}

proc getConfiguration {} {

    global gui_dbg_if
    global gui_adapter
    global omsp_conf

    regexp {(.+)_(.+)} $omsp_conf(interface) whole_match tmp_if tmp_adapter

    set gui_dbg_if  [string toupper $tmp_if] 
    set gui_adapter [string toupper $tmp_adapter]

    return 1
}

proc updateConfiguration {{w ""} {sel ""}} {

    global gui_dbg_if
    global gui_adapter
    global omsp_conf
    global omsp_nr

    if {$sel=="UART"} {
        eval .connect.cfg.if.config2.adapter.p2 list delete 0 end
        eval .connect.cfg.if.config2.adapter.p2 list insert   end [list "GENERIC"]
        set gui_adapter "GENERIC"
        set omsp_conf(interface)  uart_generic

    } elseif {$sel=="I2C"} {

        eval .connect.cfg.if.config2.adapter.p2 list delete 0 end
        eval .connect.cfg.if.config2.adapter.p2 list insert   end [list "USB-ISS"]
        set gui_adapter "USB-ISS"
        set omsp_conf(interface)  i2c_usb-iss
    }

    if {$gui_dbg_if=="UART"} {
        set omsp_nr 1
        .connect.cfg.ad.i2c_nr.l        configure -state disabled
        .connect.cfg.ad.i2c_nr.s        configure -state disabled
        .connect.cfg.ad.i2c_addr.l      configure -state disabled
        .connect.cfg.ad.i2c_addr.s0     configure -state disabled
        .connect.cfg.ad.i2c_addr.s1     configure -state disabled
        .connect.cfg.ad.i2c_addr.s2     configure -state disabled
        .connect.cfg.ad.i2c_addr.s3     configure -state disabled
        .connect.cfg.ad.arrow.l0        configure -state disabled
        .connect.cfg.ad.arrow.l1        configure -state disabled
        .connect.cfg.ad.arrow.l2        configure -state disabled
        .connect.cfg.ad.arrow.l3        configure -state disabled
        .connect.cfg.ad.server_port.p0  configure -state normal
        .connect.cfg.ad.server_port.p1  configure -state disabled
        .connect.cfg.ad.server_port.p2  configure -state disabled
        .connect.cfg.ad.server_port.p3  configure -state disabled
        .connect.cfg.ad.core_nr.l0      configure -state disabled
        .connect.cfg.ad.core_nr.l1      configure -state disabled
        .connect.cfg.ad.core_nr.l2      configure -state disabled
        .connect.cfg.ad.core_nr.l3      configure -state disabled
        .connect.cfg.ad.i2c_nr.f.soft.b configure -state disabled
	if {[winfo exists .omsp_sft_brk]} {
	    updateSoftBreakpoints
	}

    } elseif {$gui_dbg_if=="I2C"} {
        .connect.cfg.ad.core_nr.l0      configure -state normal
        .connect.cfg.ad.i2c_nr.l        configure -state normal
        .connect.cfg.ad.i2c_nr.s        configure -state normal
        .connect.cfg.ad.i2c_addr.l      configure -state normal
        .connect.cfg.ad.i2c_addr.s0     configure -state normal
        .connect.cfg.ad.arrow.l0        configure -state normal
        .connect.cfg.ad.server_port.p0  configure -state normal

        if {$omsp_nr < 2} {
            .connect.cfg.ad.core_nr.l1      configure -state disabled
            .connect.cfg.ad.server_port.p1  configure -state disabled
            .connect.cfg.ad.arrow.l1        configure -state disabled
            .connect.cfg.ad.i2c_addr.s1     configure -state disabled
            .connect.cfg.ad.i2c_nr.f.soft.b configure -state disabled
        } else            {
            .connect.cfg.ad.core_nr.l1      configure -state normal
            .connect.cfg.ad.server_port.p1  configure -state normal
            .connect.cfg.ad.arrow.l1        configure -state normal
            .connect.cfg.ad.i2c_addr.s1     configure -state normal
            .connect.cfg.ad.i2c_nr.f.soft.b configure -state normal
        }
        
        if {$omsp_nr < 3} {
            .connect.cfg.ad.core_nr.l2      configure -state disabled
            .connect.cfg.ad.server_port.p2  configure -state disabled
            .connect.cfg.ad.arrow.l2        configure -state disabled
            .connect.cfg.ad.i2c_addr.s2     configure -state disabled
        } else            {
            .connect.cfg.ad.core_nr.l2      configure -state normal
            .connect.cfg.ad.server_port.p2  configure -state normal
            .connect.cfg.ad.arrow.l2        configure -state normal
            .connect.cfg.ad.i2c_addr.s2     configure -state normal
        }
        
        if {$omsp_nr < 4} {
            .connect.cfg.ad.core_nr.l3      configure -state disabled
            .connect.cfg.ad.server_port.p3  configure -state disabled
            .connect.cfg.ad.arrow.l3        configure -state disabled
            .connect.cfg.ad.i2c_addr.s3     configure -state disabled
        } else            {
            .connect.cfg.ad.core_nr.l3      configure -state normal
            .connect.cfg.ad.server_port.p3  configure -state normal
            .connect.cfg.ad.arrow.l3        configure -state normal
            .connect.cfg.ad.i2c_addr.s3     configure -state normal
        }
	updateSoftBreakpoints
    }

    .connect.cfg.if.config2.serial_port.p2 configure -editable  1
    eval .connect.cfg.if.config2.serial_port.p2  list delete 0 end
    eval .connect.cfg.if.config2.serial_port.p2  list insert   end [lindex [GetAllowedSpeeds] 2]
    set omsp_conf(baudrate) [lindex [GetAllowedSpeeds] 1];
    .connect.cfg.if.config2.serial_port.p2 configure -editable  [lindex [GetAllowedSpeeds] 0];

}

###############################################################################
#                                 GUI MODE                                    #
###############################################################################

####################################
#   CREATE & PLACE MAIN WIDGETS    #
####################################

wm title    . "openMSP430 GDB Proxy"
wm iconname . "openMSP430 GDB Proxy"

# Create the Main Menu frame
frame  .menu
pack   .menu   -side top -padx 10 -pady 10 -fill x

# Create the Connection frame
frame  .connect -bd 2 -relief ridge    ;# solid
pack   .connect -side top -padx 10 -pady {5 0} -fill x

# Create the Info frame
frame  .info    -bd 2 -relief ridge    ;# solid
pack   .info    -side top -padx 10 -pady {10 0} -fill x

# Create the Server frame
frame  .server -bd 2 -relief ridge    ;# solid
pack   .server -side top -padx 10 -pady {10 0} -fill x

# Create the TCL script field
frame  .tclscript -bd 2 -relief ridge    ;# solid
pack   .tclscript -side top -padx 10 -pady 10 -fill x


####################################
#  CREATE THE REST                 #
####################################

# Exit button
button .menu.exit -text "Exit" -command {stopAllServers; exit 0}
pack   .menu.exit -side left

# openMSP430 label
label  .menu.omsp      -text "openMSP430 GDB proxy" -anchor center -fg "\#6a5acd" -font {-weight bold -size 14}
pack   .menu.omsp      -side right -padx 20 

# Create the Configuration, Start & Info frames
getConfiguration
frame  .connect.cfg
pack   .connect.cfg    -side left   -padx  0 -pady  0 -fill x -expand true
frame  .connect.cfg.if -bd 2 -relief ridge
pack   .connect.cfg.if -side top    -padx 10 -pady {10 0} -fill x -expand true
frame  .connect.cfg.ad -bd 2 -relief ridge
pack   .connect.cfg.ad -side top    -padx 10 -pady 10 -fill both -expand true
frame  .connect.start
pack   .connect.start  -side right  -padx 10 -pady 10 -fill both -expand true

frame  .connect.cfg.if.config1
pack   .connect.cfg.if.config1 -side left   -padx 0 -pady 0 -fill x -expand true
frame  .connect.cfg.if.config2
pack   .connect.cfg.if.config2 -side left   -padx 0 -pady 0 -fill x -expand true

# Interface & Adapter selection
frame    .connect.cfg.if.config1.adapter
pack     .connect.cfg.if.config1.adapter         -side top  -padx 5 -pady {10 0} -fill x
label    .connect.cfg.if.config1.adapter.l1      -text "Serial Debug Interface:" -anchor w
pack     .connect.cfg.if.config1.adapter.l1      -side left -padx 5
combobox .connect.cfg.if.config1.adapter.p1      -textvariable gui_dbg_if -editable false -width 15 -command {updateConfiguration}
eval     .connect.cfg.if.config1.adapter.p1      list insert end [list "UART" "I2C"]
pack     .connect.cfg.if.config1.adapter.p1      -side right -padx 10

frame    .connect.cfg.if.config2.adapter
pack     .connect.cfg.if.config2.adapter         -side top  -padx 5 -pady {10 0} -fill x
label    .connect.cfg.if.config2.adapter.l2      -text "Adapter selection:" -anchor w
pack     .connect.cfg.if.config2.adapter.l2      -side left -padx 5
combobox .connect.cfg.if.config2.adapter.p2      -textvariable gui_adapter -editable false -width 15
eval     .connect.cfg.if.config2.adapter.p2      list insert end [list "GENERIC"]
pack     .connect.cfg.if.config2.adapter.p2      -side right -padx 5

# Device port & Speed selection 
frame    .connect.cfg.if.config1.serial_port
pack     .connect.cfg.if.config1.serial_port     -side top   -padx 5 -pady {10 10} -fill x
label    .connect.cfg.if.config1.serial_port.l1  -text "Device Port:"  -anchor w
pack     .connect.cfg.if.config1.serial_port.l1  -side left  -padx 5
combobox .connect.cfg.if.config1.serial_port.p1  -textvariable omsp_conf(device) -editable true -width 15
eval     .connect.cfg.if.config1.serial_port.p1  list insert end [utils::uart_port_list]
pack     .connect.cfg.if.config1.serial_port.p1  -side right -padx 10

frame    .connect.cfg.if.config2.serial_port
pack     .connect.cfg.if.config2.serial_port     -side top   -padx 5 -pady {10 10} -fill x
label    .connect.cfg.if.config2.serial_port.l2  -text "Speed:" -anchor w
pack     .connect.cfg.if.config2.serial_port.l2  -side left  -padx 5
combobox .connect.cfg.if.config2.serial_port.p2  -textvariable omsp_conf(baudrate) -editable [lindex [GetAllowedSpeeds] 0] -width 15
eval     .connect.cfg.if.config2.serial_port.p2  list insert end [lindex [GetAllowedSpeeds] 2]
pack     .connect.cfg.if.config2.serial_port.p2  -side right -padx 5

# Server Port field & I2C address selection
frame    .connect.cfg.ad.core_nr
pack     .connect.cfg.ad.core_nr     -side left -padx 5 -pady {0 20} -fill y
label    .connect.cfg.ad.core_nr.l3  -text "Core 3:" -anchor w
pack     .connect.cfg.ad.core_nr.l3  -side bottom  -padx {25 0} -pady {10 10} 
label    .connect.cfg.ad.core_nr.l2  -text "Core 2:" -anchor w
pack     .connect.cfg.ad.core_nr.l2  -side bottom  -padx {25 0} -pady {10 2} 
label    .connect.cfg.ad.core_nr.l1  -text "Core 1:" -anchor w
pack     .connect.cfg.ad.core_nr.l1  -side bottom  -padx {25 0} -pady {10 2} 
label    .connect.cfg.ad.core_nr.l0  -text "Core 0:" -anchor w
pack     .connect.cfg.ad.core_nr.l0  -side bottom  -padx {25 0} -pady {10 2} 

frame    .connect.cfg.ad.server_port
pack     .connect.cfg.ad.server_port    -side left -padx 5 -pady {0 20} -fill y
entry    .connect.cfg.ad.server_port.p3 -textvariable server(3,port) -relief sunken -width 10
pack     .connect.cfg.ad.server_port.p3 -side bottom  -padx 5 -pady {10 10} 
entry    .connect.cfg.ad.server_port.p2 -textvariable server(2,port) -relief sunken -width 10
pack     .connect.cfg.ad.server_port.p2 -side bottom  -padx 5 -pady {10 0} 
entry    .connect.cfg.ad.server_port.p1 -textvariable server(1,port) -relief sunken -width 10
pack     .connect.cfg.ad.server_port.p1 -side bottom  -padx 5 -pady {10 0} 
entry    .connect.cfg.ad.server_port.p0 -textvariable server(0,port) -relief sunken -width 10
pack     .connect.cfg.ad.server_port.p0 -side bottom  -padx 5 -pady {10 0} 
label    .connect.cfg.ad.server_port.l  -text "Proxy Server Port" -anchor w
pack     .connect.cfg.ad.server_port.l  -side bottom  -padx 5 -pady {10 0} 

frame    .connect.cfg.ad.arrow
pack     .connect.cfg.ad.arrow     -side left -padx 5 -pady {0 20} -fill y
label    .connect.cfg.ad.arrow.l3  -text "==>" -anchor w
pack     .connect.cfg.ad.arrow.l3  -side bottom  -padx 5 -pady {10 10} 
label    .connect.cfg.ad.arrow.l2  -text "==>" -anchor w
pack     .connect.cfg.ad.arrow.l2  -side bottom  -padx 5 -pady {10 2} 
label    .connect.cfg.ad.arrow.l1  -text "==>" -anchor w
pack     .connect.cfg.ad.arrow.l1  -side bottom  -padx 5 -pady {10 2} 
label    .connect.cfg.ad.arrow.l0  -text "==>" -anchor w
pack     .connect.cfg.ad.arrow.l0  -side bottom  -padx 5 -pady {10 2} 

frame    .connect.cfg.ad.i2c_addr
pack     .connect.cfg.ad.i2c_addr     -side left -padx 5 -pady {0 20} -fill y
spinbox  .connect.cfg.ad.i2c_addr.s3  -from 8 -to 119 -textvariable omsp_conf(3,cpuaddr) -width 4
pack     .connect.cfg.ad.i2c_addr.s3  -side bottom    -padx 5 -pady {10 10} 
spinbox  .connect.cfg.ad.i2c_addr.s2  -from 8 -to 119 -textvariable omsp_conf(2,cpuaddr) -width 4
pack     .connect.cfg.ad.i2c_addr.s2  -side bottom    -padx 5 -pady {10 0} 
spinbox  .connect.cfg.ad.i2c_addr.s1  -from 8 -to 119 -textvariable omsp_conf(1,cpuaddr) -width 4
pack     .connect.cfg.ad.i2c_addr.s1  -side bottom    -padx 5 -pady {10 0} 
spinbox  .connect.cfg.ad.i2c_addr.s0  -from 8 -to 119 -textvariable omsp_conf(0,cpuaddr) -width 4
pack     .connect.cfg.ad.i2c_addr.s0  -side bottom    -padx 5 -pady {10 0} 
label    .connect.cfg.ad.i2c_addr.l   -text "I2C Address" -anchor w
pack     .connect.cfg.ad.i2c_addr.l   -side bottom    -padx 5 -pady {10 0} 

frame    .connect.cfg.ad.i2c_nr
pack     .connect.cfg.ad.i2c_nr     -side right -padx 5 -fill y
label    .connect.cfg.ad.i2c_nr.l   -text "Number of cores" -anchor w
pack     .connect.cfg.ad.i2c_nr.l   -side top    -padx 50 -pady {10 0} 
spinbox  .connect.cfg.ad.i2c_nr.s   -from 1 -to 4 -textvariable omsp_nr -state readonly -width 4 -command {updateConfiguration}
pack     .connect.cfg.ad.i2c_nr.s   -side top    -padx 50 -pady {10 10} 

frame       .connect.cfg.ad.i2c_nr.f   -bd 2 -relief ridge
pack        .connect.cfg.ad.i2c_nr.f   -side top -padx 10 -pady {5 5} -fill x
label       .connect.cfg.ad.i2c_nr.f.l2  -text "Breakpoint configuration" -anchor w
pack        .connect.cfg.ad.i2c_nr.f.l2  -side top    -padx 0 -pady {5 10} 

frame       .connect.cfg.ad.i2c_nr.f.soft
pack        .connect.cfg.ad.i2c_nr.f.soft   -side top -padx 0 -fill x
radiobutton .connect.cfg.ad.i2c_nr.f.soft.r -value "0" -text "" -state normal -variable breakSelect -command {updateSoftBreakpoints}
pack        .connect.cfg.ad.i2c_nr.f.soft.r -side left -padx {10 0}  -pady {0 0} 
label       .connect.cfg.ad.i2c_nr.f.soft.l -text "Soft" -anchor w
pack        .connect.cfg.ad.i2c_nr.f.soft.l -side left -padx {5 10} -pady {3 0} 
button      .connect.cfg.ad.i2c_nr.f.soft.b -text "Config." -state disabled -command {configSoftBreakpoints}
pack        .connect.cfg.ad.i2c_nr.f.soft.b -side right -padx {0 20}

frame       .connect.cfg.ad.i2c_nr.f.hard
pack        .connect.cfg.ad.i2c_nr.f.hard   -side top -padx 0 -pady {0 10} -fill x
radiobutton .connect.cfg.ad.i2c_nr.f.hard.r -value "1" -text "" -state normal -variable breakSelect -command {updateSoftBreakpoints}
pack        .connect.cfg.ad.i2c_nr.f.hard.r -side left -padx {10 0}  -pady {0 0} 
label       .connect.cfg.ad.i2c_nr.f.hard.l -text "Hard" -anchor w
pack        .connect.cfg.ad.i2c_nr.f.hard.l -side left -padx {5 10} -pady {3 0} 

# Update according to default values
updateConfiguration

# Connect to CPU & start proxy server
frame       .connect.start.f
pack        .connect.start.f   -side top -padx 10 -pady 0 -fill x -expand true
button      .connect.start.f.b -text "Connect to CPU(s)\n and \nStart Proxy Server(s)" -command {startServerGUI}
pack        .connect.start.f.b -side top -padx 30
checkbutton .connect.start.comp_mode -text "MSPGCC Compatibility Mode" -variable mspgcc_compat_mode
pack        .connect.start.comp_mode -side bottom -padx 10


# CPU Info
frame  .info.cpu
pack   .info.cpu      -side top   -padx 10 -pady {5 0} -fill x
label  .info.cpu.l    -text "CPU Info:"       -anchor w
pack   .info.cpu.l    -side left -padx {10 10}
label  .info.cpu.con  -text "Disconnected"    -anchor w -fg Red
pack   .info.cpu.con  -side left
button .info.cpu.more -text "More..."         -width 9 -command {displayMore} -state disabled
pack   .info.cpu.more -side right -padx {0 30}


# Server Info
frame  .info.server
pack   .info.server     -side top   -padx 10 -pady {0 10} -fill x
label  .info.server.l   -text "Server Info:"       -anchor w
pack   .info.server.l   -side left -padx {10 10}
label  .info.server.con -text "Not running"    -anchor w -fg Red
pack   .info.server.con -side left


# Create the text widget to log received messages
frame  .server.t
pack   .server.t     -side top -padx 10 -pady 10 -fill x
set server(log) [text   .server.t.log -width 80 -height 15 -borderwidth 2  \
                          -setgrid true -yscrollcommand {.server.t.scroll set}]
pack   .server.t.log -side left  -fill both -expand true
scrollbar .server.t.scroll -command {.server.t.log yview}
pack   .server.t.scroll -side right -fill both


# Log commands
frame  .server.cmd
pack   .server.cmd   -side top  -pady {0 10} -fill x
button .server.cmd.clear -text "Clear log" -command {$server(log) delete 1.0 end}
pack   .server.cmd.clear -side left -padx 10
checkbutton .server.cmd.verbose -text "Verbose" -variable verbose
pack   .server.cmd.verbose -side right -padx 10


# Load TCL script fields
frame  .tclscript.ft
pack   .tclscript.ft        -side top  -padx 10  -pady 10 -fill x
label  .tclscript.ft.l      -text "TCL script:" -state disabled
pack   .tclscript.ft.l      -side left -padx "0 10"
entry  .tclscript.ft.file   -width 58 -relief sunken -textvariable tcl_file_name -state disabled
pack   .tclscript.ft.file   -side left -padx 10
button .tclscript.ft.browse -text "Browse" -state disabled -command {set tcl_file_name [tk_getOpenFile -filetypes {{{TCL Files} {.tcl}} {{All Files} *}}]}
pack   .tclscript.ft.browse -side left -padx 5 
frame  .tclscript.fb
pack   .tclscript.fb        -side top -fill x
button .tclscript.fb.read   -text "Source TCL script !" -state disabled -command {if {[file exists $tcl_file_name]} {source $tcl_file_name}}
pack   .tclscript.fb.read   -side left -padx 20  -pady {0 10} -fill x

wm resizable . 0 0



#####################################
#  Breakpoint configuration window  #
#####################################

proc configSoftBreakpoints  { } {

    global omsp_nr

    # Destroy windows if already existing
    if {[lsearch -exact [winfo children .] .omsp_sft_brk]!=-1} {
        destroy .omsp_sft_brk
    }

    # Create master window
    set title "Software Breakpoint Configuration"
    toplevel     .omsp_sft_brk
    wm title     .omsp_sft_brk $title
    wm geometry  .omsp_sft_brk +380+200
    wm resizable .omsp_sft_brk 0 0

    # Title
    label  .omsp_sft_brk.title  -text "$title"   -anchor center -fg "\#6a5acd" -font {-weight bold -size 16}
    pack   .omsp_sft_brk.title  -side top -padx {20 20} -pady {20 10}

    # Create global frame
    frame     .omsp_sft_brk.map
    pack      .omsp_sft_brk.map   -side top  -padx {10 10} -pady {0 0}

    # Create frame for buttons
    frame       .omsp_sft_brk.map.b  -bd 2 -relief ridge
    pack        .omsp_sft_brk.map.b  -side top  -padx 10  -pady {10 0} -fill x -expand true

    button      .omsp_sft_brk.map.b.share -text "Shared Program Memory"    -command {setMemMapping 0 0 0 0}
    pack        .omsp_sft_brk.map.b.share -side left  -padx {20 15} -pady {10 10}

    button      .omsp_sft_brk.map.b.dedic -text "Dedicated Program Memory" -command {setMemMapping 0 1 2 3}
    pack        .omsp_sft_brk.map.b.dedic -side right -padx {15 20} -pady {10 10}


    # Create fram for radio-buttons
    frame       .omsp_sft_brk.map.r  -bd 2 -relief ridge
    pack        .omsp_sft_brk.map.r  -side top  -padx 10  -pady {10 20} -fill x -expand true

    frame       .omsp_sft_brk.map.r.core_nr
    pack        .omsp_sft_brk.map.r.core_nr     -side left -padx 5 -pady {0 20} -fill y
    label       .omsp_sft_brk.map.r.core_nr.l3  -text "Core 3:" -anchor w
    pack        .omsp_sft_brk.map.r.core_nr.l3  -side bottom  -padx {25 0} -pady {10 10} 
    label       .omsp_sft_brk.map.r.core_nr.l2  -text "Core 2:" -anchor w
    pack        .omsp_sft_brk.map.r.core_nr.l2  -side bottom  -padx {25 0} -pady {10 2} 
    label       .omsp_sft_brk.map.r.core_nr.l1  -text "Core 1:" -anchor w
    pack        .omsp_sft_brk.map.r.core_nr.l1  -side bottom  -padx {25 0} -pady {10 2} 
    label       .omsp_sft_brk.map.r.core_nr.l0  -text "Core 0:" -anchor w
    pack        .omsp_sft_brk.map.r.core_nr.l0  -side bottom  -padx {25 0} -pady {10 2} 
    
    frame       .omsp_sft_brk.map.r.pmem0
    pack        .omsp_sft_brk.map.r.pmem0    -side left -padx 5 -pady {0 20} -fill y
    radiobutton .omsp_sft_brk.map.r.pmem0.p3 -value "0" -text "" -state normal -variable mem_mapping(3)
    pack        .omsp_sft_brk.map.r.pmem0.p3 -side bottom  -padx 5 -pady {10 10} 
    radiobutton .omsp_sft_brk.map.r.pmem0.p2 -value "0" -text "" -state normal -variable mem_mapping(2)
    pack        .omsp_sft_brk.map.r.pmem0.p2 -side bottom  -padx 5 -pady {10 0} 
    radiobutton .omsp_sft_brk.map.r.pmem0.p1 -value "0" -text "" -state normal -variable mem_mapping(1)
    pack        .omsp_sft_brk.map.r.pmem0.p1 -side bottom  -padx 5 -pady {10 0} 
    radiobutton .omsp_sft_brk.map.r.pmem0.p0 -value "0" -text "" -state normal -variable mem_mapping(0)
    pack        .omsp_sft_brk.map.r.pmem0.p0 -side bottom  -padx 5 -pady {10 0} 
    label       .omsp_sft_brk.map.r.pmem0.l  -text "Program\nMemory 0" -anchor w
    pack        .omsp_sft_brk.map.r.pmem0.l  -side bottom  -padx 5 -pady {10 0} 

    frame       .omsp_sft_brk.map.r.pmem1
    pack        .omsp_sft_brk.map.r.pmem1    -side left -padx 5 -pady {0 20} -fill y
    radiobutton .omsp_sft_brk.map.r.pmem1.p3 -value "1" -text "" -state normal -variable mem_mapping(3)
    pack        .omsp_sft_brk.map.r.pmem1.p3 -side bottom  -padx 5 -pady {10 10} 
    radiobutton .omsp_sft_brk.map.r.pmem1.p2 -value "1" -text "" -state normal -variable mem_mapping(2)
    pack        .omsp_sft_brk.map.r.pmem1.p2 -side bottom  -padx 5 -pady {10 0} 
    radiobutton .omsp_sft_brk.map.r.pmem1.p1 -value "1" -text "" -state normal -variable mem_mapping(1)
    pack        .omsp_sft_brk.map.r.pmem1.p1 -side bottom  -padx 5 -pady {10 0} 
    radiobutton .omsp_sft_brk.map.r.pmem1.p0 -value "1" -text "" -state disable -variable mem_mapping(0)
    pack        .omsp_sft_brk.map.r.pmem1.p0 -side bottom  -padx 5 -pady {10 0} 
    label       .omsp_sft_brk.map.r.pmem1.l  -text "Program\nMemory 1" -anchor w
    pack        .omsp_sft_brk.map.r.pmem1.l  -side bottom  -padx 5 -pady {10 0} 
    
    frame       .omsp_sft_brk.map.r.pmem2
    pack        .omsp_sft_brk.map.r.pmem2    -side left -padx 5 -pady {0 20} -fill y
    radiobutton .omsp_sft_brk.map.r.pmem2.p3 -value "2" -text "" -state normal -variable mem_mapping(3)
    pack        .omsp_sft_brk.map.r.pmem2.p3 -side bottom  -padx 5 -pady {10 10} 
    radiobutton .omsp_sft_brk.map.r.pmem2.p2 -value "2" -text "" -state normal -variable mem_mapping(2)
    pack        .omsp_sft_brk.map.r.pmem2.p2 -side bottom  -padx 5 -pady {10 0} 
    radiobutton .omsp_sft_brk.map.r.pmem2.p1 -value "2" -text "" -state disable -variable mem_mapping(1)
    pack        .omsp_sft_brk.map.r.pmem2.p1 -side bottom  -padx 5 -pady {10 0} 
    radiobutton .omsp_sft_brk.map.r.pmem2.p0 -value "2" -text "" -state disable -variable mem_mapping(0)
    pack        .omsp_sft_brk.map.r.pmem2.p0 -side bottom  -padx 5 -pady {10 0} 
    label       .omsp_sft_brk.map.r.pmem2.l  -text "Program\nMemory 2" -anchor w
    pack        .omsp_sft_brk.map.r.pmem2.l  -side bottom  -padx 5 -pady {10 0} 
    
    frame       .omsp_sft_brk.map.r.pmem3
    pack        .omsp_sft_brk.map.r.pmem3    -side left -padx 5 -pady {0 20} -fill y
    radiobutton .omsp_sft_brk.map.r.pmem3.p3 -value "3" -text "" -state normal -variable mem_mapping(3)
    pack        .omsp_sft_brk.map.r.pmem3.p3 -side bottom  -padx 5 -pady {10 10} 
    radiobutton .omsp_sft_brk.map.r.pmem3.p2 -value "3" -text "" -state disable -variable mem_mapping(2)
    pack        .omsp_sft_brk.map.r.pmem3.p2 -side bottom  -padx 5 -pady {10 0} 
    radiobutton .omsp_sft_brk.map.r.pmem3.p1 -value "3" -text "" -state disable -variable mem_mapping(1)
    pack        .omsp_sft_brk.map.r.pmem3.p1 -side bottom  -padx 5 -pady {10 0} 
    radiobutton .omsp_sft_brk.map.r.pmem3.p0 -value "3" -text "" -state disable -variable mem_mapping(0)
    pack        .omsp_sft_brk.map.r.pmem3.p0 -side bottom  -padx 5 -pady {10 0} 
    label       .omsp_sft_brk.map.r.pmem3.l  -text "Program\nMemory 3" -anchor w
    pack        .omsp_sft_brk.map.r.pmem3.l  -side bottom  -padx 5 -pady {10 0} 

    # Create OK button
    button .omsp_sft_brk.okay -text "OK" -font {-weight bold}  -command {destroy .omsp_sft_brk}
    pack   .omsp_sft_brk.okay -side bottom -expand true -fill x -padx 5 -pady {0 10}

    # Update according to number of cores
    updateSoftBreakpoints
}

proc updateSoftBreakpoints  { } {

    global omsp_nr
    global breakSelect

    if {[winfo exists .omsp_sft_brk]} {
	if {$breakSelect==0} {
	    .omsp_sft_brk.map.r.core_nr.l0  configure -state normal
	    .omsp_sft_brk.map.r.pmem0.p0    configure -state normal
	    if {$omsp_nr < 2} {
		.omsp_sft_brk.map.r.core_nr.l1  configure -state disabled
		.omsp_sft_brk.map.r.pmem0.p1    configure -state disabled
		.omsp_sft_brk.map.r.pmem1.p1    configure -state disabled
	    } else {
		.omsp_sft_brk.map.r.core_nr.l1  configure -state normal
		.omsp_sft_brk.map.r.pmem0.p1    configure -state normal
		.omsp_sft_brk.map.r.pmem1.p1    configure -state normal
	    }

	    if {$omsp_nr < 3} {
		.omsp_sft_brk.map.r.core_nr.l2  configure -state disabled
		.omsp_sft_brk.map.r.pmem0.p2    configure -state disabled
		.omsp_sft_brk.map.r.pmem1.p2    configure -state disabled
		.omsp_sft_brk.map.r.pmem2.p2    configure -state disabled
	    } else {
		.omsp_sft_brk.map.r.core_nr.l2  configure -state normal
		.omsp_sft_brk.map.r.pmem0.p2    configure -state normal
		.omsp_sft_brk.map.r.pmem1.p2    configure -state normal
		.omsp_sft_brk.map.r.pmem2.p2    configure -state normal
	    }
	    
	    if {$omsp_nr < 4} {
		.omsp_sft_brk.map.r.core_nr.l3  configure -state disabled
		.omsp_sft_brk.map.r.pmem0.p3    configure -state disabled
		.omsp_sft_brk.map.r.pmem1.p3    configure -state disabled
		.omsp_sft_brk.map.r.pmem2.p3    configure -state disabled
		.omsp_sft_brk.map.r.pmem3.p3    configure -state disabled
	    } else {
		.omsp_sft_brk.map.r.core_nr.l3  configure -state normal
		.omsp_sft_brk.map.r.pmem0.p3    configure -state normal
		.omsp_sft_brk.map.r.pmem1.p3    configure -state normal
		.omsp_sft_brk.map.r.pmem2.p3    configure -state normal
		.omsp_sft_brk.map.r.pmem3.p3    configure -state normal
	    }
	} else {
	    .omsp_sft_brk.map.r.core_nr.l0  configure -state disabled
	    .omsp_sft_brk.map.r.pmem0.p0    configure -state disabled
	    .omsp_sft_brk.map.r.core_nr.l1  configure -state disabled
	    .omsp_sft_brk.map.r.pmem0.p1    configure -state disabled
	    .omsp_sft_brk.map.r.pmem1.p1    configure -state disabled
	    .omsp_sft_brk.map.r.core_nr.l2  configure -state disabled
	    .omsp_sft_brk.map.r.pmem0.p2    configure -state disabled
	    .omsp_sft_brk.map.r.pmem1.p2    configure -state disabled
	    .omsp_sft_brk.map.r.pmem2.p2    configure -state disabled
	    .omsp_sft_brk.map.r.core_nr.l3  configure -state disabled
	    .omsp_sft_brk.map.r.pmem0.p3    configure -state disabled
	    .omsp_sft_brk.map.r.pmem1.p3    configure -state disabled
	    .omsp_sft_brk.map.r.pmem2.p3    configure -state disabled
	    .omsp_sft_brk.map.r.pmem3.p3    configure -state disabled
	}
    }
}

proc setMemMapping {core0 core1 core2 core3} {

    global mem_mapping
    global omsp_nr

    set mem_mapping(0) $core0
    if {$omsp_nr > 1} {
	set mem_mapping(1) $core1
    }
    if {$omsp_nr > 2} {
	set mem_mapping(2) $core2
    }
    if {$omsp_nr > 3} {
	set mem_mapping(3) $core3
    }
}
