`timescale 1ns / 1ps
`include "C:/cachedesign/v1/ise/src/global_params.vh"
`include "C:/cachedesign/v1/ise/src/memory_params.vh"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Chinthaka A.K.
// 
// Create Date:    06:41:43 12/08/2009 
// Design Name: 
// Module Name:    memory_bank 
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
module memory_bank(CLK,EN,WE,SELECT,ADDR,DI,DO_BUF);
	input CLK,EN,WE;
	input [`OFFSET-1:0]SELECT;
	input [`ADDR_PORT_SIZE-1:0]ADDR;
	input [`DATA_PORT_SIZE-1:0] DI;
	output [`DATA_PORT_SIZE-1:0]DO_BUF;
		
	wire [`DATA_PORT_SIZE-1:0] DO;
	wire [`DATA_PORT_SIZE-1:0]DO0,DO1,DO2,DO3,DO4,DO5,DO6,DO7;
	wire [`DATA_PORT_SIZE-1:0]DI0,DI1,DI2,DI3,DI4,DI5,DI6,DI7;
	
	reg [`DATA_PORT_SIZE-1:0]REG_EN;
	
	bufif0_8bit bufout(DO_BUF,DO,WE);	// output buffer
	
	eight_to_one_mux_8bit mux(DO,{DO7,DO6,DO5,DO4,DO3,DO2,DO1,DO0},SELECT); // output mux
	
	initial REG_EN = 8'h00; // disable all banks for safe operation
	
	// Read burst and write normal
	always @(posedge CLK)
	begin
		REG_EN = 8'h00; // disable all banks
		if (EN) 
			begin
				if (WE) 
					begin
						REG_EN = 8'h00; // disable all banks
						
						case (ADDR[2:0])	// enable required single bank for normal write
							3'h0 : REG_EN = 8'h01;
							3'h1 : REG_EN = 8'h02;
							3'h2 : REG_EN = 8'h04;
							3'h3 : REG_EN = 8'h08;
							3'h4 : REG_EN = 8'h10;
							3'h5 : REG_EN = 8'h20;
							3'h6 : REG_EN = 8'h40;
							3'h7 : REG_EN = 8'h80; 
						endcase
						
					end 
				else 
					begin
						REG_EN = 8'hFF;	// enable all banks for burst read
						
					end
			end
		end
		
	// memory banks
	RAMB16_S8 bank0(CLK,REG_EN[0],WE,ADDR[13:3],DI0,DO0);
	RAMB16_S8 bank1(CLK,REG_EN[1],WE,ADDR[13:3],DI1,DO1);
	RAMB16_S8 bank2(CLK,REG_EN[2],WE,ADDR[13:3],DI2,DO2);
	RAMB16_S8 bank3(CLK,REG_EN[3],WE,ADDR[13:3],DI3,DO3);
	RAMB16_S8 bank4(CLK,REG_EN[4],WE,ADDR[13:3],DI4,DO4);
	RAMB16_S8 bank5(CLK,REG_EN[5],WE,ADDR[13:3],DI5,DO5);
	RAMB16_S8 bank6(CLK,REG_EN[6],WE,ADDR[13:3],DI6,DO6);
	RAMB16_S8 bank7(CLK,REG_EN[7],WE,ADDR[13:3],DI7,DO7);
	
	one_to_eight_demux_8bit demux({DI0,DI1,DI2,DI3,DI4,DI5,DI6,DI7},DI,ADDR[2:0]); // input mux
endmodule
