
`define MAX(a,b) ( (a)>(b)? (a):(b) )

module Ibniz_generator1 ( clk, rst, ena, T_in, X_in, Y_in, V_out );

input clk;
input rst;
input ena;
input wire signed [31:0] T_in;
input wire signed [31:0] X_in;
input wire signed [31:0] Y_in;
output reg [31:0] V_out;

wire [31:0] XxY= X_in^Y_in;

always@(posedge clk or posedge rst)
begin
	if ( rst )
	begin
	end
	else if ( ena )
	begin
	//	**
//		XY <=((XX_in * YY_in)>>>16);
//		V_out<= ( XY * (TT_in))>>>16;
	//	^x7r+Md8r& (xor exch ror(7) +   )
		V_out= XxY+ (T_in>>7) + (T_in<<(32-7));
	end
end
endmodule

module Ibniz_generator2 ( clk, rst, ena, T_in, X_in, Y_in, V_out, dbg_out );

input clk;
input rst;
input ena;
input wire signed [31:0] T_in;
input wire signed [31:0] X_in;
input wire signed [31:0] Y_in;
output reg [31:0] V_out;
output reg [63:0] dbg_out;

wire signed [47:0] XY= Y_in+X_in+(X_in>>>6);
wire signed [31:0] d_out;

wire done;

div_pipelined div1( clk, {T_in, 16'h0}, (/*XY[31]?-XY:*/XY), d_out );

//defparam div1.BITS= 48;

always@(posedge clk or posedge rst)
begin
	if ( rst )
	begin
	end
	else if ( ena )
	begin
//		if (done)
		begin
		//	+/
			V_out<= d_out;
			dbg_out[31:0]<= X_in+Y_in;
			dbg_out[63:32]<= T_in>>>16;
		end
//		else
//			V_out<= V_out>>>1;
	end
end
endmodule

////============================= PERLIN NOISE ===================================


//module Ibniz_generator7d ( clk, rst, ena, T_in, X_in, Y_in, V_out, dbg_out );
//
//`define NSCALE 14
//
//input clk;
//input rst;
//input ena;
//input wire signed [31:0] T_in;
//input wire signed [31:0] X_in;
//input wire signed [31:0] Y_in;
//output reg [31:0] V_out;
//output reg [63:0] dbg_out;
//
//wire signed [31:0] XX= (X_in>>>`NSCALE);
//wire signed [31:0] YY= (Y_in>>>`NSCALE);
//reg signed [31:0] GX00;
//reg signed [31:0] GY00;
//reg signed [31:0] GX01;
//reg signed [31:0] GY01;
//reg signed [31:0] GX10;
//reg signed [31:0] GY10;
//reg signed [31:0] GX11;
//reg signed [31:0] GY11;
//reg signed [31:0] rx00;
//reg signed [31:0] ry00;
//reg signed [31:0] rx01;
//reg signed [31:0] ry01;
//reg signed [31:0] rx10;
//reg signed [31:0] ry10;
//reg signed [31:0] rx11;
//reg signed [31:0] ry11;
//reg signed [31:0] r00;
//reg signed [31:0] r10;
//reg signed [31:0] r01;
//reg signed [31:0] r11;
//wire signed [31:0] _MX= (X_in - (XX<<<`NSCALE));//& (T_in[24]?(-1):((32'h1<<<`NSCALE) - 1));
//wire signed [31:0] _MY= (Y_in - (YY<<<`NSCALE));//& (T_in[24]?(-1):((32'h1<<<`NSCALE) - 1));
//reg signed [31:0] __MX;
//reg signed [31:0] __MY;
//reg signed [31:0] MX;
//reg signed [31:0] MY;
//reg signed [31:0] v1;
//reg signed [31:0] v2;
//reg signed [31:0] v3;
//reg signed [31:0] v4;
//wire signed [31:0] d_out;
//
//wire done;
//
////defparam div1.BITS= 48;
//
//always@(posedge clk or posedge rst)
//begin
//	if ( rst )
//	begin
//	end
//	else if ( ena )
//	begin
////		if (done)
//		begin
//		//	+/
//		  GX00<= XX * 16'h7353 + YY * 16'hacd7 ;
////		  GY00<= XX * 16'ha689 + YY * 16'h7335;
//		  GX01<= XX * 16'h7353 + (YY+1) * 16'hacd7 ;
////		  GY01<= XX * 16'ha689 + (YY+1) * 16'h7335;
//		  GX10<= (XX+1) * 16'h7353 + YY * 16'hacd7 ;
////		  GY10<= (XX+1) * 16'ha689 + YY * 16'h7335;
//		  GX11<= (XX+1) * 16'h7353 + (YY+1) * 16'hacd7 ;
////		  GY11<= (XX+1) * 16'ha689 + (YY+1) * 16'h7335;
//			rx00 <=  GX00[15] ? 0 : GX00[14] ? 1 : -1;
//			ry00 <= ~GX00[15] ? 0 : GX00[14] ? 1 : -1;
//			r00 <= rx00*(_MX) + ry00*_MY;
//			rx01 <=  GX01[15] ? 0 : GX01[14] ? 1 : -1;
//			ry01 <= ~GX01[15] ? 0 : GX01[14] ? 1 : -1;
//			r01 <= rx01*_MX + ry01*(_MY - (32'sh1<<<(`NSCALE)) );
//			rx10 <=  GX10[15] ? 0 : GX10[14] ? 1 : -1;
//			ry10 <= ~GX10[15] ? 0 : GX10[14] ? 1 : -1;
//			r10 <= rx10*(_MX - (32'sh1<<<(`NSCALE)) ) + ry10*_MY;
//			rx11 <=  GX11[15] ? 0 : GX11[14] ? 1 : -1;
//			ry11 <= ~GX11[15] ? 0 : GX11[14] ? 1 : -1;
//			r11 <= rx11*(_MX - (32'sh1<<<(`NSCALE)) ) + ry11*(_MY - (32'sh1<<<(`NSCALE)) );
//
//         __MX<= (_MX*_MX);
//         __MY<= (_MY*_MY);
//         MX<= (3*__MX - 2*_MX*(__MX>>>`NSCALE))>>>`NSCALE;
//         MY<= (3*__MY - 2*_MY*(__MY>>>`NSCALE))>>>`NSCALE;
//
//			v1 <= (r10 * MX + r00 * ((32'sh1<<<(`NSCALE)) - MX))>>>`NSCALE;
//			v2 <= (r11 * MX + r01 * ((32'sh1<<<(`NSCALE)) - MX))>>>`NSCALE;
////			V_out <= (((32'sh1<<<(`NSCALE))+v1)<<<(15-`NSCALE) );
//			V_out <= (((32'sh1<<<(`NSCALE))+v2 * MY + v1 * ((32'sh1<<<(`NSCALE)) - MY))>>>`NSCALE)<<<(15-`NSCALE);
//			
//			//			v1<= rx00 * MX + ry00 * MY;
////			v2<= rx01 * (16'h0040 - MX) + ry01 * MY;
////			v3<= rx10 * MX + ry10 * (16'h0040 - MY);
////			v4<= rx11 * (16'h0040 - MX) + ry11 * (16'h0040 - MY);
////			V_out<= (v1+v2+v3+v4);
//		end
//	end
//end
//endmodule

