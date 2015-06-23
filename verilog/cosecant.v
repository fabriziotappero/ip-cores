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

module cosecant_lut (quad, enable, degrees, data, rst, clk);

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

// look up table
	  
`INPUT_WIDTH'd0  : data[62:0] <= 64'h7ff0000000000000;
`INPUT_WIDTH'd1  : data[62:0] <= 64'h404ca63b6cba7b71;
`INPUT_WIDTH'd2  : data[62:0] <= 64'h403ca7596e271c86;
`INPUT_WIDTH'd3  : data[62:0] <= 64'h40331b797e990dc0;
`INPUT_WIDTH'd4  : data[62:0] <= 64'h402cabd2100d036c;
`INPUT_WIDTH'd5  : data[62:0] <= 64'h4026f28a8ae3ab08;
`INPUT_WIDTH'd6  : data[62:0] <= 64'h4023222ff85e6006;
`INPUT_WIDTH'd7  : data[62:0] <= 64'h402069387b617567;
`INPUT_WIDTH'd8  : data[62:0] <= 64'h401cbdbe5febffb0;
`INPUT_WIDTH'd9  : data[62:0] <= 64'h401991df41de341d;
`INPUT_WIDTH'd10 : data[62:0] <= 64'h401708fb2129168e;
`INPUT_WIDTH'd11 : data[62:0] <= 64'h4014f69f90704701;
`INPUT_WIDTH'd12 : data[62:0] <= 64'h40133d2b00047f03;
`INPUT_WIDTH'd13 : data[62:0] <= 64'h4011c819f29be025;
`INPUT_WIDTH'd14 : data[62:0] <= 64'h401088c56499f439;
`INPUT_WIDTH'd15 : data[62:0] <= 64'h400ee8dd4748bf16;
`INPUT_WIDTH'd16 : data[62:0] <= 64'h400d060d6ac58d68;
`INPUT_WIDTH'd17 : data[62:0] <= 64'h400b5cc824ec982e;
`INPUT_WIDTH'd18 : data[62:0] <= 64'h4009e3779b97f4a8;
`INPUT_WIDTH'd19 : data[62:0] <= 64'h4008928aa26c4c08;
`INPUT_WIDTH'd20 : data[62:0] <= 64'h400763f38fb4cf95;
`INPUT_WIDTH'd21 : data[62:0] <= 64'h400652cbf905707a;
`INPUT_WIDTH'd22 : data[62:0] <= 64'h40055b11998752c1;
`INPUT_WIDTH'd23 : data[62:0] <= 64'h40047974b96de77f;
`INPUT_WIDTH'd24 : data[62:0] <= 64'h4003ab32fb93a3a7;
`INPUT_WIDTH'd25 : data[62:0] <= 64'h4002edfb187b1137;
`INPUT_WIDTH'd26 : data[62:0] <= 64'h40023fd71f682341;
`INPUT_WIDTH'd27 : data[62:0] <= 64'h40019f1b8c9526f0;
`INPUT_WIDTH'd28 : data[62:0] <= 64'h40010a59ff3c94be;
`INPUT_WIDTH'd29 : data[62:0] <= 64'h40008056af82561d;
`INPUT_WIDTH'd30 : data[62:0] <= 64'h4000000000000001;
`INPUT_WIDTH'd31 : data[62:0] <= 64'h3fff10cf62336e31;
`INPUT_WIDTH'd32 : data[62:0] <= 64'h3ffe317ab5700fce;
`INPUT_WIDTH'd33 : data[62:0] <= 64'h3ffd6093ce555fa8;
`INPUT_WIDTH'd34 : data[62:0] <= 64'h3ffc9cd7b485648a;
`INPUT_WIDTH'd35 : data[62:0] <= 64'h3ffbe52877982347;
`INPUT_WIDTH'd36 : data[62:0] <= 64'h3ffb38880b4603e4;
`INPUT_WIDTH'd37 : data[62:0] <= 64'h3ffa9613f8fd7862;
`INPUT_WIDTH'd38 : data[62:0] <= 64'h3ff9fd01bf93f3a3;
`INPUT_WIDTH'd39 : data[62:0] <= 64'h3ff96c9bc1d2abfe;
`INPUT_WIDTH'd40 : data[62:0] <= 64'h3ff8e43eaadf9334;
`INPUT_WIDTH'd41 : data[62:0] <= 64'h3ff863573463a809;
`INPUT_WIDTH'd42 : data[62:0] <= 64'h3ff7e9603e24eb24;
`INPUT_WIDTH'd43 : data[62:0] <= 64'h3ff775e129d20b11;
`INPUT_WIDTH'd44 : data[62:0] <= 64'h3ff7086c7026f77e;
`INPUT_WIDTH'd45 : data[62:0] <= 64'h3ff6a09e667f3bcd;
`INPUT_WIDTH'd46 : data[62:0] <= 64'h3ff63e1c2d781ada;
`INPUT_WIDTH'd47 : data[62:0] <= 64'h3ff5e092c2857578;
`INPUT_WIDTH'd48 : data[62:0] <= 64'h3ff587b62f6162b4;
`INPUT_WIDTH'd49 : data[62:0] <= 64'h3ff53340d31354d5;
`INPUT_WIDTH'd50 : data[62:0] <= 64'h3ff4e2f2c0fa463b;
`INPUT_WIDTH'd51 : data[62:0] <= 64'h3ff4969132d53892;
`INPUT_WIDTH'd52 : data[62:0] <= 64'h3ff44de60b3c3d86;
`INPUT_WIDTH'd53 : data[62:0] <= 64'h3ff408bf665efb99;
`INPUT_WIDTH'd54 : data[62:0] <= 64'h3ff3c6ef372fe94f;
`INPUT_WIDTH'd55 : data[62:0] <= 64'h3ff3884aef684af8;
`INPUT_WIDTH'd56 : data[62:0] <= 64'h3ff34cab310ac280;
`INPUT_WIDTH'd57 : data[62:0] <= 64'h3ff313eb883ae677;
`INPUT_WIDTH'd58 : data[62:0] <= 64'h3ff2ddea2c696f6a;
`INPUT_WIDTH'd59 : data[62:0] <= 64'h3ff2aa87c7f7612b;
`INPUT_WIDTH'd60 : data[62:0] <= 64'h3ff279a74590331d;
`INPUT_WIDTH'd61 : data[62:0] <= 64'h3ff24b2da2943b49;
`INPUT_WIDTH'd62 : data[62:0] <= 64'h3ff21f01c602373d;
`INPUT_WIDTH'd63 : data[62:0] <= 64'h3ff1f50c5b61511e;
`INPUT_WIDTH'd64 : data[62:0] <= 64'h3ff1cd37b13ce9c7;
`INPUT_WIDTH'd65 : data[62:0] <= 64'h3ff1a76f9ad128b7;
`INPUT_WIDTH'd66 : data[62:0] <= 64'h3ff183a154932d8b;
`INPUT_WIDTH'd67 : data[62:0] <= 64'h3ff161bb6b4a03f3;
`INPUT_WIDTH'd68 : data[62:0] <= 64'h3ff141ada5766663;
`INPUT_WIDTH'd69 : data[62:0] <= 64'h3ff12368eecf1f68;
`INPUT_WIDTH'd70 : data[62:0] <= 64'h3ff106df459ea073;
`INPUT_WIDTH'd71 : data[62:0] <= 64'h3ff0ec03a9d451e4;
`INPUT_WIDTH'd72 : data[62:0] <= 64'h3ff0d2ca0da1530d;
`INPUT_WIDTH'd73 : data[62:0] <= 64'h3ff0bb27477cf20f;
`INPUT_WIDTH'd74 : data[62:0] <= 64'h3ff0a51105712a50;
`INPUT_WIDTH'd75 : data[62:0] <= 64'h3ff0907dc1930690;
`INPUT_WIDTH'd76 : data[62:0] <= 64'h3ff07d64b78dea34;
`INPUT_WIDTH'd77 : data[62:0] <= 64'h3ff06bbddb2b91b8;
`INPUT_WIDTH'd78 : data[62:0] <= 64'h3ff05b81cfc51885;
`INPUT_WIDTH'd79 : data[62:0] <= 64'h3ff04ca9e08b8cb6;
`INPUT_WIDTH'd80 : data[62:0] <= 64'h3ff03f2ff9989907;
`INPUT_WIDTH'd81 : data[62:0] <= 64'h3ff0330ea1b99998;
`INPUT_WIDTH'd82 : data[62:0] <= 64'h3ff02840f4e91085;
`INPUT_WIDTH'd83 : data[62:0] <= 64'h3ff01ec29f6be927;
`INPUT_WIDTH'd84 : data[62:0] <= 64'h3ff0168fd9895209;
`INPUT_WIDTH'd85 : data[62:0] <= 64'h3ff00fa563d53203;
`INPUT_WIDTH'd86 : data[62:0] <= 64'h3ff00a008406617c;
`INPUT_WIDTH'd87 : data[62:0] <= 64'h3ff0059f0252e0bc;
`INPUT_WIDTH'd88 : data[62:0] <= 64'h3ff0027f274d432f;
`INPUT_WIDTH'd89 : data[62:0] <= 64'h3ff0009fba3f7835;
`INPUT_WIDTH'd90 : data[62:0] <= 64'h3ff0000000000000;


default:data <= 64'h0;

endcase

else 
  data <= 64'hxxxxxxxxxxxxxxx;



end

endmodule
