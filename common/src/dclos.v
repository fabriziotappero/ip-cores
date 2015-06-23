/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Data Clos network.
 *** SystemVerilog is used ***
 
 History:
 17/07/2010  Initial version. <wsong83@gmail.com>
 20/09/2010  Supporting channel slicing and SDM using macro difinitions. <wsong83@gmail.com>
 23/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

// the router structure definitions
`include "define.v"

module dclos (/*AUTOARG*/
   // Outputs
   so0, so1, so2, so3, wo0, wo1, wo2, wo3, no0, no1, no2, no3, eo0,
   eo1, eo2, eo3, lo0, lo1, lo2, lo3, so4, wo4, no4, eo4, lo4, sia,
   wia, nia, eia, lia,
   // Inputs
   si0, si1, si2, si3, wi0, wi1, wi2, wi3, ni0, ni1, ni2, ni3, ei0,
   ei1, ei2, ei3, li0, li1, li2, li3, si4, wi4, ni4, ei4, li4, soa,
   woa, noa, eoa, loa, imcfg, scfg, ncfg, wcfg, ecfg, lcfg
   );
   
   parameter MN = 2;		// number of CMs
   parameter NN = 2;		// number of ports in an IM or OM, equ. to number of virtual circuits
   parameter DW = 8;		// datawidth of a single virtual circuit/port
   parameter SCN = DW/2;	// number of 1-of-4 sub-channels in one port

   input [NN-1:0][SCN-1:0]     si0, si1, si2, si3; // south input [0], X+1
   input [NN-1:0][SCN-1:0]     wi0, wi1, wi2, wi3; // west input [1], Y-1
   input [NN-1:0][SCN-1:0]     ni0, ni1, ni2, ni3; // north input [2], X-1
   input [NN-1:0][SCN-1:0]     ei0, ei1, ei2, ei3; // east input [3], Y+1
   input [NN-1:0][SCN-1:0]     li0, li1, li2, li3; // local input
   output [NN-1:0][SCN-1:0]    so0, so1, so2, so3; // south output
   output [NN-1:0][SCN-1:0]    wo0, wo1, wo2, wo3; // west output
   output [NN-1:0][SCN-1:0]    no0, no1, no2, no3; // north output
   output [NN-1:0][SCN-1:0]    eo0, eo1, eo2, eo3; // east output
   output [NN-1:0][SCN-1:0]    lo0, lo1, lo2, lo3; // local output

   // eof bits and ack lines
`ifdef ENABLE_CHANNEL_SLICING
   input [NN-1:0][SCN-1:0]     si4, wi4, ni4, ei4, li4;
   output [NN-1:0][SCN-1:0]    so4, wo4, no4, eo4, lo4;
   output [NN-1:0][SCN-1:0]    sia, wia, nia, eia, lia;
   input [NN-1:0][SCN-1:0]     soa, woa, noa, eoa, loa;
`else
   input [NN-1:0] 	       si4, wi4, ni4, ei4, li4;
   output [NN-1:0] 	       so4, wo4, no4, eo4, lo4;
   output [NN-1:0] 	       sia, wia, nia, eia, lia;
   input [NN-1:0] 	       soa, woa, noa, eoa, loa;
`endif // !`ifdef ENABLE_CHANNEL_SLICING

   input [4:0][MN-1:0][NN-1:0] imcfg; // configuration for IMs
   // configuration for CMs
   input [MN-1:0][1:0] 	       scfg, ncfg;
   input [MN-1:0][3:0] 	       wcfg, ecfg, lcfg;
   // no OMs

   // output of IMs
   wire [MN-1:0][SCN-1:0]      imos0, imos1, imos2, imos3;
   wire [MN-1:0][SCN-1:0]      imow0, imow1, imow2, imow3;
   wire [MN-1:0][SCN-1:0]      imon0, imon1, imon2, imon3;
   wire [MN-1:0][SCN-1:0]      imoe0, imoe1, imoe2, imoe3;
   wire [MN-1:0][SCN-1:0]      imol0, imol1, imol2, imol3;
`ifdef ENABLE_CHANNEL_SLICING
   wire [MN-1:0][SCN-1:0]      imos4, imow4, imon4, imoe4, imol4;
   wire [MN-1:0][SCN-1:0]      imosa, imowa, imona, imoea, imola;
`else
   wire [MN-1:0] 	       imos4, imow4, imon4, imoe4, imol4;
   wire [MN-1:0] 	       imosa, imowa, imona, imoea, imola;
`endif

   // input of CMs
   wire [MN-1:0][4:0][SCN-1:0] cmi0, cmi1, cmi2, cmi3;
`ifdef ENABLE_CHANNEL_SLICING
   wire [MN-1:0][4:0][SCN-1:0] cmi4, cmia;
`else
   wire [MN-1:0][4:0] 	       cmi4, cmia;
`endif

   // output of CMs
   wire [MN-1:0][4:0][SCN-1:0] cmo0, cmo1, cmo2, cmo3;
