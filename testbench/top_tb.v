/////////////////////////////////////////////////////////////////////
////                                                             ////
////                                                             ////
////  Trigonometric functions using                              ////
////  double precision Floating Point Unit                       ////
////                                                             ////
////  Author: Muni Aditya                                        ////
////          muni_aditya@yahoo.com                              ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2013 Muni Aditya                              ////
////                  muni_aditya@yahoo.com                      ////
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

`include "../verilog/sine.v"
`include "../verilog/cosine.v"
`include "../verilog/tangent.v"
`include "../verilog/cosecant.v"
`include "../verilog/secant.v"
`include "../verilog/cotangent.v"
`include "../verilog/divider.v"
`include "../verilog/top.v"


`timescale 1ns / 100ps

`define INPUT_WIDTH 32

/*
3'b000:		sin
3'b001:		cos
3'b010:		tan
3'b011:		csc
3'b100:	 	sec
3'b101:  		cot

*/


module top_tb;


reg enable;
reg [`INPUT_WIDTH-1:0] degrees ;
reg rst;
reg [2:0] actv;
reg clk;
wire [63:0] data1;


top u1 (.enable(enable), .degrees(degrees), .data1(data1), .rst(rst), .actv(actv), .clk(clk));

always  #5 clk = !clk;

initial



begin
  rst = 1'b0 ;
  clk = 1'b0 ;
 #100
 @(posedge clk) ;
  rst <= 1'b0 ;
  
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 enable <= 1'b1;


#50 


  degrees <= `INPUT_WIDTH'd1023;
  actv <= 3'b101;
  enable = 1'b1;

 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 if (data1==64'hbff8a34971bd7010)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);
 
   
  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd112;
  actv <= 3'b010;
  enable <= 1'b1;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
   if (data1==64'hc003ccfa561175d3)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);


  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd199;
  actv <= 3'b001;
  enable <= 1'b1;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  if (data1==64'hbfee41b02bfeb4cb)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);


  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd286;
  actv <= 3'b011;
  enable <= 1'b1;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
   if (data1==64'hbff0a51105712a50)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);


  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd400;
  actv <= 3'b000;
  enable <= 1'b1;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  if (data1==64'h3fe491b7523c161c)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);



  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd90;
  actv <= 3'b100;
  enable <= 1'b1;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
   if (data1==64'h7ff0000000000000)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);



  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd156;
  actv <= 3'b101;
  enable <= 1'b1;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  if (data1==64'hc001f7e220cc4172)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);


 @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd8769;
  actv <= 3'b001;
  enable = 1'b1;

 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
  if (data1==64'hbfe4236484487abe)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);



  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd2240;
  actv <= 3'b101;
  enable = 1'b1;

 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 if (data1==64'h3fc691e1ebc5cbbf)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);




  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd346;
  actv <= 3'b000;
  enable = 1'b1;

 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
  if (data1==64'hbfcef74bf2e4b91d)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);



  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd789;
  actv <= 3'b010;
  enable = 1'b1;

 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
   if (data1==64'h4004d738ef803785)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);




  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd869;
  actv <= 3'b100;
  enable = 1'b1;

 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
   if (data1==64'hbff2aa87c7f7612a)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);




  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd1027;
  actv <= 3'b011;
  enable = 1'b1;

 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
  if (data1==64'hbffa9613f8fd7862)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);




  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd12679;
  actv <= 3'b000;
  enable = 1'b1;

 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
  if (data1==64'h3fef697d6938b6c2)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);



  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd127;
  actv <= 3'b100;
  enable = 1'b1;

 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
  if (data1==64'hbffa9613f8fd7861)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);





  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd40;
  actv <= 3'b101;
  enable = 1'b1;

 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 if (data1==64'h3ff3116c3711527e)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);





  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd299;
  actv <= 3'b010;
  enable = 1'b1;

 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
  if (data1==64'hbffcdd612dd501f3)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);



 
  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd186;
  actv <= 3'b001;
  enable = 1'b1;

 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
  if (data1==64'hbfefd31f94f867c6)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);




  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd225;
  actv <= 3'b001;
  enable = 1'b1;

 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
  if (data1==64'hbfe6a09e667f3bcd)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);




  @(posedge clk) ;
  @(posedge clk) ;
  @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd9999;
  actv <= 3'b000;
  enable = 1'b1;

 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
  if (data1==64'hbfc4060b67a85375)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);




 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd1800;
  actv <= 3'b010;
  enable = 1'b1;

 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
   if (data1==64'h0000000000000000)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);




 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
  degrees <= `INPUT_WIDTH'd4020;
  actv <= 3'b011;
  enable = 1'b1;

 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
 @(posedge clk) ;
    if (data1==64'h3ff279a74590331d)
	$display($time,"ps For input %d Answer is correct %h", degrees, data1);
else
	$display($time,"ps Error! for input %d out is incorrect %h", degrees, data1);




  #50
  
  $finish;
  
  end
 initial begin
	$dumpfile("fpu.vcd");
	$dumpvars;
end 
  
endmodule
