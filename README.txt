
------------------------------ Remark ----------------------------------------
This code is a generic code written in RobustVerilog. In order to convert it to Verilog a RobustVerilog parser is required. 
It is possible to download a free RobustVerilog parser from www.provartec.com/edatools.

We will be very happy to receive any kind of feedback regarding our tools and cores. 
We will also be willing to support any company intending to integrate our cores into their project.
For any questions / remarks / suggestions / bugs please contact info@provartec.com.
------------------------------------------------------------------------------

RobustVerilog generic AXI interconnect fabric 

In order to create the Verilog design use the run.sh script in the run directory (notice that the run scripts calls the robust binary (RobustVerilog parser)).

The RobustVerilog top source file is ic.v, it calls the top definition file named def_ic.txt.

The default definition file def_ic.txt generates a fabric with 3 masters and 6 slaves.

Changing the interconnect parameters should be made only in def_ic.txt in the src/base directory (changing master num, slave num etc.).




