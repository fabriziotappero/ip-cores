/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Data crossbar for wormhole and SDM routers.
 Optimized by removing disabled turn models according to the XY routing algorithm.
 *** SystemVerilog is used ***
 
 History:
 21/08/2009  Initial version. <wsong83@gmail.com>
 20/09/2010  Supporting channel slicing and SDM using macro difinitions. <wsong83@gmail.com>
 23/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

// the router structure definitions
`include "define.v"

module dcb_xy (/*AUTOARG*/
   // Outputs
   so0, so1, so2, so3, wo0, wo1, wo2, wo3, no0, no1, no2, no3, eo0,
   eo1, eo2, eo3, lo0, lo1, lo2, lo3, so4, sia, wo4, wia, no4, nia,
   eo4, eia, lo4, lia,
   // Inputs
   si0, si1, si2, si3, wi0, wi1, wi2, wi3, ni0, ni1, ni2, ni3, ei0,
   ei1, ei2, ei3, li0, li1, li2, li3, si4, soa, wi4, woa, ni4, noa,
   ei4, eoa, li4, loa, scfg, ncfg, wcfg, ecfg, lcfg
   ) ;

   parameter VCN = 1;		// number of virtual circuits per port
   parameter VCW = 8;		// the datawidth of a single virtual circuit
   parameter SCN = VCW/2;	// number of 1-of-4 sub-channels in one virtual circuit

   input [VCN-1:0][SCN-1:0]    si0, si1, si2, si3; // south input, X+1
   output [VCN-1:0][SCN-1:0]   so0, so1, so2, so3; // south output
   input [VCN-1:0][SCN-1:0]    wi0, wi1, wi2, wi3; // west input, Y-1
   output [VCN-1:0][SCN-1:0]   wo0, wo1, wo2, wo3; // west output
   input [VCN-1:0][SCN-1:0]    ni0, ni1, ni2, ni3; // north input, X-1
   output [VCN-1:0][SCN-1:0]   no0, no1, no2, no3; // north output
   input [VCN-1:0][SCN-1:0]    ei0, ei1, ei2, ei3; // east input, Y+1
   output [VCN-1:0][SCN-1:0]   eo0, eo1, eo2, eo3; // east output
   input [VCN-1:0][SCN-1:0]    li0, li1, li2, li3; // local input
   output [VCN-1:0][SCN-1:0]   lo0, lo1, lo2, lo3; // local output

   // ack and eof bits
`ifdef ENABLE_CHANNEL_SLICING
   input [VCN-1:0][SCN-1:0]    si4, soa;
   output [VCN-1:0][SCN-1:0]   so4, sia;
   input [VCN-1:0][SCN-1:0]    wi4, woa;
   output [VCN-1:0][SCN-1:0]   wo4, wia;
   input [VCN-1:0][SCN-1:0]    ni4, noa;
   output [VCN-1:0][SCN-1:0]   no4, nia;
   input [VCN-1:0][SCN-1:0]    ei4, eoa;
   output [VCN-1:0][SCN-1:0]   eo4, eia;
   input [VCN-1:0][SCN-1:0]    li4, loa;
   output [VCN-1:0][SCN-1:0]   lo4, lia;
`else // !`ifdef ENABLE_CHANNEL_SLICING
   input [VCN-1:0] 	       si4, soa;
   output [VCN-1:0] 	       so4, sia;
   input [VCN-1:0] 	       wi4, woa;
   output [VCN-1:0] 	       wo4, wia;
   input [VCN-1:0] 	       ni4, noa;
   output [VCN-1:0] 	       no4, nia;
   input [VCN-1:0] 	       ei4, eoa;
   output [VCN-1:0] 	       eo4, eia;
   input [VCN-1:0] 	       li4, loa;
   output [VCN-1:0] 	       lo4, lia;
