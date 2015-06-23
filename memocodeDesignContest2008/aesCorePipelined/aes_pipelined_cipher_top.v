module aes_pipelined_cipher_top(clk, rst, ld, ready, done, key, text_in, text_out );
input		clk, rst;
input		ld;
output      ready;
output	done;
input	[127:0]	key;
input	[127:0]	text_in;
output	[127:0]	text_out;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

wire	[31:0]	w0[9:0];   
wire    [31:0]  w1[9:0];
wire    [31:0]  w2[9:0];
wire    [31:0]  w3[9:0];
reg	[127:0]	text_out;
reg	[7:0]	sa00[9:0], sa01[9:0], sa02[9:0], sa03[9:0];
reg	[7:0]	sa10[9:0], sa11[9:0], sa12[9:0], sa13[9:0];
reg	[7:0]	sa20[9:0], sa21[9:0], sa22[9:0], sa23[9:0];
reg	[7:0]	sa30[9:0], sa31[9:0], sa32[9:0], sa33[9:0];
wire	[7:0]	sa00_next[9:0], sa01_next[9:0], sa02_next[9:0], sa03_next[9:0];
wire	[7:0]	sa10_next[9:0], sa11_next[9:0], sa12_next[9:0], sa13_next[9:0];
wire	[7:0]	sa20_next[9:0], sa21_next[9:0], sa22_next[9:0], sa23_next[9:0];
wire	[7:0]	sa30_next[9:0], sa31_next[9:0], sa32_next[9:0], sa33_next[9:0];
wire	[7:0]	sa00_sub[9:0], sa01_sub[9:0], sa02_sub[9:0], sa03_sub[9:0];
wire	[7:0]	sa10_sub[9:0], sa11_sub[9:0], sa12_sub[9:0], sa13_sub[9:0];
wire	[7:0]	sa20_sub[9:0], sa21_sub[9:0], sa22_sub[9:0], sa23_sub[9:0];
wire	[7:0]	sa30_sub[9:0], sa31_sub[9:0], sa32_sub[9:0], sa33_sub[9:0];
wire	[7:0]	sa00_sr[9:0], sa01_sr[9:0], sa02_sr[9:0], sa03_sr[9:0];
wire	[7:0]	sa10_sr[9:0], sa11_sr[9:0], sa12_sr[9:0], sa13_sr[9:0];
wire	[7:0]	sa20_sr[9:0], sa21_sr[9:0], sa22_sr[9:0], sa23_sr[9:0];
wire	[7:0]	sa30_sr[9:0], sa31_sr[9:0], sa32_sr[9:0], sa33_sr[9:0];
wire	[7:0]	sa00_mc[9:0], sa01_mc[9:0], sa02_mc[9:0], sa03_mc[9:0];
wire	[7:0]	sa10_mc[9:0], sa11_mc[9:0], sa12_mc[9:0], sa13_mc[9:0];
wire	[7:0]	sa20_mc[9:0], sa21_mc[9:0], sa22_mc[9:0], sa23_mc[9:0];
wire	[7:0]	sa30_mc[9:0], sa31_mc[9:0], sa32_mc[9:0], sa33_mc[9:0];
reg		done, ld_r[9:0];
assign ready = 1'b1;
integer i;

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

always @(posedge clk) if(!rst) ld_r[0] <= 1'b0; else ld_r[0] <= ld;
always @(posedge clk) if (!rst) for(i=1; i<10; i=i+1) ld_r[i] <= 1'b0;
                      else      for(i=1; i<10; i=i+1) ld_r[i] <= ld_r[i-1];
always @(posedge clk) if (!rst) done <= 1'b0; else done <= ld_r[9];

