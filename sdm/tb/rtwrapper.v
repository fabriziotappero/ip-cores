/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The wrapper for the synthesized router.
 
 History:
 28/05/2009  Initial version. <wsong83@gmail.com>
 30/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

// the router structure definitions
`include "define.v"

module router_hdl(/*AUTOARG*/
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
   parameter SCN = DW/2;	// the number of 1-of-4 sub-channel in each virtual circuit
   
   input [VCN*SCN-1:0]      si0, si1, si2, si3;
   input [VCN*SCN-1:0] 	    wi0, wi1, wi2, wi3;
   input [VCN*SCN-1:0] 	    ni0, ni1, ni2, ni3;
   input [VCN*SCN-1:0] 	    ei0, ei1, ei2, ei3;
   input [VCN*SCN-1:0] 	    li0, li1, li2, li3;
   output [VCN*SCN-1:0]     so0, so1, so2, so3;
   output [VCN*SCN-1:0]     wo0, wo1, wo2, wo3;
   output [VCN*SCN-1:0]     no0, no1, no2, no3;
   output [VCN*SCN-1:0]     eo0, eo1, eo2, eo3;
   output [VCN*SCN-1:0]     lo0, lo1, lo2, lo3;
   // eof bits and ack lines
`ifdef ENABLE_CHANNEL_SLICING
   input [VCN*SCN-1:0] 	    si4, wi4, ni4, ei4, li4;
   output [VCN*SCN-1:0]     so4, wo4, no4, eo4, lo4;
   output [VCN*SCN-1:0]     sia, wia, nia, eia, lia;
   input [VCN*SCN-1:0] 	    soa, woa, noa, eoa, loa;
`else
   input [VCN-1:0] 	     si4, wi4, ni4, ei4, li4;
   output [VCN-1:0] 	     so4, wo4, no4, eo4, lo4;
   output [VCN-1:0] 	     sia, wia, nia, eia, lia;
   input [VCN-1:0] 	     soa, woa, noa, eoa, loa;
`endif // !`ifdef ENABLE_CHANNEL_SLICING
   
   input [7:0] 		    addrx, addry;
   input 		    rst_n;
   
   wire [VCN*SCN-1:0] 	    psi0, psi1, psi2, psi3;
   wire [VCN*SCN-1:0] 	    pwi0, pwi1, pwi2, pwi3;
   wire [VCN*SCN-1:0] 	    pni0, pni1, pni2, pni3;
   wire [VCN*SCN-1:0] 	    pei0, pei1, pei2, pei3;
   wire [VCN*SCN-1:0] 	    pli0, pli1, pli2, pli3;
   wire [VCN*SCN-1:0] 	    pso0, pso1, pso2, pso3;
   wire [VCN*SCN-1:0] 	    pwo0, pwo1, pwo2, pwo3;
   wire [VCN*SCN-1:0] 	    pno0, pno1, pno2, pno3;
   wire [VCN*SCN-1:0] 	    peo0, peo1, peo2, peo3;
   wire [VCN*SCN-1:0] 	    plo0, plo1, plo2, plo3;
   // eof bits and ack lines
`ifdef ENABLE_CHANNEL_SLICING
   wire [VCN*SCN-1:0] 	    psi4, pwi4, pni4, pei4, pli4;
   wire [VCN*SCN-1:0] 	    pso4, pwo4, pno4, peo4, plo4;
   wire [VCN*SCN-1:0] 	    psia, pwia, pnia, peia, plia;
   wire [VCN*SCN-1:0] 	    psoa, pwoa, pnoa, peoa, ploa;
`else
   wire [VCN-1:0] 	    psi4, pwi4, pni4, pei4, pli4;
   wire [VCN-1:0] 	    pso4, pwo4, pno4, peo4, plo4;
   wire [VCN-1:0] 	    psia, pwia, pnia, peia, plia;
   wire [VCN-1:0] 	    psoa, pwoa, pnoa, peoa, ploa;
