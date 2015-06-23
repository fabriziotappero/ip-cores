/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 VC allocator.
 
 History:
 05/04/2010  Initial version. <wsong83@gmail.com>
 29/09/2010  Use the asynchronous PIM alg. (MNMA) <wsong83@gmail.com>
 03/10/2010  Add VCREN c2n gates to defer the withdrawal of request until data switch is withdrawn. <wsong83@gmail.com>
 02/06/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

// the router structure definitions
`include "define.v"

module vcalloc (/*AUTOARG*/
   // Outputs
   svcra, wvcra, nvcra, evcra, lvcra, sswa, wswa, nswa, eswa, lswa,
   sosr, wosr, nosr, eosr, losr,
   // Inputs
   svcr, nvcr, lvcr, wvcr, evcr, sswr, wswr, nswr, eswr, lswr, sosa,
   wosa, nosa, eosa, losa, rst_n
   );

   parameter VCN = 4;		// number of VCs

   input [VCN-1:0][3:0]            svcr, nvcr, lvcr; // VC requests from input VCs
   input [VCN-1:0][1:0] 	   wvcr, evcr;
   output [VCN-1:0] 		   svcra,wvcra, nvcra, evcra, lvcra; // ack to VC requests
   
   input [VCN-1:0][1:0] 	   sswr, wswr, nswr, eswr, lswr; // SW requests from input VCs
   output [VCN-1:0][3:0] 	   sswa, nswa, lswa;		 // ack/routing guide to input VCs
   output [VCN-1:0][1:0] 	   wswa, eswa;
      
   output [VCN-1:0] 		   sosr, wosr, nosr, eosr, losr; // SW requests to output VCs
   input [VCN-1:0] 		   sosa, wosa, nosa, eosa, losa;
   
   input 			   rst_n; // active-low reset
   
   wire [VCN-1:0][3:0] 		   msvcr, mnvcr, mlvcr; // shuffled VC requests
   wire [VCN-1:0][1:0] 		   mwvcr, mevcr;

   wire [VCN-1:0][3:0][VCN-1:0]    wcfg, ecfg, lcfg; // configuration signals from VCA to Req CB
   wire [VCN-1:0][1:0][VCN-1:0]    scfg, ncfg;

   wire [VCN-1:0][3:0][VCN-1:0]    mwcfg, mecfg, mlcfg; // the cfg before the AND gates
   wire [VCN-1:0][1:0][VCN-1:0]    mscfg, mncfg;
   
   wire [VCN-1:0][3:0][VCN-1:0]    wcfga, ecfga, lcfga; // cfg ack from req CB
   wire [VCN-1:0][1:0][VCN-1:0]    scfga, ncfga;
   
`ifndef ENABLE_MRMA
   wire [1:0][VCN-1:0][VCN-1:0]    i2sr, i2nr; // input to output requests
   wire [3:0][VCN-1:0][VCN-1:0]    i2wr, i2er, i2lr;
`else
   wire [1:0][VCN-1:0] 		   i2sr, i2nr; // input to output requests
   wire [3:0][VCN-1:0] 		   i2wr, i2er, i2lr;
`endif   
   wire [1:0][VCN-1:0] 		   i2sa, i2na; // ack for i2(dir)r
   wire [3:0][VCN-1:0] 		   i2wa, i2ea, i2la;

   // other wires for shuffle purposes
   wire [VCN-1:0][3:0][VCN-1:0]    svcram, nvcram, lvcram;
   wire [VCN-1:0][1:0][VCN-1:0]    wvcram, evcram;
   wire [VCN-1:0][3:0][VCN-1:0]    svcrami, nvcrami, lvcrami;
   wire [VCN-1:0][1:0][VCN-1:0]    wvcrami, evcrami;
   wire [VCN-1:0][3:0] 		   svcrai, nvcrai, lvcrai;
   wire [VCN-1:0][1:0] 		   wvcrai, evcrai;
   wire [VCN-1:0][3:0] 		   svcraii, nvcraii, lvcraii;
   wire [VCN-1:0][1:0] 		   wvcraii, evcraii;
   
