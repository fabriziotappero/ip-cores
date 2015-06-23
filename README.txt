M16C5x Soft-Core Microcomputer
=======================

Copyright (C) 2013, Michael A. Morris <morrisma@mchsi.com>.
All Rights Reserved.

Released under LGPL.

General Description
-------------------

This project demonstrates the use of a PIC16C5x-compatible core as an FPGA-
based processor. It implements the 12-bit instruction set, the timer 0 module, 
the pre-scaler, and the watchdog timer. The core provided here is compatible 
with instruction set, but it is not a cycle accurate model of any particular 
PIC microcomputer. 

As configured, the core supports single cycle (1) operation with internal 
block RAM serving as program memory. In addition to the block RAM program 
store, a 4x clock generator and reset controller is included as part of the 
demonstration. 

Three I/O ports are supported, but they are accessed as external registers and 
buffers using a bidirectional data bus. The TRIS I/O control registers are 
similarly supported. Thus, the core's user is able to map the TRIS and I/O 
port registers in a manner appropriate to the intended application.

Read-modify-operations on the I/O ports do not generate read strobes. Read 
strobes of the three I/O ports are generated only if the ports are being read 
using MOVF xxx,0 instructions. Similarly, the write enables for the three I/O 
ports are asserted whenever the ports are updated. This occurs during MOVWF 
instructions, or during read- modify-write operations such as XORF, MOVF, etc.

Implementation
--------------

The implementation of the core provided consists of several Verilog source files 
and memory initialization files:

    M16C5x.v                - Top level module
        M16C5x_ClkGen.v     - M16C5x Clock/Reset Generator
        P16C5x.v            - PIC16C5x-compatible processor core
            P16C5x_IDEC.v   - ROM-based instruction decoder for PIC16C5x core
            P16C5x_ALU.v    - Arithmetic & Logic Unit for PIC16C5x core
        M16C5x_SPI.v        - High-Speed, FIFO-buffered SPI Master Interface
            DPSFmnCE.v      - Configurable Depth/Width LUT-based Synch FIFO
                TF_Init.coe - Transmit FIFO Initialization file
                RF_Init.coe - Receive FIFO Initialization file
            SPIxIF.v        - Configurable Master SPI I/F with clock Generator
        M16C5x_UART.v       - UART with Serial Interface
            SSPx_Slv.v      - SSP-compatible Slave Interface
            SSP_UART.v      - SSP-compatible UART
                re1ce.v     - Rising Edge Clock Domain Crossing Synchronizer
                DPSFmnCE.v  - onfigurable Depth/Width LUT-based Synch FIFO
                    UART_TF.coe - UART Transmit FIFO Initialization file
                    UART_RF.coe - UART Receive FIFO Initialization file
                UART_BRG.v  - UART Baud Rate Generator
                UART_TXSM.v - UART Transmit State Machine (includes SR)
                UART_RXSM.v - UART Receive State Machine (includes SR)
                UART_RTO.v  - UART Receive Timeout Generator
                UART_INT.v  - UART Interrupt Generator

        M16C5x_Test.coe     - M16C5x Test Program Memory Initialization File
        M16C5x_Tst2.coe     - M16C5x Test #2 Program Memory Initialization File
        M16C5x_Tst3.coe     - M16C5x Test #3 Program Memory Initialization File
        M16C5x_Tst4.coe     - M16C5x Test #4 Program Memory Initialization File

        M16C5x.ucf          - M16C5x User Constraint File
        M16C5x.bmm          - M16C5x Block RAM Memory Map File

Verilog tesbench files are included for the processor core, the FIFO, and the 
SPI modules.

    tb_M16C5x.v             - testbench for the soft-core processor module
    tb_P16C5x.v             - testbench for the processor core module
    tb_DPSFmnCE.v           - testbench for the LUT-based FIFO module
    tb_SPIxIF.v             - testbench for the SPI Master Interface module
    
Also provided is the MPLAB project and the source files used to create the 
memory initialization files for testing the microcomputer application. These 
files are found in the MPLAB subdirectory of the Code directory.

Finally, the configuration of the Xilinx tools used to synthesize, map, place, 
and route are captured in the the TCL file:

        M16C5x_3S50A.tcl    - TCL file for XC3S50A-4VQG100I FPGA
        
Run this TCL script from within the TCL console of ISE, or examine it in a 
text editor, to set up the project files and to set the tools to the options 
used to achieve the results provided here.
        