`endif // !`ifdef ENABLE_CHANNEL_SLICING
    
   wire [7:0] 		    paddrx, paddry;
   wire 		    prst_n;
   
   router RT ( 
	       .sia      ( psia    ),
	       .wia      ( pwia    ),
	       .nia      ( pnia    ),
	       .eia      ( peia    ),
	       .lia      ( plia    ),
	       .so0      ( pso0    ),
	       .so1      ( pso1    ),
	       .so2      ( pso2    ),
	       .so3      ( pso3    ),
	       .wo0      ( pwo0    ),
	       .wo1      ( pwo1    ),
	       .wo2      ( pwo2    ),
	       .wo3      ( pwo3    ),
	       .no0      ( pno0    ),
	       .no1      ( pno1    ),
	       .no2      ( pno2    ),
	       .no3      ( pno3    ),
	       .eo0      ( peo0    ),
	       .eo1      ( peo1    ),
	       .eo2      ( peo2    ),
	       .eo3      ( peo3    ),
	       .lo0      ( plo0    ),
	       .lo1      ( plo1    ),
	       .lo2      ( plo2    ),
	       .lo3      ( plo3    ),
	       .so4      ( pso4    ),
	       .wo4      ( pwo4    ),
	       .no4      ( pno4    ),
	       .eo4      ( peo4    ),
	       .lo4      ( plo4    ),
	       .si0      ( psi0    ),
	       .si1      ( psi1    ),
	       .si2      ( psi2    ),
	       .si3      ( psi3    ),
	       .wi0      ( pwi0    ),
	       .wi1      ( pwi1    ),
	       .wi2      ( pwi2    ),
	       .wi3      ( pwi3    ),
	       .ni0      ( pni0    ),
	       .ni1      ( pni1    ),
	       .ni2      ( pni2    ),
	       .ni3      ( pni3    ),
	       .ei0      ( pei0    ),
	       .ei1      ( pei1    ),
	       .ei2      ( pei2    ),
	       .ei3      ( pei3    ),
	       .li0      ( pli0    ),
	       .li1      ( pli1    ),
	       .li2      ( pli2    ),
	       .li3      ( pli3    ),
	       .si4      ( psi4    ),
	       .wi4      ( pwi4    ),
	       .ni4      ( pni4    ),
	       .ei4      ( pei4    ),
	       .li4      ( pli4    ),
	       .soa      ( psoa    ),
	       .woa      ( pwoa    ),
	       .noa      ( pnoa    ),
	       .eoa      ( peoa    ),
	       .loa      ( ploa    ),
	       .addrx    ( paddrx  ),
	       .addry    ( paddry  ),
	       .rst_n    ( prst_n  )
	       );
   
   assign sia      = psia   ;
   assign wia      = pwia   ;
   assign nia      = pnia   ;
   assign eia      = peia   ;
   assign lia      = plia   ;
   assign so0      = pso0   ;
   assign so1      = pso1   ;
   assign so2      = pso2   ;
   assign so3      = pso3   ;
   assign wo0      = pwo0   ;
   assign wo1      = pwo1   ;
   assign wo2      = pwo2   ;
   assign wo3      = pwo3   ;
   assign no0      = pno0   ;
   assign no1      = pno1   ;
   assign no2      = pno2   ;
   assign no3      = pno3   ;
   assign eo0      = peo0   ;
   assign eo1      = peo1   ;
   assign eo2      = peo2   ;
   assign eo3      = peo3   ;
   assign lo0      = plo0   ;
   assign lo1      = plo1   ;
   assign lo2      = plo2   ;
   assign lo3      = plo3   ;
   assign so4      = pso4   ;
   assign wo4      = pwo4   ;
   assign no4      = pno4   ;
   assign eo4      = peo4   ;
   assign lo4      = plo4   ;
   assign psi0     = si0    ;
   assign psi1     = si1    ;
   assign psi2     = si2    ;
   assign psi3     = si3    ;
   assign pwi0     = wi0    ;
   assign pwi1     = wi1    ;
   assign pwi2     = wi2    ;
   assign pwi3     = wi3    ;
   assign pni0     = ni0    ;
   assign pni1     = ni1    ;
   assign pni2     = ni2    ;
   assign pni3     = ni3    ;
   assign pei0     = ei0    ;
   assign pei1     = ei1    ;
   assign pei2     = ei2    ;
   assign pei3     = ei3    ;
   assign pli0     = li0    ;
   assign pli1     = li1    ;
   assign pli2     = li2    ;
   assign pli3     = li3    ;
   assign psi4     = si4    ;
   assign pwi4     = wi4    ;
   assign pni4     = ni4    ;
   assign pei4     = ei4    ;
   assign pli4     = li4    ;
   assign psoa     = soa    ;
   assign pwoa     = woa    ;
   assign pnoa     = noa    ;
   assign peoa     = eoa    ;
   assign ploa     = loa    ;
   assign paddrx   = addrx  ;
   assign paddry   = addry  ;
   assign prst_n   = rst_n  ;

   initial $sdf_annotate("../syn/file/router.sdf", RT);
   
endmodule
