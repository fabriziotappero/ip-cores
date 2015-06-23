`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:41:24 08/06/2008 
// Design Name: 
// Module Name:    Address_translate 
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
module Address_translate(address_in, address_out, AS_in, AS_out, CE_N0, CE_N1, CE_N2, CE_N3, CE_N4, CE_N5, CE_N6, CE_N7, CE_N8, CE_N9, CE_N10, CE_N11, CE_N12, CE_N13, CE_N14, CE_N15);
    //Ports declarations
    //inputs
    input [31:0] address_in; // Address from Processor
    input AS_in; //Address Strobe from Processor
    //outputs
    output AS_out;//Address Strobe to SRAM
    output [20:0] address_out;//Address to SRAM 
//chip enable pins for the 16 SRAM ICs
	 output CE_N0;
	 output CE_N1; 
	 output CE_N2;
	 output CE_N3;
	 output CE_N4;
	 output CE_N5;
	 output CE_N6;
	 output CE_N7;
	 output CE_N8;	 
	 output CE_N9;
	 output CE_N10;	 
	 output CE_N11;
	 output CE_N12;
	 output CE_N13;
	 output CE_N14;
	 output CE_N15;
//Signals declarations
	 wire [31:0] address_in;
	 wire AS_in;
	 reg AS_out;
	 reg [20:0]address_out;
	 reg CE_N0;
	 reg CE_N1;
	 reg CE_N2;
	 reg CE_N3;
	 reg CE_N4;
	 reg CE_N5;
	 reg CE_N6;
	 reg CE_N7;
	 reg CE_N8;
	 reg CE_N9;
	 reg CE_N10;
	 reg CE_N11;
	 reg CE_N12;
	 reg CE_N13;
	 reg CE_N14;
	 reg CE_N15;
	 wire [2:0] bank_sel = address_in[23:22];
	 initial
		 begin
		 CE_N0 = 1'b1;
		 CE_N1 = 1'b1;
		 CE_N2 = 1'b1;
		 CE_N3 = 1'b1;
		 CE_N4 = 1'b1;
		 CE_N5 = 1'b1;
		 CE_N6 = 1'b1;
		 CE_N7 = 1'b1;
		 CE_N8 = 1'b1;
		 CE_N9 = 1'b1;
		 CE_N10 = 1'b1;
		 CE_N11 = 1'b1;
		 CE_N12 = 1'b1;
		 CE_N13 = 1'b1;
		 CE_N14 = 1'b1;
		 CE_N15 = 1'b1;
		 end
always @(negedge AS_in) begin
	address_out = address_in[20:0];
	if(bank_sel === 3'b000)begin
		CE_N0 = 0;
		CE_N1 = 0;
		CE_N2 = 0;
		CE_N3 = 0;
		CE_N4 = 1;
		CE_N5 = 1;
		CE_N6 = 1;
		CE_N7 = 1;
		CE_N8 = 1;
		CE_N9 = 1;
		CE_N10 = 1;
		CE_N11 = 1;
		CE_N12 = 1;
		CE_N13 = 1;
		CE_N14 = 1;
		CE_N15 = 1;
		end
	else if (bank_sel === 3'b001)begin
		CE_N0 = 1;
		CE_N1 = 1;
		CE_N2 = 1;
		CE_N3 = 1;
		CE_N4 = 0;
		CE_N5 = 0;
		CE_N6 = 0;
		CE_N7 = 0;
		CE_N8 = 1;
		CE_N9 = 1;
		CE_N10 = 1;
		CE_N11 = 1;
		CE_N12 = 1;
		CE_N13 = 1;
		CE_N14 = 1;
		CE_N15 = 1;
		end
	else if (bank_sel === 3'b010)begin
		CE_N0 = 1;
		CE_N1 = 1;
		CE_N2 = 1;
		CE_N3 = 1;
		CE_N4 = 1;
		CE_N5 = 1;
		CE_N6 = 1;
		CE_N7 = 1;
		CE_N8 = 0;
		CE_N9 = 0;
		CE_N10 = 0;
		CE_N11 = 0;
		CE_N12 = 1;
		CE_N13 = 1;
		CE_N14 = 1;
		CE_N15 = 1;
		end
	else if (bank_sel === 3'b011)begin 
		CE_N0 = 1;
		CE_N1 = 1;
		CE_N2 = 1;
		CE_N3 = 1;
		CE_N4 = 1;
		CE_N5 = 1;
		CE_N6 = 1;
		CE_N7 = 1;
		CE_N8 = 1;
		CE_N9 = 1;
		CE_N10 = 1;
		CE_N11 = 1;
		CE_N12 = 0;
		CE_N13 = 0;
		CE_N14 = 0;
		CE_N15 = 0;
		end
	else begin
		CE_N0 = 1;
		CE_N1 = 1;
		CE_N2 = 1;
		CE_N3 = 1;
		CE_N4 = 1;
		CE_N5 = 1;
		CE_N6 = 1;
		CE_N7 = 1;
		CE_N8 = 1;
		CE_N9 = 1;
		CE_N10 = 1;
		CE_N11 = 1;
		CE_N12 = 1;
		CE_N13 = 1;
		CE_N14 = 1;
		CE_N15 = 1;
	end
end

endmodule