`endif   

   // configurations
   input [VCN-1:0][1:0][VCN-1:0]        scfg, ncfg;
   input [VCN-1:0][3:0][VCN-1:0]        wcfg, ecfg, lcfg;
   

   // ANDed wires
   wire [VCN-1:0][SCN-1:0][1:0][VCN-1:0] tos0, tos1, tos2, tos3;     // the wires to the south output port
   wire [VCN-1:0][SCN-1:0][3:0][VCN-1:0] tow0, tow1, tow2, tow3;     // the wires to the west output port
   wire [VCN-1:0][SCN-1:0][1:0][VCN-1:0] ton0, ton1, ton2, ton3;     // the wires to the north output port
   wire [VCN-1:0][SCN-1:0][3:0][VCN-1:0] toe0, toe1, toe2, toe3;     // the wires to the east output port
   wire [VCN-1:0][SCN-1:0][3:0][VCN-1:0] tol0, tol1, tol2, tol3;     // the wires to the local output port

`ifdef ENABLE_CHANNEL_SLICING
   wire [VCN-1:0][SCN-1:0][1:0][VCN-1:0] tos4, tosa;                 // the wires to the south output port
   wire [VCN-1:0][SCN-1:0][3:0][VCN-1:0] tow4, towa;                 // the wires to the west output port
   wire [VCN-1:0][SCN-1:0][1:0][VCN-1:0] ton4, tona;                 // the wires to the north output port
   wire [VCN-1:0][SCN-1:0][3:0][VCN-1:0] toe4, toea;                 // the wires to the east output port
   wire [VCN-1:0][SCN-1:0][3:0][VCN-1:0] tol4, tola;                 // the wires to the local output port

   wire [VCN-1:0][SCN-1:0][3:0][VCN-1:0] isa;                        // ack back to south
   wire [VCN-1:0][SCN-1:0][1:0][VCN-1:0] iwa;                        // ack back to west
   wire [VCN-1:0][SCN-1:0][3:0][VCN-1:0] ina;                        // ack back to north
   wire [VCN-1:0][SCN-1:0][1:0][VCN-1:0] iea;                        // ack back to east
   wire [VCN-1:0][SCN-1:0][3:0][VCN-1:0] ila;                        // ack back to local

`else // !`ifdef ENABLE_CHANNEL_SLICING
   wire [VCN-1:0][1:0][VCN-1:0] tos4, tosa;                 // the wires to the south output port
   wire [VCN-1:0][3:0][VCN-1:0] tow4, towa;                 // the wires to the west output port
   wire [VCN-1:0][1:0][VCN-1:0] ton4, tona;                 // the wires to the north output port
   wire [VCN-1:0][3:0][VCN-1:0] toe4, toea;                 // the wires to the east output port
   wire [VCN-1:0][3:0][VCN-1:0] tol4, tola;                 // the wires to the local output port   

   wire [VCN-1:0][3:0][VCN-1:0] isa;                        // ack back to south
   wire [VCN-1:0][1:0][VCN-1:0] iwa;                        // ack back to west
   wire [VCN-1:0][3:0][VCN-1:0] ina;                        // ack back to north
   wire [VCN-1:0][1:0][VCN-1:0] iea;                        // ack back to east
   wire [VCN-1:0][3:0][VCN-1:0] ila;                        // ack back to local

`endif // !`ifdef ENABLE_CHANNEL_SLICING
   
   // generate
   genvar 		      i, j, k;
   

   /*---------------------------- SOUTH OUPUT -------------------------------------*/
   generate for (i=0; i<VCN; i=i+1)
     begin:SOP
	for(j=0; j<VCN; j++) begin: V
	   for(k=0; k<SCN; k++) begin: SC
	      and AN0 (tos0[i][k][0][j], ni0[j][k], scfg[i][0][j]);
	      and AN1 (tos1[i][k][0][j], ni1[j][k], scfg[i][0][j]);
	      and AN2 (tos2[i][k][0][j], ni2[j][k], scfg[i][0][j]);
	      and AN3 (tos3[i][k][0][j], ni3[j][k], scfg[i][0][j]);
	      and AL0 (tos0[i][k][1][j], li0[j][k], scfg[i][1][j]);
	      and AL1 (tos1[i][k][1][j], li1[j][k], scfg[i][1][j]);
	      and AL2 (tos2[i][k][1][j], li2[j][k], scfg[i][1][j]);
	      and AL3 (tos3[i][k][1][j], li3[j][k], scfg[i][1][j]);
`ifdef ENABLE_CHANNEL_SLICING
	      and AN4 (tos4[i][k][0][j], ni4[j][k], scfg[i][0][j]);
	      and ANA (tosa[i][k][0][j], soa[i][k], scfg[i][0][j]);
	      and AL4 (tos4[i][k][1][j], li4[j][k], scfg[i][1][j]);
	      and ALA (tosa[i][k][1][j], soa[i][k], scfg[i][1][j]);
`endif	      
	   end // block: SC