`ifdef ENABLE_MRMA
   wire [VCN:0] 		   vcrst_n; // the buffered resets to avoid metastability
   wire [VCN-1:0] 		   svcrdy, svcrdya; // south vc ready status
   wire [VCN-1:0] 		   wvcrdy, wvcrdya; // west vc ready status
   wire [VCN-1:0] 		   nvcrdy, nvcrdya; // north vc ready status
   wire [VCN-1:0] 		   evcrdy, evcrdya; // east vc ready status
   wire [VCN-1:0] 		   lvcrdy, lvcrdya; // local vc ready status
`endif

   genvar 		 i, j;
   
   generate
      for(i=0; i<VCN; i++) begin:SF
	 
	 assign svcra[i] = {svcrai[i][0]|svcrai[i][1]|svcrai[i][2]|svcrai[i][3]};
	 assign wvcra[i] = {wvcrai[i][0]|wvcrai[i][1]};
	 assign nvcra[i] = {nvcrai[i][0]|nvcrai[i][1]|nvcrai[i][2]|nvcrai[i][3]};
	 assign evcra[i] = {evcrai[i][0]|evcrai[i][1]};
	 assign lvcra[i] = {lvcrai[i][0]|lvcrai[i][1]|lvcrai[i][2]|lvcrai[i][3]};
	 
	 or VCRENn0( mnvcr[i][0], nvcr[i][0], (|nvcram[i][0])&rst_n);
	 or VCRENl0( mlvcr[i][0], lvcr[i][0], (|lvcram[i][0])&rst_n);
	 or VCRENs0( msvcr[i][0], svcr[i][0], (|svcram[i][0])&rst_n);
	 or VCRENn1( mnvcr[i][1], nvcr[i][1], (|nvcram[i][1])&rst_n);
	 or VCRENe0( mevcr[i][0], evcr[i][0], (|evcram[i][0])&rst_n);
	 or VCRENl1( mlvcr[i][1], lvcr[i][1], (|lvcram[i][1])&rst_n);
	 or VCRENs1( msvcr[i][1], svcr[i][1], (|svcram[i][1])&rst_n);
	 or VCRENl2( mlvcr[i][2], lvcr[i][2], (|lvcram[i][2])&rst_n);
	 or VCRENs2( msvcr[i][2], svcr[i][2], (|svcram[i][2])&rst_n);
	 or VCRENw0( mwvcr[i][0], wvcr[i][0], (|wvcram[i][0])&rst_n);
	 or VCRENn2( mnvcr[i][2], nvcr[i][2], (|nvcram[i][2])&rst_n);
	 or VCRENl3( mlvcr[i][3], lvcr[i][3], (|lvcram[i][3])&rst_n);
	 or VCRENs3( msvcr[i][3], svcr[i][3], (|svcram[i][3])&rst_n);
	 or VCRENw1( mwvcr[i][1], wvcr[i][1], (|wvcram[i][1])&rst_n);
	 or VCRENn3( mnvcr[i][3], nvcr[i][3], (|nvcram[i][3])&rst_n);
	 or VCRENe1( mevcr[i][1], evcr[i][1], (|evcram[i][1])&rst_n);

	 and VCAOs0 (svcrai[i][0], (|svcrami[i][0]), svcraii[i][0]);
	 and VCAOs1 (svcrai[i][1], (|svcrami[i][1]), svcraii[i][1]);
	 and VCAOs2 (svcrai[i][2], (|svcrami[i][2]), svcraii[i][2]);
	 and VCAOs3 (svcrai[i][3], (|svcrami[i][3]), svcraii[i][3]);
	 and VCAOw0 (wvcrai[i][0], (|wvcrami[i][0]), wvcraii[i][0]);
	 and VCAOw1 (wvcrai[i][1], (|wvcrami[i][1]), wvcraii[i][1]);
	 and VCAOn0 (nvcrai[i][0], (|nvcrami[i][0]), nvcraii[i][0]);
	 and VCAOn1 (nvcrai[i][1], (|nvcrami[i][1]), nvcraii[i][1]);
	 and VCAOn2 (nvcrai[i][2], (|nvcrami[i][2]), nvcraii[i][2]);
	 and VCAOn3 (nvcrai[i][3], (|nvcrami[i][3]), nvcraii[i][3]);
	 and VCAOe0 (evcrai[i][0], (|evcrami[i][0]), evcraii[i][0]);
	 and VCAOe1 (evcrai[i][1], (|evcrami[i][1]), evcraii[i][1]);
	 and VCAOl0 (lvcrai[i][0], (|lvcrami[i][0]), lvcraii[i][0]);
	 and VCAOl1 (lvcrai[i][1], (|lvcrami[i][1]), lvcraii[i][1]);
	 and VCAOl2 (lvcrai[i][2], (|lvcrami[i][2]), lvcraii[i][2]);
	 and VCAOl3 (lvcrai[i][3], (|lvcrami[i][3]), lvcraii[i][3]);
	 
	 or VCAIs0  (svcraii[i][0], (~svcr[i][0]), (|svcram[i][0]));
	 or VCAIs1  (svcraii[i][1], (~svcr[i][1]), (|svcram[i][1]));
	 or VCAIs2  (svcraii[i][2], (~svcr[i][2]), (|svcram[i][2]));
	 or VCAIs3  (svcraii[i][3], (~svcr[i][3]), (|svcram[i][3]));
	 or VCAIw0  (wvcraii[i][0], (~wvcr[i][0]), (|wvcram[i][0]));
	 or VCAIw1  (wvcraii[i][1], (~wvcr[i][1]), (|wvcram[i][1]));
	 or VCAIn0  (nvcraii[i][0], (~nvcr[i][0]), (|nvcram[i][0]));
	 or VCAIn1  (nvcraii[i][1], (~nvcr[i][1]), (|nvcram[i][1]));
	 or VCAIn2  (nvcraii[i][2], (~nvcr[i][2]), (|nvcram[i][2]));
	 or VCAIn3  (nvcraii[i][3], (~nvcr[i][3]), (|nvcram[i][3]));
	 or VCAIe0  (evcraii[i][0], (~evcr[i][0]), (|evcram[i][0]));
	 or VCAIe1  (evcraii[i][1], (~evcr[i][1]), (|evcram[i][1]));
	 or VCAIl0  (lvcraii[i][0], (~lvcr[i][0]), (|lvcram[i][0]));
	 or VCAIl1  (lvcraii[i][1], (~lvcr[i][1]), (|lvcram[i][1]));
	 or VCAIl2  (lvcraii[i][2], (~lvcr[i][2]), (|lvcram[i][2]));
	 or VCAIl3  (lvcraii[i][3], (~lvcr[i][3]), (|lvcram[i][3]));
	 
