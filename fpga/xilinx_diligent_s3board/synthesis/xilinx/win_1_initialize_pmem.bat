::###############################################################################
::#                                                                             #
::#                     Xilinx RAM update script for WINDOWS                    #
::#                                                                             #
::###############################################################################

::###############################################################################
::#                       Specify Program to be loaded                          #
::###############################################################################

set MSP430_PROGRAM=leds
::set MSP430_PROGRAM=ta_uart


::###############################################################################
::#                     Check if the required files exist                       #
::###############################################################################
set softdir=..\..\software\%MSP430_PROGRAM%
set elffile=..\..\software\%MSP430_PROGRAM%\%MSP430_PROGRAM%.elf

IF EXIST %softdir%  GOTO :DIR_OKAY
ECHO ERROR: Software directory doesn't exist: %softdir%
PAUSE
EXIT
:DIR_OKAY

IF EXIST %elffile%  GOTO :ELF_OKAY
ECHO ERROR: ELF file doesn't exist: %elffile%
PAUSE
EXIT
:ELF_OKAY


::###############################################################################
::#                           Update FPGA Bitstream                             #
::###############################################################################


DEL /f .\WORK\%MSP430_PROGRAM%.elf
DEL /f .\WORK\%MSP430_PROGRAM%.bit

XCOPY %elffile% .\WORK\

cd .\WORK
data2mem -bm ..\scripts\memory.bmm -bd %MSP430_PROGRAM%.elf -bt openMSP430_fpga.bit -o b %MSP430_PROGRAM%.bit
cd ..\
PAUSE