/*
 Asynchronous SDM NoC
 (C)2011 Wei Song
 Advanced Processor Technologies Group
 Computer Science, the Univ. of Manchester, UK
 
 Authors: 
 Wei Song     wsong83@gmail.com
 
 License: LGPL 3.0 or later
 
 Input buffer for Wormhole/SDM routers.
 *** SystemVerilog is used ***
 
 References
 * Lookahead pipelines 
     Montek Singh and Steven M. Nowick, The design of high-performance dynamic asynchronous pipelines: lookahead style, IEEE Transactions on Very Large Scale Integration (VLSI) Systems, 2007(15), 1256-1269. doi:10.1109/TVLSI.2007.902205
 * Channel slicing
     Wei Song and Doug Edwards, A low latency wormhole router for asynchronous on-chip networks, Asia and South Pacific Design Automation Conference, 2010, 437-443.
 * SDM
     Wei Song and Doug Edwards, Asynchronous spatial division multiplexing router, Microprocessors and Microsystems, 2011(35), 85-97.
 
 History:
 05/05/2009  Initial version. <wsong83@gmail.com>
 20/09/2010  Supporting channel slicing and SDM using macro difinitions. <wsong83@gmail.com>
 24/05/2011  Clean up for opensource. <wsong83@gmail.com>
 01/06/2011  Use the comp4 common comparator rather than the chain_comparator defined in this module. <wsong83@gmail.com>
  
*/

// the router structure definitions
`include "define.v"

module inp_buf (/*AUTOARG*/
   // Outputs
   o0, o1, o2, o3, o4, ia, arb_r,
   // Inputs
   rst_n, i0, i1, i2, i3, i4, oa, addrx, addry, arb_ra
   );

   //-------------------------- parameters ---------------------------------------//
   parameter DIR = 0;              // the port direction: south, west, north, east, and local
   parameter RN = 4;               // the number of request outputs, must match the direction
   parameter DW = 16;              // the data-width of the data-path
   parameter PD = 2;		   // the depth of the input buffer
   parameter SCN = DW/2;

   //-------------------------- I/O ports ---------------------------------------//
   input                  rst_n;          // global reset, active low
   input [SCN-1:0] 	  i0, i1, i2, i3; // data input
   output [SCN-1:0] 	  o0, o1, o2, o3; // data output
`ifdef ENABLE_CHANNEL_SLICING
   input [SCN-1:0] 	  i4, oa;
   output [SCN-1:0] 	  o4, ia;
`else
   input 		  i4, oa;
   output 		  o4, ia;
`endif
   input [7:0] 		  addrx, addry;
   output [RN-1:0] 	  arb_r;
   input 		  arb_ra;
   
   //-------------------------- control signals ---------------------------------------//
   wire 		  rten;	               // routing enable
   wire 		  frame_end;	       // identify the end of a frame
   wire [7:0] 		  pipe_xd, pipe_yd;    // the target address from the incoming frame
   wire [PD:0][SCN-1:0]   pd0, pd1, pd2, pd3;  // data wires for the internal pipeline satges
   wire [5:0] 		  raw_dec;             // the routing decision from the comparator
   wire [4:0] 		  dec_reg;             // the routing decision kept by C-gates
   wire 		  x_equal;             // addr x = target x
   wire 		  rt_err;              // route decoder error
   wire                   rt_ack;	       // route build ack
   
`ifdef ENABLE_CHANNEL_SLICING
   wire [SCN-1:0] 	  rtrst;	       // rt decoder reset for each sub-channel
   wire [PD:0][SCN-1:0]   pd4, pda, pdan;      // data wires for the internal pipeline stages

`else
   wire 		  rtrst;	       // rt decode reset
   wire [PD:0] 		  pd4, pda, pdan;      // data wires for the internal pipeline satges
`endif // !`ifdef ENABLE_CHANNEL_SLICING

   genvar 		  i, j;

   //------------------------- pipelines ------------------------------------- //
   generate for(i=0; i<PD; i++) begin: DP
