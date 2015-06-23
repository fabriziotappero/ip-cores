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

module sine_lut (quad, enable, degrees, data, rst, clk);

input [1:0] quad;
input enable;
input rst;
input [`INPUT_WIDTH-1:0] degrees ;
input clk;

//////////////inputs/////////////////

output reg [63:0] data;

//////////////output/////////////////


always@(posedge clk )

// needs to be positive in first and second quadrants

   
   begin
        if (quad == 2'b10 || quad == 2'b11)
        begin
        data[63] <= 1'b1;
        end

        else
        begin
        data[63] <= 1'b0;
        end

	if(enable)
	case (degrees)
 
//look up table

`INPUT_WIDTH'd0  : data[62:0] <= 64'h0000000000000000;
`INPUT_WIDTH'd1  : data[62:0] <= 64'h3f91df0b2b89dd1e;
`INPUT_WIDTH'd2  : data[62:0] <= 64'h3fa1de58c9f7dc27;
`INPUT_WIDTH'd3  : data[62:0] <= 64'h3faacbc748efc90d;
`INPUT_WIDTH'd4  : data[62:0] <= 64'h3fb1db8f6d6a5128;
`INPUT_WIDTH'd5  : data[62:0] <= 64'h3fb64fd6b8c28102;
`INPUT_WIDTH'd6  : data[62:0] <= 64'h3fbac2609b3c576b;
`INPUT_WIDTH'd7  : data[62:0] <= 64'h3fbf32d44c4f62d3;
`INPUT_WIDTH'd8  : data[62:0] <= 64'h3fc1d06c968d9e19;
`INPUT_WIDTH'd9  : data[62:0] <= 64'h3fc4060b67a85375;
`INPUT_WIDTH'd10 : data[62:0] <= 64'h3fc63a1a7e0b7389;
`INPUT_WIDTH'd11 : data[62:0] <= 64'h3fc86c6ddd76624f;
`INPUT_WIDTH'd12 : data[62:0] <= 64'h3fca9cd9ac4258f5;
`INPUT_WIDTH'd13 : data[62:0] <= 64'h3fcccb3236cdc674;
`INPUT_WIDTH'd14 : data[62:0] <= 64'h3fcef74bf2e4b91d;
`INPUT_WIDTH'd15 : data[62:0] <= 64'h3fd0907dc1930690;
`INPUT_WIDTH'd16 : data[62:0] <= 64'h3fd1a40add328e29;
`INPUT_WIDTH'd17 : data[62:0] <= 64'h3fd2b637cf83d5c7;
`INPUT_WIDTH'd18 : data[62:0] <= 64'h3fd3c6ef372fe94f;
`INPUT_WIDTH'd19 : data[62:0] <= 64'h3fd4d61bd000cddc;
`INPUT_WIDTH'd20 : data[62:0] <= 64'h3fd5e3a8748a0bf5;
`INPUT_WIDTH'd21 : data[62:0] <= 64'h3fd6ef801fced33c;
`INPUT_WIDTH'd22 : data[62:0] <= 64'h3fd7f98deee59681;
`INPUT_WIDTH'd23 : data[62:0] <= 64'h3fd901bd2298ffaa;
`INPUT_WIDTH'd24 : data[62:0] <= 64'h3fda07f921061ad0;
`INPUT_WIDTH'd25 : data[62:0] <= 64'h3fdb0c2d77379853;
`INPUT_WIDTH'd26 : data[62:0] <= 64'h3fdc0e45dabe05c8;
`INPUT_WIDTH'd27 : data[62:0] <= 64'h3fdd0e2e2b44de00;
`INPUT_WIDTH'd28 : data[62:0] <= 64'h3fde0bd274245079;
`INPUT_WIDTH'd29 : data[62:0] <= 64'h3fdf071eedefa0ed;
`INPUT_WIDTH'd30 : data[62:0] <= 64'h3fdfffffffffffff;
`INPUT_WIDTH'd31 : data[62:0] <= 64'h3fe07b3120fddf13;
`INPUT_WIDTH'd32 : data[62:0] <= 64'h3fe0f5193eacdd2a;
`INPUT_WIDTH'd33 : data[62:0] <= 64'h3fe16daed770771c;
`INPUT_WIDTH'd34 : data[62:0] <= 64'h3fe1e4e88411fd12;
`INPUT_WIDTH'd35 : data[62:0] <= 64'h3fe25abcf87c4978;
`INPUT_WIDTH'd36 : data[62:0] <= 64'h3fe2cf2304755a5e;
`INPUT_WIDTH'd37 : data[62:0] <= 64'h3fe342119455beb6;
`INPUT_WIDTH'd38 : data[62:0] <= 64'h3fe3b37fb1bdc939;
`INPUT_WIDTH'd39 : data[62:0] <= 64'h3fe4236484487abe;
`INPUT_WIDTH'd40 : data[62:0] <= 64'h3fe491b7523c161c;
`INPUT_WIDTH'd41 : data[62:0] <= 64'h3fe4fe6f81384fd4;
`INPUT_WIDTH'd42 : data[62:0] <= 64'h3fe5698496e20bd8;
`INPUT_WIDTH'd43 : data[62:0] <= 64'h3fe5d2ee398c9c2b;
`INPUT_WIDTH'd44 : data[62:0] <= 64'h3fe63aa430e07310;
`INPUT_WIDTH'd45 : data[62:0] <= 64'h3fe6a09e667f3bcc;
`INPUT_WIDTH'd46 : data[62:0] <= 64'h3fe704d4e6a54d38;
`INPUT_WIDTH'd47 : data[62:0] <= 64'h3fe7673fe0c86982;
`INPUT_WIDTH'd48 : data[62:0] <= 64'h3fe7c7d7a833bec1;
`INPUT_WIDTH'd49 : data[62:0] <= 64'h3fe82694b4a11c36;
`INPUT_WIDTH'd50 : data[62:0] <= 64'h3fe8836fa2cf5039;
`INPUT_WIDTH'd51 : data[62:0] <= 64'h3fe8de613515a327;
`INPUT_WIDTH'd52 : data[62:0] <= 64'h3fe9376253f463d1;
`INPUT_WIDTH'd53 : data[62:0] <= 64'h3fe98e6c0ea27a14;
`INPUT_WIDTH'd54 : data[62:0] <= 64'h3fe9e3779b97f4a8;
`INPUT_WIDTH'd55 : data[62:0] <= 64'h3fea367e59158747;
`INPUT_WIDTH'd56 : data[62:0] <= 64'h3fea8779cda8eea5;
`INPUT_WIDTH'd57 : data[62:0] <= 64'h3fead663a8ae2fdb;
`INPUT_WIDTH'd58 : data[62:0] <= 64'h3feb2335c2cda945;
`INPUT_WIDTH'd59 : data[62:0] <= 64'h3feb6dea1e76eadd;
`INPUT_WIDTH'd60 : data[62:0] <= 64'h3febb67ae8584caa;
`INPUT_WIDTH'd61 : data[62:0] <= 64'h3febfce277d339c6;
`INPUT_WIDTH'd62 : data[62:0] <= 64'h3fec411b4f6d2707;
`INPUT_WIDTH'd63 : data[62:0] <= 64'h3fec83201d3d2c6c;
`INPUT_WIDTH'd64 : data[62:0] <= 64'h3fecc2ebbb5638ca;
`INPUT_WIDTH'd65 : data[62:0] <= 64'h3fed0079302dd767;
`INPUT_WIDTH'd66 : data[62:0] <= 64'h3fed3bc3aeff7f95;
`INPUT_WIDTH'd67 : data[62:0] <= 64'h3fed74c6982c666f;
`INPUT_WIDTH'd68 : data[62:0] <= 64'h3fedab7d7997cb57;
`INPUT_WIDTH'd69 : data[62:0] <= 64'h3feddfe40effb805;
`INPUT_WIDTH'd70 : data[62:0] <= 64'h3fee11f642522d1b;
`INPUT_WIDTH'd71 : data[62:0] <= 64'h3fee41b02bfeb4ca;
`INPUT_WIDTH'd72 : data[62:0] <= 64'h3fee6f0e134454ff;
`INPUT_WIDTH'd73 : data[62:0] <= 64'h3fee9a0c6e7bdb1f;
`INPUT_WIDTH'd74 : data[62:0] <= 64'h3feec2a7e35e7b80;
`INPUT_WIDTH'd75 : data[62:0] <= 64'h3feee8dd4748bf15;
`INPUT_WIDTH'd76 : data[62:0] <= 64'h3fef0ca99f79ba25;
`INPUT_WIDTH'd77 : data[62:0] <= 64'h3fef2e0a214e870f;
`INPUT_WIDTH'd78 : data[62:0] <= 64'h3fef4cfc327a0080;
`INPUT_WIDTH'd79 : data[62:0] <= 64'h3fef697d6938b6c2;
`INPUT_WIDTH'd80 : data[62:0] <= 64'h3fef838b8c811c17;
`INPUT_WIDTH'd81 : data[62:0] <= 64'h3fef9b24942fe45c;
`INPUT_WIDTH'd82 : data[62:0] <= 64'h3fefb046a930947a;
`INPUT_WIDTH'd83 : data[62:0] <= 64'h3fefc2f025a23e8b;
`INPUT_WIDTH'd84 : data[62:0] <= 64'h3fefd31f94f867c6;
`INPUT_WIDTH'd85 : data[62:0] <= 64'h3fefe0d3b41815a2;
`INPUT_WIDTH'd86 : data[62:0] <= 64'h3fefec0b7170fff6;
`INPUT_WIDTH'd87 : data[62:0] <= 64'h3feff4c5ed12e61d;
`INPUT_WIDTH'd88 : data[62:0] <= 64'h3feffb0278bf0567;
`INPUT_WIDTH'd89 : data[62:0] <= 64'h3feffec097f5af8a;
`INPUT_WIDTH'd90 : data[62:0] <= 64'h3ff0000000000000;

default:data <= 64'h0;

endcase

else 
  data <= 64'hxxxxxxxxxxxxxxx;



end


endmodule
