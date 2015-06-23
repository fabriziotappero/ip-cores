#-----------------------------------------------------------------------------------------------------------
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
#-----------------------------------------------------------------------------------------------------------
# 
# File Name:   dbg_functions.tcl
#
# Author(s):
#             - Olivier Girard,    olgirard@gmail.com
#
#-----------------------------------------------------------------------------------------------------------
# $Rev: 172 $
# $LastChangedBy: olivier.girard $
# $LastChangedDate: 2012-12-28 00:06:56 +0100 (Fri, 28 Dec 2012) $
#-----------------------------------------------------------------------------------------------------------
#
# Description: Main utility functions for the openMSP430 serial debug
#             interface.
#
#       The following functions are implemented according to the SLAA149
#     application report from TI (Programming a Flash-Based MSP430 Using the
#     JTAG Interface):
#
#               - GetDevice       (CpuNr)
#               - ReleaseDevice   (CpuNr, Addr)
#               - ExecutePOR      (CpuNr)
#               - SetPC           (CpuNr, Addr)
#               - HaltCPU         (CpuNr)
#               - ReleaseCPU      (CpuNr)
#               - WriteMem        (CpuNr, Format,    Addr,     Data)
#               - WriteMemQuick   (CpuNr, StartAddr, DataList)
#               - ReadMem         (CpuNr, Format,    Addr)
#               - ReadMemQuick    (CpuNr, StartAddr, Length)
#               - VerifyMem       (CpuNr, StartAddr, DataList)
#
#
#       The following have been added:
#
#               - ExecutePOR_Halt (CpuNr)
#               - GetCPU_ID       (CpuNr)
#               - GetCPU_ID_SIZE  (CpuNr)
#               - VerifyCPU_ID    (CpuNr)
#               - WriteReg        (CpuNr, Addr,      Data)
#               - WriteRegAll     (CpuNr, DataList)
#               - ReadReg         (CpuNr, Addr)
#               - ReadRegAll      (CpuNr)
#               - WriteMemQuick8  (CpuNr, StartAddr, DataList)
#               - ReadMemQuick8   (CpuNr, StartAddr, Length)
#               - StepCPU         (CpuNr)
#               - EraseRAM        (CpuNr)
#               - EraseROM        (CpuNr)
#               - InitBreakUnits  (CpuNr)
#               - SetHWBreak      (CpuNr, Type, Addr,      Rd,       Wr)
#               - ClearHWBreak    (CpuNr, Type, Addr)
#               - IsHalted        (CpuNr)
#               - ClrStatus       (CpuNr)
#               - GetChipAlias    (CpuNr)
#               - GetAllowedSpeeds()
# 
#-----------------------------------------------------------------------------------------------------------

#==========================================================================================================#
# GLOBAL VARIABLES: OMSP_CONF
#-----------------------------------------------------------------------------------------------------------
#
# The global conifugration array variable is meant to be initialized by the higher level
# programs prior the "GetDevice" call.
#
#  omsp_conf(interface)                     ->  Debug interface type: "uart" or "i2c_usb-iss"
#  omsp_conf(device)                        ->  Serial port device (i.e. /dev/ttyS0 or COM2:)
#  omsp_conf(baudrate)                      ->  UART communication speed
#  omsp_conf(<cpu_nr>,cpuaddr)              ->  Address of the core <cpu_nr> (i.e. I2C device address)
#
#==========================================================================================================#
global omsp_conf

# Initialize to default values
set omsp_conf(interface)       uart_generic
set omsp_conf(device)          /dev/ttyUSB0
set omsp_conf(baudrate)        9600
for {set i 0} {$i<128} {incr i} {
    set omsp_conf($i,cpuaddr) 0
}


#==========================================================================================================#
# GLOBAL VARIABLES: OMSP_INFO
#-----------------------------------------------------------------------------------------------------------
#
# This array variable is updated by the "GetDevice" procedure when the connection is built
# with the oMSP core.
# The array is structured as following:
#
#  omsp_info(connected)                     ->  Main Physical connection is active
#  omsp_info(<cpu_nr>,connected)            ->  Connection to CPU <cpu_nr> is active
#  omsp_info(<cpu_nr>,hw_break)             ->  Number of hardware breakpoints
#  omsp_info(<cpu_nr>,cpu_ver)              ->  From CPU_ID  : CPU Version
#  omsp_info(<cpu_nr>,user_ver)             ->  From CPU_ID  : User version
#  omsp_info(<cpu_nr>,per_size)             ->  From CPU_ID  : Peripheral address size 
#  omsp_info(<cpu_nr>,dmem_size)            ->  From CPU_ID  : Data memory size 
#  omsp_info(<cpu_nr>,pmem_size)            ->  From CPU_ID  : Program memory size
#  omsp_info(<cpu_nr>,mpy)                  ->  From CPU_ID  : Hardware multiplier
#  omsp_info(<cpu_nr>,asic)                 ->  From CPU_ID  : ASIC/FPGA version
#  omsp_info(<cpu_nr>,inst_nr)              ->  From CPU_NR  : current oMSP instance number
#  omsp_info(<cpu_nr>,total_nr)             ->  From CPU_NR  : totalnumber of oMSP instances-1
#  omsp_info(<cpu_nr>,alias)                ->  From XML File: Alias name
#  omsp_info(<cpu_nr>,extra,0,Description)  ->  From XML File: Optional Description
#  omsp_info(<cpu_nr>,extra,1,Contact)      ->  From XML File: Contact person
#  omsp_info(<cpu_nr>,extra,2,Email)        ->  From XML File: Email of contact person
#  omsp_info(<cpu_nr>,extra,3,URL)          ->  From XML File: URL of the project
#  omsp_info(<cpu_nr>,extra,4,per_size)     ->  From XML File: Custom Peripheral address size 
#  omsp_info(<cpu_nr>,extra,5,dmem_size)    ->  From XML File: Custom Data memory size 
#  omsp_info(<cpu_nr>,extra,6,pmem_size)    ->  From XML File: Custom Program memory size
#  omsp_info(<cpu_nr>,extra,?,????)         ->  From XML File: ... any extra stuff
#
#==========================================================================================================#
global omsp_info

