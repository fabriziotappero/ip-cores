//////////////////////////////////////////////////////////////////////
////                                                              ////
////  bytefifo.v                                                  ////
////                                                              ////
////                                                              ////
////  A simple byte-wide FIFO with byte and free space counts     ////
////                                                              ////
////  Author(s):                                                  ////
////       Nathan Yawn (nathan.yawn@opencores.org)                ////
////                                                              ////
////                                                              ////
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
//
// This is an 8-entry, byte-wide, single-port FIFO.  It can either
// push or pop a byte each clock cycle (but not both).  It includes
// outputs indicating the number of bytes in the FIFO, and the number
// of bytes free - if you don't connect BYTES_FREE, the synthesis
// tool should eliminate the hardware to generate it.
//
// This attempts to use few resources.  There is only 1 counter,
// and only 1 decoder.  The FIFO works like a big shift register:
// bytes are always written to entry '0' of the FIFO, and older
// bytes are shifted toward entry '7' as newer bytes are added.
// The counter determines which entry the output reads.
//
// One caveat is that the DATA_OUT will glitch during a 'push'
// operation.  If the output is being sent to another clock
// domain, you should register it first.
//
// Ports:
// CLK:  Clock for all synchronous elements
// RST:  Zeros the counter and all registers asynchronously
// DATA_IN: Data to be pushed into the FIFO
// DATA_OUT: Always shows the data at the head of the FIFO, 'XX' if empty
// PUSH_POPn: When high (and EN is high), DATA_IN will be pushed onto the
//            FIFO and the count will be incremented at the next posedge
//            of CLK (assuming the FIFO is not full).  When low (and EN
//            is high), the count will be decremented and the output changed
//            to the next value in the FIFO (assuming FIFO not empty).
// EN: When high at posedege CLK, a push or pop operation will be performed,
//     based on the value of PUSH_POPn, assuming sufficient data or space.
// BYTES_AVAIL: Number of bytes in the FIFO.  May be in the range 0 to 8.
// BYTES_FREE: Free space in the FIFO.  May be in the range 0 to 8.          


// Top module
module bytefifo (
		 CLK,
		 RST,
                 DATA_IN,
		 DATA_OUT,
		 PUSH_POPn,
                 EN,
                 BYTES_AVAIL,
		 BYTES_FREE
		);


   input        CLK;
   input        RST;
   input  [7:0] DATA_IN;
   output [7:0] DATA_OUT;
   input        PUSH_POPn;
   input        EN;
   output [3:0] BYTES_AVAIL;
   output [3:0] BYTES_FREE;

   reg [7:0] 	reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7;
   reg [3:0] 	counter;
      
   reg [7:0]  DATA_OUT;
   wire [3:0]  BYTES_AVAIL;
   wire [3:0] 	BYTES_FREE;
   wire 	push_ok;
   wire    pop_ok;
   
   ///////////////////////////////////
   // Combinatorial assignments
   
   assign BYTES_AVAIL = counter;  
   assign  BYTES_FREE = 4'h8 - BYTES_AVAIL;
   assign  push_ok = !(counter == 4'h8);
   assign  pop_ok = !(counter == 4'h0);
   
   ///////////////////////////////////
   // FIFO memory / shift registers
   
   // Reg 0 - takes input from DATA_IN
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg0 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg0 <= DATA_IN;
     end


   // Reg 1 - takes input from reg0
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg1 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg1 <= reg0;
     end

   
   // Reg 2 - takes input from reg1
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg2 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg2 <= reg1;
     end

   
   // Reg 3 - takes input from reg2
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg3 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg3 <= reg2;
     end

   
   // Reg 4 - takes input from reg3
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg4 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg4 <= reg3;
     end

   
   // Reg 5 - takes input from reg4
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg5 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg5 <= reg4;
     end

   
   // Reg 6 - takes input from reg5
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg6 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg6 <= reg5;
     end

   
   // Reg 7 - takes input from reg6
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)
	  reg7 <= 8'h0;
	else if(EN & PUSH_POPn & push_ok)
	  reg7 <= reg6;
     end

   ///////////////////////////////////////////////////
   // Read counter
   // This is a 4-bit saturating up/down counter
  // The 'saturating' is done via push_ok and pop_ok
  
   always @ (posedge CLK or posedge RST)
     begin
	if(RST)             counter <= 4'h0;
	else if(EN & PUSH_POPn & push_ok)  counter <= counter + 4'h1;
	else if(EN & (~PUSH_POPn) & pop_ok)    counter <= counter - 4'h1;
     end

   /////////////////////////////////////////////////
   // Output decoder
   
   always @ (counter or reg0 or reg1 or reg2 or reg3 or reg4 or reg5
	     or reg6 or reg7)
     begin
	case (counter)
	  4'h1:     DATA_OUT <= reg0; 
	  4'h2:     DATA_OUT <= reg1;
	  4'h3:     DATA_OUT <= reg2;
	  4'h4:     DATA_OUT <= reg3;
	  4'h5:     DATA_OUT <= reg4;
	  4'h6:     DATA_OUT <= reg5;
	  4'h7:     DATA_OUT <= reg6;
	  4'h8:     DATA_OUT <= reg7;
	  default:  DATA_OUT <= 8'hXX;
	endcase
     end

   
endmodule
