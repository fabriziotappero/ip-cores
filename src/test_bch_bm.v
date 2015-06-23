///-----------------------------------------
///introduce:
///bch error position polynomial calculate by bm algorithm
///author:jiml
///record:
///2015.1.31    initial
///2015.2.2     S_syndrome modified from parallel to serial
///-----------------------------------------
`timescale 1ns/100ps
module test_bch_bm
#(
    parameter C_PRIMPOLY_ORDER = 14,          //order of eigenpolynomial
    parameter C_COEF_NUM = 43,                //correct threshold
	parameter C_PRIMPOLY = 15'h4443           //eigenpolynomial
)
(
input                                                           I_clk        ,
input                                                           I_rst        ,
input      [C_PRIMPOLY_ORDER*C_COEF_NUM-1:0]                    I_syndrome   , //syndrome cascaded
input                                                           I_syndrome_v , //syndrome available
output reg [C_PRIMPOLY_ORDER*C_COEF_NUM-1+C_PRIMPOLY_ORDER:0]   O_err_pos    , //error position polynomial
(* MAX_FANOUT=30 *)output reg                                   O_err_pos_v    //error position polynomial available
);

//--------------------------------
//parameter and variable
//--------------------------------
localparam C_CYCLE = GETASIZE(C_COEF_NUM);
integer i,j,jj;
reg [C_CYCLE+1:0]                             S_syndrome_v_slr = 0;
reg                                           S_syndrome_v_all = 0;
reg [C_PRIMPOLY_ORDER-1:0]                    S_syndrome [2*C_COEF_NUM-1:0];
reg                                           S_syndrome_v = 0;
reg                                           S_syndrome_v_d = 0;
reg                                           S_syndrome_v_2d = 0;
reg                                           S_syndrome_v_3d = 0;
reg                                           S_bm_cnt2_d = 0;
reg [C_PRIMPOLY_ORDER*C_COEF_NUM-1:0]         S_syndrome_seq = 0;
reg [C_PRIMPOLY_ORDER*C_COEF_NUM-1:0]         S_syndrome_seq2 = 0;
reg [C_PRIMPOLY_ORDER-1:0]                    S_syndrome_new = 0;
reg [C_PRIMPOLY_ORDER-1:0]                    S_syndrome_seq_sel = 0;
reg [C_PRIMPOLY_ORDER-1:0]                    S_syndrome_new_d = 0;
reg [C_PRIMPOLY_ORDER*(C_COEF_NUM+1)-1:0]     S_syndrome_slr = 0;
(* MAX_FANOUT=8 *)reg [C_PRIMPOLY_ORDER-1:0]  S_poly_v [C_COEF_NUM-1+1:0];
reg [C_PRIMPOLY_ORDER-1:0]                    S_poly_deltav [C_COEF_NUM-1+1:0];
(* MAX_FANOUT=16 *)reg [C_PRIMPOLY_ORDER-1:0] S_poly_k [C_COEF_NUM-1+2:0];
(* MAX_FANOUT=50 *)reg [C_PRIMPOLY_ORDER-1:0] S_delta;
reg [C_PRIMPOLY_ORDER-1:0]                    S_d_uint [C_COEF_NUM-1+1:0];
(* MAX_FANOUT=36 *)reg [C_PRIMPOLY_ORDER-1:0] S_d;
wire [C_PRIMPOLY_ORDER-1:0]                   S_d_xor [C_COEF_NUM+1:0];
reg [C_PRIMPOLY_ORDER-1:0]                    S_mult_result [C_COEF_NUM-1:0];
reg                                           S_bm_v = 0;
reg                                           S_bm_v_d = 0;
reg                                           S_bm_v_2d = 0;
(* MAX_FANOUT=36 *)reg [1:0]                  S_bm_cnt = 0;
reg [C_CYCLE-1:0]                             S_bm_cnt2 = 0;
reg                                           S_d_nozero = 0;
reg                                           S_kdelta_v = 0;
reg [C_COEF_NUM-1:0]                          S_poly_v_exist = 0;
reg                                           S_poly_v_exist_all = 0;
reg                                           S_syndrome_ram_we = 0;
reg [C_PRIMPOLY_ORDER-1:0]                    S_syndrome_ram [2**C_CYCLE-1:0];
reg [C_CYCLE-1:0]                             S_syndrome_waddr = 0;
reg [C_CYCLE-1:0]                             S_syndrome_raddr = 0;
reg [C_PRIMPOLY_ORDER-1:0]                    S_syndrome_ram_dout = 0;
reg                                           S_k_v = 0;


///----------------------------
///function
///----------------------------
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

//two elements in Galois Field multiplication
function [C_PRIMPOLY_ORDER-1:0] F_var_upgrade;
input [C_PRIMPOLY_ORDER-1:0] S_mult1;
input [C_PRIMPOLY_ORDER-1:0] S_mult2;
integer i;
reg [C_PRIMPOLY_ORDER-1:0] S_temp1;
reg [C_PRIMPOLY_ORDER-1:0] S_temp2;
begin
	F_var_upgrade = {C_PRIMPOLY_ORDER{1'b0}};
	for(i=0;i<C_PRIMPOLY_ORDER;i=i+1)
	begin
	    S_temp1 = {C_PRIMPOLY_ORDER{F_var_upgrade[C_PRIMPOLY_ORDER-1]}} & C_PRIMPOLY[C_PRIMPOLY_ORDER-1:0];
		S_temp2 = {C_PRIMPOLY_ORDER{S_mult1[C_PRIMPOLY_ORDER-1-i]}} & S_mult2;
		F_var_upgrade = {F_var_upgrade[C_PRIMPOLY_ORDER-2:0],1'b0} ^ S_temp1 ^ S_temp2;
	end
end
endfunction

///----------------------------
///syndrome
///----------------------------
always @(posedge I_clk)
begin
    S_syndrome_v_slr <= {S_syndrome_v_slr[C_CYCLE:0],I_syndrome_v};
	S_syndrome_v_all <= |S_syndrome_v_slr;
	S_syndrome_v <= I_syndrome_v;
	S_syndrome_v_d <= S_syndrome_v;
	S_syndrome_v_2d <= S_syndrome_v_d;
	S_syndrome_v_3d <= S_syndrome_v_2d;
	S_bm_cnt2_d <= S_bm_cnt2[0];
end

//an odd order syndrome used to calculate even order syndrome
always @(posedge I_clk)
begin
    if(I_syndrome_v)
	    S_syndrome_seq <= I_syndrome;
	else if((S_bm_cnt == 'd2 && S_bm_cnt2_d) || S_syndrome_v)
	    S_syndrome_seq <= S_syndrome_seq>>C_PRIMPOLY_ORDER;
end

//every iteration need an odd order syndrome
always @(posedge I_clk)
begin
    if(I_syndrome_v)
	    S_syndrome_seq2 <= I_syndrome;
	else if(S_bm_cnt == 'd1)
	    S_syndrome_seq2 <= S_syndrome_seq2>>C_PRIMPOLY_ORDER;
end

//even order syndrome generation by multiplication, multiplier is odd order or even order 
always @(posedge I_clk) 
begin
    S_syndrome_new <= F_var_upgrade(S_syndrome_seq_sel,S_syndrome_seq_sel);
end

//multiplier selection, S_syndrome_seq[C_PRIMPOLY_ORDER-1:0] is odd order, and S_syndrome_ram_dout is even order
always @(posedge I_clk)
begin
    if(I_syndrome_v)
	    S_syndrome_seq_sel <= I_syndrome[C_PRIMPOLY_ORDER-1:0];
	else if(S_syndrome_v_3d)
	    S_syndrome_seq_sel <= S_syndrome_new_d;
	else if(S_bm_cnt == 'd2) 
	begin
	    S_syndrome_seq_sel <= (S_bm_cnt2_d) ? S_syndrome_seq[C_PRIMPOLY_ORDER-1:0] : S_syndrome_ram_dout;
	end
end

//every iteration need an even order syndrome
always @(posedge I_clk) 
begin
    if(S_bm_cnt == 'd1 || S_syndrome_v_d)
	    S_syndrome_new_d <= S_syndrome_new;
end

//even order syndrome are saved into ram for further even order syndrome calculation
always @(posedge I_clk)
begin
    S_syndrome_ram_we <= (S_bm_cnt == 'd1) && S_bm_v_2d;
	if(S_syndrome_ram_we)
	    S_syndrome_ram[S_syndrome_waddr] <= S_syndrome_new_d;
	if(I_syndrome_v)
	    S_syndrome_waddr <= 'd0;
	else if(S_syndrome_ram_we)
	    S_syndrome_waddr <= S_syndrome_waddr + 'd1;
	S_syndrome_ram_dout <= S_syndrome_ram[S_syndrome_raddr];
	if(I_syndrome_v)
	    S_syndrome_raddr <= 'd0;
	else if((S_bm_cnt == 'd1) && (!S_bm_cnt2_d) && S_bm_v_2d)
	    S_syndrome_raddr <= S_syndrome_raddr + 'd1;
end

//syndrome update every iteration
always @(posedge I_clk)
begin
    if(I_syndrome_v)
	begin
	    S_syndrome_slr <= 'd0;
		S_syndrome_slr[C_PRIMPOLY_ORDER-1:0] <= I_syndrome[C_PRIMPOLY_ORDER-1:0];
		S_syndrome_slr[2*C_PRIMPOLY_ORDER-1:C_PRIMPOLY_ORDER] <= 'd1;
	end
	else if(S_bm_cnt == 'd2)
	begin
	    S_syndrome_slr <= S_syndrome_slr<<(C_PRIMPOLY_ORDER*2);
		S_syndrome_slr[0+:C_PRIMPOLY_ORDER*2] <= {S_syndrome_new_d,S_syndrome_seq2[C_PRIMPOLY_ORDER-1:0]};
	end
end

///-------------------------------
///bm
///-------------------------------
///bm algorithm
///v(0)=1,k(0)=1,delta(-2)=1
///for k=0:1:C_COEF_NUM-1
///v(2k+2)=delta(2k-2)*v(2k)+d(2k)*k(2k)*z
///k(2k+2)=z^2*k(2k)        if d(2k) == 0 or if deg v(2k)>k
///k(2k+2)=z*v(2k)          if d(2k) != 0 and if deg v(2k)<=k
///delta(2k)=delta(2k-2)    if d(2k) == 0 or if deg v(2k)>k
///delta(2k)=d(2k)          if d(2k) != 0 and if deg v(2k)<=k

always @(posedge I_clk)
begin
    if(S_syndrome_v)
	    S_bm_v <= 'b1;
	else if(S_bm_cnt2 == C_COEF_NUM)
	    S_bm_v <= 'b0;
end

always @(posedge I_clk)
begin
    O_err_pos_v <= (!S_bm_v) && S_bm_v_d;
end

always @(posedge I_clk)
begin
    if(S_bm_v)
	begin
	    if(S_bm_cnt=='d2)
		    S_bm_cnt <= 'd0;
		else
		    S_bm_cnt <= S_bm_cnt + 'd1;
	end
	else
	    S_bm_cnt <= 'd0;
end

always @(posedge I_clk)
begin
    if(S_bm_v)
	begin
	    if(S_bm_cnt=='d1)
		    S_bm_cnt2 <= S_bm_cnt2 + 'd1;
	end
	else
	    S_bm_cnt2 <= 'd0; 
end

//variable d generation
always @(posedge I_clk)
begin
	if(S_bm_cnt[1:0]=='d1)
	    S_d <= S_d_xor[C_COEF_NUM+1];	
end

always @(posedge I_clk)
begin
    S_d_nozero <= (S_d != 'd0);
	S_kdelta_v <= (S_bm_cnt[1:0]=='d2);
	S_k_v <= (S_bm_cnt[1:0]=='d1);
	S_bm_v_d <= S_bm_v;
	S_bm_v_2d <= S_bm_v_d;
	if(S_bm_cnt[1:0]=='d1)
		S_poly_deltav[C_COEF_NUM] <= F_var_upgrade(S_delta,S_poly_v[C_COEF_NUM]);
end

assign S_d_xor[0] = 0;

genvar S_jj;
generate
for(S_jj=0;S_jj<=C_COEF_NUM;S_jj=S_jj+1)
begin:bm2

assign S_d_xor[S_jj+1] = S_d_xor[S_jj] ^ S_d_uint[S_jj];

always @(posedge I_clk)
begin
    if(S_bm_cnt[1:0]=='d0) 
	begin
	    S_d_uint[S_jj] <= F_var_upgrade(S_syndrome_slr[S_jj*C_PRIMPOLY_ORDER+:C_PRIMPOLY_ORDER],S_poly_v[S_jj]);
	end	
end
end
endgenerate


genvar S_j;
generate
for(S_j=0;S_j<C_COEF_NUM;S_j=S_j+1)
begin:bm

always @(posedge I_clk)
begin
    if(S_bm_cnt[1:0]=='d1)
		S_poly_deltav[S_j] <= F_var_upgrade(S_delta,S_poly_v[S_j]);
end

//variable v generation
always @(posedge I_clk)
begin
    if(I_syndrome_v)
	    S_poly_v[S_j+1] <= 'd0;
	else if(S_bm_cnt[1:0]=='d2)
	    S_poly_v[S_j+1] <= S_poly_deltav[S_j+1] ^ F_var_upgrade(S_poly_k[S_j],S_d);
end

always @(posedge I_clk)
begin
    S_poly_v_exist[S_j] <= (S_poly_v[S_j] != 'd0) && (S_j > S_bm_cnt2);
end

always @(posedge I_clk)
begin
    O_err_pos[C_PRIMPOLY_ORDER*S_j+C_PRIMPOLY_ORDER-1-:C_PRIMPOLY_ORDER] <= S_poly_v[S_j];
end

end
endgenerate

always @(posedge I_clk)
begin
    S_poly_v_exist_all <= |S_poly_v_exist;
	O_err_pos[C_PRIMPOLY_ORDER*C_COEF_NUM+C_PRIMPOLY_ORDER-1-:C_PRIMPOLY_ORDER] <= S_poly_v[C_COEF_NUM];
end

always @(posedge I_clk) 
begin
    if(I_syndrome_v)
	    S_poly_v[0] <= 'd1;
	else if(S_bm_cnt[1:0]=='d2)
	    S_poly_v[0] <= S_poly_deltav[0];
end

//variable k generation
genvar S_k;
generate
for(S_k=1;S_k<C_COEF_NUM;S_k=S_k+1)
begin:think
always @(posedge I_clk)
begin
    if(I_syndrome_v)
	    S_poly_k[S_k+1] <= 'd0;
	else if(S_k_v)
	begin
	    if(!((S_d != 'd0) && !S_poly_v_exist_all))
		    S_poly_k[S_k+1] <= S_poly_k[S_k-1];
		else
		    S_poly_k[S_k+1] <= S_poly_v[S_k];
	end
end
end
endgenerate

always @(posedge I_clk) 
begin
    if(I_syndrome_v)
	begin
	    S_poly_k[0] <= 'd1;
		S_poly_k[1] <= 'd0;
		S_poly_k[C_COEF_NUM+1] <= 'd0;
	end
	else if(S_k_v)
	begin
	    if(!((S_d != 'd0) && !S_poly_v_exist_all))
		begin
		    S_poly_k[0] <= 'd0;
			S_poly_k[1] <= 'd0;
			S_poly_k[C_COEF_NUM+1] <= S_poly_k[C_COEF_NUM-1];
		end
		else
		begin
		    S_poly_k[1] <= S_poly_v[0];
			S_poly_k[0] <= 'd0;
			S_poly_k[C_COEF_NUM+1] <= S_poly_v[C_COEF_NUM];
		end
	end
end

//variable delta generation
always @(posedge I_clk) 
begin
    if(I_syndrome_v)
	    S_delta <= 'd1;
	else if(S_kdelta_v && S_d_nozero && !S_poly_v_exist_all)
	    S_delta <= S_d;
end

endmodule
