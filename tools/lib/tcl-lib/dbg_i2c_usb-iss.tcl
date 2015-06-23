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
# File Name:   dbg_uart_i2c-iss.tcl
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
#     Some I2C utility functions for the openMSP430 serial debug interface
#     using the USB-ISS adapter.
#
#     Mandatory Public functions:
#
#         - i2c_usb-iss::dbg_open           (Device,  OperatingMode)
#         - i2c_usb-iss::dbg_connect        (CpuAddr)
#         - i2c_usb-iss::dbg_rd             (CpuAddr, RegisterName)
#         - i2c_usb-iss::dbg_wr             (CpuAddr, RegisterName, Data)
#         - i2c_usb-iss::dbg_burst_rx       (CpuAddr, Format,       Length)
#         - i2c_usb-iss::dbg_burst_tx       (CpuAddr, Format,       DataList)
#         - i2c_usb-iss::get_allowed_speeds ()
#
#
#     Private functions:
#
#         - i2c_usb-iss::i2c_mode           (OperatingMode)
#         - i2c_usb-iss::dbg_format_cmd     (RegisterName, Action)
#         - i2c_usb-iss::ISS_VERSION        ()
#         - i2c_usb-iss::GET_SER_NUM        ()
#         - i2c_usb-iss::ISS_MODE           (OperatingMode)
#         - i2c_usb-iss::SETPINS            (IO1, IO2, IO3, IO4)
#         - i2c_usb-iss::GETPINS            ()
# 
#----------------------------------------------------------------------------------
namespace eval i2c_usb-iss {

    #=============================================================================#
    # Source required libraries                                                   #
    #=============================================================================#

    set     scriptDir [file dirname [info script]]
    source $scriptDir/dbg_utils.tcl


    #=============================================================================#
    # i2c_usb-iss::dbg_open (Device, Baudrate)                                    #
    #-----------------------------------------------------------------------------#
    # Description: Open and configure the UART connection.                        #
    #              Attach and configure the USB-ISS adapter.                      #
    # Arguments  : Device        - Serial port device (i.e. /dev/ttyS0 or COM2:)  #
    #              OperatingMode - Name of the I2C operating mode.                #
    # Result     : 0 if error, 1 otherwise.                                       #
    #=============================================================================#
    proc dbg_open {Device OperatingMode} {
    
        # Open UART interface
        if {![utils::uart_open $Device 0 115200]} {
            return 0
        }

        # Check the ISS-VERSION command on the adapter
        if {[lindex [ISS_VERSION] 0]=="0"} {
            return 0
        }

        # Get operating mode value
        set op_mode [i2c_mode $OperatingMode]

        # Configure the USB-ISS adaptor for I2C communication
        #                       IO_MODE+I2C      IO_TYPE
        if {![ISS_MODE [list      $op_mode        0x00]]} {
            return 0
        }

        # Clear IO pins to make sure the Serial debug interface is under reset
        SETPINS 0 0 0 0
        after 100

        return 1
    }


    #=============================================================================#
    # i2c_usb-iss::dbg_connect (CpuAddr)                                          #
    #-----------------------------------------------------------------------------#
    # Description: In case the serial debug interface enable signal is connected  #
    #              to the I/O 1 or I/O 2 port, this function will enable it.      #
    # Arguments  : CpuAddr - Unused argument.                                     #
    # Result     : 0 if error, 1 otherwise.                                       #
    #=============================================================================#
    proc dbg_connect {CpuAddr} {
    
        # Make sure the Serial debug interface is still under reset
        SETPINS 0 0 0 0
        after 100

        # Enable the Serial debug interface
        SETPINS 1 1 1 1
        after 100

        return 1
    }


