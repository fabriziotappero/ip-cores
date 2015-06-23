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
# File Name:   dbg_uart_generic.tcl
#
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#
#----------------------------------------------------------------------------------
# $Rev: 158 $
# $LastChangedBy: olivier.girard $
# $LastChangedDate: 2012-10-15 23:49:09 +0200 (Mon, 15 Oct 2012) $
#----------------------------------------------------------------------------------
#
# Description:
#
#     Generic UART utility functions for the openMSP430 serial debug interface.
#
#     Mandatory Public functions:
#
#         - uart_generic::dbg_open           (Device,  Baudrate)
#         - uart_generic::dbg_connect        (CpuAddr)
#         - uart_generic::dbg_rd             (CpuAddr, RegisterName)
#         - uart_generic::dbg_wr             (CpuAddr, RegisterName, Data)
#         - uart_generic::dbg_burst_rx       (CpuAddr, Format,       Length)
#         - uart_generic::dbg_burst_tx       (CpuAddr, Format,       DataList)
#         - uart_generic::get_allowed_speeds ()
#
#
#     Private functions:
#
#         - uart::dbg_format_cmd             (RegisterName, Action)
# 
#----------------------------------------------------------------------------------
namespace eval uart_generic {

    #=============================================================================#
    # Source required libraries                                                   #
    #=============================================================================#

    set     scriptDir [file dirname [info script]]
    source $scriptDir/dbg_utils.tcl


    #=============================================================================#
    # uart_generic::dbg_open (Device, Baudrate)                                   #
    #-----------------------------------------------------------------------------#
    # Description: Open and configure the UART connection.                        #
    # Arguments  : Device   - Serial port device (i.e. /dev/ttyS0 or COM2:)       #
    #              Baudrate - UART communication speed.                           #
    # Result     : 0 if error, 1 otherwise.                                       #
    #=============================================================================#
    proc dbg_open {Device Baudrate} {
    
	# Open UART interface
	if {![utils::uart_open $Device 1 $Baudrate]} {
	    return 0
	}

        return 1
    }


    #=============================================================================#
    # uart_generic::dbg_connect (CpuAddr)                                         #
    #-----------------------------------------------------------------------------#
    # Description: Send the synchronization frame in order to connect with the    #
    #              openMSP430 core.                                               #
    # Arguments  : CpuAddr - Unused argument for the UART interface (I2C only).   #
    # Result     : 0 if error, 1 otherwise.                                       #
    #=============================================================================#
    proc dbg_connect {CpuAddr} {
    
	# Send synchronisation frame
	utils::uart_tx {0x80}
	after 100
        
	# Send dummy frame in case the debug interface is already synchronized
	utils::uart_tx {0xC0}
	utils::uart_tx {0x00}

        return 1
    }


    #=============================================================================#
    # uart_generic::dbg_rd (CpuAddr, RegisterName)                                #
    #-----------------------------------------------------------------------------#
    # Description: Read the specified debug register.                             #
    # Arguments  : CpuAddr      - Unused for the UART interface (I2C only).       #
    #              RegisterName - Name of the register to be read.                #
    # Result     : Register content, in hexadecimal.                              #
    #=============================================================================#
    proc dbg_rd {CpuAddr RegisterName} {

        # Send command frame
        set cmd [dbg_format_cmd $RegisterName RD]
        utils::uart_tx $cmd

        # Compute size of data to be received
        if [string eq [expr 0x40 & $cmd] 64] {
            set format 1
            set length 1
        } else {
            set format 0
            set length 2
        }

        # Receive data
        set rx_data [utils::uart_rx $format $length]

        return $rx_data
    }

    #=============================================================================#
    # uart_generic::dbg_wr (CpuAddr, RegisterName, Data)                          #
    #-----------------------------------------------------------------------------#
    # Description: Write to the specified debug register.                         #
    # Arguments  : CpuAddr      - Unused for the UART interface (I2C only).       #
    #              RegisterName - Name of the register to be written.             #
    #              Data         - Data to be written.                             #
    # Result     : 0 if error, 1 otherwise.                                       #
    #=============================================================================#
    proc dbg_wr {CpuAddr RegisterName Data} {
        
        # Send command frame
        set cmd [dbg_format_cmd $RegisterName WR]
        utils::uart_tx $cmd

        # Format input data
        if {![regexp {0x} $Data match]} {
            set Data [format "0x%x" $Data]
        }
        set hex_val [format %04x $Data]
        regexp {(..)(..)} $hex_val match hex_msb hex_lsb

        # Compute size of data to be sent
        if [string eq [expr 0x40 & $cmd] 64] {
            set size 1
        } else {
            set size 2
        }

        # Send data
        utils::uart_tx "0x$hex_lsb"
        if {$size==2} {
            utils::uart_tx "0x$hex_msb"
        }

        return 1
    }

