`timescale 1ns/100ps
module sim_top;


reg I_clk;
reg I_rst;

reg [31:0] S_data_random1 = 0;
reg [31:0] S_data_random2 = 0;
reg [31:0] S_data_random3 = 0;
reg [31:0] S_data_random4 = 0;

reg S_start_id = 0;
wire [127:0] S_data_random;
initial
begin
    I_clk = 0;
	forever #5 I_clk = !I_clk;
end

initial
begin
	I_rst = 0;
	#100
	forever
	begin
	    @(posedge I_clk);
		T_random_gen;
	end
end

initial
begin
	S_start_id = 0;
    #120
	@(posedge I_clk);
	S_start_id = 1;
	@(posedge I_clk);
	S_start_id = 0;
end

task T_random_gen;
begin
	S_data_random1 = $random;
	S_data_random2 = $random;
	S_data_random3 = $random;
	S_data_random4 = $random;
end
endtask


assign S_data_random = {S_data_random4,S_data_random3,S_data_random2,S_data_random1};
localparam C_FRAME_LEN = 64;
genvar S_i;
generate
for(S_i=0;S_i<1;S_i=S_i+1)
begin:test

localparam C_DWIDTH_THREAD = 2**(S_i+1);
localparam C_INPUT_NUM = C_DWIDTH_THREAD*C_FRAME_LEN;
localparam C_COEF_NUM = (S_i<3) ? 15 : 4*(S_i+4);
localparam C_TOTALBIT_NUM = C_INPUT_NUM + C_COEF_NUM*(S_i+8);
//localparam C_TOTALBIT_NUM = C_INPUT_NUM + C_COEF_NUM*(S_i+8) - 4; //primpoly8 is not all 8 in genpoly,one in the middle is 4
localparam C_PRIMPOLY_ORDER = S_i + 8;
localparam C_GENPOLY = (S_i == 0) ? 'h11d : ((S_i == 1) ? 'h211 : ((S_i == 2) ? 'h409 : ((S_i == 3) ? 'h805 : ((S_i == 4) ? 'h1053 : ((S_i == 5) ? 'h201b : 'h4443)))));
localparam C_SEARCH_THREAD_NUM = 2**S_i;
localparam C_BYTE_NUM = C_TOTALBIT_NUM/C_DWIDTH_THREAD;
localparam C_COEF_NUM2 = C_COEF_NUM;

wire [C_DWIDTH_THREAD-1:0] S_data;
reg [C_DWIDTH_THREAD-1:0] S_data_d;
wire S_data_v;
wire S_data_sof;
wire S_data_eof;
reg S_data_v_d;
reg S_data_sof_d;
reg S_data_eof_d;
wire [1:0] S_result;
reg I_data_v;
reg I_data_sof;
reg I_data_eof;
integer S_err_byte [C_COEF_NUM2-1 : 0];
reg [C_DWIDTH_THREAD-1:0] S_err_bit [C_COEF_NUM2-1 : 0] ;
integer S_err_num;

reg [7:0] S_encode_cnt = 0;
reg [7:0] S_cnt = 0;
reg S_data_v_2d = 0;

test_bch_encode
#(
.C_DWIDTH         (C_DWIDTH_THREAD        ),
.C_COEF_NUM       (C_COEF_NUM      ),
.C_PRIMPOLY_ORDER (C_PRIMPOLY_ORDER),
.C_PRIM_POLY      (C_GENPOLY       )
)
test_bch_encode_inst
(
.I_clk       (I_clk      ),
.I_rst       (I_rst      ),
.I_data      (S_data_random[C_DWIDTH_THREAD-1:0]),
.I_data_v    (I_data_v   ),
.I_data_sof  (I_data_sof ),
.I_data_eof  (I_data_eof ),
.O_data      (S_data     ),
.O_data_v    (S_data_v   ),
.O_data_sof  (S_data_sof ),
.O_data_eof  (S_data_eof )
);

always @(posedge I_clk)
begin
    if(S_start_id || S_result[1] || S_cnt != 0)
	begin
	    if(S_cnt == C_FRAME_LEN)
		    S_cnt <= 'd0;
		else
		    S_cnt <= S_cnt + 'd1;
	end
end

always @(posedge I_clk)
begin
    I_data_v <= (S_cnt != 'd0);
	I_data_sof <= S_cnt == 'd1;
	I_data_eof <= S_cnt == C_FRAME_LEN;
end

integer ii;

initial
begin
	forever
	begin
    wait(I_data_sof || S_result[1]);
	S_err_num = {$random}%C_COEF_NUM;
	for(ii=0;ii<C_COEF_NUM2;ii=ii+1)
	begin
	S_err_byte[ii] = {$random}%C_BYTE_NUM;
	S_err_bit[ii] = 1<<({$random}%C_DWIDTH_THREAD);
	end
	@(posedge I_clk);
	end
end

integer jj;

always @(posedge I_clk)
begin
    if(S_data_v)
		S_encode_cnt <= S_encode_cnt + 'd1;
	else
	    S_encode_cnt <= 'd0;
end

always @(posedge I_clk)
begin
    if(S_data_v)
	begin
		S_data_d = S_data;
	    for(jj=0;jj<C_COEF_NUM2;jj=jj+1)
		begin
			if(S_encode_cnt==S_err_byte[jj])
				S_data_d = S_data ^ S_err_bit[jj];
		end
	end
end

always @(posedge I_clk)
begin
    S_data_sof_d <= S_data_sof;
	S_data_eof_d <= S_data_eof;
	S_data_v_d <= S_data_v;
	S_data_v_2d <= S_data_v_d;
end

tb_encode
#(
.C_DWIDTH            (C_DWIDTH_THREAD),
.C_COEF_NUM          (C_COEF_NUM),
.C_PRIMPOLY_ORDER    (C_PRIMPOLY_ORDER),
.C_GENPOLY           (C_GENPOLY),
.C_INPUT_NUM         (C_INPUT_NUM),
.C_SEARCH_THREAD_NUM (C_SEARCH_THREAD_NUM),
.C_TOTALBIT_NUM      (C_TOTALBIT_NUM)
)
tb_encode_inst
(
.I_clk                     (I_clk),
.I_rst                     (I_rst),
.I_data                    (S_data_d),
.I_data_v                  (S_data_v_d),
.I_data_sof                (S_data_sof_d),
.I_data_eof                (S_data_eof_d),
.I_data_ori                (S_data_random[C_DWIDTH_THREAD-1:0]),
.I_data_v_ori              (I_data_v),
.I_data_sof_ori            (I_data_sof),
.I_data_eof_ori            (I_data_eof),
.O_result                  (S_result)
);
integer fid1;
integer fid2;
initial
begin
    fid1 = $fopen("data1.txt");
	fid2 = $fopen("data2.txt");
end
always @(posedge I_clk)
begin
    if(S_data_v_2d)
		$fdisplay(fid1,"%d",S_data_d);
	if(I_data_v)
	    $fdisplay(fid2,"%d",S_data_random[C_DWIDTH_THREAD-1:0]);
end

always @(posedge I_clk)
begin
    if(S_result[1])
	begin
		$display("width is %d,input number is %d,C_COEF_NUM is %d,total number is %d,prime order is %d,search thread is %d",C_DWIDTH_THREAD,C_INPUT_NUM,C_COEF_NUM,C_TOTALBIT_NUM,C_PRIMPOLY_ORDER,C_SEARCH_THREAD_NUM);
	    if(S_result[0])
			begin
				$display("bch is right");
			end
		else
			begin
				$display("bch is wrong");	
				$stop();
			end
	end
end

end
endgenerate



endmodule
