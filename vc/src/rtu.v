/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 The routing calculation unit in every input buffer.
 p0 -> L -> p1 -> RTC -> p2 -> L -> p3 -> DEMUX -> p[0] -> L -> p[1] -> L -> p[2] -> L -> p[3] -> L -> p[4]  
 
 History:
 02/04/2010  Initial version. <wsong83@gmail.com>
 02/06/2011  Clean up for opensource. <wsong83@gmail.com>
 09/06/2011  The selection pin of the demux must be considered in the ack process. <wsong83@gmail.com>
 
*/

module rtu (/*AUTOARG*/
   // Outputs
   dia, dort,
   // Inputs
   rst_n, di0, di1, di2, di3, dit, divc, addrx, addry, doa
   );
   parameter VCN = 2;
   parameter DIR = 0;
   parameter SN = 4;
   parameter PD = 2;

   input            rst_n;
   input [3:0]      di0, di1, di2, di3;
   input [2:0] 	    dit;
   input [VCN-1:0]  divc;
   output 	    dia;

   input [7:0] 	    addrx, addry;

   output [VCN-1:0][SN-1:0] dort;
   input [VCN-1:0] 	    doa;

   //------------------------------------------
   wire 	    p0an, p0ap, p0den, p0ad, p0avc;
   wire [3:0] 	    p1d0, p1d1, p1d2, p1d3;
   wire [VCN-1:0]   p1vc;
   wire 	    p1a, p1ad, p1avc, p1an;
   wire [SN-1:0]    p2d;
   wire [VCN-1:0]   p2vc;
   wire 	    p2a, p2ad, p2avc, p2an;
   wire [SN-1:0]    p3d;
   wire [VCN-1:0]   p3vc;
   wire 	    p3a, p3an;
   wire [PD*2:0][VCN-1:0][SN-1:0] pd;
   wire [PD*2:0][VCN-1:0] 	  pda, pdan;

   wire [2:0] 			  x_cmp [1:0];
   wire [2:0] 			  y_cmp [1:0];
   wire [5:0] 			  dec;
   wire 			  ds, dw, dn, de, dl;
   

   genvar 			  gvc, gbd, i;

   //------------------------------------------
   // p0 -> L -> p1

   c2 CP0DE ( .a0(dit[0]), .a1(p1an), .q(p0den));
   c2 CP0A  ( .a0(p0ad), .a1(p0avc), .q(p0ap));
   assign p0an = |dit[2:1];
   assign dia = p0an | p0ap;
   
   pipe4 #(.DW(8))
   L0D (
	.ia ( p0ad   ), 
	.o0 ( p1d0   ), 
	.o1 ( p1d1   ),
	.o2 ( p1d2   ), 
	.o3 ( p1d3   ), 
	.i0 ( di0    ),
	.i1 ( di1    ), 
	.i2 ( di2    ),
	.i3 ( di3    ),
	.oa ( p0den  )
	);

   pipen #(.DW(VCN))
   L0V (
	.d_in    ( divc    ),
	.d_in_a  ( p0avc   ),
	.d_out   ( p1vc    ),
	.d_out_a ( p0den   )
	);

   // p1 -> RTC -> p2
   comp4 X0 ( .a({p1d3[0], p1d2[0], p1d1[0], p1d0[0]}), .b(addrx[3:0]), .q(x_cmp[0]));
   comp4 X1 ( .a({p1d3[1], p1d2[1], p1d1[1], p1d0[1]}), .b(addrx[7:4]), .q(x_cmp[1]));
   comp4 Y0 ( .a({p1d3[2], p1d2[2], p1d1[2], p1d0[2]}), .b(addry[3:0]), .q(y_cmp[0]));
   comp4 Y1 ( .a({p1d3[3], p1d2[3], p1d1[3], p1d0[3]}), .b(addry[7:4]), .q(y_cmp[1]));

   assign dec[0] = x_cmp[1][0] | (x_cmp[1][2]&x_cmp[0][0]);       // frame x > addr x
   assign dec[1] = x_cmp[1][1] | (x_cmp[1][2]&x_cmp[0][1]);       // frame x < addr x
   assign dec[2] = x_cmp[1][2] & x_cmp[0][2];                     // frame x = addr x
   assign dec[3] = y_cmp[1][0] | (y_cmp[1][2]&y_cmp[0][0]);       // frame y > addr y
   assign dec[4] = y_cmp[1][1] | (y_cmp[1][2]&y_cmp[0][1]);       // frame y < addr y
   assign dec[5] = y_cmp[1][2] & y_cmp[0][2];                     // frame y = addr y

   assign ds = dec[0];
   assign dw = dec[2]&dec[4];
   assign dn = dec[1];
   assign de = dec[2]&dec[3];
   assign dl = dec[2]&dec[5];
   
   assign p2d =  
		   DIR == 0 ?   {dl, de, dn, dw}  :       // south port
                   DIR == 1 ?   {dl, de}          :       // west port
                   DIR == 2 ?   {dl, de, dw, ds}  :       // north port
                   DIR == 3 ?   {dl, dw}          :       // east port
                                {de, dn, dw, ds}  ;       // local port

   assign p2vc = p1vc;
   assign p1an = p2an;

   // p2 -> L -> p3

   c2 CP2A  ( .a0(p2ad), .a1(p2avc), .q(p2a));
   assign p2an = (~p2a) & rst_n;

   pipen #(.DW(SN))
   L2R (
	.d_in    ( p2d     ),
	.d_in_a  ( p2ad    ),
	.d_out   ( p3d     ),
	.d_out_a ( p3an    )
	);
          
   pipen #(.DW(VCN))
   L2V (
	.d_in    ( p2vc    ),
	.d_in_a  ( p2avc   ),
	.d_out   ( p3vc    ),
	.d_out_a ( p3an    )
	);

   // p3 -> DEMUX -> pd[0]
   ddmux #(.DW(SN), .VCN(VCN))
   RTDM (
	 .d_in_a  ( p3a   ), 
	 .d_out   ( pd[0] ),
	 .d_in    ( p3d   ), 
	 .d_sel   ( p3vc  ), 
	 .d_out_a ( pda[0])
	 );

   //c2 CP3A (.q(p3a), .a0(p3ad), .a1(|p3vc));
   assign p3an = (~p3a) & rst_n;

   // pd pipeline
   generate
      for(gbd=0; gbd<PD*2; gbd++) begin:RT
	 for(gvc=0; gvc<VCN; gvc++) begin:V
	    pipen #(.DW(SN))
	    P (
	       .d_in    ( pd[gbd][gvc]     ),
	       .d_in_a  ( pda[gbd][gvc]    ),
	       .d_out   ( pd[gbd+1][gvc]   ),
	       .d_out_a ( pdan[gbd+1][gvc] )
	       );
	    assign pdan[gbd+1][gvc] = (~pda[gbd+1][gvc])&rst_n;
	 end
      end // block: RT
   endgenerate

   // output
   generate
      for(gvc=0; gvc<VCN; gvc++) begin:OV
	 assign dort[gvc] = pd[PD*2][gvc];
	 assign pda[PD*2][gvc] = doa[gvc];
      end
   endgenerate

endmodule // rtu

   

   
