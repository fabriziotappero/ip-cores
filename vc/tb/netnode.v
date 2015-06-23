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
 05/06/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

`include "define.v"

module NetNode (
		doa, doc, do0, do1, do2, do3, doft, dovc, doca,
		dia, dic, di0, di1, di2, di3, dift, divc, dica,
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
   parameter FT = 3;
   parameter x = 2;
   parameter y = 2;
   parameter SCN = DW/2;
   
   output               doa ;
   output [VCN-1:0] 	doc ;
   input [SCN-1:0] 	do0 ;
   input [SCN-1:0] 	do1 ;
   input [SCN-1:0] 	do2 ;
   input [SCN-1:0] 	do3 ;
   input [FT-1:0] 	doft;
   input [VCN-1:0] 	dovc;
   input [VCN-1:0] 	doca;
   input 		dia;
   input [VCN-1:0] 	dic;
   output [SCN-1:0] 	di0;
   output [SCN-1:0] 	di1;
   output [SCN-1:0] 	di2;
   output [SCN-1:0] 	di3;
   output [FT-1:0] 	dift;
   output [VCN-1:0] 	divc;
   output [VCN-1:0] 	dica;
   

   input 		rst_n;

   
endmodule // NetNode

   
