
------------------------------ Remark ----------------------------------------
This code is a generic code written in RobustVerilog. In order to convert it to Verilog a RobustVerilog parser is required. 
It is possible to download a free RobustVerilog parser from www.provartec.com/edatools.

We will be very happy to receive any kind of feedback regarding our tools and cores. 
We will also be willing to support any company intending to integrate our cores into their project.
For any questions / remarks / suggestions / bugs please contact info@provartec.com.
------------------------------------------------------------------------------

RobustVerilog generic APB master stub

The APB master is built out of an AXI master and an AXI2APB bridge (both independent OpenCores projects)

In order to create the Verilog design use the run.sh script in the run directory (notice that the run scripts calls the robust binary (RobustVerilog parser)).

The RobustVerilog top source file is apb_master.v, it calls the top definition file named def_apb_master.txt.

Changing the stub parameters should be made only in def_apb_master.txt in the src/base directory (changing to APB3, address bits, etc.).

Once the Verilog files have been generated instruction on how to use the stub are at the top of apb_master.v (tasks and parameters).

