================================================================================
COPYRIGHT
================================================================================

    Copyright (C) 2006 Shawn Tan Ser Ngiap <shawn.tan@aeste.net>.
    Permission is granted to copy, distribute and/or modify this document
    under the terms of the GNU Free Documentation License, Version 1.2
    or any later version published by the Free Software Foundation;
    with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
    A copy of the license is included in the section entitled "GNU
    Free Documentation License".

================================================================================
INTRODUCTION
================================================================================

The AE18 is a clean room implementation of a PIC18 software compatible core.
It is developed using publicly available documentation and tools. It is not
architecturally compatible. Major differences are noted in the section below.

================================================================================
NON-STANDARD FEATURES
================================================================================

There are some things that are implemented in a non standard way from the
PIC18. These are mainly minor issues that should not affect normal software
implementations. However, in certain cases, some software might need to be
modified to ensure correct operation.

1) Watch Dog Timer

The WDT is enabled by default. As there is no way to set any config bits for
this core, the ONLY way to disable it is by clearing the SWDTEN bit in the
WDTCON register. 

2) Other Timers

The other timers found standard on a PIC18 are NOT included with the AE18
core. These timers can all be built as external peripherals and attached to
the data bus of the AE18.

3) Other Peripherals

The AE18 core DOES NOT include any I/O devices or peripherals with the core.
However, it is WISHBONE compliant and can be included in a larger SoC with
suitable I/O devices and peripherals included.

4) External Interrupts

The AE18 has the built in facility to handle external interrupts. However,
the interrupt controller is not included in the core and will need to be
attached to the data bus as an external device.

The INT_I[1:0] and INTE_I[1:0] inputs are used to indicate high/low interrupt
sources and enables. The external interrupts are all positive edge triggered.
On an interrupt, the PC will branch directly to the correct vectors.

================================================================================
NON-IMPLEMENTED FEATURES
================================================================================

There are a few PIC18 features that are non implemented. These include some
SFR and some architectural features. These need to be carefully noted as
they will require some minor software changes to ensure correct operation.

1) SFR Non Implemented

Some SFR are not implemented. Any attempt to read/write these SFR will not
work correctly. These SFR should not be accessed at all.

a) RCON
   Does not make sense as the only source of reset is EXTERNAL/WDT/RESET.    
b) OSCCON/LVDCON
   Does not include a simple way to implement these features in an FPGA.
c) INTCON,INTCON2,INTCON3
   Not implemented as it depends on external devices.
d) ALL peripheral registers
   These will need to be implemented in each external device.
     
2) Important Notes

a) SLEEP
   This instruction should always be followed by two NOP instructions.
b) DAW
   This instruction has not been implemented yet.
c) ACCESS BANK
   The data memory space for SFR has been moved to 0xFF80 and above.

================================================================================
USAGE
================================================================================

Some software and scripts have been included with the core. These are to assist
in the simulation and verification of the AE18.

1) Simulation

For the purpose of software simulation, the core has been extensively tested
using sample test software. The test software is included in the /sw directory.
The assembly file is compiled using GPASM 0.13.4. The resulting code has been
simulated using Icarus Verilog 0.8.2 and GPLCVER 2.11a.

Sample simulation scripts have been included for both cver and iverilog. These
scripts are located in the /sim directory. When running the included testbench
software (ae18_core.asm), the core should echo "Test response OK!" if it
passed all the tests in the software.

2) Implementation

The specifics of implementation will depend on the toolset used by the vendor.
However, the main point to note is memory implementation. The instruction 
memory can be implemented as either on-chip or external memory.

================================================================================
FINAL NOTES
================================================================================

Although every care has been taken to test the core, there is no guarantee that
the AE18 core is compatible with the PIC18. If you wish to use this core in
production, please test the application thoroughly first.

1) TODO

   - Tidy up the code and split it into manageable chunks.
   - Optimise many of the parts (mainly PC and EA calculators).

================================================================================
CONTACT INFORMATION
================================================================================

Author	:	Shawn Tan
Email	:	shawn.tan@aeste.net
Website	:	www.aeste.net

Please do not hesitate to contact me if you use this core in any of your
applications.