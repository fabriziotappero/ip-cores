Simulation Files description:
-------------------------------------------

1. RS_dec_tb.v:
-----------------------
Verilog test bench to test the Reed Solomon Decoder core, 
by feeding input test cases to the core and compare outputs of 
the core with true outputs, (using input and output files), the test
bench is configured to make a functional simulation to the core, in case
of post place and route simulation you should uncomment the timescale 
on the first line of the test bench and set the required clock value by 
configuring the value of the parameter pclk.

2.input_RS_blocks:
-----------------------------
the inputs file, the test bench uses this file to feed inputs to the core, the file 
should contain the input bytes in binary format, every line should contain 
a single byte. 

2.output_RS_blocks:
-------------------------------
the outputs file, the test bench uses this file to verify the outputs from the core, the file 
should contain the true output bytes in binary format, every line should contain 
a single byte. 

3.RS_test_vectors.m:
--------------------------------
MATLAB script to generate test vectors for the core, it will generate random data and
encode it using MATLAB rs_enc then put errors on the code from 0:8 byte errors 
on every codeword, then it will generate inputs and outputs test files to be used 
by the Verilog test bench.

4.wave.do
----------------
Modelsim wave file contain inputs and outputs port of the design.

5.do.do
-------------
Modelsim macro to compile the verilog files, load the wave file, and start functional simulation.
and the file depends on directory structure of simulation and rtl directories.(must use 
the same directory structure to work in a proper way).