////////////////////////////////////////////////////////////////////
//
// Initial Permutation (AddRoundKey)
//
always @(posedge clk) sa33[0] <=  ld ? text_in[007:000] ^ key[07:00] : 8'b0;
always @(posedge clk) sa23[0] <=  ld ? text_in[015:008] ^ key[15:08] : 8'b0;
always @(posedge clk) sa13[0] <=  ld ? text_in[023:016] ^ key[23:16] : 8'b0;
always @(posedge clk) sa03[0] <=  ld ? text_in[031:024] ^ key[31:24] : 8'b0;
always @(posedge clk) sa32[0] <=  ld ? text_in[039:032] ^ key[39:32] : 8'b0;
always @(posedge clk) sa22[0] <=  ld ? text_in[047:040] ^ key[47:40] : 8'b0;
always @(posedge clk) sa12[0] <=  ld ? text_in[055:048] ^ key[55:48] : 8'b0;
always @(posedge clk) sa02[0] <=  ld ? text_in[063:056] ^ key[63:56] : 8'b0;
always @(posedge clk) sa31[0] <=  ld ? text_in[071:064] ^ key[71:64] : 8'b0;
always @(posedge clk) sa21[0] <=  ld ? text_in[079:072] ^ key[79:72] : 8'b0;
always @(posedge clk) sa11[0] <=  ld ? text_in[087:080] ^ key[87:80] : 8'b0;
always @(posedge clk) sa01[0] <=  ld ? text_in[095:088] ^ key[95:88] : 8'b0;
always @(posedge clk) sa30[0] <=  ld ? text_in[103:096] ^ key[103:96] : 8'b0;
always @(posedge clk) sa20[0] <=  ld ? text_in[111:104] ^ key[111:104] : 8'b0;
always @(posedge clk) sa10[0] <=  ld ? text_in[119:112] ^ key[119:112] : 8'b0;
always @(posedge clk) sa00[0] <=  ld ? text_in[127:120] ^ key[127:120] : 8'b0;

////////////////////////////////////////////////////////////////////
//
// Round Permutations
//
genvar k;
generate
for(k=0; k<10; k=k+1) begin: sub_wire
assign sa00_sr[k] = sa00_sub[k];
assign sa01_sr[k] = sa01_sub[k];
assign sa02_sr[k] = sa02_sub[k];
assign sa03_sr[k] = sa03_sub[k];
assign sa10_sr[k] = sa11_sub[k];
assign sa11_sr[k] = sa12_sub[k];
assign sa12_sr[k] = sa13_sub[k];
assign sa13_sr[k] = sa10_sub[k];
assign sa20_sr[k] = sa22_sub[k];
assign sa21_sr[k] = sa23_sub[k];
assign sa22_sr[k] = sa20_sub[k];
assign sa23_sr[k] = sa21_sub[k];
assign sa30_sr[k] = sa33_sub[k];
assign sa31_sr[k] = sa30_sub[k];
assign sa32_sr[k] = sa31_sub[k];
assign sa33_sr[k] = sa32_sub[k];
end
for(k=0; k<9; k=k+1) begin: mc_wire
assign {sa00_mc[k], sa10_mc[k], sa20_mc[k], sa30_mc[k]}  = mix_col(sa00_sr[k],sa10_sr[k],sa20_sr[k],sa30_sr[k]);
assign {sa01_mc[k], sa11_mc[k], sa21_mc[k], sa31_mc[k]}  = mix_col(sa01_sr[k],sa11_sr[k],sa21_sr[k],sa31_sr[k]);
assign {sa02_mc[k], sa12_mc[k], sa22_mc[k], sa32_mc[k]}  = mix_col(sa02_sr[k],sa12_sr[k],sa22_sr[k],sa32_sr[k]);
assign {sa03_mc[k], sa13_mc[k], sa23_mc[k], sa33_mc[k]}  = mix_col(sa03_sr[k],sa13_sr[k],sa23_sr[k],sa33_sr[k]);
assign sa00_next[k] = sa00_mc[k] ^ w0[k][31:24];
assign sa01_next[k] = sa01_mc[k] ^ w1[k][31:24];
assign sa02_next[k] = sa02_mc[k] ^ w2[k][31:24];
assign sa03_next[k] = sa03_mc[k] ^ w3[k][31:24];
assign sa10_next[k] = sa10_mc[k] ^ w0[k][23:16];
assign sa11_next[k] = sa11_mc[k] ^ w1[k][23:16];
assign sa12_next[k] = sa12_mc[k] ^ w2[k][23:16];
assign sa13_next[k] = sa13_mc[k] ^ w3[k][23:16];
assign sa20_next[k] = sa20_mc[k] ^ w0[k][15:08];
assign sa21_next[k] = sa21_mc[k] ^ w1[k][15:08];
assign sa22_next[k] = sa22_mc[k] ^ w2[k][15:08];
assign sa23_next[k] = sa23_mc[k] ^ w3[k][15:08];
assign sa30_next[k] = sa30_mc[k] ^ w0[k][07:00];
assign sa31_next[k] = sa31_mc[k] ^ w1[k][07:00];
assign sa32_next[k] = sa32_mc[k] ^ w2[k][07:00];
assign sa33_next[k] = sa33_mc[k] ^ w3[k][07:00];
end
endgenerate