Added utility program to convert MPLAB Intel Hex programming files into MEM 
files for use with Xilinx Data2MEM utility program to speed the process of 
incorporating program/data/parameter data into block RAMs. TCL also 
incorporates the process parameter changes to get the BMM file processed by 
Map/PAR/Bitgen.

    IH2MEM.c                    - Source code for Intel Hex to MEM utility
    IH2MEM.exe                  - Windows Executable (32-bit)

        M16C5x_Tst3.mem         - M16C5x Test #3 Program Memory Data2Mem File
        M16C5x_Tst4.mem         - M16C5x Test #4 Program Memory Data2Mem File

Synthesis
---------

The primary objective of the M16C5x is to synthesize a processor core, 4kW of 
program memory, a buffered SPI master, and a buffered UART into a Xilinx 
XC3S50A-4VQG100I FPGA. The present implementation includes the P16C5x core, 
4kW of program memory, a dual-channel SPI Master I/F, and an SSP-compatible 
UART supporting baud rates from 3M bps to 1200 bps.

Using ISE 10.1i SP3, the implementation results for an XC3S50A-4VQ100I are as 
follows:

    Number of Slice FFs:                619 of 1408      43%
    Number of 4-input LUTs:            1287 of 1408      92%
    Number of Occupied Slices:          701 of  704      99%
    Total Number of 4-input LUTs:      1333 of 1408      94%

                    Logic:             1052
                    Route-Through:       46
                    16x1 RAMs:            8
                    Dual-Port RAMs:     194
                    32x1 RAMs:           32
                    Shift Registers:      1

    Number of BUFGMUXs:                   4 of   24      16%
    Number of DCMs:                       1 of    2      50%
    Number of RAMB16BWEs                  3 of    3     100%

    Best Case Achievable:           12.381 ns (0.119 ns Setup, 0.691 ns Hold)

Status
------

Design and verification is complete. Verification performed using ISim, MPLAB, 
and a board with an XC3S200AN-4VQG100I FPGA, various oscillators, SEEPROMs, 
and RS-232/RS-485 transceivers.

Release Notes
-------------

###Release 1.0

In this release, the M16C5x has been synthesized, mapped, placed, routed, and 
used to configure an FPGA. The FPGA used for this initial test of the M16C5x 
was the XC3S200A-4VQG100I FPGA. The test program provided demonstrated that 
the M16C5x was executing the program in the same manner as simulated with the 
MPLAB simulator.

Using an external 14.7456 MHz oscillator, selected for use for use with the 
UART, square waves were generated by the core to illuminate external LEDs 
using the upper 6 bits of PortA. The square waves have the appropriate ratios, 
and the frequency of the fastest LED drive signal is ~4.753kHz.

The clock generator multiplies the input frequency to 58.9824 MHz which 
results in an effective instruction frequency of 29.4912 MHz because of the 
two cycle nature of the core. The instruction loop is essentially 8*(*+3*256), 
which equals 6208 cycles per LED toggle. The measured toggle frequency of the 
fastest LED is approximately equal to 29.4912 MHz / 6208, or 4.750 kHz.

Work will continue to verify the testbench results with the FPGA. The next 
release should include the UART, and test the ability of the core to 
send/receive data using the FIFOs at rates of 115,200 baud or greater.

###Release 2.0

In this release, the UART has been addded. An update has been made to the SPI 
I/F Master function; update correct fault with the framing of SPI Mode 3 
frames with shift lengths greater than 1 byte. A correction, not fully tested 
or verified, was made to the P16C5x core to correct anomalous behavior for 
BTFSC/BTFSS instructions.

UART integrated with the Release 1.0 core. Verification of the integrated 
interface is underway.

###Release 2.1

Testing with an M16C5x core processor program assembled using 
MPLAB and ISIM showed that polling of the UART status register to determine 
whether the transmit FIFO was empty or not (using the iTFE interrupt flag) 
would clear the generated interrupt flags before they had actually been 
captured and shifted in the SSP response to the core.

This indicated a clock domain crossing issue in the interrupt clearing logic. 
This release fixes that issue. Previous use of the UART does not poll the USR, 
so this problem does not manisfest itself in a reasonable amount of time, if 
ever. In other words, the synchronization fault has been present all along in 
the implementation, but the module's usage in the application (or testbench) 
did not present the conditions under which the fault manifests.

The correction required registering the USR data on the SSP clock domain, and 
qualifying the clearing of the interrupt flags on the basis of whether the 
flag is set in both domains when the USR is read. The addition of the register 
reduced the logic utilization, and only a small additonal time delay was 
incurred. The resulting design is still able to fit into a Spartan 3A XC3S50A-
4VQG100I FPGA.

