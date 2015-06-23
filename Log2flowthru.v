module Log2flowthru

/* 
A fast base-2 logarithm function, 24 bits (21 used) in, 8 bits out.
Designed and coded by: Michael Dunn, http://www.cantares.on.ca/
(more info at the web site - see "Extras")
Executes every cycle, with a latency of 1 - slower throughput than pipelined
version, but faster result.

This version has a smallish lookup table, hence, a slightly uneven output.
Valid input range = 000100 - FFFFFF. In effect, there is a binary point:
xxxx.yy. Logs of inputs below 1.00 are negative, and not handled by this design.

License: Free to use & modify, but please keep this header intact.
July 27, 2010, Kitchener, Ontario, Canada
*/

(
	input [23:0]	DIN,
	output	[7:0]	DOUT
);


// Comprises 3 main blocks: priority encoder, barrel shifter, and LUT

wire	[3:0]	priencout1;
wire	[3:0]	LUTout; 

assign	DOUT	=	{priencout1, LUTout};	// Basic top-level connectivity


// Barrel shifter - OMG, it's a primitive in Verilog!

wire	[19:0]	barrelin	=	DIN[22:3];
wire	[19:0]	tmp1 =	(barrelin << ~priencout1);
wire 	[4:0]	barrelout	=	tmp1[19:15];


// Priority encoder

wire	[15:0]	priencin = DIN[23:8];
always @*
casex (priencin)

	16'b1xxxxxxxxxxxxxxx:	priencout1	=	15;
	16'b01xxxxxxxxxxxxxx:	priencout1	=	14;
	16'b001xxxxxxxxxxxxx:	priencout1	=	13;	
	16'b0001xxxxxxxxxxxx:	priencout1	=	12;	
	16'b00001xxxxxxxxxxx:	priencout1	=	11;	
	16'b000001xxxxxxxxxx:	priencout1	=	10;	
	16'b0000001xxxxxxxxx:	priencout1	=	9;	
	16'b00000001xxxxxxxx:	priencout1	=	8;	
	16'b000000001xxxxxxx:	priencout1	=	7;	
	16'b0000000001xxxxxx:	priencout1	=	6;	
	16'b00000000001xxxxx:	priencout1	=	5;	
	16'b000000000001xxxx:	priencout1	=	4;	
	16'b0000000000001xxx:	priencout1	=	3;	
	16'b00000000000001xx:	priencout1	=	2;	
	16'b000000000000001x:	priencout1	=	1;	
	16'b000000000000000x:	priencout1	=	0;
	
endcase



/*
LUT for log fraction lookup
 - can be done with array or case:

case (addr)
0:out=0;
.
31:out=15;
endcase

	OR
	
wire [3:0] lut [0:31];
assign lut[0] = 0;
.
assign lut[31] = 15;

Are there any better ways?
*/

// Let's try "case".
// The equation is: output = log2(1+input/32)*16
// For larger tables, better to generate a separate data file using a program!

always @*
case (barrelout)

	0:	LUTout	=	0;
	1:	LUTout	=	1;
	2:	LUTout	=	1;
	3:	LUTout	=	2;
	4:	LUTout	=	3;
	5:	LUTout	=	3;
	6:	LUTout	=	4;
	7:	LUTout	=	5;
	8:	LUTout	=	5;
	9:	LUTout	=	6;
	10:	LUTout	=	6;
	11:	LUTout	=	7;
	12:	LUTout	=	7;
	13:	LUTout	=	8;
	14:	LUTout	=	8;
	15:	LUTout	=	9;
	16:	LUTout	=	9;
	17:	LUTout	=	10;
	18:	LUTout	=	10;
	19:	LUTout	=	11;
	20:	LUTout	=	11;
	21:	LUTout	=	12;
	22:	LUTout	=	12;
	23:	LUTout	=	13;
	24:	LUTout	=	13;
	25:	LUTout	=	13;
	26:	LUTout	=	14;
	27:	LUTout	=	14;
	28:	LUTout	=	14;	// calculated value is *slightly* closer to 15, but 14 makes for a smoother curve!
	29:	LUTout	=	15;
	30:	LUTout	=	15;
	31:	LUTout	=	15;

endcase

endmodule