always @(posedge clk)	for(i=0; i<9; i=i+1) sa33[i+1] <= sa33_next[i];
always @(posedge clk)	for(i=0; i<9; i=i+1) sa23[i+1] <= sa23_next[i];
always @(posedge clk)	for(i=0; i<9; i=i+1) sa13[i+1] <= sa13_next[i];
always @(posedge clk)	for(i=0; i<9; i=i+1) sa03[i+1] <= sa03_next[i];
always @(posedge clk)	for(i=0; i<9; i=i+1) sa32[i+1] <= sa32_next[i];
always @(posedge clk)	for(i=0; i<9; i=i+1) sa22[i+1] <= sa22_next[i];
always @(posedge clk)	for(i=0; i<9; i=i+1) sa12[i+1] <= sa12_next[i];
always @(posedge clk)	for(i=0; i<9; i=i+1) sa02[i+1] <= sa02_next[i];
always @(posedge clk)	for(i=0; i<9; i=i+1) sa31[i+1] <= sa31_next[i];
always @(posedge clk)	for(i=0; i<9; i=i+1) sa21[i+1] <= sa21_next[i];
always @(posedge clk)	for(i=0; i<9; i=i+1) sa11[i+1] <= sa11_next[i];
always @(posedge clk)	for(i=0; i<9; i=i+1) sa01[i+1] <= sa01_next[i];
always @(posedge clk)	for(i=0; i<9; i=i+1) sa30[i+1] <= sa30_next[i];
always @(posedge clk)	for(i=0; i<9; i=i+1) sa20[i+1] <= sa20_next[i];
always @(posedge clk)	for(i=0; i<9; i=i+1) sa10[i+1] <= sa10_next[i];
always @(posedge clk)	for(i=0; i<9; i=i+1) sa00[i+1] <= sa00_next[i];

////////////////////////////////////////////////////////////////////
//
// Final text output
//

always @(posedge clk) text_out[127:120] <=  sa00_sr[9] ^ w0[9][31:24];
always @(posedge clk) text_out[095:088] <=  sa01_sr[9] ^ w1[9][31:24];
always @(posedge clk) text_out[063:056] <=  sa02_sr[9] ^ w2[9][31:24];
always @(posedge clk) text_out[031:024] <=  sa03_sr[9] ^ w3[9][31:24];
always @(posedge clk) text_out[119:112] <=  sa10_sr[9] ^ w0[9][23:16];
always @(posedge clk) text_out[087:080] <=  sa11_sr[9] ^ w1[9][23:16];
always @(posedge clk) text_out[055:048] <=  sa12_sr[9] ^ w2[9][23:16];
always @(posedge clk) text_out[023:016] <=  sa13_sr[9] ^ w3[9][23:16];
always @(posedge clk) text_out[111:104] <=  sa20_sr[9] ^ w0[9][15:08];
always @(posedge clk) text_out[079:072] <=  sa21_sr[9] ^ w1[9][15:08];
always @(posedge clk) text_out[047:040] <=  sa22_sr[9] ^ w2[9][15:08];
always @(posedge clk) text_out[015:008] <=  sa23_sr[9] ^ w3[9][15:08];
always @(posedge clk) text_out[103:096] <=  sa30_sr[9] ^ w0[9][07:00];
always @(posedge clk) text_out[071:064] <=  sa31_sr[9] ^ w1[9][07:00];
always @(posedge clk) text_out[039:032] <=  sa32_sr[9] ^ w2[9][07:00];
always @(posedge clk) text_out[007:000] <=  sa33_sr[9] ^ w3[9][07:00];

