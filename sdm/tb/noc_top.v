/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The mesh network for simulation. 
 
 History:
 03/03/2011  Initial version. <wsong83@gmail.com>
 30/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

// the router structure definitions
`include "define.v"

module noc_top(/*AUTOARG*/
   // Inputs
   rst_n
   );
   input rst_n;

   
   parameter DW = 32;
   parameter VCN = 1;
   parameter DIMX = 8;
   parameter DIMY = 8;
   parameter SCN = DW/2;

   wire [DIMX-1:0][DIMY-1:0][3:0][VCN*SCN-1:0] di0, di1, di2, di3;
   wire [DIMX-1:0][DIMY-1:0][3:0][VCN*SCN-1:0] do0, do1, do2, do3;
`ifdef ENABLE_CHANNEL_SLICING
   wire [DIMX-1:0][DIMY-1:0][3:0][VCN*SCN-1:0] di4, dia;
   wire [DIMX-1:0][DIMY-1:0][3:0][VCN*SCN-1:0] do4, doa;
`else
   wire [DIMX-1:0][DIMY-1:0][3:0][VCN-1:0]     di4, dia;
   wire [DIMX-1:0][DIMY-1:0][3:0][VCN-1:0]     do4, doa;
`endif

   genvar 				     x, y;   

   generate for(x=0; x<DIMX; x++) begin: DX
      for(y=0; y<DIMY; y++) begin: DY
	
	 node_top #(.DW(DW), .VCN(VCN), .x(x), .y(y))
	 NN (
	     .si0 (di0[x][y][0]), .si1 (di1[x][y][0]), .si2 (di2[x][y][0]), .si3 (di3[x][y][0]), .si4 (di4[x][y][0]), .sia (dia[x][y][0]),
	     .wi0 (di0[x][y][1]), .wi1 (di1[x][y][1]), .wi2 (di2[x][y][1]), .wi3 (di3[x][y][1]), .wi4 (di4[x][y][1]), .wia (dia[x][y][1]),
	     .ni0 (di0[x][y][2]), .ni1 (di1[x][y][2]), .ni2 (di2[x][y][2]), .ni3 (di3[x][y][2]), .ni4 (di4[x][y][2]), .nia (dia[x][y][2]),
	     .ei0 (di0[x][y][3]), .ei1 (di1[x][y][3]), .ei2 (di2[x][y][3]), .ei3 (di3[x][y][3]), .ei4 (di4[x][y][3]), .eia (dia[x][y][3]),
	     .so0 (do0[x][y][0]), .so1 (do1[x][y][0]), .so2 (do2[x][y][0]), .so3 (do3[x][y][0]), .so4 (do4[x][y][0]), .soa (doa[x][y][0]),
	     .wo0 (do0[x][y][1]), .wo1 (do1[x][y][1]), .wo2 (do2[x][y][1]), .wo3 (do3[x][y][1]), .wo4 (do4[x][y][1]), .woa (doa[x][y][1]),
	     .no0 (do0[x][y][2]), .no1 (do1[x][y][2]), .no2 (do2[x][y][2]), .no3 (do3[x][y][2]), .no4 (do4[x][y][2]), .noa (doa[x][y][2]),
	     .eo0 (do0[x][y][3]), .eo1 (do1[x][y][3]), .eo2 (do2[x][y][3]), .eo3 (do3[x][y][3]), .eo4 (do4[x][y][3]), .eoa (doa[x][y][3]),
	     .rst_n(rst_n)
	     );
	 
	 // north link
	 if(x==0) begin
	    assign di0[x][y][2] = do0[x][y][2];
	    assign di1[x][y][2] = do1[x][y][2];
	    assign di2[x][y][2] = do2[x][y][2];
	    assign di3[x][y][2] = do3[x][y][2];
	    assign di4[x][y][2] = do4[x][y][2];
	    assign doa[x][y][2] = dia[x][y][2];
	 end else begin
	    assign di0[x][y][2] = do0[x-1][y][0];
	    assign di1[x][y][2] = do1[x-1][y][0];
	    assign di2[x][y][2] = do2[x-1][y][0];
	    assign di3[x][y][2] = do3[x-1][y][0];
	    assign di4[x][y][2] = do4[x-1][y][0];
	    assign doa[x-1][y][0] = dia[x][y][2];
	 end	    

	 // south link
	 if(x==DIMX-1) begin
	    assign di0[x][y][0] = do0[x][y][0];
	    assign di1[x][y][0] = do1[x][y][0];
	    assign di2[x][y][0] = do2[x][y][0];
	    assign di3[x][y][0] = do3[x][y][0];
	    assign di4[x][y][0] = do4[x][y][0];
	    assign doa[x][y][0] = dia[x][y][0];
	 end else begin
	    assign di0[x][y][0] = do0[x+1][y][2];
	    assign di1[x][y][0] = do1[x+1][y][2];
	    assign di2[x][y][0] = do2[x+1][y][2];
	    assign di3[x][y][0] = do3[x+1][y][2];
	    assign di4[x][y][0] = do4[x+1][y][2];
	    assign doa[x+1][y][2] = dia[x][y][0];
	 end

	 // west link
	 if(y==0) begin
	    assign di0[x][y][1] = do0[x][y][1];
	    assign di1[x][y][1] = do1[x][y][1];
	    assign di2[x][y][1] = do2[x][y][1];
	    assign di3[x][y][1] = do3[x][y][1];
	    assign di4[x][y][1] = do4[x][y][1];
	    assign doa[x][y][1] = dia[x][y][1];
	 end else begin
	    assign di0[x][y][1] = do0[x][y-1][3];
	    assign di1[x][y][1] = do1[x][y-1][3];
	    assign di2[x][y][1] = do2[x][y-1][3];
	    assign di3[x][y][1] = do3[x][y-1][3];
	    assign di4[x][y][1] = do4[x][y-1][3];
	    assign doa[x][y-1][3] = dia[x][y][1];
	 end // else: !if(y==0)

	 // east link
	 if(y==DIMY-1) begin
	    assign di0[x][y][3] = do0[x][y][3];
	    assign di1[x][y][3] = do1[x][y][3];
	    assign di2[x][y][3] = do2[x][y][3];
	    assign di3[x][y][3] = do3[x][y][3];
	    assign di4[x][y][3] = do4[x][y][3];
	    assign doa[x][y][3] = dia[x][y][3];
	 end else begin
	    assign di0[x][y][3] = do0[x][y+1][1];
	    assign di1[x][y][3] = do1[x][y+1][1];
	    assign di2[x][y][3] = do2[x][y+1][1];
	    assign di3[x][y][3] = do3[x][y+1][1];
	    assign di4[x][y][3] = do4[x][y+1][1];
	    assign doa[x][y+1][1] = dia[x][y][3];
	 end // else: !if(y==DIMY-1)

      end // block: DY
   end // block: DX
   endgenerate
   
endmodule // noc_top
