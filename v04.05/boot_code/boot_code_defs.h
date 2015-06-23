localparam MEM_DATA_W = 16;
localparam IM_W = 6;
// defines that make programming code more human readable
`define __			4'h0
`define _0			4'h0
`define _1			4'h1
`define _2			4'h2
`define _3			4'h3
`define _4			4'h4
`define _5			4'h5
`define _6			4'h6
`define _7			4'h7
`define P0			4'h8
`define P1			4'h9
`define P2			4'ha
`define P3			4'hb
`define P4			4'hc
`define P5			4'hd
`define P6			4'he
`define P7			4'hf
//
`define nop			op_nop[MEM_DATA_W-1:8]
`define pop			op_pop[MEM_DATA_W-1:8]
`define pgc			op_pgc[MEM_DATA_W-1:8]
`define lit_s		op_lit_s[MEM_DATA_W-1:8]
`define lit_h		op_lit_h[MEM_DATA_W-1:8]
`define lit_u		op_lit_u[MEM_DATA_W-1:8]
`define reg_rs		op_reg_rs[MEM_DATA_W-1:8]
`define reg_rh		op_reg_rh[MEM_DATA_W-1:8]
`define reg_w		op_reg_w[MEM_DATA_W-1:8]
`define reg_wh		op_reg_wh[MEM_DATA_W-1:8]
//
`define cpy			op_cpy[MEM_DATA_W-1:8]
`define nsg			op_nsg[MEM_DATA_W-1:8]
`define not			op_not[MEM_DATA_W-1:8]
`define flp			op_flp[MEM_DATA_W-1:8]
`define lzc			op_lzc[MEM_DATA_W-1:8]
`define bra			op_bra[MEM_DATA_W-1:8]
`define bro			op_bro[MEM_DATA_W-1:8]
`define brx			op_brx[MEM_DATA_W-1:8]
`define and			op_and[MEM_DATA_W-1:8]
`define orr			op_orr[MEM_DATA_W-1:8]
`define xor			op_xor[MEM_DATA_W-1:8]
//
`define add			op_add[MEM_DATA_W-1:8]
`define add_xs		op_add_xs[MEM_DATA_W-1:8]
`define add_xu		op_add_xu[MEM_DATA_W-1:8]
`define sub			op_sub[MEM_DATA_W-1:8]
`define sub_xs		op_sub_xs[MEM_DATA_W-1:8]
`define sub_xu		op_sub_xu[MEM_DATA_W-1:8]
`define mul			op_mul[MEM_DATA_W-1:8]
`define mul_xs		op_mul_xs[MEM_DATA_W-1:8]
`define mul_xu		op_mul_xu[MEM_DATA_W-1:8]
`define shl_s		op_shl_s[MEM_DATA_W-1:8]
`define shl_u		op_shl_u[MEM_DATA_W-1:8]
`define pow			op_pow[MEM_DATA_W-1:8]
//
`define jmp_z		op_jmp_z[MEM_DATA_W-1:8]
`define jmp_nz		op_jmp_nz[MEM_DATA_W-1:8]
`define jmp_lz		op_jmp_lz[MEM_DATA_W-1:8]
`define jmp_nlz	op_jmp_nlz[MEM_DATA_W-1:8]
`define jmp			op_jmp[MEM_DATA_W-1:8]
`define gto			op_gto[MEM_DATA_W-1:8]
`define gsb			op_gsb[MEM_DATA_W-1:8]
//
`define mem_irs	op_mem_irs[MEM_DATA_W-1:12]
`define mem_irh	op_mem_irh[MEM_DATA_W-1:12]
`define mem_iw		op_mem_iw[MEM_DATA_W-1:12]
`define mem_iwh	op_mem_iwh[MEM_DATA_W-1:12]
//
`define jmp_ie		op_jmp_ie[MEM_DATA_W-1:12]
`define jmp_ine	op_jmp_ine[MEM_DATA_W-1:12]
`define jmp_ils	op_jmp_ils[MEM_DATA_W-1:12]
`define jmp_inls	op_jmp_inls[MEM_DATA_W-1:12]
`define jmp_ilu	op_jmp_ilu[MEM_DATA_W-1:12]
`define jmp_inlu	op_jmp_inlu[MEM_DATA_W-1:12]
//
`define jmp_iz		op_jmp_iz[MEM_DATA_W-1:10]
`define jmp_inz	op_jmp_inz[MEM_DATA_W-1:10]
`define jmp_ilz	op_jmp_ilz[MEM_DATA_W-1:10]
`define jmp_inlz	op_jmp_inlz[MEM_DATA_W-1:10]
//
`define dat_is		op_dat_is[MEM_DATA_W-1:10]
`define add_is		op_add_is[MEM_DATA_W-1:10]
`define shl_is		op_shl_is[MEM_DATA_W-1:10]
`define psu_i		op_psu_i[MEM_DATA_W-1:10]
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
