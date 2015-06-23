/*********************************************************
 MODULE:		Sub Level DMA Internal Register Block

 FILE NAME:	dma_internal_reg.v
 VERSION:	1.0
 DATE:		May 20th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the sub level RTL code of DMA Controller Internal
 Register verilog code.
 
 It will instantiate the following blocks in the ASIC:


 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps
 
// TOP MODULE
module dma_internal_reg(// Inputs
								reset,
								clk0,
								dma_host_cmd,
								dma_host_addr,
								dma_host_datain,
								dma_wr_addr_cnt,
								dma_rd_addr_cnt,
								fifo_rd,
								fifo_wr,
								// Output
								dma_host_dataout,
								done,
								go,
								busy,
								fifo_wr_enb,
								fifo_rd_enb,
								wr_inc1,
								wr_inc2,
								wr_inc4,
								rd_inc1,
								rd_inc2,
								rd_inc4
								);


// Parameter
`include        "parameter.v"

// Inputs
input reset;
input clk0;
input [padd_size - 1 : 0]dma_host_addr;
input [cmd_size  - 1 : 0]dma_host_cmd;
input [data_size - 1 : 0]dma_host_datain;
input [dma_fifo_depth - 1 : 0]dma_wr_addr_cnt;
input [dma_fifo_depth - 1 : 0]dma_rd_addr_cnt;
input fifo_rd;
input fifo_wr;


// Outputs
output [data_size - 1 : 0]dma_host_dataout;
output done;
output go;
output busy;
output fifo_wr_enb;
output fifo_rd_enb;
output wr_inc1;
output wr_inc2;
output wr_inc4;
output rd_inc1;
output rd_inc2;
output rd_inc4;


// Signal Declarations
wire reset;
wire clk0;
wire [padd_size - 1 : 0]dma_host_addr;
wire [cmd_size  - 1 : 0]dma_host_cmd;
wire [data_size - 1 : 0]dma_host_datain;
wire [dma_fifo_depth - 1 : 0]dma_wr_addr_cnt;
wire [dma_fifo_depth - 1 : 0]dma_rd_addr_cnt;
wire fifo_rd;
wire fifo_wr;


reg [data_size - 1 : 0]dma_host_dataout;


// Internal signals
wire [dma_reg_width - 1 : 0]dma_register0;
wire [dma_reg_width - 1 : 0]dma_register1;
wire [dma_reg_width - 1 : 0]dma_register2;
wire [dma_reg_width - 1 : 0]dma_register3;
wire [dma_reg_width - 1 : 0]dma_register6;


wire wr_inc1;
wire wr_inc2;
wire wr_inc4;

wire rd_inc1;
wire rd_inc2;
wire rd_inc4;

wire done;
wire busy;
wire reop;
wire weop;
wire len;

wire byte;
wire hw;
wire word;
wire go;
wire i_en;
wire reen;
wire ween;
wire leen;
wire rcon;
wire wcon;

wire fifo_wr_enb;
wire fifo_rd_enb;

/***************** Internal Register of DMA configuration *******************/
reg [dma_reg_width - 1 : 0] dma_register [dma_reg_depth - 1 : 0];

// Assignment statments

