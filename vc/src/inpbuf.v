/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The input buffer for VC routers.
 
 History:
 01/04/2010  Initial version. <wsong83@gmail.com>
 12/05/2010  Use MPxP crossbars. <wsong83@gmail.com>
 17/04/2010  Remove unnecessary pipeline stages. <wsong83@gmail.com>
 02/06/2011  Clean up for opensource. <wsong83@gmail.com>
 09/06/2011  Remove the C-elements as muxes already have C-elements inside. <wsong83@gmail.com>
 
*/

module inpbuf (/*AUTOARG*/
   // Outputs
   dia, cor, do0, do1, do2, do3, dot, dortg, vcr, swr,
   // Inputs
   di0, di1, di2, di3, dit, divc, coa, doa, vcra, swrt, addrx, addry,
   rst_n
   );

   parameter DW = 32;		// data width
   parameter VCN = 2;		// VC number
   parameter DIR = 0;           // 0-4 south, west, north, east, local
   parameter SN = 2;		// maximal output port number
   parameter PD = 3;		// the depth of the input buffer pipeline
   parameter SCN = DW/2;	// number of 1-of-4 sub-channels
   parameter FT = 3;		// flit type, now 3, HOF, BOF, EOF
        
   // data IP
   input [SCN-1:0] di0, di1, di2, di3;
   input [FT-1:0]  dit;
   input [VCN-1:0] divc;
   output 	   dia;

   // credit flow-control
   output [VCN-1:0] cor;
   input [VCN-1:0]  coa;

   // data to crossbar
   output [VCN-1:0][SCN-1:0] do0,do1,do2,do3;
   output [VCN-1:0][FT-1:0]  dot;
   output [VCN-1:0][SN-1:0]  dortg;
   input  [VCN-1:0]	    doa;

   // request to VC allocator
   output [VCN-1:0][SN-1:0] vcr;
   input [VCN-1:0] 	    vcra;

   // output to SW allocator
   output [VCN-1:0][1:0]    swr;

   // routing guide for SW DEMUX
   input [VCN-1:0][SN-1:0]  swrt;

   // local addresses
   input [7:0] 		    addrx, addry;

   input 		    rst_n;

   //-----------------------------		    
   // VC_MUX
   wire 		    ivma, rua;
   wire [SCN-1:0] 	    di0m, di1m, di2m, di3m;
   wire [FT-1:0] 	    ditm;
   wire [VCN-1:0] 	    divcm;
   wire [VCN-1:0] 	    muxa; 	    
   
   // VC_BUF
   wire [2*PD:0][VCN-1:0][SCN-1:0] vcd0, vcd1, vcd2, vcd3; // VC data
   wire [2*PD:0][VCN-1:0][FT-1:0]  vcdt;		   // VC flit type
   wire [2*PD:0][VCN-1:0][SCN-1:0] vcdad, vcdadn;          // VC ack
   wire [2*PD:0][VCN-1:0] 	   vcdat, vcdatn;	   // VC data ack and type ack
   wire [1:0][VCN-1:0] 		   vcda;                   // the comman ack 		   

   // control path
   wire [2*PD:2*PD-2][VCN-1:0][1:0] vcft;		   // flit type on control path
   wire [2*PD:2*PD-2][VCN-1:0] 	   vcfta, vcftan;          // flit type ack, on control path
   wire [VCN-1:0] 		   vcdam;		   // need an extra ack internal signal
   wire [VCN-1:0][SN-1:0] 	   rtg;			   // routing direction guide
   wire [VCN-1:0] 		   doan;
   
   // last stage of input buffer
   wire [VCN-1:0] 		   vcor;
   wire [VCN-1:0] 		   vcog;
   wire [VCN-1:0] 		   swa;

   genvar 			   gbd, gvc, gsub, i;

   //---------------------------------------------
   // the input VCDMUX
   vcdmux #(.VCN(VCN), .DW(DW))
   IVM ( 
	 .dia   ( ivma     ), 
	 .do0   ( vcd0[0]  ), 
	 .do1   ( vcd1[0]  ), 
	 .do2   ( vcd2[0]  ), 
	 .do3   ( vcd3[0]  ), 
	 .dot   ( vcdt[0]  ),
	 .di0   ( di0m     ), 
	 .di1   ( di1m     ), 
	 .di2   ( di2m     ), 
	 .di3   ( di3m     ), 
	 .dit   ( ditm     ), 
	 .divc  ( divcm    ), 
	 .doa   ( muxa     )
	 );

   //c2 IVMA (.a0(ivma), .a1(rua), .q(dia)); divc is not checked
   ctree #(.DW(2)) ACKT(.ci({ivma, rua}), .co(dia));
   
   assign di0m = rst_n ? di0 : 0;
   assign di1m = rst_n ? di1 : 0;
   assign di2m = rst_n ? di2 : 0;
   assign di3m = rst_n ? di3 : 0;
   assign ditm = rst_n ? dit : 0;
   assign divcm = rst_n ? divc : 0;

   //---------------------------------------------
   // the VC buffers
   generate
      for(gbd=0; gbd<PD*2-2; gbd++) begin:BFN
	 for(gvc=0; gvc<VCN; gvc++) begin:V
	    for(gsub=0; gsub<SCN; gsub++) begin:SC
	       pipe4 #(.DW(2)) 
	       DP (
		   .ia ( vcdad[gbd][gvc][gsub]  ), 
		   .o0 ( vcd0[gbd+1][gvc][gsub] ), 
		   .o1 ( vcd1[gbd+1][gvc][gsub] ),
		   .o2 ( vcd2[gbd+1][gvc][gsub] ), 
		   .o3 ( vcd3[gbd+1][gvc][gsub] ), 
		   .i0 ( vcd0[gbd][gvc][gsub]   ),
		   .i1 ( vcd1[gbd][gvc][gsub]   ), 
		   .i2 ( vcd2[gbd][gvc][gsub]   ),
		   .i3 ( vcd3[gbd][gvc][gsub]   ),
		   .oa ( vcdadn[gbd+1][gvc][gsub] )
		   );
	       assign vcdadn[gbd+1][gvc][gsub] = (~vcdad[gbd+1][gvc][gsub])&rst_n;
	    end // block: SC
	    
	    pipen #(.DW(FT)) 
	    TP (
		.d_in    ( vcdt[gbd][gvc]     ),
		.d_in_a  ( vcdat[gbd][gvc]    ),
		.d_out   ( vcdt[gbd+1][gvc]   ),
		.d_out_a ( vcdatn[gbd+1][gvc]  )
		);
	    assign vcdatn[gbd+1][gvc] = (~vcdat[gbd+1][gvc])&rst_n;
	    
	 end // block: V
      end // block: BFN

      for(gvc=0; gvc<VCN; gvc++) begin:BFNV
	 if(PD>1) begin:ACKG
	    ctree #(.DW(SCN+1)) ACKT(.ci({vcdat[0],vcdad[0]}), .co(muxa[gvc]));
	    assign vcdad[PD*2-2][gvc] = {SCN{vcda[0][gvc]}};
	    assign vcdat[PD*2-2] = vcda[0][gvc];
	 end else begin
	    assign muxa[gvc] = vcda[0][gvc];
	 end
      end // block: V
      
   endgenerate

   // the last two stages of VC buffers, separate flit type and data
   generate
      for(gbd=PD*2-2; gbd<PD*2; gbd++) begin:BFL2
	 for(gvc=0; gvc<VCN; gvc++) begin:V
	    for(gsub=0; gsub<SCN; gsub++) begin:SC
	       pipe4 #(.DW(2)) 
	       DP (
		   .ia ( vcdad[gbd][gvc][gsub]    ),
		   .o0 ( vcd0[gbd+1][gvc][gsub]   ),
		   .o1 ( vcd1[gbd+1][gvc][gsub]   ),
		   .o2 ( vcd2[gbd+1][gvc][gsub]   ), 
		   .o3 ( vcd3[gbd+1][gvc][gsub]   ), 
		   .i0 ( vcd0[gbd][gvc][gsub]     ),
		   .i1 ( vcd1[gbd][gvc][gsub]     ), 
		   .i2 ( vcd2[gbd][gvc][gsub]     ),
		   .i3 ( vcd3[gbd][gvc][gsub]     ),
		   .oa ( vcdadn[gbd+1][gvc][gsub] )
		   );
	       assign vcdadn[gbd+1][gvc][gsub] = (~vcdad[gbd+1][gvc][gsub])&rst_n;
	    end // block: SC
	    
	    pipen #(.DW(FT)) 
	    TP (
		.d_in    ( vcdt[gbd][gvc]     ),
		.d_in_a  ( vcdat[gbd][gvc]    ),
		.d_out   ( vcdt[gbd+1][gvc]   ),
		.d_out_a ( vcdatn[gbd+1][gvc]  )
		);

	    assign vcdatn[gbd+1][gvc] = (~vcdat[gbd+1][gvc])&rst_n;

	    pipen #(.DW(2))
	    CTP (
		.d_in    ( vcft[gbd][gvc]     ),
		.d_in_a  ( vcfta[gbd][gvc]    ),
		.d_out   ( vcft[gbd+1][gvc]   ),
		.d_out_a ( vcftan[gbd+1][gvc] )
		);

	    assign vcftan[gbd+1][gvc] = (~vcfta[gbd+1][gvc])&rst_n;
	 end // block: V
      end // block: BFL2

      for(gvc=0; gvc<VCN; gvc++) begin:BFL2V
	 ctree #(.DW(SCN+2)) ACKT(.ci({vcfta[PD*2-2][gvc], vcdat[PD*2-2][gvc], vcdad[PD*2-2][gvc]}), .co(vcda[0][gvc]));
	 assign vcdat[PD*2][gvc] = vcda[1][gvc];
	 assign vcdad[PD*2][gvc] = {SCN{vcda[1][gvc]}};
	 assign vcfta[PD*2][gvc] = swa[gvc];
	 assign vcft[PD*2-2][gvc] = {vcdt[PD*2-2][gvc][FT-1], |vcdt[PD*2-2][gvc][FT-2:0]};
	 assign swr[gvc] = vcft[PD*2][gvc];
      end

   endgenerate
   

   // the routing guide pipeline stage
   generate
      for(gvc=0; gvc<VCN; gvc++) begin:R
	 pipen #(.DW(SN))
	 RP (
	     .d_in     ( swrt[gvc]          ),
	     .d_in_a   ( swa[gvc]           ),
	     .d_out    ( rtg[gvc]           ),
	     .d_out_a  ( (~vcda[1][gvc])&rst_n   )
	     );
      end
   endgenerate

   generate
      for(gvc=0; gvc<VCN; gvc++) begin:LPS

	 // credit control
	 dc2 FCP (.q(cor[gvc]), .d(|rtg[gvc]), .a((~coa[gvc])&rst_n));

	 // output name conversation
	 assign do0[gvc] = vcd0[PD*2][gvc];
	 assign do1[gvc] = vcd1[PD*2][gvc];
	 assign do2[gvc] = vcd2[PD*2][gvc];
	 assign do3[gvc] = vcd3[PD*2][gvc];

	 assign dot[gvc] = vcdt[PD*2][gvc];
	 assign dortg[gvc] = rtg[gvc];

	 c2 AC (.q(vcda[1][gvc]), .a0(cor[gvc]), .a1(doa[gvc]));

      end // block: LPS
   endgenerate
   
   // routing unit
   rtu #(.VCN(VCN), .DIR(DIR), .SN(SN), .PD(PD))
   RTC (
	.dia   ( rua       ), 
	.dort  ( vcr       ),
	.rst_n ( rst_n     ),
	.di0   ( di0m[3:0] ), 
	.di1   ( di1m[3:0] ), 
	.di2   ( di2m[3:0] ), 
	.di3   ( di3m[3:0] ), 
	.dit   ( ditm      ), 
	.divc  ( divcm     ), 
	.addrx ( addrx     ), 
	.addry ( addry     ), 
	.doa   ( vcra      )
   );
   
endmodule // inpbuf

   

   


   
