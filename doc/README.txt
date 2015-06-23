How to understand the SXP architecture. 
--------------------------------------
A graphic showing the architecture diagram will
be supplied very soon.

The processor is a pipelined processor which means
that instructions are processed like an assembly line.

The pipeline is broken into stages that do specific
things with each instruction.

The stages for the SXP are as such.

Fetch - Get instructions from memory and control program counter
Reg File - local register storage and look up
ALU - Arithmetic logic unit / data munging
WB - Determine where the data from the ALU/MEM READ/EXT BUS gets written back to.

Please see the instr.txt document to see how instructions are built but
basically an instruction is broken up into control fragments for each 
one of these mentioned stages. That is why is was mentioned  
that the instructions are non conventional and we get the added
bonus of no Decoder stage and thus a faster pipeline. Each stage
is responsible for reading a small section of the instruction and
figuring out what to do with the rest of the data in the instruction or
in the pipeline from the previous stage. 
A conventional processor with standard instructions needs a decoder to
turn the instructions into microcode (possibly) the then a controller
to turn the microcode into fragments that control each pipeline when
necessary.

This is a very simple processor. Right now it is not intended to
be a processor with diferent modes and other high level functions.
(Although those features can be added at a later time or in another
version.)
There is a need for both low level microcontrollers and the feature
filled microprocessors. It is just a question of scope and intended
design goals. 



Sections of the SXP code
------------------------
Verilog simulation of the SXP:
  The SXP processor was written in Verilog code and tested with the
  GPL'ed Icarus verilog simulator. If you want to follow this path
  then please get the latest development snapshot. I have tested
  the current realease on Icaurus and everything works as 
  expected.

SXP C++ Model 
  The C++ model is an attempt to simulate the operation of the
  SXP in C++ code. It is not perfect but the current implementation
  will simulate ok.

Visual Instruction Development tool - coder.tcl
  coder.tcl is a TK/TCL tool that help to develop
  small assembly language programs. 

Assembly language verilog files.
  All assembly language files are in verilog memory format.
  This is done for easy simulation in verilog. Tools can later
  be written to translate verilog memory files into binary
  files.  (This will be useful if the SXP is synthesized into
  an FPGA.)



Directory structure
-------------------

- /doc
    instr.txt - Assembly Instruction Documentation
    int_cont.txt - Interupt documentation
    README.txt - This file

- /sim
    test_sxp.v  -  Testbench for SXP processor
    test.sxp - Assembly language instructions file
    (Written in verilog memory format. Loaded into instruction RAM)

- /src
    sxp.v - SXP processor top level verilog
    
- /fetch
    /src
      fetch.v - fetch module code
    /sim
      test_fetch.v - testbench for fetch module

- /dpmem
    /src
      dpmem.v - behavioral dual port memory
    /sim
      test_mem.v - Testbench for behavioral dual port memory

- /tcl
    coder.tcl - TCL/TK Visual Instruction Development Tool

- /int_cont
    /src
      int_cont.v - interupt controller module verilog code
    /sim
      test_int_cont.v - testbench for interupt controller

- /regf
    /src
      mem_regf.v - memory based reg file
      sync_regf.v - syncronous reg file
      regf_status.v - scoreboard module for reg file
    /sim
      test_regf.v - testbench for reg file

- /timer_cont
    /src
      timer_cont.v - timer controller module verilog source
    /sim
      test_timer.v - testbench for timer controller 
       
- /csim - C++ model of SXP processor
- /csim/alu/alu.cc - alu c++ model
- /csim/ext/ext.cc - ext bus c++ model
- /csim/fetch/fetch.cc - fetch module c++ model
- /csim/memory/memory.cc - memory c++ model
- /csim/reg_file/reg_file.cc - register file c++ model
- /csim/sxp/sxp.cc - SXP processor main class for processor
    run_sxp - executable script to run the c++ model
    sxp_sim.cc - c++ simulation file (instantiates the processor and runs code)
    test.sxp - Assembly language code (Verilog based memory file)

      
