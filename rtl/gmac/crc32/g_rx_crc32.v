//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Tubo 8051 cores MAC Interface Module                        ////
////                                                              ////
////  This file is part of the Turbo 8051 cores project           ////
////  http://www.opencores.org/cores/turbo8051/                   ////
////                                                              ////
////  Description                                                 ////
////  Turbo 8051 definitions.                                     ////
////                                                              ////
////  To Do:                                                      ////
////    nothing                                                   ////
////                                                              ////
////  Author(s):                                                  ////
////      - Dinesh Annayya, dinesha@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
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
/***************************************************************
  Description:
  rx_crc32.v: This block contains the crc32 checker.
 * CRC is generated in the receive data when mi2rc_rcv_valid is asserted.
 * For the recieve data. crc_ok indicates whenther the packet was 
 * good or bad.
 * The 32-bit crc shift register is reset to all 1's when
 * mi2rc_strt_rcv is asserted.
 
 *********************************************************************/
module g_rx_crc32 (
              // CRC Valid signal to rx_fsm
	      rc2rf_crc_ok,
	      
	      // Global Signals
	      phy_rx_clk,
	      reset_n,
              // CRC Data signals
	      mi2rc_strt_rcv,
	      mi2rc_rcv_valid,
	      mi2rc_rx_byte
	      );
  
  // defx[ine inputs and outputs.
  
  output	rc2rf_crc_ok;            // asserted when crc check is ok. to rx.

  input		phy_rx_clk;              // serial clock from phy.
  input		reset_n;             // global asynchronous reset.

  input		mi2rc_rcv_valid;        // when asserted, crc is computed on 
                                   // rx_crc_data. from rx.
  input		mi2rc_strt_rcv;      // when asserted, crc shift register is
                                   // reset to all 1's. from rx.
  input [7:0]	mi2rc_rx_byte;       // receive data. from rx.
  
  
  
  
  // reg/wire declarations for primary outputs.
  wire		rc2rf_crc_ok;
  
  // define constants and parameters here.
  // define local signals here.
  
  wire [7:0]	crc_in;
  wire		gen_crc;
  reg [31:0]	current_crc, next_crc;
  reg		crc_ok_ul;
 
  wire [31:0]   rx_fcs;
  
  // code starts here.
  
  // select either rx_crc_data or tx_data as the input to crc generator.
  assign crc_in = mi2rc_rx_byte;

  // enable crc generator 
  
  assign gen_crc = mi2rc_rcv_valid ; // 
  
  // 32-bit crc shift register for crc calculation.
  
  always @(posedge phy_rx_clk or negedge reset_n)
    begin
      if (!reset_n)
	begin
	  current_crc <= 32'hffffffff;
	end
      else
	begin
	  if (mi2rc_strt_rcv)
	    begin
	      current_crc <= 32'hffffffff;
	    end
	  else if (gen_crc)  // generate crc 
	    begin
	      current_crc <= next_crc;
	    end // else: !if(tx_reset_crc || mi2rc_strt_rcv)
	end // else: !if(!reset_n)
    end // always @ (posedge phy_rx_clk or negedge reset_n)

  // combinational logic to generate next_crc

  always @(current_crc or crc_in)
    begin

      next_crc[0]  = current_crc[8]  ^ current_crc[2] ^ crc_in[2];
	    next_crc[1]  = current_crc[9]  ^ current_crc[0] ^ crc_in[0] ^
	                   current_crc[3]  ^ crc_in[3]; 
	    next_crc[2]  = current_crc[10] ^ current_crc[0] ^ crc_in[0] ^
	                   current_crc[1]  ^ crc_in[1] ^ current_crc[4]  ^
		                 crc_in[4];
	    next_crc[3]  = current_crc[11] ^ current_crc[1] ^ crc_in[1] ^
	                   current_crc[2]  ^ crc_in[2] ^ current_crc[5]  ^
		                 crc_in[5];
	    next_crc[4]  = current_crc[12] ^ current_crc[2] ^ crc_in[2] ^
	                   current_crc[3] ^ crc_in[3] ^ current_crc[6]  ^
		                 current_crc[0] ^ crc_in[0] ^ crc_in[6];
	    next_crc[5]  = current_crc[13] ^ current_crc[3] ^ crc_in[3] ^
	                   current_crc[4] ^ crc_in[4] ^ current_crc[7]  ^
		                 current_crc[1] ^ crc_in[1] ^ crc_in[7];
	    next_crc[6]  = current_crc[14] ^ current_crc[4] ^ crc_in[4] ^
	                   current_crc[5] ^ crc_in[5];
	    next_crc[7]  = current_crc[15] ^ current_crc[5] ^ crc_in[5] ^
	                   current_crc[6] ^ current_crc[0] ^ crc_in[0]  ^
		                 crc_in[6];
	    next_crc[8]  = current_crc[16] ^ current_crc[0] ^ crc_in[0] ^
	                   current_crc[6] ^ current_crc[0] ^ crc_in[0]  ^
      		           crc_in[6] ^ current_crc[7] ^ current_crc[1]  ^
		                 crc_in[1] ^ crc_in[7];
	    next_crc[9]  = current_crc[17] ^ current_crc[1] ^ crc_in[1] ^
	                   current_crc[7] ^ current_crc[1] ^ crc_in[1]  ^
       		           crc_in[7];
	    next_crc[10]  = current_crc[18] ^ current_crc[2] ^ crc_in[2];
	    next_crc[11]  = current_crc[19] ^ current_crc[3] ^ crc_in[3];
	    next_crc[12]  = current_crc[20] ^ current_crc[0] ^ crc_in[0] ^
	                    current_crc[4] ^ crc_in[4];
	    next_crc[13]  = current_crc[21] ^ current_crc[0] ^ crc_in[0] ^
	                    current_crc[1] ^ crc_in[1] ^ current_crc[5]  ^
		                  crc_in[5];
	    next_crc[14]  = current_crc[22] ^ current_crc[0] ^ crc_in[0] ^
	                    current_crc[1] ^ crc_in[1] ^ current_crc[2]  ^
		                  crc_in[2] ^ current_crc[6] ^ current_crc[0]  ^
		                  crc_in[0] ^ crc_in[6];
	    next_crc[15]  = current_crc[23] ^ current_crc[1] ^ crc_in[1] ^
	                    current_crc[2] ^ crc_in[2] ^ current_crc[3]  ^
		                  crc_in[3] ^ current_crc[7] ^ current_crc[1]  ^
		                  crc_in[1] ^ crc_in[7];
	    next_crc[16]  = current_crc[24] ^ current_crc[0] ^ crc_in[0] ^
	                    current_crc[2] ^ crc_in[2] ^ current_crc[3]  ^
		                  crc_in[3] ^ current_crc[4] ^ crc_in[4];
	    next_crc[17]  = current_crc[25] ^ current_crc[0] ^ crc_in[0] ^
	                    current_crc[1] ^ crc_in[1] ^ current_crc[3]  ^
		                  crc_in[3] ^ current_crc[4] ^ crc_in[4]  ^
		                  current_crc[5] ^ crc_in[5]; 
	    next_crc[18]  = current_crc[26] ^ current_crc[1] ^ crc_in[1] ^
	                    current_crc[2] ^ crc_in[2] ^ current_crc[4]  ^
		                  crc_in[4] ^ current_crc[5] ^ crc_in[5]  ^
		                  current_crc[6] ^ current_crc[0] ^ crc_in[0]  ^
		                  crc_in[6];
	    next_crc[19]  = current_crc[27] ^ current_crc[0] ^ crc_in[0] ^
	                    current_crc[2] ^ crc_in[2] ^ current_crc[3]  ^
		                  crc_in[3] ^ current_crc[5] ^ crc_in[5]  ^
		                  current_crc[6] ^ current_crc[0] ^ crc_in[0]  ^
		                  crc_in[6] ^ current_crc[7] ^ current_crc[1]  ^
		                  crc_in[1] ^ crc_in[7];
	    next_crc[20]  = current_crc[28] ^ current_crc[0] ^ crc_in[0] ^
	                    current_crc[1] ^ crc_in[1] ^ current_crc[3]  ^
		                  crc_in[3] ^ current_crc[4] ^ crc_in[4]  ^
		                  current_crc[6] ^ current_crc[0] ^ crc_in[0]  ^
		                  crc_in[6] ^ current_crc[7] ^ current_crc[1]  ^
		                  crc_in[1] ^ crc_in[7];
	    next_crc[21]  = current_crc[29] ^ current_crc[1] ^ crc_in[1] ^
                      current_crc[2] ^ crc_in[2] ^ current_crc[4]  ^
                      crc_in[4] ^ current_crc[5] ^ crc_in[5]  ^
                      current_crc[7] ^ current_crc[1] ^ crc_in[1]  ^ 
                      crc_in[7];
	    next_crc[22]  = current_crc[30] ^ current_crc[0] ^ crc_in[0] ^
                      current_crc[2] ^ crc_in[2] ^ current_crc[3]  ^
                      crc_in[3] ^ current_crc[5] ^ crc_in[5]  ^
                      current_crc[6] ^ current_crc[0] ^ crc_in[0]  ^
                      crc_in[6];
	    next_crc[23]  = current_crc[31] ^ current_crc[0] ^ crc_in[0] ^
                      current_crc[1] ^ crc_in[1] ^ current_crc[3]  ^
                      crc_in[3] ^ current_crc[4] ^ crc_in[4]  ^
                      current_crc[6] ^ current_crc[0] ^ crc_in[0]  ^
                      crc_in[6] ^ current_crc[7] ^ current_crc[1]  ^
                      crc_in[1] ^ crc_in[7];
	    next_crc[24]  = current_crc[0] ^ crc_in[0] ^ current_crc[1]  ^ 
                      crc_in[1] ^ current_crc[2] ^ crc_in[2]    ^
                      current_crc[4] ^ crc_in[4] ^ current_crc[5]  ^
                      crc_in[5] ^ current_crc[7] ^ current_crc[1]  ^
                      crc_in[1] ^ crc_in[7];
	    next_crc[25]  = current_crc[1] ^ crc_in[1] ^ current_crc[2]  ^ 
	                    crc_in[2] ^ current_crc[3] ^ crc_in[3]    ^ 
                      current_crc[5] ^ crc_in[5] ^ current_crc[6]  ^ 
                      current_crc[0]  ^ crc_in[0] ^ crc_in[6]; 
	    next_crc[26]  = current_crc[2] ^ crc_in[2] ^ current_crc[3]  ^ 
                      crc_in[3] ^ current_crc[4] ^ crc_in[4]    ^ 
                      current_crc[6] ^ current_crc[0] ^ crc_in[0]  ^ 
                      crc_in[6]  ^ current_crc[7] ^ current_crc[1] ^ 
                      crc_in[1]  ^ crc_in[7];
	    next_crc[27]  = current_crc[3] ^ crc_in[3] ^ current_crc[4]  ^ 
                      crc_in[4] ^ current_crc[5] ^ crc_in[5]    ^ 
                      current_crc[7] ^ current_crc[1] ^ crc_in[1]  ^ 
                      crc_in[7];
	    next_crc[28]  = current_crc[4] ^crc_in[4] ^ current_crc[5]   ^ 
                      crc_in[5] ^ current_crc[6] ^ current_crc[0]  ^ 
                      crc_in[0] ^ crc_in[6];
	    next_crc[29]  = current_crc[5] ^ crc_in[5] ^ current_crc[6]  ^ 
                      current_crc[0] ^ crc_in[0] ^ crc_in[6]    ^ 
                      current_crc[7] ^ current_crc[1] ^ crc_in[1]  ^ 
                      crc_in[7];
	    next_crc[30]  = current_crc[6] ^ current_crc[0] ^ crc_in[0]  ^ 
                      crc_in[6] ^ current_crc[7] ^ current_crc[1]  ^
                      crc_in[1] ^ crc_in[7];
	    next_crc[31]  = current_crc[7] ^ current_crc[1] ^ crc_in[1] ^ 
                      crc_in[7];
    end   // always