# Initialize connection status 
set    omsp_info(connected) 0

# Support up to 128 multicore implementations
for {set i 0} {$i<128} {incr i} {
    set  omsp_info($i,connected) 0
}


#==========================================================================================================#
# SOURCE REQUIRED LIBRARIES
#==========================================================================================================#

set     scriptDir [file dirname [info script]]
source $scriptDir/xml.tcl
source $scriptDir/dbg_uart_generic.tcl
source $scriptDir/dbg_i2c_usb-iss.tcl


#==========================================================================================================#
# DEBUG PROCEDURES
#==========================================================================================================#

#=============================================================================#
# GetDevice (CpuNr)                                                           #
#-----------------------------------------------------------------------------#
# Description: Takes the target MSP430 device under UART/I2C control.         #
#              Enable the auto-freeze feature of timers when in the CPU is    #
#              stopped. This prevents an automatic watchdog reset condition.  #
#              Enables software breakpoints.                                  #
# Arguments  : CpuNr - oMSP device number to connect to.                      #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc GetDevice {CpuNr} {
    
    global omsp_conf
    global omsp_info

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set device   $omsp_conf(device)
    set baudrate $omsp_conf(baudrate)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)


    # Open Physical connection (if not already open)
    if {$omsp_info(connected)==0} {

        if {![${if}::dbg_open $device $baudrate]} {
            return 0
        }

        # Physical connection is active
        set omsp_info(connected) 1
    }


    # Open Connection with the CPU
    if {$omsp_info($CpuNr,connected)==0} {

        # Connect to the CPU
        if {![${if}::dbg_connect $cpuaddr]} {
            return 0
        }

        # Make sure the CPU_ID is correct
        if {![VerifyCPU_ID $CpuNr]} {
            return 0
        }

        # Enable auto-freeze & software breakpoints
        ${if}::dbg_wr $cpuaddr CPU_CTL 0x0018

        # Initialize the omsp_info global variable
        GetCPU_ID $CpuNr

        # Get number of hardware breakpoints
        set omsp_info($CpuNr,hw_break)  [InitBreakUnits $CpuNr]
    
        # Connection with the CPU is now active
        set omsp_info($CpuNr,connected) 1
    }

    return 1
}

#=============================================================================#
# ReleaseDevice (CpuNr, Addr)                                                 #
#-----------------------------------------------------------------------------#
# Description: Releases the target device from UART/I2C control; CPU starts   #
#              execution at the specified PC address.                         #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
#              Addr  - 0xfffe: perform reset;                                 #
#                              address at reset vector loaded into PC;        #
#                      otherwise address specified by Addr loaded into PC.    #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc ReleaseDevice {CpuNr Addr} {

    if {[expr $Addr]==[expr 0xfffe]} {
        set result 1
        set result [expr $result+[ExecutePOR $CpuNr]]
        set result [expr $result+[ReleaseCPU $CpuNr]]
    } else {
        set result 0
        set result [expr $result+[HaltCPU    $CpuNr]]
        set result [expr $result+[SetPC      $CpuNr $Addr]]
        set result [expr $result+[ReleaseCPU $CpuNr]]
    }

    if {$result==3} {
        return 1
    } else {
        return 0
    }
}

#=============================================================================#
# ExecutePOR (CpuNr)                                                          #
#-----------------------------------------------------------------------------#
# Description: Executes a power-up clear (PUC) command.                       #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc ExecutePOR {CpuNr} {
  
    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Set PUC
    set cpu_ctl_org [${if}::dbg_rd $cpuaddr CPU_CTL]
    set cpu_ctl_new [expr 0x40 | $cpu_ctl_org]
    ${if}::dbg_wr $cpuaddr CPU_CTL $cpu_ctl_new

    # Remove PUC, clear break after reset
    set cpu_ctl_org [expr 0x5f & $cpu_ctl_org]
    ${if}::dbg_wr $cpuaddr CPU_CTL $cpu_ctl_org

    # Check status: make sure a PUC occured
    set cpu_stat_val [${if}::dbg_rd $cpuaddr CPU_STAT]
    set puc_pnd      [expr 0x04 & $cpu_stat_val]
    if {![string eq $puc_pnd 4]} {
        return 0
    }

    # Clear PUC pending flag
    ${if}::dbg_wr $cpuaddr CPU_STAT 0x04

    return 1
}

#=============================================================================#
# SetPC (CpuNr, Addr)                                                         #
#-----------------------------------------------------------------------------#
# Description: Loads the target device CPU's program counter (PC) with the    #
#              desired 16-bit address.                                        #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
#              Addr  - Desired 16-bit PC value (in hexadecimal).              #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc SetPC {CpuNr Addr} {

    return [WriteReg $CpuNr 0 $Addr]
}

