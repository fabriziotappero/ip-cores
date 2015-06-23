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

`define mem_init_file "uart-nocache.mif" //specific memory initalization file name, which can be intel hex(.hex) or Altera mif file 
                                         //if no initalization file used, give a name of "UNUSED"

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

`ifdef ALTERA_FPGA    //only for altera memory initialization

//2^adr_width x 32bit single-port ram.
altsyncram altsyncram_component (
				.wren_a (we),
				.clock0 (wb_clk_i),
				.byteena_a (be_i),
				.address_a (wb_adr_i[adr_width+1:2]),
				.data_a (wb_dat_i),
				.q_a (wb_dat_o),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.address_b (1'b1),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_b (1'b0));
	defparam
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.init_file = `mem_init_file,
		altsyncram_component.intended_device_family = "Stratix III",
		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.operation_mode = "SINGLE_PORT",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_reg_a = "UNREGISTERED",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		altsyncram_component.numwords_a = (1<<adr_width),
		altsyncram_component.widthad_a = adr_width,
		altsyncram_component.width_a = 32,
		altsyncram_component.byte_size = 8,
		altsyncram_component.width_byteena_a = 4;


`else               //other FPGA Type
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
				mux2 #
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
				mux2 #
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
        minsoc_onchip_ram block_ram_0 ( 
            .clk(wb_clk_i), 
            .rst(wb_rst_i),
            .addr(wb_adr_i[aw_int+1:2]), 
            .di(wb_dat_i[7:0]), 
            .doq(int_dat_o[i][7:0]), 
            .we(we & bank[i]), 
            .oe(1'b1),
            .ce(be_i[0])
        ); 


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

    end
endgenerate
`endif

endmodule 

module mux2(sel,in1,in2,out);

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
