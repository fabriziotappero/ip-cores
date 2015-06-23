/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 data crossbar for the VC router
 
 History:
 04/04/2010  Initial version. <wsong83@gmail.com>
 12/05/2010  Use MPxP crossbar. <wsong83@gmail.com>
 02/06/2011  Clean up for opensource. <wsong83@gmail.com>
 09/06/2011  Remove the C-elements as muxes already have C-elements inside. <wsong83@gmail.com>
 
*/

module dcb_vc (/*AUTOARG*/
   // Outputs
   dia, do0, do1, do2, do3, dot,
   // Inputs
   di0, di1, di2, di3, dit, srtg, nrtg, lrtg, wrtg, ertg, doa
   );
   parameter DW = 32;		// data width of a VC
   parameter FT = 3;		// wire count of the flit tyoe bus
   parameter VCN = 2;		// number of VC per direction
   parameter SCN = DW/2;

   input [4:0][VCN-1:0][SCN-1:0]   di0, di1, di2, di3; // data input
   input [4:0][VCN-1:0][FT-1:0]    dit;		       // flit type input
   output [4:0][VCN-1:0] 	   dia;		       // input ack
   input [VCN-1:0][3:0] 	   srtg, nrtg, lrtg;   // routing guide
   input [VCN-1:0][1:0] 	   wrtg, ertg;

   output [4:0][SCN-1:0] 	   do0, do1, do2, do3; // data output
   output [4:0][FT-1:0] 	   dot;		       // flit type output
   input [4:0] 			   doa;		       // output ack

   // internal wires
   wire [VCN-1:0][3:0][SCN-1:0]    s0, s1, s2, s3;
   wire [VCN-1:0][3:0][FT-1:0] 	   sft;
   wire [VCN-1:0][3:0] 		   sa;
   wire [VCN-1:0][1:0][SCN-1:0]    w0, w1, w2, w3;
   wire [VCN-1:0][1:0][FT-1:0] 	   wft;
   wire [VCN-1:0][1:0] 		   wa;
   wire [VCN-1:0][3:0][SCN-1:0]    n0, n1, n2, n3;
   wire [VCN-1:0][3:0][FT-1:0] 	   nft;
   wire [VCN-1:0][3:0] 		   na;
   wire [VCN-1:0][1:0][SCN-1:0]    e0, e1, e2, e3;
   wire [VCN-1:0][1:0][FT-1:0] 	   eft;
   wire [VCN-1:0][1:0] 		   ea;
   wire [VCN-1:0][3:0][SCN-1:0]    l0, l1, l2, l3;
   wire [VCN-1:0][3:0][FT-1:0] 	   lft;
   wire [VCN-1:0][3:0] 		   la;

   wire [3:0][SCN-1:0][VCN-1:0]    ss0, ss1, ss2, ss3;
   wire [3:0][FT-1:0][VCN-1:0] 	   ssft;
   wire [1:0][SCN-1:0][VCN-1:0]    sw0, sw1, sw2, sw3;
   wire [1:0][FT-1:0][VCN-1:0] 	   swft;
   wire [3:0][SCN-1:0][VCN-1:0]    sn0, sn1, sn2, sn3;
   wire [3:0][FT-1:0][VCN-1:0] 	   snft;
   wire [1:0][SCN-1:0][VCN-1:0]    se0, se1, se2, se3;
   wire [1:0][FT-1:0][VCN-1:0] 	   seft;
   wire [3:0][SCN-1:0][VCN-1:0]    sl0, sl1, sl2, sl3;
   wire [3:0][FT-1:0][VCN-1:0] 	   slft;

   wire [3:0][SCN-1:0] 		   ms0, ms1, ms2, ms3;
   wire [3:0][FT-1:0] 		   msft;
   wire [1:0][SCN-1:0] 		   mw0, mw1, mw2, mw3;
   wire [1:0][FT-1:0] 		   mwft;
   wire [3:0][SCN-1:0] 		   mn0, mn1, mn2, mn3;
   wire [3:0][FT-1:0] 		   mnft;
   wire [1:0][SCN-1:0] 		   me0, me1, me2, me3;
   wire [1:0][FT-1:0] 		   meft;
   wire [3:0][SCN-1:0] 		   ml0, ml1, ml2, ml3;
   wire [3:0][FT-1:0] 		   mlft;

   genvar 		  i,j,k;
   
   generate
      // demux using the routing guides
      for(i=0; i<VCN; i++) begin: IMX
	 vcdmux #(.DW(DW), .VCN(4))
	 SDMX( 
	       .dia  ( dia[0][i]    ), 
	       .do0  ( s0[i]        ), 
	       .do1  ( s1[i]        ), 
	       .do2  ( s2[i]        ), 
	       .do3  ( s3[i]        ), 
	       .dot  ( sft[i]       ),
	       .di0  ( di0[0][i]    ), 
	       .di1  ( di1[0][i]    ), 
	       .di2  ( di2[0][i]    ), 
	       .di3  ( di3[0][i]    ), 
	       .dit  ( dit[0][i]    ), 
	       .divc ( srtg[i]      ), 
	       .doa  ( sa[i]        )
	       );
	 
	 vcdmux #(.DW(DW), .VCN(2))
	 WDMX( 
	       .dia  ( dia[1][i]    ), 
	       .do0  ( w0[i]        ), 
	       .do1  ( w1[i]        ), 
	       .do2  ( w2[i]        ), 
	       .do3  ( w3[i]        ), 
	       .dot  ( wft[i]       ),
	       .di0  ( di0[1][i]    ), 
	       .di1  ( di1[1][i]    ), 
	       .di2  ( di2[1][i]    ), 
	       .di3  ( di3[1][i]    ), 
	       .dit  ( dit[1][i]    ), 
	       .divc ( wrtg[i]      ), 
	       .doa  ( wa[i]        )
	       );

	 vcdmux #(.DW(DW), .VCN(4))
	 NDMX( 
	       .dia  ( dia[2][i]    ), 
	       .do0  ( n0[i]        ), 
	       .do1  ( n1[i]        ), 
	       .do2  ( n2[i]        ), 
	       .do3  ( n3[i]        ), 
	       .dot  ( nft[i]       ),
	       .di0  ( di0[2][i]    ), 
	       .di1  ( di1[2][i]    ), 
	       .di2  ( di2[2][i]    ), 
	       .di3  ( di3[2][i]    ), 
	       .dit  ( dit[2][i]    ), 
	       .divc ( nrtg[i]      ), 
	       .doa  ( na[i]        )
	       );
	 
	 vcdmux #(.DW(DW), .VCN(2))
	 EDMX( 
	       .dia  ( dia[3][i]    ), 
	       .do0  ( e0[i]        ), 
	       .do1  ( e1[i]        ), 
	       .do2  ( e2[i]        ), 
	       .do3  ( e3[i]        ), 
	       .dot  ( eft[i]       ),
	       .di0  ( di0[3][i]    ), 
	       .di1  ( di1[3][i]    ), 
	       .di2  ( di2[3][i]    ), 
	       .di3  ( di3[3][i]    ), 
	       .dit  ( dit[3][i]    ), 
	       .divc ( ertg[i]      ), 
	       .doa  ( ea[i]        )
	       );

	 vcdmux #(.DW(DW), .VCN(4))
	 LDMX( 
	       .dia  ( dia[4][i]    ), 
	       .do0  ( l0[i]        ), 
	       .do1  ( l1[i]        ), 
	       .do2  ( l2[i]        ), 
	       .do3  ( l3[i]        ), 
	       .dot  ( lft[i]       ),
	       .di0  ( di0[4][i]    ), 
	       .di1  ( di1[4][i]    ), 
	       .di2  ( di2[4][i]    ), 
	       .di3  ( di3[4][i]    ), 
	       .dit  ( dit[4][i]    ), 
	       .divc ( lrtg[i]      ), 
	       .doa  ( la[i]        )
	       );
	 
	 // acknowledgement
	 /*
	 c2 SA0 (.a0(srtg[i][0]), .a1(doa[1]), .q(sa[i][0]));
	 c2 SA1 (.a0(srtg[i][1]), .a1(doa[2]), .q(sa[i][1]));
	 c2 SA2 (.a0(srtg[i][2]), .a1(doa[3]), .q(sa[i][2]));
	 c2 SA3 (.a0(srtg[i][3]), .a1(doa[4]), .q(sa[i][3]));
	 c2 WA0 (.a0(wrtg[i][0]), .a1(doa[3]), .q(wa[i][0]));
	 c2 WA1 (.a0(wrtg[i][1]), .a1(doa[4]), .q(wa[i][1]));
	 c2 NA0 (.a0(nrtg[i][0]), .a1(doa[0]), .q(na[i][0]));
	 c2 NA1 (.a0(nrtg[i][1]), .a1(doa[1]), .q(na[i][1]));
	 c2 NA2 (.a0(nrtg[i][2]), .a1(doa[3]), .q(na[i][2]));
	 c2 NA3 (.a0(nrtg[i][3]), .a1(doa[4]), .q(na[i][3]));
	 c2 EA0 (.a0(ertg[i][0]), .a1(doa[1]), .q(ea[i][0]));
	 c2 EA1 (.a0(ertg[i][1]), .a1(doa[4]), .q(ea[i][1]));
	 c2 LA0 (.a0(lrtg[i][0]), .a1(doa[0]), .q(la[i][0]));
	 c2 LA1 (.a0(lrtg[i][1]), .a1(doa[1]), .q(la[i][1]));
	 c2 LA2 (.a0(lrtg[i][2]), .a1(doa[2]), .q(la[i][2]));
	 c2 LA3 (.a0(lrtg[i][3]), .a1(doa[3]), .q(la[i][3]));
	  */
	 assign sa[i][0] = doa[1];
	 assign sa[i][1] = doa[2];
	 assign sa[i][2] = doa[3];
	 assign sa[i][3] = doa[4];
	 assign wa[i][0] = doa[3];
	 assign wa[i][1] = doa[4];
	 assign na[i][0] = doa[0];
	 assign na[i][1] = doa[1];
	 assign na[i][2] = doa[3];
	 assign na[i][3] = doa[4];
	 assign ea[i][0] = doa[1];
	 assign ea[i][1] = doa[4];
	 assign la[i][0] = doa[0];
	 assign la[i][1] = doa[1];
	 assign la[i][2] = doa[2];
	 assign la[i][3] = doa[3];
	 
      end // block: IMX
   endgenerate

   generate
      for(i=0; i<VCN; i++) begin: V
	 for(j=0; j<4; j++) begin: D0
	    for(k=0; k<SCN; k++) begin: D
	       assign ss0[j][k][i] = s0[i][j][k];
	       assign ss1[j][k][i] = s1[i][j][k];
	       assign ss2[j][k][i] = s2[i][j][k];
	       assign ss3[j][k][i] = s3[i][j][k];
	       assign sn0[j][k][i] = n0[i][j][k];
	       assign sn1[j][k][i] = n1[i][j][k];
	       assign sn2[j][k][i] = n2[i][j][k];
	       assign sn3[j][k][i] = n3[i][j][k];
	       assign sl0[j][k][i] = l0[i][j][k];
	       assign sl1[j][k][i] = l1[i][j][k];
	       assign sl2[j][k][i] = l2[i][j][k];
	       assign sl3[j][k][i] = l3[i][j][k];
	    end // block: D
	    for(k=0; k<FT; k++) begin: T
	       assign ssft[j][k][i] = sft[i][j][k];
	       assign snft[j][k][i] = nft[i][j][k];
	       assign slft[j][k][i] = lft[i][j][k];
	    end // block: T
	 end // block: D0
	 
	 for(j=0; j<2; j++) begin: D1
	    for(k=0; k<SCN; k++) begin: D
	       assign sw0[j][k][i] = w0[i][j][k];
	       assign sw1[j][k][i] = w1[i][j][k];
	       assign sw2[j][k][i] = w2[i][j][k];
	       assign sw3[j][k][i] = w3[i][j][k];
	       assign se0[j][k][i] = e0[i][j][k];
	       assign se1[j][k][i] = e1[i][j][k];
	       assign se2[j][k][i] = e2[i][j][k];
	       assign se3[j][k][i] = e3[i][j][k];
	    end // block: D
	    for(k=0; k<FT; k++) begin: T
	       assign swft[j][k][i] = wft[i][j][k];
	       assign seft[j][k][i] = eft[i][j][k];
	    end // block: T
	 end // block: D1
      end

      for(j=0; j<4; j++) begin: D2
	 for(k=0; k<SCN; k++) begin: D
	    assign ms0[j][k] = |ss0[j][k];
	    assign ms1[j][k] = |ss1[j][k];
	    assign ms2[j][k] = |ss2[j][k];
	    assign ms3[j][k] = |ss3[j][k];
	    assign mn0[j][k] = |sn0[j][k];
	    assign mn1[j][k] = |sn1[j][k];
	    assign mn2[j][k] = |sn2[j][k];
	    assign mn3[j][k] = |sn3[j][k];   
	    assign ml0[j][k] = |sl0[j][k];
	    assign ml1[j][k] = |sl1[j][k];
	    assign ml2[j][k] = |sl2[j][k];
	    assign ml3[j][k] = |sl3[j][k];
	 end // block: D
	 for(k=0; k<FT; k++) begin: T
	    assign msft[j][k] = |ssft[j][k];
	    assign mnft[j][k] = |snft[j][k];
	    assign mlft[j][k] = |slft[j][k];
	 end
      end // block: D2

      for(j=0; j<2; j++) begin: D4
	 for(k=0; k<SCN; k++) begin: D
	    assign mw0[j][k] = |sw0[j][k];
	    assign mw1[j][k] = |sw1[j][k];
	    assign mw2[j][k] = |sw2[j][k];
	    assign mw3[j][k] = |sw3[j][k];
	    assign me0[j][k] = |se0[j][k];
	    assign me1[j][k] = |se1[j][k];
	    assign me2[j][k] = |se2[j][k];
	    assign me3[j][k] = |se3[j][k];   
	 end // block: D
	 for(k=0; k<FT; k++) begin: T
	    assign mwft[j][k] = |swft[j][k];
	    assign meft[j][k] = |seft[j][k];
	 end // block: T
      end // block: D4
   endgenerate
      
   // south output
   assign do0[0] = mn0[0]|ml0[0];
   assign do1[0] = mn1[0]|ml1[0];
   assign do2[0] = mn2[0]|ml2[0];
   assign do3[0] = mn3[0]|ml3[0];
   assign dot[0] = mnft[0]|mlft[0];

   // west output
   assign do0[1] = ms0[0]|mn0[1]|me0[0]|ml0[1];
   assign do1[1] = ms1[0]|mn1[1]|me1[0]|ml1[1];
   assign do2[1] = ms2[0]|mn2[1]|me2[0]|ml2[1];
   assign do3[1] = ms3[0]|mn3[1]|me3[0]|ml3[1];
   assign dot[1] = msft[0]|mnft[1]|meft[0]|mlft[1];

   // south output
   assign do0[2] = ms0[1]|ml0[2];
   assign do1[2] = ms1[1]|ml1[2];
   assign do2[2] = ms2[1]|ml2[2];
   assign do3[2] = ms3[1]|ml3[2];
   assign dot[2] = msft[1]|mlft[2];

   // east output
   assign do0[3] = ms0[2]|mw0[0]|mn0[2]|ml0[3];
   assign do1[3] = ms1[2]|mw1[0]|mn1[2]|ml1[3];
   assign do2[3] = ms2[2]|mw2[0]|mn2[2]|ml2[3];
   assign do3[3] = ms3[2]|mw3[0]|mn3[2]|ml3[3];
   assign dot[3] = msft[2]|mwft[0]|mnft[2]|mlft[3];

   // local output
   assign do0[4] = ms0[3]|mw0[1]|mn0[3]|me0[1];
   assign do1[4] = ms1[3]|mw1[1]|mn1[3]|me1[1];
   assign do2[4] = ms2[3]|mw2[1]|mn2[3]|me2[1];
   assign do3[4] = ms3[3]|mw3[1]|mn3[3]|me3[1];
   assign dot[4] = msft[3]|mwft[1]|mnft[3]|meft[1];


endmodule // dcb_vc