#=============================================================================#
# HaltCPU (CpuNr)                                                             #
#-----------------------------------------------------------------------------#
# Description: Sends the target CPU into a controlled, stopped state.         #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc HaltCPU {CpuNr} {
  
    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Stop CPU
    set cpu_ctl_org [${if}::dbg_rd $cpuaddr CPU_CTL]
    set cpu_ctl_new [expr 0x01 | $cpu_ctl_org]
    ${if}::dbg_wr $cpuaddr CPU_CTL $cpu_ctl_new

    # Check status: make sure the CPU halted
    set cpu_stat_val [${if}::dbg_rd $cpuaddr CPU_STAT]
    set halted       [expr 0x01 & $cpu_stat_val]
    if {![string eq $halted 1]} {
        return 0
    }

    return 1
}

#=============================================================================#
# ReleaseCPU (CpuNr)                                                          #
#-----------------------------------------------------------------------------#
# Description: Releases the target device's CPU from the controlled, stopped  #
#              state. (Does not release the target device from debug control.)#
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc ReleaseCPU {CpuNr} {
  
    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Start CPU
    set cpu_ctl_org [${if}::dbg_rd $cpuaddr CPU_CTL]
    set cpu_ctl_new [expr 0x02 | $cpu_ctl_org]
    ${if}::dbg_wr $cpuaddr CPU_CTL $cpu_ctl_new

    # Check status: make sure the CPU runs
    set cpu_stat_val [${if}::dbg_rd $cpuaddr CPU_STAT]
    set halted       [expr 0x01 & $cpu_stat_val]
    if {![string eq $halted 0]} {
        return 0
    }

    return 1
}

#=============================================================================#
# WriteMem (CpuNr, Format, Addr, Data)                                        #
#-----------------------------------------------------------------------------#
# Description: Write a single byte or word to a given address (RAM, ROM &     #
#              Peripherals.                                                   #
# Arguments  : CpuNr  - oMSP device number to be addressed.                   #
#              Format - 0 to write a word, 1 to write a byte.                 #
#              Addr   - Destination address for data to be written.           #
#              Data   - Data value to be written.                             #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc WriteMem {CpuNr Format Addr Data} {

    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Configure memory transfer
    #${if}::dbg_wr $cpuaddr MEM_CNT  0x0000
    ${if}::dbg_wr $cpuaddr MEM_ADDR $Addr
    ${if}::dbg_wr $cpuaddr MEM_DATA $Data

    # Trigger transfer
    if {$Format==0} {
        ${if}::dbg_wr $cpuaddr MEM_CTL  0x0003
    } else {
        ${if}::dbg_wr $cpuaddr MEM_CTL  0x000b
    }

    return 1
}

#=============================================================================#
# WriteMemQuick (CpuNr, StartAddr, DataList)                                  #
#-----------------------------------------------------------------------------#
# Description: Writes a list of words into the target device memory (RAM,     #
#              ROM & Peripherals.                                             #
# Arguments  : CpuNr     - oMSP device number to be addressed.                #
#              StartAddr - Start address of destination memory.               #
#              DataList  - List of data to be written (in hexadecimal).       #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc WriteMemQuick {CpuNr StartAddr DataList} {

    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Single data transfer
    if {[llength $DataList]==1} {
        WriteMem $CpuNr 0 $StartAddr $DataList

    # Burst data transfer
    } else {

        # Configure & trigger memory transfer
        ${if}::dbg_wr $cpuaddr MEM_CNT  [expr [llength $DataList]-1]
        ${if}::dbg_wr $cpuaddr MEM_ADDR $StartAddr
        ${if}::dbg_wr $cpuaddr MEM_CTL  0x0003

        # Send data list
        ${if}::dbg_burst_tx $cpuaddr 0 $DataList

    }
    return 1
}

#=============================================================================#
# ReadMem (CpuNr, Format, Addr)                                               #
#-----------------------------------------------------------------------------#
# Description: Read one byte or word from a specified target memory address.  #
# Arguments  : CpuNr  - oMSP device number to be addressed.                   #
#              Format - 0 to read a word, 1 to read a byte.                   #
#              Addr   - Target address for data to be read.                   #
# Result     : Data value stored in the target address memory location.       #
#=============================================================================#
proc ReadMem {CpuNr Format Addr} {

    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Single data transfer
    #${if}::dbg_wr $cpuaddr MEM_CNT  0x0000
    ${if}::dbg_wr $cpuaddr MEM_ADDR $Addr

    # Trigger transfer
    if {$Format==0} {
        ${if}::dbg_wr $cpuaddr MEM_CTL  0x0001
        set mem_val [${if}::dbg_rd $cpuaddr MEM_DATA]
    } else {
        ${if}::dbg_wr $cpuaddr MEM_CTL  0x0009
        set mem_val [${if}::dbg_rd $cpuaddr MEM_DATA]
        set mem_val [format "0x%02x" $mem_val]
    }

    return $mem_val
}

