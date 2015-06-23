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
 30/05/2011  Clean up for opensource. <wsong83@gmail.com>
 
*/

// the router structure definitions
`include "define.v"

module node_top(/*AUTOARG*/
   // Outputs
   so0, so1, so2, so3, wo0, wo1, wo2, wo3, no0, no1, no2, no3, eo0,
   eo1, eo2, eo3, sia, wia, nia, eia, so4, wo4, no4, eo4,
   // Inputs
   si0, si1, si2, si3, wi0, wi1, wi2, wi3, ni0, ni1, ni2, ni3, ei0,
   ei1, ei2, ei3, si4, wi4, ni4, ei4, soa, woa, noa, eoa, rst_n
   );
   parameter DW = 32;
   parameter VCN = 1;
   parameter x = 0;
   parameter y = 0;
   parameter SCN = DW/2;

   input [VCN*SCN-1:0]   si0, si1, si2, si3;
   input [VCN*SCN-1:0]   wi0, wi1, wi2, wi3;
   input [VCN*SCN-1:0]   ni0, ni1, ni2, ni3;
   input [VCN*SCN-1:0]   ei0, ei1, ei2, ei3;
   output [VCN*SCN-1:0]  so0, so1, so2, so3;
   output [VCN*SCN-1:0]  wo0, wo1, wo2, wo3;
   output [VCN*SCN-1:0]  no0, no1, no2, no3;
   output [VCN*SCN-1:0]  eo0, eo1, eo2, eo3;
   wire [VCN*SCN-1:0] 	 li0, li1, li2, li3;
   wire [VCN*SCN-1:0] 	 lo0, lo1, lo2, lo3;
`ifdef ENABLE_CHANNEL_SLICING
   input [VCN*SCN-1:0] 	 si4, wi4, ni4, ei4;
   output [VCN*SCN-1:0]  sia, wia, nia, eia;
   output [VCN*SCN-1:0]  so4, wo4, no4, eo4;
   input [VCN*SCN-1:0] 	 soa, woa, noa, eoa;
   wire [VCN*SCN-1:0] 	 li4, lia, lo4, loa;
`else
   input [VCN-1:0] 	 si4, wi4, ni4, ei4;
   output [VCN-1:0] 	 sia, wia, nia, eia;
   output [VCN-1:0] 	 so4, wo4, no4, eo4;
   input [VCN-1:0] 	 soa, woa, noa, eoa;
   wire [VCN-1:0] 	 li4, lia, lo4, loa;
`endif // !`ifdef ENABLE_CHANNEL_SLICING

   input 		 rst_n;

   
   // the network node
   NetNode #(.DW(DW), .VCN(VCN), .x(x), .y(y))
   Node (
	 .dia   ( lia   ),
	 .do4   ( lo4   ),
	 .doa   ( loa   ),
	 .di4   ( li4   ),
	 .do0   ( lo0   ),
	 .do1   ( lo1   ),
	 .do2   ( lo2   ),
	 .do3   ( lo3   ),
	 .di0   ( li0   ),
	 .di1   ( li1   ),
	 .di2   ( li2   ),
	 .di3   ( li3   ),
	 .rst_n ( rst_n )
	 );
   
   
   // router wrapper
   router_hdl #(.DW(DW), .VCN(VCN))
   RTN (
	.so0(so0), .so1(so1), .so2(so2), .so3(so3), .so4(so4), .soa(soa),
	.wo0(wo0), .wo1(wo1), .wo2(wo2), .wo3(wo3), .wo4(wo4), .woa(woa),
	.no0(no0), .no1(no1), .no2(no2), .no3(no3), .no4(no4), .noa(noa),
	.eo0(eo0), .eo1(eo1), .eo2(eo2), .eo3(eo3), .eo4(eo4), .eoa(eoa),
	.lo0(lo0), .lo1(lo1), .lo2(lo2), .lo3(lo3), .lo4(lo4), .loa(loa),
	.si0(si0), .si1(si1), .si2(si2), .si3(si3), .si4(si4), .sia(sia),
	.wi0(wi0), .wi1(wi1), .wi2(wi2), .wi3(wi3), .wi4(wi4), .wia(wia),
	.ni0(ni0), .ni1(ni1), .ni2(ni2), .ni3(ni3), .ni4(ni4), .nia(nia),
	.ei0(ei0), .ei1(ei1), .ei2(ei2), .ei3(ei3), .ei4(ei4), .eia(eia),
	.li0(li0), .li1(li1), .li2(li2), .li3(li3), .li4(li4), .lia(lia),
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