module Ibniz_generator3 ( clk, rst, ena, T_in, X_in, Y_in, V_out );

input clk;
input rst;
input ena;
input wire signed [31:0] T_in;
input wire signed [31:0] X_in;
input wire signed [31:0] Y_in;
output reg [31:0] V_out;

always@(posedge clk or posedge rst)
begin
	if ( rst )
	begin
	end
	else if ( ena )
	begin
		//	**
		V_out= ((((X_in>>>4) * (Y_in>>>4))>>>8) * (T_in>>>16));
	end
end
endmodule

module Ibniz_generator4 ( clk, rst, ena, T_in, X_in, Y_in, V_out );

input clk;
input rst;
input ena;
input wire signed [31:0] T_in;
input wire signed [31:0] X_in;
input wire signed [31:0] Y_in;
output reg [31:0] V_out;

always@(posedge clk or posedge rst)
begin
	if ( rst )
	begin
	end
	else if ( ena )
	begin
		//	&*
		V_out= (X_in & Y_in) * (T_in>>>16);
	end
end
endmodule



//


//
////============================= FLOOR+CEIL ===================================
module Ibniz_generator7 ( clk, rst, ena, T_in, _X_in, Y_in, V_out, dbg_out );

input clk;
input rst;
input ena;
input wire signed [31:0] T_in;
input wire signed [31:0] _X_in;
wire signed [31:0] X_in= _X_in/2;
input wire signed [31:0] Y_in;
output reg [31:0] V_out;
output reg [63:0] dbg_out;