`ifndef ENABLE_CHANNEL_SLICING
	   and AN4 (tos4[i][0][j], ni4[j], scfg[i][0][j]);
	   and ANA (tosa[i][0][j], soa[i], scfg[i][0][j]);
	   and AL4 (tos4[i][1][j], li4[j], scfg[i][1][j]);
	   and ALA (tosa[i][1][j], soa[i], scfg[i][1][j]);
`endif	   
	end // block: V
	
	for(k=0; k<SCN; k++) begin: SCOR
	   assign so0[i][k] = |(tos0[i][k][0]|tos0[i][k][1]);
	   assign so1[i][k] = |(tos1[i][k][0]|tos1[i][k][1]);
	   assign so2[i][k] = |(tos2[i][k][0]|tos2[i][k][1]);
	   assign so3[i][k] = |(tos3[i][k][0]|tos3[i][k][1]);
`ifdef ENABLE_CHANNEL_SLICING
	   assign so4[i][k] = |(tos4[i][k][0]|tos4[i][k][1]);
`endif
	end
`ifndef ENABLE_CHANNEL_SLICING
	assign so4[i] = |(tos4[i][0]|tos4[i][1]);
`endif
     end
   endgenerate
   
   /*---------------------------- WEST OUPUT -------------------------------------*/
   generate for (i=0; i<VCN; i=i+1)
     begin:WOP
	for(j=0; j<VCN; j++) begin: V
	   for(k=0; k<SCN; k++) begin: SC
	      and AS0 (tow0[i][k][0][j], si0[j][k], wcfg[i][0][j]);
	      and AS1 (tow1[i][k][0][j], si1[j][k], wcfg[i][0][j]);
	      and AS2 (tow2[i][k][0][j], si2[j][k], wcfg[i][0][j]);
	      and AS3 (tow3[i][k][0][j], si3[j][k], wcfg[i][0][j]);
	      and AN0 (tow0[i][k][1][j], ni0[j][k], wcfg[i][1][j]);
	      and AN1 (tow1[i][k][1][j], ni1[j][k], wcfg[i][1][j]);
	      and AN2 (tow2[i][k][1][j], ni2[j][k], wcfg[i][1][j]);
	      and AN3 (tow3[i][k][1][j], ni3[j][k], wcfg[i][1][j]);
	      and AE0 (tow0[i][k][2][j], ei0[j][k], wcfg[i][2][j]);
	      and AE1 (tow1[i][k][2][j], ei1[j][k], wcfg[i][2][j]);
	      and AE2 (tow2[i][k][2][j], ei2[j][k], wcfg[i][2][j]);
	      and AE3 (tow3[i][k][2][j], ei3[j][k], wcfg[i][2][j]);
	      and AL0 (tow0[i][k][3][j], li0[j][k], wcfg[i][3][j]);
	      and AL1 (tow1[i][k][3][j], li1[j][k], wcfg[i][3][j]);
	      and AL2 (tow2[i][k][3][j], li2[j][k], wcfg[i][3][j]);
	      and AL3 (tow3[i][k][3][j], li3[j][k], wcfg[i][3][j]);
`ifdef ENABLE_CHANNEL_SLICING
	      and AS4 (tow4[i][k][0][j], si4[j][k], wcfg[i][0][j]);
	      and ASA (towa[i][k][0][j], woa[i][k], wcfg[i][0][j]);
	      and AN4 (tow4[i][k][1][j], ni4[j][k], wcfg[i][1][j]);
	      and ANA (towa[i][k][1][j], woa[i][k], wcfg[i][1][j]);
	      and AE4 (tow4[i][k][2][j], ei4[j][k], wcfg[i][2][j]);
	      and AEA (towa[i][k][2][j], woa[i][k], wcfg[i][2][j]);
	      and AL4 (tow4[i][k][3][j], li4[j][k], wcfg[i][3][j]);
	      and ALA (towa[i][k][3][j], woa[i][k], wcfg[i][3][j]);
`endif	      
	   end // block: SC
