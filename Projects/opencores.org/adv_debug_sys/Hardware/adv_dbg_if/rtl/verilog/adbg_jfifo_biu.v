//////////////////////////////////////////////////////////////////////
////                                                              ////
////  adbg_jfifo_biu.v                                              ////
////                                                              ////
////                                                              ////
////  This file is part of the SoC Debug Interface.               ////
////                                                              ////
////  Author(s):                                                  ////
////       Nathan Yawn (nathan.yawn@opencores.org)                ////
////                                                              ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2010        Authors                            ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// This is where the magic happens in the JTAG Serial Port.  The serial
// port FIFOs and counters are kept in the WishBone clock domain.
// 'Syncflop' elements are used to synchronize strobe lines across
// clock domains, and 'syncreg' elements keep the byte and free count
// as current as possible in the JTAG clock domain.  Also in the WB
// clock domain is a WishBone target interface, which more or less
// tries to emulate a 16550 without FIFOs (despite the fact that
// FIFOs are actually present, they are opaque to the WB interface.)
//


// Top module
module `VARIANT`JFIFO_BIU
  (
   // Debug interface signals
   tck_i,
   rst_i,
   data_o,
   bytes_available_o,
   bytes_free_o,
   rd_strobe_i,
   wr_strobe_i,

   // Wishbone signals
   wb_clk_i,
   wb_dat_i,
   wb_stb_i
   );

   // Debug interface signals
   input tck_i;
   input rst_i;
   output [7:0] data_o;
   output [3:0] bytes_free_o;
   output [3:0] bytes_available_o;
   input 	rd_strobe_i;
   input 	wr_strobe_i;

   // Wishbone signals
   input 	 wb_clk_i;
   input  [7:0]  wb_dat_i;
   input 	 wb_stb_i;
  


   wire [7:0] 	 data_o;
   wire [3:0] 	 bytes_free_o;
   assign        bytes_free_o = 4'b0100;
   
   wire [3:0] 	 bytes_available_o;
   
   // Registers

   reg [7:0] 	 rdata;
   reg 		 ren_tff;
 
   // Wires  
   wire 	 wb_fifo_ack;
   wire [3:0] 	 wr_bytes_free;
   wire [3:0] 	 rd_bytes_avail;
   wire [3:0]	 wr_bytes_avail;  // used to generate wr_fifo_not_empty
   assign       wr_bytes_avail = 4'b0000;
   

   wire 	 rd_bytes_avail_not_zero;
   wire 	 ren_sff_out;   
   wire [7:0] 	 rd_fifo_data_out;

   wire 	 wr_fifo_not_empty;  // this is for the WishBone interface LSR register
   
   // Control Signals (FSM outputs)

   reg 		 ren_rst;   // reset 'pop' SFF
   reg 		 rdata_en;  // enable 'rdata' register
   reg 		 rpp;       // read FIFO PUSH (1) or POP (0)
   reg 		 r_fifo_en; // enable read FIFO    
   reg 		 r_wb_ack;  // read FSM acks WB transaction


   // Indicators to FSMs

   wire 	 pop;         // JTAG side received a byte, pop and get next
   wire 	 rcz;         // zero bytes available in read FIFO
   
   

   //////////////////////////////////////////////////////
   // TCK clock domain
   // There is no FSM here, just signal latching and clock
   // domain synchronization

   assign 	 data_o = rdata;


   // Read enable (REN) toggle FF
   always @ (posedge tck_i or posedge rst_i)
     begin
	if(rst_i) ren_tff <= 1'b0;
	else if(rd_strobe_i) ren_tff <= ~ren_tff;
     end


   

   ///////////////////////////////////////////////////////
   // Wishbone clock domain

   // Combinatorial assignments
   assign rd_bytes_avail_not_zero = !(rd_bytes_avail == 4'h0);
   assign pop = ren_sff_out & rd_bytes_avail_not_zero;
   assign rcz = ~rd_bytes_avail_not_zero;
   assign wb_fifo_ack = r_wb_ack ;
   assign wr_fifo_not_empty = 1'b0;
       
   // rdata register
   always @ (posedge wb_clk_i or posedge rst_i)
     begin
	if(rst_i) rdata <= 8'h0;
	else if(rdata_en) rdata <= rd_fifo_data_out;
     end
        
   
   // REN SFF
   `VARIANT`SYNCFLOP ren_sff (
                     .DEST_CLK(wb_clk_i),
		     .D_SET(1'b0),
		     .D_RST(ren_rst),
		     .RESET(rst_i),
                     .TOGGLE_IN(ren_tff),
                     .D_OUT(ren_sff_out)
		     );
   

   
   // 'bytes available' syncreg
   `VARIANT`SYNCREG bytesavail_syncreg (
			      .CLKA(wb_clk_i),
			      .CLKB(tck_i),
			      .RST(rst_i),
			      .DATA_IN(rd_bytes_avail),
			      .DATA_OUT(bytes_available_o)
			      );
   
   
   // read FIFO
   `VARIANT`BYTEFIFO rd_fifo (
		     .CLK          ( wb_clk_i          ),
		     .RST          ( rst_i             ),  // rst_i from JTAG clk domain, xmit_fifo_rst from WB, RST is async reset
                     .DATA_IN      ( wb_dat_i[7:0]     ),
		     .DATA_OUT     ( rd_fifo_data_out  ),
		     .PUSH_POPn    ( rpp               ),
                     .EN           ( r_fifo_en         ),
                     .BYTES_AVAIL  ( rd_bytes_avail    ),
		     .BYTES_FREE   (                   )
		     );			      




   
   /////////////////////////////////////////////////////
   // State machine for the read FIFO

   reg [1:0] rd_fsm_state;
   reg [1:0]   next_rd_fsm_state;

`define STATE_RD_IDLE     2'h0
`define STATE_RD_PUSH     2'h1
`define STATE_RD_POP      2'h2
`define STATE_RD_LATCH    2'h3
   
   // Sequential bit
   always @ (posedge wb_clk_i or posedge rst_i)
     begin
	if(rst_i) rd_fsm_state <= `STATE_RD_IDLE;
	else rd_fsm_state <= next_rd_fsm_state; 
     end

   // Determination of next state (combinatorial)
   always @ (*)
     begin
	case (rd_fsm_state)
          `STATE_RD_IDLE:
            begin
               if(wb_stb_i) next_rd_fsm_state = `STATE_RD_PUSH;
               else if (pop) next_rd_fsm_state = `STATE_RD_POP;
               else next_rd_fsm_state = `STATE_RD_IDLE;
            end
          `STATE_RD_PUSH:
            begin
               if(rcz) next_rd_fsm_state = `STATE_RD_LATCH;  // putting first item in fifo, move to rdata in state LATCH
               else if(pop) next_rd_fsm_state = `STATE_RD_POP;
	       else next_rd_fsm_state = `STATE_RD_IDLE;
            end
	  `STATE_RD_POP:
	    begin
	       next_rd_fsm_state = `STATE_RD_LATCH; // new data at FIFO head, move to rdata in state LATCH
	    end
	  `STATE_RD_LATCH:
	    begin
	       if(wb_stb_i) next_rd_fsm_state = `STATE_RD_PUSH;
	       else if(pop) next_rd_fsm_state = `STATE_RD_POP;
	       else next_rd_fsm_state = `STATE_RD_IDLE;
	    end
	  default:
	    begin
	       next_rd_fsm_state = `STATE_RD_IDLE;
	    end
	endcase
     end

   // Outputs of state machine (combinatorial)
   always @ (rd_fsm_state)
     begin
	ren_rst = 1'b0;
	rpp = 1'b0;
	r_fifo_en = 1'b0;
	rdata_en = 1'b0;
	r_wb_ack = 1'b0;
	
	case (rd_fsm_state)
          `STATE_RD_IDLE:;

          `STATE_RD_PUSH:
            begin
	       rpp = 1'b1;
	       r_fifo_en = 1'b1;
	       r_wb_ack = 1'b1;
            end
	  
	  `STATE_RD_POP:
	    begin
	       ren_rst = 1'b1;
	       r_fifo_en = 1'b1;
	    end
	  
	  `STATE_RD_LATCH:
	    begin
	       rdata_en = 1'b1;
	    end
	endcase
     end



   





   



	      
endmodule