#=============================================================================#
# ReadMemQuick (CpuNr, StartAddr, Length)                                     #
#-----------------------------------------------------------------------------#
# Description: Reads a list of words from target memory.                      #
# Arguments  : CpuNr     - oMSP device number to be addressed.                #
#              StartAddr - Start address of target memory to be read.         #
#              Length    - Number of words to be read.                        #
# Result     : List of data values stored in the target memory.               #
#=============================================================================#
proc ReadMemQuick {CpuNr StartAddr Length} {

    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Single data transfer
    if {$Length==1} {
        set mem_val [ReadMem $CpuNr 0 $StartAddr]

    # Burst data transfer
    } else {

        # Configure & trigger memory transfer
        ${if}::dbg_wr $cpuaddr MEM_CNT  [expr $Length-1]
        ${if}::dbg_wr $cpuaddr MEM_ADDR $StartAddr
        ${if}::dbg_wr $cpuaddr MEM_CTL  0x0001

	# Receive Data list
        set mem_val [${if}::dbg_burst_rx $cpuaddr 0 [expr $Length*2]]
    }
    return $mem_val
}

#=============================================================================#
# VerifyMem (CpuNr, StartAddr, DataList)                                      #
#-----------------------------------------------------------------------------#
# Description: Performs a program verification over the given memory range.   #
# Arguments  : CpuNr     - oMSP device number to be addressed.                #
#              StartAddr - Start address of the memory to be verified.        #
#              DataList  - List of reference data (in hexadecimal).           #
# Result     : 0 if error, 1 if verification was successful.                  #
#=============================================================================#
proc VerifyMem {CpuNr StartAddr DataList {DumpOnError 0}} {

    # Read memory content
    set mem_val [ReadMemQuick $CpuNr $StartAddr [llength $DataList]]

    # Compare memory contents
    set    return_val [string equal $DataList $mem_val]

    # Dump memory content in files for comparison
    if {($return_val==0) && ($DumpOnError==1)} {

        # Delete old files
        file delete -force openmsp430-verifymem-debug-expected.mem
        file delete -force openmsp430-verifymem-debug-dumped.mem

        # Write expected memory content
        set fileId [open openmsp430-verifymem-debug-expected.mem "w"]
        foreach hexCode $DataList {
            puts $fileId $hexCode
        }
        close $fileId

        # Dump read memory content
        set fileId [open openmsp430-verifymem-debug-dumped.mem "w"]
        foreach hexCode $mem_val {
            puts $fileId $hexCode
        }
        close $fileId
    }

    return $return_val
}

#=============================================================================#
# ExecutePOR_Halt (CpuNr)                                                     #
#-----------------------------------------------------------------------------#
# Description: Same as ExecutePOR with the difference that the CPU            #
#              automatically goes in Halt mode after reset.                   #
# Arguments  : CpuNr  - oMSP device number to be addressed.                   #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc ExecutePOR_Halt {CpuNr} {
  
    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Perform PUC
    set cpu_ctl_org [${if}::dbg_rd $cpuaddr CPU_CTL]
    set cpu_ctl_new [expr 0x60 | $cpu_ctl_org]
    ${if}::dbg_wr $cpuaddr CPU_CTL $cpu_ctl_new
    ${if}::dbg_wr $cpuaddr CPU_CTL $cpu_ctl_org

    # Check status: make sure a PUC occured and that the CPU is halted
    set cpu_stat_val [${if}::dbg_rd $cpuaddr CPU_STAT]
    set puc_pnd      [expr 0x05 & $cpu_stat_val]
    if {![string eq $puc_pnd 5]} {
        return 0
    }

    # Clear PUC pending flag
    ${if}::dbg_wr $cpuaddr CPU_STAT 0x04

    return 1
}

#=============================================================================#
# GetCPU_ID (CpuNr)                                                           #
#-----------------------------------------------------------------------------#
# Description: This function reads the CPU_ID from the target device, update  #
#              the omsp_info global variable and return the raw CPU_ID value. #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
# Result     : Return CPU_ID.                                                 #
#=============================================================================#
proc GetCPU_ID {CpuNr} {

    global omsp_conf
    global omsp_info

     # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Retreive CPU_ID/CPU_NR values
    set cpu_id_lo [${if}::dbg_rd $cpuaddr CPU_ID_LO]
    set cpu_id_hi [${if}::dbg_rd $cpuaddr CPU_ID_HI]
    set cpu_nr    [${if}::dbg_rd $cpuaddr CPU_NR]
    
    # Check if value is valid
    if {[string eq "0x" $cpu_id_lo]} {
        set cpu_id_lo "0x0000"
    }
    if {[string eq "0x" $cpu_id_hi]} {
        set cpu_id_hi "0x0000"
    }
    if {[string eq "0x" $cpu_nr]} {
        set cpu_nr    "0x0000"
    }
    
    # Remove the "0x" prefix
    regsub {0x} $cpu_id_lo {} cpu_id_lo
    regsub {0x} $cpu_id_hi {} cpu_id_hi

    set cpu_id    "0x$cpu_id_hi$cpu_id_lo"
    set cpu_id_lo "0x$cpu_id_lo"
    set cpu_id_hi "0x$cpu_id_hi"


    # Extract the omsp info depending on the CPU version
    set omsp_info($CpuNr,cpu_ver) [expr ($cpu_id_lo & 0x0007)+1]
    if {$omsp_info($CpuNr,cpu_ver)==1} {
        set omsp_info($CpuNr,user_ver)    --
        set omsp_info($CpuNr,per_size)   512
        set omsp_info($CpuNr,dmem_size)  [expr $cpu_id_lo]
        set omsp_info($CpuNr,pmem_size)  [expr $cpu_id_hi]
        set omsp_info($CpuNr,mpy)         --
        set omsp_info($CpuNr,asic)         0
    } else {
        set omsp_info($CpuNr,user_ver)   [expr  ($cpu_id_lo & 0x01f0)/16]
        set omsp_info($CpuNr,per_size)   [expr (($cpu_id_lo & 0xfe00)/512)  * 512]
        set omsp_info($CpuNr,dmem_size)  [expr (($cpu_id_hi & 0x03fe)/2)    * 128]
        set omsp_info($CpuNr,pmem_size)  [expr (($cpu_id_hi & 0xfc00)/1024) * 1024]
        set omsp_info($CpuNr,mpy)        [expr  ($cpu_id_hi & 0x0001)/1]
        set omsp_info($CpuNr,asic)       [expr  ($cpu_id_lo & 0x0008)/8]
    }

    # Get the instance number
    set omsp_info($CpuNr,inst_nr)  [expr  ($cpu_nr & 0x00ff)/1]
    set omsp_info($CpuNr,total_nr) [expr  ($cpu_nr & 0xff00)/256]

    # Get alias from the XML file
    set omsp_info($CpuNr,alias) [GetChipAlias $CpuNr]

    return $cpu_id
}

