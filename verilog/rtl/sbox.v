//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Sub Bytes Box file                                          ////
////                                                              ////
////  Description:                                                ////
////  Implement sub byte box look up table                        ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Luo Dongjun,   dongjun_luo@hotmail.com                ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
module sbox(
	clk,
	reset,
	enable,
	din,
	ende,
	en_dout,
	de_dout);
 
input		clk;
input		reset;
input		enable;
input	[7:0]	din;
input		ende;  //0: encryption;  1: decryption
output	[7:0]	en_dout;
output	[7:0]	de_dout;
 
wire [7:0] first_matrix_out,first_matrix_in,last_matrix_out_enc,last_matrix_out_dec;
wire [3:0] p,q,p2,q2,sumpq,sump2q2,inv_sump2q2,p_new,q_new,mulpq,q2B;
reg [7:0]  first_matrix_out_L;
reg [3:0]  p_new_L,q_new_L;
 
// GF(256) to GF(16) transformation
assign first_matrix_in[7:0] = ende ? INV_AFFINE(din[7:0]): din[7:0];
assign first_matrix_out[7:0] = GF256_TO_GF16(first_matrix_in[7:0]);
 
// pipeline 1
always @ (posedge clk or posedge reset)
begin
	if (reset)
		first_matrix_out_L[7:0] <= 8'b0;
	else if (enable)
		first_matrix_out_L[7:0] <= first_matrix_out[7:0];
end
 
/*****************************************************************************/
// GF16 inverse logic
/*****************************************************************************/
//                     p+q _____ 
//                              \
//  p --> p2 ___                 \
//   \          \                 x --> p_new
//    x -> p*q -- + --> inverse -/
//   /          /                \
//  q --> q2*B-/                  x --> q_new 
//   \___________________________/
//
assign p[3:0] = first_matrix_out_L[3:0];
assign q[3:0] = first_matrix_out_L[7:4];
assign p2[3:0] = SQUARE(p[3:0]);
assign q2[3:0] = SQUARE(q[3:0]);
//p+q
assign sumpq[3:0] = p[3:0] ^ q[3:0];
//p*q
assign mulpq[3:0] = MUL(p[3:0],q[3:0]);
//q2B calculation
assign q2B[0]=q2[1]^q2[2]^q2[3];
assign q2B[1]=q2[0]^q2[1];
assign q2B[2]=q2[0]^q2[1]^q2[2];
assign q2B[3]=q2[0]^q2[1]^q2[2]^q2[3];
//p2+p*q+q2B
assign sump2q2[3:0] = q2B[3:0] ^ mulpq[3:0] ^ p2[3:0];
// inverse p2+pq+q2B
assign inv_sump2q2[3:0] = INVERSE(sump2q2[3:0]);
// results
assign p_new[3:0] = MUL(sumpq[3:0],inv_sump2q2[3:0]);
assign q_new[3:0] = MUL(q[3:0],inv_sump2q2[3:0]);
 
// pipeline 2
always @ (posedge clk or posedge reset)
begin
	if (reset)
		{p_new_L[3:0],q_new_L[3:0]} <= 8'b0;
	else if (enable)
		{p_new_L[3:0],q_new_L[3:0]} <= {p_new[3:0],q_new[3:0]};
end
 
// GF(16) to GF(256) transformation
assign last_matrix_out_dec[7:0] = GF16_TO_GF256(p_new_L[3:0],q_new_L[3:0]);
assign last_matrix_out_enc[7:0] = AFFINE(last_matrix_out_dec[7:0]);
assign en_dout[7:0] = last_matrix_out_enc[7:0];
assign de_dout[7:0] = last_matrix_out_dec[7:0];
 
/*****************************************************************************/
// Functions
/*****************************************************************************/
 
// convert GF(256) to GF(16)
function [7:0] GF256_TO_GF16;
input [7:0] data;
reg a,b,c;
begin
	a = data[1]^data[7];
	b = data[5]^data[7];
	c = data[4]^data[6];
	GF256_TO_GF16[0] = c^data[0]^data[5];
	GF256_TO_GF16[1] = data[1]^data[2];
	GF256_TO_GF16[2] = a;
	GF256_TO_GF16[3] = data[2]^data[4];
	GF256_TO_GF16[4] = c^data[5]; 
	GF256_TO_GF16[5] = a^c;
	GF256_TO_GF16[6] = b^data[2]^data[3];
	GF256_TO_GF16[7] = b;
