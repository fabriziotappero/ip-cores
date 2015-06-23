//////////////////////////////////////////////////////////////////////
////                                                              ////
//// 		 Generic Wishbone controller for		  ////
////	      	  Single-Port Synchronous RAM                     ////
////                                                              ////
////  This file is part of memory library available from          ////
////  http://www.opencores.org/cvsweb.shtml/minsoc/  		  ////
////                                                              ////
////  Description                                                 ////
////  This Wishbone controller connects to the wrapper of         ////
////  the single-port synchronous memory interface.               ////
////  Besides universal memory due to onchip_ram it provides a    ////
////  generic way to set the depth of the memory.                 ////
////                                                              ////
////  To Do:                                                      ////
////                                                              ////
////  Author(s):                                                  ////
////      - Raul Fajardo, rfajardo@gmail.com	                  ////
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
//// from http://www.gnu.org/licenses/lgpl.html                   ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// Revision History
//
// Revision 1.1 2009/10/02 16:49      fajardo
// Not using the oe signal (output enable) from 
// memories, instead multiplexing the outputs
// between the different instantiated blocks
//
//
// Revision 1.0 2009/08/18 15:15:00   fajardo
// Created interface and tested
//
`include "minsoc_defines.v"

module minsoc_onchip_ram_top ( 
  wb_clk_i, wb_rst_i, 
 
  wb_dat_i, wb_dat_o, wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i, 
  wb_stb_i, wb_ack_o, wb_err_o 
); 
 
// 
// Parameters 
//
parameter    adr_width = 13;		//Memory address width, is composed by blocks of aw_int, is not allowed to be less than 12
localparam    aw_int = 11;       	//11 = 2048
localparam    blocks = (1<<(adr_width-aw_int)); //generated memory contains "blocks" memory blocks of 2048x32 2048 depth x32 bit data

// 
// I/O Ports 
// 
input      wb_clk_i; 
input      wb_rst_i; 
 
// 
// WB slave i/f 
// 
input  [31:0]   wb_dat_i; 
output [31:0]   wb_dat_o; 
input  [31:0]   wb_adr_i; 
input  [3:0]    wb_sel_i; 
input      wb_we_i; 
input      wb_cyc_i; 
input      wb_stb_i; 
output     wb_ack_o; 
output     wb_err_o; 
 
// 
// Internal regs and wires 
// 
wire    we; 
wire [3:0]  be_i; 
wire [31:0]  wb_dat_o; 
reg    ack_we; 
reg    ack_re; 
// 
// Aliases and simple assignments 
// 
assign wb_ack_o = ack_re | ack_we; 
assign wb_err_o = wb_cyc_i & wb_stb_i & (|wb_adr_i[23:adr_width+2]);  // If Access to > (8-bit leading prefix ignored) 
assign we = wb_cyc_i & wb_stb_i & wb_we_i & (|wb_sel_i[3:0]); 
assign be_i = (wb_cyc_i & wb_stb_i) * wb_sel_i; 
 
// 
// Write acknowledge 
// 
always @ (negedge wb_clk_i or posedge wb_rst_i) 
begin 
if (wb_rst_i) 
    ack_we <= 1'b0; 
  else 
  if (wb_cyc_i & wb_stb_i & wb_we_i & ~ack_we) 
    ack_we <= #1 1'b1; 
  else 
    ack_we <= #1 1'b0; 
end 
 
// 
// read acknowledge 
// 
always @ (posedge wb_clk_i or posedge wb_rst_i) 
begin 
  if (wb_rst_i) 
    ack_re <= 1'b0; 
  else 
  if (wb_cyc_i & wb_stb_i & ~wb_err_o & ~wb_we_i & ~ack_re) 
    ack_re <= #1 1'b1; 
  else 
    ack_re <= #1 1'b0; 
end 

//Generic (multiple inputs x 1 output) MUX
localparam mux_in_nr = blocks;
localparam slices = adr_width-aw_int;
localparam mux_out_nr = blocks-1;

wire [31:0] int_dat_o[0:mux_in_nr-1];
wire [31:0] mux_out[0:mux_out_nr-1];

generate
genvar j, k;
	for (j=0; j<slices; j=j+1) begin : SLICES
		for (k=0; k<(mux_in_nr>>(j+1)); k=k+1) begin : MUX
			if (j==0) begin
				mux21 #
                (
                    .dw(32)
                ) 
                mux_int(
                    .sel( wb_adr_i[aw_int+2+j] ), 
                    .in1( int_dat_o[k*2] ),
				    .in2( int_dat_o[k*2+1] ), 
                    .out( mux_out[k] )
                );
			end
			else begin
				mux21 #
                (
                    .dw(32)
                ) 
                mux_int(
                    .sel( wb_adr_i[aw_int+2+j] ), 
				    .in1( mux_out[(mux_in_nr-(mux_in_nr>>(j-1)))+k*2] ), 
				    .in2( mux_out[(mux_in_nr-(mux_in_nr>>(j-1)))+k*2+1] ), 
				    .out( mux_out[(mux_in_nr-(mux_in_nr>>j))+k] )
                );
			end
		end
	end
endgenerate

//last output = total output
assign wb_dat_o = mux_out[mux_out_nr-1];

//(mux_in_nr-(mux_in_nr>>j)): 
//-Given sum of 2^i | i = x -> y series can be resumed to 2^(y+1)-2^x
//so, with this expression I'm evaluating how many times the internal loop has been run

wire [blocks-1:0] bank;
 
generate 
genvar i;
    for (i=0; i < blocks; i=i+1) begin : MEM

        assign bank[i] = wb_adr_i[adr_width+1:aw_int+2] == i;

        //BANK0
/*        minsoc_onchip_ram block_ram_0 ( 
            .clk(wb_clk_i), 
            .rst(wb_rst_i),
            .addr(wb_adr_i[aw_int+1:2]), 
            .di(wb_dat_i[7:0]), 
            .doq(int_dat_o[i][7:0]), 
            .we(we & bank[i]), 
            .oe(1'b1),
            .ce(be_i[0])
        ); 
*/
		  RAMB16_S9 block_ram_0(
				.CLK(wb_clk_i),
				.SSR(wb_rst_i),
				.ADDR(wb_adr_i[aw_int+1:2]),
				.DI(wb_dat_i[7:0]),
				.DIP(1'b0),
				.EN(be_i[0]),
				.WE(we & bank[i]),
				.DO(int_dat_o[i][7:0]),
				.DOP()
			);

/*
        minsoc_onchip_ram block_ram_1 ( 
            .clk(wb_clk_i), 
            .rst(wb_rst_i),
            .addr(wb_adr_i[aw_int+1:2]), 
            .di(wb_dat_i[15:8]), 
            .doq(int_dat_o[i][15:8]), 
            .we(we & bank[i]), 
            .oe(1'b1),
            .ce(be_i[1])
        );
*/		  
		  RAMB16_S9 block_ram_1(
				.CLK(wb_clk_i),
				.SSR(wb_rst_i),
				.ADDR(wb_adr_i[aw_int+1:2]),
				.DI(wb_dat_i[15:8]),
				.DIP(1'b0),
				.EN(be_i[1]),
				.WE(we & bank[i]),
				.DO(int_dat_o[i][15:8]),
				.DOP()
			);
/*
        minsoc_onchip_ram block_ram_2 ( 
            .clk(wb_clk_i), 
            .rst(wb_rst_i),
            .addr(wb_adr_i[aw_int+1:2]), 
            .di(wb_dat_i[23:16]), 
            .doq(int_dat_o[i][23:16]), 
            .we(we & bank[i]), 
            .oe(1'b1),
            .ce(be_i[2])
        ); 
*/
		  RAMB16_S9 block_ram_2(
				.CLK(wb_clk_i),
				.SSR(wb_rst_i),
				.ADDR(wb_adr_i[aw_int+1:2]),
				.DI(wb_dat_i[23:16]),
				.DIP(1'b0),
				.EN(be_i[2]),
				.WE(we & bank[i]),
				.DO(int_dat_o[i][23:16]),
				.DOP()
			);

/*
        minsoc_onchip_ram block_ram_3 ( 
            .clk(wb_clk_i), 
            .rst(wb_rst_i),
            .addr(wb_adr_i[aw_int+1:2]), 
            .di(wb_dat_i[31:24]), 
            .doq(int_dat_o[i][31:24]), 
            .we(we & bank[i]), 
            .oe(1'b1),
            .ce(be_i[3])
        ); 
*/
		  RAMB16_S9 block_ram_3(
				.CLK(wb_clk_i),
				.SSR(wb_rst_i),
				.ADDR(wb_adr_i[aw_int+1:2]),
				.DI(wb_dat_i[31:24]),
				.DIP(1'b0),
				.EN(be_i[3]),
				.WE(we & bank[i]),
				.DO(int_dat_o[i][31:24]),
				.DOP()
			);

    end
endgenerate

`ifdef BLOCK_RAM_INIT
`include "block_ram.init"
`endif

endmodule 

module mux21(sel,in1,in2,out);

parameter dw = 32;

input sel;
input [dw-1:0] in1, in2;
output reg [dw-1:0] out;

always @ (sel or in1 or in2)
begin
	case (sel)
		1'b0: out = in1;
		1'b1: out = in2;
	endcase
end

endmodule
