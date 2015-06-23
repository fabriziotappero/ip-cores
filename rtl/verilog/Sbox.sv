////////////////////////////////////////////////////////////////// ////
//// 																////
//// AES Decryption Core for FPGA									////
//// 																////
//// This file is part of the AES Decryption Core for FPGA project 	////
//// http://www.opencores.org/cores/xxx/ 							////
//// 																////
//// Description 													////
//// Implementation of  AES Decryption Core for FPGA according to 	////
//// core specification document.		 							////
//// 																////
//// To Do: 														////
//// - 																////
//// 																////
//// Author(s): 													////
//// - scheng, schengopencores@opencores.org 						////
//// 																////
//////////////////////////////////////////////////////////////////////
//// 																////
//// Copyright (C) 2009 Authors and OPENCORES.ORG 					////
//// 																////
//// This source file may be used and distributed without 			////
//// restriction provided that this copyright statement is not 		////
//// removed from the file and that any derivative work contains 	////
//// the original copyright notice and the associated disclaimer. 	////
//// 																////
//// This source file is free software; you can redistribute it 	////
//// and/or modify it under the terms of the GNU Lesser General 	////
//// Public License as published by the Free Software Foundation; 	////
//// either version 2.1 of the License, or (at your option) any 	////
//// later version. 												////
//// 																////
//// This source is distributed in the hope that it will be 		////
//// useful, but WITHOUT ANY WARRANTY; without even the implied 	////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 		////
//// PURPOSE. See the GNU Lesser General Public License for more 	////
//// details. 														////
//// 																////
//// You should have received a copy of the GNU Lesser General 		////
//// Public License along with this source; if not, download it 	////
//// from http://www.opencores.org/lgpl.shtml 						////
//// 																//// ///
///////////////////////////////////////////////////////////////////
////																////
//// This file implements the SBox transform as described in		////
//// section 5.1.1 of the FIPS-197 specification. It is used to 	////
//// implement the SubWord() transform in Key Expansion.			////
////																////
////////////////////////////////////////////////////////////////////////

module Sbox(
    input [7:0] d,
    output [7:0] q
    );

    wire [7:0] q0, q1, q2, q3;
    wire [7:0] r0, r1;
    
    Sbox_table0 t0(.d(d[5:0]), .q(q0));
    Sbox_table1 t1(.d(d[5:0]), .q(q1));
    Sbox_table2 t2(.d(d[5:0]), .q(q2));
    Sbox_table3 t3(.d(d[5:0]), .q(q3));
       
    genvar j;
    generate
        for (j=0; j<8; j++)
        begin
            MUXF7 muxf7_lo(.O(r0[j]), .I0(q0[j]), .I1(q1[j]), .S(d[6]));
            MUXF7 muxf7_hi(.O(r1[j]), .I0(q2[j]), .I1(q3[j]), .S(d[6]));
            MUXF8 muxf8_u(.O(q[j]), .I0(r0[j]), .I1(r1[j]), .S(d[7]));
        end
    endgenerate
    
endmodule

// The SBox transform is divided into 4 tables, each 64 entries by 8-bit.

// The "keep_hierarchy" attribute is there to prevent the tool from further
// optimizing the table, thereby forcing it to infer 8 LUT6 for each table.
// This allows the table output to feed the MUXF7 in the same slice, forcing
// the tool to pack the LUT6 and MUXFX into the same slice.

