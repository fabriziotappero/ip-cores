///-----------------------------------------
///introduce:
///bch correct in decoder
///author:jiml
///record:
///2015.3.15    initial
///-----------------------------------------
`timescale 1ns/100ps
module test_correct
#(
parameter C_INPUT_NUM = 128,          //length of input bit 
parameter C_DWIDTH = 16,              //input data width
parameter C_ECCWIDTH = 16             //check data width
)
(
input                     I_clk        ,
input                     I_rst        ,
input [C_DWIDTH-1:0]      I_data       ,  //input data
input                     I_data_sof   ,  //input data frame start
input                     I_data_eof   ,  //input data frame end
input                     I_data_v     ,  //input data available
input [C_ECCWIDTH-1:0]    I_ecc        ,  //check data
input                     I_ecc_v      ,  //check data available
input                     I_ecc_sof    ,  //check data frame start
input                     I_ecc_eof    ,  //check data frame end
output reg [C_DWIDTH-1:0] O_data       ,  //corrected data
output reg                O_data_v     ,  //corrected data available
output reg                O_data_sof   ,  //corrected data frame start
output reg                O_data_eof      //corrected data frame end
);

//----------------------------------------
//parameter and variable
//----------------------------------------
localparam C_OVERFLOW_THRESHOLD = C_DWIDTH-C_ECCWIDTH+1;
localparam C_DIF = C_DWIDTH - C_ECCWIDTH;
localparam C_SLR_CNT_WIDTH = GETASIZE(C_DWIDTH)+1;
localparam C_CHIP_NUM = C_INPUT_NUM/C_DWIDTH;
localparam C_CHIP_NUM_WIDTH = GETASIZE(C_CHIP_NUM);

reg [2*C_DWIDTH-1:0] S_data_slr = 0;
reg [C_SLR_CNT_WIDTH-1:0] S_slr_cnt = 0;
reg S_ov_id = 0;
reg [C_DWIDTH-1:0] S_data_tran = 0;
reg S_ecc_eof = 0;
reg S_ecc_eof_d = 0;
reg S_ecc_v = 0;
reg [C_ECCWIDTH-1:0] S_ecc = 0;
reg S_data_tran_v = 0;
reg [C_DWIDTH-1:0] S_ecc_ram [2**C_CHIP_NUM_WIDTH-1:0];
reg [C_DWIDTH-1:0] S_data_ram [2**C_CHIP_NUM_WIDTH-1:0];
reg [C_CHIP_NUM_WIDTH-1:0] S_ecc_waddr = 0;
reg [C_CHIP_NUM_WIDTH:0] S_data_waddr = 0;
reg [C_CHIP_NUM_WIDTH-1:0] S_ecc_raddr = 0;
reg S_ecc_r = 0;
reg [C_DWIDTH-1:0] S_ecc_dout;
reg [C_DWIDTH-1:0] S_dataout;
reg S_ecc_r_d = 0;
reg S_data_eof = 0; 
//-------------------------------------------
//function
//-------------------------------------------
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

//big endian change to little endian
function [C_DWIDTH-1:0] F_data_inv;
input [C_DWIDTH-1:0] S_datain;
integer i;
begin
    for(i=0;i<C_DWIDTH;i=i+1)
		F_data_inv[i] = S_datain[C_DWIDTH-1-i];
end
endfunction

//-----------------------------------------
//check data alignment
//-----------------------------------------
always @(posedge I_clk)
begin
    S_ecc_eof <= I_ecc_eof;
	S_ecc_eof_d <= S_ecc_eof;
	S_ecc_v <= I_ecc_v;
	S_ecc <= I_ecc;
end

always @(posedge I_clk)
begin
    if(S_ecc_eof)
	begin
		S_slr_cnt <= 'd0;
		S_ov_id <= 1'b0;
	end
	else if(I_ecc_v)
	begin
		if(S_slr_cnt <= C_OVERFLOW_THRESHOLD)
		begin
    		S_slr_cnt <= S_slr_cnt + C_ECCWIDTH;
			S_ov_id <= 1'b0;
		end
		else
		begin
		    S_slr_cnt <= S_slr_cnt - C_DIF;
			S_ov_id <= 1'b1;
		end
	end		
end

always @(posedge I_clk)
begin
    if(S_ecc_eof_d)
	    S_data_slr <= 'd0;
	else if(I_ecc_v || S_ecc_v)
	begin
	    if(!S_ov_id)
			S_data_slr <= (I_ecc<<S_slr_cnt) | S_data_slr;
		else
		    S_data_slr <= (S_data_slr>>C_DWIDTH) | (I_ecc<<S_slr_cnt);
	end
end

always @(posedge I_clk)
begin
    if(S_ecc_v && S_ov_id)
	    S_data_tran <= F_data_inv(S_data_slr[0+:C_DWIDTH]);
	else if(S_ecc_eof_d)
	    S_data_tran <= F_data_inv(S_data_slr[0+:C_DWIDTH]);
end

always @(posedge I_clk)
begin
    S_data_tran_v <= (S_ecc_v && S_ov_id) || S_ecc_eof_d;
end

//--------------------------------------------------
//original data save
//--------------------------------------------------
always @(posedge I_clk)
begin
    if(I_data_v)
	    S_data_ram[S_data_waddr[C_CHIP_NUM_WIDTH-1:0]] <= I_data;
	S_dataout <= S_data_ram[S_ecc_raddr];
	if(I_data_eof)
	    S_data_waddr <= 'd0;
	else if(I_data_v && (S_data_waddr<C_CHIP_NUM))
	    S_data_waddr <= S_data_waddr + 'd1;
end

always @(posedge I_clk)
begin
    if(S_data_tran_v)
	    S_ecc_ram[S_ecc_waddr] <= S_data_tran;
	S_ecc_dout <= S_ecc_ram[S_ecc_raddr];
	if(I_ecc_sof)
	    S_ecc_waddr <= 'd0;
	else if(S_data_tran_v)
	    S_ecc_waddr <= S_ecc_waddr + 'd1;    
end

always @(posedge I_clk)
begin
    if(S_ecc_waddr == C_CHIP_NUM-1 && S_data_tran_v)
	    S_ecc_r <= 1'b1;
	else if(S_ecc_raddr == C_CHIP_NUM-1)
	    S_ecc_r <= 1'b0;
	S_ecc_r_d <= S_ecc_r;
end

always @(posedge I_clk)
begin
    if(I_ecc_sof)
	    S_ecc_raddr <= 'd0;
	else if(S_ecc_r)
	    S_ecc_raddr <= S_ecc_raddr + 'd1;
end

//---------------------------------------
//correct
//---------------------------------------
always @(posedge I_clk)
begin
    O_data_sof <= S_ecc_raddr == 'd1;
	S_data_eof <= S_ecc_raddr == C_CHIP_NUM-1;
	O_data_eof <= S_data_eof;
end

always @(posedge I_clk)
begin
    O_data <= S_dataout ^ S_ecc_dout;
	O_data_v <= S_ecc_r_d;
end

endmodule
