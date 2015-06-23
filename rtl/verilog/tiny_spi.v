//////////////////////////////////////////////////////////////////////
////                                                              ////
////  tiny_spi.v                                                  ////
////                                                              ////
////  This file is part of the TINY SPI IP core project           ////
////  http://www.opencores.org/projects/tiny_spi/                 ////
////                                                              ////
////  Author(s):                                                  ////
////      - Thomas Chou <thomas@wytron.com.tw>                    ////
////                                                              ////
////  All additional information is avaliable in the README       ////
////  file.                                                       ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2010 Authors                                   ////
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

module tiny_spi(
   // system
   input	  rst_i,
   input	  clk_i,
   // memory mapped
   input	  stb_i,
   input	  we_i,
   output [31:0]  dat_o,
   input [31:0]   dat_i,
   output	  int_o,
   input [2:0]	  adr_i,
   input 	  cyc_i, // comment out for avalon
   output 	  ack_o, // comment out for avalon

   // spi
   output	  MOSI,
   output	  SCLK,
   input	  MISO
   );

   parameter BAUD_WIDTH = 8;
   parameter BAUD_DIV = 0;
   parameter SPI_MODE = 0;
   parameter BC_WIDTH = 3;
   parameter DIV_WIDTH = BAUD_DIV ? $clog2(BAUD_DIV / 2 - 1) : BAUD_WIDTH;


   reg [7:0]	  sr8, bb8;
   wire [7:0]	  sr8_sf;
   reg [BC_WIDTH - 1:0]		bc, bc_next;
   reg [DIV_WIDTH - 1:0]	ccr;
   reg [DIV_WIDTH - 1:0]	cc, cc_next;
   wire		  misod;
   wire		  cstb, wstb, bstb, istb;
   reg		  sck;
   reg		  sf, ld;
   reg		  bba;   // buffer flag
   reg		  txren, txeen;
   wire 	  txr, txe;
   wire		  cpol, cpha;
   reg		  cpolr, cphar;
   wire 	  wr;
   // wire 	  cyc_i; // comment out for wishbone
   // wire 	  ack_o; // comment out for wishbone
   // assign cyc_i = 1'b1;  // comment out for wishbone
   assign ack_o = stb_i & cyc_i; // zero wait
   assign wr = stb_i & cyc_i & we_i & ack_o;
   assign wstb = wr & (adr_i == 1);
   assign istb = wr & (adr_i == 2);
   assign cstb = wr & (adr_i == 3);
   assign bstb = wr & (adr_i == 4);
   assign sr8_sf = { sr8[6:0],misod };
   assign dat_o =
		      (sr8 & {8{(adr_i == 0)}})
		    | (bb8 & {8{(adr_i == 1)}})
		    | ({ txr, txe } & {8{(adr_i == 2)}})
		      ;

   parameter
     IDLE = 0,
     PHASE1 = 1,
     PHASE2 = 2
     ;

   reg [1:0] spi_seq, spi_seq_next;
   always @(posedge clk_i or posedge rst_i)
     if (rst_i)
       spi_seq <= IDLE;
     else
       spi_seq <= spi_seq_next;

   always @(posedge clk_i)
     begin
	cc <= cc_next;
	bc <= bc_next;
     end

   always @(/*AS*/bba or bc or cc or ccr or cpha or cpol or spi_seq)
     begin
	sck = cpol;
	cc_next = BAUD_DIV ? (BAUD_DIV / 2 - 1) : ccr;
	bc_next = bc;
	ld = 1'b0;
	sf = 1'b0;

	case (spi_seq)
	  IDLE:
	    begin
	       if (bba)
		 begin
		    bc_next = 7;
		    ld = 1'b1;
		    spi_seq_next = PHASE2;
		 end
	       else
		 spi_seq_next = IDLE;
	    end
	  PHASE2:
	    begin
	       sck = (cpol ^ cpha);
	       if (cc == 0)
		 spi_seq_next = PHASE1;
	       else
		 begin
		    cc_next = cc - 1;
		    spi_seq_next = PHASE2;
		 end
	    end
	  PHASE1:
	    begin
	       sck = ~(cpol ^ cpha);
	       if (cc == 0)
		 begin
		    bc_next = bc -1;
		    sf = 1'b1;
		    if (bc == 0)
		      begin
			 if (bba)
			   begin
			      bc_next = 7;
			      ld = 1'b1;
			      spi_seq_next = PHASE2;
			   end
			 else
			   spi_seq_next = IDLE;
		      end
		    else
		      spi_seq_next = PHASE2;
		 end
	       else
		 begin
		    cc_next = cc - 1;
		    spi_seq_next = PHASE1;
		 end
	    end
	endcase
     end // always @ (...

   always @(posedge clk_i)
     begin
	if (cstb) // control reg
	  { cpolr, cphar } <= dat_i;
	else
	  { cpolr, cphar } <= { cpolr, cphar };

	if (istb) // irq enable reg
	  { txren, txeen } <= dat_i;
	else
	  { txren, txeen } <= { txren, txeen };

	if (bstb) // baud reg
	  ccr <= dat_i;
	else
	  ccr <= ccr;

	if (ld)   // shift reg
	  sr8 <= bb8;
	else if (sf)
	  sr8 <= sr8_sf;
	else
	  sr8 <= sr8;

	if (wstb) // buffer reg
	  bb8 <= dat_i;
	else if (ld)
	  bb8 <= (spi_seq == IDLE) ? sr8 : sr8_sf;
	else
	  bb8 <= bb8;
     end // always @ (posedge clk_i)

   always @(posedge clk_i or posedge rst_i)
     begin
	if (rst_i)
	  bba <= 1'b0;
	else if (wstb)
	  bba <= 1'b1;
	else if (ld)
	  bba <= 1'b0;
	else
	  bba <= bba;
     end

   assign { cpol, cpha } = ((SPI_MODE >= 0) & (SPI_MODE < 4)) ?
			   SPI_MODE : { cpolr, cphar };
   assign txe = (spi_seq == IDLE);
   assign txr = ~bba;
   assign int_o = (txr & txren) | (txe & txeen);
   assign SCLK = sck;
   assign MOSI = sr8[7];
   assign misod = MISO;

endmodule