    #=============================================================================#
    # uart_generic::dbg_burst_rx (CpuAddr, Format, Length)                        #
    #-----------------------------------------------------------------------------#
    # Description: Receive data list as burst from the serial debug interface.    #
    # Arguments  : CpuAddr  - Unused for the UART interface (I2C only).           #
    #              Format   - 0 format as 16 bit word, 1 format as 8 bit word.    #
    #              Length   - Number of byte to be received.                      #
    # Result     : 0 if error, 1 otherwise.                                       #
    #=============================================================================#
    proc dbg_burst_rx {CpuAddr Format Length} {

        return [utils::uart_rx $Format $Length]

    }

    #=============================================================================#
    # uart_generic::dbg_burst_tx (CpuAddr, Format, DataList)                      #
    #-----------------------------------------------------------------------------#
    # Description: Transmit data list as burst to the serial debug interface.     #
    # Arguments  : CpuAddr   - Unused for the UART interface (I2C only).          #
    #              Format    - 0 format as 16 bit word, 1 format as 8 bit word.   #
    #              DataList  - List of data to be written (in hexadecimal).       #
    # Result     : 0 if error, 1 otherwise.                                       #
    #=============================================================================#
    proc dbg_burst_tx {CpuAddr Format DataList} {

        foreach data [split $DataList] {

	    if {$Format==1} {                 ####  8-bit data format ####
		# Format data
		set data [format %02x $data]

		# Send data
		utils::uart_tx "0x$data"

	    } else {                          #### 16-bit data format ####
		# Format data
		set data [format %04x $data]
		regexp {(..)(..)} $data match data_msb data_lsb

		# Send data
		utils::uart_tx "0x$data_lsb 0x$data_msb"
	    }
	}
    }

    #=============================================================================#
    # uart_generic::get_allowed_speeds ()                                         #
    #-----------------------------------------------------------------------------#
    # Description: Return the list of allowed UART baudrates.                     #
    #=============================================================================#
    proc get_allowed_speeds {} {

	#             Editable    Default             UART-Baudrates
        return [list     1        115200      [list          9600          \
                                                            19200          \
                                                            38400          \
                                                            57600          \
                                                           115200          \
                                                           230400          \
                                                           460800          \
                                                           500000          \
                                                           576000          \
                                                           921600          \
                                                          1000000          \
                                                          1152000          \
                                                          2000000]         ]
    }

###################################################################################################
###################################################################################################
###################################################################################################
###################################################################################################
#######                                                                                     #######
#######                             PRIVATE FUNCTIONS                                       #######
#######                                                                                     #######
###################################################################################################
###################################################################################################
###################################################################################################
###################################################################################################

    #=============================================================================#
    # uart_generic::dbg_format_cmd (RegisterName, Action)                         #
    #-----------------------------------------------------------------------------#
    # Description: Get the correcponding UART command to a given debug register   #
    #              access.                                                        #
    # Arguments  : RegisterName - Name of the register to be accessed.            #
    #              Action       - RD for read / WR for write.                     #
    # Result     : Command to be sent via UART.                                   #
    #=============================================================================#
    proc dbg_format_cmd {RegisterName Action} {

        switch -exact $Action {
            RD         {set rd_wr "0x00"}
            WR         {set rd_wr "0x080"}
            default    {set rd_wr "0x00"}
        }

        switch -exact $RegisterName {
            CPU_ID_LO  {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x00]]}
            CPU_ID_HI  {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x01]]}
            CPU_CTL    {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x02]]}
            CPU_STAT   {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x03]]}
            MEM_CTL    {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x04]]}
            MEM_ADDR   {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x05]]}
            MEM_DATA   {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x06]]}
            MEM_CNT    {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x07]]}
            BRK0_CTL   {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x08]]}
            BRK0_STAT  {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x09]]}
            BRK0_ADDR0 {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x0A]]}
            BRK0_ADDR1 {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x0B]]}
            BRK1_CTL   {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x0C]]}
            BRK1_STAT  {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x0D]]}
            BRK1_ADDR0 {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x0E]]}
            BRK1_ADDR1 {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x0F]]}
            BRK2_CTL   {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x10]]}
            BRK2_STAT  {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x11]]}
            BRK2_ADDR0 {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x12]]}
            BRK2_ADDR1 {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x13]]}
            BRK3_CTL   {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x14]]}
            BRK3_STAT  {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x40 | 0x15]]}
            BRK3_ADDR0 {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x16]]}
            BRK3_ADDR1 {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x17]]}
            CPU_NR     {set uart_cmd  [format "0x%02x" [expr $rd_wr | 0x00 | 0x18]]}
            default    {set uart_cmd  "0x00"}
        }

        return $uart_cmd
    }

}