wire signed [31:0] d_out;
wire signed [31:0] d_del;
wire signed [31:0] Y_pos_del;
wire signed [31:0] s_out;

wire done;

wire signed [47:0] XY= X_in+Y_in;
//wire signed [47:0] X_pos= { {48{X_in[31]}}, X_in, 16'h0};
//wire signed [48:0] Y_pos= Y_in;
wire signed [47:0] X_pos= `ABS(X_in)>`ABS(Y_in) ? { {48{X_in[31]}}, X_in, 16'h0} : { {48{Y_in[31]}}, Y_in, 16'h0};
wire signed [48:0] Y_pos= `ABS(X_in)>`ABS(Y_in) ? Y_in : X_in;

div_pipelined div1( clk, X_pos, Y_pos, d_out );
//div_pipelined div1( clk, X_in+T_in, Y_in, d_out );
defparam div1.BITS= 24;								

id_pipelined   id2( clk, Y_pos, Y_pos_del );
defparam id2.DELAY= 24;								
//defparam div2.BITS= 24;								

//wire signed [31:0] ys_out;
//sin_pipelined sin1( clk, Y_pos, ys_out, _, _ );
//wire signed [31:0] ds_out;
//sin_pipelined sin2( clk, d_out, ds_out, _, _ );

wire signed [31:0] hor= -((Y_pos_del>>>5)* (T_in>>>14));
wire signed [31:0] _bright= `ABS(Y_pos_del)*2-32'hffff;
wire signed [31:0] bright= (_bright>>>8)*(_bright>>>8);
reg signed [31:0] bright2;

always@(posedge clk or posedge rst)
begin
	if ( rst )
	begin
	end
	else if ( ena )
	begin
//		if (done)
		begin
		//	//
			bright2 <= (bright>>>8)*(bright>>>8);
//			V_out<=  d_out^(Y_pos+ ((X_in+Y_in<0) ? (T_in>>>10):-(T_in>>>10)));//(	(X_in<<<16 <0 != (Y_in<<<16 <0))	) ? 0 : 32'haaaaaaaa;
			V_out<=  (bright*(d_out[15:0]^hor[18:3])>>16) 
						| (d_out[16]^hor[20] ? 32'h80000000:0) 
						| (d_out[17]^hor[21] ? 32'h00800000:0)
						| (d_out[18]^hor[22] ? 32'h40000000:0) 
						| (Y_pos_del==Y_in ? 32'h00400000:0);//(	(X_in<<<16 <0 != (Y_in<<<16 <0))	) ? 0 : 32'haaaaaaaa;
			dbg_out[31:0]<= X_in+Y_in;
			dbg_out[63:32]<= T_in>>>16;
		end
//		else
//			V_out<= V_out>>>1;
	end
end
endmodule

//============================= MATH TEST ===================================
//module Ibniz_generator7h ( clk, rst, ena, T_in, X_in, Y_in, V_out, dbg_out );
//
//input clk;
//input rst;
//input ena;
//input wire signed [31:0] T_in;
//input wire signed [31:0] X_in;
//input wire signed [31:0] Y_in;
//output reg [31:0] V_out;
//output reg [63:0] dbg_out;
//
//wire signed [31:0] d_out;
//exp_pipelined exp1( clk, (X_in)<<<4, d_out );
//
//
//always@(posedge clk or posedge rst)
//begin
//	if ( rst )
//	begin
//	end
//	else if ( ena )
//	begin
//		begin
//			V_out<= (	(d_out > (Y_in<<<10))	) ? 0 : 32'haaaaaaaa;
//			dbg_out[63:32]<= T_in>>>16;
//		end
//	end
//end
//endmodule
