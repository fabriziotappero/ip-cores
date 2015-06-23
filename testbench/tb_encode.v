`timescale 1ns/100ps
module tb_encode
#(
parameter C_DWIDTH = 32,
parameter C_COEF_NUM = 2,
parameter C_PRIMPOLY_ORDER = 10,
parameter C_GENPOLY = 'h409,
parameter C_INPUT_NUM = 512,
parameter C_SEARCH_THREAD_NUM = 32,
parameter C_TOTALBIT_NUM = 100
)
(
input I_clk                      ,
input I_rst                      ,
input [C_DWIDTH-1:0] I_data      ,
input I_data_v                   ,
input I_data_sof                 ,
input I_data_eof                 ,
input [C_DWIDTH-1:0] I_data_ori  ,
input I_data_v_ori               ,
input I_data_sof_ori             ,
input I_data_eof_ori             ,
output reg [1:0] O_result       
);
wire [C_DWIDTH-1:0] S_data  ;
wire [C_DWIDTH-1:0] S_data_d;
wire S_data_v               ; 
wire S_data_sof             ;
wire S_data_eof             ;
wire [C_PRIMPOLY_ORDER*C_COEF_NUM-1:0] S_syndrome;
wire S_syndrome_v;
wire [C_PRIMPOLY_ORDER*C_COEF_NUM-1+C_PRIMPOLY_ORDER:0] S_err_pos;
wire [C_SEARCH_THREAD_NUM-1:0] S_ecc;
wire S_ecc_v;
wire S_ecc_sof;
wire S_ecc_eof;
wire [C_DWIDTH-1:0] S_data_cor;
wire S_data_v_cor;
wire S_data_sof_cor;
wire S_data_eof_cor;

reg [C_DWIDTH-1:0] S_ram_ori [1023:0];
reg [9:0] S_ram_ori_waddr = 0;
reg [9:0] S_ram_ori_raddr = 0;
reg S_data_eof_cor_d = 0;
reg [C_DWIDTH-1:0] S_ram_ori_dout = 0;
reg S_data_v_cor_d = 0;
reg [C_DWIDTH-1:0] S_data_cor_d = 0;
reg S_data_eof_ori = 0;

always @(posedge I_clk)
begin
	S_data_eof_ori <= I_data_eof_ori;
    if(S_data_eof_ori)
	    S_ram_ori_waddr <= 'd0;
	else if(I_data_v_ori)
	    S_ram_ori_waddr <= S_ram_ori_waddr + 'd1;
	if(I_data_v_ori)
	    S_ram_ori[S_ram_ori_waddr] <= I_data_ori;
end

always @(posedge I_clk)
begin
	S_data_eof_cor_d <= S_data_eof_cor;
    if(S_data_eof_cor_d)
	    S_ram_ori_raddr <= 'd0;
	else if(S_data_v_cor)
	    S_ram_ori_raddr <= S_ram_ori_raddr + 'd1;
	S_ram_ori_dout <= S_ram_ori[S_ram_ori_raddr];
	S_data_v_cor_d <= S_data_v_cor;
	S_data_cor_d <= S_data_cor;
end

always @(posedge I_clk)
begin
	if(S_data_sof_cor)
	    O_result[0] <= 1'b1;
    else if(S_data_v_cor_d)
	    O_result[0] <= O_result[0] && (S_ram_ori_dout == S_data_cor_d);
	O_result[1] <= S_data_eof_cor_d;
	    
end

/*test_bch_encode
#(
.C_DWIDTH         (C_DWIDTH        ),
.C_COEF_NUM       (C_COEF_NUM      ),
.C_PRIMPOLY_ORDER (C_PRIMPOLY_ORDER),
.C_PRIM_POLY      (C_GENPOLY       )
)
test_bch_encode_inst
(
.I_clk       (I_clk      ),
.I_rst       (I_rst      ),
.I_data      (I_data     ),
.I_data_v    (I_data_v   ),
.I_data_sof  (I_data_sof ),
.I_data_eof  (I_data_eof ),
.O_data      (S_data     ),
.O_data_v    (S_data_v   ),
.O_data_sof  (S_data_sof ),
.O_data_eof  (S_data_eof )
);*/

test_bch_syndrome
#(
.C_DWIDTH             (C_DWIDTH),
.C_COEF_NUM           (C_COEF_NUM),
.C_PRIMPOLY_ORDER     (C_PRIMPOLY_ORDER),
.C_PRIM_POLY          (C_GENPOLY)
)
test_bch_syndrome_inst
(
.I_clk          (I_clk),
.I_rst          (I_rst),
.I_data         (I_data    ),
.I_data_v       (I_data_v  ),
.I_data_sof     (I_data_sof),
.I_data_eof     (I_data_eof),
.O_syndrome     (S_syndrome),
.O_syndrome_v   (S_syndrome_v)
);

test_bch_bm
#(
.C_PRIMPOLY_ORDER  (C_PRIMPOLY_ORDER),
.C_COEF_NUM        (C_COEF_NUM),
.C_PRIMPOLY        (C_GENPOLY)
)
test_bch_bm_inst
(
.I_clk          (I_clk),
.I_rst          (I_rst),
.I_syndrome     (S_syndrome),
.I_syndrome_v   (S_syndrome_v),
.O_err_pos      (S_err_pos),
.O_err_pos_v    (S_err_pos_v)
);

test_chian_search
#(
.C_PRIMPOLY_ORDER (C_PRIMPOLY_ORDER),
.C_COEF_NUM       (C_COEF_NUM),
.C_TOTALBIT_NUM   (C_TOTALBIT_NUM),
.C_THREAD_NUM     (C_SEARCH_THREAD_NUM),
.C_PRIMPOLY       (C_GENPOLY)
)
test_chian_search_inst
(
.I_clk        (I_clk),
.I_rst        (I_rst),
.I_coef       (S_err_pos),
.I_coef_v     (S_err_pos_v),
.O_data       (S_ecc    ),
.O_data_v     (S_ecc_v  ),
.O_data_sof   (S_ecc_sof),
.O_data_eof   (S_ecc_eof)
);

test_correct
#(
.C_INPUT_NUM (C_INPUT_NUM),
.C_DWIDTH    (C_DWIDTH ),
.C_ECCWIDTH  (C_SEARCH_THREAD_NUM )
)
test_correct_inst
(
.I_clk        (I_clk),
.I_rst        (I_rst),
.I_data       (I_data  ),
.I_data_sof   (I_data_sof  ),
.I_data_eof   (I_data_eof),
.I_data_v     (I_data_v),
.I_ecc        (S_ecc    ),
.I_ecc_v      (S_ecc_v  ),
.I_ecc_sof    (S_ecc_sof),
.I_ecc_eof    (S_ecc_eof),
.O_data       (S_data_cor    ),
.O_data_v     (S_data_v_cor  ),
.O_data_sof   (S_data_sof_cor),
.O_data_eof   (S_data_eof_cor)
);

endmodule