`ifdef ENABLE_MRMA
	    assign i2sr[0][i] = mnvcr[i][0];
	    assign i2sr[1][i] = mlvcr[i][0];
	    assign i2wr[0][i] = msvcr[i][0];
	    assign i2wr[1][i] = mnvcr[i][1];
	    assign i2wr[2][i] = mevcr[i][0];
	    assign i2wr[3][i] = mlvcr[i][1];
	    assign i2nr[0][i] = msvcr[i][1];
	    assign i2nr[1][i] = mlvcr[i][2];
	    assign i2er[0][i] = msvcr[i][2];
	    assign i2er[1][i] = mwvcr[i][0];
	    assign i2er[2][i] = mnvcr[i][2];
	    assign i2er[3][i] = mlvcr[i][3];
	    assign i2lr[0][i] = msvcr[i][3];
	    assign i2lr[1][i] = mwvcr[i][1];
	    assign i2lr[2][i] = mnvcr[i][3];
	    assign i2lr[3][i] = mevcr[i][1];
`endif //  `ifndef ENABLE_MRMA

	 for(j=0; j<VCN; j++) begin : CO
`ifndef ENABLE_MRMA
	    assign i2sr[0][i][j] = mnvcr[i][0];
	    assign i2sr[1][i][j] = mlvcr[i][0];
	    assign i2wr[0][i][j] = msvcr[i][0];
	    assign i2wr[1][i][j] = mnvcr[i][1];
	    assign i2wr[2][i][j] = mevcr[i][0];
	    assign i2wr[3][i][j] = mlvcr[i][1];
	    assign i2nr[0][i][j] = msvcr[i][1];
	    assign i2nr[1][i][j] = mlvcr[i][2];
	    assign i2er[0][i][j] = msvcr[i][2];
	    assign i2er[1][i][j] = mwvcr[i][0];
	    assign i2er[2][i][j] = mnvcr[i][2];
	    assign i2er[3][i][j] = mlvcr[i][3];
	    assign i2lr[0][i][j] = msvcr[i][3];
	    assign i2lr[1][i][j] = mwvcr[i][1];
	    assign i2lr[2][i][j] = mnvcr[i][3];
	    assign i2lr[3][i][j] = mevcr[i][1];
`endif //  `ifndef ENABLE_MRMA
	    
	    assign svcram[i][0][j] = wcfga[j][0][i];
	    assign svcram[i][1][j] = ncfga[j][0][i];
	    assign svcram[i][2][j] = ecfga[j][0][i];
	    assign svcram[i][3][j] = lcfga[j][0][i];
	    assign wvcram[i][0][j] = ecfga[j][1][i];
	    assign wvcram[i][1][j] = lcfga[j][1][i];
	    assign nvcram[i][0][j] = scfga[j][0][i];
	    assign nvcram[i][1][j] = wcfga[j][1][i];
	    assign nvcram[i][2][j] = ecfga[j][2][i];
	    assign nvcram[i][3][j] = lcfga[j][2][i];
	    assign evcram[i][0][j] = wcfga[j][2][i];
	    assign evcram[i][1][j] = lcfga[j][3][i];
	    assign lvcram[i][0][j] = scfga[j][1][i];
	    assign lvcram[i][1][j] = wcfga[j][3][i];
	    assign lvcram[i][2][j] = ncfga[j][1][i];
	    assign lvcram[i][3][j] = ecfga[j][3][i];

	    assign svcrami[i][0][j] = mwcfg[j][0][i];
	    assign svcrami[i][1][j] = mncfg[j][0][i];
	    assign svcrami[i][2][j] = mecfg[j][0][i];
	    assign svcrami[i][3][j] = mlcfg[j][0][i];
	    assign wvcrami[i][0][j] = mecfg[j][1][i];
	    assign wvcrami[i][1][j] = mlcfg[j][1][i];
	    assign nvcrami[i][0][j] = mscfg[j][0][i];
	    assign nvcrami[i][1][j] = mwcfg[j][1][i];
	    assign nvcrami[i][2][j] = mecfg[j][2][i];
	    assign nvcrami[i][3][j] = mlcfg[j][2][i];
	    assign evcrami[i][0][j] = mwcfg[j][2][i];
	    assign evcrami[i][1][j] = mlcfg[j][3][i];
	    assign lvcrami[i][0][j] = mscfg[j][1][i];
	    assign lvcrami[i][1][j] = mwcfg[j][3][i];
	    assign lvcrami[i][2][j] = mncfg[j][1][i];
	    assign lvcrami[i][3][j] = mecfg[j][3][i];

	    and CFGENw0 (wcfg[j][0][i], svcr[i][0], mwcfg[j][0][i]);
	    and CFGENn0 (ncfg[j][0][i], svcr[i][1], mncfg[j][0][i]);
	    and CFGENe0 (ecfg[j][0][i], svcr[i][2], mecfg[j][0][i]);
	    and CFGENl0 (lcfg[j][0][i], svcr[i][3], mlcfg[j][0][i]);
	    and CFGENe1 (ecfg[j][1][i], wvcr[i][0], mecfg[j][1][i]);
	    and CFGENl1 (lcfg[j][1][i], wvcr[i][1], mlcfg[j][1][i]);
	    and CFGENs0 (scfg[j][0][i], nvcr[i][0], mscfg[j][0][i]);
	    and CFGENw1 (wcfg[j][1][i], nvcr[i][1], mwcfg[j][1][i]);
	    and CFGENe2 (ecfg[j][2][i], nvcr[i][2], mecfg[j][2][i]);
	    and CFGENl2 (lcfg[j][2][i], nvcr[i][3], mlcfg[j][2][i]);
	    and CFGENw2 (wcfg[j][2][i], evcr[i][0], mwcfg[j][2][i]);
	    and CFGENl3 (lcfg[j][3][i], evcr[i][1], mlcfg[j][3][i]);
	    and CFGENs1 (scfg[j][1][i], lvcr[i][0], mscfg[j][1][i]);
	    and CFGENw3 (wcfg[j][3][i], lvcr[i][1], mwcfg[j][3][i]);
	    and CFGENn1 (ncfg[j][1][i], lvcr[i][2], mncfg[j][1][i]);
	    and CFGENe3 (ecfg[j][3][i], lvcr[i][3], mecfg[j][3][i]);
	 end // block: CO 
      end // block: SF
   endgenerate
   
   // the requests crossbar
   rcb_vc #(.VCN(VCN))
   RSW (
	.ro    ( {losr, eosr, nosr, wosr, sosr} ),
	.srt   ( sswa                           ),
	.wrt   ( wswa                           ),
	.nrt   ( nswa                           ),
	.ert   ( eswa                           ),
	.lrt   ( lswa                           ),
	.ri    ( {lswr, eswr, nswr, wswr, sswr} ),
	.go    ( {losa, eosa, nosa, wosa, sosa} ),
	.wctl  ( wcfg                           ),
	.ectl  ( ecfg                           ),
	.lctl  ( lcfg                           ),
	.sctl  ( scfg                           ),
	.nctl  ( ncfg                           ),
	.wctla ( wcfga                          ),
	.ectla ( ecfga                          ),
	.lctla ( lcfga                          ),
	.sctla ( scfga                          ),
	.nctla ( ncfga                          )
	);

   // the VC allocators
