`include "reg_set_addr.h"
`include "op_encode.h"

localparam IM_W = 6;

// defines that make programming code more human readable
`define __			4'h0
`define s0			4'h0
`define s1			4'h1
`define s2			4'h2
`define s3			4'h3
`define s4			4'h4
`define s5			4'h5
`define s6			4'h6
`define s7			4'h7
`define P0			4'h8
`define P1			4'h9
`define P2			4'ha
`define P3			4'hb
`define P4			4'hc
`define P5			4'hd
`define P6			4'he
`define P7			4'hf
//
`define nop			op_nop[DATA_W-1:8]
`define pop			op_pop[DATA_W-1:8]
`define pgc			op_pgc[DATA_W-1:8]
`define lit_s		op_lit_s[DATA_W-1:8]
`define lit_h		op_lit_h[DATA_W-1:8]
`define lit_u		op_lit_u[DATA_W-1:8]
`define reg_rs		op_reg_rs[DATA_W-1:8]
`define reg_rh		op_reg_rh[DATA_W-1:8]
`define reg_w		op_reg_w[DATA_W-1:8]
`define reg_wh		op_reg_wh[DATA_W-1:8]
//
`define cpy			op_cpy[DATA_W-1:8]
`define nsg			op_nsg[DATA_W-1:8]
`define not			op_not[DATA_W-1:8]
`define flp			op_flp[DATA_W-1:8]
`define lzc			op_lzc[DATA_W-1:8]
`define bra			op_bra[DATA_W-1:8]
`define bro			op_bro[DATA_W-1:8]
`define brx			op_brx[DATA_W-1:8]
`define and			op_and[DATA_W-1:8]
`define orr			op_orr[DATA_W-1:8]
`define xor			op_xor[DATA_W-1:8]
//
`define add			op_add[DATA_W-1:8]
`define add_xs		op_add_xs[DATA_W-1:8]
`define add_xu		op_add_xu[DATA_W-1:8]
`define sub			op_sub[DATA_W-1:8]
`define sub_xs		op_sub_xs[DATA_W-1:8]
`define sub_xu		op_sub_xu[DATA_W-1:8]
`define mul			op_mul[DATA_W-1:8]
`define mul_xs		op_mul_xs[DATA_W-1:8]
`define mul_xu		op_mul_xu[DATA_W-1:8]
`define shl_s		op_shl_s[DATA_W-1:8]
`define shl_u		op_shl_u[DATA_W-1:8]
`define pow			op_pow[DATA_W-1:8]
//
`define jmp_z		op_jmp_z[DATA_W-1:8]
`define jmp_nz		op_jmp_nz[DATA_W-1:8]
`define jmp_lz		op_jmp_lz[DATA_W-1:8]
`define jmp_nlz	op_jmp_nlz[DATA_W-1:8]
`define jmp			op_jmp[DATA_W-1:8]
`define gto			op_gto[DATA_W-1:8]
`define gsb			op_gsb[DATA_W-1:8]
//
`define mem_irs	op_mem_irs[DATA_W-1:12]
`define mem_irh	op_mem_irh[DATA_W-1:12]
`define mem_iw		op_mem_iw[DATA_W-1:12]
`define mem_iwh	op_mem_iwh[DATA_W-1:12]
//
`define jmp_ie		op_jmp_ie[DATA_W-1:12]
`define jmp_ine	op_jmp_ine[DATA_W-1:12]
`define jmp_ils	op_jmp_ils[DATA_W-1:12]
`define jmp_inls	op_jmp_inls[DATA_W-1:12]
`define jmp_ilu	op_jmp_ilu[DATA_W-1:12]
`define jmp_inlu	op_jmp_inlu[DATA_W-1:12]
//
`define jmp_iz		op_jmp_iz[DATA_W-1:10]
`define jmp_inz	op_jmp_inz[DATA_W-1:10]
`define jmp_ilz	op_jmp_ilz[DATA_W-1:10]
`define jmp_inlz	op_jmp_inlz[DATA_W-1:10]
//
`define dat_is		op_dat_is[DATA_W-1:10]
`define add_is		op_add_is[DATA_W-1:10]
`define shl_is		op_shl_is[DATA_W-1:10]
`define psu_i		op_psu_i[DATA_W-1:10]
//
`define VER			VER_ADDR[IM_W-1:0]
`define THRD_ID	THRD_ID_ADDR[IM_W-1:0]
`define CLR			CLR_ADDR[IM_W-1:0]
`define INTR_EN	INTR_EN_ADDR[IM_W-1:0]
`define OP_ER		OP_ER_ADDR[IM_W-1:0]
`define STK_ER		STK_ER_ADDR[IM_W-1:0]
`define IO_LO		IO_LO_ADDR[IM_W-1:0]
`define IO_HI		IO_HI_ADDR[IM_W-1:0]
`define UART_RX	UART_RX_ADDR[IM_W-1:0]
`define UART_TX	UART_TX_ADDR[IM_W-1:0]
