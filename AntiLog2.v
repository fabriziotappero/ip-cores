module AntiLog2

/* 
A fast base-2 anti-logarithm function, 10 bits in, 24 bits out.
Designed and coded by: Michael Dunn, http://www.cantares.on.ca/
Executes every cycle, with a latency of 2.

The input and output have binary points: In: xxxx.yyyy_yy; Out: xxxx_xxxx_xxxx_xxxx.yyyy_yyyy

License: Free to use & modify, but please keep this header intact.
August 8, 2010, Kitchener, Ontario, Canada
*/

(
	input [9:0]	DIN,
	input			clk,

	output reg	[23:0]	DOUT
);


// Comprises 2 main blocks: barrel shifter & LUT

reg	[3:0]	barrelshfcnt;
reg	[22:0]	LUTout;

wire [38:0] tmp1 =	({1'b1, LUTout}  <<  barrelshfcnt);

always @(posedge clk) 					
begin
	barrelshfcnt	<=	DIN[9:6];
	DOUT			<=	tmp1[38:15];
end


//LUT for one octave of antilog lookup
// The equation is: output = (2^(input/64)-1) * 2^23
// For larger tables, better to generate a separate data file using a program!

always @(posedge clk)
case (DIN[5:0])

	0:	LUTout	<=	0;
	1:	LUTout	<=	91346;
	2:	LUTout	<=	183687;
	3:	LUTout	<=	277033;
	4:	LUTout	<=	371395;
	5:	LUTout	<=	466786;
	6:	LUTout	<=	563215;
	7:	LUTout	<=	660693;
	8:	LUTout	<=	759234;
	9:	LUTout	<=	858847;
	10:	LUTout	<=	959546;
	11:	LUTout	<=	1061340;
	12:	LUTout	<=	1164243;
	13:	LUTout	<=	1268267;
	14:	LUTout	<=	1373424;
	15:	LUTout	<=	1479725;
	16:	LUTout	<=	1587184;
	17:	LUTout	<=	1695814;
	18:	LUTout	<=	1805626;
	19:	LUTout	<=	1916634;
	20:	LUTout	<=	2028850;
	21:	LUTout	<=	2142289;
	22:	LUTout	<=	2256963;
	23:	LUTout	<=	2372886;
	24:	LUTout	<=	2490071;
	25:	LUTout	<=	2608532;
	26:	LUTout	<=	2728283;
	27:	LUTout	<=	2849338;
	28:	LUTout	<=	2971711;
	29:	LUTout	<=	3095417;
	30:	LUTout	<=	3220470;
	31:	LUTout	<=	3346884;
	32:	LUTout	<=	3474675;
	33:	LUTout	<=	3603858;
	34:	LUTout	<=	3734447;
	35:	LUTout	<=	3866459;
	36:	LUTout	<=	3999908;
	37:	LUTout	<=	4134810;
	38:	LUTout	<=	4271181;
	39:	LUTout	<=	4409037;
	40:	LUTout	<=	4548394;
	41:	LUTout	<=	4689269;
	42:	LUTout	<=	4831678;
	43:	LUTout	<=	4975637;
	44:	LUTout	<=	5121164;
	45:	LUTout	<=	5268276;
	46:	LUTout	<=	5416990;
	47:	LUTout	<=	5567323;
	48:	LUTout	<=	5719293;
	49:	LUTout	<=	5872918;
	50:	LUTout	<=	6028216;
	51:	LUTout	<=	6185205;
	52:	LUTout	<=	6343903;
	53:	LUTout	<=	6504329;
	54:	LUTout	<=	6666503;
	55:	LUTout	<=	6830442;
	56:	LUTout	<=	6996167;
	57:	LUTout	<=	7163696;
	58:	LUTout	<=	7333050;
	59:	LUTout	<=	7504247;
	60:	LUTout	<=	7677309;
	61:	LUTout	<=	7852255;
	62:	LUTout	<=	8029107;
	63:	LUTout	<=	8207884;

endcase

endmodule