`ifndef ENABLE_MRMA
   mnma #(.N(2*VCN), .M(VCN)) 
   SVA (
	.r     ( i2sr   ),
	.cfg   ( mscfg  ),
	.ra    (        )
	);

   mnma #(.N(4*VCN), .M(VCN)) 
   WVA (
	.r     ( i2wr   ),
	.cfg   ( mwcfg  ),
	.ra    (        )
	);
   
   mnma #(.N(2*VCN), .M(VCN)) 
   NVA (
	.r     ( i2nr   ),
	.cfg   ( mncfg  ),
	.ra    (        )
	);

   mnma #(.N(4*VCN), .M(VCN)) 
   EVA (
	.r     ( i2er   ),
	.cfg   ( mecfg  ),
	.ra    (        )
	);

   mnma #(.N(4*VCN), .M(VCN)) 
   LVA (
	.r     ( i2lr   ),
	.cfg   ( mlcfg  ),
	.ra    (        )
	);
`else // !`ifndef ENABLE_MRMA
   mrma #(.N(2*VCN), .M(VCN)) 
   SVA (
	.c     ( i2sr    ),
	.cfg   ( mscfg   ),
	.ca    (         ),
	.r     ( svcrdy  ),
	.ra    ( svcrdya ),
	.rst_n ( rst_n   )
	);

   mrma #(.N(4*VCN), .M(VCN)) 
   WVA (
	.c     ( i2wr    ),
	.cfg   ( mwcfg   ),
	.ca    (         ),
	.r     ( wvcrdy  ),
	.ra    ( wvcrdya ),
	.rst_n ( rst_n   )
	);
   
   mrma #(.N(2*VCN), .M(VCN)) 
   NVA (
	.c     ( i2nr    ),
	.cfg   ( mncfg   ),
	.ca    (         ),
	.r     ( nvcrdy  ),
	.ra    ( nvcrdya ),
	.rst_n ( rst_n   )
	);

   mrma #(.N(4*VCN), .M(VCN)) 
   EVA (
	.c     ( i2er    ),
	.cfg   ( mecfg   ),
	.ca    (         ),
	.r     ( evcrdy  ),
	.ra    ( evcrdya ),
	.rst_n ( rst_n   )
	);

   mrma #(.N(4*VCN), .M(VCN)) 
   LVA (
	.c     ( i2lr    ),
	.cfg   ( mlcfg   ),
	.ca    (         ),
	.r     ( lvcrdy  ),
	.ra    ( lvcrdya ),
	.rst_n ( rst_n   )
	);

   generate
      for(i=0; i<VCN; i++) begin: OPC
	 delay DLY ( .q(vcrst_n[i+1]), .a(vcrst_n[i])); // dont touch
	 assign svcrdy[i] = (~svcrdya[i])&vcrst_n[i+1];
	 assign wvcrdy[i] = (~wvcrdya[i])&vcrst_n[i+1];
	 assign nvcrdy[i] = (~nvcrdya[i])&vcrst_n[i+1];
	 assign evcrdy[i] = (~evcrdya[i])&vcrst_n[i+1];
	 assign lvcrdy[i] = (~lvcrdya[i])&vcrst_n[i+1];
      end
   endgenerate

   assign vcrst_n[0] = rst_n;

`endif // !`ifndef ENABLE_MRMA
      
endmodule // vcalloc

/*   logic of the control logic generated from petrify

// Verilog model for vca_ctl
// Generated by petrify 4.2 (compiled 15-Oct-03 at 3:06 PM)
// CPU time for synthesis (host <unknown>): 0.04 seconds
// Estimated area = 72.00

// The circuit is self-resetting and does not need reset pin.

module vca_ctl_net (
    vcri,
    cfg,
    vcrai,
    vcro,
    cfgen,
    vcrao
);

input vcri;
input cfg;
input vcrai;

output vcro;
output cfgen;
output vcrao;


// Functions not mapped into library gates:
// ----------------------------------------

// Equation: vcro = vcri + vcrai
or _U0 (vcro, vcrai, vcri);

// Equation: cfgen = vcri
buf _U1 (cfgen, vcri);

// Equation: vcrao = cfg (vcri' + vcrai)
not _U1 (_X1, vcri);
and _U2 (_X0, vcrai, cfg);
and _U3 (_X2, cfg, _X1);
or _U4 (vcrao, _X0, _X2);


// signal values at the initial state:
//     !vcri !cfg !vcrai !vcro !cfgen !vcrao
endmodule
*/