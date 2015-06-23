`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:28:18 08/24/2011 
// Design Name: 
// Module Name:    q15_add 
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
module qadd(
    input [N-1:0] a,
    input [N-1:0] b,
    output [N-1:0] c
    );
//sign+16.15

	//Parameterized values
	parameter Q = 15;
	parameter N = 32;

reg [N-1:0] res;

assign c = res;

always @(a,b)
begin
	//both negative
	if(a[N-1] == 1 && b[N-1] == 1) begin
		//sign
		res[N-1] = 1;
		//whole
		res[N-2:0] = a[N-2:0] + b[N-2:0];
	end
	//both positive
	else if(a[N-1] == 0 && b[N-1] == 0) begin
		//sign
		res[N-1] = 0;
		//whole
		res[N-2:0] = a[N-2:0] + b[N-2:0];
	end
	//subtract a-b
	else if(a[N-1] == 0 && b[N-1] == 1) begin
		//sign
		if(a[N-2:0] > b[N-2:0])
			res[N-1] = 1;
		else
			res[N-1] = 0;
		//whole
		res[N-2:0] = a[N-2:0] - b[N-2:0];
	end
	//subtract b-a
	else begin
		//sign
		if(a[N-2:0] < b[N-2:0])
			res[N-1] = 1;
		else
			res[N-1] = 0;
		//whole
		res[N-2:0] = b[N-2:0] - a[N-2:0];
	end
end

endmodule