#=============================================================================#
# GetCPU_ID_SIZE (CpuNr)                                                      #
#-----------------------------------------------------------------------------#
# Description: Returns the Data and Program memory sizes of the connected     #
#              device.                                                        #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
# Result     : Return "PMEM_SIZE DMEM_SIZE PER_SIZE" in byte.                 #
#=============================================================================#
proc GetCPU_ID_SIZE {CpuNr} {

    global omsp_info

    # Check if custom sizes are available from the XML file
    set custom_pmem [array names omsp_info -glob "$CpuNr,extra,*,pmem_size"]
    set custom_dmem [array names omsp_info -glob "$CpuNr,extra,*,dmem_size"]
    set custom_per  [array names omsp_info -glob "$CpuNr,extra,*,per_size"]

    # Program memory size
    if {$custom_pmem != ""} {
	set pmem_size $omsp_info($custom_pmem)
    } elseif {[info exists omsp_info($CpuNr,pmem_size)]} {
        set pmem_size $omsp_info($CpuNr,pmem_size)
    } else {
        set pmem_size -1
    }

    # Data memory size
    if {$custom_dmem != ""} {
	set dmem_size $omsp_info($custom_dmem)
    } elseif {[info exists omsp_info($CpuNr,dmem_size)]} {
        set dmem_size $omsp_info($CpuNr,dmem_size)
    } else {
        set dmem_size -1
    }

    # Peripheral address space size
    if {$custom_per != ""} {
	set per_size $omsp_info($custom_per)
    } elseif {[info exists omsp_info($CpuNr,per_size)]} {
        set per_size $omsp_info($CpuNr,per_size)
    } else {
        set per_size -1
    }

    return "$pmem_size $dmem_size $per_size"
}

#=============================================================================#
# VerifyCPU_ID (CpuNr)                                                        #
#-----------------------------------------------------------------------------#
# Description: Read and check the CPU_ID from the target device.              #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc VerifyCPU_ID {CpuNr} {

    global omsp_conf
    global omsp_info

    set cpu_id_full [GetCPU_ID $CpuNr]

    if {[string eq "0x00000000" $cpu_id_full] |
        ([string length $cpu_id_full]!=10)    |
        ($omsp_info($CpuNr,cpu_ver) >3)       } {
    
        puts "\n"
        puts "ERROR: cpu_id not valid: $cpu_id_full"
        puts ""
        puts "         --------------------------------------------------------------"
        puts "       !!!! What next:                                               !!!!"
	if {[regexp {i2c_} $omsp_conf(interface)]} {
	    puts "       !!!!    - double check the I2C address of the target core.    !!!!"
	}
	puts "       !!!!    - check that you are properly connected to the board. !!!!"
        puts "       !!!!    - try reseting the serial debug interface (or CPU).   !!!!"
        puts "         --------------------------------------------------------------"
        puts ""

        return 0
    }
    return 1
}

#=============================================================================#
# WriteReg (CpuNr, Addr,  Data)                                               #
#-----------------------------------------------------------------------------#
# Description: Write a word to the the selected CPU register.                 #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
#              Addr  - Target CPU Register number.                            #
#              Data  - Data value to be written.                              #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc WriteReg {CpuNr Addr Data} {

    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Configure memory transfer
    #${if}::dbg_wr $cpuaddr MEM_CNT  0x0000
    ${if}::dbg_wr $cpuaddr MEM_ADDR $Addr
    ${if}::dbg_wr $cpuaddr MEM_DATA $Data

    # Trigger transfer
    ${if}::dbg_wr $cpuaddr MEM_CTL  0x0007

    return 1
}

#=============================================================================#
# WriteRegAll (CpuNr, DataList)                                               #
#-----------------------------------------------------------------------------#
# Description: Write all CPU registers.                                       #
# Arguments  : CpuNr     - oMSP device number to be addressed.                #
#              DataList  - Data values to be written.                         #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc WriteRegAll {CpuNr DataList} {

    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Configure & trigger memory transfer
    ${if}::dbg_wr $cpuaddr MEM_CNT  [expr [llength $DataList]-1]
    ${if}::dbg_wr $cpuaddr MEM_ADDR 0x0000
    ${if}::dbg_wr $cpuaddr MEM_CTL  0x0007

    # Send data list
    ${if}::dbg_burst_tx $cpuaddr 0 $DataList

    return 1
}

