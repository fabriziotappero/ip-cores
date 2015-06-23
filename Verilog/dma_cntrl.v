/*********************************************************
 MODULE:		Sub Level Direct Memory Access Controller

 FILE NAME:	dma_cntrl.v
 VERSION:	1.0
 DATE:		May 7th, 2002	
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the top level RTL code of DMA Controller verilog code.
 
 It will instantiate the following blocks in the ASIC:

 1)	DMA FIFO
 2)	DMA Internal Registers

 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps
 
// TOP MODULE
module dma_cntrl(	// Inputs
						reset,
						clk0,
						dma_host_addr,
						dma_host_cmd,
						dma_host_datain,
						dma_bus_grant,
						dma_rd_datain,
						dma_wr_datain,
						// Output
						dma_host_dataout,
						dma_irq,
						dma_bus_req,
						dma_rd_addr,
						dma_wr_addr,
						dma_wr_dataout,
						dma_rd_cmd,
						dma_busy,
						uart_cs,
						uart_rd,
						uart_wr,
						dma_rd_dataout
						);

// Parameter
`include "parameter.v"

// Inputs
input reset;
input clk0;
input [padd_size - 1 : 0]dma_host_addr;
input [cmd_size  - 1 : 0]dma_host_cmd;
input [data_size - 1 : 0]dma_host_datain;
input dma_bus_grant;
input [fifo_size - 1 : 0]dma_rd_datain;
input [fifo_size - 1 : 0]dma_wr_datain;

// Outputs
output [data_size - 1 : 0]dma_host_dataout;
output dma_irq;
output dma_bus_req;
output [padd_size - 1 : 0]dma_rd_addr;
output [padd_size - 1 : 0]dma_wr_addr;
output [fifo_size - 1 : 0]dma_wr_dataout;
output [cmd_size  - 1 : 0]dma_rd_cmd;
output dma_busy;
output uart_cs;
output uart_rd;
output uart_wr;
output [fifo_size - 1 : 0]dma_rd_dataout;

// Signal Declarations
wire reset;
wire clk0;
wire [padd_size - 1 : 0]dma_host_addr;
wire [cmd_size  - 1 : 0]dma_host_cmd;
wire [data_size - 1 : 0]dma_host_datain;
wire dma_bus_grant;
wire [fifo_size - 1 : 0]dma_rd_datain;
wire [fifo_size - 1 : 0]dma_wr_datain;

wire [data_size - 1 : 0]dma_host_dataout;
wire dma_irq;
wire dma_bus_req;
reg [padd_size - 1 : 0]dma_rd_addr;
reg [padd_size - 1 : 0]dma_wr_addr;
reg [fifo_size - 1 : 0]dma_wr_dataout;
reg [cmd_size  - 1 : 0]dma_rd_cmd;
reg [fifo_size - 1 : 0]dma_rd_dataout;
wire [fifo_size - 1 : 0]wdma_rd_dataout;
wire dma_busy;

reg uart_cs;
reg uart_rd;
reg uart_wr;

// Internal wire and reg Signals
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

reg fifo_rd;
reg fifo_wr;

reg [dma_fifo_depth - 1 : 0]dma_wr_addr_cnt;
reg [dma_fifo_depth - 1 : 0]dma_rd_addr_cnt;

wire [dma_fifo_depth - 1 : 0]wdma_wr_addr_cnt;
wire [dma_fifo_depth - 1 : 0]wdma_rd_addr_cnt;


wire wr_inc1;
wire wr_inc2;
wire wr_inc4;

wire rd_inc1;
wire rd_inc2;
wire rd_inc4;

wire fifo_wr_enb;
wire fifo_rd_enb;

wire [fifo_size - 1 : 0]fifo_in_data;
wire [fifo_size - 1 : 0]fifo_out_data;

reg fifo_sel_in;
reg fifo_sel_out;


// Assignment statments
assign dma_irq = done;
assign dma_bus_req = go;
assign dma_busy = busy;
assign wdma_wr_addr_cnt = dma_wr_addr_cnt;
assign wdma_rd_addr_cnt = dma_rd_addr_cnt;

// Muxing the fifo for bidirection functionality
assign fifo_in_data = fifo_sel_in ? dma_wr_datain : dma_rd_datain;

/********************************** FIFO Instantiation ******************************/

dma_fifo dma_fifo0 (// Input
							.clk(clk0),
							.sinit(reset),
							.din(fifo_in_data),
							.wr_en(fifo_wr),
							.rd_en(fifo_rd),
							// Output
							.dout(fifo_out_data),
							.full(),
							.empty()
							);


