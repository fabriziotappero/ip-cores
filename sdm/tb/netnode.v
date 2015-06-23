/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The SystemC module of network node including the processing element and the network interface.
 Currently the transmission FIFO is 500 frame deep.
   
 History:
 27/02/2011  Initial version. <wsong83@gmail.com>
 30/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

`include "define.v"

module NetNode (
		dia, do4, doa, di4,
		do0, do1, do2, do3,
		di0, di1, di2, di3,
		rst_n)
   //
   // The foreign attribute string value must be a SystemC value.
   //
   (* integer foreign = "SystemC";
    *);
   //
   // Verilog port names must match port names exactly as they appear in the
   // sc_module class in SystemC; they must also match in order, mode, and type.
   //
   parameter DW = 32;
   parameter VCN = 1;
   parameter x = 2;
   parameter y = 2;
   parameter SCN = DW/2;
   
`ifdef ENABLE_CHANNEL_SLICING
   input [VCN*SCN-1:0] dia;
   input [VCN*SCN-1:0] do4;
   output [VCN*SCN-1:0] doa;
   output [VCN*SCN-1:0] di4;   
`else
   input [VCN-1:0] dia;
   input [VCN-1:0] do4;
   output [VCN-1:0] doa;
   output [VCN-1:0] di4;   
`endif // !`ifdef ENABLE_CHANNEL_SLICING

   input [VCN*SCN-1:0] do0;
   input [VCN*SCN-1:0] do1;
   input [VCN*SCN-1:0] do2;
   input [VCN*SCN-1:0] do3;
   
   output [VCN*SCN-1:0] di0;
   output [VCN*SCN-1:0] di1;
   output [VCN*SCN-1:0] di2;
   output [VCN*SCN-1:0] di3;

   input 		rst_n;

   
endmodule // NetNode

   
