/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Test bench.
 
 History:
 03/03/2011  Initial version. <wsong83@gmail.com>
 05/06/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

`timescale 1ns/1ps

module noctb;
   parameter DW = 8;		// the data width of a single virtual circuit
   parameter VCN = 2;		// the number of VCs per direction
   parameter DIMX = 4;		// the X dimension
   parameter DIMY = 4;		// the Y dimension
   
   reg rst_n;
   
   noc_top #(.DW(DW), .VCN(VCN), .DIMX(DIMX), .DIMY(DIMY))
   NoC (.rst_n(rst_n));		// the mesh network

   AnaProc ANAM();		// the global performance analyser
   
   initial begin
      rst_n = 0;

      # 133;

      rst_n = 1;

   end

endmodule // noctb



   
