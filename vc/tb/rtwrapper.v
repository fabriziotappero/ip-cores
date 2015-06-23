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
 05/06/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

// the router structure definitions
`include "define.v"

module router_hdl(/*AUTOARG*/
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

   parameter VCN = 1;		// number of virtual circuits in each direction. When VCN == 1, it is a wormhole router
   parameter DW = 32;		// the datawidth of a single virtual circuit, the total data width of the router is DW*VCN
   parameter FT = 3;// the number of types of flits
   parameter SCN = DW/2;	// the number of 1-of-4 sub-channel in each virtual circuit
   
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

   input [7:0] 	      addrx, addry;
   input 	      rst_n;
   
   wire [SCN-1:0]     psi0, psi1, psi2, psi3;
   wire [SCN-1:0]     pwi0, pwi1, pwi2, pwi3;
   wire [SCN-1:0]     pni0, pni1, pni2, pni3;
   wire [SCN-1:0]     pei0, pei1, pei2, pei3;
   wire [SCN-1:0]     pli0, pli1, pli2, pli3;
   wire [FT-1:0]      psift, pwift, pnift, peift, plift;
   wire [VCN-1:0]     psivc, pwivc, pnivc, peivc, plivc;
   wire 	      psia, pwia, pnia, peia, plia;
   wire [VCN-1:0]     psic, pwic, pnic, peic, plic;
   wire [VCN-1:0]     psica, pwica, pnica, peica, plica;
   
   wire [SCN-1:0]     pso0, pso1, pso2, pso3;
   wire [SCN-1:0]     pwo0, pwo1, pwo2, pwo3;
   wire [SCN-1:0]     pno0, pno1, pno2, pno3;
   wire [SCN-1:0]     peo0, peo1, peo2, peo3;
   wire [SCN-1:0]     plo0, plo1, plo2, plo3;
   wire [FT-1:0]      psoft, pwoft, pnoft, peoft, ploft;
   wire [VCN-1:0]     psovc, pwovc, pnovc, peovc, plovc;
   wire 	      psoa, pwoa, pnoa, peoa, ploa;
   wire [VCN-1:0]     psoc, pwoc, pnoc, peoc, ploc;
   wire [VCN-1:0]     psoca, pwoca, pnoca, peoca, ploca;
   
   wire [7:0] 	      paddrx, paddry;
   wire 	      prst_n;

   router RT ( 
				 .sia      ( psia    ),
				 .wia      ( pwia    ),
				 .nia      ( pnia    ),
				 .eia      ( peia    ),
				 .lia      ( plia    ),
				 .sic      ( psic    ),
				 .wic      ( pwic    ),
				 .nic      ( pnic    ),
				 .eic      ( peic    ),
				 .lic      ( plic    ),
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
				 .soft     ( psoft   ),
				 .woft     ( pwoft   ),
				 .noft     ( pnoft   ),
				 .eoft     ( peoft   ),
				 .loft     ( ploft   ),
				 .sovc     ( psovc   ),
				 .wovc     ( pwovc   ),
				 .novc     ( pnovc   ),
				 .eovc     ( peovc   ),
				 .lovc     ( plovc   ),
				 .soca     ( psoca   ),
				 .woca     ( pwoca   ),
				 .noca     ( pnoca   ),
				 .eoca     ( peoca   ),
				 .loca     ( ploca   ),
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
				 .sift     ( psift   ),
				 .wift     ( pwift   ),
				 .nift     ( pnift   ),
				 .eift     ( peift   ),
				 .lift     ( plift   ),
				 .sivc     ( psivc   ),
				 .wivc     ( pwivc   ),
				 .nivc     ( pnivc   ),
				 .eivc     ( peivc   ),
				 .livc     ( plivc   ),
				 .sica     ( psica   ),
				 .wica     ( pwica   ),
				 .nica     ( pnica   ),
				 .eica     ( peica   ),
				 .lica     ( plica   ),
				 .soa      ( psoa    ),
				 .woa      ( pwoa    ),
				 .noa      ( pnoa    ),
				 .eoa      ( peoa    ),
				 .loa      ( ploa    ),
				 .soc      ( psoc    ),
				 .woc      ( pwoc    ),
				 .noc      ( pnoc    ),
				 .eoc      ( peoc    ),
				 .loc      ( ploc    ),
				 .addrx    ( paddrx  ),
				 .addry    ( paddry  ),
				 .rst_n    ( prst_n  )
				 );
   
   assign sia      = psia   ;
   assign wia      = pwia   ;
   assign nia      = pnia   ;
   assign eia      = peia   ;
   assign lia      = plia   ;
   assign sic      = psic   ;
   assign wic      = pwic   ;
   assign nic      = pnic   ;
   assign eic      = peic   ;
   assign lic      = plic   ;
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
   assign soft     = psoft  ;
   assign woft     = pwoft  ;
   assign noft     = pnoft  ;
   assign eoft     = peoft  ;
   assign loft     = ploft  ;
   assign sovc     = psovc  ;
   assign wovc     = pwovc  ;
   assign novc     = pnovc  ;
   assign eovc     = peovc  ;
   assign lovc     = plovc  ;
   assign soca     = psoca  ;
   assign woca     = pwoca  ;
   assign noca     = pnoca  ;
   assign eoca     = peoca  ;
   assign loca     = ploca  ;
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
   assign psift    = sift   ;
   assign pwift    = wift   ;
   assign pnift    = nift   ;
   assign peift    = eift   ;
   assign plift    = lift   ;
   assign psivc    = sivc   ;
   assign pwivc    = wivc   ;
   assign pnivc    = nivc   ;
   assign peivc    = eivc   ;
   assign plivc    = livc   ;
   assign psica    = sica   ;
   assign pwica    = wica   ;
   assign pnica    = nica   ;
   assign peica    = eica   ;
   assign plica    = lica   ;
   assign psoa     = soa    ;
   assign pwoa     = woa    ;
   assign pnoa     = noa    ;
   assign peoa     = eoa    ;
   assign ploa     = loa    ;
   assign psoc     = soc    ;
   assign pwoc     = woc    ;
   assign pnoc     = noc    ;
   assign peoc     = eoc    ;
   assign ploc     = loc    ;
   assign paddrx   = addrx  ;
   assign paddry   = addry  ;
   assign prst_n   = rst_n  ;

   initial $sdf_annotate("../syn/file/router.sdf", RT);
   
endmodule
