module	shift_1b(
input	i_shift,
input	[31:0]i_data,
output	[31:0]o_data
);
assign	o_data=i_shift?{i_data[30:0],1'b0}:i_data;

endmodule

module	shift_3b(
input	[2:0]i_shift,
input	[31:0]i_data,
output	[31:0]o_data
);
wire	[31:0]data1;
assign	data1=i_shift[1]?{i_data[29:0],2'b0}:i_data;
wire	shift1;
assign	shift1=(i_shift[0]&i_shift[1])|(i_shift[2]^i_shift[1]);
shift_1b	shift_1b_0(
shift1,
data1,
o_data
);
endmodule

module	shift_7b(
input	[6:0]i_shift,
input	[31:0]i_data,
output	[31:0]o_data
);
wire	[31:0]data1;
assign	data1=i_shift[3]?{i_data[27:0],4'b0}:i_data;
wire	[2:0]shift1;
assign	shift1=(i_shift[2:0]&{3{i_shift[3]}})|(i_shift[6:4]^{3{i_shift[3]}});

shift_3b	shift_3b_0(
shift1,
data1,
o_data
);

endmodule

module	shift_15b(
input	[14:0]i_shift,
input	[31:0]i_data,
output	[31:0]o_data
);
wire	[31:0]data1;
assign	data1=i_shift[7]?{i_data[23:0],8'b0}:i_data;
wire	[6:0]shift1;
assign	shift1=(i_shift[6:0]&{7{i_shift[7]}})|(i_shift[14:8]^{7{i_shift[7]}});

shift_7b	shift_7b_0(
shift1,
data1,
o_data
);

endmodule











module	shifter(
input	[31:0]i_data,
output	[31:0]o_data,
output	[4:0]o_shifted
);

wire	[31:0]node_0;
assign	node_0=i_data[31]?i_data:~i_data;

// odd nodes tree
///////////////////////// layer 1 ////////////////////////////
wire	[15:0]onode_1;
assign	onode_1[0]=node_0[0]&node_0[1];
assign	onode_1[1]=node_0[2]&node_0[3];
assign	onode_1[2]=node_0[4]&node_0[5];
assign	onode_1[3]=node_0[6]&node_0[7];
assign	onode_1[4]=node_0[8]&node_0[9];
assign	onode_1[5]=node_0[10]&node_0[11];
assign	onode_1[6]=node_0[12]&node_0[13];
assign	onode_1[7]=node_0[14]&node_0[15];
assign	onode_1[8]=node_0[16]&node_0[17];
assign	onode_1[9]=node_0[18]&node_0[19];
assign	onode_1[10]=node_0[20]&node_0[21];
assign	onode_1[11]=node_0[22]&node_0[23];
assign	onode_1[12]=node_0[24]&node_0[25];
assign	onode_1[13]=node_0[26]&node_0[27];
assign	onode_1[14]=node_0[28]&node_0[29];
assign	onode_1[15]=node_0[30]&node_0[31];
///////////////////////// layer 2 ////////////////////////////
wire	[15:0]onode_2;
assign	onode_2[0]=onode_1[0]&onode_1[1];
assign	onode_2[1]=onode_1[1]&onode_1[2];
assign	onode_2[2]=onode_1[2]&onode_1[3];
assign	onode_2[3]=onode_1[3]&onode_1[4];
assign	onode_2[4]=onode_1[4]&onode_1[5];
assign	onode_2[5]=onode_1[5]&onode_1[6];
assign	onode_2[6]=onode_1[6]&onode_1[7];
assign	onode_2[7]=onode_1[7]&onode_1[8];
assign	onode_2[8]=onode_1[8]&onode_1[9];
assign	onode_2[9]=onode_1[9]&onode_1[10];
assign	onode_2[10]=onode_1[10]&onode_1[11];
assign	onode_2[11]=onode_1[11]&onode_1[12];
assign	onode_2[12]=onode_1[12]&onode_1[13];
assign	onode_2[13]=onode_1[13]&onode_1[14];
assign	onode_2[14]=onode_1[14]&onode_1[15];
assign	onode_2[15]=onode_1[15];
///////////////////////// layer 3 ////////////////////////////
wire	[15:0]onode_3;
assign	onode_3[0]=onode_2[0]&onode_2[2];
assign	onode_3[1]=onode_2[1]&onode_2[3];
assign	onode_3[2]=onode_2[2]&onode_2[4];
assign	onode_3[3]=onode_2[3]&onode_2[5];
assign	onode_3[4]=onode_2[4]&onode_2[6];
assign	onode_3[5]=onode_2[5]&onode_2[7];
assign	onode_3[6]=onode_2[6]&onode_2[8];
assign	onode_3[7]=onode_2[7]&onode_2[9];
assign	onode_3[8]=onode_2[8]&onode_2[10];
assign	onode_3[9]=onode_2[9]&onode_2[11];
assign	onode_3[10]=onode_2[10]&onode_2[12];
assign	onode_3[11]=onode_2[11]&onode_2[13];
assign	onode_3[12]=onode_2[12]&onode_2[14];
assign	onode_3[13]=onode_2[13]&onode_2[15];
assign	onode_3[14]=onode_2[14];
assign	onode_3[15]=onode_2[15];
///////////////////////// layer 4 ////////////////////////////
wire	[15:0]onode_4;
assign	onode_4[0]=onode_3[0]&onode_3[4];
assign	onode_4[1]=onode_3[1]&onode_3[5];
assign	onode_4[2]=onode_3[2]&onode_3[6];
assign	onode_4[3]=onode_3[3]&onode_3[7];
assign	onode_4[4]=onode_3[4]&onode_3[8];
assign	onode_4[5]=onode_3[5]&onode_3[9];
assign	onode_4[6]=onode_3[6]&onode_3[10];
assign	onode_4[7]=onode_3[7]&onode_3[11];
assign	onode_4[8]=onode_3[8]&onode_3[12];
assign	onode_4[9]=onode_3[9]&onode_3[13];
assign	onode_4[10]=onode_3[10]&onode_3[14];
assign	onode_4[11]=onode_3[11]&onode_3[15];
assign	onode_4[12]=onode_3[12];
assign	onode_4[13]=onode_3[13];
assign	onode_4[14]=onode_3[14];
assign	onode_4[15]=onode_3[15];
///////////////////////// layer 5 ////////////////////////////
wire	[15:0]onode_5;
assign	onode_5[0]=onode_4[0]&onode_4[8];
assign	onode_5[1]=onode_4[1]&onode_4[9];
assign	onode_5[2]=onode_4[2]&onode_4[10];
assign	onode_5[3]=onode_4[3]&onode_4[11];
assign	onode_5[4]=onode_4[4]&onode_4[12];
assign	onode_5[5]=onode_4[5]&onode_4[13];
assign	onode_5[6]=onode_4[6]&onode_4[14];
assign	onode_5[7]=onode_4[7]&onode_4[15];
assign	onode_5[8]=onode_4[8];
assign	onode_5[9]=onode_4[9];
assign	onode_5[10]=onode_4[10];
assign	onode_5[11]=onode_4[11];
assign	onode_5[12]=onode_4[12];
assign	onode_5[13]=onode_4[13];
assign	onode_5[14]=onode_4[14];
assign	onode_5[15]=onode_4[15];


// even nodes
wire	[14:0]enode;
assign	enode[14]=onode_5[15]&node_0[29];
assign	enode[13]=onode_5[14]&node_0[27];
assign	enode[12]=onode_5[13]&node_0[25];
assign	enode[11]=onode_5[12]&node_0[23];
assign	enode[10]=onode_5[11]&node_0[21];
assign	enode[9]=onode_5[10]&node_0[19];
assign	enode[8]=onode_5[9]&node_0[17];
assign	enode[7]=onode_5[8]&node_0[15];
assign	enode[6]=onode_5[7]&node_0[13];
assign	enode[5]=onode_5[6]&node_0[11];
assign	enode[4]=onode_5[5]&node_0[9];
assign	enode[3]=onode_5[4]&node_0[7];
assign	enode[2]=onode_5[3]&node_0[5];
assign	enode[1]=onode_5[2]&node_0[3];
assign	enode[0]=onode_5[1]&node_0[1];

// shift amount genration
wire	shift_1;
assign	shift_1=onode_5[15];
wire	[1:0]shift_2;
assign	shift_2[0]=onode_5[14];
assign	shift_2[1]=enode[14];
wire	[1:0]shift_3;
assign	shift_3[0]=onode_5[13];
assign	shift_3[1]=enode[13];
wire	[3:0]shift_4;
assign	shift_4[0]=onode_5[11];
assign	shift_4[1]=enode[11];
assign	shift_4[2]=onode_5[12];
assign	shift_4[3]=enode[12];
wire	[7:0]shift_5;
assign	shift_5[0]=onode_5[7];
assign	shift_5[1]=enode[7];
assign	shift_5[2]=onode_5[8];
assign	shift_5[3]=enode[8];
assign	shift_5[4]=onode_5[9];
assign	shift_5[5]=enode[9];
assign	shift_5[6]=onode_5[10];
assign	shift_5[7]=enode[10];
wire	[13:0]shift_6;
assign	shift_6[0]=onode_5[0];
assign	shift_6[1]=enode[0];
assign	shift_6[2]=onode_5[1];
assign	shift_6[3]=enode[1];
assign	shift_6[4]=onode_5[2];
assign	shift_6[5]=enode[2];
assign	shift_6[6]=onode_5[3];
assign	shift_6[7]=enode[3];
assign	shift_6[8]=onode_5[4];
assign	shift_6[9]=enode[4];
assign	shift_6[10]=onode_5[5];
assign	shift_6[11]=enode[5];
assign	shift_6[12]=onode_5[6];
assign	shift_6[13]=enode[6];

// shift tree

wire	[31:0]data_1,data_2,data_3,data_4,data_5;
shift_1b	shift_1b_0(
shift_1,
i_data,
data_1
);

shift_3b	shift_3b_0(
{shift_2,1'b0},
data_1,
data_2
);

shift_3b	shift_3b_1(
{shift_3,1'b0},
data_2,
data_3
);

shift_7b	shift_7b_0(
{shift_4,3'b0},
data_3,
o_data
);
/*
shift_7b	shift_7b_0(
{shift_4,3'b0},
data_3,
data_4
);

shift_15b	shift_15b_0(
{shift_5,7'b0},
data_4,
data_5
);

shift_15b	shift_15b_1(
{shift_6,1'b0},
data_5,
o_data
);
*/
// number of shifted bits determination
wire	[4:0]shifted_1,shifted_2,shifted_3,shifted_4,shifted_5;
assign	shifted_1=shift_1?1:0;
assign	shifted_2=	(shift_2==2'b11)?3:
			(shift_2==2'b10)?2:shifted_1;
assign	shifted_3=	(shift_3==2'b11)?5:
			(shift_3==2'b10)?4:shifted_2;

assign	o_shifted=	(shift_4==4'b1111)?9:
			(shift_4==4'b1110)?8:
			(shift_4==4'b1100)?7:
			(shift_4==4'b1000)?6:shifted_3;

/*
assign	shifted_4=	(shift_4==4'b1111)?9:
			(shift_4==4'b1110)?8:
			(shift_4==4'b1100)?7:
			(shift_4==4'b1000)?6:shifted_3;
assign	shifted_5=	(shift_5==8'b11111111)?17:
			(shift_5==8'b11111110)?16:
			(shift_5==8'b11111100)?15:
			(shift_5==8'b11111000)?14:
			(shift_5==8'b11110000)?13:
			(shift_5==8'b11100000)?12:
			(shift_5==8'b11000000)?11:
			(shift_5==8'b10000000)?10:shifted_4;
assign	o_shifted=	(shift_6==14'b11111111111111)?31:
			(shift_6==14'b11111111111110)?30:
			(shift_6==14'b11111111111100)?29:
			(shift_6==14'b11111111111000)?28:
			(shift_6==14'b11111111110000)?27:
			(shift_6==14'b11111111100000)?26:
			(shift_6==14'b11111111000000)?25:
			(shift_6==14'b11111110000000)?24:
			(shift_6==14'b11111100000000)?23:
			(shift_6==14'b11111000000000)?22:
			(shift_6==14'b11110000000000)?21:
			(shift_6==14'b11100000000000)?20:
			(shift_6==14'b11000000000000)?19:
			(shift_6==14'b10000000000000)?18:shifted_5;
*/


endmodule