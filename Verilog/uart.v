/*********************************************************
 MODULE:		Sub Level UART Device

 FILE NAME:	uart.v
 VERSION:	1.0
 DATE:		May 14th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the top level RTL code of UART verilog code.
 
 It will instantiate the following blocks in the ASIC:


 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps
 
// TOP MODULE
module uart(// Inputs
				reset,
				clk0,
				uart_addr,
				uart_host_addr,
			   uart_host_cmd,
				uart_cmd,
				uart_host_datain,
				uart_cs,
				uart_rd,
				uart_wr,
				ser_rxd,
				uart_datain,
				// Outputs
				ser_txd,
				uart_host_dataout,
				uart_dataout
				);


// Parameter
`include        "parameter.v"

// Inputs
input reset;
input clk0;
input [padd_size - 1 : 0]uart_addr;
input [padd_size - 1 : 0]uart_host_addr;
input [cmd_size - 1 : 0]uart_host_cmd;
input [cmd_size - 1 : 0]uart_cmd;
input [data_size - 1 : 0]uart_host_datain;
input uart_cs;
input uart_rd;
input uart_wr;
input ser_rxd;
input [Byte_size - 1 : 0]uart_datain;

// Outputs
output ser_txd;
output [data_size - 1 : 0]uart_host_dataout;
output [Byte_size - 1 : 0]uart_dataout;

 
// Signal Declarations
wire reset;
wire clk0;
wire [padd_size - 1 : 0]uart_addr;
wire [padd_size - 1 : 0]uart_host_addr;
wire [cmd_size - 1 : 0]uart_host_cmd;
wire [cmd_size - 1 : 0]uart_cmd;
wire [data_size - 1 : 0]uart_host_datain;
wire uart_cs;
wire uart_rd;
wire uart_wr;
wire ser_rxd;
wire [Byte_size - 1 : 0]uart_datain;
 
reg ser_txd;
reg [data_size - 1 : 0]uart_host_dataout;
wire [Byte_size - 1 : 0]uart_dataout;
reg [Byte_size - 1 : 0]ruart_dataout;

// Internal Registers
reg [Byte_size - 1 : 0]uart_reg_dataout;


reg [Byte_size -1 : 0]shift_reg_in;
reg [Byte_size -1 : 0]shift_reg_out;
reg [uart_cnt_size - 1 : 0]serin_cnt;
reg [uart_cnt_size - 1 : 0]serout_cnt;

reg byte_in;
reg byte_out;

// Assignment statments
assign uart_dataout = ruart_dataout;

/***************** Internal Register of Uart configuration *******************/
reg [uart_reg_width - 1 : 0] uart_register [uart_reg_depth - 1 : 0];


// Circuit for internal Register
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		uart_host_dataout <= 32'h0;
		uart_register[0] <= 32'h0;
		uart_register[1] <= 32'h0;
		uart_register[2] <= 32'h0;
		uart_register[3] <= 32'h0;
		uart_register[4] <= 32'h0;
		uart_register[5] <= 32'h0;
		uart_register[6] <= 32'h0;
		uart_register[7] <= 32'h0;
	end
	else
	begin
		if(uart_host_cmd == 3'b010)
		begin
			case(uart_host_addr)
				24'h080024: uart_register[0] <= uart_host_datain;
				24'h080025: uart_register[1] <= uart_host_datain;
				24'h080026: uart_register[2] <= uart_host_datain;
				24'h080027: uart_register[3] <= uart_host_datain;
				24'h080028: uart_register[4] <= uart_host_datain;
				24'h080029: uart_register[5] <= uart_host_datain;
				24'h08002A: uart_register[6] <= uart_host_datain;
				24'h08002B: uart_register[7] <= uart_host_datain;
			endcase
		end
		else
		if(uart_host_cmd == 3'b001)
		begin
			case(uart_host_addr)
				24'h080024: uart_host_dataout <= uart_register[0];
				24'h080025: uart_host_dataout <= uart_register[1];
				24'h080026: uart_host_dataout <= uart_register[2];
				24'h080027: uart_host_dataout <= uart_register[3];
				24'h080028: uart_host_dataout <= uart_register[4];
				24'h080029: uart_host_dataout <= uart_register[5];
				24'h08002A: uart_host_dataout <= uart_register[6];
				24'h08002B: uart_host_dataout <= uart_register[7];
			endcase
		end
	end

end


// Circuit for reciever side
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		shift_reg_in  <= 8'h0;
	end
	else
	if((uart_wr == 1'b1) && (uart_rd == 1'b0) && (byte_in == 1'b0))
	begin
		shift_reg_in[7] <= shift_reg_in[6];
		shift_reg_in[6] <= shift_reg_in[5];
		shift_reg_in[5] <= shift_reg_in[4];
		shift_reg_in[4] <= shift_reg_in[3];
		shift_reg_in[3] <= shift_reg_in[2];
		shift_reg_in[2] <= shift_reg_in[1];
		shift_reg_in[1] <= shift_reg_in[0];
		shift_reg_in[0] <= ser_rxd;
	end
	else
		shift_reg_in <= shift_reg_in;
end

	
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
		ruart_dataout <= 8'h0;
	else
	if((uart_wr == 1'b1) && (uart_rd == 1'b0) && (byte_in == 1'b1))
	begin
	  ruart_dataout[0] <= shift_reg_in[0];		
	  ruart_dataout[1] <= shift_reg_in[1];
	  ruart_dataout[2] <= shift_reg_in[2];
	  ruart_dataout[3] <= shift_reg_in[3];
	  ruart_dataout[4] <= shift_reg_in[4];
	  ruart_dataout[5] <= shift_reg_in[5];
	  ruart_dataout[6] <= shift_reg_in[6];
	  ruart_dataout[7] <= shift_reg_in[7];													
	end
end

	
// Circuit for transmitter side
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		shift_reg_out <= 8'h0;
		ser_txd <= 1'b0;
	end
	else
	if((uart_wr == 1'b0) && (uart_rd == 1'b1) && (byte_out == 1'b0))
	begin
		ser_txd <= shift_reg_out[7];
		shift_reg_out[7] <= shift_reg_out[6];
		shift_reg_out[6] <= shift_reg_out[5];
		shift_reg_out[5] <= shift_reg_out[4];
		shift_reg_out[4] <= shift_reg_out[3];
		shift_reg_out[3] <= shift_reg_out[2];
		shift_reg_out[2] <= shift_reg_out[1];
		shift_reg_out[1] <= shift_reg_out[0];
	end
	else
	if((uart_wr == 1'b0) && (uart_rd == 1'b1) && (byte_out == 1'b1))
		shift_reg_out <= uart_datain;
end



// Serial Input Byte Counter
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		serin_cnt <= 3'b000;
		byte_in <= 1'b0;
	end
	else
	if((uart_cs == 1'b1) && (uart_wr == 1'b1) && (uart_rd == 1'b0))
		serin_cnt <= serin_cnt + 1;
	else
	if(serin_cnt == 3'b111)
		byte_in <= 1'b1;
	else
	begin
		byte_in <= 1'b0;
		serin_cnt <= serin_cnt;
	end
end


// Serial Output Byte Counter
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		serout_cnt <= 3'b000;
		byte_out <= 1'b0;
	end
	else
	if((uart_cs == 1'b1) && (uart_wr == 1'b0) && (uart_rd == 1'b1))
		serout_cnt <= serout_cnt + 1;
	else
	if(serout_cnt == 3'b111)
		byte_out <= 1'b1;
	else
	begin
		byte_out <= 1'b0;
		serout_cnt <= serout_cnt;
	end
end

endmodule
