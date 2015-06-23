`timescale 1ns / 1ps
/*
	Wishbone slave 
	(Verilog 2001)
*/
module lcd_wishbone_slave(
    input clk_i,
    input rst_i,
    input [1:0] wb_adr_i,
    input [7:0] wb_dat_i,
    output [7:0] wb_dat_o,
    input wb_we_i,
    input SEL_I0,
    input wb_stb_i,
    output wb_ack_o,
    input CYC_I
    );


endmodule
