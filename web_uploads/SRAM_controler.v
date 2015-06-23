`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:28:22 08/05/2008 
// Design Name: 
// Module Name:    SRAM_controler 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//Defines
`define WR_COUNT 1 //Number of write cycles needed
`define RD_COUNT 4 //Number of read cycles needed
`define CNT_BITS 2 //number of bits needed for the counter to count the cycles
`define DEL 1 

module SRAM_controler(CLK, reset_n, as_n, rw, out_en, write_en, ack);
//INPUTS
    input CLK; //state machine clock
    input reset_n;//Synchronous reset
    input as_n;//address strobe
    input rw;//read/write command
	 
//OUTPUTS
    output out_en;//output enable to memory
    output write_en;//write enable to memory
    output ack;//Acknowledge signal to processor
	 
//SIGNAL DECLARATIONS
wire CLK;
wire reset_n;
wire as_n;
wire rw;
wire out_en;
wire write_en;
wire ack;
reg [1:0] state; //State machine
reg [`CNT_BITS-1:0] cnt;//cycle counter
//PARAMETERS
parameter[1:0] //state machine states
	IDLE = 0,
	WRITE = 1,
	READ = 2;
//ASSIGN STATEMENTS
					//creates the outputs from the states
assign out_en = state[1]; // output enable = LSB of state
assign write_en= state[0];//write enable = HSB of state
					//create the acknowledge combinatorially
assign #1 ack = ~as_n && ((~rw && (cnt == `WR_COUNT-1)) || (rw && (cnt == `RD_COUNT-1)));

//look at the rising edge of clock for state transitions 
always @(negedge CLK or negedge reset_n) begin
	if(~reset_n) begin
		state <= #1 IDLE;
		cnt <= #1 `CNT_BITS'h0;
	end
	else begin
		case (state) 
			IDLE: begin
			//Look for address strobe to begin the access
			if(~as_n)begin
				if(rw) begin
					//This is a read access
					state <= #1 READ;
				end
				else begin
					//This is a write access
					state <= #1 WRITE;
				end
			end
		end
			WRITE:begin
			if ((cnt == `WR_COUNT-1) || as_n) begin
			state <= #1 IDLE;
			cnt <= #1 `CNT_BITS'h0;
			end
			else
			cnt <= #1 cnt + 1;
		end
		   READ:begin
			if((cnt == `RD_COUNT-1) || as_n) begin
			 state <= #1 IDLE;
			 cnt <= #`DEL `CNT_BITS'h0;
			end
			else
			 cnt <= #`DEL cnt +1; 
			end
	endcase 		
 end
end
endmodule