    #=============================================================================#
    # i2c_usb-iss::dbg_rd (CpuAddr, RegisterName)                                 #
    #-----------------------------------------------------------------------------#
    # Description: Read the specified debug register.                             #
    # Arguments  : CpuAddr      - I2C address of the target CPU.                  #
    #              RegisterName - Name of the register to be read.                #
    # Result     : Register content, in hexadecimal.                              #
    #=============================================================================#
    proc dbg_rd {CpuAddr RegisterName} {

        # Send command frame
        set cmd [dbg_format_cmd $RegisterName RD]

        # Word or Byte register
        set isByte [string eq [expr 0x40 & $cmd] 64]

        # Compute device frame (address+WR/RD)
        set DeviceFrameWR [format "0x%02x" [expr $CpuAddr*2+0]]
        set DeviceFrameRD [format "0x%02x" [expr $CpuAddr*2+1]]

        # Send command frame:   I2C_DIRECT  I2C_START  I2C_WRITE2   DEVICE_ADDRESS+WR   DATA   STOP
        utils::uart_tx [concat    0x57        0x01       0x31      $DeviceFrameWR      $cmd   0x03]

	set response [utils::uart_rx 1 2]
	if {[lindex $response 0] == 0x00} {
	    puts "I2C ERROR: $response"
	    return "0x"
	}

        if {$isByte} {
            # Read data:          I2C_DIRECT  I2C_START  I2C_WRITE1   DEVICE_ADDRESS+RD    NACK     READ1   STOP
            utils::uart_tx [concat    0x57        0x01       0x30        $DeviceFrameRD    0x04     0x20    0x03]
        } else {
            # Read data:          I2C_DIRECT  I2C_START  I2C_WRITE1   DEVICE_ADDRESS+RD    READ1    NACK    READ1   STOP
            utils::uart_tx [concat    0x57        0x01       0x30        $DeviceFrameRD    0x20     0x04    0x20    0x03]
        }
	set response [utils::uart_rx 1 2]
	if {[lindex $response 0] == 0x00} {
	    puts "I2C ERROR: $response"
	    return "0x"
	}

        # Compute size of data to be received
        if {$isByte} {
            set format 1
            set length 1
        } else {
            set format 0
            set length 2
        }

        # Receive data
	set rx_data [utils::uart_rx $format [expr $length]]

        return $rx_data
    }

    #=============================================================================#
    # i2c_usb-iss::dbg_wr (CpuAddr, RegisterName, Data)                           #
    #-----------------------------------------------------------------------------#
    # Description: Write to the specified debug register.                         #
    # Arguments  : CpuAddr      - I2C address of the target CPU.                  #
    #              RegisterName - Name of the register to be written.             #
    #              Data         - Data to be written.                             #
    # Result     : 0 if error, 1 otherwise.                                       #
    #=============================================================================#
    proc dbg_wr {CpuAddr RegisterName Data} {
        
        # Send command frame
        set cmd [dbg_format_cmd $RegisterName WR]

        # Word or Byte register
        set isByte [string eq [expr 0x40 & $cmd] 64]

        # Compute device frame (address+WR/RD)
        set DeviceFrameWR [format "0x%02x" [expr $CpuAddr*2+0]]
        set DeviceFrameRD [format "0x%02x" [expr $CpuAddr*2+1]]

        # Send command frame:   I2C_DIRECT  I2C_START  I2C_WRITE2   DEVICE_ADDRESS+WR   DATA   STOP
        utils::uart_tx [concat    0x57        0x01       0x31      $DeviceFrameWR      $cmd   0x03]

	set response [utils::uart_rx 1 2]
	if {[lindex $response 0] == 0x00} {
	    puts "I2C ERROR: $response"
	    return 0
	}

        # Format input data
        if {![regexp {0x} $Data match]} {
            set Data [format "0x%x" $Data]
        }
        set hex_val [format %04x $Data]
        regexp {(..)(..)} $hex_val match hex_msb hex_lsb

        if {$isByte} {
            # Read data:          I2C_DIRECT  I2C_START  I2C_WRITE2   DEVICE_ADDRESS+WR      DATA      STOP
            utils::uart_tx [concat    0x57        0x01       0x31       $DeviceFrameWR   "0x$hex_lsb"  0x03]
        } else {
            # Read data:          I2C_DIRECT  I2C_START  I2C_WRITE1   DEVICE_ADDRESS+WR    DATA_LSB      DATA_MSB      STOP
            utils::uart_tx [concat    0x57        0x01       0x32       $DeviceFrameWR   "0x$hex_lsb"   "0x$hex_msb"   0x03]
        }
	set response [utils::uart_rx 1 2]
	if {[lindex $response 0] == 0x00} {
	    puts "I2C ERROR: $response"
	    return 0
	}

        return 1
    }

    #=============================================================================#
    # i2c_usb-iss::dbg_burst_rx (CpuAddr, Format, Length)                         #
    #-----------------------------------------------------------------------------#
    # Description: Receive data list as burst from the serial debug interface.    #
    # Arguments  : CpuAddr  - I2C address of the target CPU.                      #
    #              Format   - 0 format as 16 bit word, 1 format as 8 bit word.    #
    #              Length   - Number of byte to be received.                      #
    # Result     : 0 if error, 1 otherwise.                                       #
    #=============================================================================#
    proc dbg_burst_rx {CpuAddr Format Length} {

        # Compute device frame (address+WR/RD)
        set DeviceFrameWR [format "0x%02x" [expr $CpuAddr*2+0]]
        set DeviceFrameRD [format "0x%02x" [expr $CpuAddr*2+1]]

	set rx_data ""
	while { $Length > 0 } {

	    # Maximum frame length is 16 bytes
	    if       {$Length >= 16} {set rxLength 16
	    } else                   {set rxLength $Length}

	    # Compute I2C read command
	    set readCmd [format "0x%x" [expr $rxLength + 0x1f - 1]]

	    if {$readCmd == "0x1f"} {
		# Read data:          I2C_DIRECT  I2C_START  I2C_WRITE1   DEVICE_ADDRESS+RD              NACK   READ1  STOP
		utils::uart_tx [concat    0x57        0x01       0x30        $DeviceFrameRD              0x04   0x20   0x03]
	    } else {
		# Read data:          I2C_DIRECT  I2C_START  I2C_WRITE1   DEVICE_ADDRESS+RD     READxx   NACK   READ1  STOP
		utils::uart_tx [concat    0x57        0x01       0x30        $DeviceFrameRD    $readCmd  0x04   0x20   0x03]
	    }

	    set response [utils::uart_rx 1 2]
	    if {[lindex $response 0] == 0x00} {
		puts "I2C ERROR: $response"
		return 0
	    }

	    # Receive data
	    set rx_data [concat $rx_data [utils::uart_rx $Format [expr $rxLength]]]
	    
	    # Remaining bytes to be received
	    set Length [expr $Length - $rxLength]
	}

        return $rx_data
    }


