
`timescale 1ps / 1ps
module fpu_addsub_tb;

reg clk;
reg rst;
reg enable;
reg fpu_op;
reg [1:0]rmode;
reg [63:0]opa;
reg [63:0]opb;
wire [63:0]out;
wire ready;


	fpu_addsub UUT (
		.clk(clk),
		.rst(rst),
		.enable(enable),
		.fpu_op(fpu_op),
		.rmode(rmode),
		.opa(opa),
		.opb(opb),
		.out(out),
		.ready(ready));

initial
begin : STIMUL 
	#0
	enable = 1'b0;
	rst = 1'b1;
    #10000; 
	enable = 1'b1;
	rst = 1'b0;	
	opa = 64'b0100000000010001010110010001011010000111001010110000001000001100;
	opb = 64'b0000110000000110111010010011111101011101101000101000001001001100;
	fpu_op = 1'b0;
	rmode = 2'b10;
	#10000;	   
	//inputA:1.6000000000e+001
	//inputB:1.0000000000e-208
	opa = 64'b0100000000110000000000000000000000000000000000000000000000000000;
	opb = 64'b0001010011000000011100000001101111010101001001111011010010011000;
	fpu_op = 1'b1;
	rmode = 2'b10;
	#10000;
	//inputA:9.9999999996e-314
	//inputB:4.6770000000e+000
	opa = 64'b0000000000000000000000000000010010110110011010010101010000110010;
	opb = 64'b0100000000010010101101010011111101111100111011011001000101101000;
	fpu_op = 1'b1;
	rmode = 2'b11;	 
	#10000;	 
	//inputA:5.3620000000e+003
	//inputB:1.9999999999e-314
	opa = 64'b0100000010110100111100100000000000000000000000000000000000000000;
	opb = 64'b0000000000000000000000000000000011110001010010000100010000001010;
	fpu_op = 1'b0;
	rmode = 2'b10;	  
	#10000;
	//inputA:5.8000000000e+000
	//inputB:5.7900000000e+000
	opa = 64'b0100000000010111001100110011001100110011001100110011001100110011;
	opb = 64'b0100000000010111001010001111010111000010100011110101110000101001;
	fpu_op = 1'b1;
	rmode = 2'b10;
	#10000;
	opa = 64'b0100000000010001010110010001011010000111001010110000001000001100;
	opb = 64'b0000110000000110111010010011111101011101101000101000001001001100;
	fpu_op = 1'b0;
	rmode = 2'b00;	
		#10000;
	//inputA:-9.4000000000e+035
	//inputB:9.4770000000e+035
	opa = 64'b1100011101100110101000010011001010000000011101101111101100010011;
	opb = 64'b0100011101100110110100001010011011110101101100101001000000100011;
	fpu_op = 1'b0;
	rmode = 2'b10;	   
	  #10000;
	//inputA:-3.6680000000e+000
	//inputB:9.0007340000e+003
	opa = 64'b1100000000001101010110000001000001100010010011011101001011110010;
	opb = 64'b0100000011000001100101000101110111110011101101100100010110100010;
	fpu_op = 1'b1;
	rmode = 2'b11; 
	   #10000;
	//inputA:4.7700000000e+000
	//inputB:-2.5000000000e-003
	opa = 64'b0100000000010011000101000111101011100001010001111010111000010100;
	opb = 64'b1011111101100100011110101110000101000111101011100001010001111011;
	fpu_op = 1'b0;
	rmode = 2'b10;	   
	#10000;
	 //inputA:7.9500000000e+000
	//inputB:-7.9433210000e+000
	opa = 64'b0100000000011111110011001100110011001100110011001100110011001101;
	opb = 64'b1100000000011111110001011111010111110000101100101000010100100011;
	fpu_op = 1'b1;
	rmode = 2'b00;	 
	#10000;
	//inputA:8.0260000000e+000
	//inputB:1.0000000000e-106
	opa = 64'b0100000000100000000011010100111111011111001110110110010001011010;
	opb = 64'b0010100111101101010110110101011000010101011101000111011001011011;
	fpu_op = 1'b0;
	rmode = 2'b10;	
	#10000;
	//inputA:9.9230000000e+001
	//inputB:2.5370000000e-003
	opa = 64'b0100000001011000110011101011100001010001111010111000010100011111;
	opb = 64'b0011111101100100110010000111100110000000111101010101110111100110;
	fpu_op = 1'b1;
	rmode = 2'b11;
	#10000;	
	//inputA:1.7179869184e+010
	//inputB:4.0000000000e-176
	opa = 64'b0100001000001111111111111111111111111111111111111111111111111111;
	opb = 64'b0001101110000100010000101110010011111011011001110001100101100000;
	fpu_op = 1'b0;
	rmode = 2'b10; 
	#10000;	 
	//inputA:-2.6800000000e-005
	//inputB:-8.5400000000e-013
	opa = 64'b1011111011111100000110100001000111111001111111011000011110000000;
	opb = 64'b1011110101101110000011000010010111101110000010111101110010010110;
	fpu_op = 1'b0;
	rmode = 2'b00;
	#10000;			 
	//inputA:-8.5400000000e-013
	//inputB:INF
	opa = 64'b1011110101101110000011000010010111101110000010111101110010010110;
	opb = 64'b0111111111110000000000000000000000000000000000000000000000000000;
	fpu_op = 1'b0;
	rmode = 2'b00;
	#10000;
	//inputA:-5.6555650000e+006
	//inputB:-2.3665000000e-001
	opa = 64'b1100000101010101100100110000001101000000000000000000000000000000;
	opb = 64'b1011111111001110010010101000110000010101010011001001100001011111;
	fpu_op = 1'b1;
	rmode = 2'b11;
	#90000;
	//Output:4.337000000000001e+000
	if (out==64'h40115916872B020D)
		$display($time,"ps Answer is correct %h", out);
	else
		$display($time,"ps Error! out is incorrect %h", out);
	#10000;
	//Output:1.600000000000000e+001
	if (out==64'h4030000000000000)
		$display($time,"ps Answer is correct %h", out);
	else
		$display($time,"ps Error! out is incorrect %h", out);
	#10000;		  
	//Output:-4.677000000000000e+000
	if (out==64'hC012B53F7CED9168)
		$display($time,"ps Answer is correct %h", out);
	else
		$display($time,"ps Error! out is incorrect %h", out);
	#10000;
	//Output:5.362000000000001e+003
	if (out==64'h40B4F20000000000)
		$display($time,"ps Answer is correct %h", out);
	else
		$display($time,"ps Error! out is incorrect %h", out);	
	#10000;	
	//Output:9.999999999999787e-003
	if (out==64'h3F847AE147AE1400)
		$display($time,"ps Answer is correct %h", out);
	else
		$display($time,"ps Error! out is incorrect %h", out);  
		#10000;
	//Output:4.337000000000001e+000
	if (out==64'h40115916872B020C)
		$display($time,"ps Answer is correct %h", out);
	else
		$display($time,"ps Error! out is incorrect %h", out);
	#10000;
	//Output:7.699999999999867e+033
	if (out==64'h46F7BA3A9DCA8800)
		$display($time,"ps Answer is correct %h", out);
	else
		$display($time,"ps Error! out is incorrect %h", out);
	#10000;
	//Output:-9.004402000000000e+003
	if (out==64'hC0C1963374BC6A80)
		$display($time,"ps Answer is correct %h", out);
	else
		$display($time,"ps Error! out is incorrect %h", out);
	#10000;
	//Output:4.767500000000000e+000
	if (out==64'h401311EB851EB852)
		$display($time,"ps Answer is correct %h", out);
	else
		$display($time,"ps Error! out is incorrect %h", out);
	#10000;
	//Output:1.589332100000000e+001
	if (out==64'h402FC9615EBFA8F8)
		$display($time,"ps Answer is correct %h", out);
	else
		$display($time,"ps Error! out is incorrect %h", out);  
	#10000;
	//Output:8.026000000000002e+000
	if (out==64'h40200D4FDF3B645B)
		$display($time,"ps Answer is correct %h", out);
	else
		$display($time,"ps Error! out is incorrect %h", out);
	#10000;
	//Output:9.922746300000000e+001
	if (out==64'h4058CE8EC0F88334)
		$display($time,"ps Answer is correct %h", out);
	else
		$display($time,"ps Error! out is incorrect %h", out);	  
	#10000;
	//Output:1.717986918400000e+010
	if (out==64'h4210000000000000)
		$display($time,"ps Answer is correct %h", out);
	else
		$display($time,"ps Error! out is incorrect %h", out);
	#10000;	
	//Output:-2.680000085400000e-005
	if (out==64'hBEFC1A1209039A77)	
		$display($time,"ps Answer is correct %h", out);
	else
		$display($time,"ps Error! out is incorrect %h", out); 
	#10000;
	//Output:INF
	if (out==64'h7FF0000000000000)
		$display($time,"ps Answer is correct %h", out);
	else
		$display($time,"ps Error! out is incorrect %h", out);	
	#10000;
	//Output:-5.655564763350001e+006
	if (out==64'hC155930330DAB9F6)
		$display($time,"ps Answer is correct %h", out);
	else
		$display($time,"ps Error! out is incorrect %h", out);
	#390000; 
	$finish;
	end 
	
	always
	begin : CLOCK_clk
		clk = 1'b0;
		#5000; 	
		clk = 1'b1;
		#5000; 	
	end
	
	
	
	
	endmodule
	