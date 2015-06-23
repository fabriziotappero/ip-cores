
`define MAX(a,b) ( (a)>(b)? (a):(b) )
`define ABS(a) ( (a)>0? (a):(-(a)) )

//============================= XOR VARIATION ===================================

//module Ibniz_generator7z ( clk, rst, ena, T_in, X_in, Y_in, V_out );
//
//input clk;
//input rst;
//input ena;
//input wire signed [31:0] T_in;
//input wire signed [31:0] X_in;
//input wire signed [31:0] Y_in;
//output reg [31:0] V_out;
//
//wire [31:0] XxY= ( X_in+ (X_in <<T_in[28:24] ) )^ ( Y_in + T_in[26:10] ) ;
//wire [31:0] V0= XxY+ (T_in>>7);
//
//always@(posedge clk or posedge rst)
//begin
//	if ( rst )
//	begin
//	end
//	else if ( ena )
//	begin
//	//	**
////		XY <=((XX_in * YY_in)>>>16);
////		V_out<= ( XY * (TT_in))>>>16;
//	//	^x7r+Md8r& (xor exch ror(7) +   )
//		V_out= V0 + ((V0<<(T_in[29:25])) & 32'hFFFF0000 );
//	end
//end
//endmodule

module Ibniz_Stars ( clk, rst, ena, T_in, X_in, Y_in, V_out );

input clk;
input rst;
input ena;
input wire signed [31:0] T_in;
input wire signed [31:0] X_in;
input wire signed [31:0] Y_in;
output reg [31:0] V_out;

reg [31:0] R1;
reg [31:0] R2;
reg [31:0] R3;
reg [31:0] G1;
reg [31:0] G2;
reg [31:0] G3;

always@(posedge clk or posedge rst)
begin
	if ( rst )
	begin
	end
	else if ( ena )
	begin
		R1 <= (((X_in+T_in[31:12])>>>7)) * 11713 + ((Y_in>>>8)+(Y_in)) * 5422133;
		R2 <= R1 * 7 + (R1>>8)*1817 ;
		R3 <= { R2[7:0],R2[15:8],R2[23:16], R2[7:0] ^ R2[15:8] ^ R2[23:16] ^ R2[31:24] };
	//	**
		V_out <= R3[7:0] ? 0 : R3[8] ? -1 : R3;
	end
end
endmodule

//============================= ATAN2 ===================================
module Ibniz_generator0 ( clk, rst, ena, T_in, _X_in, _Y_in, V_out, dbg_out );

input clk;
input rst;
input ena;
input wire signed [31:0] T_in;
input wire signed [31:0] _X_in;
input wire signed [31:0] _Y_in;
output reg [31:0] V_out;
output reg signed [63:0] dbg_out;

wire signed [31:0] X_in=  _X_in/2;
wire signed [31:0] Y_in=  _Y_in/2;

always@(posedge clk or posedge rst)
begin
	if ( rst )
	begin
	end
	else if ( ena )
	begin
		//	&*
//		V_out= ((d_out<<<4)+(T_in>>>6))^(s_out>>6);
		V_out= 
//					`ABS(_X_in) > 32'hF800 ? 0: 
													V0;// + ((V0<<(T_in[29:25])) & 32'hFFFF0000 );
	end
end

//wire [31:0] V0= ((d_out-(T_in>>>14)) *20) ^((div_out>>>12)+(T_in>>>8));//((a_out[23:16]==Y_in[15:8])? -1:0);

wire [31:0] V0;

wire signed [31:0] T_sin;
PseudoSin ( clk, rst, ena, T_in>>>7, T_sin, _ );


Psin_Texture ( clk, rst, ena, T_in, ((d_out-(T_sin>>>7)-(T_in>>>13)) *20), ((div_out>>>12)+(T_sin)+(T_in>>>5)), V0 );
//Psin_Texture ( clk, rst, ena, T_in, ((d_out-(T_in>>>13)) *20), ((div_out>>>12)+(T_in>>>7)), V0 );

wire signed [31:0] s_out;
wire signed [31:0] a_out;
wire signed [31:0] a_outm;
wire signed [31:0] d_out;
wire signed [31:0] XX= ( (X_in) *(X_in) )>>12;
wire signed [31:0] YY= ( Y_in*Y_in)>>12;
wire signed [31:0] XXYY= XX+YY;

atan2_pipelined atan( clk, X_in, Y_in, a_out, _ );

defparam atan.IS_IBNIZ= 1;
//div_pipelined mydiv( clk, a_out<<12, pix2, d_out );
id_pipelined id( clk, a_out, d_out );
defparam id.DELAY= 16;
sqrt_pipelined sqrt1( clk, XXYY, s_out, _ );

wire signed [31:0] sin_a;
wire signed [31:0] cos_a;
wire signed [31:0] sin_q;
wire signed [31:0] div_out;

div_pipelined div1( clk, 48'h400000000000, XXYY, div_out );
defparam div1.BITS= 48;								

endmodule



//============================= CIRCLES ===================================
//module Ibniz_generator7y ( clk, rst, ena, T_in, X_in, Y_in, V_out, dbg_out );
//
//input clk;
//input rst;
//input ena;
//input wire signed [31:0] T_in;
//input wire signed [35:0] X_in;
//input wire signed [35:0] Y_in;
//output reg [31:0] V_out;
//output reg signed [63:0] dbg_out;
//
//always@(posedge clk or posedge rst)
//begin
//	if ( rst )
//	begin
//	end
//	else if ( ena )
//	begin
//		//	&*
//		V_out= s_out*(T_in>>16);
//	end
//end
//
//wire signed [31:0] s_out;
//wire signed [31:0] d_out;
//sqrt_pipelined sqrt1( clk, (X_in*X_in+Y_in*Y_in)>>>16, s_out, d_out );
//
//wire signed [31:0] XXX = X_in<<16;
//wire signed [31:0] XXX2 = (X_in-16*128);
//wire signed [31:0] YYY = Y_in<<16;
//wire signed [31:0] YYY_p = (YYY-256);
//wire signed [31:0] g_out = (YYY==0 || XXX==0 || X_in==32'h8000 || Y_in==(-32'h8000) ) ? -16'sh1 : 
//													((YYY >= s_out /*&& YYY_p<-s_out*/) ? 32'h33338000 : 32'h0)
////									         +(  (YYY >= d_out /*&& YYY_p<-d_out*/) ? 32'hCC008000 : 32'h0)
////									         +(  (YYY >= -c_out && YYY_p<-c_out) ? 32'h88888000 : 32'h0)
//												;
//
//endmodule

//

