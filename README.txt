
------------------------------ Remark ----------------------------------------
This code is a generic code written in RobustVerilog. In order to convert it to Verilog a RobustVerilog parser is required. 
It is possible to download a free RobustVerilog parser from www.provartec.com/edatools.

We will be very happy to receive any kind of feedback regarding our tools and cores. 
We will also be willing to support any company intending to integrate our cores into their project.
For any questions / remarks / suggestions / bugs please contact info@provartec.com.
------------------------------------------------------------------------------

RobustVerilog generic FIR filter

In order to create the Verilog design use the run.sh script in the run directory (notice that the run scripts calls the robust binary (RobustVerilog parser)).

The filter can be built according to 3 different architectures, parallel, serial or something in the middle (named Nserial).

The architecture is determined according to the MACNUM parameter (multiplayer-accumulator).

The RobustVerilog top source file is fir.v. The command line calls it with an additional definition file named def_fir_top.txt

The default definition file def_fir_top.txt generates 3 filters, 1 parallel, 1 serial and 1 Nserial.

Changing the interconnect parameters should be made only in def_fir_top.txt in the src/base directory (changing multiplier number, filter order etc.).