Modified the UART Baud Rate Generator. Removed the fixed 16x12 ROM that 
provided the pre-scaler and divider constants for a fixed set of 16 baud 
rates. Added a 12-bit, write-only register, BRR - Baud Rate Register, that can 
be used to set the baud rate from 1/16 of the processor clock. With a 
58.9824 MHz oscillator, the baud rate can range from 3.6864Mbps down to 900 bps. 
Set the default baud rate to 9600 for a 58.9824 MHz UART clock.

Utilization for a XC3S50A-4VQG100I FPGA is 100%. The 128 byte LUT-based 
receive FIFO can be reduced to accomodate some additional functions. Synthesis 
and MAP/PAR able to implement the design. There is also some place holder 
logic that can be used for other purposes.

###Release 2.2

Updated the soft-core so as to be able to parameterize the microcontroller 
from the top module. Changed the frequency multiplication from 4 to 5 in order 
to test operation at the frequency which the UCF constrains Map/PAR tools. The 
input clock is driven by a 14.7456 MHz oscillator, and the clock multiplier 
(DCM) generates **73.7280 MHz**. The default baud rate, 9600, required that the 
default settings be adjusted. All other parameters remain the same.

Also added a Block RAM Memory Map file to the project. Utilized Xilinx's 
Data2MEM tool to insert modified program contents into the affected Block RAMs 
using MEM files dereived from standard MPLAB outputs. Tutorial on this subject 
is being prepared and will be released on an associated Wiki soon.

###Release 2.3

Updated the soft-core microcomputer. Fixed the UART clock, Clk_UART, to twice 
the input frequency. This means that the UART operates with a fixed reference 
frequency unlike Release 2.2 where Clk_UART was set to the system clock 
frequency.

Also added asynchronous resets to several registers in the UART so that it 
would simulate correcly with ISim. Direct control of the UART prescaler and 
divider was previously untested using the simulation. With that change to the 
baud rate generator made to UART, the reset/power-on values of these two logic 
functions are unknown. The unknowns, "X", propagate through the baud rate 
generator and prevent the simulator from resolving the state of the internal 
baud rate clock of the UART. Thus, although the rest of circuits simulate as 
expected, the transmit shift register never shifts because there's an 
"unknown" signal level applied on the bit clock.

###Release 2.4

Polling the UART's Receive Data Register (RDR) uncovered a race condition like 
that previously found and corrected in regards to polling the UART Status 
Register (USR). Correction required registering the RDR in the SCK clock 
domain, and qualifying the read enable pulse for the receive FIFO so that it 
is only generated if the Receive Rdy flag is present in the SCK clock domain. 
Otherwise, the Receive FIFO is not read which prevents the inadvertent 
clearing of the FIFO empty flag.

Test Program 4, M16C5x_Tst4.asm, is used to test the receive signal path. 
Hyperterminal and Tera Term were used to sent (without local echo) several 
large text files through the M16C5x UART. The test program polls the RDR, and 
if a character is received without error, then upper case are converted to 
lower case characters, and vice-versa. Using a Keyspan Quad Port USB serial 
port adapter, characters were sent to the M16C5x at a rate of 921.6k baud, the 
highest programmable baud rate supported by the Keyspan device. The echo back 
to terminal emulator appeared to be without error. (**Note:** _the two wire 
RS-232 mode of the UART was used for this test. The ADM3232 charge-pump RS-232 
transceiver appeared to work well at this frequency. Som slew rate limiting is 
visible on an O-scope, but it appears to be tolerable. These tests were 
conducted while the core was operating at **117.9648 MHz**._)

This release is expected to be the last public release of this soft-core 
microcomputer. The released core and peripherals are sufficient to demonstrate 
a non-trivial FPGA implementation of a soft-core microcomputer. Further 
developments will be focused on improving access to the internal block RAMs, 
and improving the I/O capabilities of the release core.

###Release 2.5

Converted the core to operate in a single cycle mode with the block RAM 
memories of the FPGA. Operating frequency, in a -4 Spartan 3A FPGA, is 60+ 
MHz. This rate is equivalent to the 117.9848 MHz reported above of for Release 
2.4. Some combinatorial path improvements were made to the processor core, 
P16C5x, by using wired-OR bus connections rather than explicit multiplexers. 
These improvements also provided some reductions in the resource utilization 
of the project.

####Release 2.5.1

Modified the BMM file to allow the MEM file data fields to be represented in 
natural order. In other words, unlike the previous release, the most 
significant nibble is the first (leftmost) character of each data word, and 
the least significant nibble is the last (rightmost) character in a data word. 
Also modified the utility provided that converts Intel Hex programming files 
into files compatible with the Xilinx Data2MEM utility program. 
