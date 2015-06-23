#----------------------------------------------------------------------------------
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
#----------------------------------------------------------------------------------
# 
# File Name:   dbg_utils.tcl
#
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#
#----------------------------------------------------------------------------------
# $Rev: 133 $
# $LastChangedBy: olivier.girard $
# $LastChangedDate: 2012-03-22 21:28:26 +0100 (Thu, 22 Mar 2012) $
#----------------------------------------------------------------------------------
#
# Description:
#
#     Basic utility functions for UART communication.
#
#     Public functions:
#
#         - utils::uart_port_list  ()
#         - utils::uart_open       (Device,       Baudrate)
#         - utils::uart_tx         (Data)
#         - utils::uart_rx         (Format,       Length)
# 
#----------------------------------------------------------------------------------
namespace eval utils {

    global serial_ch

    #=============================================================================#
    # utils::uart_port_list ()                                                    #
    #-----------------------------------------------------------------------------#
    # Description: Return the available serial ports (works on both linux and     #
    #              windows.                                                       #
    # Arguments  : None.                                                          #
    # Result     : List of the available serial ports.                            #
    #=============================================================================#
    proc uart_port_list {} {

        set serial_ports ""

        switch $::tcl_platform(os) {
            {Linux}      {
                          set dmesg        ""
                          catch {exec dmesg} dmesg
                          while {[regexp {ttyS\d+?} $dmesg match]} {
			      regsub $match $dmesg {} dmesg
			      if { [lsearch -exact $serial_ports "/dev/$match"] == -1 } {
				  lappend serial_ports "/dev/$match"
			      }
			  }
                          while {[regexp {ttyACM\d+?} $dmesg match]} {
			      regsub $match $dmesg {} dmesg
			      if { [lsearch -exact $serial_ports "/dev/$match"] == -1 } {
				  lappend serial_ports "/dev/$match"
			      }
			  }
                          while {[regexp {ttyUSB\d+?} $dmesg match]} {
			      regsub $match $dmesg {} dmesg
			      if { [lsearch -exact $serial_ports "/dev/$match"] == -1 } {
				  lappend serial_ports "/dev/$match"
			      }
			  }
                          if {![llength $serial_ports]} {
			      set serial_ports [list /dev/ttyS0 /dev/ttyS1 /dev/ttyS2 /dev/ttyS3]
			  }
                         }
            {Windows NT} {
                          package require registry
                          set serial_base "HKEY_LOCAL_MACHINE\\HARDWARE\\DEVICEMAP\\SERIALCOMM"
                          set values [registry values $serial_base]
                          foreach valueName $values {
			      lappend serial_ports "[registry get $serial_base $valueName]:"
			  }
                          }
            default       {set serial_ports ""}
        }

        return $serial_ports
    }

    #=============================================================================#
    # utils::uart_open (Device, Baudrate)                                         #
    #-----------------------------------------------------------------------------#
    # Description: Open and configure the UART connection.                        #
    # Arguments  : Device    - Serial port device (i.e. /dev/ttyS0 or COM2:)      #
    #              Configure - Configure serial communication (1:UART/0:I2C)      #
    #              Baudrate  - UART communication speed.                          #
    # Result     : 0 if error, 1 otherwise.                                       #
    #=============================================================================#
    proc uart_open {Device Configure Baudrate} {
    
        global serial_ch

	# Open device for reading and writing
	if {[catch {open $Device RDWR} serial_ch]} {
	    return 0
	}
 
	if {$Configure} {
	    # Setup the baud rate
	    fconfigure $serial_ch -mode "$Baudrate,n,8,1"
            
	    # Block on read, don't buffer output
	    fconfigure $serial_ch -blocking 1 -buffering none -translation binary -timeout 1000

	} else {
	    fconfigure $serial_ch                             -translation binary
	}

	return 1
    }

    #=============================================================================#
    # utils::uart_tx (Data)                                                       #
    #-----------------------------------------------------------------------------#
    # Description: Transmit data over the serial debug interface.                 #
    # Arguments  : Data    - Data byte list to be sent.                           #
    # Result     : 0 if error, 1 otherwise.                                       #
    #=============================================================================#
    proc uart_tx {Data} {
        
        global serial_ch
        set allchar ""
	# Format data
        foreach char [split $Data] {
	    append allchar [format %02x $char]
        }
        # Send data
#        puts "TX: $allchar"
        puts -nonewline $serial_ch [binary format H* $allchar]
        flush $serial_ch

        return 1
    }

    #=============================================================================#
    # utils::uart_rx (Format, Length)                                             #
    #-----------------------------------------------------------------------------#
    # Description: Receive data from the serial debug interface.                  #
    # Arguments  : Format   - 0 format as 16 bit word, 1 format as 8 bit word.    #
    #              Length   - Number of bytes to be received.                     #
    # Result     : List of received values, in hexadecimal.                       #
    #=============================================================================#
    proc uart_rx {Format Length} {
        
        global serial_ch
        
        if { [catch {read $serial_ch $Length} rx_data] } {
            
            set hex_data "0000"
        } else {
            set hex_data ""
            foreach char [split $rx_data {}] {
                binary scan $char H* hex_char
                lappend hex_data $hex_char
            }
        }
#        puts "RX: $hex_data"
        # Format data
        if {$Format==0} {
            set num_byte 2
        } else {
            set num_byte 1
        }
        set formated_data ""
        for {set i 0} {$i<[expr $Length/$num_byte]} {incr i} {
        
            set data ""
            for {set j $num_byte} {$j>0} {set j [expr $j-1]} {
                append data [lindex $hex_data [expr ($i*$num_byte)+$j-1]]
            }
            lappend formated_data "0x$data"
        }

        return $formated_data
    }

}
