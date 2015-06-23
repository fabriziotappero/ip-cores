///-----------------------------------------
///introduce:
///bch encoder
///author:jiml
///record:
///2015.1.31    initial
///-----------------------------------------
`timescale 1ns/100ps
module test_bch_encode
#(
parameter C_DWIDTH = 128,                //input data width
parameter C_COEF_NUM = 43,               //correct threshold
parameter C_PRIMPOLY_ORDER = 14,         //order of eigenpolynomial
parameter C_PRIM_POLY = 15'h4443         //eigenpolynomial
)
(
input                     I_clk       ,
input                     I_rst       ,
input      [C_DWIDTH-1:0] I_data      ,  //input data
input                     I_data_v    ,  //input data available
input                     I_data_sof  ,  //input data frame start
input                     I_data_eof  ,  //input data frame end
output reg [C_DWIDTH-1:0] O_data      ,  //output data
output reg                O_data_v    ,  //output data available
output reg                O_data_sof  ,  //output data frame start
output reg                O_data_eof     //output data frame end
);

///----------------------------------------
///parameter and variable
///----------------------------------------
localparam C_REG_LEN = C_COEF_NUM*C_PRIMPOLY_ORDER;
localparam C_GEN_WIDTH = F_TOTAL_NUM(0);
localparam C_ECC_PERIOD = F_DIV(C_GEN_WIDTH,C_DWIDTH);
localparam C_CNT_WIDTH = GETASIZE(C_ECC_PERIOD);
localparam C_GENPOLY = F_GEN_POLY(0);

reg [C_GEN_WIDTH-1:0] S_reg = 0;
reg [C_CNT_WIDTH-1:0] S_ecc_cnt = 0;
reg S_ecc_v = 0;

//---------------------------------------------
//function
//---------------------------------------------
//calculate length of encode polynomial
function integer F_TOTAL_NUM;
input red;
integer i,j;
integer temp;
reg [2**C_PRIMPOLY_ORDER-2:0] S_flag;
begin
	F_TOTAL_NUM = 0;
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
				F_TOTAL_NUM=F_TOTAL_NUM+1;
			end
		end
	end
end
endfunction

//integer division
function integer F_DIV;
input integer S_DIVIDEND;
input integer S_DIVIDER;
begin
    F_DIV = (S_DIVIDEND-1)/S_DIVIDER;
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

//encode polynomial generation
function [C_GEN_WIDTH:0] F_GEN_POLY;
input red;
integer i,j,k;
integer pointer;
reg [2**C_PRIMPOLY_ORDER-2:0] S_flag;
reg [C_PRIMPOLY_ORDER-1:0] S_temp [C_GEN_WIDTH:0]; //every reg is C_PRIMPOLY_ORDER width, represent a element 
reg [C_PRIMPOLY_ORDER-1:0] S_temp2;
begin
	F_GEN_POLY = 0;
	for(i=0;i<=C_PRIMPOLY_ORDER;i=i+1)
		S_temp[i] = C_PRIM_POLY[i];                //least C_PRIMPOLY_ORDER bits are eigenpolynomial
	for(i=C_PRIMPOLY_ORDER+1;i<=C_GEN_WIDTH;i=i+1)
		S_temp[i] = 0;
	for(i=1;i<C_COEF_NUM;i=i+1)    //encode polynomial include C_COEF_NUM polynomials
	begin
		S_flag = 0;
	    for(j=1;j<=C_PRIMPOLY_ORDER;j=j+1)  //each polynomial have at most C_PRIMPOLY_ORDER element
		begin
			pointer = (2*i+1)*(2**(j-1));
			while(pointer>(2**C_PRIMPOLY_ORDER-2))
				pointer = pointer - (2**C_PRIMPOLY_ORDER-1);
		    if(!S_flag[pointer])            //flag is a marker to indicate element exists or not
			begin
			    S_flag[pointer] = 1;
				S_temp2 = F_gen(1,pointer);
				for(k=C_GEN_WIDTH-1;k>0;k=k-1)   //each polynomial have at most C_PRIMPOLY_ORDER multiplication
				begin
				    S_temp[k]= F_mult(S_temp[k],S_temp2) ^ S_temp[k-1]; //all the reg need to shift in each multiplication
				end
				S_temp[0] = F_mult(S_temp[0],S_temp2);
				S_temp[C_GEN_WIDTH] = S_temp[C_GEN_WIDTH-1];
			end
		end
	end
	for(i=0;i<C_GEN_WIDTH;i=i+1)
	F_GEN_POLY[i] = (S_temp[i] == 1);     //finally the S_temp should only be 1 or 0
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

//polynomial multiplication between encode polynomial and input data
function [C_GEN_WIDTH-1:0] F_reg_update;
input [C_GEN_WIDTH-1:0] S_reg_ori;
input [C_DWIDTH-1:0] S_data;
integer i;
reg S_temp1;
begin
	F_reg_update = S_reg_ori;
	for(i=0;i<C_DWIDTH;i=i+1)
	begin
		S_temp1 = F_reg_update[C_GEN_WIDTH-1] ^ S_data[C_DWIDTH-1-i];	
		F_reg_update[C_GEN_WIDTH-1:0] = {F_reg_update[C_GEN_WIDTH-2:0],1'b0} ^ ({C_GEN_WIDTH{S_temp1}} & C_GENPOLY[C_GEN_WIDTH-1:0]);
	end
end
endfunction

//-----------------------------------------------
//encode
//-----------------------------------------------
always @(posedge I_clk)
begin
	if(I_data_v)
	    S_reg <= F_reg_update(S_reg,I_data);
	else if(S_ecc_v)
	    S_reg <= S_reg << C_DWIDTH;
end

//output counter
always @(posedge I_clk)
begin
    if(S_ecc_v)
	    S_ecc_cnt <= S_ecc_cnt + 'd1;
	else
	    S_ecc_cnt <= 'd0;
end

always @(posedge I_clk)
begin
    if(I_data_eof && I_data_v)
	    S_ecc_v <= 1'b1;
	else if(S_ecc_cnt == C_ECC_PERIOD && S_ecc_v)
	    S_ecc_v <= 1'b0;
end

//data out
always @(posedge I_clk)
begin
    if(S_ecc_v)
	    O_data <= (C_GEN_WIDTH >= C_DWIDTH) ? S_reg[C_GEN_WIDTH-1-:C_DWIDTH] : (S_reg << (C_DWIDTH-C_GEN_WIDTH));
	else
	    O_data <= I_data;
		
	O_data_v <= I_data_v || S_ecc_v;
	O_data_sof <= I_data_sof;
	O_data_eof <= (S_ecc_cnt == C_ECC_PERIOD) && S_ecc_v;
end

endmodule
