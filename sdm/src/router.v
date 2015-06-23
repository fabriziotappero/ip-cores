/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Wormhole/SDM router top level module
 *** SystemVerilog is used ***
 
 History:
 28/05/2009  Initial version. <wsong83@gmail.com>
 23/09/2010  Supporting channel slicing and SDM using macro difinitions. <wsong83@gmail.com>
 22/10/2010  Parameterize the number of pipelines in output buffers. <wsong83@gmail.com>
 25/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

// the router structure definitions
`include "define.v"

module router(/*AUTOARG*/
   // Outputs
   so0, so1, so2, so3, wo0, wo1, wo2, wo3, no0, no1, no2, no3, eo0,
   eo1, eo2, eo3, lo0, lo1, lo2, lo3, so4, wo4, no4, eo4, lo4, sia,
   wia, nia, eia, lia,
   // Inputs
   si0, si1, si2, si3, wi0, wi1, wi2, wi3, ni0, ni1, ni2, ni3, ei0,
   ei1, ei2, ei3, li0, li1, li2, li3, si4, wi4, ni4, ei4, li4, soa,
   woa, noa, eoa, loa, addrx, addry, rst_n
   );

   parameter VCN = 1;		// number of virtual circuits in each direction. When VCN == 1, it is a wormhole router
   parameter DW = 32;		// the datawidth of a single virtual circuit, the total data width of the router is DW*VCN
   parameter IPD = 1;		// the number of half-buffer stages in input buffers
   parameter OPD = 2;		// the number of half-buffer stages in output buffers
   parameter SCN = DW/2;	// the number of 1-of-4 sub-channel in each virtual circuit

   input [VCN-1:0][SCN-1:0]      si0, si1, si2, si3; // south input [0], X+1
   input [VCN-1:0][SCN-1:0] 	 wi0, wi1, wi2, wi3; // west input [1], Y-1
   input [VCN-1:0][SCN-1:0] 	 ni0, ni1, ni2, ni3; // north input [2], X-1
   input [VCN-1:0][SCN-1:0] 	 ei0, ei1, ei2, ei3; // east input [3], Y+1
   input [VCN-1:0][SCN-1:0] 	 li0, li1, li2, li3; // local input
   output [VCN-1:0][SCN-1:0] 	 so0, so1, so2, so3; // south output
   output [VCN-1:0][SCN-1:0] 	 wo0, wo1, wo2, wo3; // west output
   output [VCN-1:0][SCN-1:0] 	 no0, no1, no2, no3; // north output
   output [VCN-1:0][SCN-1:0] 	 eo0, eo1, eo2, eo3; // east output
   output [VCN-1:0][SCN-1:0] 	 lo0, lo1, lo2, lo3; // local output
   
   // eof bits and ack lines
`ifdef ENABLE_CHANNEL_SLICING
   input [VCN-1:0][SCN-1:0] 	 si4, wi4, ni4, ei4, li4;
   output [VCN-1:0][SCN-1:0] 	 so4, wo4, no4, eo4, lo4;
   output [VCN-1:0][SCN-1:0] 	 sia, wia, nia, eia, lia;
   input [VCN-1:0][SCN-1:0] 	 soa, woa, noa, eoa, loa;
`else
   input [VCN-1:0] 		 si4, wi4, ni4, ei4, li4;
   output [VCN-1:0] 		 so4, wo4, no4, eo4, lo4;
   output [VCN-1:0] 		 sia, wia, nia, eia, lia;
   input [VCN-1:0] 		 soa, woa, noa, eoa, loa;
`endif // !`ifdef ENABLE_CHANNEL_SLICING

   input [7:0] 			 addrx, addry; // the local address of the router, coded in 1-of-4 coding
   input 			 rst_n;	       // active low reset signal

   // internal wires, input buffers to switches (crossbar): [dir]2[cb][1-of-4 index]
   wire [VCN-1:0][SCN-1:0] 	 s2c0, s2c1, s2c2, s2c3; // south input to switch data
   wire [VCN-1:0][SCN-1:0] 	 w2c0, w2c1, w2c2, w2c3;
   wire [VCN-1:0][SCN-1:0] 	 n2c0, n2c1, n2c2, n2c3;
   wire [VCN-1:0][SCN-1:0] 	 e2c0, e2c1, e2c2, e2c3;
   wire [VCN-1:0][SCN-1:0] 	 l2c0, l2c1, l2c2, l2c3;
   // internal wires, switches (crossbar) to output buffers: [cb]2[dir][1-of-4 index]
   wire [VCN-1:0][SCN-1:0] 	 c2s0, c2s1, c2s2, c2s3;
   wire [VCN-1:0][SCN-1:0] 	 c2w0, c2w1, c2w2, c2w3;
   wire [VCN-1:0][SCN-1:0] 	 c2n0, c2n1, c2n2, c2n3; // switch to north output
   wire [VCN-1:0][SCN-1:0] 	 c2e0, c2e1, c2e2, c2e3;
   wire [VCN-1:0][SCN-1:0] 	 c2l0, c2l1, c2l2, c2l3;

   // internal wires for ack and eof bits