end
endfunction
 
// squre 
function [3:0] SQUARE;
input [3:0] data;
begin
	SQUARE[0] = data[0]^data[2];
	SQUARE[1] = data[2];
	SQUARE[2] = data[1]^data[3];
	SQUARE[3] = data[3];
end
endfunction
 
// inverse
function [3:0] INVERSE;
input [3:0] data;
reg a;
begin
	a=data[1]^data[2]^data[3]^(data[1]&data[2]&data[3]);
	INVERSE[0]=a^data[0]^(data[0]&data[2])^(data[1]&data[2])^(data[0]&data[1]&data[2]);
	INVERSE[1]=(data[0]&data[1])^(data[0]&data[2])^(data[1]&data[2])^data[3]^
		(data[1]&data[3])^(data[0]&data[1]&data[3]);
	INVERSE[2]=(data[0]&data[1])^data[2]^(data[0]&data[2])^data[3]^
		(data[0]&data[3])^(data[0]&data[2]&data[3]);
	INVERSE[3]=a^(data[0]&data[3])^(data[1]&data[3])^(data[2]&data[3]);
end
endfunction
 
// multiply
function [3:0] MUL;
input [3:0] d1,d2;
reg a,b;
begin
	a=d1[0]^d1[3];
	b=d1[2]^d1[3];
 
	MUL[0]=(d1[0]&d2[0])^(d1[3]&d2[1])^(d1[2]&d2[2])^(d1[1]&d2[3]);
	MUL[1]=(d1[1]&d2[0])^(a&d2[1])^(b&d2[2])^((d1[1]^d1[2])&d2[3]);
	MUL[2]=(d1[2]&d2[0])^(d1[1]&d2[1])^(a&d2[2])^(b&d2[3]);
	MUL[3]=(d1[3]&d2[0])^(d1[2]&d2[1])^(d1[1]&d2[2])^(a&d2[3]);
end
endfunction
 
// GF16 to GF256 transform
function [7:0] GF16_TO_GF256;
input [3:0] p,q;
reg a,b;
begin
	a=p[1]^q[3];
	b=q[0]^q[1];
 
	GF16_TO_GF256[0]=p[0]^q[0];
	GF16_TO_GF256[1]=b^q[3];
	GF16_TO_GF256[2]=a^b;
	GF16_TO_GF256[3]=b^p[1]^q[2];
	GF16_TO_GF256[4]=a^b^p[3];
	GF16_TO_GF256[5]=b^p[2];
	GF16_TO_GF256[6]=a^p[2]^p[3]^q[0];
	GF16_TO_GF256[7]=b^p[2]^q[3];
end
endfunction
 
// affine transformation
function [7:0] AFFINE;
input [7:0] data;
begin
	//affine trasformation
	AFFINE[0]=(!data[0])^data[4]^data[5]^data[6]^data[7];
	AFFINE[1]=(!data[0])^data[1]^data[5]^data[6]^data[7];
	AFFINE[2]=data[0]^data[1]^data[2]^data[6]^data[7];
	AFFINE[3]=data[0]^data[1]^data[2]^data[3]^data[7];
	AFFINE[4]=data[0]^data[1]^data[2]^data[3]^data[4];
	AFFINE[5]=(!data[1])^data[2]^data[3]^data[4]^data[5];
	AFFINE[6]=(!data[2])^data[3]^data[4]^data[5]^data[6];
	AFFINE[7]=data[3]^data[4]^data[5]^data[6]^data[7];
end
endfunction
 
// inverse affine transformation
function [7:0] INV_AFFINE;
input [7:0] data;
reg a,b,c,d;
begin
	a=data[0]^data[5];
	b=data[1]^data[4];
	c=data[2]^data[7];
	d=data[3]^data[6];
	INV_AFFINE[0]=(!data[5])^c;
	INV_AFFINE[1]=data[0]^d;
	INV_AFFINE[2]=(!data[7])^b;
	INV_AFFINE[3]=data[2]^a;
	INV_AFFINE[4]=data[1]^d;
	INV_AFFINE[5]=data[4]^c;
	INV_AFFINE[6]=data[3]^a;
	INV_AFFINE[7]=data[6]^b;
end
endfunction
endmodule