/*always @(posedge clk) begin
$display("w0 %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x", w0[0], w0[1], w0[2], w0[3], w0[4], w0[5], w0[6], w0[7], w0[8], w0[9]);
$display("w1 %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x", w1[0], w1[1], w1[2], w1[3], w1[4], w1[5], w1[6], w1[7], w1[8], w1[9]);
$display("w2 %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x", w2[0], w2[1], w2[2], w2[3], w2[4], w2[5], w2[6], w2[7], w2[8], w2[9]);
$display("w3 %08x %08x %08x %08x %08x %08x %08x %08x %08x %08x", w3[0], w3[1], w3[2], w3[3], w3[4], w3[5], w3[6], w3[7], w3[8], w3[9]);
end*/
////////////////////////////////////////////////////////////////////
//
// Generic Functions
//

function [31:0] mix_col;
input	[7:0]	s0,s1,s2,s3;
reg	[7:0]	s0_o,s1_o,s2_o,s3_o;
begin
mix_col[31:24]=xtime(s0)^xtime(s1)^s1^s2^s3;
mix_col[23:16]=s0^xtime(s1)^xtime(s2)^s2^s3;
mix_col[15:08]=s0^s1^xtime(s2)^xtime(s3)^s3;
mix_col[07:00]=xtime(s0)^s0^s1^s2^xtime(s3);
end
endfunction

function [7:0] xtime;
input [7:0] b; xtime={b[6:0],1'b0}^(8'h1b&{8{b[7]}});
endfunction

////////////////////////////////////////////////////////////////////
//
// Modules
//

aes_pipelined_key_expand_128 u0(w0[0], w0[1], w0[2], w0[3], w0[4], w0[5], w0[6], w0[7], w0[8], w0[9],
                      w1[0], w1[1], w1[2], w1[3], w1[4], w1[5], w1[6], w1[7], w1[8], w1[9],
                      w2[0], w2[1], w2[2], w2[3], w2[4], w2[5], w2[6], w2[7], w2[8], w2[9],
                      w3[0], w3[1], w3[2], w3[3], w3[4], w3[5], w3[6], w3[7], w3[8], w3[9]);
genvar j;
generate
for (j=0; j<10; j=j+1) begin: mem_block_top
aes_pipelined_sbox us00(	.a(	sa00[j]	), .d(	sa00_sub[j]	));
aes_pipelined_sbox us01(	.a(	sa01[j]	), .d(	sa01_sub[j]	));
aes_pipelined_sbox us02(	.a(	sa02[j]	), .d(	sa02_sub[j]	));
aes_pipelined_sbox us03(	.a(	sa03[j]	), .d(	sa03_sub[j]	));
aes_pipelined_sbox us10(	.a(	sa10[j]	), .d(	sa10_sub[j]	));
aes_pipelined_sbox us11(	.a(	sa11[j]	), .d(	sa11_sub[j]	));
aes_pipelined_sbox us12(	.a(	sa12[j]	), .d(	sa12_sub[j]	));
aes_pipelined_sbox us13(	.a(	sa13[j]	), .d(	sa13_sub[j]	));
aes_pipelined_sbox us20(	.a(	sa20[j]	), .d(	sa20_sub[j]	));
aes_pipelined_sbox us21(	.a(	sa21[j]	), .d(	sa21_sub[j]	));
aes_pipelined_sbox us22(	.a(	sa22[j]	), .d(	sa22_sub[j]	));
aes_pipelined_sbox us23(	.a(	sa23[j]	), .d(	sa23_sub[j]	));
aes_pipelined_sbox us30(	.a(	sa30[j]	), .d(	sa30_sub[j]	));
aes_pipelined_sbox us31(	.a(	sa31[j]	), .d(	sa31_sub[j]	));
aes_pipelined_sbox us32(	.a(	sa32[j]	), .d(	sa32_sub[j]	));
aes_pipelined_sbox us33(	.a(	sa33[j]	), .d(	sa33_sub[j]	));
end
endgenerate

endmodule