#=============================================================================#
# ReadReg (CpuNr, Addr)                                                       #
#-----------------------------------------------------------------------------#
# Description: Read the value from the selected CPU register.                 #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
#              Addr  - Target CPU Register number.                            #
# Result     : Data value stored in the selected CPU register.                #
#=============================================================================#
proc ReadReg {CpuNr Addr} {

    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Single data transfer
    ${if}::dbg_wr $cpuaddr MEM_CNT  0x0000
    ${if}::dbg_wr $cpuaddr MEM_ADDR $Addr

    # Trigger transfer
    ${if}::dbg_wr $cpuaddr MEM_CTL  0x0005
    set reg_val [${if}::dbg_rd $cpuaddr MEM_DATA]

    return $reg_val
}

#=============================================================================#
# ReadRegAll (CpuNr)                                                          #
#-----------------------------------------------------------------------------#
# Description: Read all CPU registers.                                        #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
# Result     : Current values of all CPU registers.                           #
#=============================================================================#
proc ReadRegAll {CpuNr} {

    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Configure & trigger memory transfer
    ${if}::dbg_wr $cpuaddr MEM_CNT  0x000f
    ${if}::dbg_wr $cpuaddr MEM_ADDR 0x0000
    ${if}::dbg_wr $cpuaddr MEM_CTL  0x0005

    # Receive Data list
    set reg_val [${if}::dbg_burst_rx $cpuaddr 0 32]

    return $reg_val
}

#=============================================================================#
# WriteMemQuick8 (CpuNr, StartAddr, DataList)                                 #
#-----------------------------------------------------------------------------#
# Description: Writes a list of bytes into the target device memory (RAM,     #
#              ROM & Peripherals.                                             #
# Arguments  : CpuNr     - oMSP device number to be addressed.                #
#              StartAddr - Start address of destination memory.               #
#              DataList  - List of data to be written (in hexadecimal).       #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc WriteMemQuick8 {CpuNr StartAddr DataList} {

    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Single data transfer
    if {[llength $DataList]==1} {
        WriteMem $CpuNr 1 $StartAddr $DataList

    # Burst data transfer
    } else {

        # Configure & trigger memory transfer
        ${if}::dbg_wr $cpuaddr MEM_CNT  [expr [llength $DataList]-1]
        ${if}::dbg_wr $cpuaddr MEM_ADDR $StartAddr
        ${if}::dbg_wr $cpuaddr MEM_CTL  0x000b

	# Send data list
        ${if}::dbg_burst_tx $cpuaddr 1 $DataList

    }
    return 1
}

#=============================================================================#
# ReadMemQuick8 (CpuNr, StartAddr, Length)                                    #
#-----------------------------------------------------------------------------#
# Description: Reads a list of bytes from target memory.                      #
# Arguments  : CpuNr     - oMSP device number to be addressed.                #
#              StartAddr - Start address of target memory to be read.         #
#              Length    - Number of bytes to be read.                        #
# Result     : List of data values stored in the target memory.               #
#=============================================================================#
proc ReadMemQuick8 {CpuNr StartAddr Length} {

    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Single data transfer
    if {$Length==1} {
        set mem_val [ReadMem $CpuNr 1 $StartAddr]

    # Burst data transfer
    } else {

        # Configure & trigger memory transfer
        ${if}::dbg_wr $cpuaddr MEM_CNT  [expr $Length-1]
        ${if}::dbg_wr $cpuaddr MEM_ADDR $StartAddr
        ${if}::dbg_wr $cpuaddr MEM_CTL  0x0009

	# Receive Data list
        set mem_val [${if}::dbg_burst_rx $cpuaddr 1 $Length]
    }

    return $mem_val
}

#=============================================================================#
# StepCPU (CpuNr)                                                             #
#-----------------------------------------------------------------------------#
# Description: Performs a CPU incremental step.                               #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc StepCPU {CpuNr} {

    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Check if the device is halted. If not, stop it.
    set cpu_ctl_val [${if}::dbg_rd $cpuaddr CPU_CTL]
    set cpu_ctl_new [expr 0x04 | $cpu_ctl_val]
    ${if}::dbg_wr $cpuaddr CPU_CTL $cpu_ctl_new

    return 1
}

#=============================================================================#
# EraseRAM (CpuNr)                                                            #
#-----------------------------------------------------------------------------#
# Description: Erase RAM.                                                     #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc EraseRAM {CpuNr} {

    global omsp_info

    set ram_size [lindex [GetCPU_ID_SIZE $CpuNr] 1]
    set per_size [lindex [GetCPU_ID_SIZE $CpuNr] 2]

    if {$ram_size!=-1} {

        set DataList ""
        for {set i 0} {$i<$ram_size} {incr i} {
            lappend DataList 0x00
        }

        WriteMemQuick8 $CpuNr $per_size $DataList

        return 1
    }
    return 0
}

#=============================================================================#
# EraseROM (CpuNr)                                                            #
#-----------------------------------------------------------------------------#
# Description: Erase ROM.                                                     #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc EraseROM {CpuNr} {

    set rom_size  [lindex [GetCPU_ID_SIZE $CpuNr] 0]
    set rom_start [expr 0x10000-$rom_size]

    if {$rom_size!=-1} {   
        set DataList ""
        for {set i 0} {$i<$rom_size} {incr i} {
            lappend DataList 0x00
        }

        WriteMemQuick8 $CpuNr $rom_start $DataList

        return 1
    }
    return 0
}

