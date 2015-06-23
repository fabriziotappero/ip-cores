
`timescale 1ps / 1ps
module fpu_mul_tb;

reg clk;
reg rst;
reg enable;
reg [1:0]rmode;
reg [63:0]opa;
reg [63:0]opb;
wire ready;
wire [63:0]outfp;

	fpu_mul UUT (
		.clk(clk),
		.rst(rst),
		.enable(enable),
		.rmode(rmode),
		.opa(opa),
		.opb(opb),
		.ready(ready),
		.outfp(outfp));

initial
begin : STIMUL 
	#0
	enable = 1'b0;
	rst = 1'b1;
    #10000; //0
	enable = 1'b1;
	rst = 1'b0;	 
//inputA:9.6300000000e+001
//inputB:-2.5600000000e-001
opa = 64'b0100000001011000000100110011001100110011001100110011001100110011;
opb = 64'b1011111111010000011000100100110111010010111100011010100111111100;
rmode = 2'b11;
	 #10000; 
//inputA:3.6600000000e+000
//inputB:2.2500000000e+000
opa = 64'b0100000000001101010001111010111000010100011110101110000101001000;
opb = 64'b0100000000000010000000000000000000000000000000000000000000000000;
rmode = 2'b00;
	   #10000; 
//inputA:-5.6970000000e+001
//inputB:1.2340000000e-001
opa = 64'b1100000001001100011111000010100011110101110000101000111101011100;
opb = 64'b0011111110111111100101110010010001110100010100111000111011110011;
rmode = 2'b11;
	   #10000; 
//inputA:4.5680000000e+001
//inputB:2.1300000000e+000
opa = 64'b0100000001000110110101110000101000111101011100001010001111010111;
opb = 64'b0100000000000001000010100011110101110000101000111101011100001010;
rmode = 2'b00;
	  #10000; 
//inputA:3.0000000000e-311
//inputB:-4.0000000000e+060
opa = 64'b0000000000000000000001011000010111000011011011101010101101110011;
opb = 64'b1100110010000011111010011110010011100100110000101111001101000100;
rmode = 2'b10;
	   #10000; 
//inputA:4.6300000000e+001
//inputB:2.3110000000e+001
opa = 64'b0100000001000111001001100110011001100110011001100110011001100110;
opb = 64'b0100000000110111000111000010100011110101110000101000111101011100;
rmode = 2'b00;
	   #10000; 
//inputA:5.0000000000e-250
//inputB:-1.#INF000000e+000
opa = 64'b0000110000101100101000111000111100110101000010110010001011011111;
opb = 64'b1111111111110000000000000000000000000000000000000000000000000000;
rmode = 2'b11;	 
	    #10000; 
//inputA:
//inputB:
opa = 64'b0100000000111111111111111111111111111111111111111111111111111110;
opb = 64'b0100000000110000000000000000000000000000000000000000000000000001;
rmode = 2'b00;
	   #10000; 
//inputA:1.2000000000e-001
//inputB:5.2000000000e+001
opa = 64'b0011111110111110101110000101000111101011100001010001111010111000;
opb = 64'b0100000001001010000000000000000000000000000000000000000000000000;
rmode = 2'b00;
	    #10000; 
//inputA:8.9999000000e+004
//inputB:1.6000000000e+001
opa = 64'b0100000011110101111110001111000000000000000000000000000000000000;
opb = 64'b0100000000110000000000000000000000000000000000000000000000000000;	 
rmode = 2'b10;

	#120000;
//Output:-2.465280000000000e+001
if (outfp==64'hC038A71DE69AD42D)
	$display($time,"ps Answer is correct %h", outfp);
else
	$display($time,"ps Error! out is incorrect %h", outfp);
	#10000; //0
//Output:8.235000000000001e+000
if (outfp==64'h40207851EB851EB8)
	$display($time,"ps Answer is correct %h", outfp);
else
	$display($time,"ps Error! out is incorrect %h", outfp); 
	#10000; //0
//Output:-7.030098000000000e+000
if (outfp==64'hC01C1ED20296B335)
	$display($time,"ps Answer is correct %h", outfp);
else
	$display($time,"ps Error! out is incorrect %h", outfp);
	#10000; //0
//Output:9.729840000000000e+001
if (outfp==64'h40585318FC504817)
	$display($time,"ps Answer is correct %h", outfp);
else
	$display($time,"ps Error! out is incorrect %h", outfp);
	#10000; //0
//Output:-0
if (outfp==64'h8000000000000000)
	$display($time,"ps Answer is correct %h", outfp);
else
	$display($time,"ps Error! out is incorrect %h", outfp); 
	#10000; //0
//Output:1.069993000000000e+003
if (outfp==64'h4090B7F8D4FDF3B6)
	$display($time,"ps Answer is correct %h", outfp);
else
	$display($time,"ps Error! out is incorrect %h", outfp);	
	#10000; //0
//Output:-INF
if (outfp==64'hFFF0000000000000)
	$display($time,"ps Answer is correct %h", outfp);
else
	$display($time,"ps Error! out is incorrect %h", outfp);
		#10000; //0
	//Output
if (outfp==64'h4080000000000000)
	$display($time,"ps Answer is correct %h", outfp);
else
	$display($time,"ps Error! out is incorrect %h", outfp);
	#10000; //0
//Output:6.240000000000000e+000
if (outfp==64'h4018F5C28F5C28F6)
	$display($time,"ps Answer is correct %h", outfp);
else
	$display($time,"ps Error! out is incorrect %h", outfp);
	  
	#10000; //0
	//Output:1.439984000000000e+006
if (outfp==64'h4135F8F000000000)
	$display($time,"ps Answer is correct %h", outfp);
else
	$display($time,"ps Error! out is incorrect %h", outfp);	  

    #290000; //10000
	$finish;
end // end of stimulus process
	
always
begin : CLOCK_clk

	clk = 1'b0;
	#5000; 
	clk = 1'b1;
	#5000; 
end


endmodule