`ifdef ENABLE_CHANNEL_SLICING
      for(j=0; j<SCN; j++) begin: SC
	 pipe4 #(.DW(2))
	 P (
	    .o0  ( pd0[i][j]   ),
	    .o1  ( pd1[i][j]   ),
	    .o2  ( pd2[i][j]   ),
	    .o3  ( pd3[i][j]   ),
	    .o4  ( pd4[i][j]   ),
	    .ia  ( pda[i+1][j] ),
	    .i0  ( pd0[i+1][j] ),
	    .i1  ( pd1[i+1][j] ),
	    .i2  ( pd2[i+1][j] ),
	    .i3  ( pd3[i+1][j] ),
	    .i4  ( pd4[i+1][j] ),
	    .oa  ( pdan[i][j]  )
	    );
      end // block: SC

`else // !`ifdef ENABLE_CHANNEL_SLICING
      pipe4 #(.DW(DW))
      P (
	 .o0  ( pd0[i]   ),
	 .o1  ( pd1[i]   ),
	 .o2  ( pd2[i]   ),
	 .o3  ( pd3[i]   ),
	 .o4  ( pd4[i]   ),
	 .ia  ( pda[i+1] ),
	 .i0  ( pd0[i+1] ),
	 .i1  ( pd1[i+1] ),
	 .i2  ( pd2[i+1] ),
	 .i3  ( pd3[i+1] ),
	 .i4  ( pd4[i+1] ),
	 .oa  ( pdan[i]  )
	 );
`endif // !`ifdef ENABLE_CHANNEL_SLICING
   end // block: DP
   endgenerate

   generate for(i=1; i<PD; i++) begin: DPA
      assign pdan[i] = rst_n ? ~(pda[i]|pd4[i-1]) : 0;
   end
   endgenerate

   assign ia = pda[PD]|pd4[PD-1];
   assign pd0[PD] = i0;
   assign pd1[PD] = i1;
   assign pd2[PD] = i2;
   assign pd3[PD] = i3;
   assign pd4[PD] = i4;
   assign o0 = pd0[0];
   assign o1 = pd1[0];
   assign o2 = pd2[0];
   assign o3 = pd3[0];
   assign o4 = pd4[0];
   
   //---------------------------- route decoder related -------------------------- //
   // fetch the x and y target
   and Px_0 (pipe_xd[0], rten, pd0[1][0]);
   and Px_1 (pipe_xd[1], rten, pd1[1][0]);
   and Px_2 (pipe_xd[2], rten, pd2[1][0]);
   and Px_3 (pipe_xd[3], rten, pd3[1][0]);
   and Px_4 (pipe_xd[4], rten, pd0[1][1]);
   and Px_5 (pipe_xd[5], rten, pd1[1][1]);
   and Px_6 (pipe_xd[6], rten, pd2[1][1]);
   and Px_7 (pipe_xd[7], rten, pd3[1][1]);
   and Py_0 (pipe_yd[0], rten, pd0[1][2]);
   and Py_1 (pipe_yd[1], rten, pd1[1][2]);
   and Py_2 (pipe_yd[2], rten, pd2[1][2]);
   and Py_3 (pipe_yd[3], rten, pd3[1][2]);
   and Py_4 (pipe_yd[4], rten, pd0[1][3]);
   and Py_5 (pipe_yd[5], rten, pd1[1][3]);
   and Py_6 (pipe_yd[6], rten, pd2[1][3]);
   and Py_7 (pipe_yd[7], rten, pd3[1][3]);

   
   routing_decision      // the comparator
   RTD(
       .addrx      ( addrx   )
       ,.addry     ( addry   )
       ,.pipe_xd   ( pipe_xd )
       ,.pipe_yd   ( pipe_yd )
       ,.decision  ( raw_dec )
       );

   // keep the routing decision until the tail flit is received by all sub-channels
   c2p C_RTD0  ( .b(raw_dec[0]),      .a((~frame_end)&rst_n),    .q(dec_reg[0]));
   c2p C_RTD1  ( .b(raw_dec[1]),      .a((~frame_end)&rst_n),    .q(dec_reg[1]));
   c2p C_RT_XEQ (.b(raw_dec[2]),      .a((~frame_end)&rst_n),    .q(x_equal) );
   c2p C_RTD2  ( .b(raw_dec[3]),      .a(x_equal),               .q(dec_reg[2]));
   c2p C_RTD3  ( .b(raw_dec[4]),      .a(x_equal),               .q(dec_reg[3]));
   c2p C_RTD4  ( .b(raw_dec[5]),      .a(x_equal),               .q(dec_reg[4]));

   // generate the arbiter request signals
   assign arb_r = 
		  DIR == 0 ? {dec_reg[4],dec_reg[2],dec_reg[1],dec_reg[3]} :   // south port
                  DIR == 1 ? {dec_reg[4],dec_reg[2]}                       :   // west port
                  DIR == 2 ? {dec_reg[4],dec_reg[2],dec_reg[3],dec_reg[0]} :   // north port
                  DIR == 3 ? {dec_reg[4],dec_reg[3]}                       :   // east port
                             {dec_reg[2],dec_reg[1],dec_reg[3],dec_reg[0]} ;   // local port
   

   assign rt_err = 
		  DIR == 0 ? |{dec_reg[0]}                        :   // south port
                  DIR == 1 ? |{dec_reg[0],dec_reg[1],dec_reg[3]}  :   // west port
                  DIR == 2 ? |{dec_reg[1]}                        :   // north port
                  DIR == 3 ? |{dec_reg[0],dec_reg[1],dec_reg[2]}  :   // east port
                             |{dec_reg[4]}                        ;   // local port

   or IP_RTACK (rt_ack, rt_err, arb_ra);

   // ------------------------ pipeline control ------------------------------ //
   
