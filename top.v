//
// This is the top level of the unconfuser test bench
//

`timescale 1ns/100ps


module top ();

reg clk;

reg [31:0] sid0=5714;  //Pratik
reg [31:0] sid1=3538;  //Rohini
reg [31:0] sid2=4956;  //Peter
reg [31:0] sid3=5714;  //Pratik
reg [31:0] sid4=3538;  //Rohini

wire reset,push;
wire [7:0] din,dout;
wire [6:0] Caddr;
wire [7:0] Cdata;
wire Cpush;
wire pushout,stopout;
wire [7:0] mdin1,mdout1,mdin2,mdout2;
wire mwrite1,mwrite2;
wire [15:0] maddrw1,maddrr1,maddrw2,maddrr2;

mem64kx8 m1(clk,maddrw1,mdin1,mwrite1,maddrr1,mdout1);
mem64kx8 m2(clk,maddrw2,mdin2,mwrite2,maddrr2,mdout2);

ctb t(clk,reset,push,din,Caddr,Cdata,Cpush,pushout,stopout,dout,sid0,sid1,
		sid2,sid3,sid4);
		
unConfuser u(clk,reset,push,din,Caddr,Cdata,Cpush,pushout,stopout,dout
	,mdin1,maddrw1,mwrite1,mdout1,maddrr1
	,mdin2,maddrw2,mwrite2,mdout2,maddrr2
);

//unConfuser u(din, push, clk, reset, dout, pushout, stopout, Caddr, Cdata, Cpush);

initial begin
	clk=0;
	#8;
	forever begin
	   #8;
	   clk=!clk;
	end
end

//initial begin
//  $dumpfile("test.dump");
//  $dumpvars(10,top);
//end

endmodule
