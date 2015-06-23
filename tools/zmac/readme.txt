Several things are happening here:

1. Generation of Z80 test code for ModelSim and FPGA at the "host/basic" level:

  Run the batch file "make_fpga.bat" generate "fpga.hex" from a test source file.
  This file is included by the host/basic/ram.v module into the FPGA image.

2. Generation of Z80 test code for the toplevel A-Z80 CPU ModelSim at the
   "cpu/toplevel/simulation/modelsim" level:

  Run the batch file "make_modelsim.bat" to generate this test file.

  /cpu/toplevel/tb_ram.sv is a ModelSim test bench for the toplevel A-Z80 block.
  There is no "host board" at that level but ModelSim's UART device will capture
  and print any output.

  "ram.hexdump" contains the test code that provides UART print functions as well
  as INT/NMI handlers used to test interrupts.

Currently tested sources which should work in both of those use cases:

     "hello_world.asm" - simply test UART print out functions

     "test.daa.asm" - runs DAA instruction on all values. The output should be
     ASCII-identical to the output of the DAA tests at tools/dongle/daa

     "test.neg.asm" - runs NEG instruction on all values. The output should be
     ASCII-identical to the output of the NEG tests at tools/dongle/neg

     "zexdoc.asm" - modified ZEXDOC test program