`ifdef ENABLE_CHANNEL_SLICING
   wire [VCN-1:0][SCN-1:0] 	 s2c4, w2c4, n2c4, e2c4, l2c4;
   wire [VCN-1:0][SCN-1:0] 	 c2s4, c2w4, c2n4, c2e4, c2l4;
   wire [VCN-1:0][SCN-1:0] 	 s2ca, w2ca, n2ca, e2ca, l2ca;
   wire [VCN-1:0][SCN-1:0] 	 c2sa, c2wa, c2na, c2ea, c2la;
`else
   wire [VCN-1:0] 		 s2c4, w2c4, n2c4, e2c4, l2c4;
   wire [VCN-1:0] 		 c2s4, c2w4, c2n4, c2e4, c2l4;
   wire [VCN-1:0] 		 s2ca, w2ca, n2ca, e2ca, l2ca;
   wire [VCN-1:0] 		 c2sa, c2wa, c2na, c2ea, c2la;
`endif // !`ifdef ENABLE_CHANNEL_SLICING

   // the requests/acks from/to input buffers to switch allocators
   wire [VCN-1:0][3:0] 		 sreq, nreq, lreq;
   wire [VCN-1:0][1:0] 		 wreq, ereq;
   wire [VCN-1:0] 		 sack, wack, nack, eack, lack;

   // configuration bits for the switches
`ifdef ENABLE_CLOS
   wire [4:0][VCN-1:0][VCN-1:0]  imcfg;
   wire [VCN-1:0][1:0] 		 scfg, ncfg;
   wire [VCN-1:0][3:0] 		 wcfg, ecfg, lcfg;
`else // normal crossbar based SDM
   wire [VCN-1:0][2*VCN-1:0] 	 scfg, ncfg;
   wire [VCN-1:0][4*VCN-1:0] 	 wcfg, ecfg, lcfg;