`ifndef ENABLE_CHANNEL_SLICING
	   and AS4 (tow4[i][0][j], si4[j], wcfg[i][0][j]);
	   and ASA (towa[i][0][j], woa[i], wcfg[i][0][j]);
	   and AN4 (tow4[i][1][j], ni4[j], wcfg[i][1][j]);
	   and ANA (towa[i][1][j], woa[i], wcfg[i][1][j]);
	   and AE4 (tow4[i][2][j], ei4[j], wcfg[i][2][j]);
	   and AEA (towa[i][2][j], woa[i], wcfg[i][2][j]);
	   and AL4 (tow4[i][3][j], li4[j], wcfg[i][3][j]);
	   and ALA (towa[i][3][j], woa[i], wcfg[i][3][j]);
`endif	   
	end // block: V
	
	for(k=0; k<SCN; k++) begin: SCOR
	   assign wo0[i][k] = |(tow0[i][k][0]|tow0[i][k][1]|tow0[i][k][2]|tow0[i][k][3]);
	   assign wo1[i][k] = |(tow1[i][k][0]|tow1[i][k][1]|tow1[i][k][2]|tow1[i][k][3]);
	   assign wo2[i][k] = |(tow2[i][k][0]|tow2[i][k][1]|tow2[i][k][2]|tow2[i][k][3]);
	   assign wo3[i][k] = |(tow3[i][k][0]|tow3[i][k][1]|tow3[i][k][2]|tow3[i][k][3]);
`ifdef ENABLE_CHANNEL_SLICING
	   assign wo4[i][k] = |(tow4[i][k][0]|tow4[i][k][1]|tow4[i][k][2]|tow4[i][k][3]);
`endif
	end
`ifndef ENABLE_CHANNEL_SLICING
	assign wo4[i] = |(tow4[i][0]|tow4[i][1]|tow4[i][2]|tow4[i][3]);
`endif
     end
   endgenerate

   /*---------------------------- NORTH OUPUT -------------------------------------*/
   generate for (i=0; i<VCN; i=i+1)
     begin:NOP
	for(j=0; j<VCN; j++) begin: V
	   for(k=0; k<SCN; k++) begin: SC
	      and AS0 (ton0[i][k][0][j], si0[j][k], ncfg[i][0][j]);
	      and AS1 (ton1[i][k][0][j], si1[j][k], ncfg[i][0][j]);
	      and AS2 (ton2[i][k][0][j], si2[j][k], ncfg[i][0][j]);
	      and AS3 (ton3[i][k][0][j], si3[j][k], ncfg[i][0][j]);
	      and AL0 (ton0[i][k][1][j], li0[j][k], ncfg[i][1][j]);
	      and AL1 (ton1[i][k][1][j], li1[j][k], ncfg[i][1][j]);
	      and AL2 (ton2[i][k][1][j], li2[j][k], ncfg[i][1][j]);
	      and AL3 (ton3[i][k][1][j], li3[j][k], ncfg[i][1][j]);
`ifdef ENABLE_CHANNEL_SLICING
	      and AS4 (ton4[i][k][0][j], si4[j][k], ncfg[i][0][j]);
	      and ASA (tona[i][k][0][j], noa[i][k], ncfg[i][0][j]);
	      and AL4 (ton4[i][k][1][j], li4[j][k], ncfg[i][1][j]);
	      and ALA (tona[i][k][1][j], noa[i][k], ncfg[i][1][j]);
`endif	      
	   end // block: SC
`ifndef ENABLE_CHANNEL_SLICING
	   and AS4 (ton4[i][0][j], si4[j], ncfg[i][0][j]);
	   and ASA (tona[i][0][j], noa[i], ncfg[i][0][j]);
	   and AL4 (ton4[i][1][j], li4[j], ncfg[i][1][j]);
	   and ALA (tona[i][1][j], noa[i], ncfg[i][1][j]);
`endif	   
	end // block: V
	
	for(k=0; k<SCN; k++) begin: SCOR
	   assign no0[i][k] = |(ton0[i][k][0]|ton0[i][k][1]);
	   assign no1[i][k] = |(ton1[i][k][0]|ton1[i][k][1]);
	   assign no2[i][k] = |(ton2[i][k][0]|ton2[i][k][1]);
	   assign no3[i][k] = |(ton3[i][k][0]|ton3[i][k][1]);
`ifdef ENABLE_CHANNEL_SLICING
	   assign no4[i][k] = |(ton4[i][k][0]|ton4[i][k][1]);
`endif
	end