assign rx_fcs[0] = current_crc[31];
assign rx_fcs[1] = current_crc[30];
assign rx_fcs[2] = current_crc[29];
assign rx_fcs[3] = current_crc[28];
assign rx_fcs[4] = current_crc[27];
assign rx_fcs[5] = current_crc[26];
assign rx_fcs[6] = current_crc[25];
assign rx_fcs[7] = current_crc[24];
assign rx_fcs[8] = current_crc[23];
assign rx_fcs[9] = current_crc[22];
assign rx_fcs[10] = current_crc[21];
assign rx_fcs[11] = current_crc[20];
assign rx_fcs[12] = current_crc[19];
assign rx_fcs[13] = current_crc[18];
assign rx_fcs[14] = current_crc[17];
assign rx_fcs[15] = current_crc[16];
assign rx_fcs[16] = current_crc[15];
assign rx_fcs[17] = current_crc[14];
assign rx_fcs[18] = current_crc[13];
assign rx_fcs[19] = current_crc[12];
assign rx_fcs[20] = current_crc[11];
assign rx_fcs[21] = current_crc[10];
assign rx_fcs[22] = current_crc[9];
assign rx_fcs[23] = current_crc[8];
assign rx_fcs[24] = current_crc[7];
assign rx_fcs[25] = current_crc[6];
assign rx_fcs[26] = current_crc[5];
assign rx_fcs[27] = current_crc[4];
assign rx_fcs[28] = current_crc[3];
assign rx_fcs[29] = current_crc[2];
assign rx_fcs[30] = current_crc[1];
assign rx_fcs[31] = current_crc[0];

  always @(rx_fcs)
    begin
      if (rx_fcs == 32'hc704dd7b)
	crc_ok_ul = 1;
      else
	crc_ok_ul = 0;
    end  // always


 assign rc2rf_crc_ok = crc_ok_ul; 
  
  
endmodule