`endif
   
   
   genvar 		  i;

   generate
      for (i=0; i<VCN; i++) begin: SC

	 // --------------- input buffers ------------------- //

	 inp_buf #(.DIR(0), .RN(4), .DW(DW), .PD(IPD))
	 SIB (
	      .o0     ( s2c0[i]  ),
	      .o1     ( s2c1[i]  ),
	      .o2     ( s2c2[i]  ),
	      .o3     ( s2c3[i]  ),
	      .o4     ( s2c4[i]  ),
	      .ia     ( sia[i]   ), 
	      .arb_r  ( sreq[i]  ),
	      .rst_n  ( rst_n    ), 
	      .i0     ( si0[i]   ), 
	      .i1     ( si1[i]   ), 
	      .i2     ( si2[i]   ), 
	      .i3     ( si3[i]   ), 
	      .i4     ( si4[i]   ), 
	      .oa     ( s2ca[i]  ), 
	      .addrx  ( addrx    ), 
	      .addry  ( addry    ), 
	      .arb_ra ( sack[i]  )
	      );

	 inp_buf #(.DIR(1), .RN(2), .DW(DW), .PD(IPD))
	 WIB (
	      .o0     ( w2c0[i]  ),
	      .o1     ( w2c1[i]  ),
	      .o2     ( w2c2[i]  ),
	      .o3     ( w2c3[i]  ),
	      .o4     ( w2c4[i]  ),
	      .ia     ( wia[i]   ), 
	      .arb_r  ( wreq[i]  ),
	      .rst_n  ( rst_n    ), 
	      .i0     ( wi0[i]   ), 
	      .i1     ( wi1[i]   ), 
	      .i2     ( wi2[i]   ), 
	      .i3     ( wi3[i]   ), 
	      .i4     ( wi4[i]   ), 
	      .oa     ( w2ca[i]  ), 
	      .addrx  ( addrx    ), 
	      .addry  ( addry    ), 
	      .arb_ra ( wack[i]  )
	      );

	 inp_buf #(.DIR(2), .RN(4), .DW(DW), .PD(IPD))
	 NIB (
	      .o0     ( n2c0[i]  ),
	      .o1     ( n2c1[i]  ),
	      .o2     ( n2c2[i]  ),
	      .o3     ( n2c3[i]  ),
	      .o4     ( n2c4[i]  ),
	      .ia     ( nia[i]   ), 
	      .arb_r  ( nreq[i]  ),
	      .rst_n  ( rst_n    ), 
	      .i0     ( ni0[i]   ), 
	      .i1     ( ni1[i]   ), 
	      .i2     ( ni2[i]   ), 
	      .i3     ( ni3[i]   ), 
	      .i4     ( ni4[i]   ), 
	      .oa     ( n2ca[i]  ), 
	      .addrx  ( addrx    ), 
	      .addry  ( addry    ), 
	      .arb_ra ( nack[i]  )
	      );

	 inp_buf #(.DIR(3), .RN(2), .DW(DW), .PD(IPD))
	 EIB (
	      .o0     ( e2c0[i]  ),
	      .o1     ( e2c1[i]  ),
	      .o2     ( e2c2[i]  ),
	      .o3     ( e2c3[i]  ),
	      .o4     ( e2c4[i]  ),
	      .ia     ( eia[i]   ), 
	      .arb_r  ( ereq[i]  ),
	      .rst_n  ( rst_n    ), 
	      .i0     ( ei0[i]   ), 
	      .i1     ( ei1[i]   ), 
	      .i2     ( ei2[i]   ), 
	      .i3     ( ei3[i]   ), 
	      .i4     ( ei4[i]   ), 
	      .oa     ( e2ca[i]  ), 
	      .addrx  ( addrx    ), 
	      .addry  ( addry    ), 
	      .arb_ra ( eack[i]  )
	      );

	 inp_buf #(.DIR(4), .RN(4), .DW(DW), .PD(IPD))
	 LIB (
	      .o0     ( l2c0[i]  ),
	      .o1     ( l2c1[i]  ),
	      .o2     ( l2c2[i]  ),
	      .o3     ( l2c3[i]  ),
	      .o4     ( l2c4[i]  ),
	      .ia     ( lia[i]   ), 
	      .arb_r  ( lreq[i]  ),
	      .rst_n  ( rst_n    ), 
	      .i0     ( li0[i]   ), 
	      .i1     ( li1[i]   ), 
	      .i2     ( li2[i]   ), 
	      .i3     ( li3[i]   ), 
	      .i4     ( li4[i]   ), 
	      .oa     ( l2ca[i]  ), 
	      .addrx  ( addrx    ), 
	      .addry  ( addry    ), 
	      .arb_ra ( lack[i]  )
	      );

	 // --------------------- output buffers ---------------- //
	 outp_buf #(.DW(DW), .PD(OPD))
	 SOB (
	      .o0     ( so0[i]   ),
	      .o1     ( so1[i]   ),
	      .o2     ( so2[i]   ),
	      .o3     ( so3[i]   ),
	      .o4     ( so4[i]   ),
	      .oa     ( soa[i]   ),
	      .i0     ( c2s0[i]  ),
	      .i1     ( c2s1[i]  ),
	      .i2     ( c2s2[i]  ),
	      .i3     ( c2s3[i]  ),
	      .i4     ( c2s4[i]  ),
	      .ia     ( c2sa[i]  ),
	      .rst_n  ( rst_n    )
	      );
	 
	 outp_buf #(.DW(DW), .PD(OPD))
	 WOB (
	      .o0     ( wo0[i]   ),
	      .o1     ( wo1[i]   ),
	      .o2     ( wo2[i]   ),
	      .o3     ( wo3[i]   ),
	      .o4     ( wo4[i]   ),
	      .oa     ( woa[i]   ),
	      .i0     ( c2w0[i]  ),
	      .i1     ( c2w1[i]  ),
	      .i2     ( c2w2[i]  ),
	      .i3     ( c2w3[i]  ),
	      .i4     ( c2w4[i]  ),
	      .ia     ( c2wa[i]  ),
	      .rst_n  ( rst_n    )
	      );
	 
	 outp_buf #(.DW(DW), .PD(OPD))
	 NOB (
	      .o0     ( no0[i]   ),
	      .o1     ( no1[i]   ),
	      .o2     ( no2[i]   ),
	      .o3     ( no3[i]   ),
	      .o4     ( no4[i]   ),
	      .oa     ( noa[i]   ),
	      .i0     ( c2n0[i]  ),
	      .i1     ( c2n1[i]  ),
	      .i2     ( c2n2[i]  ),
	      .i3     ( c2n3[i]  ),
	      .i4     ( c2n4[i]  ),
	      .ia     ( c2na[i]  ),
	      .rst_n  ( rst_n    )
	      );
	 
	 outp_buf #(.DW(DW), .PD(OPD))
	 EOB (
	      .o0     ( eo0[i]   ),
	      .o1     ( eo1[i]   ),
	      .o2     ( eo2[i]   ),
	      .o3     ( eo3[i]   ),
	      .o4     ( eo4[i]   ),
	      .oa     ( eoa[i]   ),
	      .i0     ( c2e0[i]  ),
	      .i1     ( c2e1[i]  ),
	      .i2     ( c2e2[i]  ),
	      .i3     ( c2e3[i]  ),
	      .i4     ( c2e4[i]  ),
	      .ia     ( c2ea[i]  ),
	      .rst_n  ( rst_n    )
	      );
	 
	 outp_buf #(.DW(DW), .PD(OPD))
	 LOB (
	      .o0     ( lo0[i]   ),
	      .o1     ( lo1[i]   ),
	      .o2     ( lo2[i]   ),
	      .o3     ( lo3[i]   ),
	      .o4     ( lo4[i]   ),
	      .oa     ( loa[i]   ),
	      .i0     ( c2l0[i]  ),
	      .i1     ( c2l1[i]  ),
	      .i2     ( c2l2[i]  ),
	      .i3     ( c2l3[i]  ),
	      .i4     ( c2l4[i]  ),
	      .ia     ( c2la[i]  ),
	      .rst_n  ( rst_n    )
	      );
	 
      end // block: SC
   endgenerate

`ifdef ENABLE_CLOS
   dclos #(.MN(VCN), .NN(VCN), .DW(DW))
   CB (
       .so0     ( c2s0      ), 
       .so1     ( c2s1      ), 
       .so2     ( c2s2      ), 
       .so3     ( c2s3      ), 
       .so4     ( c2s4      ), 
       .soa     ( c2sa      ),
       .wo0     ( c2w0      ), 
       .wo1     ( c2w1      ), 
       .wo2     ( c2w2      ), 
       .wo3     ( c2w3      ), 
       .wo4     ( c2w4      ), 
       .woa     ( c2wa      ),
       .no0     ( c2n0      ), 
       .no1     ( c2n1      ), 
       .no2     ( c2n2      ), 
       .no3     ( c2n3      ), 
       .no4     ( c2n4      ), 
       .noa     ( c2na      ),
       .eo0     ( c2e0      ), 
       .eo1     ( c2e1      ), 
       .eo2     ( c2e2      ), 
       .eo3     ( c2e3      ), 
       .eo4     ( c2e4      ), 
       .eoa     ( c2ea      ),
       .lo0     ( c2l0      ), 
       .lo1     ( c2l1      ), 
       .lo2     ( c2l2      ), 
       .lo3     ( c2l3      ), 
       .lo4     ( c2l4      ), 
       .loa     ( c2la      ),
       .si0     ( s2c0      ), 
       .si1     ( s2c1      ), 
       .si2     ( s2c2      ), 
       .si3     ( s2c3      ), 
       .si4     ( s2c4      ), 
       .sia     ( s2ca      ),
       .wi0     ( w2c0      ), 
       .wi1     ( w2c1      ), 
       .wi2     ( w2c2      ), 
       .wi3     ( w2c3      ), 
       .wi4     ( w2c4      ), 
       .wia     ( w2ca      ),
       .ni0     ( n2c0      ), 
       .ni1     ( n2c1      ), 
       .ni2     ( n2c2      ), 
       .ni3     ( n2c3      ), 
       .ni4     ( n2c4      ), 
       .nia     ( n2ca      ),
       .ei0     ( e2c0      ), 
       .ei1     ( e2c1      ), 
       .ei2     ( e2c2      ), 
       .ei3     ( e2c3      ), 
       .ei4     ( e2c4      ), 
       .eia     ( e2ca      ),
       .li0     ( l2c0      ), 
       .li1     ( l2c1      ), 
       .li2     ( l2c2      ), 
       .li3     ( l2c3      ), 
       .li4     ( l2c4      ), 
       .lia     ( l2ca      ),
       .imcfg   ( imcfg     ),
       .wcfg    ( wcfg      ), 
       .ecfg    ( ecfg      ), 
       .lcfg    ( lcfg      ), 
       .scfg    ( scfg      ), 
       .ncfg    ( ncfg      )
       ) ;

   clos_sch #(.M(VCN), .N(VCN))
   ALLOC (
	  .sack  ( sack    ), 
	  .wack  ( wack    ), 
	  .nack  ( nack    ), 
	  .eack  ( eack    ), 
	  .lack  ( lack    ), 
	  .imc   ( imcfg   ), 
	  .scfg  ( scfg    ), 
	  .ncfg  ( ncfg    ), 
	  .wcfg  ( wcfg    ), 
	  .ecfg  ( ecfg    ), 
	  .lcfg  ( lcfg    ),
	  .sreq  ( sreq    ), 
	  .nreq  ( nreq    ), 
	  .lreq  ( lreq    ), 
	  .wreq  ( wreq    ), 
	  .ereq  ( ereq    ), 
	  .rst_n ( rst_n   )
	  );