// Increment the write/read counter according to byte, half word or word mode
assign wr_inc1  = 	(~(dma_register0 == 32'h0) &
							~(dma_register2 == 32'h0) & 
							(go == 1'b1) &
						 	(word == 1'b0) &
						 	(hw == 1'b0) &
						 	(byte == 1'b1));

assign wr_inc2  = 	(~(dma_register0 == 32'h0) &
							~(dma_register2 == 32'h0) & 
							(go == 1'b1) &
						 	(word == 1'b0) &
						 	(hw == 1'b1) &
						 	(byte == 1'b0));

assign wr_inc4  = 	(~(dma_register0 == 32'h0) &
							~(dma_register2 == 32'h0) & 
							(go == 1'b1) &
						 	(word == 1'b1) &
						 	(hw == 1'b0) &
						 	(byte == 1'b0));


assign rd_inc1  = 	(~(dma_register0 == 32'h0) &
							~(dma_register1 == 32'h0) & 
							(go == 1'b1) &
						 	(word == 1'b0) &
						 	(hw == 1'b0) &
						 	(byte == 1'b1));

assign rd_inc2  = 	(~(dma_register0 == 32'h0) &
							~(dma_register1 == 32'h0) & 
							(go == 1'b1) &
						 	(word == 1'b0) &
						 	(hw == 1'b1) &
						 	(byte == 1'b0));

assign rd_inc4  = 	(~(dma_register0 == 32'h0) &
							~(dma_register1 == 32'h0) & 
							(go == 1'b1) &
						 	(word == 1'b1) &
						 	(hw == 1'b0) &
						 	(byte == 1'b0));


assign fifo_wr_enb = (~(dma_register3 == 32'h0) &
							~(dma_register2 == 32'h0) &
							(go == 1'b1));


assign fifo_rd_enb = (~(dma_register3 == 32'h0) &
							~(dma_register1 == 32'h0) &
							(go == 1'b1));

assign dma_register0 = dma_register[0];
assign dma_register1 = dma_register[1];
assign dma_register2 = dma_register[2];
assign dma_register3 = dma_register[3];
assign dma_register6 = dma_register[6];


// Bitwise decoding of status register
assign done = dma_register0[0] & 32'd1;
assign busy = dma_register0[1] & 32'd1;
assign reop = dma_register0[2] & 32'd1;
assign weop = dma_register0[3] & 32'd1;
assign len  = dma_register0[4] & 32'd1;

// Bitwise decoding of control register
assign byte = dma_register6[0] & 32'd1;
assign hw   = dma_register6[1] & 32'd1;
assign word = dma_register6[2] & 32'd1;
assign go   = dma_register6[3] & 32'd1;
assign i_en = dma_register6[4] & 32'd1;
assign reen = dma_register6[5] & 32'd1;
assign ween = dma_register6[6] & 32'd1;
assign leen = dma_register6[7] & 32'd1;
assign rcon = dma_register6[8] & 32'd1;
assign wcon = dma_register6[9] & 32'd1;


// Access to internal register by CPU address and command signals (write/read)
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		dma_host_dataout <= 32'h0;
		dma_register[0] <= 32'h0;
		dma_register[1] <= 32'h0;
		dma_register[2] <= 32'h0;
		dma_register[3] <= 32'h0;
		dma_register[4] <= 32'h0;
		dma_register[5] <= 32'h0;
		dma_register[6] <= 32'h0;
		dma_register[7] <= 32'h0;
	end
	else
	begin
		if(dma_host_cmd == 3'b010)	// Write from Host to DMA internal Registers
		begin
			case (dma_host_addr)
			
				24'h080000:	dma_register[0] <= dma_host_datain;	// Status Register
				24'h080001:	dma_register[1] <= dma_host_datain;	// Read Master Start Address
				24'h080002:	dma_register[2] <= dma_host_datain;	// Write Master Start Address
				24'h080003:	dma_register[3] <= dma_host_datain;	// Length in Bytes
				24'h080004:	dma_register[4] <= dma_host_datain;	// Reserved
				24'h080005:	dma_register[5] <= dma_host_datain; // Reserved
				24'h080006:	dma_register[6] <= dma_host_datain;	// Control
				24'h080007:	dma_register[7] <= dma_host_datain; // Reserved
			endcase
		end
		else
		if(dma_host_cmd == 3'b001)	// Read from DMA internal Registers to Host
		begin
			case (dma_host_addr)
			
				24'h080000:	dma_host_dataout <= dma_register[0];
				24'h080001:	dma_host_dataout <= dma_register[1];
				24'h080002:	dma_host_dataout <= dma_register[2];
				24'h080003:	dma_host_dataout <= dma_register[3];
				24'h080004:	dma_host_dataout <= dma_register[4];
				24'h080005:	dma_host_dataout <= dma_register[5];
				24'h080006:	dma_host_dataout <= dma_register[6];
				24'h080007:	dma_host_dataout <= dma_register[7];
			endcase
		end

	if(((reop == 1'b1) || (weop == 1'b1) || (len == 32'h0)) && (i_en))
		dma_register[0] <= dma_register[0] | 32'h1;				// Set the done pin

	if(~(len == 32'h0))
		dma_register[0] <= dma_register[0] | 32'h2;				// Set the busy pin

	if((reen == 1'b1) && (len == 1'b1))
		dma_register[0] <= dma_register[0] | 32'h4;				// Set the reop pin

	if((ween == 1'b1) && (len == 1'b1))
		dma_register[0] <= dma_register[0] | 32'h8;				// Set the weop pin

	if((dma_register3 == dma_register2) || (dma_register3 == dma_register1)) 
		dma_register[0] <= dma_register[0] | 32'hf;				// Set the len pin

	if(fifo_rd == 1'b1)
		dma_register[3] <= dma_register[3] - dma_wr_addr_cnt;

   if(fifo_wr == 1'b1)
		dma_register[3] <= dma_register[3] - dma_rd_addr_cnt;

	end	
end

endmodule