`ifdef ENABLE_CHANNEL_SLICING
   for(j=0; j<SCN; j++) begin: SC
      // the sub-channel controller
      subc_ctl SCH_C (
		      .nack     ( pdan[0][j]  ),
		      .rt_rst   ( rtrst[j]    ),
		      .ai2cb    ( oa[j]       ),
		      .ack      ( pda[1][j]   ),
		      .eof      ( pd4[0][j]   ),
		      .rt_ra    ( rt_ack      ),
		      .rt_err   ( rt_err      ),
		      .rst_n    ( rst_n       )
		      );
   end // block: SC
`else // !`ifdef ENABLE_CHANNEL_SLICING
   subc_ctl SCH_C (
		   .nack     ( pdan[0]  ),
		   .rt_rst   ( rtrst    ),
		   .ai2cb    ( oa       ),
		   .ack      ( pda[1]   ),
		   .eof      ( pd4[0]   ),
		   .rt_ra    ( rt_ack   ),
		   .rt_err   ( rt_err   ),
		   .rst_n    ( rst_n    )
		   );
`endif // !`ifdef ENABLE_CHANNEL_SLICING
   
   // the router controller part
   assign rten = ~rt_ack;
   assign frame_end = &rtrst;

endmodule // inp_buf


// the routing decision making procedure, comparitors
module routing_decision (
			 addrx
			 ,addry
			 ,pipe_xd
			 ,pipe_yd
			 ,decision
			 );

   // compare with (2,3)
   input [7:0] addrx;
   input [7:0] addry;
   
   input   [7:0]   pipe_xd;
   input [7:0] 	   pipe_yd;
   output [5:0]    decision;

   wire [2:0] 	   x_cmp [1:0];
   wire [2:0] 	   y_cmp [1:0];

   comp4 X0 ( .a(pipe_xd[3:0]), .b(addrx[3:0]), .q(x_cmp[0]));
   comp4 X1 ( .a(pipe_xd[7:4]), .b(addrx[7:4]), .q(x_cmp[1]));
   comp4 Y0 ( .a(pipe_yd[3:0]), .b(addry[3:0]), .q(y_cmp[0]));
   comp4 Y1 ( .a(pipe_yd[7:4]), .b(addry[7:4]), .q(y_cmp[1]));

   assign decision[0] = x_cmp[1][0] | (x_cmp[1][2]&x_cmp[0][0]);       // frame x > addr x
   assign decision[1] = x_cmp[1][1] | (x_cmp[1][2]&x_cmp[0][1]);       // frame x < addr x
   assign decision[2] = x_cmp[1][2] & x_cmp[0][2];                     // frame x = addr x
   assign decision[3] = y_cmp[1][0] | (y_cmp[1][2]&y_cmp[0][0]);       // frame y > addr y
   assign decision[4] = y_cmp[1][1] | (y_cmp[1][2]&y_cmp[0][1]);       // frame y < addr y
   assign decision[5] = y_cmp[1][2] & y_cmp[0][2];                     // frame y = addr y

endmodule // routing_decision