#=============================================================================#
# InitBreakUnits(CpuNr)                                                       #
#-----------------------------------------------------------------------------#
# Description: Initialize the hardware breakpoint units.                      #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
# Result     : Number of hardware breakpoint units.                           #
#=============================================================================#
proc InitBreakUnits {CpuNr} {

    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Initialize each hardware breakpoint unit and count how many of them
    # are present in the current core
    set num_brk_units 0
    for {set i 0} {$i<4} {incr i} {

        ${if}::dbg_wr $cpuaddr "BRK$i\_ADDR0" 0x1234
        set new_val [${if}::dbg_rd $cpuaddr "BRK$i\_ADDR0"]
        if {$new_val=="0x1234"} {
            incr num_brk_units
            ${if}::dbg_wr $cpuaddr "BRK$i\_CTL"   0x00
            ${if}::dbg_wr $cpuaddr "BRK$i\_STAT"  0xff
            ${if}::dbg_wr $cpuaddr "BRK$i\_ADDR0" 0x0000
            ${if}::dbg_wr $cpuaddr "BRK$i\_ADDR1" 0x0000
        }
    }
    return $num_brk_units
}

#=============================================================================#
# SetHWBreak(CpuNr, Type, Addr, Rd, Wr)                                       #
#-----------------------------------------------------------------------------#
# Description: Set data/instruction breakpoint on a given memory address.     #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
#              Type  - 1 for instruction break, 0 for data break.             #
#              Addr  - Memory address of the data breakpoint.                 #
#              Rd    - Breakpoint on read access.                             #
#              Wr    - Breakpoint on write access.                            #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc SetHWBreak {CpuNr Type Addr Rd Wr} {

    global omsp_info
    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Compute the BRKx_CTL corresponding value
    set brk_ctl_ref [format "0x%02x" [expr 8*$Type+4+2*$Wr+$Rd]]

    # First look for utilized units with correct BRKx_CTL attributes
    for {set i 0} {$i<$omsp_info($CpuNr,hw_break)} {incr i} {
        if {[string eq [${if}::dbg_rd $cpuaddr "BRK$i\_CTL"] $brk_ctl_ref]} {

            # Look if there is an address free
            set brk_addr0 [${if}::dbg_rd $cpuaddr "BRK$i\_ADDR0"]
            set brk_addr1 [${if}::dbg_rd $cpuaddr "BRK$i\_ADDR1"]
            if {[string eq $brk_addr0 $brk_addr1]} {
                ${if}::dbg_wr $cpuaddr "BRK$i\_ADDR1" $Addr
                return 1
            }
        }
    }

    # Then look for a free unit
    for {set i 0} {$i<$omsp_info($CpuNr,hw_break)} {incr i} {
        if {[string eq [${if}::dbg_rd $cpuaddr "BRK$i\_CTL"] 0x00]} {
            ${if}::dbg_wr $cpuaddr "BRK$i\_ADDR0" $Addr
            ${if}::dbg_wr $cpuaddr "BRK$i\_ADDR1" $Addr
            ${if}::dbg_wr $cpuaddr "BRK$i\_CTL"   $brk_ctl_ref
            return 1
        }
    }

    return 0
}

#=============================================================================#
# ClearHWBreak(CpuNr, Type, Addr)                                             #
#-----------------------------------------------------------------------------#
# Description: Clear the data/instruction breakpoint set on the provided      #
#              memory address.                                                #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
#              Type  - 1 for instruction break, 0 for data break.             #
#              Addr  - Data address of the breakpoint to be cleared.          #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc ClearHWBreak {CpuNr Type Addr} {

    global omsp_info
    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    for {set i 0} {$i<$omsp_info($CpuNr,hw_break)} {incr i} {

        # Check if the unit works on Data or Instructions)
        set brk_ctl [${if}::dbg_rd $cpuaddr "BRK$i\_CTL"]
        if {[expr $brk_ctl & 0x08]==[expr 8*$Type]} {

            # Look for the matching address
            set brk_addr0 [${if}::dbg_rd $cpuaddr "BRK$i\_ADDR0"]
            set brk_addr1 [${if}::dbg_rd $cpuaddr "BRK$i\_ADDR1"]

            if {[string eq $brk_addr0 $brk_addr1] && [string eq $brk_addr0 $Addr]} {
                ${if}::dbg_wr $cpuaddr "BRK$i\_CTL"   0x00
                ${if}::dbg_wr $cpuaddr "BRK$i\_STAT"  0xff
                ${if}::dbg_wr $cpuaddr "BRK$i\_ADDR0" 0x0000
                ${if}::dbg_wr $cpuaddr "BRK$i\_ADDR1" 0x0000
                return 1
            }
            if {[string eq $brk_addr0 $Addr]} {
                ${if}::dbg_wr $cpuaddr "BRK$i\_ADDR0" $brk_addr1
                return 1
            }
            if {[string eq $brk_addr1 $Addr]} {
                ${if}::dbg_wr $cpuaddr "BRK$i\_ADDR1" $brk_addr0
                return 1
            }
        }
    }
    return 1
}

#=============================================================================#
# IsHalted (CpuNr)                                                            #
#-----------------------------------------------------------------------------#
# Description: Check if the CPU is currently stopped or not.                  #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
# Result     : 0 if CPU is running, 1 if stopped.                             #
#=============================================================================#
proc IsHalted {CpuNr} {

    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Check current target status
    set cpu_stat_val [${if}::dbg_rd $cpuaddr CPU_STAT]
    set halted       [expr 0x01 & $cpu_stat_val]

    return $halted
}

