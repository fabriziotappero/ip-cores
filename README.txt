
------------------------------ Remark ----------------------------------------
This code is a generic code written in RobustVerilog. In order to convert it to Verilog a RobustVerilog parser is required. 
It is possible to download a free RobustVerilog parser from www.provartec.com/edatools.

We will be very happy to receive any kind of feedback regarding our tools and cores. 
We will also be willing to support any company intending to integrate our cores into their project.
For any questions / remarks / suggestions / bugs please contact info@provartec.com.
------------------------------------------------------------------------------

RobustVerilog generic AXI master stub

In order to create the Verilog design use the run.sh script in the run directory (notice that the run scripts calls the robust binary (RobustVerilog parser)).

The RobustVerilog top source file is axi_master.v, it calls the top definition file named def_axi_master.txt.

The default definition file def_axi_master.txt generates an AXI master with 3 internal masters (AXI IDs), 64 bit data bus and command depth of 4.

Changing the stub parameters should be made only in def_axi_master.txt in the src/base directory (changing ID number, ID values, data width etc.).

Once the Verilog files have been generated instruction on how to use the stub are at the top of axi_master.v (tasks and parameters).


