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
  crc_32.v: This block contains the tx_crc32 generator.
            CRC is generated on the tx data when gen_tx_crc asserted.
            The 32-bit crc shift register is reset to all 1's when either
            tx_reset_crc asserted
 
 *********************************************************************/
module g_tx_crc32 (
	      // List of outputs.
	      tx_fcs,
	      
	      // List of inputs
	      gen_tx_crc,
	      tx_reset_crc,
	      tx_data,
	      sclk,
	      reset_n);
  
  // defx[ine inputs and outputs.
  
  input		gen_tx_crc;        // when asserted, crc is generated on the
                                   // tx_data[3:0]. 
  input		tx_reset_crc;      // when asserted, crc shift register is
                                   // reset to all 1's. from link_phy_intfc.
  input [7:0]	tx_data;           // trasnmit data.
  input		sclk;              // serial clock from phy.
  input		reset_n;             // global asynchronous reset.
  
  
  output [31:0]	tx_fcs;       // 32-bit crc for tx_data. to link_phy_intfc.
  
  
  // reg/wire declarations for primary outputs.
  wire [31:0]	tx_fcs;        
  
  // define constants and parameters here.
   
  // define local signals here.
  
  wire [7:0]	crc_in;
  wire		gen_crc;
  wire[7:0]     tx_data_in;
  wire          carry0,carry1,carry2,carry3;
  wire          carry4,carry5,carry6,carry7;
  reg [31:0]	current_crc, next_crc;
  
  // code starts here.
  assign tx_data_in = tx_data;
  assign crc_in = tx_data_in;
  
  assign gen_crc = gen_tx_crc;
  
  // 32-bit crc shift register for crc calculation.
  
  always @(posedge sclk or negedge reset_n)
    begin
      if (!reset_n)
	begin
	  current_crc <= 32'hffffffff;
	end
      else
	begin
	  if (tx_reset_crc )
	    begin
	      current_crc <= 32'hffffffff;
	    end
	  else if (gen_crc)  // generate crc 
	    begin
	      current_crc <= next_crc;
	    end // else: !if(tx_reset_crc )
	end // else: !if(reset_n)
    end // always @ (posedge sclk or negedge reset_n)

  // combinational logic to generate next_crc
  
  always @(current_crc or crc_in)
    begin

      next_crc[0]  = current_crc[8] ^ current_crc[2] ^ crc_in[2];
	    next_crc[1]  = current_crc[9] ^ current_crc[0] ^ crc_in[0] ^
	                   current_crc[3] ^ crc_in[3]; 
	    next_crc[2]  = current_crc[10] ^ current_crc[0] ^ crc_in[0] ^
	                   current_crc[1] ^ crc_in[1] ^ current_crc[4]  ^
		                 crc_in[4];
	    next_crc[3]  = current_crc[11] ^ current_crc[1] ^ crc_in[1] ^
	                   current_crc[2] ^ crc_in[2] ^ current_crc[5]  ^
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
	                   current_crc[6]  ^ current_crc[0] ^ crc_in[0]  ^
		                 crc_in[6] ^ current_crc[7] ^ current_crc[1]  ^
		                 crc_in[1] ^ crc_in[7];
	    next_crc[9]  = current_crc[17] ^ current_crc[1] ^ crc_in[1] ^
	                   current_crc[7] ^ current_crc[1] ^ crc_in[1]  ^
		                 crc_in[7];
	    next_crc[10]  = current_crc[18] ^ current_crc[2] ^ crc_in[2];
	    next_crc[11]  = current_crc[19] ^ current_crc[3] ^ crc_in[3];
	    next_crc[12]  = current_crc[20] ^ current_crc[0] ^ crc_in[0] ^
	                    current_crc[4]  ^ crc_in[4];
	    next_crc[13]  = current_crc[21] ^ current_crc[0] ^ crc_in[0] ^
	                    current_crc[1]  ^ crc_in[1] ^ current_crc[5]  ^
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

//  assign tx_fcs = ~current_crc;
  assign tx_fcs[0] = !current_crc[0];
  assign tx_fcs[1] = !current_crc[1];
  assign tx_fcs[2] = !current_crc[2];
  assign tx_fcs[3] = !current_crc[3];
  assign tx_fcs[4] = !current_crc[4];
  assign tx_fcs[5] = !current_crc[5];
  assign tx_fcs[6] = !current_crc[6];
  assign tx_fcs[7] = !current_crc[7];
  assign tx_fcs[8] = !current_crc[8];
  assign tx_fcs[9] = !current_crc[9];
  assign tx_fcs[10] = !current_crc[10];
  assign tx_fcs[11] = !current_crc[11];
  assign tx_fcs[12] = !current_crc[12];
  assign tx_fcs[13] = !current_crc[13];
  assign tx_fcs[14] = !current_crc[14];
  assign tx_fcs[15] = !current_crc[15];
  assign tx_fcs[16] = !current_crc[16];
  assign tx_fcs[17] = !current_crc[17];
  assign tx_fcs[18] = !current_crc[18];
  assign tx_fcs[19] = !current_crc[19];
  assign tx_fcs[20] = !current_crc[20];
  assign tx_fcs[21] = !current_crc[21];
  assign tx_fcs[22] = !current_crc[22];
  assign tx_fcs[23] = !current_crc[23];
  assign tx_fcs[24] = !current_crc[24];
  assign tx_fcs[25] = !current_crc[25];
  assign tx_fcs[26] = !current_crc[26];
  assign tx_fcs[27] = !current_crc[27];
  assign tx_fcs[28] = !current_crc[28];
  assign tx_fcs[29] = !current_crc[29];
  assign tx_fcs[30] = !current_crc[30];
  assign tx_fcs[31] = !current_crc[31];
  
endmodule