    #=============================================================================#
    # i2c_usb-iss::dbg_burst_tx (CpuAddr, Format, DataList)                       #
    #-----------------------------------------------------------------------------#
    # Description: Transmit data list as burst to the serial debug interface.     #
    # Arguments  : CpuAddr   - I2C address of the target CPU.                     #
    #              Format    - 0 format as 16 bit word, 1 format as 8 bit word.   #
    #              DataList  - List of data to be written (in hexadecimal).       #
    # Result     : 0 if error, 1 otherwise.                                       #
    #=============================================================================#
    proc dbg_burst_tx {CpuAddr Format DataList} {

        # Compute device frame (address+WR/RD)
        set DeviceFrameWR [format "0x%02x" [expr $CpuAddr*2+0]]
        set DeviceFrameRD [format "0x%02x" [expr $CpuAddr*2+1]]

	#----------------------------------------
	# Format the list of bytes to be sent
	#----------------------------------------
	set tx_data ""
        foreach data [split $DataList] {

            if {$Format==1} {                 ####  8-bit data format ####
                # Format data
                set data [format %02x $data]

                # Add data to list
                set tx_data [concat $tx_data "0x$data"]

            } else {                          #### 16-bit data format ####
                # Format data
                set data [format %04x $data]
                regexp {(..)(..)} $data match data_msb data_lsb

                # Add data to list
                set tx_data [concat $tx_data "0x$data_lsb 0x$data_msb"]
            }
        }

	#----------------------------------------
	# Send the list of bytes over I2C
	#----------------------------------------
	set Length [llength $tx_data]

	while { $Length > 0 } {

	    # Maximum frame length is 16 bytes
	    if       {$Length >= 16} {set txLength 16
	    } else                   {set txLength $Length}

	    # Compute I2C write command
	    set writeCmd [format "0x%x" [expr $txLength + 0x2f]]

	    # Get the data from the list and remove it from there
	    set hex_data [lrange   $tx_data 0 [expr $txLength-1]]
	    set tx_data  [lreplace $tx_data 0 [expr $txLength-1]]

	    # Read data:          I2C_DIRECT  I2C_START  I2C_WRITE1   DEVICE_ADDRESS+WR     WRITExx     DATA       STOP
	    utils::uart_tx [concat    0x57        0x01       0x30        $DeviceFrameWR    $writeCmd  $hex_data    0x03]

	    set response [utils::uart_rx 1 2]
	    if {[lindex $response 0] == 0x00} {
		puts "I2C ERROR: $response"
		return 0
	    }
	    
	    # Remaining bytes to be received
	    set Length [expr $Length - $txLength]
	}

    }