`ifndef ENABLE_CHANNEL_SLICING
	assign no4[i] = |(ton4[i][0]|ton4[i][1]);
`endif
     end
   endgenerate
   
   /*---------------------------- EAST OUPUT -------------------------------------*/
   generate for (i=0; i<VCN; i=i+1)
     begin:EOP
	for(j=0; j<VCN; j++) begin: V
	   for(k=0; k<SCN; k++) begin: SC
	      and AS0 (toe0[i][k][0][j], si0[j][k], ecfg[i][0][j]);
	      and AS1 (toe1[i][k][0][j], si1[j][k], ecfg[i][0][j]);
	      and AS2 (toe2[i][k][0][j], si2[j][k], ecfg[i][0][j]);
	      and AS3 (toe3[i][k][0][j], si3[j][k], ecfg[i][0][j]);
	      and AW0 (toe0[i][k][1][j], wi0[j][k], ecfg[i][1][j]);
	      and AW1 (toe1[i][k][1][j], wi1[j][k], ecfg[i][1][j]);
	      and AW2 (toe2[i][k][1][j], wi2[j][k], ecfg[i][1][j]);
	      and AW3 (toe3[i][k][1][j], wi3[j][k], ecfg[i][1][j]);
	      and AN0 (toe0[i][k][2][j], ni0[j][k], ecfg[i][2][j]);
	      and AN1 (toe1[i][k][2][j], ni1[j][k], ecfg[i][2][j]);
	      and AN2 (toe2[i][k][2][j], ni2[j][k], ecfg[i][2][j]);
	      and AN3 (toe3[i][k][2][j], ni3[j][k], ecfg[i][2][j]);
	      and AL0 (toe0[i][k][3][j], li0[j][k], ecfg[i][3][j]);
	      and AL1 (toe1[i][k][3][j], li1[j][k], ecfg[i][3][j]);
	      and AL2 (toe2[i][k][3][j], li2[j][k], ecfg[i][3][j]);
	      and AL3 (toe3[i][k][3][j], li3[j][k], ecfg[i][3][j]);
`ifdef ENABLE_CHANNEL_SLICING
	      and AS4 (toe4[i][k][0][j], si4[j][k], ecfg[i][0][j]);
	      and ASA (toea[i][k][0][j], eoa[i][k], ecfg[i][0][j]);
	      and AW4 (toe4[i][k][1][j], wi4[j][k], ecfg[i][1][j]);
	      and AWA (toea[i][k][1][j], eoa[i][k], ecfg[i][1][j]);
	      and AN4 (toe4[i][k][2][j], ni4[j][k], ecfg[i][2][j]);
	      and ANA (toea[i][k][2][j], eoa[i][k], ecfg[i][2][j]);
	      and AL4 (toe4[i][k][3][j], li4[j][k], ecfg[i][3][j]);
	      and ALA (toea[i][k][3][j], eoa[i][k], ecfg[i][3][j]);
`endif	      
	   end // block: SC
`ifndef ENABLE_CHANNEL_SLICING
	   and AS4 (toe4[i][0][j], si4[j], ecfg[i][0][j]);
	   and ASA (toea[i][0][j], eoa[i], ecfg[i][0][j]);
	   and AW4 (toe4[i][1][j], wi4[j], ecfg[i][1][j]);
	   and AWA (toea[i][1][j], eoa[i], ecfg[i][1][j]);
	   and AN4 (toe4[i][2][j], ni4[j], ecfg[i][2][j]);
	   and ANA (toea[i][2][j], eoa[i], ecfg[i][2][j]);
	   and AL4 (toe4[i][3][j], li4[j], ecfg[i][3][j]);
	   and ALA (toea[i][3][j], eoa[i], ecfg[i][3][j]);
`endif	   
	end // block: V
	
	for(k=0; k<SCN; k++) begin: SCOR
	   assign eo0[i][k] = |(toe0[i][k][0]|toe0[i][k][1]|toe0[i][k][2]|toe0[i][k][3]);
	   assign eo1[i][k] = |(toe1[i][k][0]|toe1[i][k][1]|toe1[i][k][2]|toe1[i][k][3]);
	   assign eo2[i][k] = |(toe2[i][k][0]|toe2[i][k][1]|toe2[i][k][2]|toe2[i][k][3]);
	   assign eo3[i][k] = |(toe3[i][k][0]|toe3[i][k][1]|toe3[i][k][2]|toe3[i][k][3]);
`ifdef ENABLE_CHANNEL_SLICING
	   assign eo4[i][k] = |(toe4[i][k][0]|toe4[i][k][1]|toe4[i][k][2]|toe4[i][k][3]);
`endif
	end