(* keep_hierarchy = "yes" *) module Sbox_table0(input [5:0] d, output [7:0] q);
	logic [7:0] p0;
 
	always_comb
		case (d)
			6'h00 : p0 <= 8'h63;
			6'h01 : p0 <= 8'h7c;
			6'h02 : p0 <= 8'h77;
			6'h03 : p0 <= 8'h7b;
			6'h04 : p0 <= 8'hf2;
			6'h05 : p0 <= 8'h6b;
			6'h06 : p0 <= 8'h6f;
			6'h07 : p0 <= 8'hc5;
			6'h08 : p0 <= 8'h30;
			6'h09 : p0 <= 8'h01;
			6'h0a : p0 <= 8'h67;
			6'h0b : p0 <= 8'h2b;
			6'h0c : p0 <= 8'hfe;
			6'h0d : p0 <= 8'hd7;
			6'h0e : p0 <= 8'hab;
			6'h0f : p0 <= 8'h76;
			6'h10 : p0 <= 8'hca;
			6'h11 : p0 <= 8'h82;
			6'h12 : p0 <= 8'hc9;
			6'h13 : p0 <= 8'h7d;
			6'h14 : p0 <= 8'hfa;
			6'h15 : p0 <= 8'h59;
			6'h16 : p0 <= 8'h47;
			6'h17 : p0 <= 8'hf0;
			6'h18 : p0 <= 8'had;
			6'h19 : p0 <= 8'hd4;
			6'h1a : p0 <= 8'ha2;
			6'h1b : p0 <= 8'haf;
			6'h1c : p0 <= 8'h9c;
			6'h1d : p0 <= 8'ha4;
			6'h1e : p0 <= 8'h72;
			6'h1f : p0 <= 8'hc0;
			6'h20 : p0 <= 8'hb7;
			6'h21 : p0 <= 8'hfd;
			6'h22 : p0 <= 8'h93;
			6'h23 : p0 <= 8'h26;
			6'h24 : p0 <= 8'h36;
			6'h25 : p0 <= 8'h3f;
			6'h26 : p0 <= 8'hf7;
			6'h27 : p0 <= 8'hcc;
			6'h28 : p0 <= 8'h34;
			6'h29 : p0 <= 8'ha5;
			6'h2a : p0 <= 8'he5;
			6'h2b : p0 <= 8'hf1;
			6'h2c : p0 <= 8'h71;
			6'h2d : p0 <= 8'hd8;
			6'h2e : p0 <= 8'h31;
			6'h2f : p0 <= 8'h15;
			6'h30 : p0 <= 8'h04;
			6'h31 : p0 <= 8'hc7;
			6'h32 : p0 <= 8'h23;
			6'h33 : p0 <= 8'hc3;
			6'h34 : p0 <= 8'h18;
			6'h35 : p0 <= 8'h96;
			6'h36 : p0 <= 8'h05;
			6'h37 : p0 <= 8'h9a;
			6'h38 : p0 <= 8'h07;
			6'h39 : p0 <= 8'h12;
			6'h3a : p0 <= 8'h80;
			6'h3b : p0 <= 8'he2;
			6'h3c : p0 <= 8'heb;
			6'h3d : p0 <= 8'h27;
			6'h3e : p0 <= 8'hb2;
			6'h3f : p0 <= 8'h75;
		endcase
         
	assign q = p0;
endmodule

(* keep_hierarchy = "yes" *) module Sbox_table1(input [5:0] d, output [7:0] q);
	logic [7:0] p1;
 
	always_comb
		case (d)
			6'h00 : p1 <= 8'h09;
			6'h01 : p1 <= 8'h83;
			6'h02 : p1 <= 8'h2c;
			6'h03 : p1 <= 8'h1a;
			6'h04 : p1 <= 8'h1b;
			6'h05 : p1 <= 8'h6e;
			6'h06 : p1 <= 8'h5a;
			6'h07 : p1 <= 8'ha0;
			6'h08 : p1 <= 8'h52;
			6'h09 : p1 <= 8'h3b;
			6'h0a : p1 <= 8'hd6;
			6'h0b : p1 <= 8'hb3;
			6'h0c : p1 <= 8'h29;
			6'h0d : p1 <= 8'he3;
			6'h0e : p1 <= 8'h2f;
			6'h0f : p1 <= 8'h84;
			6'h10 : p1 <= 8'h53;
			6'h11 : p1 <= 8'hd1;
			6'h12 : p1 <= 8'h00;
			6'h13 : p1 <= 8'hed;
			6'h14 : p1 <= 8'h20;
			6'h15 : p1 <= 8'hfc;
			6'h16 : p1 <= 8'hb1;
			6'h17 : p1 <= 8'h5b;
			6'h18 : p1 <= 8'h6a;
			6'h19 : p1 <= 8'hcb;
			6'h1a : p1 <= 8'hbe;
			6'h1b : p1 <= 8'h39;
			6'h1c : p1 <= 8'h4a;
			6'h1d : p1 <= 8'h4c;
			6'h1e : p1 <= 8'h58;
			6'h1f : p1 <= 8'hcf;
			6'h20 : p1 <= 8'hd0;
			6'h21 : p1 <= 8'hef;
			6'h22 : p1 <= 8'haa;
			6'h23 : p1 <= 8'hfb;
			6'h24 : p1 <= 8'h43;
			6'h25 : p1 <= 8'h4d;
			6'h26 : p1 <= 8'h33;
			6'h27 : p1 <= 8'h85;
			6'h28 : p1 <= 8'h45;
			6'h29 : p1 <= 8'hf9;
			6'h2a : p1 <= 8'h02;
			6'h2b : p1 <= 8'h7f;
			6'h2c : p1 <= 8'h50;
			6'h2d : p1 <= 8'h3c;
			6'h2e : p1 <= 8'h9f;
			6'h2f : p1 <= 8'ha8;
			6'h30 : p1 <= 8'h51;
			6'h31 : p1 <= 8'ha3;
			6'h32 : p1 <= 8'h40;
			6'h33 : p1 <= 8'h8f;
			6'h34 : p1 <= 8'h92;
			6'h35 : p1 <= 8'h9d;
			6'h36 : p1 <= 8'h38;
			6'h37 : p1 <= 8'hf5;
			6'h38 : p1 <= 8'hbc;
			6'h39 : p1 <= 8'hb6;
			6'h3a : p1 <= 8'hda;
			6'h3b : p1 <= 8'h21;
			6'h3c : p1 <= 8'h10;
			6'h3d : p1 <= 8'hff;
			6'h3e : p1 <= 8'hf3;
			6'h3f : p1 <= 8'hd2;
     		endcase
     	assign q = p1;
