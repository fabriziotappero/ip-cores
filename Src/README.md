M65C02 Processor Core Source Files
==================================

Copyright (C) 2012, Michael A. Morris <morrisma@mchsi.com>.
All Rights Reserved.

Released under LGPL.

Organization
------------

The source files are provided in subdirectories:

    M65C02-Test-Programs
    Memory-Images
    Microprogram-Sources
    RTL
    Settings
    
The contents of each of the subdirectories is provided below.

The M65C02 test programs as assembler programs. Two test programs are 
provided. The first program was a simple program used to test the operation of 
jumps, branches, stack operations, and register transfers. With this test 
program, a major part of the microprogram was tested and verified.

The second test program is a more complete program. All instructions, i.e. all 
256 opcodes, are tested using the second program. The operation of the 
interrupt logic and the automatic wait state inserted during decimal (BCD) 
mode addition and subtraction (ADC/SBC) are also tested with the second test 
program. It is not a comprehensive diagnostics program. Examination of the 
simulation output was used to test the operation of many of the M65C02's 
instructions. However, the second test program does contain some self-checks, 
and those were used to speed the process of testing each instruction and each 
addressing mode. (The most recent release of the core, Release 2.2, exposed an 
issue that affected the PSW on entry into the ISR. Proper adjustment of the 
PSW in the PSW  was not being tested within the simulated ISR. The problem was 
detected further into the test program when and BCD arithmetic failed. Since 
this is a critical behavior, the ISR has been modified to include checks that 
verify that the BCD mode (PSW.D) is not set, and that interrupt mask is set 
(PSW.I) when the ISR is entered.)

The M65C02 is a microprogrammed implementation. There are two microprogram 
memories used. The first, M65C02_Decoder_ROM, provides the control of the ALU 
during the execute phase. The second, M65C02_uPgm_V3, provides the control of 
the core. That is, the second microprogram implements each addressing mode, 
deals with interrupts and BRK, and controls the fetching and execution of all 
instructions. Both microprogram ROMs include an instruction decoder. When the 
instruction is present on the input data bus, it is captured into the 
instruction register, IR, but it is simultaneously applied to the address bus 
of the two microprogram ROMs.

In the Decoder ROM, the opcode is applied in a normal fashion, so the Decoder 
ROM is organized linearly. In the uPgm ROM, the opcode is applied to the 
address bus with the opcode's nibbles swapped. Thus, the instruction decoder 
in the uPgm ROM is best thought of as being organized by the rows in the 
opcode matrix of the M65C02.

There are three memory image files provided in the corresponding subdirectory. 
One is for the M65C02 test program, and the other two are for the microprogram 
ROMs. The microprogram ROMs are implemented using Block RAMs, whose contents 
are initialized by the contents of the two microprogram ROM image files.

The RTL source files are provided along with a user constraint file (UCF) that 
was used during development to optimize the implementation times of the core. 
The UCF does provide the PERIOD constraint used during development to judge 
whether the operating speed objective would be met by the M65C02. The LOCing 
of the pins was done to aid the implementation tools, and is not reflective of 
any implementation constraints inherent in the M65C02 core logic.

The project, synthesis, and implementation settings were captured in a TCL 
file. That file allows the duplication of the exact settings used to 
synthesize and implement it in a Spartan-3AN FPGA.

M65C02-Test-Programs
--------------------

    M65C02_Tst3.a65         - Kingswood A65 assembler source code test program
        M65C02.bin          - M65C02_Tst2.a65 output of the Kingswood assembler
        M65C02.txt          - M65C02_Tst2.a65 ASCII hex output of bin2txt.exe
    M65C02_Tst.A65          - First test pgm: jmps, branches, stk ops, transfers

Memory-Images
-------------

    M65C02_Decoder_ROM.coe  - M65C02 core microprogram ALU control fields
    M65C02_uPgm_V3a.coe     - M65C02 core microprogram (Addressing mode control)
    M65C02_Tst3.txt         - Memory initialization file for M65C02 test program

Microprogram-Sources
--------------------
    
    M65C02_Decoder_ROM.txt      - M65C02 core microprogram ALU control fields
        M65C02_Decoder_ROM.out  - Listing file
    M65C02_uPgm_V3a.txt         - M65C02 core microprogram (sequence control)
        M65C02_uPgm_V3a.out     - Listing file

RTL
-------------

The implementation of the core provided consists of five Verilog source files:

    M65C02_Core.v               - Top level module
        M65C02_MPCv3.v          - Microprogram Controller (Fairchild F9408 MPC)
        M65C02_AddrGen.v        - M65C02 Address Generator module
        M65C02_ALU.v            - M65C02 ALU module
            M65C02_BIN.v        - M65C02 Binary Mode Adder module
            M65C02_BCD.v        - M65C02 Decimal Mode Adder module
    M65C02.ucf                  - User Constraints File: period and pin LOCs
    
In addition to the above files, the directory also contains another core. This 
core is the base core and is based on the original release, but includes the 
corrections needed to perform all zero page addressing modes correctly. The 
solution employed for this version of the core is implemented in logic instead 
of in the microprogram. The results are the same, but less flexible. Thus, if 
this core would be extended to support additional instructions, then the 
solution used for correctly supporting zero page addressing modes may require 
modification, and it can impose limits on the microprogram. This core has been 
maintained while the new core is being migrated to support LUT, BRAM, and 
external SynchRAM using a microcycle length controller in the microprogram 
controller instead of an asynchronous wait state inserter in the microprogram 
controller. The files for the base (original) core are:

    M65C02_Base.v               - Top level module
        M65C02_MPC.v            - Microprogram Controller (Fairchild F9408 MPC)
        M65C02_AddrGen.v        - M65C02 Address Generator module
        M65C02_ALU.v            - M65C02 ALU module
            M65C02_BIN.v        - M65C02 Binary Mode Adder module
            M65C02_BCD.v        - M65C02 Decimal Mode Adder module
    M65C02.ucf                  - User Constraints File: period and pin LOCs

As can be seen, only the core logic file and the microprogram controller are 
different between the two implementations. The fixed portion of the 
microprogram (which implements the ALU control word) is also common, but the 
variable microprogram (which implements the addressing modes, instruction 
sequences, and trap handling) are different. For this base (original) core, 
the microprogram files are the following:
    
    M65C02_Decoder_ROM.txt      - M65C02 core microprogram ALU control fields
        M65C02_Decoder_ROM.out  - Listing file
    M65C02_uPgm_V3.txt          - M65C02 core microprogram (sequence control)
        M65C02_uPgm_V3.out      - Listing file

Settings
-------------

    M65C02.tcl              - Project settings file
    
Status
------

All files are current.