`ifndef ENABLE_CHANNEL_SLICING
	assign eo4[i] = |(toe4[i][0]|toe4[i][1]|toe4[i][2]|toe4[i][3]);
`endif
     end
   endgenerate


   /*---------------------------- LOCAL OUPUT -------------------------------------*/
   generate for (i=0; i<VCN; i=i+1)
     begin:LOP
	for(j=0; j<VCN; j++) begin: V
	   for(k=0; k<SCN; k++) begin: SC
	      and AS0 (tol0[i][k][0][j], si0[j][k], lcfg[i][0][j]);
	      and AS1 (tol1[i][k][0][j], si1[j][k], lcfg[i][0][j]);
	      and AS2 (tol2[i][k][0][j], si2[j][k], lcfg[i][0][j]);
	      and AS3 (tol3[i][k][0][j], si3[j][k], lcfg[i][0][j]);
	      and AW0 (tol0[i][k][1][j], wi0[j][k], lcfg[i][1][j]);
	      and AW1 (tol1[i][k][1][j], wi1[j][k], lcfg[i][1][j]);
	      and AW2 (tol2[i][k][1][j], wi2[j][k], lcfg[i][1][j]);
	      and AW3 (tol3[i][k][1][j], wi3[j][k], lcfg[i][1][j]);
	      and AN0 (tol0[i][k][2][j], ni0[j][k], lcfg[i][2][j]);
	      and AN1 (tol1[i][k][2][j], ni1[j][k], lcfg[i][2][j]);
	      and AN2 (tol2[i][k][2][j], ni2[j][k], lcfg[i][2][j]);
	      and AN3 (tol3[i][k][2][j], ni3[j][k], lcfg[i][2][j]);
	      and AE0 (tol0[i][k][3][j], ei0[j][k], lcfg[i][3][j]);
	      and AE1 (tol1[i][k][3][j], ei1[j][k], lcfg[i][3][j]);
	      and AE2 (tol2[i][k][3][j], ei2[j][k], lcfg[i][3][j]);
	      and AE3 (tol3[i][k][3][j], ei3[j][k], lcfg[i][3][j]);
`ifdef ENABLE_CHANNEL_SLICING
	      and AS4 (tol4[i][k][0][j], si4[j][k], lcfg[i][0][j]);
	      and ASA (tola[i][k][0][j], loa[i][k], lcfg[i][0][j]);
	      and AW4 (tol4[i][k][1][j], wi4[j][k], lcfg[i][1][j]);
	      and AWA (tola[i][k][1][j], loa[i][k], lcfg[i][1][j]);
	      and AN4 (tol4[i][k][2][j], ni4[j][k], lcfg[i][2][j]);
	      and ANA (tola[i][k][2][j], loa[i][k], lcfg[i][2][j]);
	      and AE4 (tol4[i][k][3][j], ei4[j][k], lcfg[i][3][j]);
	      and AEA (tola[i][k][3][j], loa[i][k], lcfg[i][3][j]);
`endif	      
	   end // block: SC
`ifndef ENABLE_CHANNEL_SLICING
	   and AS4 (tol4[i][0][j], si4[j], lcfg[i][0][j]);
	   and ASA (tola[i][0][j], loa[i], lcfg[i][0][j]);
	   and AW4 (tol4[i][1][j], wi4[j], lcfg[i][1][j]);
	   and AWA (tola[i][1][j], loa[i], lcfg[i][1][j]);
	   and AN4 (tol4[i][2][j], ni4[j], lcfg[i][2][j]);
	   and ANA (tola[i][2][j], loa[i], lcfg[i][2][j]);
	   and AE4 (tol4[i][3][j], ei4[j], lcfg[i][3][j]);
	   and AEA (tola[i][3][j], loa[i], lcfg[i][3][j]);
`endif	   
	end // block: V
	
	for(k=0; k<SCN; k++) begin: SCOR
	   assign lo0[i][k] = |(tol0[i][k][0]|tol0[i][k][1]|tol0[i][k][2]|tol0[i][k][3]);
	   assign lo1[i][k] = |(tol1[i][k][0]|tol1[i][k][1]|tol1[i][k][2]|tol1[i][k][3]);
	   assign lo2[i][k] = |(tol2[i][k][0]|tol2[i][k][1]|tol2[i][k][2]|tol2[i][k][3]);
	   assign lo3[i][k] = |(tol3[i][k][0]|tol3[i][k][1]|tol3[i][k][2]|tol3[i][k][3]);
