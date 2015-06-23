///-----------------------------------------
///introduce:
///bch syndrome generation in decoder
///author:jiml
///record:
///2015.1.31    initial
///-----------------------------------------
`timescale 1ns/100ps
module test_bch_syndrome
#(
parameter C_DWIDTH = 128,                  //input data width
parameter C_COEF_NUM = 43,                 //correct threshold
parameter C_PRIMPOLY_ORDER = 14,           //order of eigenpolynomial
parameter C_PRIM_POLY = 15'h4443           //eigenpolynomial
)
(
input                                        I_clk        ,
input                                        I_rst        ,
input      [C_DWIDTH-1:0]                    I_data       ,    //input data
input                                        I_data_v     ,    //input data available
input                                        I_data_sof   ,    //input data frame start
input                                        I_data_eof   ,    //input data frame end
output reg [C_COEF_NUM*C_PRIMPOLY_ORDER-1:0] O_syndrome   ,    //syndrome
output reg                                   O_syndrome_v      //syndrome available
);

//------------------------------------------
//parameter and variable
//------------------------------------------
localparam [C_PRIMPOLY_ORDER*C_PRIMPOLY_ORDER*C_COEF_NUM-1:0] C_TRANS_MATRIX = F_transform(0);
localparam C_UPP_WIDTH = GETASIZE(C_PRIMPOLY_ORDER);
localparam C_GEN_UPP = F_GEN_NUM(0);
localparam C_GEN_POLY = F_GEN_POLY2(0);
localparam C_SHIFT_NUM = F_shift_cal(0);

reg [C_PRIMPOLY_ORDER-1:0] S_reg [C_COEF_NUM-1:0];
reg S_data_eof = 0;
reg [C_DWIDTH-1:0] S_data = 0;
reg S_data_eof_d = 0;
reg S_data_v = 0;
reg S_data_sof = 0;

//--------------------------------------------
//function
//--------------------------------------------
//element generation in Galois Field
function [C_PRIMPOLY_ORDER-1:0] F_gen;
input [C_PRIMPOLY_ORDER-1:0] S_init;
input integer S_times;
integer i;
begin
	F_gen = S_init;
    for(i=0;i<S_times;i=i+1)
	begin
	    if(F_gen[C_PRIMPOLY_ORDER-1])
		    F_gen = (F_gen<<1) ^ C_PRIM_POLY[C_PRIMPOLY_ORDER-1:0];
		else
		    F_gen = (F_gen<<1);
	end
end
endfunction

//2*t-1 power of element transform to 1 power of element
function [C_PRIMPOLY_ORDER*C_PRIMPOLY_ORDER*C_COEF_NUM-1:0] F_transform;
input red;
integer i,j,k;
reg [C_PRIMPOLY_ORDER-1:0] S_reg;
begin	
	for(i=0;i<C_COEF_NUM;i=i+1)
	begin
		for(j=0;j<C_PRIMPOLY_ORDER;j=j+1)
		begin
		    S_reg = F_gen(1,j*(2*i+1));
			for(k=0;k<C_PRIMPOLY_ORDER;k=k+1)
			begin
			    F_transform[C_PRIMPOLY_ORDER*C_PRIMPOLY_ORDER*i+C_PRIMPOLY_ORDER*k+j] = S_reg[k];
			end
		end
	end
end
endfunction

//when length of encode polynomial is not exactly divided into C_DWIDTH, data should shift right to occupy C_DWIDTH bits fully
function integer F_shift_cal;
input red;
integer i;
integer temp;
begin
	F_shift_cal = 0;
	for(i=0;i<C_COEF_NUM;i=i+1)
		F_shift_cal=F_shift_cal+C_GEN_UPP[i*C_UPP_WIDTH+:C_UPP_WIDTH];
	
    while(F_shift_cal>C_DWIDTH)
		F_shift_cal = F_shift_cal - C_DWIDTH;
	F_shift_cal = C_DWIDTH-F_shift_cal;
end
endfunction

//generated polynomial cascaded
function [C_PRIMPOLY_ORDER*C_COEF_NUM-1:0] F_GEN_POLY2;
input red;
integer i,j,k;
integer pointer;
reg [2**C_PRIMPOLY_ORDER-2:0] S_flag;
reg [C_PRIMPOLY_ORDER-1:0] S_temp [C_PRIMPOLY_ORDER:0];
reg [C_PRIMPOLY_ORDER-1:0] S_temp2;
begin
	F_GEN_POLY2 = 0;
	for(i=0;i<C_PRIMPOLY_ORDER;i=i+1)    //least bits are eigenpolynomial
		F_GEN_POLY2[i] = C_PRIM_POLY[i];
	for(i=1;i<C_COEF_NUM;i=i+1)          //there are C_COEF_NUM generated polynomial
	begin
		for(j=1;j<=C_PRIMPOLY_ORDER;j=j+1)
			S_temp[j] = 0;
		S_temp[0]=1;
		S_flag = 0;
	    for(j=1;j<=C_PRIMPOLY_ORDER;j=j+1)   //each polynomial have at most C_PRIMPOLY_ORDER element
		begin
			pointer = (2*i+1)*(2**(j-1));
			while(pointer>(2**C_PRIMPOLY_ORDER-2))
				pointer = pointer - (2**C_PRIMPOLY_ORDER-1);
		    if(!S_flag[pointer])
			begin
			    S_flag[pointer] = 1;
				S_temp2 = F_gen(1,pointer);
				for(k=C_PRIMPOLY_ORDER-1;k>0;k=k-1)
				begin
				    S_temp[k]= F_mult(S_temp[k],S_temp2) ^ S_temp[k-1];
				end
				S_temp[0] = F_mult(S_temp[0],S_temp2);
				S_temp[C_PRIMPOLY_ORDER] = S_temp[C_PRIMPOLY_ORDER-1];
			end
		end
		for(j=0;j<C_PRIMPOLY_ORDER;j=j+1)
			F_GEN_POLY2[i*C_PRIMPOLY_ORDER+j] = (S_temp[j] == 1);
	end
end
endfunction

//polynomial multiplication in Galois Field
function [C_PRIMPOLY_ORDER-1:0] F_mult;
input [C_PRIMPOLY_ORDER-1:0] S_data1;
input [C_PRIMPOLY_ORDER-1:0] S_data2;
reg [C_PRIMPOLY_ORDER*2-1:0] S_temp;
integer i;
begin
    S_temp = 0;
	F_mult = 0;
	for(i=0;i<C_PRIMPOLY_ORDER;i=i+1)
	begin
	    S_temp = S_temp ^ ({(C_PRIMPOLY_ORDER*2){S_data1[i]}} & (S_data2<<i));
	end
	for(i=0;i<C_PRIMPOLY_ORDER*2;i=i+1)
	begin
		F_mult = {F_mult[C_PRIMPOLY_ORDER-2:0],S_temp[C_PRIMPOLY_ORDER*2-1-i]} ^ (C_PRIM_POLY[C_PRIMPOLY_ORDER-1:0] & {C_PRIMPOLY_ORDER{F_mult[C_PRIMPOLY_ORDER-1]}});
	end
end
endfunction

//width calculation
function integer GETASIZE;
input integer a;
integer i;
begin
    for(i=1;(2**i)<=a;i=i+1)
      begin
      end
    GETASIZE = i;
end
endfunction

//length of generated polynomial cascaded
function [C_UPP_WIDTH*C_COEF_NUM-1:0] F_GEN_NUM;
input red;
integer i,j;
integer temp;
reg [2**C_PRIMPOLY_ORDER-2:0] S_flag;
begin
	F_GEN_NUM = 0;
    for(i=0;i<C_COEF_NUM;i=i+1)
	begin
		S_flag = 0;
		for(j=1;j<=C_PRIMPOLY_ORDER;j=j+1)
		begin
			temp = (2*i+1)*(2**(j-1));
			while(temp > 2**C_PRIMPOLY_ORDER-2)
				temp = temp - (2**C_PRIMPOLY_ORDER-1);
		    if(!S_flag[temp])
			begin
			    S_flag[temp] = 1;
				F_GEN_NUM[i*C_UPP_WIDTH+:C_UPP_WIDTH]=F_GEN_NUM[i*C_UPP_WIDTH+:C_UPP_WIDTH]+'d1;
			end
		end
	end
end
endfunction

//polynomial division in Galois Field
function [C_PRIMPOLY_ORDER-1:0] F_reg_update;
input [C_PRIMPOLY_ORDER-1:0] S_reg_ori;
input [C_DWIDTH-1:0] S_data;
input [C_PRIMPOLY_ORDER-1:0] S_poly;
input integer S_upp;
integer i;
reg S_temp1;
reg S_temp2;
begin
	F_reg_update = S_reg_ori;
	for(i=0;i<C_DWIDTH;i=i+1)
	begin
		S_temp1 = F_reg_update[S_upp];	
		S_temp2 = S_temp1 ^ S_data[C_DWIDTH-1-i];
		F_reg_update[C_PRIMPOLY_ORDER-1:1] = {F_reg_update[C_PRIMPOLY_ORDER-2:0]} ^ ({(C_PRIMPOLY_ORDER-1){S_temp1}} & S_poly[C_PRIMPOLY_ORDER-1:1]);
		F_reg_update[0] = S_temp2;
	end
end
endfunction

//---------------------------------------
//syndrome calculation
//---------------------------------------
genvar S_i;
generate
for(S_i=0;S_i<C_COEF_NUM;S_i=S_i+1)   //parallel calculation
begin:test

wire [C_PRIMPOLY_ORDER-1:0] S_para1;
reg [C_DWIDTH-1:0] S_para2;

localparam C_POLY = C_GEN_POLY[S_i*C_PRIMPOLY_ORDER+:C_PRIMPOLY_ORDER];
localparam C_UPP = C_GEN_UPP[S_i*C_UPP_WIDTH+:C_UPP_WIDTH]-1;

always @(posedge I_clk)
begin
	S_para2 <= (C_SHIFT_NUM != 0) ? (I_data_sof ? {{C_SHIFT_NUM{1'b0}},I_data[C_DWIDTH-1-:(C_DWIDTH-C_SHIFT_NUM)]} : {S_data,I_data[C_DWIDTH-1-:(C_DWIDTH-C_SHIFT_NUM)]}) : I_data;
end

assign S_para1 = S_data_sof ? 'd0 : S_reg[S_i];

always @(posedge I_clk)
begin
    if(S_data_v)
	begin
		S_reg[S_i] <= F_reg_update(S_para1,S_para2,C_POLY,C_UPP);
	end	
end

end
endgenerate

always @(posedge I_clk)
begin
    S_data <= I_data;
end

integer j,k;
always @(posedge I_clk)
begin
	S_data_eof <= I_data_eof;
	S_data_eof_d <= S_data_eof;
    O_syndrome_v <= S_data_eof_d;
	S_data_v <= I_data_v;
	S_data_sof <= I_data_sof;
	if(S_data_eof_d)
	begin
	    for(j=0;j<C_COEF_NUM;j=j+1)
			for(k=0;k<C_PRIMPOLY_ORDER;k=k+1)
			begin
			    O_syndrome[j*C_PRIMPOLY_ORDER+k] <= ^(S_reg[j] & C_TRANS_MATRIX[j*C_PRIMPOLY_ORDER*C_PRIMPOLY_ORDER+k*C_PRIMPOLY_ORDER+:C_PRIMPOLY_ORDER]);
			end
	end
end


endmodule