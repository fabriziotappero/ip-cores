/////////////////////////////////////////////////////////////////////
////                                                             ////
////                                                          ////
////  Trigonometric functions using double precision Floating Point Unit        ////
////                                                             ////
////  Author: Muni Aditya                                        ////
////          muni_aditya@yahoo.com                                ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2013 Muni Aditya                           ////
////                  muni_aditya@yahoo.com                        ////
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

`timescale 1ns / 100ps

`define INPUT_WIDTH 32

module top( enable, degrees, data1, rst, actv, clk) ;


input enable;
input [`INPUT_WIDTH-1:0] degrees ;
input rst;
input [2:0] actv;
input clk;

//////////////inputs/////////////////

output reg [63:0] data1;

//////////////output/////////////////


reg [63:0] data;
reg [`INPUT_WIDTH-1:0] half_wave;
reg [`INPUT_WIDTH-1:0] full_wave;
reg [63:0] data_tmp;
reg [`INPUT_WIDTH-1:0] degrees_tmp1;
reg [`INPUT_WIDTH-1:0] degrees_tmp2;
reg [1:0] quad;
reg sin_enable, cos_enable, tan_enable, csc_enable, sec_enable, cot_enable;

//////////////registers/////////////////

wire [63:0] data_sin, data_cos, data_tan, data_csc, data_sec, data_cot;
wire [`INPUT_WIDTH-1:0] divider_out;

//////////////wires/////////////////


sine_lut      a1 (.quad(quad), .enable(sin_enable) , .degrees(degrees_tmp2) , .data(data_sin), .rst(rst), .clk(clk));

cosine_lut    a2 (.quad(quad), .enable(cos_enable) , .degrees(degrees_tmp2) , .data(data_cos), .rst(rst), .clk(clk));

tangent_lut   a3 (.quad(quad), .enable(tan_enable) , .degrees(degrees_tmp2) , .data(data_tan), .rst(rst), .clk(clk));

cosecant_lut  a4 (.quad(quad), .enable(csc_enable) , .degrees(degrees_tmp2) , .data(data_csc), .rst(rst), .clk(clk));

secant_lut    a5 (.quad(quad), .enable(sec_enable) , .degrees(degrees_tmp2) , .data(data_sec), .rst(rst), .clk(clk));

cotangent_lut a6 (.quad(quad), .enable(cot_enable) , .degrees(degrees_tmp2) , .data(data_cot), .rst(rst), .clk(clk));

dividor a7 (.clk(clk), .inp(degrees), .rst(rst), .out(divider_out));
  
  

    

always@(posedge clk)

begin

	if (rst)
	begin
	
	sin_enable	<= 0;
	cos_enable	<= 0;
	tan_enable	<= 0;
	csc_enable	<= 0;
	sec_enable	<= 0;
	cot_enable	<= 0;
	
	end

	else
	begin
	sin_enable <= (actv == 3'b000) ? enable : 1'b0 ;
	cos_enable <= (actv == 3'b001) ? enable : 1'b0 ;
	tan_enable <= (actv == 3'b010) ? enable : 1'b0 ;
	csc_enable <= (actv == 3'b011) ? enable : 1'b0 ;
	sec_enable <= (actv == 3'b100) ? enable : 1'b0 ;
	cot_enable <= (actv == 3'b101) ? enable : 1'b0 ;
	end
end



 /////////// degress calculation////////////
 
 always@(posedge clk)
  begin
    if( degrees > `INPUT_WIDTH'd360)
	begin
	  
//////////////// If input value greater than 360 ///////////////
	  
  if (divider_out > `INPUT_WIDTH'd270)
	begin
	quad <= 2'b11;
	degrees_tmp2 <= divider_out - `INPUT_WIDTH'd270;
   	end
   else

	if (divider_out > `INPUT_WIDTH'd180 && (divider_out < `INPUT_WIDTH'd270 || divider_out == `INPUT_WIDTH'd270))
	begin
	quad <= 2'b10;
	degrees_tmp2 <= divider_out - `INPUT_WIDTH'd180;
	end
	else
	  
	if (divider_out > `INPUT_WIDTH'd90 && (divider_out < `INPUT_WIDTH'd180 || divider_out == `INPUT_WIDTH'd180))
		begin
		degrees_tmp2 <= `INPUT_WIDTH'd180 - divider_out;
		quad <= 2'b01;
		end
	else
		begin
		degrees_tmp2 <= divider_out;
		quad <= 2'b00;
		end
	end  // >360
	////////////////////////end of divider///////////////////
   else

 

////////////// If input value is between 181 and 360//////////
  
   if (degrees > `INPUT_WIDTH'd180 && (degrees < `INPUT_WIDTH'd360 || degrees == `INPUT_WIDTH'd360))
	begin
	degrees_tmp1 <= degrees - `INPUT_WIDTH'd180;
	
	begin
	  if(degrees_tmp1 >`INPUT_WIDTH'd90)
	    begin
	      quad <= 2'b11;
	      degrees_tmp2 <= `INPUT_WIDTH'd180 - degrees_tmp1;
	      end
	      
	      else
	        begin
	          quad <= 2'b10;
	        degrees_tmp2 <= degrees_tmp1;
	         end
	         
	         end
	
	end
   else

//////////// If input value is between 91 and 180//////////////

   if (degrees > `INPUT_WIDTH'd90 && (degrees < `INPUT_WIDTH'd180 || degrees == `INPUT_WIDTH'd180))
	begin
	quad <= 2'b01;
	degrees_tmp2 <= `INPUT_WIDTH'd180 - degrees;
	end
   else

	begin
	quad <= 2'b00;
	degrees_tmp2 <= degrees;
	end
 	
end		
      
 always@(posedge clk)

  begin
    case (actv)
3'b000:         data1 <= data_sin;
3'b001:         data1 <= data_cos;
3'b010:         data1 <= data_tan;
3'b011:         data1 <= data_csc;
3'b100:         data1 <= data_sec;
3'b101:         data1 <= data_cot;
default:        data1 <= 0;
endcase


end


endmodule
