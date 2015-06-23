/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Asynchronous VC router.
 
 History:
 05/04/2010  Initial version. <wsong83@gmail.com>
 02/06/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

module router (/*AUTOARG*/
   // Outputs
   sia, wia, nia, eia, lia, sic, wic, nic, eic, lic, so0, so1, so2,
   so3, wo0, wo1, wo2, wo3, no0, no1, no2, no3, eo0, eo1, eo2, eo3,
   lo0, lo1, lo2, lo3, soft, woft, noft, eoft, loft, sovc, wovc, novc,
   eovc, lovc, soca, woca, noca, eoca, loca,
   // Inputs
   si0, si1, si2, si3, wi0, wi1, wi2, wi3, ni0, ni1, ni2, ni3, ei0,
   ei1, ei2, ei3, li0, li1, li2, li3, sift, wift, nift, eift, lift,
   sivc, wivc, nivc, eivc, livc, sica, wica, nica, eica, lica, soa,
   woa, noa, eoa, loa, soc, woc, noc, eoc, loc, addrx, addry, rst_n
   );

   parameter VCN = 2;		// number of VCs per direction
   parameter DW = 32;		// data width of an input port
   parameter PD = 1;		// the depth of a input VC buffer
   parameter FT = 3;		// the number of flit types, currently 3 (HD, DATA, TAIL)
   
   parameter FCPD = PD;
   parameter SCN = DW/2;

   // input ports
   input [SCN-1:0]    si0, si1, si2, si3;
   input [SCN-1:0]    wi0, wi1, wi2, wi3;
   input [SCN-1:0]    ni0, ni1, ni2, ni3;
   input [SCN-1:0]    ei0, ei1, ei2, ei3;
   input [SCN-1:0]    li0, li1, li2, li3;
   input [FT-1:0]     sift, wift, nift, eift, lift;
   input [VCN-1:0]    sivc, wivc, nivc, eivc, livc;
   output 	      sia, wia, nia, eia, lia;
   output [VCN-1:0]   sic, wic, nic, eic, lic;
   input [VCN-1:0]    sica, wica, nica, eica, lica;

   // output ports
   output [SCN-1:0]   so0, so1, so2, so3;
   output [SCN-1:0]   wo0, wo1, wo2, wo3;
   output [SCN-1:0]   no0, no1, no2, no3;
   output [SCN-1:0]   eo0, eo1, eo2, eo3;
   output [SCN-1:0]   lo0, lo1, lo2, lo3;
   output [FT-1:0]    soft, woft, noft, eoft, loft;
   output [VCN-1:0]   sovc, wovc, novc, eovc, lovc;
   input 	      soa, woa, noa, eoa, loa;
   input [VCN-1:0]    soc, woc, noc, eoc, loc;
   output [VCN-1:0]   soca, woca, noca, eoca, loca;

   // local address, in 1-of-4 format
   input [7:0] 	      addrx, addry;
   // active-low reset
   input 	      rst_n;

   //----------------------------------
   // input to crossbar
   wire [VCN-1:0][SCN-1:0]     s2cb0, s2cb1, s2cb2, s2cb3;
   wire [VCN-1:0][SCN-1:0]     w2cb0, w2cb1, w2cb2, w2cb3;
   wire [VCN-1:0][SCN-1:0]     n2cb0, n2cb1, n2cb2, n2cb3;
   wire [VCN-1:0][SCN-1:0]     e2cb0, e2cb1, e2cb2, e2cb3;
   wire [VCN-1:0][SCN-1:0]     l2cb0, l2cb1, l2cb2, l2cb3;
   wire [VCN-1:0][FT-1:0]      s2cbt, w2cbt, n2cbt, e2cbt, l2cbt;
   wire [VCN-1:0][3:0] 	       s2cbrtg, n2cbrtg, l2cbrtg;
   wire [VCN-1:0][1:0] 	       w2cbrtg, e2cbrtg;
   wire [VCN-1:0] 	       s2cba, w2cba, n2cba, e2cba, l2cba;

   // VC requests
   wire [VCN-1:0][3:0] svcr, nvcr, lvcr;
   wire [VCN-1:0]      svcra, nvcra, lvcra;
   wire [VCN-1:0][1:0] wvcr, evcr;
   wire [VCN-1:0]      wvcra, evcra;

   // SW requests
   wire [VCN-1:0][1:0] siswr, wiswr, niswr, eiswr, liswr;
   wire [VCN-1:0][3:0] siswrt, niswrt, liswrt;
   wire [VCN-1:0][1:0] wiswrt, eiswrt;

   // crossbar to output
   wire [SCN-1:0]      cb2s0, cb2s1, cb2s2, cb2s3;
   wire [SCN-1:0]      cb2w0, cb2w1, cb2w2, cb2w3;
   wire [SCN-1:0]      cb2n0, cb2n1, cb2n2, cb2n3;
   wire [SCN-1:0]      cb2e0, cb2e1, cb2e2, cb2e3;
   wire [SCN-1:0]      cb2l0, cb2l1, cb2l2, cb2l3;
   wire [FT-1:0]       cb2st, cb2wt, cb2nt, cb2et, cb2lt;
   wire 	       cb2sa, cb2wa, cb2na, cb2ea, cb2la;

   // SW requests to VC arbiters in output buffers
   wire [VCN-1:0]      soswr, woswr, noswr, eoswr, loswr;
   wire [VCN-1:0]      soswa, woswa, noswa, eoswa, loswa;

   //-------------------------------------
   // south input buffer
   inpbuf #(.DW(DW), .VCN(VCN), .DIR(0), .SN(4), .PD(PD), .FT(FT))
   SIB (
	.dia   ( sia     ), 
	.cor   ( sic     ), 
	.do0   ( s2cb0   ), 
	.do1   ( s2cb1   ), 
	.do2   ( s2cb2   ), 
	.do3   ( s2cb3   ), 
	.dot   ( s2cbt   ), 
	.dortg ( s2cbrtg ), 
	.vcr   ( svcr    ), 
	.swr   ( siswr   ),
	.di0   ( si0     ), 
	.di1   ( si1     ), 
	.di2   ( si2     ), 
	.di3   ( si3     ), 
	.dit   ( sift    ), 
	.divc  ( sivc    ), 
	.coa   ( sica    ), 
	.doa   ( s2cba   ), 
	.vcra  ( svcra   ), 
	.swrt  ( siswrt  ), 
	.addrx ( addrx   ), 
	.addry ( addry   ),
	.rst_n ( rst_n   )
	);

   // west input buffer
   inpbuf #(.DW(DW), .VCN(VCN), .DIR(1), .SN(2), .PD(PD), .FT(FT))
   WIB (
	.dia   ( wia     ), 
	.cor   ( wic     ), 
	.do0   ( w2cb0   ), 
	.do1   ( w2cb1   ), 
	.do2   ( w2cb2   ), 
	.do3   ( w2cb3   ), 
	.dot   ( w2cbt   ), 
	.dortg ( w2cbrtg ), 
	.vcr   ( wvcr    ), 
	.swr   ( wiswr   ),
	.di0   ( wi0     ), 
	.di1   ( wi1     ), 
	.di2   ( wi2     ), 
	.di3   ( wi3     ), 
	.dit   ( wift    ), 
	.divc  ( wivc    ), 
	.coa   ( wica    ), 
	.doa   ( w2cba   ), 
	.vcra  ( wvcra   ), 
	.swrt  ( wiswrt  ), 
	.addrx ( addrx   ), 
	.addry ( addry   ),
	.rst_n ( rst_n   )
	);
   
   // north input buffer
   inpbuf #(.DW(DW), .VCN(VCN), .DIR(2), .SN(4), .PD(PD), .FT(FT))
   NIB (
	.dia   ( nia     ), 
	.cor   ( nic     ), 
	.do0   ( n2cb0   ), 
	.do1   ( n2cb1   ), 
	.do2   ( n2cb2   ), 
	.do3   ( n2cb3   ), 
	.dot   ( n2cbt   ), 
	.dortg ( n2cbrtg ), 
	.vcr   ( nvcr    ), 
	.swr   ( niswr   ),
	.di0   ( ni0     ), 
	.di1   ( ni1     ), 
	.di2   ( ni2     ), 
	.di3   ( ni3     ), 
	.dit   ( nift    ), 
	.divc  ( nivc    ), 
	.coa   ( nica    ), 
	.doa   ( n2cba   ), 
	.vcra  ( nvcra   ), 
	.swrt  ( niswrt  ), 
	.addrx ( addrx   ), 
	.addry ( addry   ),
	.rst_n ( rst_n   )
	);
   
   // east input buffer
   inpbuf #(.DW(DW), .VCN(VCN), .DIR(3), .SN(2), .PD(PD), .FT(FT))
   EIB (
	.dia   ( eia     ), 
	.cor   ( eic     ), 
	.do0   ( e2cb0   ), 
	.do1   ( e2cb1   ), 
	.do2   ( e2cb2   ), 
	.do3   ( e2cb3   ), 
	.dot   ( e2cbt   ), 
	.dortg ( e2cbrtg ), 
	.vcr   ( evcr    ), 
	.swr   ( eiswr   ),
	.di0   ( ei0     ), 
	.di1   ( ei1     ), 
	.di2   ( ei2     ), 
	.di3   ( ei3     ), 
	.dit   ( eift    ), 
	.divc  ( eivc    ), 
	.coa   ( eica    ), 
	.doa   ( e2cba   ), 
	.vcra  ( evcra   ), 
	.swrt  ( eiswrt  ), 
	.addrx ( addrx   ), 
	.addry ( addry   ),
	.rst_n ( rst_n   )
	);
   
   // local input buffer
   inpbuf #(.DW(DW), .VCN(VCN), .DIR(4), .SN(4), .PD(PD), .FT(FT))
   LIB (
	.dia   ( lia     ), 
	.cor   ( lic     ), 
	.do0   ( l2cb0   ), 
	.do1   ( l2cb1   ), 
	.do2   ( l2cb2   ), 
	.do3   ( l2cb3   ), 
	.dot   ( l2cbt   ), 
	.dortg ( l2cbrtg ), 
	.vcr   ( lvcr    ), 
	.swr   ( liswr   ),
	.di0   ( li0     ), 
	.di1   ( li1     ), 
	.di2   ( li2     ), 
	.di3   ( li3     ), 
	.dit   ( lift    ), 
	.divc  ( livc    ), 
	.coa   ( lica    ), 
	.doa   ( l2cba   ), 
	.vcra  ( lvcra   ), 
	.swrt  ( liswrt  ), 
	.addrx ( addrx   ), 
	.addry ( addry   ),
	.rst_n ( rst_n   )
	);

   // south output buffer
   outpbuf #(.DW(DW), .VCN(VCN), .FT(FT), .FCPD(FCPD))
   SOB (
	.dia   ( cb2sa   ), 
	.do0   ( so0     ), 
	.do1   ( so1     ), 
	.do2   ( so2     ), 
	.do3   ( so3     ), 
	.dot   ( soft    ), 
	.dovc  ( sovc    ), 
	.afc   ( soca    ), 
	.vca   ( soswa   ),
	.di0   ( cb2s0   ),
	.di1   ( cb2s1   ), 
	.di2   ( cb2s2   ), 
	.di3   ( cb2s3   ), 
	.dit   ( cb2st   ), 
	.doa   ( soa     ), 
	.credit( soc     ), 
	.vcr   ( soswr   ), 
	.rst_n ( rst_n   )
	);

   // west output buffer
   outpbuf #(.DW(DW), .VCN(VCN), .FT(FT), .FCPD(FCPD))
   WOB (
	.dia   ( cb2wa   ), 
	.do0   ( wo0     ), 
	.do1   ( wo1     ), 
	.do2   ( wo2     ), 
	.do3   ( wo3     ), 
	.dot   ( woft    ), 
	.dovc  ( wovc    ), 
	.afc   ( woca    ), 
	.vca   ( woswa   ),
	.di0   ( cb2w0   ),
	.di1   ( cb2w1   ), 
	.di2   ( cb2w2   ), 
	.di3   ( cb2w3   ), 
	.dit   ( cb2wt   ), 
	.doa   ( woa     ), 
	.credit( woc     ), 
	.vcr   ( woswr   ), 
	.rst_n ( rst_n   )
	);

   // north output buffer
   outpbuf #(.DW(DW), .VCN(VCN), .FT(FT), .FCPD(FCPD))
   NOB (
	.dia   ( cb2na   ), 
	.do0   ( no0     ), 
	.do1   ( no1     ), 
	.do2   ( no2     ), 
	.do3   ( no3     ), 
	.dot   ( noft    ), 
	.dovc  ( novc    ), 
	.afc   ( noca    ), 
	.vca   ( noswa   ),
	.di0   ( cb2n0   ),
	.di1   ( cb2n1   ), 
	.di2   ( cb2n2   ), 
	.di3   ( cb2n3   ), 
	.dit   ( cb2nt   ), 
	.doa   ( noa     ), 
	.credit( noc     ), 
	.vcr   ( noswr   ), 
	.rst_n ( rst_n   )
	);

   // east output buffer
   outpbuf #(.DW(DW), .VCN(VCN), .FT(FT), .FCPD(FCPD))
   EOB (
	.dia   ( cb2ea   ), 
	.do0   ( eo0     ), 
	.do1   ( eo1     ), 
	.do2   ( eo2     ), 
	.do3   ( eo3     ), 
	.dot   ( eoft    ), 
	.dovc  ( eovc    ), 
	.afc   ( eoca    ), 
	.vca   ( eoswa   ),
	.di0   ( cb2e0   ),
	.di1   ( cb2e1   ), 
	.di2   ( cb2e2   ), 
	.di3   ( cb2e3   ), 
	.dit   ( cb2et   ), 
	.doa   ( eoa     ), 
	.credit( eoc     ), 
	.vcr   ( eoswr   ), 
	.rst_n ( rst_n   )
	);

   // east output buffer
   outpbuf #(.DW(DW), .VCN(VCN), .FT(FT), .FCPD(FCPD))
   LOB (
	.dia   ( cb2la   ), 
	.do0   ( lo0     ), 
	.do1   ( lo1     ), 
	.do2   ( lo2     ), 
	.do3   ( lo3     ), 
	.dot   ( loft    ), 
	.dovc  ( lovc    ), 
	.afc   ( loca    ), 
	.vca   ( loswa   ),
	.di0   ( cb2l0   ),
	.di1   ( cb2l1   ), 
	.di2   ( cb2l2   ), 
	.di3   ( cb2l3   ), 
	.dit   ( cb2lt   ), 
	.doa   ( loa     ), 
	.credit( loc     ), 
	.vcr   ( loswr   ), 
	.rst_n ( rst_n   )
	);

   // VC allocator
   vcalloc #(.VCN(VCN))
   ALLOC (
	  .svcra   ( svcra   ), 
	  .wvcra   ( wvcra   ), 
	  .nvcra   ( nvcra   ), 
	  .evcra   ( evcra   ), 
	  .lvcra   ( lvcra   ), 
	  .sswa    ( siswrt  ), 
	  .wswa    ( wiswrt  ), 
	  .nswa    ( niswrt  ), 
	  .eswa    ( eiswrt  ), 
	  .lswa    ( liswrt  ),
	  .sosr    ( soswr   ), 
	  .wosr    ( woswr   ), 
	  .nosr    ( noswr   ), 
	  .eosr    ( eoswr   ), 
	  .losr    ( loswr   ),
	  .svcr    ( svcr    ), 
	  .nvcr    ( nvcr    ), 
	  .lvcr    ( lvcr    ), 
	  .wvcr    ( wvcr    ), 
	  .evcr    ( evcr    ), 
	  .sswr    ( siswr   ), 
	  .wswr    ( wiswr   ), 
	  .nswr    ( niswr   ), 
	  .eswr    ( eiswr   ), 
	  .lswr    ( liswr   ), 
	  .sosa    ( soswa   ),
	  .wosa    ( woswa   ), 
	  .nosa    ( noswa   ), 
	  .eosa    ( eoswa   ), 
	  .losa    ( loswa   ), 
	  .rst_n   ( rst_n   )
	  );

   // crossbar
   dcb_vc #(.DW(DW), .FT(FT), .VCN(VCN))
   CB (
       .dia   ( {l2cba, e2cba, n2cba, w2cba, s2cba} ), 
       .do0   ( {cb2l0, cb2e0, cb2n0, cb2w0, cb2s0} ), 
       .do1   ( {cb2l1, cb2e1, cb2n1, cb2w1, cb2s1} ), 
       .do2   ( {cb2l2, cb2e2, cb2n2, cb2w2, cb2s2} ), 
       .do3   ( {cb2l3, cb2e3, cb2n3, cb2w3, cb2s3} ), 
       .dot   ( {cb2lt, cb2et, cb2nt, cb2wt, cb2st} ),
       .di0   ( {l2cb0, e2cb0, n2cb0, w2cb0, s2cb0} ), 
       .di1   ( {l2cb1, e2cb1, n2cb1, w2cb1, s2cb1} ), 
       .di2   ( {l2cb2, e2cb2, n2cb2, w2cb2, s2cb2} ), 
       .di3   ( {l2cb3, e2cb3, n2cb3, w2cb3, s2cb3} ), 
       .dit   ( {l2cbt, e2cbt, n2cbt, w2cbt, s2cbt} ), 
       .srtg  ( s2cbrtg                             ), 
       .nrtg  ( n2cbrtg                             ), 
       .lrtg  ( l2cbrtg                             ), 
       .wrtg  ( w2cbrtg                             ), 
       .ertg  ( e2cbrtg                             ), 
       .doa   ( {cb2la, cb2ea, cb2na, cb2wa, cb2sa} )
       );
   
endmodule // router

   
   
   
