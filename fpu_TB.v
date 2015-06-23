/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FPU                                                        ////
////  Floating Point Unit (Double precision)                     ////
////                                                             ////
////  Author: David Lundgren                                     ////
////          davidklun@gmail.com                                ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2009 David Lundgren                           ////
////                  davidklun@gmail.com                        ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

`timescale 1ps / 1ps

module fpu_tb;

reg clk;
reg rst;
reg enable;
reg [1:0]rmode;
reg [2:0]fpu_op;
reg [63:0]opa;
reg [63:0]opb;
wire [63:0]out;
wire ready;
wire underflow;
wire overflow;
wire inexact;
wire exception;
wire invalid;  

reg [6:0] count;


	fpu UUT (
		.clk(clk),
		.rst(rst),
		.enable(enable),
		.rmode(rmode),
		.fpu_op(fpu_op),
		.opa(opa),
		.opb(opb),
		.out(out),
		.ready(ready),
		.underflow(underflow),
		.overflow(overflow),
		.inexact(inexact),
		.exception(exception),
		.invalid(invalid));

  		  
initial
begin : STIMUL 
	#0			  
	count = 0;
	rst = 1'b1;
	#20000;
	rst = 1'b0;	   // paste after this
//inputA:1.6999999999e-314
//inputB:4.0000000000e-300
enable = 1'b1;
opa = 64'b0000000000000000000000000000000011001101000101110000011010100010;
opb = 64'b0000000111000101011011100001111111000010111110001111001101011001;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:4.249999999722977e-015
if (out==64'h3CF323EA98D06FB6)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:3.0000000000e-290
//inputB:3.0000000000e-021
enable = 1'b1;
opa = 64'b0000001111010010101101100000010001001001010000101111100001010101;
opb = 64'b0011101110101100010101011000111000001111000101011110100011110111;
fpu_op = 3'b010;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:9.000000000000022e-311
if (out==64'h000010914A4C025A)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.6500000000e+002
//inputB:6.5000000000e+001
enable = 1'b1;
opa = 64'b0100000001111101000100000000000000000000000000000000000000000000;
opb = 64'b0100000001010000010000000000000000000000000000000000000000000000;
fpu_op = 3'b001;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:4.000000000000000e+002
if (out==64'h4079000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:2.2700000000e-001
//inputB:3.4000000000e+001
enable = 1'b1;
opa = 64'b0011111111001101000011100101011000000100000110001001001101110101;
opb = 64'b0100000001000001000000000000000000000000000000000000000000000000;
fpu_op = 3'b000;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:3.422700000000000e+001
if (out==64'h40411D0E56041894)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:2.2300000000e+002
//inputB:5.6000000000e+001
enable = 1'b1;
opa = 64'b0100000001101011111000000000000000000000000000000000000000000000;
opb = 64'b0100000001001100000000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:3.982142857142857e+000
if (out==64'h400FDB6DB6DB6DB7)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-9.5000000000e+001
//inputB:2.0000000000e+002
enable = 1'b1;
opa = 64'b1100000001010111110000000000000000000000000000000000000000000000;
opb = 64'b0100000001101001000000000000000000000000000000000000000000000000;
fpu_op = 3'b010;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:-1.900000000000000e+004
if (out==64'hC0D28E0000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-4.5000000000e+001
//inputB:-3.2000000000e+001
enable = 1'b1;
opa = 64'b1100000001000110100000000000000000000000000000000000000000000000;
opb = 64'b1100000001000000000000000000000000000000000000000000000000000000;
fpu_op = 3'b001;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:-1.300000000000000e+001
if (out==64'hC02A000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-9.0300000000e+002
//inputB:2.1000000000e+001
enable = 1'b1;
opa = 64'b1100000010001100001110000000000000000000000000000000000000000000;
opb = 64'b0100000000110101000000000000000000000000000000000000000000000000;
fpu_op = 3'b000;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:-8.820000000000000e+002
if (out==64'hC08B900000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.5500000000e+002
//inputB:-4.5900000000e+002
enable = 1'b1;
opa = 64'b0100000001111100011100000000000000000000000000000000000000000000;
opb = 64'b1100000001111100101100000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:-9.912854030501089e-001
if (out==64'hBFEFB89C2A6346D5)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:2.3577000000e+002
//inputB:2.0000000000e-002
enable = 1'b1;
opa = 64'b0100000001101101011110001010001111010111000010100011110101110001;
opb = 64'b0011111110010100011110101110000101000111101011100001010001111011;
fpu_op = 3'b010;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:4.715400000000001e+000
if (out==64'h4012DC91D14E3BCE)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.0195000000e+002
//inputB:-3.3600000000e+001
enable = 1'b1;
opa = 64'b0100000001111001000111110011001100110011001100110011001100110011;
opb = 64'b1100000001000000110011001100110011001100110011001100110011001101;
fpu_op = 3'b001;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:4.355500000000000e+002
if (out==64'h407B38CCCCCCCCCC)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-1.0000000000e-309
//inputB:1.1000000000e-309
enable = 1'b1;
opa = 64'b1000000000000000101110000001010101110010011010001111110110101110;
opb = 64'b0000000000000000110010100111110111111101110110011110001111011001;
fpu_op = 3'b000;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:9.999999999999969e-311
if (out==64'h000012688B70E62B)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.0000000000e-200
//inputB:2.0000000000e+002
enable = 1'b1;
opa = 64'b0001011010001000011111101001001000010101010011101111011110101100;
opb = 64'b0100000001101001000000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:2.000000000000000e-202
if (out==64'h160F5A549627A36C)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.0000000000e+020
//inputB:2.0000000000e+002
enable = 1'b1;
opa = 64'b0100010000110101101011110001110101111000101101011000110001000000;
opb = 64'b0100000001101001000000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:2.000000000000000e+018
if (out==64'h43BBC16D674EC800)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:5.0000000000e+000
//inputB:2.5000000000e+000
enable = 1'b1;
opa = 64'b0100000000010100000000000000000000000000000000000000000000000000;
opb = 64'b0100000000000100000000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:2.000000000000000e+000
if (out==64'h4000000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:1.0000000000e-312
//inputB:1.0000000000e+000
enable = 1'b1;
opa = 64'b0000000000000000000000000010111100100000000111010100100111111011;
opb = 64'b0011111111110000000000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:9.999999999984653e-313
if (out==64'h0000002F201D49FB)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.8999000000e+004
//inputB:2.3600000000e+001
enable = 1'b1;
opa = 64'b0100000011100111111011001110000000000000000000000000000000000000;
opb = 64'b0100000000110111100110011001100110011001100110011001100110011010;
fpu_op = 3'b001;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:4.897540000000000e+004
if (out==64'h40E7E9ECCCCCCCCD)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.0000000000e-200
//inputB:3.0000000000e+111
enable = 1'b1;
opa = 64'b0001011010001000011111101001001000010101010011101111011110101100;
opb = 64'b0101011100010011111101011000110101000011010010100010101110101110;
fpu_op = 3'b011;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:1.333333333333758e-311
if (out==64'h0000027456DBDA6D)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:7.0000000000e-310
//inputB:8.0000000000e-100
enable = 1'b1;
opa = 64'b0000000000000000100000001101101111010000000101100100101100101101;
opb = 64'b0010101101011011111111110010111011100100100011100000010100110000;
fpu_op = 3'b011;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:8.749999999999972e-211
if (out==64'h14526914EEBBD470)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:1.4000000000e-311
//inputB:2.5000000000e-310
enable = 1'b1;
opa = 64'b0000000000000000000000101001001111000001100110100000101110111110;
opb = 64'b0000000000000000001011100000010101011100100110100011111101101011;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:5.599999999999383e-002
if (out==64'h3FACAC083126E600)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-4.0600000000e+001
//inputB:-3.5700000000e+001
enable = 1'b1;
opa = 64'b1100000001000100010011001100110011001100110011001100110011001101;
opb = 64'b1100000001000001110110011001100110011001100110011001100110011010;
fpu_op = 3'b000;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:-7.630000000000001e+001
if (out==64'hC053133333333334)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:3.4500000000e+002
//inputB:-3.4400000000e+002
enable = 1'b1;
opa = 64'b0100000001110101100100000000000000000000000000000000000000000000;
opb = 64'b1100000001110101100000000000000000000000000000000000000000000000;
fpu_op = 3'b000;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:1.000000000000000e+000
if (out==64'h3FF0000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:2.3770000000e+001
//inputB:-4.5000000000e+001
enable = 1'b1;
opa = 64'b0100000000110111110001010001111010111000010100011110101110000101;
opb = 64'b1100000001000110100000000000000000000000000000000000000000000000;
fpu_op = 3'b001;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:6.877000000000000e+001
if (out==64'h40513147AE147AE1)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-4.7700000000e+002
//inputB:4.8960000000e+002
enable = 1'b1;
opa = 64'b1100000001111101110100000000000000000000000000000000000000000000;
opb = 64'b0100000001111110100110011001100110011001100110011001100110011010;
fpu_op = 3'b010;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:-2.335392000000000e+005
if (out==64'hC10C82199999999A)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:2.0000000000e-311
//inputB:0.0000000000e+000
enable = 1'b1;
opa = 64'b0000000000000000000000111010111010000010010010011100011110100010;
opb = 64'b0000000000000000000000000000000000000000000000000000000000000000;
fpu_op = 3'b000;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:1.999999999999895e-311
if (out==64'h000003AE8249C7A2)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:0.0000000000e+000
//inputB:9.0000000000e+050
enable = 1'b1;
opa = 64'b0000000000000000000000000000000000000000000000000000000000000000;
opb = 64'b0100101010000011001111100111000010011110001011100011000100101101;
fpu_op = 3'b010;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:0.000000000000000e+000
if (out==64'h0000000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:5.4000000000e+001
//inputB:0.0000000000e+000
enable = 1'b1;
opa = 64'b0100000001001011000000000000000000000000000000000000000000000000;
opb = 64'b0000000000000000000000000000000000000000000000000000000000000000;
fpu_op = 3'b000;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:5.400000000000000e+001
if (out==64'h404B000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-6.7000000000e+001
//inputB:0.0000000000e+000
enable = 1'b1;
opa = 64'b1100000001010000110000000000000000000000000000000000000000000000;
opb = 64'b0000000000000000000000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:-1.#INF00000000000e+000
if (out==64'hFFEFFFFFFFFFFFFF)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-4.5600000000e+001
//inputB:-6.9000000000e+001
enable = 1'b1;
opa = 64'b1100000001000110110011001100110011001100110011001100110011001101;
opb = 64'b1100000001010001010000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:6.608695652173914e-001
if (out==64'h3FE525D7EE30F953)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-5.9900000000e+002
//inputB:2.7000000000e-002
enable = 1'b1;
opa = 64'b1100000010000010101110000000000000000000000000000000000000000000;
opb = 64'b0011111110011011101001011110001101010011111101111100111011011001;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:-2.218518518518519e+004
if (out==64'hC0D5AA4BDA12F685)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:2.1000000000e-308
//inputB:2.0000000000e-308
enable = 1'b1;
opa = 64'b0000000000001111000110011100001001100010100111001100111101010011;
opb = 64'b0000000000001110011000011010110011110000001100111101000110100100;
fpu_op = 3'b000;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:4.100000000000000e-308
if (out==64'h001D7B6F52D0A0F7)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:5.0000000000e-308
//inputB:2.0000000000e-312
enable = 1'b1;
opa = 64'b0000000000100001111110100001100000101100010000001100011000001101;
opb = 64'b0000000000000000000000000101111001000000001110101001001111110110;
fpu_op = 3'b000;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:5.000199999999999e-308
if (out==64'h0021FA474C5E1008)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:3.9800000000e+000
//inputB:3.7700000000e+000
enable = 1'b1;
opa = 64'b0100000000001111110101110000101000111101011100001010001111010111;
opb = 64'b0100000000001110001010001111010111000010100011110101110000101001;
fpu_op = 3'b000;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:7.750000000000000e+000
if (out==64'h401F000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.4000000000e+001
//inputB:7.9000000000e-002
enable = 1'b1;
opa = 64'b0100000001000110000000000000000000000000000000000000000000000000;
opb = 64'b0011111110110100001110010101100000010000011000100100110111010011;
fpu_op = 3'b000;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:4.407900000000000e+001
if (out==64'h40460A1CAC083127)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:5.0000000000e-311
//inputB:9.0000000000e+009
enable = 1'b1;
opa = 64'b0000000000000000000010010011010001000101101110000111001100010101;
opb = 64'b0100001000000000110000111000100011010000000000000000000000000000;
fpu_op = 3'b010;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:4.499999999999764e-301
if (out==64'h01934982FC467380)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-4.0000000000e-305
//inputB:2.0000000000e-008
enable = 1'b1;
opa = 64'b1000000010111100000101101100010111000101001001010011010101110101;
opb = 64'b0011111001010101011110011000111011100010001100001000110000111010;
fpu_op = 3'b010;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:-8.000000000007485e-313
if (out==64'h80000025B34AA196)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:3.0000000000e-308
//inputB:1.0000000000e-012
enable = 1'b1;
opa = 64'b0000000000010101100100101000001101101000010011011011101001110111;
opb = 64'b0011110101110001100101111001100110000001001011011110101000010001;
fpu_op = 3'b010;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:2.999966601548049e-320
if (out==64'h00000000000017B8)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:5.6999990000e+006
//inputB:5.6999989900e+006
enable = 1'b1;
opa = 64'b0100000101010101101111100110011111000000000000000000000000000000;
opb = 64'b0100000101010101101111100110011110111111010111000010100011110110;
fpu_op = 3'b001;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:9.999999776482582e-003
if (out==64'h3F847AE140000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-4.0000000000e+000
//inputB:9.0000000000e+000
enable = 1'b1;
opa = 64'b1100000000010000000000000000000000000000000000000000000000000000;
opb = 64'b0100000000100010000000000000000000000000000000000000000000000000;
fpu_op = 3'b001;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:-1.300000000000000e+001
if (out==64'hC02A000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:3.9700000000e+001
//inputB:2.5700000000e-002
enable = 1'b1;
opa = 64'b0100000001000011110110011001100110011001100110011001100110011010;
opb = 64'b0011111110011010010100010001100111001110000001110101111101110000;
fpu_op = 3'b001;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:3.967430000000001e+001
if (out==64'h4043D64F765FD8AF)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:2.3000000000e+000
//inputB:7.0000000000e-002
enable = 1'b1;
opa = 64'b0100000000000010011001100110011001100110011001100110011001100110;
opb = 64'b0011111110110001111010111000010100011110101110000101000111101100;
fpu_op = 3'b001;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:2.230000000000000e+000
if (out==64'h4001D70A3D70A3D7)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:1.9999999673e-316
//inputB:1.9999999673e-317
enable = 1'b1;
opa = 64'b0000000000000000000000000000000000000010011010011010111011000010;
opb = 64'b0000000000000000000000000000000000000000001111011100010010101101;
fpu_op = 3'b001;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:1.799999970587486e-316
if (out==64'h00000000022BEA15)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:1.9999999970e-315
//inputB:-1.9999999673e-316
enable = 1'b1;
opa = 64'b0000000000000000000000000000000000011000001000001101001110011010;
opb = 64'b1000000000000000000000000000000000000010011010011010111011000010;
fpu_op = 3'b001;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:2.199999993695311e-315
if (out==64'h000000001A8A825C)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:4.0000000000e+000
//inputB:1.0000000000e-025
enable = 1'b1;
opa = 64'b0100000000010000000000000000000000000000000000000000000000000000;
opb = 64'b0011101010111110111100101101000011110101110110100111110111011001;
fpu_op = 3'b001;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:4.000000000000000e+000
if (out==64'h4010000000000000)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:3.0000000000e-310
//inputB:4.0000000000e-304
enable = 1'b1;
opa = 64'b0000000000000000001101110011100110100010010100101011001010000001;
opb = 64'b0000000011110001100011100011101110011011001101110100000101101001;
fpu_op = 3'b000;
rmode = 2'b10;
#20000;
enable = 1'b0;
#800000;
//Output:4.000003000000000e-304
if (out==64'h00F18E3C781DCAB4)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:3.5000000000e-313
//inputB:7.0000000000e+004
enable = 1'b1;
opa = 64'b0000000000000000000000000001000001111110011100001010011010110001;
opb = 64'b0100000011110001000101110000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:4.999998683134458e-318
if (out==64'h00000000000F712B)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-5.1000000000e-306
//inputB:2.0480000000e+003
enable = 1'b1;
opa = 64'b1000000010001100101001101001011010000110100001110011101110100101;
opb = 64'b0100000010100000000000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:-2.490234375000003e-309
if (out==64'h8001CA69686873BB)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-1.5000000000e-305
//inputB:1.0240000000e+003
enable = 1'b1;
opa = 64'b1000000010100101000100010001010001010011110110111110100000011000;
opb = 64'b0100000010010000000000000000000000000000000000000000000000000000;
fpu_op = 3'b011;
rmode = 2'b11;
#20000;
enable = 1'b0;
#800000;
//Output:-1.464843750000000e-308
if (out==64'h800A888A29EDF40C)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:-3.4000000000e+056
//inputB:-4.0000000000e+199
enable = 1'b1;
opa = 64'b1100101110101011101110111000100000000000101110111001110000000101;
opb = 64'b1110100101100000101110001110000010101100101011000100111010101111;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:8.500000000000000e-144
if (out==64'h223A88ECC2AC8317)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);
//inputA:1.3559000000e-001
//inputB:2.3111240000e+003
enable = 1'b1;
opa = 64'b0011111111000001010110110000001101011011110101010001001011101100;
opb = 64'b0100000010100010000011100011111101111100111011011001000101101000;
fpu_op = 3'b011;
rmode = 2'b00;
#20000;
enable = 1'b0;
#800000;
//Output:5.866842281071894e-005
if (out==64'h3F0EC257A882625F)
	$display($time,"ps Answer is correct %h", out);
else
	$display($time,"ps Error! out is incorrect %h", out);

// end of paste
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
