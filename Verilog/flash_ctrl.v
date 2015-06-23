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
module flash_ctrl(// Inputs
						reset,
						clk0,
						flash_host_addr,
						flash_host_cmd,
						flash_host_dataout,
						flash_datain,
						// Outputs
						flash_host_datain,
						flash_cle,
						flash_ale,
						flash_ce,
						flash_re,
						flash_we,
						flash_wp,
						flash_rb,
						flash_irq,
						flash_dataout
						);
		

// Parameter
`include        "parameter.v"

// Inputs
input reset;
input clk0;
input [padd_size - 1 : 0]flash_host_addr;
input [cmd_size - 1 : 0]flash_host_cmd;
input [data_size - 1 : 0]flash_host_dataout;
input [flash_size - 1 : 0]flash_datain;

// Outputs
output [data_size - 1 : 0]flash_host_datain;
output flash_cle;
output flash_ale;
output flash_ce;
output flash_re;
output flash_we;
output flash_wp;
output flash_rb;
output flash_irq;
output [flash_size - 1 : 0]flash_dataout;


// Signal Declarations
wire reset;
wire clk0;
wire [padd_size - 1 : 0]flash_host_addr;
wire [cmd_size - 1 : 0]flash_host_cmd;
wire [data_size - 1 : 0]flash_host_dataout;
wire [flash_size - 1 : 0]flash_datain;

wire [data_size - 1 : 0]flash_host_datain;
reg flash_cle;
reg flash_ale;
reg flash_ce;
reg flash_re;
reg flash_we;
reg flash_wp;
reg flash_rb;
reg flash_irq;
reg [flash_size - 1 : 0]flash_dataout;


// Internal Registers
reg [Byte_size - 1 : 0]flash_reg_dataout;

// Assignment statments
assign flash_host_datain = flash_reg_dataout;

/***************** Internal Register of Uart configuration *******************/
reg [flash_reg_width - 1 : 0] flash_register [flash_reg_depth - 1 : 0];


// Circuit for internal Register
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		flash_reg_dataout <= 8'h0;
		flash_register[0] <= 8'h0;
		flash_register[1] <= 8'h0;
		flash_register[2] <= 8'h0;
		flash_register[3] <= 8'h0;
		flash_register[4] <= 8'h0;
		flash_register[5] <= 8'h0;
		flash_register[6] <= 8'h0;
		flash_register[7] <= 8'h0;
	end
	else
	begin
		if(flash_host_cmd == 3'b010)
		begin
			case(flash_host_addr)
				24'h080008: flash_register[0] <= flash_host_dataout;
				24'h080009: flash_register[1] <= flash_host_dataout;
				24'h08000A: flash_register[2] <= flash_host_dataout;
				24'h08000B: flash_register[3] <= flash_host_dataout;
				24'h08000C: flash_register[4] <= flash_host_dataout;
				24'h08000D: flash_register[5] <= flash_host_dataout;
				24'h08000E: flash_register[6] <= flash_host_dataout;
				24'h08000F: flash_register[7] <= flash_host_dataout;
			endcase
		end
		else
		if(flash_host_cmd == 3'b001)
		begin
			case(flash_host_addr)
				24'h080008: flash_reg_dataout <= flash_register[0];
				24'h080009: flash_reg_dataout <= flash_register[1];
				24'h08000A: flash_reg_dataout <= flash_register[2];
				24'h08000B: flash_reg_dataout <= flash_register[3];
				24'h08000C: flash_reg_dataout <= flash_register[4];
				24'h08000D: flash_reg_dataout <= flash_register[5];
				24'h08000E: flash_reg_dataout <= flash_register[6];
				24'h08000F: flash_reg_dataout <= flash_register[7];
			endcase
		end
	end

end


always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		flash_cle <= 1'b0;
		flash_ale <= 1'b0;
		flash_ce <= 1'b0;
		flash_re <= 1'b0;
		flash_we <= 1'b0;
		flash_wp <= 1'b0;
		flash_rb <= 1'b0;
		flash_irq <= 1'b0;
		flash_dataout <= 8'h0;
	end
	else
	begin
		flash_cle <= flash_host_addr[7];
		flash_ale <= flash_host_addr[0] & flash_host_cmd[0];
		flash_ce <= flash_host_addr[1] & flash_host_cmd[1];
		flash_re <= flash_host_addr[2] & flash_host_cmd[2];
		flash_we <= flash_host_addr[3];
		flash_wp <= flash_host_addr[4];
		flash_rb <= flash_host_addr[5];
		flash_irq <= flash_host_addr[6];
		flash_dataout <= flash_datain;
	end
end

endmodule
