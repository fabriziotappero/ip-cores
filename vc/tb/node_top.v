/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 A network node including a router, a NI and a processing element. 
 
 History:
 03/03/2011  Initial version. <wsong83@gmail.com>
 04/03/2011  Support VC. <wsong83@gmail.com>
 05/06/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

// the router structure definitions
`include "define.v"

module node_top(/*AUTOARG*/
   // Outputs
   sia, wia, nia, eia, sic, wic, nic, eic, so0, so1, so2, so3, wo0,
   wo1, wo2, wo3, no0, no1, no2, no3, eo0, eo1, eo2, eo3, soft, woft,
   noft, eoft, sovc, wovc, novc, eovc, soca, woca, noca, eoca,
   // Inputs
   si0, si1, si2, si3, wi0, wi1, wi2, wi3, ni0, ni1, ni2, ni3, ei0,
   ei1, ei2, ei3, sift, wift, nift, eift, sivc, wivc, nivc, eivc,
   sica, wica, nica, eica, soa, woa, noa, eoa, soc, woc, noc, eoc,
   rst_n
   );
   parameter DW = 32;
   parameter VCN = 1;
   parameter FT = 3;
   parameter x = 0;
   parameter y = 0;
   parameter SCN = DW/2;

   input [SCN-1:0]    si0, si1, si2, si3;
   input [SCN-1:0]    wi0, wi1, wi2, wi3;
   input [SCN-1:0]    ni0, ni1, ni2, ni3;
   input [SCN-1:0]    ei0, ei1, ei2, ei3;
   input [FT-1:0]     sift, wift, nift, eift;
   input [VCN-1:0]    sivc, wivc, nivc, eivc;
   output 	      sia, wia, nia, eia;
   output [VCN-1:0]   sic, wic, nic, eic;
   input [VCN-1:0]    sica, wica, nica, eica;

   output [SCN-1:0]   so0, so1, so2, so3;
   output [SCN-1:0]   wo0, wo1, wo2, wo3;
   output [SCN-1:0]   no0, no1, no2, no3;
   output [SCN-1:0]   eo0, eo1, eo2, eo3;
   output [FT-1:0]    soft, woft, noft, eoft;
   output [VCN-1:0]   sovc, wovc, novc, eovc;
   input 	      soa, woa, noa, eoa;
   input [VCN-1:0]    soc, woc, noc, eoc;
   output [VCN-1:0]   soca, woca, noca, eoca;

   wire [SCN-1:0]     li0, li1, li2, li3;
   wire [SCN-1:0]     lo0, lo1, lo2, lo3;
   wire [FT-1:0]      lift;
   wire [VCN-1:0]     livc;
   wire 	      lia;
   wire [VCN-1:0]     lic;
   wire [VCN-1:0]     lica;
   wire [FT-1:0]      loft;
   wire [VCN-1:0]     lovc;
   wire 	      loa;
   wire [VCN-1:0]     loc;
   wire [VCN-1:0]     loca;

   input 		 rst_n;

   
   // the network node
   NetNode #(.DW(DW), .VCN(VCN), .FT(FT), .x(x), .y(y))
   Node (
	 .doa(loa), .doc(loc), 
	 .do0(lo0), .do1(lo1), .do2(lo2), .do3(lo3), 
	 .doft(loft), .dovc(lovc), .doca(loca),
	 .dia(lia), .dic(lic), 
	 .di0(li0), .di1(li1), .di2(li2), .di3(li3), 
	 .dift(lift), .divc(livc), .dica(lica),
	 .rst_n(rst_n)
	 );
   
   
   // router wrapper
   router_hdl #(.DW(DW), .VCN(VCN))
   RTN (
	.so0(so0), .so1(so1), .so2(so2), .so3(so3), .soa(soa), .soft(soft), .sovc(sovc), .soc(soc), .soca(soca),
	.wo0(wo0), .wo1(wo1), .wo2(wo2), .wo3(wo3), .woa(woa), .woft(woft), .wovc(wovc), .woc(woc), .woca(woca),
	.no0(no0), .no1(no1), .no2(no2), .no3(no3), .noa(noa), .noft(noft), .novc(novc), .noc(noc), .noca(noca),
	.eo0(eo0), .eo1(eo1), .eo2(eo2), .eo3(eo3), .eoa(eoa), .eoft(eoft), .eovc(eovc), .eoc(eoc), .eoca(eoca),
	.lo0(lo0), .lo1(lo1), .lo2(lo2), .lo3(lo3), .loa(loa), .loft(loft), .lovc(lovc), .loc(loc), .loca(loca),
	.si0(si0), .si1(si1), .si2(si2), .si3(si3), .sia(sia), .sift(sift), .sivc(sivc), .sic(sic), .sica(sica),
	.wi0(wi0), .wi1(wi1), .wi2(wi2), .wi3(wi3), .wia(wia), .wift(wift), .wivc(wivc), .wic(wic), .wica(wica),
	.ni0(ni0), .ni1(ni1), .ni2(ni2), .ni3(ni3), .nia(nia), .nift(nift), .nivc(nivc), .nic(nic), .nica(nica),
	.ei0(ei0), .ei1(ei1), .ei2(ei2), .ei3(ei3), .eia(eia), .eift(eift), .eivc(eivc), .eic(eic), .eica(eica),
	.li0(li0), .li1(li1), .li2(li2), .li3(li3), .lia(lia), .lift(lift), .livc(livc), .lic(lic), .lica(lica),
	.addrx (b2chain(x)), 
	.addry (b2chain(y)), 
	.rst_n (rst_n)
   );
   

   // binary to 1-of-4 (Chain) converter
   function [7:0] b2chain;
      input [3:0] 	 data;
      begin
         b2chain[0] = (data[1:0] == 2'b00);
         b2chain[1] = (data[1:0] == 2'b01);
         b2chain[2] = (data[1:0] == 2'b10);
         b2chain[3] = (data[1:0] == 2'b11);
         b2chain[4] = (data[3:2] == 2'b00);
         b2chain[5] = (data[3:2] == 2'b01);
         b2chain[6] = (data[3:2] == 2'b10);
         b2chain[7] = (data[3:2] == 2'b11);
      end
   endfunction

endmodule // node_top