endmodule

(* keep_hierarchy = "yes" *) module Sbox_table2(input [5:0] d, output [7:0] q);
	logic [7:0] p2;
 
	always_comb
		case (d)
			6'h00 : p2 <= 8'hcd;
			6'h01 : p2 <= 8'h0c;
			6'h02 : p2 <= 8'h13;
			6'h03 : p2 <= 8'hec;
			6'h04 : p2 <= 8'h5f;
			6'h05 : p2 <= 8'h97;
			6'h06 : p2 <= 8'h44;
			6'h07 : p2 <= 8'h17;
			6'h08 : p2 <= 8'hc4;
			6'h09 : p2 <= 8'ha7;
			6'h0a : p2 <= 8'h7e;
			6'h0b : p2 <= 8'h3d;
			6'h0c : p2 <= 8'h64;
			6'h0d : p2 <= 8'h5d;
			6'h0e : p2 <= 8'h19;
			6'h0f : p2 <= 8'h73;
			6'h10 : p2 <= 8'h60;
			6'h11 : p2 <= 8'h81;
			6'h12 : p2 <= 8'h4f;
			6'h13 : p2 <= 8'hdc;
			6'h14 : p2 <= 8'h22;
			6'h15 : p2 <= 8'h2a;
			6'h16 : p2 <= 8'h90;
			6'h17 : p2 <= 8'h88;
			6'h18 : p2 <= 8'h46;
			6'h19 : p2 <= 8'hee;
			6'h1a : p2 <= 8'hb8;
			6'h1b : p2 <= 8'h14;
			6'h1c : p2 <= 8'hde;
			6'h1d : p2 <= 8'h5e;
			6'h1e : p2 <= 8'h0b;
			6'h1f : p2 <= 8'hdb;
			6'h20 : p2 <= 8'he0;
			6'h21 : p2 <= 8'h32;
			6'h22 : p2 <= 8'h3a;
			6'h23 : p2 <= 8'h0a;
			6'h24 : p2 <= 8'h49;
			6'h25 : p2 <= 8'h06;
			6'h26 : p2 <= 8'h24;
			6'h27 : p2 <= 8'h5c;
			6'h28 : p2 <= 8'hc2;
			6'h29 : p2 <= 8'hd3;
			6'h2a : p2 <= 8'hac;
			6'h2b : p2 <= 8'h62;
			6'h2c : p2 <= 8'h91;
			6'h2d : p2 <= 8'h95;
			6'h2e : p2 <= 8'he4;
			6'h2f : p2 <= 8'h79;
			6'h30 : p2 <= 8'he7;
			6'h31 : p2 <= 8'hc8;
			6'h32 : p2 <= 8'h37;
			6'h33 : p2 <= 8'h6d;
			6'h34 : p2 <= 8'h8d;
			6'h35 : p2 <= 8'hd5;
			6'h36 : p2 <= 8'h4e;
			6'h37 : p2 <= 8'ha9;
			6'h38 : p2 <= 8'h6c;
			6'h39 : p2 <= 8'h56;
			6'h3a : p2 <= 8'hf4;
			6'h3b : p2 <= 8'hea;
			6'h3c : p2 <= 8'h65;
			6'h3d : p2 <= 8'h7a;
			6'h3e : p2 <= 8'hae;
			6'h3f : p2 <= 8'h08;
        	endcase
        assign q = p2;
