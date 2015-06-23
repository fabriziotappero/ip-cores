`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:14:48 08/19/2008 
// Design Name: 
// Module Name:    Registers_file 
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
`define DATA_WIDTH 8
`define DATA_DEPTH 32
`define DEL 1
module Registers_file(D, WE_N, RE_N, ALE, A0, ADD_ext, EXT, CLK);
//INOUTS
    inout [`DATA_WIDTH-1:0] D;//Data bus
//INPUT
	 input [`DATA_WIDTH-1:0]ADD_ext;//external address for acces the registers
 	 input WE_N;//write enable
	 input RE_N;//read enable
	 input A0;//used to access the internal register 
	 input ALE;//with the trailing edge of ALE the addres in the local data bus is latched in to the addres register
	 input EXT;
	 input CLK;
//SIGNAL DECLARATIONS
	 wire [`DATA_WIDTH-1:0]ADD_ext;
	 reg [`DATA_WIDTH-1:0]ADD_int;
	 wire [`DATA_WIDTH-1:0] D;
	 wire [`DATA_WIDTH-1:0] ADD;
	 wire [`DATA_WIDTH-1:0] D_IN;
	 wire A0;
	 wire ALE;
	 wire EXT;
	 reg [`DATA_WIDTH-1:0] D_OUT;
	 reg [`DATA_WIDTH-1:0] registers [`DATA_DEPTH-1:0];
//ASSIGMENT STATEMENTS
	 assign	#`DEL D = RE_N ? D_IN : D_OUT;
	 assign #`DEL ADD = EXT ? ADD_ext : ADD_int;
//MAIN CODE
always @(posedge ALE) begin
		registers[`DATA_WIDTH'h1A] <= #`DEL D_IN;
		end
always @(negedge CLK) begin
	if(EXT == 0) begin
		if(A0 == 0)begin
			if(!WE_N && RE_N)begin
				ADD_int <= #`DEL `DATA_WIDTH'h1A;
				end
			if((WE_N === 1'b1) && (RE_N === 1'b0) )begin	
				ADD_int  <= #`DEL `DATA_WIDTH'h1F;
				end
		end
		else if(A0 == 1)begin
			ADD_int <= #`DEL registers[`DATA_WIDTH'h1A];
			if(~WE_N)begin
				registers[ADD] <= D_IN;
			end
			if(~RE_N)begin
				D_OUT <= registers[ADD];
			end
		end
	end
	else if(EXT == 1)begin
		if(~WE_N)begin
				registers[ADD] <= D_IN;
			end
		if(~RE_N)begin
				D_OUT <= registers[ADD];
			end
	end
	end
always @(ADD)begin
	if((ADD == `DATA_WIDTH'h18)|| (ADD == `DATA_WIDTH'h19)||(ADD == `DATA_WIDTH'h1A)||(ADD == `DATA_WIDTH'h1F))begin
		registers[`DATA_WIDTH'h1A] <= registers[`DATA_WIDTH'h1A];
		end
	else begin
		registers[`DATA_WIDTH'h1A] <= registers[`DATA_WIDTH'h1A]+1;
		end
	end
endmodule

