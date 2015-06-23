// This is a 64k by 8 bit memory model for testing the fifo design
// This memory has 3-4 ns of delay on the output
// It is just a model for simulation purposes 
//
// Author: Morris Jones
// San Jose State University
//
`timescale 1ns/100ps


module mem64kx8(clk,addrw,din,write,addrr,dout);
input clk,write;
input [15:0] addrw;
input [15:0] addrr;
input [7:0] din;
output [7:0] dout;
reg [7:0] delayedOut ;

reg [7:0] fifo[0:65535];

always @(posedge(clk)) begin
	if(write) begin
		#0.05;	// check for hold time...
		fifo[addrw]=din;
	end
end
always @(addrr or addrw or write) begin
	delayedOut <= #3 fifo[addrr];
end

assign dout=delayedOut;

endmodule