`ifdef ENABLE_CHANNEL_SLICING
	   assign lo4[i][k] = |(tol4[i][k][0]|tol4[i][k][1]|tol4[i][k][2]|tol4[i][k][3]);
`endif
	end
`ifndef ENABLE_CHANNEL_SLICING
	assign lo4[i] = |(tol4[i][0]|tol4[i][1]|tol4[i][2]|tol4[i][3]);
`endif
     end
   endgenerate

   generate for(i=0; i<VCN; i++) begin: IACK
`ifdef ENABLE_CHANNEL_SLICING
      for(k=0; k<SCN; k++) begin: SC
	 for(j=0; j<VCN; j++) begin: SHUFFLE
	    assign isa[i][k][0][j] = towa[j][k][0][i];
	    assign isa[i][k][1][j] = tona[j][k][0][i];
	    assign isa[i][k][2][j] = toea[j][k][0][i];
	    assign isa[i][k][3][j] = tola[j][k][0][i];
	    assign iwa[i][k][0][j] = toea[j][k][1][i];
	    assign iwa[i][k][1][j] = tola[j][k][1][i];
	    assign ina[i][k][0][j] = tosa[j][k][0][i];
	    assign ina[i][k][1][j] = towa[j][k][1][i];
	    assign ina[i][k][2][j] = toea[j][k][2][i];
	    assign ina[i][k][3][j] = tola[j][k][2][i];
	    assign iea[i][k][0][j] = towa[j][k][2][i];
	    assign iea[i][k][1][j] = tola[j][k][3][i];
	    assign ila[i][k][0][j] = tosa[j][k][1][i];
	    assign ila[i][k][1][j] = towa[j][k][3][i];
	    assign ila[i][k][2][j] = tona[j][k][1][i];
	    assign ila[i][k][3][j] = toea[j][k][3][i];
	 end // block: SHUFFLE
	 assign sia[i][k] = |{isa[i][k][0]|isa[i][k][1]|isa[i][k][2]|isa[i][k][3]};
	 assign wia[i][k] = |{iwa[i][k][0]|iwa[i][k][1]};
	 assign nia[i][k] = |{ina[i][k][0]|ina[i][k][1]|ina[i][k][2]|ina[i][k][3]};
	 assign eia[i][k] = |{iea[i][k][0]|iea[i][k][1]};
	 assign lia[i][k] = |{ila[i][k][0]|ila[i][k][1]|ila[i][k][2]|ila[i][k][3]};
      end // block: SC
`else // !`ifdef ENABLE_CHANNEL_SLICING
      for(j=0; j<VCN; j++) begin: SHUFFLE
	 assign isa[i][0][j] = towa[j][0][i];
	 assign isa[i][1][j] = tona[j][0][i];
	 assign isa[i][2][j] = toea[j][0][i];
	 assign isa[i][3][j] = tola[j][0][i];
	 assign iwa[i][0][j] = toea[j][1][i];
	 assign iwa[i][1][j] = tola[j][1][i];
	 assign ina[i][0][j] = tosa[j][0][i];
	 assign ina[i][1][j] = towa[j][1][i];
	 assign ina[i][2][j] = toea[j][2][i];
	 assign ina[i][3][j] = tola[j][2][i];
	 assign iea[i][0][j] = towa[j][2][i];
	 assign iea[i][1][j] = tola[j][3][i];
	 assign ila[i][0][j] = tosa[j][1][i];
	 assign ila[i][1][j] = towa[j][3][i];
	 assign ila[i][2][j] = tona[j][1][i];
	 assign ila[i][3][j] = toea[j][3][i];
      end // block: SHUFFLE
      assign sia[i] = |{isa[i][0]|isa[i][1]|isa[i][2]|isa[i][3]};
      assign wia[i] = |{iwa[i][0]|iwa[i][1]};
      assign nia[i] = |{ina[i][0]|ina[i][1]|ina[i][2]|ina[i][3]};
      assign eia[i] = |{iea[i][0]|iea[i][1]};
      assign lia[i] = |{ila[i][0]|ila[i][1]|ila[i][2]|ila[i][3]};
`endif
   end // block: IACK
   endgenerate
   
endmodule // dcb_xy



