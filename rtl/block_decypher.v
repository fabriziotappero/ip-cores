`include "../bench/timescale.v"


// this module will do the block decrypter work 
module single_block_decyper(ri,kk,ro);
input [8*8-1:0*8] ri;
input [8-1:0]  kk;
output [8*8-1:0*8] ro;

wire [8-1:0]sbox_in;
wire [8-1:0]sbox_out;
wire [8-1:0]perm_out;
wire [8-1:0]next_r8;

assign sbox_in=kk ^ ri[7*8-1:6*8];
block_sbox s(.in(sbox_in),.out(sbox_out));
block_perm p(.in(sbox_out),.out(perm_out));
assign next_r8=ri[7*8-1:6*8];
assign ro[7*8-1:6*8]=ri[6*8-1:5*8]^perm_out;
assign ro[6*8-1:5*8]=ri[5*8-1:4*8];
assign ro[5*8-1:4*8]=ri[4*8-1:3*8]^ri[8*8-1:7*8]^sbox_out;
assign ro[4*8-1:3*8]=ri[3*8-1:2*8]^ri[8*8-1:7*8]^sbox_out;
assign ro[3*8-1:2*8]=ri[2*8-1:1*8]^ri[8*8-1:7*8]^sbox_out;
assign ro[2*8-1:1*8]=ri[1*8-1:0*8];
assign ro[1*8-1:0*8]=ri[8*8-1:7*8]^sbox_out;
assign ro[8*8-1:7*8]=next_r8;
endmodule

module block_decypher(kk,ib,bd);
input   [56 *8-1:0*8]kk;
input   [8  *8-1:0]ib;
output  [8  *8-1:0]bd;

wire    [56*8*8-1:0]r;
single_block_decyper b56(.ri(ib[8*8-1:0]),.kk(kk[56*8-1:55*8]),.ro(r[56*8*8-1:55*8*8]));
single_block_decyper b55(.ri(r[56*8*8-1:55*8*8]),.kk(kk[55*8-1:54*8]),.ro(r[55*8*8-1:54*8*8]));
single_block_decyper b54(.ri(r[55*8*8-1:54*8*8]),.kk(kk[54*8-1:53*8]),.ro(r[54*8*8-1:53*8*8]));
single_block_decyper b53(.ri(r[54*8*8-1:53*8*8]),.kk(kk[53*8-1:52*8]),.ro(r[53*8*8-1:52*8*8]));
single_block_decyper b52(.ri(r[53*8*8-1:52*8*8]),.kk(kk[52*8-1:51*8]),.ro(r[52*8*8-1:51*8*8]));
single_block_decyper b51(.ri(r[52*8*8-1:51*8*8]),.kk(kk[51*8-1:50*8]),.ro(r[51*8*8-1:50*8*8]));
single_block_decyper b50(.ri(r[51*8*8-1:50*8*8]),.kk(kk[50*8-1:49*8]),.ro(r[50*8*8-1:49*8*8]));
single_block_decyper b49(.ri(r[50*8*8-1:49*8*8]),.kk(kk[49*8-1:48*8]),.ro(r[49*8*8-1:48*8*8]));
single_block_decyper b48(.ri(r[49*8*8-1:48*8*8]),.kk(kk[48*8-1:47*8]),.ro(r[48*8*8-1:47*8*8]));
single_block_decyper b47(.ri(r[48*8*8-1:47*8*8]),.kk(kk[47*8-1:46*8]),.ro(r[47*8*8-1:46*8*8]));
single_block_decyper b46(.ri(r[47*8*8-1:46*8*8]),.kk(kk[46*8-1:45*8]),.ro(r[46*8*8-1:45*8*8]));
single_block_decyper b45(.ri(r[46*8*8-1:45*8*8]),.kk(kk[45*8-1:44*8]),.ro(r[45*8*8-1:44*8*8]));
single_block_decyper b44(.ri(r[45*8*8-1:44*8*8]),.kk(kk[44*8-1:43*8]),.ro(r[44*8*8-1:43*8*8]));
single_block_decyper b43(.ri(r[44*8*8-1:43*8*8]),.kk(kk[43*8-1:42*8]),.ro(r[43*8*8-1:42*8*8]));
single_block_decyper b42(.ri(r[43*8*8-1:42*8*8]),.kk(kk[42*8-1:41*8]),.ro(r[42*8*8-1:41*8*8]));
single_block_decyper b41(.ri(r[42*8*8-1:41*8*8]),.kk(kk[41*8-1:40*8]),.ro(r[41*8*8-1:40*8*8]));
single_block_decyper b40(.ri(r[41*8*8-1:40*8*8]),.kk(kk[40*8-1:39*8]),.ro(r[40*8*8-1:39*8*8]));
single_block_decyper b39(.ri(r[40*8*8-1:39*8*8]),.kk(kk[39*8-1:38*8]),.ro(r[39*8*8-1:38*8*8]));
single_block_decyper b38(.ri(r[39*8*8-1:38*8*8]),.kk(kk[38*8-1:37*8]),.ro(r[38*8*8-1:37*8*8]));
single_block_decyper b37(.ri(r[38*8*8-1:37*8*8]),.kk(kk[37*8-1:36*8]),.ro(r[37*8*8-1:36*8*8]));
single_block_decyper b36(.ri(r[37*8*8-1:36*8*8]),.kk(kk[36*8-1:35*8]),.ro(r[36*8*8-1:35*8*8]));
single_block_decyper b35(.ri(r[36*8*8-1:35*8*8]),.kk(kk[35*8-1:34*8]),.ro(r[35*8*8-1:34*8*8]));
single_block_decyper b34(.ri(r[35*8*8-1:34*8*8]),.kk(kk[34*8-1:33*8]),.ro(r[34*8*8-1:33*8*8]));
single_block_decyper b33(.ri(r[34*8*8-1:33*8*8]),.kk(kk[33*8-1:32*8]),.ro(r[33*8*8-1:32*8*8]));
single_block_decyper b32(.ri(r[33*8*8-1:32*8*8]),.kk(kk[32*8-1:31*8]),.ro(r[32*8*8-1:31*8*8]));
single_block_decyper b31(.ri(r[32*8*8-1:31*8*8]),.kk(kk[31*8-1:30*8]),.ro(r[31*8*8-1:30*8*8]));
single_block_decyper b30(.ri(r[31*8*8-1:30*8*8]),.kk(kk[30*8-1:29*8]),.ro(r[30*8*8-1:29*8*8]));
single_block_decyper b29(.ri(r[30*8*8-1:29*8*8]),.kk(kk[29*8-1:28*8]),.ro(r[29*8*8-1:28*8*8]));
single_block_decyper b28(.ri(r[29*8*8-1:28*8*8]),.kk(kk[28*8-1:27*8]),.ro(r[28*8*8-1:27*8*8]));
single_block_decyper b27(.ri(r[28*8*8-1:27*8*8]),.kk(kk[27*8-1:26*8]),.ro(r[27*8*8-1:26*8*8]));
single_block_decyper b26(.ri(r[27*8*8-1:26*8*8]),.kk(kk[26*8-1:25*8]),.ro(r[26*8*8-1:25*8*8]));
single_block_decyper b25(.ri(r[26*8*8-1:25*8*8]),.kk(kk[25*8-1:24*8]),.ro(r[25*8*8-1:24*8*8]));
single_block_decyper b24(.ri(r[25*8*8-1:24*8*8]),.kk(kk[24*8-1:23*8]),.ro(r[24*8*8-1:23*8*8]));
single_block_decyper b23(.ri(r[24*8*8-1:23*8*8]),.kk(kk[23*8-1:22*8]),.ro(r[23*8*8-1:22*8*8]));
single_block_decyper b22(.ri(r[23*8*8-1:22*8*8]),.kk(kk[22*8-1:21*8]),.ro(r[22*8*8-1:21*8*8]));
single_block_decyper b21(.ri(r[22*8*8-1:21*8*8]),.kk(kk[21*8-1:20*8]),.ro(r[21*8*8-1:20*8*8]));
single_block_decyper b20(.ri(r[21*8*8-1:20*8*8]),.kk(kk[20*8-1:19*8]),.ro(r[20*8*8-1:19*8*8]));
single_block_decyper b19(.ri(r[20*8*8-1:19*8*8]),.kk(kk[19*8-1:18*8]),.ro(r[19*8*8-1:18*8*8]));
single_block_decyper b18(.ri(r[19*8*8-1:18*8*8]),.kk(kk[18*8-1:17*8]),.ro(r[18*8*8-1:17*8*8]));
single_block_decyper b17(.ri(r[18*8*8-1:17*8*8]),.kk(kk[17*8-1:16*8]),.ro(r[17*8*8-1:16*8*8]));
single_block_decyper b16(.ri(r[17*8*8-1:16*8*8]),.kk(kk[16*8-1:15*8]),.ro(r[16*8*8-1:15*8*8]));
single_block_decyper b15(.ri(r[16*8*8-1:15*8*8]),.kk(kk[15*8-1:14*8]),.ro(r[15*8*8-1:14*8*8]));
single_block_decyper b14(.ri(r[15*8*8-1:14*8*8]),.kk(kk[14*8-1:13*8]),.ro(r[14*8*8-1:13*8*8]));
single_block_decyper b13(.ri(r[14*8*8-1:13*8*8]),.kk(kk[13*8-1:12*8]),.ro(r[13*8*8-1:12*8*8]));
single_block_decyper b12(.ri(r[13*8*8-1:12*8*8]),.kk(kk[12*8-1:11*8]),.ro(r[12*8*8-1:11*8*8]));
single_block_decyper b11(.ri(r[12*8*8-1:11*8*8]),.kk(kk[11*8-1:10*8]),.ro(r[11*8*8-1:10*8*8]));
single_block_decyper b10(.ri(r[11*8*8-1:10*8*8]),.kk(kk[10*8-1: 9*8]),.ro(r[10*8*8-1: 9*8*8]));
single_block_decyper b9 (.ri(r[10*8*8-1: 9*8*8]),.kk(kk[ 9*8-1: 8*8]),.ro(r[ 9*8*8-1: 8*8*8]));
single_block_decyper b8 (.ri(r[ 9*8*8-1: 8*8*8]),.kk(kk[ 8*8-1: 7*8]),.ro(r[ 8*8*8-1: 7*8*8]));
single_block_decyper b7 (.ri(r[ 8*8*8-1: 7*8*8]),.kk(kk[ 7*8-1: 6*8]),.ro(r[ 7*8*8-1: 6*8*8]));
single_block_decyper b6 (.ri(r[ 7*8*8-1: 6*8*8]),.kk(kk[ 6*8-1: 5*8]),.ro(r[ 6*8*8-1: 5*8*8]));
single_block_decyper b5 (.ri(r[ 6*8*8-1: 5*8*8]),.kk(kk[ 5*8-1: 4*8]),.ro(r[ 5*8*8-1: 4*8*8]));
single_block_decyper b4 (.ri(r[ 5*8*8-1: 4*8*8]),.kk(kk[ 4*8-1: 3*8]),.ro(r[ 4*8*8-1: 3*8*8]));
single_block_decyper b3 (.ri(r[ 4*8*8-1: 3*8*8]),.kk(kk[ 3*8-1: 2*8]),.ro(r[ 3*8*8-1: 2*8*8]));
single_block_decyper b2 (.ri(r[ 3*8*8-1: 2*8*8]),.kk(kk[ 2*8-1: 1*8]),.ro(r[ 2*8*8-1: 1*8*8]));
single_block_decyper b1 (.ri(r[ 2*8*8-1: 1*8*8]),.kk(kk[ 1*8-1: 0*8]),.ro(r[ 1*8*8-1: 0*8*8]));

assign bd=r[ 1*8*8-1: 0*8*8];
endmodule