endmodule

(* keep_hierarchy = "yes" *) module Sbox_table3(input [5:0] d, output [7:0] q);
	logic [7:0] p3;
 
	always_comb
		case (d)
			6'h00 : p3 <= 8'hba;
			6'h01 : p3 <= 8'h78;
			6'h02 : p3 <= 8'h25;
			6'h03 : p3 <= 8'h2e;
			6'h04 : p3 <= 8'h1c;
			6'h05 : p3 <= 8'ha6;
			6'h06 : p3 <= 8'hb4;
			6'h07 : p3 <= 8'hc6;
			6'h08 : p3 <= 8'he8;
			6'h09 : p3 <= 8'hdd;
			6'h0a : p3 <= 8'h74;
			6'h0b : p3 <= 8'h1f;
			6'h0c : p3 <= 8'h4b;
			6'h0d : p3 <= 8'hbd;
			6'h0e : p3 <= 8'h8b;
			6'h0f : p3 <= 8'h8a;
			6'h10 : p3 <= 8'h70;
			6'h11 : p3 <= 8'h3e;
			6'h12 : p3 <= 8'hb5;
			6'h13 : p3 <= 8'h66;
			6'h14 : p3 <= 8'h48;
			6'h15 : p3 <= 8'h03;
			6'h16 : p3 <= 8'hf6;
			6'h17 : p3 <= 8'h0e;
			6'h18 : p3 <= 8'h61;
			6'h19 : p3 <= 8'h35;
			6'h1a : p3 <= 8'h57;
			6'h1b : p3 <= 8'hb9;
			6'h1c : p3 <= 8'h86;
			6'h1d : p3 <= 8'hc1;
			6'h1e : p3 <= 8'h1d;
			6'h1f : p3 <= 8'h9e;
			6'h20 : p3 <= 8'he1;
			6'h21 : p3 <= 8'hf8;
			6'h22 : p3 <= 8'h98;
			6'h23 : p3 <= 8'h11;
			6'h24 : p3 <= 8'h69;
			6'h25 : p3 <= 8'hd9;
			6'h26 : p3 <= 8'h8e;
			6'h27 : p3 <= 8'h94;
			6'h28 : p3 <= 8'h9b;
			6'h29 : p3 <= 8'h1e;
			6'h2a : p3 <= 8'h87;
			6'h2b : p3 <= 8'he9;
			6'h2c : p3 <= 8'hce;
			6'h2d : p3 <= 8'h55;
			6'h2e : p3 <= 8'h28;
			6'h2f : p3 <= 8'hdf;
			6'h30 : p3 <= 8'h8c;
			6'h31 : p3 <= 8'ha1;
			6'h32 : p3 <= 8'h89;
			6'h33 : p3 <= 8'h0d;
			6'h34 : p3 <= 8'hbf;
			6'h35 : p3 <= 8'he6;
			6'h36 : p3 <= 8'h42;
			6'h37 : p3 <= 8'h68;
			6'h38 : p3 <= 8'h41;
			6'h39 : p3 <= 8'h99;
			6'h3a : p3 <= 8'h2d;
			6'h3b : p3 <= 8'h0f;
			6'h3c : p3 <= 8'hb0;
			6'h3d : p3 <= 8'h54;
			6'h3e : p3 <= 8'hbb;
			6'h3f : p3 <= 8'h16;
        	endcase
        assign q = p3;
endmodule
