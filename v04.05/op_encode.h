`include "lg_sel_encode.h"
`include "tst_encode.h"

// `ifndef _op_encode_h_
// `define _op_encode_h_

// misc - 16 x 16 x 16 = 4096 codes
localparam	[MEM_DATA_W-1:0]	op_nop		= { 4'h0, 4'h0, 4'hx, 4'hx };	// do nothing (no pops either)
localparam	[MEM_DATA_W-1:0]	op_pop		= { 4'h0, 4'h1, 4'hx, 4'hx };	// pop [7:0] none/one/some/all stacks
localparam	[MEM_DATA_W-1:0]	op_pgc		= { 4'h0, 4'h4, 4'hx, 4'hx };	// A=PC  read PC (unsigned)
localparam	[MEM_DATA_W-1:0]	op_lit_s		= { 4'h0, 4'h8, 4'hx, 4'hx };	// A=mem(PC)  literal data signed
localparam	[MEM_DATA_W-1:0]	op_lit_h		= { 4'h0, 4'h9, 4'hx, 4'hx };	// A={mem(PC),A[lo]}  literal data high
localparam	[MEM_DATA_W-1:0]	op_lit_u		= { 4'h0, 4'ha, 4'hx, 4'hx };	// A=mem(PC)  literal data unsigned
localparam	[MEM_DATA_W-1:0]	op_reg_rs	= { 4'h0, 4'hc, 4'hx, 4'hx };	// A=reg(B)  register read signed
localparam	[MEM_DATA_W-1:0]	op_reg_rh	= { 4'h0, 4'hd, 4'hx, 4'hx };	// A={reg(B),A[lo]}  register read high
localparam	[MEM_DATA_W-1:0]	op_reg_w		= { 4'h0, 4'he, 4'hx, 4'hx };	// reg(B)=A[lo]  register write
localparam	[MEM_DATA_W-1:0]	op_reg_wh	= { 4'h0, 4'hf, 4'hx, 4'hx };	// reg(B)=A[hi]  register write high
// logical & other - 16 x 16 x 16 = 4096 codes
localparam	[MEM_DATA_W-1:0]	op_cpy		= { 4'h1, `lg_cpy, 4'hx, 4'hx };	// A=B  copy
localparam	[MEM_DATA_W-1:0]	op_nsg		= { 4'h1, `lg_nsg, 4'hx, 4'hx };	// A[MSB]=~B[MSB]  invert sign
localparam	[MEM_DATA_W-1:0]	op_not		= { 4'h1, `lg_not, 4'hx, 4'hx };	// A=~B  logical NOT
localparam	[MEM_DATA_W-1:0]	op_flp		= { 4'h1, `lg_flp, 4'hx, 4'hx };	// A=flip(B)  flip bits end for end
localparam	[MEM_DATA_W-1:0]	op_lzc		= { 4'h1, `lg_lzc, 4'hx, 4'hx };	// A=lzc(B)  leading zero count
localparam	[MEM_DATA_W-1:0]	op_bra		= { 4'h1, `lg_bra, 4'hx, 4'hx };	// A=&B  logical AND bit reduction
localparam	[MEM_DATA_W-1:0]	op_bro		= { 4'h1, `lg_bro, 4'hx, 4'hx };	// A=|B  logical OR bit reduction
localparam	[MEM_DATA_W-1:0]	op_brx		= { 4'h1, `lg_brx, 4'hx, 4'hx };	// A=^B  logical XOR bit reduction
localparam	[MEM_DATA_W-1:0]	op_and		= { 4'h1, `lg_and, 4'hx, 4'hx };	// A=A&B  logical AND
localparam	[MEM_DATA_W-1:0]	op_orr		= { 4'h1, `lg_orr, 4'hx, 4'hx };	// A=A|B  logical OR
localparam	[MEM_DATA_W-1:0]	op_xor		= { 4'h1, `lg_xor, 4'hx, 4'hx };	// A=A^B  logical XOR
// arithmetic - 16 x 16 x 16 = 4096 codes
localparam	[MEM_DATA_W-1:0]	op_add		= { 4'h2, 4'h0, 4'hx, 4'hx };	// A=A+B  add
localparam	[MEM_DATA_W-1:0]	op_add_xs	= { 4'h2, 4'h2, 4'hx, 4'hx };	// A=A+B  add extended signed
localparam	[MEM_DATA_W-1:0]	op_add_xu	= { 4'h2, 4'h3, 4'hx, 4'hx };	// A=A+B  add extended unsigned
localparam	[MEM_DATA_W-1:0]	op_sub		= { 4'h2, 4'h4, 4'hx, 4'hx };	// A=A-B  subtract
localparam	[MEM_DATA_W-1:0]	op_sub_xs	= { 4'h2, 4'h6, 4'hx, 4'hx };	// A=A-B  subtract extended signed
localparam	[MEM_DATA_W-1:0]	op_sub_xu	= { 4'h2, 4'h7, 4'hx, 4'hx };	// A=A-B  subtract extended unsigned
localparam	[MEM_DATA_W-1:0]	op_mul		= { 4'h2, 4'h8, 4'hx, 4'hx };	// A=A*B  multiply
localparam	[MEM_DATA_W-1:0]	op_mul_xs	= { 4'h2, 4'ha, 4'hx, 4'hx };	// A=A*B  multiply extended signed
localparam	[MEM_DATA_W-1:0]	op_mul_xu	= { 4'h2, 4'hb, 4'hx, 4'hx };	// A=A*B  multiply extended unsigned
localparam	[MEM_DATA_W-1:0]	op_shl_s		= { 4'h2, 4'hc, 4'hx, 4'hx };	// A=A<<<B  shift left A signed
localparam	[MEM_DATA_W-1:0]	op_shl_u		= { 4'h2, 4'hd, 4'hx, 4'hx };	// A=A<<B  shift left A unsigned
localparam	[MEM_DATA_W-1:0]	op_pow		= { 4'h2, 4'he, 4'hx, 4'hx };	// A=1<<B  power of 2
// branching - 16 x 16 x 16 = 4096 codes
localparam	[MEM_DATA_W-1:0]	op_jmp_z		= { 4'h3, 2'b00, `z,   4'hx, 4'hx };	// PC=(A?0)?PC+B  jump zero conditional
localparam	[MEM_DATA_W-1:0]	op_jmp_nz	= { 4'h3, 2'b00, `nz,  4'hx, 4'hx };
localparam	[MEM_DATA_W-1:0]	op_jmp_lz	= { 4'h3, 2'b00, `lz,  4'hx, 4'hx };
localparam	[MEM_DATA_W-1:0]	op_jmp_nlz	= { 4'h3, 2'b00, `nlz, 4'hx, 4'hx };
localparam	[MEM_DATA_W-1:0]	op_jmp		= { 4'h3, 4'hc, 4'hx, 4'hx };	// PC=PC+B  jump unconditional
localparam	[MEM_DATA_W-1:0]	op_gto		= { 4'h3, 4'hd, 4'hx, 4'hx };	// PC=B  go to unconditional
localparam	[MEM_DATA_W-1:0]	op_gsb		= { 4'h3, 4'he, 4'hx, 4'hx };	// PC=B,A=PC  subroutine call unconditional
// immediate memory access - 4 x 16 x 16 x 16 = 16384 codes
localparam	[MEM_DATA_W-1:0]	op_mem_irs	= { 4'h4, 4'hx, 4'hx, 4'hx };	// A=mem(B+I)  memory read signed
localparam	[MEM_DATA_W-1:0]	op_mem_irh	= { 4'h5, 4'hx, 4'hx, 4'hx };	// A={mem(B+I),A[lo]}  memory read high
localparam	[MEM_DATA_W-1:0]	op_mem_iw	= { 4'h6, 4'hx, 4'hx, 4'hx };	// mem(B+I)=A[lo]  memory write
localparam	[MEM_DATA_W-1:0]	op_mem_iwh	= { 4'h7, 4'hx, 4'hx, 4'hx };	// mem(B+I)=A[hi]  memory write high
// immediate conditional (A?B) jumps - 6 x 16 x 16 x 16 = 24576 codes
localparam	[MEM_DATA_W-1:0]	op_jmp_ie	= { `e,   4'hx, 4'hx, 4'hx };	// PC=(A?B)?PC+I  jump immediate conditional
localparam	[MEM_DATA_W-1:0]	op_jmp_ine	= { `ne,  4'hx, 4'hx, 4'hx };
localparam	[MEM_DATA_W-1:0]	op_jmp_ils	= { `ls,  4'hx, 4'hx, 4'hx };
localparam	[MEM_DATA_W-1:0]	op_jmp_inls	= { `nls, 4'hx, 4'hx, 4'hx };
localparam	[MEM_DATA_W-1:0]	op_jmp_ilu	= { `lu,  4'hx, 4'hx, 4'hx };
localparam	[MEM_DATA_W-1:0]	op_jmp_inlu	= { `nlu, 4'hx, 4'hx, 4'hx };
// immediate conditional (A?0) jumps - 4 x 64 x 16 = 4096 codes
localparam	[MEM_DATA_W-1:0]	op_jmp_iz	= { 4'he, `z,   6'bxxxxxx, 4'hx };	// PC=(A?0)?PC+I  jump immediate conditional
localparam	[MEM_DATA_W-1:0]	op_jmp_inz	= { 4'he, `nz,  6'bxxxxxx, 4'hx };
localparam	[MEM_DATA_W-1:0]	op_jmp_ilz	= { 4'he, `lz,  6'bxxxxxx, 4'hx };
localparam	[MEM_DATA_W-1:0]	op_jmp_inlz	= { 4'he, `nlz, 6'bxxxxxx, 4'hx };
// immediate data - 1 x 64 x 16 = 1024 codes
localparam	[MEM_DATA_W-1:0]	op_dat_is	= { 4'hf, 2'b00, 6'bxxxxxx, 4'hx };	// A=I  data immediate signed
// immediate add - 1 x 64 x 16 = 1024 codes
localparam	[MEM_DATA_W-1:0]	op_add_is	= { 4'hf, 2'b01, 6'bxxxxxx, 4'hx };	// A=A+I  add immediate signed
// immediate shifts - 2 x 64 x 16 = 2048 codes
localparam	[MEM_DATA_W-1:0]	op_shl_is	= { 4'hf, 2'b10, 6'bxxxxxx, 4'hx };	// A=A<<<I  shift left A signed
localparam	[MEM_DATA_W-1:0]	op_psu_i		= { 4'hf, 2'b11, 6'bxxxxxx, 4'hx };	// A=1<<I  power of 2; A=A<<I  shift A unsigned

// `endif  // _op_encode_h_

