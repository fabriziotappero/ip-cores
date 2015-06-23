################################################################################
## This sourcecode is released under BSD license.
## Please see http://www.opensource.org/licenses/bsd-license.php for details!
################################################################################
##
## Copyright (c) 2010, Stefan Fischer <Ste.Fis@OpenCores.org>
## All rights reserved.
##
## Redistribution and use in source and binary forms, with or without 
## modification, are permitted provided that the following conditions are met:
##
##  * Redistributions of source code must retain the above copyright notice, 
##    this list of conditions and the following disclaimer.
##  * Redistributions in binary form must reproduce the above copyright notice,
##    this list of conditions and the following disclaimer in the documentation
##    and/or other materials provided with the distribution.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
## ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
## LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
## INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
## CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
## POSSIBILITY OF SUCH DAMAGE.
##
################################################################################
## filename: baud_rate_calculator.tcl
## description: tcl-script generating assembler constants for standard baud
##              rates
## todo4user: 1. modify output file path, SYSTEM_CLOCK and BAUD_RATES as needed
##            2. run script with TCL interpreter of your choice, i. e. from
##               ModelSim (R) GUI: Menu->Tools->TCL->Execute Macro...
##            3. copy and paste file content from generated
##               baud_rate_constants.txt to assembler source code
## version: 0.0.0
## changelog: - 0.0.0, initial release
##            - ...
################################################################################

# output file path
cd "e:/home_users/ste.fis/projects/wb4pb/trunk/asm"

# reference clock, normally several MHz
set SYSTEM_CLOCK 50.0E6

# some standard baud rates
set BAUD_RATES {
  300
  600
  1200
  2400
  4800
  9600
  19200
  38400
  57600
  115200
  230400
  460800
  921600
}

# open file handle
set f [open "baud_rate_constants.txt" w]

# baud rate configuration:
# baud_limit = round( system clock frequency / (16 * baud rate) ) - 1
# i. e. 9600 baud at 50 MHz system clock =>
# baud_limit = round( 50.0E6 / (16 * 9600) ) - 1 = 325 = 0x0145

# WARNING, baud rate error should not exceed 1.0 % for reliable operation!

# calculating baud min. and max. values
set baud_max [expr floor($SYSTEM_CLOCK / 16)]
set baud_min [expr ceil($SYSTEM_CLOCK / (16 * 65536))]

puts $f "; baud rate settings for $SYSTEM_CLOCK Hz system reference clock"
puts $f "; max. $baud_max baud"
puts $f "; min. $baud_min baud (16 bit baud timer)"
foreach baud_rate $BAUD_RATES {
  # checking, if current baud rate works with system hardware parameters
  if {[expr $baud_min <= $baud_rate] && [expr $baud_rate <= $baud_max]} {
    # calculating hardware baud timer limit
    set baud_limit [expr round($SYSTEM_CLOCK / (16 * $baud_rate)) - 1]
    # calculating actual hardware baud rate
    set actual_baud_rate [expr $SYSTEM_CLOCK / (16 * ($baud_limit + 1))]
    # calculating baud rate error, value is commented out automatically, if 
    # frequency error is greater than the recommended 1 %
    if {
      [set baud_error [expr abs(($baud_rate / $actual_baud_rate) - 1)]] > 0.01
    } {
      set comment ";"
    } else {
      set comment ""
    }
    # generating a 16 bit, 4 character hexadecimal string of hardware baud timer
    # limit
    set baud_limit_hex [format %04X $baud_limit]
    # creating strings with constant definitions in kcpsm3 assembler syntax,
    # splitting into high and low byte
    puts $f "${comment}CONSTANT UART_BAUD_LO_${baud_rate}_VALUE , [string range\
             $baud_limit_hex 2 3] ; actual baud rate [format %.2f\
             $actual_baud_rate]"
    puts $f "${comment}CONSTANT UART_BAUD_HI_${baud_rate}_VALUE , [string range\
             $baud_limit_hex 0 1] ; => baud rate error [format %.3f [expr 100 *\
             $baud_error]] %"
  }
}

# closing file
close $f