#=============================================================================#
# ClrStatus (CpuNr)                                                           #
#-----------------------------------------------------------------------------#
# Description: Clear the status bit of the CPU_STAT register.                 #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
# Result     : 0 if error, 1 otherwise.                                       #
#=============================================================================#
proc ClrStatus {CpuNr} {

    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)
    set cpuaddr  $omsp_conf($CpuNr,cpuaddr)

    # Clear status
    ${if}::dbg_wr $cpuaddr CPU_STAT  0xff
    ${if}::dbg_wr $cpuaddr BRK0_STAT 0xff
    ${if}::dbg_wr $cpuaddr BRK1_STAT 0xff
    ${if}::dbg_wr $cpuaddr BRK2_STAT 0xff
    ${if}::dbg_wr $cpuaddr BRK3_STAT 0xff

    return 1
}

#=============================================================================#
# GetAllowedSpeeds()                                                          #
#-----------------------------------------------------------------------------#
# Description: Return the list of allowed speed configurations for the        #
#              selected adapter.                                              #
# Arguments  : None.                                                          #
# Result     : list of modes.                                                 #
#=============================================================================#
proc GetAllowedSpeeds {} {

    global omsp_conf

    # Copy global variable to local for code readability
    set if       $omsp_conf(interface)

    # Return list of allowed speed configuration
    return [${if}::get_allowed_speeds]
}

#=============================================================================#
# GetChipAlias (CpuNr)                                                        #
#-----------------------------------------------------------------------------#
# Description: Parse the chip alias XML file an return the alias name.        #
# Arguments  : CpuNr - oMSP device number to be addressed.                    #
# Result     : Chip Alias.                                                    #
#=============================================================================#
proc GetChipAlias {CpuNr} {

    global omsp_info

    # Set XML file name
    if {[info exists  ::env(OMSP_XML_FILE)]} {
        set xmlFile $::env(OMSP_XML_FILE)
    } else {
        set xmlFile [file normalize "$::scriptDir/../../omsp_alias.xml"]
    }

    # Read XML file
    if {[file exists $xmlFile]} {
        set fp [open $xmlFile r]
        set xmlData [read $fp]
        close $fp
    } else {
        puts "WARNING: the XML alias file was not found - $xmlFile"
        return ""
    }

    # Analyze XML file
    ::XML::Init $xmlData
    set wellFormed [::XML::IsWellFormed]
    if {$wellFormed ne ""} {
        puts "WARNING: the XML alias file is not well-formed - $xmlFile \n $wellFormed"
        return ""
    }

    #========================================================================#
    # Create list from XML file                                              #
    #========================================================================#
    set aliasList    ""
    set currentALIAS ""
    set currentTYPE  ""
    set currentTAG   ""
    while {1} {
        foreach {type val attr etype} [::XML::NextToken] break
        if {$type == "EOF"} break

        # Detect the start of a new alias description
        if {($type == "XML") & ($val == "omsp:alias") & ($etype == "START")} {
            set aliasName ""
            regexp {val=\"(.*)\"} $attr whole_match aliasName
            lappend aliasList $aliasName
            set currentALIAS $aliasName
        }

        # Detect start and end of the configuration field
        if {($type == "XML") & ($val == "omsp:configuration")} {

            if {($etype == "START")} {
                set currentTYPE  "config"

            } elseif {($etype == "END")} {
                set currentTYPE  ""
            }
        }

        # Detect start and end of the extra_info field
        if {($type == "XML") & ($val == "omsp:extra_info")} {

            if {($etype == "START")} {
                set currentTYPE  "extra_info"
                set idx 0

            } elseif {($etype == "END")} {
                set currentTYPE  ""
            }
        }
        
        # Detect the current TAG
        if {($type == "XML") & ($etype == "START")} {
            regsub {omsp:} $val {} val
            set currentTAG $val
        }

        if {($type == "TXT")} {
            if {$currentTYPE=="extra_info"} {
                set alias($currentALIAS,$currentTYPE,$idx,$currentTAG) $val
                incr idx
            } else {
                set alias($currentALIAS,$currentTYPE,$currentTAG) $val
            }
        }
    }

    #========================================================================#
    # Check if the current OMSP_INFO has an alias match                      #
    #========================================================================#
    foreach currentALIAS $aliasList {

        set aliasCONFIG [array names alias -glob "$currentALIAS,config,*"]
        set aliasEXTRA  [lsort -increasing [array names alias -glob "$currentALIAS,extra_info,*"]]

        #----------------------------------#
        # Is current alias matching ?      #
        #----------------------------------#
        set match       1
        set description ""
        foreach currentCONFIG $aliasCONFIG {

            regsub "$currentALIAS,config," $currentCONFIG {} configName

            if {![string eq $omsp_info($CpuNr,$configName) $alias($currentCONFIG)]} {
                set match 0
            }
        }

        #----------------------------------#
        # If matching, get the extra infos #
        #----------------------------------#
        if {$match} {

            set idx 0
            foreach currentEXTRA $aliasEXTRA {
                regsub "$currentALIAS,extra_info," $currentEXTRA {} extraName
                set omsp_info($CpuNr,extra,$idx,$extraName) $alias($currentEXTRA)
                incr idx
            }
            return $currentALIAS
        }
    }

    return ""
}