dma_internal_reg dma_internal_reg0(// Input
											.reset(reset),
											.clk0(clk0),
											.dma_host_cmd(dma_host_cmd),
											.dma_host_addr(dma_host_addr),
											.dma_host_datain(dma_host_datain),
											.dma_rd_addr_cnt(wdma_rd_addr_cnt),
											.dma_wr_addr_cnt(wdma_wr_addr_cnt),
											.fifo_rd(fifo_rd),
											.fifo_wr(fifo_wr),
											// Output
											.dma_host_dataout(dma_host_dataout),
											.done(done),
											.go(go),
											.busy(busy),
											.fifo_wr_enb(fifo_wr_enb),
											.fifo_rd_enb(fifo_rd_enb),
											.wr_inc1(wr_inc1),
											.wr_inc2(wr_inc2),
											.wr_inc4(wr_in4),
											.rd_inc1(rd_inc1),
											.rd_inc2(rd_inc2),
											.rd_inc4(rd_inc4)
											);


// Set the Demultiplexer for the FIFO output port
always @(reset or fifo_sel_out or dma_bus_grant or fifo_out_data)
begin
	if(reset == 1'b1)
	begin
		dma_rd_dataout <= 8'h0;
		dma_wr_dataout <= 8'h0;
	end
	else
	if((dma_bus_grant == 1'b1) && (fifo_sel_out == 1'b1))
		dma_wr_dataout <= fifo_out_data;
	else
	if((dma_bus_grant == 1'b0) && (fifo_sel_out == 1'b0))
			dma_rd_dataout <= fifo_out_data;
end


// Increment the DMA Write Slave Address
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
		dma_wr_addr_cnt <= 32'h0;
	else
	if (wr_inc1 == 1'b1)
		dma_wr_addr_cnt <= dma_wr_addr_cnt + 1;
	else
	if (wr_inc2 == 1'b1)
		dma_wr_addr_cnt <= dma_wr_addr_cnt + 2;
	else
	if (wr_inc4 == 1'b1)
		dma_wr_addr_cnt <= dma_wr_addr_cnt + 4;
	else
		dma_wr_addr_cnt <= dma_wr_addr_cnt;
end


// Increment the DMA Read Slave Address
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
		dma_rd_addr_cnt <= 32'h0;
	else
	if (rd_inc1 == 1'b1)
		dma_rd_addr_cnt <= dma_rd_addr_cnt + 1;
	else
	if (rd_inc2 == 1'b1)
		dma_rd_addr_cnt <= dma_rd_addr_cnt + 2;
	else
	if (rd_inc4 == 1'b1)
		dma_rd_addr_cnt <= dma_rd_addr_cnt + 4;
	else
		dma_rd_addr_cnt <= dma_rd_addr_cnt;
end


// Generating FIFO read and write enable signals
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		fifo_wr <= 1'b0;
		fifo_rd <= 1'b0;
		fifo_sel_in  <= 1'b0;
		fifo_sel_out <= 1'b0;
	end
	else
	begin
		if((fifo_wr_enb == 1'b1) && (dma_bus_req == 1'b1))
		begin
			fifo_sel_in <= 1'b1;
			fifo_wr <= 1'b1;
		end
		else
		if((fifo_wr_enb == 1'b1) && (dma_bus_req == 1'b0))
		begin
			fifo_sel_in <= 1'b0;
			fifo_wr <= 1'b1;
		end
		else
		begin
			fifo_sel_in <= 1'b0;
			fifo_wr <= 1'b0;
		end

		if((fifo_rd_enb == 1'b1) && (dma_bus_req == 1'b1))
		begin
			fifo_sel_out <= 1'b0;
			fifo_rd <= 1'b1;
		end
		else
		if((fifo_rd_enb == 1'b1) && (dma_bus_req == 1'b0))
		begin
			fifo_sel_out <= 1'b1;
			fifo_rd <= 1'b1;
		end
		else
		begin
			fifo_sel_out <= 1'b0;
			fifo_rd <= 1'b0;
		end
	end
end


always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		dma_wr_addr <= 24'h0;
		dma_rd_addr <= 24'h0;
		dma_rd_cmd <= 3'h0;
		uart_cs <= 1'b0;
		uart_rd <= 1'b0;
		uart_wr <= 1'b0;
	end
	else
	begin
		dma_wr_addr <= dma_wr_addr_cnt;
		if(ween == 1'b1)
		begin
			uart_cs <= 1'b1;
			uart_wr <= 1'b1;
			dma_rd_cmd <= 3'b010;
			dma_wr_addr <= dma_wr_addr_cnt;
		end
		else
		if(reen == 1'b1)
		begin
			uart_cs <= 1'b1;
			uart_rd <= 1'b1;
			dma_rd_cmd <= 3'b001;
			dma_rd_addr <= dma_rd_addr_cnt;
		end
	end
end

endmodule
