/*Author: Zhuxu
	m99a1@yahoo.cn
Use parallel prefix tree structure to reduce a 16-bit number by one.

stage 0:	number of genration=16;	number of logic operation=16;	G_0[xx]=~i_operand[xx];
stage 1:	NOG=16;			NOO=8;				G_1[2n-1]=G_0[2n-1]&&G_0[2n-2];	n=8:1
stage 2:	NOG=16;			NOO=7;				G_2[2n-1]=G_1[2n-1]&&G_1[2n-3];	n=8:2
stage 3:	NOG=16;			NOO=6;				G_3[2n-1]=G_2[2n-1]&&G_2[2n-5];	n=8:3	
stage 4:	NOG=16;			NOO=4;				G_4[2n-1]=G_3[2n-1]&&G_3[2n-9];	n=8:5	
stage 5:	NOG=16;			NOO=7;				G_5[2n]=G_4[2n]&&G_4[2n-1];	n=7:1

*/
module minus_one(
input	[15:0]i_operand,
output	[15:0]o_result,
output	o_borrow
);
//stage 0
wire	[15:0]G_0;
assign	G_0=~i_operand;

//stage 1
wire	[15:0]G_1;
assign	G_1[1]=G_0[1]&G_0[0];
assign	G_1[3]=G_0[3]&G_0[2];
assign	G_1[5]=G_0[5]&G_0[4];
assign	G_1[7]=G_0[7]&G_0[6];
assign	G_1[9]=G_0[9]&G_0[8];
assign	G_1[11]=G_0[11]&G_0[10];
assign	G_1[13]=G_0[13]&G_0[12];
assign	G_1[15]=G_0[15]&G_0[14];
assign	G_1[0]=G_0[0];
assign	G_1[2]=G_0[2];
assign	G_1[4]=G_0[4];
assign	G_1[6]=G_0[6];
assign	G_1[8]=G_0[8];
assign	G_1[10]=G_0[10];
assign	G_1[12]=G_0[12];
assign	G_1[14]=G_0[14];

//stage 2
wire	[15:0]G_2;
assign	G_2[3]=G_1[3]&G_1[1];
assign	G_2[5]=G_1[5]&G_1[3];
assign	G_2[7]=G_1[7]&G_1[5];
assign	G_2[9]=G_1[9]&G_1[7];
assign	G_2[11]=G_1[11]&G_1[9];
assign	G_2[13]=G_1[13]&G_1[11];
assign	G_2[15]=G_1[15]&G_1[13];
assign	G_2[0]=G_1[0];
assign	G_2[2]=G_1[2];
assign	G_2[1]=G_1[1];
assign	G_2[4]=G_1[4];
assign	G_2[6]=G_1[6];
assign	G_2[8]=G_1[8];
assign	G_2[10]=G_1[10];
assign	G_2[12]=G_1[12];
assign	G_2[14]=G_1[14];

//stage 3
wire	[15:0]G_3;
assign	G_3[5]=G_2[5]&G_2[1];
assign	G_3[7]=G_2[7]&G_2[3];
assign	G_3[9]=G_2[9]&G_2[5];
assign	G_3[11]=G_2[11]&G_2[7];
assign	G_3[13]=G_2[13]&G_2[9];
assign	G_3[15]=G_2[15]&G_2[11];
assign	G_3[0]=G_2[0];
assign	G_3[2]=G_2[2];
assign	G_3[1]=G_2[1];
assign	G_3[4]=G_2[4];
assign	G_3[3]=G_2[3];
assign	G_3[6]=G_2[6];
assign	G_3[8]=G_2[8];
assign	G_3[10]=G_2[10];
assign	G_3[12]=G_2[12];
assign	G_3[14]=G_2[14];

//stage 4
wire	[15:0]G_4;
assign	G_4[9]=G_3[9]&G_3[1];
assign	G_4[11]=G_3[11]&G_3[3];
assign	G_4[13]=G_3[13]&G_3[5];
assign	G_4[15]=G_3[15]&G_3[7];
assign	G_4[0]=G_3[0];
assign	G_4[2]=G_3[2];
assign	G_4[1]=G_3[1];
assign	G_4[4]=G_3[4];
assign	G_4[3]=G_3[3];
assign	G_4[6]=G_3[6];
assign	G_4[5]=G_3[5];
assign	G_4[8]=G_3[8];
assign	G_4[7]=G_3[7];
assign	G_4[10]=G_3[10];
assign	G_4[12]=G_3[12];
assign	G_4[14]=G_3[14];

//stage 5
wire	[15:0]G_5;
assign	G_5[2]=G_4[2]&G_4[1];
assign	G_5[4]=G_4[4]&G_4[3];
assign	G_5[6]=G_4[6]&G_4[5];
assign	G_5[8]=G_4[8]&G_4[7];
assign	G_5[10]=G_4[10]&G_4[9];
assign	G_5[12]=G_4[12]&G_4[11];
assign	G_5[14]=G_4[14]&G_4[13];
assign	G_5[1]=G_4[1];
assign	G_5[3]=G_4[3];
assign	G_5[5]=G_4[5];
assign	G_5[7]=G_4[7];
assign	G_5[9]=G_4[9];
assign	G_5[11]=G_4[11];
assign	G_5[13]=G_4[13];
assign	G_5[15]=G_4[15];
assign	G_5[0]=G_4[0];

//stage 6
assign	o_result[0]=~i_operand[0];
assign	o_result[15:1]=(G_5[14:0]&(~i_operand[15:1]))|((~G_5[14:0])&i_operand[15:1]);
assign	o_borrow=G_5[15];

endmodule