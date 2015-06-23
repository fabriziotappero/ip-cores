/*********************************************************
 MODULE:		Sub Level Timer Device

 FILE NAME:	timer.v
 VERSION:	1.0
 DATE:		May 21th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the top level RTL code of Timer verilog code.
 
 It will instantiate the following blocks in the ASIC:


 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps
 
// TOP MODULE
module timer(// Inputs
					reset,
					clk0,
					timer_host_datain,
					timer_cmd,
					timer_addr,
					// Outputs
					timer_host_dataout,
					timer_irq
					);


// Parameter
`include        "parameter.v"

// Inputs
input reset;
input clk0;
input [data_size - 1 : 0]timer_host_datain;
input [cmd_size - 1 : 0]timer_cmd;
input [padd_size - 1 : 0]timer_addr;

// Outputs
output [data_size - 1 : 0]timer_host_dataout;
output timer_irq;

 
// Signal Declarations
wire reset;
wire clk0;
wire [data_size - 1 : 0]timer_host_datain;
wire [cmd_size - 1 : 0]timer_cmd;
wire [padd_size - 1 : 0]timer_addr;

wire [data_size - 1 : 0]timer_host_dataout;
reg timer_irq;

reg [data_size - 1 : 0]timer_reg_dataout;
reg [timer_size - 1 : 0]timer;

wire [timer_reg_width - 1 : 0] timer_register0;
wire [timer_reg_width - 1 : 0] timer_register1;
wire [timer_reg_width - 1 : 0] timer_register2;
wire [timer_reg_width - 1 : 0] timer_register3;

wire timed_out;
wire running;
wire irq_enb;
wire continuous;
wire timer_start;
wire timer_stop;

// Internal Registers

/***************** Internal Register of Timer configuration *******************/
reg [timer_reg_width - 1 : 0] timer_register [timer_reg_depth - 1 : 0];


// Assignment statments
assign timer_host_dataout = timer_reg_dataout;

// Internal Register Mapping
assign timer_register0 = timer_register[0]; 	// Status Register
assign timer_register1 = timer_register[1];	// Control Register
assign timer_register2 = timer_register[2];	// Time-Out Period
assign timer_register3 = timer_register[3];	// Snapshot Register

// Status Register
assign timed_out   = timer_register0[0];
assign running     = timer_register0[1];

// Control Register
assign irq_enb     = timer_register1[0];
assign continuous  = timer_register1[1];
assign timer_start = timer_register1[2];
assign timer_stop  = timer_register1[3];


// Setting the internal Registers by the Host (CPU)
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		timer_reg_dataout  <= 32'h0;
		timer_register[0] <= 32'h0;
		timer_register[1] <= 32'h0;
		timer_register[2] <= 32'h0;
		timer_register[3] <= 32'h0;
	end
	else
	begin
		if(timer_cmd == 3'b010)
		begin
			case(timer_addr)
				24'h080020: timer_register[0] <= timer_host_datain;		// Status Register
				24'h080021: timer_register[1] <= timer_host_datain;		// Control Register
				24'h080022: timer_register[2] <= timer_host_datain;		// Time-Out Period
				24'h080023: timer_register[3] <= timer_host_datain;		// Timer Snapshot
			endcase
		end
		else
		if(timer_cmd == 3'b001)
		begin
			case(timer_addr)
				24'h080020: timer_reg_dataout <= timer_register[0];
				24'h080021: timer_reg_dataout <= timer_register[1];
				24'h080022: timer_reg_dataout <= timer_register[2];
				24'h080023: timer_reg_dataout <= timer_register[3];
			endcase
		end

	// Set the Status Register timed_out bit to one if timer is in continuous mode
 	// and timer reached the maximum	time set by CPU
	if((continuous == 1'b1) && (timer == timer_register2))
		timer_register[0] <= timer_register0 & 32'h1;
	else
		timer_register[0] <= timer_register0 & 32'h0;

	// Set the Status Register running bit to one if the timer started and not reached
	// the maximum value
	if((timer_start == 1'b1) && (timer_irq == 1'b0))
		timer_register[0] <= timer_register0 & 32'h2;
	else
		timer_register[0] <= timer_register0 & 32'h0;

	// Set the timer snapshot to current value of timer for CPU to evaluate
	timer_register[3] <= timer;

	end
end


// 32-bit Timer and it's control signals base on the internal register settings
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		timer <= 32'h0;
	end
	else
	begin
		// Star Counting
		if((timer_start == 1'b1) && (timer_stop == 1'b0))
			timer <= timer + 1;
		else
			timer <= timer;
		// Stop Counting
		if(timer_stop == 1'b1)
			timer <= timer;
		// Set time to begin (zero) value
		if((continuous == 1'b1) && (timer == timer_register2))
			timer <= 32'h0;
		// Set the irq pin if the irq_enb is one and timmer reaches the maximum
		if((irq_enb == 1'b1) && (timer == timer_register2))
			timer_irq <= 1'b1;
		else
			timer_irq <= 1'b0;

	end
end


endmodule
