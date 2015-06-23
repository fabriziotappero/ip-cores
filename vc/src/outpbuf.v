/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The output buffer for VC routers.
 
 History:
 04/04/2010  Initial version. <wsong83@gmail.com>
 12/05/2010  Use MPxP crossbars. <wsong83@gmail.com>
 08/05/2010  Remove unnecessary pipeline stages. <wsong83@gmail.com>
 02/06/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

module outpbuf (/*AUTOARG*/
   // Outputs
   dia, do0, do1, do2, do3, dot, dovc, afc, vca,
   // Inputs
   di0, di1, di2, di3, dit, doa, credit, vcr, rst_n
   );
   parameter DW = 32;		// data width
   parameter VCN = 4;		// VC number
   parameter FT = 3;		// flit type, now 3, HOF, BOF, EOF
   parameter FCPD = 3;		// the depth of the credit pipeline
   parameter SCN = DW/2;

   //data in
   input [SCN-1:0] di0, di1, di2, di3;
   input [FT-1:0]  dit;
   output 	   dia;

   // data out
   output [SCN-1:0] do0, do1, do2, do3;
   output [FT-1:0]  dot;
   output [VCN-1:0] dovc;
   input 	    doa;

   // credit
   input [VCN-1:0]  credit;
   output [VCN-1:0] afc;

   // vc requests in
   input [VCN-1:0]  vcr;
   output [VCN-1:0] vca;

   // active-low reset
   input 	    rst_n;

   //--------------------------------------------------------------
   wire [VCN-1:0]   vcro, vcg, vcgl, vcrm;
   wire [SCN-1:0]   doan, diad;
   wire             dian, diavc, diavcn, diat;
   
   genvar 	    i, gsub;
   
   // flow control controller
   fcctl #(.VCN(VCN), .PD(FCPD))
   FCU (
	.afc    ( afc    ), 
	.ro     ( vcro   ),
	.credit ( credit ), 
	.ri     ( vcr    ), 
	.rst    ( ~rst_n  )
	);

   // VC arbiter
   mutex_arb #(.wd(VCN)) Sch (.req(vcro), .gnt(vcg));

   // the control logic for VC arbiter
   generate
      for(i=0; i<VCN; i++)begin:SCEN
	 c2 C (.a0(vcg[i]), .a1(diavcn), .q(vcgl[i]));
      end
   endgenerate
   assign diavcn = (~diavc)&rst_n;

   // output data buffer
   generate
      for(gsub=0; gsub<SCN; gsub++) begin:SC
	 pipe4 #(.DW(2))
	 L0D (
	      .ia ( diad[gsub]   ), 
	      .o0 ( do0[gsub]    ), 
	      .o1 ( do1[gsub]    ),
	      .o2 ( do2[gsub]    ),
	      .o3 ( do3[gsub]    ),
	      .i0 ( di0[gsub]    ),
	      .i1 ( di1[gsub]    ), 
	      .i2 ( di2[gsub]    ),
	      .i3 ( di3[gsub]    ),
	      .oa ( doan[gsub]   )
	      );
	 assign doan[gsub] = (~doa)&rst_n;
      end // block: SC
   endgenerate

   pipen #(.DW(FT))
   L0T (
	.d_in    ( dit     ),
	.d_in_a  ( diat    ),
	.d_out   ( dot     ),  
	.d_out_a ( (~doa)&rst_n )
	);
   
   ctree #(.DW(SCN+2)) ACKT (.ci({diavc,diat, diad}), .co(dia));
   
   pipen #(.DW(VCN))
   LSV (
	.d_in    ( vcgl       ),
	.d_in_a  ( diavc      ),
	.d_out   ( dovc       ),
	.d_out_a ( (~doa)&rst_n )
	);

   assign vca = dovc;

endmodule // outpbuf


   
