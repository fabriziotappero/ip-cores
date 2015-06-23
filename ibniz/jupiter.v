
`define MAX(a,b) ( (a)>(b)? (a):(b) )
`define ABS(a) ( (a)>0? (a):(-(a)) )


//============================= ATAN2 ===================================
module Ibniz_generator5 ( clk, rst, ena, T_in, _X_in, _Y_in, V_out, dbg_out );

input clk;
input rst;
input ena;
input wire signed [31:0] T_in;
input wire signed [31:0] _X_in;
input wire signed [31:0] _Y_in;
output reg [31:0] V_out;
output reg signed [63:0] dbg_out;
reg signed [31:0] V_out2;

 wire signed [31:0] X_in =_X_in;//+_Y_in)*3/4;
 wire signed [31:0] Y_in =_Y_in;//-_Y_in)*3/4;

reg [31:0] R1;
reg [31:0] R2;
reg [31:0] R3;

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
		//	&*
//		V_out2= ((d_out1*Z_D)>>>16 );//32'h00408000 + 
//		V_out= ( (V3<<16)+(V2<<8)+((V1*Z_D)>>>16));
//		V_out= ( T_in[24] ? (a_T^(a_out1<<<2)) : ( a_out1<<<2 )+16'h8000 );
		V_out= Z_D<5 ? (R3[7:0] ? 0 : R3[8] ? -1 : R3) :