`ifdef ENABLE_CHANNEL_SLICING
   wire [MN-1:0][4:0][SCN-1:0] cmo4, cmoa;
`else
   wire [MN-1:0][4:0] 	       cmo4, cmoa;
`endif
   
   genvar 		       i,j,k;

   dcb #(.NN(NN), .MN(MN), .DW(DW))
   SIM (
       .o0  ( imos0    ),
       .o1  ( imos1    ),
       .o2  ( imos2    ),
       .o3  ( imos3    ),
       .o4  ( imos4    ),
       .ia  ( sia      ),
       .i0  ( si0      ),
       .i1  ( si1      ),
       .i2  ( si2      ),
       .i3  ( si3      ),
       .i4  ( si4      ),
       .oa  ( imosa    ),
       .cfg ( imcfg[0] )
       );

   dcb #(.NN(NN), .MN(MN), .DW(DW))
   WIM (
       .o0  ( imow0    ),
       .o1  ( imow1    ),
       .o2  ( imow2    ),
       .o3  ( imow3    ),
       .o4  ( imow4    ),
       .ia  ( wia      ),
       .i0  ( wi0      ),
       .i1  ( wi1      ),
       .i2  ( wi2      ),
       .i3  ( wi3      ),
       .i4  ( wi4      ),
       .oa  ( imowa    ),
       .cfg ( imcfg[1] )
       );
   
   dcb #(.NN(NN), .MN(MN), .DW(DW))
   NIM (
       .o0  ( imon0    ),
       .o1  ( imon1    ),
       .o2  ( imon2    ),
       .o3  ( imon3    ),
       .o4  ( imon4    ),
       .ia  ( nia      ),
       .i0  ( ni0      ),
       .i1  ( ni1      ),
       .i2  ( ni2      ),
       .i3  ( ni3      ),
       .i4  ( ni4      ),
       .oa  ( imona    ),
       .cfg ( imcfg[2] )
       );
   
   dcb #(.NN(NN), .MN(MN), .DW(DW))
   EIM (
       .o0  ( imoe0    ),
       .o1  ( imoe1    ),
       .o2  ( imoe2    ),
       .o3  ( imoe3    ),
       .o4  ( imoe4    ),
       .ia  ( eia      ),
       .i0  ( ei0      ),
       .i1  ( ei1      ),
       .i2  ( ei2      ),
       .i3  ( ei3      ),
       .i4  ( ei4      ),
       .oa  ( imoea    ),
       .cfg ( imcfg[3] )
       );

   dcb #(.NN(NN), .MN(MN), .DW(DW))
   LIM (
       .o0  ( imol0    ),
       .o1  ( imol1    ),
       .o2  ( imol2    ),
       .o3  ( imol3    ),
       .o4  ( imol4    ),
       .ia  ( lia      ),
       .i0  ( li0      ),
       .i1  ( li1      ),
       .i2  ( li2      ),
       .i3  ( li3      ),
       .i4  ( li4      ),
       .oa  ( imola    ),
       .cfg ( imcfg[4] )
       );

   generate for(i=0; i<MN; i++) begin: IMSHF
      // shuffle the interconnects between IMs and CMs
      assign cmi0[i][0] = imos0[i];
      assign cmi1[i][0] = imos1[i];
      assign cmi2[i][0] = imos2[i];
      assign cmi3[i][0] = imos3[i];
      assign cmi4[i][0] = imos4[i];
      assign imosa[i] = cmia[i][0];
      
      assign cmi0[i][1] = imow0[i];
      assign cmi1[i][1] = imow1[i];
      assign cmi2[i][1] = imow2[i];
      assign cmi3[i][1] = imow3[i];
      assign cmi4[i][1] = imow4[i];
      assign imowa[i] = cmia[i][1];
      
      assign cmi0[i][2] = imon0[i];
      assign cmi1[i][2] = imon1[i];
      assign cmi2[i][2] = imon2[i];
      assign cmi3[i][2] = imon3[i];
      assign cmi4[i][2] = imon4[i];
      assign imona[i] = cmia[i][2];

      assign cmi0[i][3] = imoe0[i];
      assign cmi1[i][3] = imoe1[i];
      assign cmi2[i][3] = imoe2[i];
      assign cmi3[i][3] = imoe3[i];
      assign cmi4[i][3] = imoe4[i];
      assign imoea[i] = cmia[i][3];
   
      assign cmi0[i][4] = imol0[i];
      assign cmi1[i][4] = imol1[i];
      assign cmi2[i][4] = imol2[i];
      assign cmi3[i][4] = imol3[i];
      assign cmi4[i][4] = imol4[i];
      assign imola[i] = cmia[i][4];

      // CM modules
      dcb_xy #(.VCN(1), .VCW(DW))
      CM (
	  .sia   ( cmia[i][0]   ), 
	  .wia   ( cmia[i][1]   ), 
	  .nia   ( cmia[i][2]   ), 
	  .eia   ( cmia[i][3]   ), 
	  .lia   ( cmia[i][4]   ), 
	  .so0   ( cmo0[i][0]   ), 
	  .so1   ( cmo1[i][0]   ), 
	  .so2   ( cmo2[i][0]   ), 
	  .so3   ( cmo3[i][0]   ), 
	  .so4   ( cmo4[i][0]   ), 
	  .wo0   ( cmo0[i][1]   ), 
	  .wo1   ( cmo1[i][1]   ), 
	  .wo2   ( cmo2[i][1]   ),
	  .wo3   ( cmo3[i][1]   ), 
	  .wo4   ( cmo4[i][1]   ) , 
	  .no0   ( cmo0[i][2]   ), 
	  .no1   ( cmo1[i][2]   ), 
	  .no2   ( cmo2[i][2]   ), 
	  .no3   ( cmo3[i][2]   ), 
	  .no4   ( cmo4[i][2]   ), 
	  .eo0   ( cmo0[i][3]   ), 
	  .eo1   ( cmo1[i][3]   ), 
	  .eo2   ( cmo2[i][3]   ), 
	  .eo3   ( cmo3[i][3]   ), 
	  .eo4   ( cmo4[i][3]   ), 
	  .lo0   ( cmo0[i][4]   ),
	  .lo1   ( cmo1[i][4]   ), 
	  .lo2   ( cmo2[i][4]   ), 
	  .lo3   ( cmo3[i][4]   ), 
	  .lo4   ( cmo4[i][4]   ),
	  .si0   ( cmi0[i][0]   ), 
	  .si1   ( cmi1[i][0]   ), 
	  .si2   ( cmi2[i][0]   ), 
	  .si3   ( cmi3[i][0]   ), 
	  .si4   ( cmi4[i][0]   ), 
	  .wi0   ( cmi0[i][1]   ), 
	  .wi1   ( cmi1[i][1]   ), 
	  .wi2   ( cmi2[i][1]   ), 
	  .wi3   ( cmi3[i][1]   ), 
	  .wi4   ( cmi4[i][1]   ), 
	  .ni0   ( cmi0[i][2]   ), 
	  .ni1   ( cmi1[i][2]   ), 
	  .ni2   ( cmi2[i][2]   ),
	  .ni3   ( cmi3[i][2]   ), 
	  .ni4   ( cmi4[i][2]   ), 
	  .ei0   ( cmi0[i][3]   ), 
	  .ei1   ( cmi1[i][3]   ), 
	  .ei2   ( cmi2[i][3]   ), 
	  .ei3   ( cmi3[i][3]   ), 
	  .ei4   ( cmi4[i][3]   ), 
	  .li0   ( cmi0[i][4]   ), 
	  .li1   ( cmi1[i][4]   ), 
	  .li2   ( cmi2[i][4]   ), 
	  .li3   ( cmi3[i][4]   ), 
	  .li4   ( cmi4[i][4]   ), 
	  .soa   ( cmoa[i][0]   ),
	  .woa   ( cmoa[i][1]   ), 
	  .noa   ( cmoa[i][2]   ), 
	  .eoa   ( cmoa[i][3]   ), 
	  .loa   ( cmoa[i][4]   ), 
	  .wcfg  ( wcfg[i]      ), 
	  .ecfg  ( ecfg[i]      ), 
	  .lcfg  ( lcfg[i]      ), 
	  .scfg  ( scfg[i]      ), 
	  .ncfg  ( ncfg[i]      )
	  );

      // shuffle between CMs and OMs(OPs)
      assign so0[i] = cmo0[i][0];
      assign so1[i] = cmo1[i][0];
      assign so2[i] = cmo2[i][0];
      assign so3[i] = cmo3[i][0];
      assign so4[i] = cmo4[i][0];
      assign cmoa[i][0] = soa[i];

      assign wo0[i] = cmo0[i][1];
      assign wo1[i] = cmo1[i][1];
      assign wo2[i] = cmo2[i][1];
      assign wo3[i] = cmo3[i][1];
      assign wo4[i] = cmo4[i][1];
      assign cmoa[i][1] = woa[i];
      
      assign no0[i] = cmo0[i][2];
      assign no1[i] = cmo1[i][2];
      assign no2[i] = cmo2[i][2];
      assign no3[i] = cmo3[i][2];
      assign no4[i] = cmo4[i][2];
      assign cmoa[i][2] = noa[i];

      assign eo0[i] = cmo0[i][3];
      assign eo1[i] = cmo1[i][3];
      assign eo2[i] = cmo2[i][3];
      assign eo3[i] = cmo3[i][3];
      assign eo4[i] = cmo4[i][3];
      assign cmoa[i][3] = eoa[i];

      assign lo0[i] = cmo0[i][4];
      assign lo1[i] = cmo1[i][4];
      assign lo2[i] = cmo2[i][4];
      assign lo3[i] = cmo3[i][4];
      assign lo4[i] = cmo4[i][4];
      assign cmoa[i][4] = loa[i];
   end // block: IMSHF
      
   endgenerate

   
endmodule // dclos


      
       
      

     
      
	    
	     