`else  // Crossbar based SDM

   dcb_xy #(.VCN(VCN), .VCW(DW))
   CB (
       .so0     ( c2s0      ), 
       .so1     ( c2s1      ), 
       .so2     ( c2s2      ), 
       .so3     ( c2s3      ), 
       .so4     ( c2s4      ), 
       .soa     ( c2sa      ),
       .wo0     ( c2w0      ), 
       .wo1     ( c2w1      ), 
       .wo2     ( c2w2      ), 
       .wo3     ( c2w3      ), 
       .wo4     ( c2w4      ), 
       .woa     ( c2wa      ),
       .no0     ( c2n0      ), 
       .no1     ( c2n1      ), 
       .no2     ( c2n2      ), 
       .no3     ( c2n3      ), 
       .no4     ( c2n4      ), 
       .noa     ( c2na      ),
       .eo0     ( c2e0      ), 
       .eo1     ( c2e1      ), 
       .eo2     ( c2e2      ), 
       .eo3     ( c2e3      ), 
       .eo4     ( c2e4      ), 
       .eoa     ( c2ea      ),
       .lo0     ( c2l0      ), 
       .lo1     ( c2l1      ), 
       .lo2     ( c2l2      ), 
       .lo3     ( c2l3      ), 
       .lo4     ( c2l4      ), 
       .loa     ( c2la      ),
       .si0     ( s2c0      ), 
       .si1     ( s2c1      ), 
       .si2     ( s2c2      ), 
       .si3     ( s2c3      ), 
       .si4     ( s2c4      ), 
       .sia     ( s2ca      ),
       .wi0     ( w2c0      ), 
       .wi1     ( w2c1      ), 
       .wi2     ( w2c2      ), 
       .wi3     ( w2c3      ), 
       .wi4     ( w2c4      ), 
       .wia     ( w2ca      ),
       .ni0     ( n2c0      ), 
       .ni1     ( n2c1      ), 
       .ni2     ( n2c2      ), 
       .ni3     ( n2c3      ), 
       .ni4     ( n2c4      ), 
       .nia     ( n2ca      ),
       .ei0     ( e2c0      ), 
       .ei1     ( e2c1      ), 
       .ei2     ( e2c2      ), 
       .ei3     ( e2c3      ), 
       .ei4     ( e2c4      ), 
       .eia     ( e2ca      ),
       .li0     ( l2c0      ), 
       .li1     ( l2c1      ), 
       .li2     ( l2c2      ), 
       .li3     ( l2c3      ), 
       .li4     ( l2c4      ), 
       .lia     ( l2ca      ),
       .wcfg    ( wcfg      ), 
       .ecfg    ( ecfg      ), 
       .lcfg    ( lcfg      ), 
       .scfg    ( scfg      ), 
       .ncfg    ( ncfg      )
       ) ;
   
   
   sdm_sch #(.VCN(VCN))
   ALLOC (
	  .sack  ( sack    ), 
	  .wack  ( wack    ), 
	  .nack  ( nack    ), 
	  .eack  ( eack    ), 
	  .lack  ( lack    ), 
	  .scfg  ( scfg    ), 
	  .ncfg  ( ncfg    ), 
	  .wcfg  ( wcfg    ), 
	  .ecfg  ( ecfg    ), 
	  .lcfg  ( lcfg    ),
	  .sreq  ( sreq    ), 
	  .nreq  ( nreq    ), 
	  .lreq  ( lreq    ), 
	  .wreq  ( wreq    ), 
	  .ereq  ( ereq    ),
	  .rst_n ( rst_n   )
	  );
`endif

endmodule // router
