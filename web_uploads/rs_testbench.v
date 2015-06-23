/////////////////////////////////////////////////////////////////////
////                                                             ////
////  High Speed Reed Solomon Encoder                            ////
////                                                             ////
////                                                             ////
////  Author: Rajesh Pathak                                      ////
////          rajesh_99@opencores.org                            ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2003 Rajesh Pathak                            ////
////                         rajesh_99@netzero.net               ////
////                         Exponentiation Technology           ////
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



module teststim( );
wire  [7:0] q0, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, 
q15;

reg clk, valid;
reg [7:0] datain;
wire[7:0] gin0, gin1, gin2, gin3, gin4, gin5, gin6, gin7, gin8, gin9, gin10, 
gin11, gin12, gin13, gin14, gin15;
reg rst;
reg [31:0] tmp_reg1, tmp_reg2, tmp_reg3, tmp_reg4;
wire [7:0] fbck, in, m0, z0, gin, sdrome;
integer seed;
integer seed1;
initial begin
clk = 0;
rst = 1'b1;
datain = 8'h06;
#2 rst = 1'b0;
#1 rst = 1'b1;

//Start feeding message data here one  byte at every clock.

#1 datain =  8'h06;
valid = 1;
$dumpfile ("xxx.dump");
$dumpvars (2, teststim);

#10 datain =  8'hF0;
#10 datain =  8'h82;
#10 datain =  8'hEE;
#10 datain =  8'h71;
#10 datain =  8'h04;
#10 datain =  8'h24;
#10 datain =  8'h9A;
#10 datain =  8'hEA;
#10 datain =  8'h6E;
#10 datain =  8'hEF;
#10 datain =  8'hDD;
#10 datain = $random(seed1);
#10 datain = $random(seed);
#10 datain = $random(seed1);
#10 datain = $random(seed);
#10 datain = $random(seed1);
#10 datain = $random(seed);
#10 datain = $random(seed);
#10 datain =  8'hF0;
#10 datain =  8'hAC;
#10 datain =  8'h1C;



//Continue upto 239 bytes. Here only a partial list has been fed.


//End feeding message data. The registers contain parity bytes now. The parity and
//message bytes togather form code bytes.  
//From next clock cylcle on, the parity bytes generated is fed into the machine as if the 
//parity bytes are message bytes. In other words, the entire code polynomial is shifted
// into the machine. This will result in zero register values at the end of shift 
//sequence. Reason: code polynomial divides generator polynomial so the remainder should be zero.

//Feeding message polynomial followed by remainder polynomial implies code polynomial has been
//fed to the machine. This implies the contents of registers q15, q14, ...........q1. q0 contains
//the remainder of division between code polynomial and generator polynomial. The result should be
//all zero bytes. Check to see contents of q15........q0 are 8'h00.

 #4 tmp_reg1 = {q3, q2, q1, q0};
   tmp_reg2 = {q7, q6, q5, q4};
   tmp_reg3 = {q11, q10, q9, q8};
   tmp_reg4 = {q15, q14, q13, q12}; 
#6 datain = tmp_reg4[31:24];
#10 datain = tmp_reg4[23:16];
#10 datain = tmp_reg4[15:8];
#10 datain = tmp_reg4[7:0];

#10 datain = tmp_reg3[31:24];
#10 datain = tmp_reg3[23:16];
#10 datain = tmp_reg3[15:8];
#10 datain = tmp_reg3[7:0];

#10 datain = tmp_reg2[31:24];
#10 datain = tmp_reg2[23:16];
#10 datain = tmp_reg2[15:8];
#10 datain = tmp_reg2[7:0];

#10 datain = tmp_reg1[31:24];
#10 datain = tmp_reg1[23:16];
#10 datain = tmp_reg1[15:8];
#10 datain = tmp_reg1[7:0];

//Stop the state machine after the entire code polynomial is shifted, using valid signal. Pulling valid low will
// freeze the machine with its register contents.

#10 valid = 0;
#30 $finish;
end

always #5 clk = ~clk;

//assign generator polynomial co-efficients here. The generator polynomial is
//of form X^16+g15X^15+g14X^14 + ..................+g1X+g0;
//Each gi (i=0, 1, ...15) is an element of GF(2^8);
//Here they have been randomly assigned. Assign actual values.

assign gin0 = 8'b00010000; 
assign gin1 = 8'hAB;
assign gin2 = 8'hCD;
assign gin3 = 8'h8E;
assign gin4 = 8'h93;
assign gin5=8'hAB; assign gin6=8'h8E; assign gin7=8'hCD;
assign gin8=8'hFA;
assign gin9=8'hEE; assign gin10=8'hFF; assign gin11=8'h0C; assign gin12=8'hAB;
assign gin13= 8'h26; assign gin14=8'h35; assign gin15=8'h89;

rs_encode U1(datain, valid, gin0, gin1, gin2, gin3, gin4, gin5, gin6, gin7, gin8, gin9, 
gin10, gin11, gin12, gin13, gin14, gin15, q0, q1, q2, q3, q4, q5, q6, q7, q8, 
q9, q10, q11, q12, q13, q14, q15, rst, clk);
endmodule