    #=============================================================================#
    # i2c_usb-iss::get_allowed_speeds ()                                          #
    #-----------------------------------------------------------------------------#
    # Description: Return the list of allowed I2C configuration modes.            #
    #=============================================================================#
    proc get_allowed_speeds {} {

	#             Not-Editable    Default              I2C-Operating-Modes
        return [list        0        I2C_S_100KHZ    [list     I2C_S_20KHZ        \
                                                               I2C_S_50KHZ        \
                                                               I2C_S_100KHZ       \
                                                               I2C_S_400KHZ       \
                                                               I2C_H_100KHZ       \
                                                               I2C_H_400KHZ       \
                                                               I2C_H_1000KHZ]     ]
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
    # i2c_usb-iss::i2c_mode (OperatingMode)                                       #
    #-----------------------------------------------------------------------------#
    # Description: Get the correcponding hexadecimal value for a given I2C mode.  #
    # Arguments  : OperatingMode - Name of the I2C operating mode.                #
    # Result     : Command to be sent via UART.                                   #
    #=============================================================================#
    proc i2c_mode {OperatingMode} {

        switch -exact $OperatingMode {
            I2C_S_20KHZ    {set op_mode "0x20"}
            I2C_S_50KHZ    {set op_mode "0x30"}
            I2C_S_100KHZ   {set op_mode "0x40"}
            I2C_S_400KHZ   {set op_mode "0x50"}
            I2C_H_100KHZ   {set op_mode "0x60"}
            I2C_H_400KHZ   {set op_mode "0x70"}
            I2C_H_1000KHZ  {set op_mode "0x80"}
            default        {set op_mode "0x40"}
        }

        return $op_mode
    }

    #=============================================================================#
    # i2c_usb-iss::dbg_format_cmd (RegisterName, Action)                          #
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


    #=============================================================================#
    # i2c_usb-iss::ISS_VERSION ()                                                 #
    #-----------------------------------------------------------------------------#
    # Description:  Will return three bytes.                                      #
    #               The first is the Module ID, this will always be 7.            #
    #               The second byte is the firmware revision number.              #
    #               The third byte is the current operating mode.                 #
    #=============================================================================#
    proc ISS_VERSION {} {

        # Send ISS-VERSION command to the adapter
        utils::uart_tx [list 0x5A 0x01]

        # Make sure 3 bytes are then received (the first one must be 0x07)
        set iss_version [utils::uart_rx 1 3]
        if {([lindex $iss_version 0] != "0x07") |
            ([lindex $iss_version 1] == "0x")   |
            ([lindex $iss_version 2] == "0x")} {
            return [list 0 0 0]
        }
        return $iss_version
    }

    #=============================================================================#
    # i2c_usb-iss::GET_SER_NUM ()                                                 #
    #-----------------------------------------------------------------------------#
    # Description:  Will return the modules unique 8 byte USB serial number.      #
    #=============================================================================#
    proc GET_SER_NUM {} {

        # Send GET_SER_NUM command to the adapter
        utils::uart_tx [list 0x5A 0x03]

        # Get the 8 bytes
        set serial_number [utils::uart_rx 1 8]

        return $serial_number
    }

    #=============================================================================#
    # i2c_usb-iss::ISS_MODE (OperatingMode)                                       #
    #-----------------------------------------------------------------------------#
    # Description:  Sets the operating mode.                                      #
    #               This sets up the modules I/O pins and hardware for the        #
    #               required mode.                                                #
    #               There are 4 operating modes (I2C, SPI, Serial and I/O) some   #
    #               which can be combined.                                        #
    #               See online documentation for more info:                       #
    #                    http://www.robot-electronics.co.uk/htm/usb_iss_tech.htm  #
    #=============================================================================#
    proc ISS_MODE {OperatingMode} {


        # Send the ISS_MODE command:
        #                             ISS_CMD   ISS_MODE     OPERATION_MODE+REMAINING
        utils::uart_tx [concat [list   0x5A       0x02  ]       $OperatingMode       ]

        # Get the 2 byte response
        set config_response [utils::uart_rx 1 2]
        if {$config_response != [list 0xff 0x00]} {
            return 0
        }
        return 1
    }

    #=============================================================================#
    # i2c_usb-iss::SETPINS (IO1, IO2, IO3, IO4)                                   #
    #-----------------------------------------------------------------------------#
    # Description:  The SETPINS command only operates on pins that have been set  #
    #               as output pins.                                               #
    #               Digital or analogue input pins, or pins that are used for I2C #
    #               or serial are not affected.                                   #
    #=============================================================================#
    proc SETPINS {IO1 IO2 IO3 IO4} {

        # Get the hex value for IO configuration
        set io_config [format "0x0%x" [expr $IO1+($IO2*2)+($IO3*4)+($IO4*8)]]

        # Send the SETPINS command to the adaptor
        utils::uart_tx  [list  0x63   $io_config]

        # Get the 1 byte response
        set config_response [utils::uart_rx 1 1]
        if {$config_response != "0xff"} {
            return 0
        }
        return 1
    }

    #=============================================================================#
    # i2c_usb-iss::GETPINS ()                                                     #
    #-----------------------------------------------------------------------------#
    # Description:  This is used to get the current state of all digital I/O pins #
    #=============================================================================#
    proc GETPINS {} {

        # Send the GETPINS command to the adaptor
        utils::uart_tx  0x64

        # Get the 1 byte response
        set config_response [utils::uart_rx 1 1]
        if {$config_response == "0x"} {
            return 0
        }

        # Get the hex value for IO configuration
        set IO4 [expr ($config_response & 0x08)/8]
        set IO3 [expr ($config_response & 0x04)/4]
        set IO2 [expr ($config_response & 0x02)/2]
        set IO1 [expr ($config_response & 0x01)/1]

        return [list $IO1 $IO2 $IO3 $IO4]
    }

}
