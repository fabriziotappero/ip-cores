//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : nova_tb.v
// Generated : March 13,2006
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Testbench for nova
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module nova_tb;
	
	reg clk;
	reg reset_n;
	reg pin_disable_DF;
	reg freq_ctrl0;
	reg freq_ctrl1;
	
	wire BitStream_ram_ren;
	wire [16:0] BitStream_ram_addr; 
	wire [15:0] BitStream_buffer_input;
	wire [5:0] pic_num;
	wire [6:0] mb_num;
	
	wire [13:0] ext_frame_RAM0_addr;
	wire [31:0] ext_frame_RAM0_data;
	wire [13:0] ext_frame_RAM1_addr;
	wire [31:0] ext_frame_RAM1_data;
	wire [31:0] dis_frame_RAM_din;
	
	wire [15:0] temp;
	assign temp = dis_frame_RAM_din[15:0];
	
	//for debug only
	wire slice_header_s6;
	
	Beha_BitStream_ram Beha_BitStream_ram (
		.clk(clk),
		.BitStream_ram_ren(BitStream_ram_ren),
		.BitStream_ram_addr(BitStream_ram_addr),
		.BitStream_ram_data(BitStream_buffer_input)
		);
	ext_frame_RAM0_wrapper ext_frame_RAM0_wrapper (
		.clk(clk),
		.reset_n(reset_n),
		.ext_frame_RAM0_cs_n(ext_frame_RAM0_cs_n),
		.ext_frame_RAM0_wr(ext_frame_RAM0_wr),
		.ext_frame_RAM0_addr(ext_frame_RAM0_addr),
		.dis_frame_RAM_din(dis_frame_RAM_din),
		.ext_frame_RAM0_data(ext_frame_RAM0_data),
		.pic_num(pic_num),
		.slice_header_s6(slice_header_s6)
		);
	ext_frame_RAM1_wrapper ext_frame_RAM1_wrapper (
		.clk(clk),
		.reset_n(reset_n),
		.ext_frame_RAM1_cs_n(ext_frame_RAM1_cs_n),
		.ext_frame_RAM1_wr(ext_frame_RAM1_wr),
		.ext_frame_RAM1_addr(ext_frame_RAM1_addr),
		.dis_frame_RAM_din(dis_frame_RAM_din),
		.ext_frame_RAM1_data(ext_frame_RAM1_data),
		.pic_num(pic_num),
		.slice_header_s6(slice_header_s6)
		);
	nova nova (
		.clk(clk),
		.reset_n(reset_n),
		.freq_ctrl0(freq_ctrl0),
		.freq_ctrl1(freq_ctrl1),
		.BitStream_buffer_input(BitStream_buffer_input),
		.BitStream_ram_ren(BitStream_ram_ren),
		.BitStream_ram_addr(BitStream_ram_addr),
		.pic_num(pic_num),
		.pin_disable_DF(pin_disable_DF),
		.ext_frame_RAM0_cs_n(ext_frame_RAM0_cs_n),
		.ext_frame_RAM0_wr(ext_frame_RAM0_wr),
		.ext_frame_RAM0_addr(ext_frame_RAM0_addr),
		.ext_frame_RAM0_data(ext_frame_RAM0_data),
		.ext_frame_RAM1_cs_n(ext_frame_RAM1_cs_n),
		.ext_frame_RAM1_wr(ext_frame_RAM1_wr),
		.ext_frame_RAM1_addr(ext_frame_RAM1_addr),
		.ext_frame_RAM1_data(ext_frame_RAM1_data), 
		.dis_frame_RAM_din(dis_frame_RAM_din),
		.slice_header_s6(slice_header_s6)
      	);
		
	initial
		begin
			clk = 1'b1;
			reset_n = 1'b1;
			pin_disable_DF = 1'b0;
			freq_ctrl0 = 1'b0;
			freq_ctrl1 = 1'b1;
			#1100 reset_n = 1'b0;
			#1000 reset_n = 1'b1;
		end

	always 
		#340 clk = ~clk;

endmodule
