///-----------------------------------------
///introduce:
///bch error position search in decoder
///author:jiml
///record:
///2015.1.31    initial
///-----------------------------------------
`timescale 1ns/100ps
module test_chian_search
#(
parameter C_PRIMPOLY_ORDER = 14,              //order of eigenpolynomial
parameter C_COEF_NUM = 43,                    //correct threshold
parameter C_TOTALBIT_NUM = 8832,              //total bit length include original and correct bits
parameter C_THREAD_NUM = 8,                   //parallel search thread
parameter C_PRIMPOLY = 15'h4443               //eigenpolynomial
)
(
input                                                         I_clk       ,
input                                                         I_rst       ,
input      [C_PRIMPOLY_ORDER*C_COEF_NUM-1+C_PRIMPOLY_ORDER:0] I_coef      ,  //error position polynomial
input                                                         I_coef_v    ,  //error position polynomial available
output reg [C_THREAD_NUM-1:0]                                 O_data      ,  //check data
output reg                                                    O_data_v    ,  //check data available
output reg                                                    O_data_sof  ,  //check data frame start
output reg                                                    O_data_eof     //check data frame end
);

//--------------------------------------------
//parameter and variable
//--------------------------------------------
localparam C_SEARCH_START = 2**C_PRIMPOLY_ORDER - 1 - C_TOTALBIT_NUM;
localparam C_CNT_LIMIT = (C_TOTALBIT_NUM-1)/C_THREAD_NUM;
localparam C_CNT_LIMIT_WIDTH = GETASIZE(C_CNT_LIMIT);

reg S_search_v = 0;
reg [C_PRIMPOLY_ORDER-1:0] S_const = 0;
reg S_search_v_d = 0;
reg S_search_v_2d = 0;
reg S_search_v_3d = 0;
reg [C_CNT_LIMIT_WIDTH:0] S_search_cnt = 0;
reg [C_PRIMPOLY_ORDER*C_COEF_NUM-1:0] S_var [C_THREAD_NUM-1:0];
reg [C_PRIMPOLY_ORDER*C_COEF_NUM-1+C_PRIMPOLY_ORDER:0] S_var_xor [C_THREAD_NUM-1:0];
reg [C_PRIMPOLY_ORDER-1:0] S_var_xor_result [C_THREAD_NUM-1:0];
reg [C_THREAD_NUM-1:0] S_err_id = 0;
wire [C_PRIMPOLY_ORDER*C_COEF_NUM-1:0] S_coef1;
wire integer S_coef2 [C_THREAD_NUM-1:0];

//--------------------------------------------
//function
//--------------------------------------------
//element multiplication in Galois Field
function [C_PRIMPOLY_ORDER-1:0] F_var_upgrade;
input [C_PRIMPOLY_ORDER-1:0] S_mult;
input integer S_times;
integer i;
reg [C_PRIMPOLY_ORDER-1:0] S_temp;
reg [C_PRIMPOLY_ORDER-1:0] S_temp2;
reg S_temp_upp;
begin
	S_temp = S_mult;
	for(i=0;i<S_times;i=i+1)
	begin
		S_temp_upp = S_temp[C_PRIMPOLY_ORDER-1];
		S_temp2 = S_temp<<1;
		S_temp = S_temp2 ^ (C_PRIMPOLY[C_PRIMPOLY_ORDER-1:0] & {C_PRIMPOLY_ORDER{S_temp_upp}});
	end
	F_var_upgrade = S_temp;
end
endfunction

//width calculation
function integer GETASIZE;
input integer a;
integer i;
begin
    for(i=1;(2**i)<a;i=i+1)
      begin
      end
    GETASIZE = i;
end
endfunction

///-------------------------------
///search
///-------------------------------
always @(posedge I_clk)
begin
    if(I_rst)
	    S_search_v <= 'd0;
	else if(I_coef_v)
	    S_search_v <= 'd1;
	else if(S_search_cnt == C_CNT_LIMIT)
	    S_search_v <= 'd0;
end

always @(posedge I_clk)
begin
    if(S_search_v)
	    S_search_cnt <= S_search_cnt + 'd1;
	else
	    S_search_cnt <= 'd0;
end

always @(posedge I_clk)
begin
	S_search_v_d <= S_search_v;
	S_search_v_2d <= S_search_v_d;
	S_search_v_3d <= S_search_v_2d;
end

always @(posedge I_clk)
begin
    if(I_coef_v)
	    S_const <= I_coef[C_PRIMPOLY_ORDER-1:0];
end

assign S_coef1 = I_coef_v ? I_coef[C_PRIMPOLY_ORDER+:C_PRIMPOLY_ORDER*C_COEF_NUM] : S_var[C_THREAD_NUM-1];

genvar S_k;
integer k,kk;
generate
for(S_k=0;S_k<C_THREAD_NUM;S_k=S_k+1)                   //parallel search
begin:process

assign S_coef2[S_k] = I_coef_v ? C_SEARCH_START : (S_k+1);

always @(posedge I_clk)
begin
    for(k=0;k<C_COEF_NUM;k=k+1)
		S_var[S_k][C_PRIMPOLY_ORDER*k+:C_PRIMPOLY_ORDER] <= F_var_upgrade(S_coef1[C_PRIMPOLY_ORDER*k+:C_PRIMPOLY_ORDER],S_coef2[S_k]*(k+1));
end

always @(*)
begin
    S_var_xor[S_k][0+:C_PRIMPOLY_ORDER] = S_const;
end

always @(*)
begin 
	for(kk=0;kk<C_COEF_NUM;kk=kk+1) 
	S_var_xor[S_k][C_PRIMPOLY_ORDER*(kk+1)+:C_PRIMPOLY_ORDER] = I_coef_v ? 'd0 : (S_var_xor[S_k][C_PRIMPOLY_ORDER*(kk)+:C_PRIMPOLY_ORDER] ^ S_var[S_k][C_PRIMPOLY_ORDER*kk+:C_PRIMPOLY_ORDER]);
end

always @(posedge I_clk)
begin
    S_var_xor_result[S_k] <= S_var_xor[S_k][C_PRIMPOLY_ORDER*C_COEF_NUM+:C_PRIMPOLY_ORDER];
end

always @(posedge I_clk)
begin
    S_err_id[S_k] <= (S_var_xor_result[S_k] == 'd0);   //zero means error position
end

end
endgenerate

//-------------------------------------------
//check data output
//-------------------------------------------
always @(posedge I_clk)
begin
    O_data <= S_err_id;
	O_data_v <= S_search_v_3d;
end

always @(posedge I_clk)
begin
    O_data_sof <= S_search_v_3d && (!O_data_v);
	O_data_eof <= (!S_search_v_2d) && S_search_v_3d;
end

endmodule