//					(((( d_out1&32'hff000000 )*Z_D)>>>16)&32'hff000000)|
//					(((( d_out1&32'h00ff0000 )*Z_D)>>>16)&32'h00ff0000)|
					(((( d_out1&32'hffff0000 ))))|
					(((( d_out1&32'h0000ffff )*Z_D)>>>16)&32'h0000ffff);//(a_out2<<<3) ^(( a_out1<<<3 ) );//+16'h8000
	end
end

wire signed [47:0] XY= ((a_out1)<<<2)+(a_out2)-48'h00010000;
wire signed [31:0] d_out1= (_d_out1)>>>8;
wire signed [47:0] _d_out1;

div_pipelined div1( clk, {T_in, 22'h0}, (/*XY[31]?-XY:*/XY), _d_out1 );


wire signed [31:0] X_D;
wire signed [31:0] Y_D;
wire signed [31:0] Z_D;
wire signed [31:0] s_out1;
wire signed [31:0] s_out2;
wire signed [47:0] a_out2 =_a_out2>>>3;
wire signed [47:0] a_out1 =`ABS(_a_out1);
wire signed [17:0] _a_out2;
wire signed [17:0] _a_out1;
wire signed [31:0] d_out;
wire signed [31:0] XX= ( (X_in>>>1)*(X_in>>>1) );					//	30
wire signed [31:0] YY= ( (Y_in>>>1)*(Y_in>>>1) );					//	30
wire signed [31:0] MXXYY1= 32'h40000000 - (XX+YY);					//	30
wire signed [31:0] MXXYY= (MXXYY1[31]) ? 0:(MXXYY1<<1) ;			//	31
wire signed [31:0] MYY=  (MXXYY1[31]) ? 0:(-YY<<1) ;				//	31
//wire signed [31:0] MXXYY= 32'h00010000 - (XX+YY);
//wire signed [31:0] MYY= 32'h00010000 - YY;

atan2_pipelined atan1( clk, s_out1[31:14], Y_in, _a_out1, dummy1 );
atan2_pipelined atan2( clk, X_in, s_out2[28:13], _a_out2, dummy2 );
//atan2_pipelined atan1( clk, s_out1, Y_D, a_out1, dummy1 );
//atan2_pipelined atan2( clk, X_D, s_out2, a_out2, dummy2 );

defparam atan1.IS_IBNIZ= 1;
defparam atan2.IS_IBNIZ= 1;
//div_pipelined mydiv( clk, a_out<<12, pix2, d_out );
//id_pipelined id1( clk, X_in, X_D );
//defparam id1.DELAY= 32;
//id_pipelined id2( clk, Y_in, Y_D );
//defparam id2.DELAY= 32;
id_pipelined id3( clk, s_out2[28:13], Z_D );
defparam id3.DELAY= 64;

sqrt_pipelined sqrt1( clk, MYY[31:4], s_out1[31:0], _ );
sqrt_pipelined sqrt2( clk, MXXYY[31:4], s_out2[31:0], _ );
//sqrt_pipelined sqrt2( clk, MXXYY[16:1], s_out2[15:0], _ );
//defparam sqrt2.BITS= 20;
//defparam sqrt1.BITS= 20;

endmodule


//============================= ATAN2 ===================================
module PseudoSin ( clk, rst, ena, _X_in, S_out, R_out );

input clk;
input rst;
input ena;
input wire signed [31:0] _X_in;
output reg [31:0] S_out;
output reg [15:0] R_out;

wire signed [31:0] XX_in= 32'h00007fff-{ {16{1'b0}}, {_X_in[15:0]} };
wire signed [31:0] X_in= 
									`ABS(XX_in) < 32'h00000100 ? 32'h00000100 :
																			XX_in;
reg signed [31:0] X1;
reg signed [31:0] X2;
reg signed [31:0] X2d;
reg signed [31:0] X3;
reg sgn_x;
reg _sgn_x;
reg [15:0]rgn_x;
reg [15:0]_rgn_x;

always@(posedge clk or posedge rst)
begin
	if ( rst )
	begin
	end
	else if ( ena )
	begin
	// 1 ступень конвеера
		X1<= `ABS(X_in);
		X2<= ((X_in) * (X_in))>>>16;
		_sgn_x<= _X_in[16];
		_rgn_x<= _X_in[31:16];
		
	// 2 ступень конвеера
		X2d<= X2;
		X3<= (X1 * X2)>>>16;
		sgn_x<= _sgn_x;
		rgn_x<=_rgn_x;
		
	// 3 ступень конвеера
		R_out<=rgn_x;
		S_out<=  (((1<<15)-(3*X2d-2*X3)) ) * (sgn_x ? -2:2);//
	end
end

endmodule




module Psin_Texture ( clk, rst, ena, T_in, _X_in, _Y_in, V_out );

input clk;
input rst;
input ena;
input wire signed [31:0] T_in;
input wire signed [31:0] _X_in;
input wire signed [31:0] _Y_in;
output reg [31:0] V_out;

reg signed [31:0] SXSY;
wire signed [31:0] _SSS;
wire signed [31:0] MSSS= -_SSS;
wire signed [31:0] etalon;

wire signed [31:0] RX;
wire signed [31:0] RY;

wire signed [15:0] NX;
wire signed [15:0] NY;
wire signed [15:0] NXd;
wire signed [15:0] NYd;
wire signed [15:0] PXY= NXd+NYd;
wire signed [15:0] MXY= NXd-NYd;
wire signed [31:0] NXY= _SSS>0 ? (PXY[3]?{ PXY[3:0], 4'b0, PXY[3:0]*PXY[7:4], 4'b0, (_SSS[15:0]) } :0) :
											(MXY[3]?{ MXY[4:1], 4'b0, MXY[3:0]*MXY[7:4], 4'b0, (MSSS[15:0]) } :0);


always@(posedge clk or posedge rst)
begin
	if ( rst )
	begin
	end
	else if ( ena )
	begin
		SXSY<= ( ((( RX>>>7)*( RY>>>7))) )/2;
		V_out<= 	
//					_X_in==0 && _Y_in[8]==0 ? 32'haaaaaaaa :
	//				_Y_in<32'h00008000 ? SXSY :
					NXY;
//		V_out= _Y_in==0 || _X_in==0  ? 32'haaaaaaaa : (((RX)>_Y_in ? -1:0) ^ ((etalon)>_Y_in ? 32'h33333333:0) );//+32'sh00008000;
	end
end

sin_pipelined sin1( clk, _X_in, etalon, _, _ );

PseudoSin psinX(  clk, rst, ena, _X_in*8, RX, NX );
PseudoSin psinY(  clk, rst, ena, _Y_in*8, RY, NY );

PseudoSin psinV(  clk, rst, ena, SXSY*2, _SSS, _ );
id_pipelined idnx( clk, NX, NXd );
id_pipelined idny( clk, NY, NYd );
defparam idnx.DELAY= 4;
defparam idny.DELAY= 4;

endmodule


//============================= rotate sphere ===================================
module Ibniz_generator6 ( clk, rst, ena, T_in, _X_in, _Y_in, V_out, dbg_out );

input clk;
input rst;
input ena;
input wire signed [31:0] T_in;
input wire signed [31:0] _X_in;
input wire signed [31:0] _Y_in;
output reg [31:0] V_out;
output reg signed [63:0] dbg_out;
reg signed [31:0] V_out2;

 wire signed [31:0] __X_in= _X_in+(48<<7);

 reg signed [31:0] X_in;
 wire signed [31:0] Y_in =_Y_in>0 ? (_Y_in - 32'h8008)*2 : (_Y_in + 32'h8008)*2;//-_Y_in)*3/4;

reg [31:0] R1;
reg [31:0] R2;
reg [31:0] R3;

always@(posedge clk or posedge rst)
begin
	if ( rst )
	begin
	end
	else if ( ena )
	begin
		X_in =__X_in>(32'sd16<<<8) ? (__X_in - 32'h9000)*2 : (__X_in + 32'h8000)*2;//+_Y_in)*3/4;
		//R1 <= (((X_in+T_in[31:12])>>>7)) * 11713 + ((Y_in>>>8)+(Y_in)) * 5422133;
		//R2 <= R1 * 7 + (R1>>8)*1817 ;
		//R3 <= { R2[7:0],R2[15:8],R2[23:16], R2[7:0] ^ R2[15:8] ^ R2[23:16] ^ R2[31:24] };
		//	&*
//		V_out2= ((d_out1*Z_D)>>>16 );//32'h00408000 + 
//		V_out= ( (V3<<16)+(V2<<8)+((V1*Z_D)>>>16));
//		V_out= ( T_in[24] ? (a_out2^(a_out1<<<2)) : ( a_out1<<<2 )+16'h8000 );
		V_out= Z_D<5 ? 0://(R3[7:0] ? 0 : R3[8] ? -1 : R3) :
					d_out1;//(a_out2<<<3) ^(( a_out1<<<3 ) );//+16'h8000
	end
end

//wire signed [47:0] XY= ((a_out1)<<<3)+(a_out2)-48'h00010000;
wire signed [31:0] d_out1= ((a_out1<<<4)+( _X_in>0 ? (T_in>>>10):0 ))^((a_out2<<<4)+( _Y_in>0 ? (T_in>>>10):0 ));
//wire signed [47:0] _d_out1;

//div_pipelined div1( clk, {T_in, 22'h0}, (/*XY[31]?-XY:*/XY), _d_out1 );


wire signed [31:0] X_D;
wire signed [31:0] Y_D;
wire signed [31:0] Z_D;
wire signed [31:0] s_out1;
wire signed [31:0] s_out2;
wire signed [47:0] a_out2 =_a_out2>>>3;
wire signed [47:0] a_out1 =`ABS(_a_out1>>>1);
wire signed [31:0] _a_out2;
wire signed [17:0] _a_out1;
wire signed [31:0] d_out;
wire signed [31:0] XX= ( (X_in>>>2)*(X_in>>>2) );					//	30
wire signed [31:0] YY= ( (Y_in>>>2)*(Y_in>>>2) );					//	30
wire signed [31:0] MXXYY1= 32'h10000000 - (XX+YY);					//	30
wire signed [31:0] MXXYY= (MXXYY1[31]) ? 0:(MXXYY1<<3) ;			//	31
wire signed [31:0] MYY=  (MXXYY1[31]) ? 0:(-YY<<1) ;				//	31
//wire signed [31:0] MXXYY= 32'h00010000 - (XX+YY);
//wire signed [31:0] MYY= 32'h00010000 - YY;

atan2_pipelined atan1( clk, s_out1[31:14], Y_in, _a_out1, dummy1 );	//16
atan2_pipelined atan2( clk, X_in-(32'sd32<<<8), s_out2[31:13], _a_out2, dummy2 );
//atan2_pipelined atan1( clk, s_out1, Y_D, a_out1, dummy1 );
//atan2_pipelined atan2( clk, X_D, s_out2, a_out2, dummy2 );

defparam atan1.IS_IBNIZ= 1;
defparam atan2.IS_IBNIZ= 1;
//div_pipelined mydiv( clk, a_out<<12, pix2, d_out );
//id_pipelined id1( clk, X_in, X_D );
//defparam id1.DELAY= 32;
//id_pipelined id2( clk, Y_in, Y_D );
//defparam id2.DELAY= 32;
id_pipelined id3( clk, s_out2[28:13], Z_D );
defparam id3.DELAY= 16;

sqrt_pipelined sqrt1( clk, MYY[31:4], s_out1[31:0], _ );	//32
sqrt_pipelined sqrt2( clk, MXXYY[31:4], s_out2[31:0], _ );
//sqrt_pipelined sqrt2( clk, MXXYY[16:1], s_out2[15:0], _ );
//defparam sqrt2.BITS= 20;
//defparam sqrt1.BITS= 20;

endmodule

