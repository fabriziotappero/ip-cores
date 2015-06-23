// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: tlu_tdp.v
// Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
// DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
// 
// The above named program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
// 
// The above named program is distributed in the hope that it will be 
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.
// 
// You should have received a copy of the GNU General Public
// License along with this work; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
// 
// ========== Copyright Header End ============================================
///////////////////////////////////////////////////////////////////////
/*
//	Description:	Trap Datapath 
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
// system level definition file which contains the /*
/* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: sys.h
* Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
* DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
* 
* The above named program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License version 2 as published by the Free Software Foundation.
* 
* The above named program is distributed in the hope that it will be 
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
* 
* You should have received a copy of the GNU General Public
* License along with this work; if not, write to the Free Software
* Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
* 
* ========== Copyright Header End ============================================
*/
// -*- verilog -*-
////////////////////////////////////////////////////////////////////////
/*
//
// Description:		Global header file that contain definitions that 
//                      are common/shared at the systme level
*/
////////////////////////////////////////////////////////////////////////
//
// Setting the time scale
// If the timescale changes, JP_TIMESCALE may also have to change.
`timescale	1ps/1ps

//
// JBUS clock
// =========
//



// Afara Link Defines
// ==================

// Reliable Link




// Afara Link Objects


// Afara Link Object Format - Reliable Link










// Afara Link Object Format - Congestion



  







// Afara Link Object Format - Acknowledge











// Afara Link Object Format - Request

















// Afara Link Object Format - Message



// Acknowledge Types




// Request Types





// Afara Link Frame



//
// UCB Packet Type
// ===============
//

















//
// UCB Data Packet Format
// ======================
//






























// Size encoding for the UCB_SIZE_HI/LO field
// 000 - byte
// 001 - half-word
// 010 - word
// 011 - double-word
// 111 - quad-word







//
// UCB Interrupt Packet Format
// ===========================
//










//`define UCB_THR_HI             9      // (6) cpu/thread ID shared with
//`define UCB_THR_LO             4             data packet format
//`define UCB_PKT_HI             3      // (4) packet type shared with
//`define UCB_PKT_LO             0      //     data packet format







//
// FCRAM Bus Widths
// ================
//






//
// ENET clock periods
// ==================
//




//
// JBus Bridge defines
// =================
//











//
// PCI Device Address Configuration
// ================================
//























			     // time scale definition

////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////
/*
/* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: tlu.h
* Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
* DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
* 
* The above named program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License version 2 as published by the Free Software Foundation.
* 
* The above named program is distributed in the hope that it will be 
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
* 
* You should have received a copy of the GNU General Public
* License along with this work; if not, write to the Free Software
* Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
* 
* ========== Copyright Header End ============================================
*/
// ifu trap types
















//
// modified for hypervisor support
//
























//


// modified due to bug 2588
// `define	TSA_PSTATE_VRANGE2_LO 16 


//











//
// added due to Niagara SRAMs methodology
// The following defines have been replaced due
// the memory macro replacement from:
// bw_r_rf32x144 -> 2x bw_r_rf32x80
/*
`define	TSA_MEM_WIDTH     144 
`define	TSA_HTSTATE_HI    142 //  3 bits 
`define	TSA_HTSTATE_LO    140 
`define	TSA_TPC_HI        138 // 47 bits 
`define	TSA_TPC_LO         92
`define	TSA_TNPC_HI        90 // 47 bits
`define	TSA_TNPC_LO        44 
`define	TSA_TSTATE_HI      40 // 29 bits 
`define	TSA_TSTATE_LO      12 
`define	TSA_TTYPE_HI        8 //  9 bits
`define	TSA_TTYPE_LO        0
`define	TSA_MEM_CWP_LO	   12
`define	TSA_MEM_CWP_HI	   14
`define	TSA_MEM_PSTATE_LO  15
`define	TSA_MEM_PSTATE_HI  22
`define	TSA_MEM_ASI_LO	   23
`define	TSA_MEM_ASI_HI	   30
`define	TSA_MEM_CCR_LO	   31
`define	TSA_MEM_CCR_HI	   38
`define	TSA_MEM_GL_LO	   39 
`define	TSA_MEM_GL_HI	   40 
*/











//











// HPSTATE position definitions within wsr






// TSTATE postition definitions within wsr







// modified due to bug 2588


// added for bug 2584 




//







//
// tick_cmp and stick_cmp definitions





//
// PIB WRAP



// HPSTATE postition definitions






// HTBA definitions




// TBA definitions




















//
// added for the hypervisor support


// modified due to bug 2588
















//
// compressed PSTATE WSR definitions














//
// ASI_QUEUE for hypervisor
// Queues are: CPU_MONODO
//             DEV_MONODO
//             RESUMABLE_ERROR
//             NON_RESUMABLE_ERROR
//







// for address range checking
















//
// Niagara scratch-pads
// VA address of 0x20 and 0x28 are exclusive to hypervisor
// 







//
// range checking 







// PIB related definitions
// Bit definition for events









// 
// PIB related definitions
// PCR and PIC address definitions



// 
// PCR bit definitions







//









// PIC definitions








// PIC  mask bit position definitions










// added define from sparc_tlu_int.v 










//
// shadow scan related definitions 

// modified due to logic redistribution
// `define TCL_SSCAN_WIDTH 12 





// `define TCL_SSCAN_LO 51 




// 
// position definitions - TDP






// 
// position definitions - TCL




// 
// To speedup POR for verification purposes


//FPGA_SYN enables all FPGA related modifications
 




module tlu_tdp (/*AUTOARG*/
   // Outputs
   tlu_pib_rsr_data_e, tlu_restore_pc_w1, tlu_restore_npc_w1, tlu_partial_trap_pc_w1,
   tsa_wdata, tlu_int_pstate_ie, local_pstate_ie, tlu_ifu_pstate_pef, 
   tlu_lsu_pstate_cle, tlu_lsu_pstate_priv, tlu_int_redmode, tlu_lsu_redmode, 
   tlu_sscan_test_data, 
   // modified for bug 1767
   tlu_pstate_am, tlu_sftint_id, 
   // added for timing
   // modfied for hypervisor support
   tlu_dnrtry_global_g, tlu_tick_incr_din, tlu_exu_rsr_data_m, 
   tlu_hpstate_priv, local_hpstate_priv, local_hpstate_enb, local_pstate_priv, 
   tlu_hpstate_enb, tlu_hintp, tlu_por_rstint_g, tcl_hpstate_priv, tcl_hpstate_enb, 
   tlu_trap_hpstate_enb, tlu_hpstate_tlz, tlu_asi_state_e, tlu_hpstate_ibe, 
   so, 
   // Inputs
   tsa_rdata, tlu_wsr_data_w, lsu_tlu_rsr_data_e, tlu_ibrkpt_trap_w2, 
   // reset was modified to abide to the Niagara reset methodology
   rclk, tlu_rst, tlu_thrd_wsel_w2, ifu_lsu_imm_asi_d, // tm_l, 
   tlu_final_ttype_w2, tlu_pstate_din_sel0, tlu_pstate_din_sel1, 
   tlu_pstate_din_sel2, tlu_pstate_din_sel3, ifu_lsu_imm_asi_vld_d,  
   lsu_asi_reg0, lsu_asi_reg1, lsu_asi_reg2, lsu_asi_reg3, 
   exu_tlu_ccr0_w, exu_tlu_ccr1_w, exu_tlu_ccr2_w, exu_tlu_ccr3_w, 
   exu_tlu_cwp0, exu_tlu_cwp1, exu_tlu_cwp2, exu_tlu_cwp3, tlu_trap_cwp_en, 
   tlu_pc_new_w, tlu_npc_new_w, tlu_sftint_en_l_g, tlu_sftint_mx_sel, 
   tlu_set_sftint_l_g, tlu_wr_tsa_inst_w2,  tlu_clr_sftint_l_g, 
   tlu_wr_sftint_l_g, tlu_sftint_penc_sel, tlu_tba_en_l, tlu_tick_en_l, 
   tlu_tickcmp_sel, tlu_tickcmp_en_l, // tlu_retry_inst_m, tlu_done_inst_m, 
   tlu_update_pc_l_w, tlu_tl_gt_0_w2, pib_pich_wrap, // tlu_dnrtry_inst_m_l, 
   tlu_select_tba_w2, tlu_select_redmode, tlu_update_pstate_l_w2, tlu_pil, 
   tlu_trp_lvl, tlu_tick_npt, tlu_thrd_rsel_e, tlu_tick_incr_dout, 
   tlu_rdpr_mx1_sel, tlu_rdpr_mx2_sel, tlu_rdpr_mx3_sel, tlu_rdpr_mx4_sel, 
   tlu_hpstate_din_sel0, tlu_hpstate_din_sel1, tlu_pc_mxsel_w2,  
   tlu_hpstate_din_sel2, tlu_hpstate_din_sel3, tlu_update_hpstate_l_w2, 
   tlu_htba_en_l, tlu_rdpr_mx5_sel, tlu_rdpr_mx6_sel, pib_picl_wrap, 
   tlu_rdpr_mx7_sel, tlu_htickcmp_intdis, tlu_stickcmp_en_l, tlu_htickcmp_en_l, 
   tlu_gl_lvl0, tlu_gl_lvl1, tlu_gl_lvl2, tlu_gl_lvl3, tlu_wr_hintp_g, 
   tlu_set_hintp_sel_g, ctu_sscan_tid, si, se
   );	

/*AUTOINPUT*/
// Beginning of automatic inputs (from unused autoinst inputs)
// End of automatics
input	[134-1:0] tsa_rdata;		   // rd data for tsa.
input   [4-1:0] tlu_por_rstint_g;
//
// modified for timing
input   [64-1:0] tlu_wsr_data_w; // pr/st data from irf.

input	[7:0]	lsu_tlu_rsr_data_e;	// lsu sr/pr read data

input		rclk;			// clock
//
// reset was removed to abide to the Niagara reset methodology 
input tlu_rst;			           // unit-reset
input [4-1:0] tlu_thrd_wsel_w2;// thread requiring tsa write.
input [9-1:0]	tlu_final_ttype_w2;	   // selected ttype - g
input tlu_ibrkpt_trap_w2;	// instruction brkpt trap 
input tlu_trap_hpstate_enb;	// mode indicator for the trapped thrd 
input tlu_wr_tsa_inst_w2;	// write state inst
input [1:0]  tlu_pstate_din_sel0; // sel source of tsa wdata
input [1:0]  tlu_pstate_din_sel1; // sel source of tsa wdata
input [1:0]  tlu_pstate_din_sel2; // sel source of tsa wdata
input [1:0]  tlu_pstate_din_sel3; // sel source of tsa wdata
input [8-1:0] lsu_asi_reg0; // asi state - thread0
input [8-1:0] lsu_asi_reg1; // asi state - thread1
input [8-1:0] lsu_asi_reg2; // asi state - thread2
input [8-1:0] lsu_asi_reg3; // asi state - thread3
input [8-1:0] ifu_lsu_imm_asi_d; // asi state value from imm 
input ifu_lsu_imm_asi_vld_d; // valid asi state value from imm

input [3:0]	 tlu_tickcmp_sel;  // select src for tickcmp
input [3:0]	 tlu_tickcmp_en_l; // tick cmp reg write enable
input        tlu_tick_en_l;	   // tick reg write enable

// overflow for the pic registers - lvl15 int 
// input  [`TLU_THRD_NUM-1:0] pib_pic_wrap; 
input  [4-1:0] pib_pich_wrap; 
input  [4-1:0] pib_picl_wrap; 

input [7:0]  exu_tlu_ccr0_w;  // ccr - thread0
input [7:0]  exu_tlu_ccr1_w;  // ccr - thread1
input [7:0]  exu_tlu_ccr2_w;  // ccr - thread2
input [7:0]  exu_tlu_ccr3_w;  // ccr - thread3
// input [2:0]  exu_tlu_cwp0_w;  // cwp - thread0
// input [2:0]  exu_tlu_cwp1_w;  // cwp - thread1
// input [2:0]  exu_tlu_cwp2_w;  // cwp - thread2
// input [2:0]  exu_tlu_cwp3_w;  // cwp - thread3
input [2:0]  exu_tlu_cwp0;  // cwp - thread0
input [2:0]  exu_tlu_cwp1;  // cwp - thread1
input [2:0]  exu_tlu_cwp2;  // cwp - thread2
input [2:0]  exu_tlu_cwp3;  // cwp - thread3
// added for bug3499
input [4-1:0] tlu_trap_cwp_en;
// modified due to bug 3017
// input [47:0] ifu_tlu_pc_m;	  // pc
// input [47:0] ifu_tlu_npc_m;   // npc
// modified due to redistribution of logic
// input [48:0] ifu_tlu_pc_m;	  // pc
// input [48:0] ifu_tlu_npc_m;   // npc
input [48:0] tlu_pc_new_w;	  // pc
input [48:0] tlu_npc_new_w;   // npc

input [3:0]	 tlu_sftint_en_l_g; // wr enable for sftint regs.
input [3:0]	 tlu_sftint_mx_sel; // mux select for sftint regs 
input        tlu_set_sftint_l_g;       // set sftint
input        tlu_clr_sftint_l_g;       // clr sftint
input        tlu_wr_sftint_l_g;        // wr to sftin (asr 16)
//
// removed due to sftint recode
// input [3:0]	 tlu_sftint_lvl14_int;  // sftint lvl 14 plus tick int
input [3:0]	 tlu_sftint_penc_sel;
input [3:0]	 tlu_tba_en_l;		   // tba reg write enable
// logic moved to tlu_misctl
// input		 tlu_retry_inst_m;	   // valid retry inst
// input		 tlu_done_inst_m;	   // valid done inst
// input		 tlu_dnrtry_inst_m;	   // valid done/retry inst - g
// input		 tlu_dnrtry_inst_m_l;	   // valid done/retry inst - g
// input [3:0]	 tlu_update_pc_l_m;	   // update pc or npc for a thread
input [3:0]	 tlu_update_pc_l_w;	   // update pc or npc for a thread
// modified due to timing
// input  		 tlu_self_boot_rst_g;
// input		 tlu_tl_gt_0_g;		   // trp lvl gt then 0
// input  		 tlu_select_tba_g;
// input tlu_select_htba_g;   // choosing htba for forming trappc/trapnpc 
// input tlu_self_boot_rst_w2;
// added for one-hot mux problem
input [2:0] tlu_pc_mxsel_w2; 
input tlu_tl_gt_0_w2;	  // trp lvl gt then 0
input tlu_select_tba_w2;
input [4-1:0] tlu_update_pstate_l_w2; // pstate write enable
input [4-1:0] tlu_thrd_rsel_e; // read select for threaded regs
input [3:0] tlu_pil;     // mx'ed pil
input [2:0] tlu_trp_lvl; // mx'ed trp lvl

input tlu_select_redmode;
input tlu_tick_npt;       // npt bit of tick

input [64-4:0] tlu_tick_incr_dout;
//
// added and/or modified for hypervisor support
input [1:0] tlu_hpstate_din_sel0; // sel source of tsa wdata
input [1:0] tlu_hpstate_din_sel1; // sel source of tsa wdata
input [1:0] tlu_hpstate_din_sel2; // sel source of tsa wdata
input [1:0] tlu_hpstate_din_sel3; // sel source of tsa wdata
input [4-1:0] tlu_stickcmp_en_l; // stick cmp reg write enable
input [4-1:0] tlu_htickcmp_en_l; // htick cmp reg write enable
input [4-1:0] tlu_wr_hintp_g;    // wr control for hintp regs.
input [4-1:0] tlu_set_hintp_sel_g; // set control for hintp regs.
input [4-1:0] tlu_htba_en_l;     // htba reg write enable
input [4-1:0] tlu_update_hpstate_l_w2; // hpstate write enable
input tlu_htickcmp_intdis; // int. disable bit of htick-cmp
input [2-1:0] tlu_gl_lvl0; // global register value t0 
input [2-1:0] tlu_gl_lvl1; // global register value t1 
input [2-1:0] tlu_gl_lvl2; // global register value t2 
input [2-1:0] tlu_gl_lvl3; // global register value t3 
// mux select to read the new ASR registers
input [3:1] tlu_rdpr_mx1_sel;
input [3:1] tlu_rdpr_mx2_sel;
input [2:1] tlu_rdpr_mx3_sel;
input [2:1] tlu_rdpr_mx4_sel;
input [3:1] tlu_rdpr_mx5_sel;
input [2:0] tlu_rdpr_mx6_sel;
input [3:0] tlu_rdpr_mx7_sel;
//
input [4-1:0] ctu_sscan_tid;
input [64-1:0] tlu_pib_rsr_data_e; // rsr data from pib 

input si; // scan-in
input se; // scan-en

/*AUTOOUTPUT*/
// Beginning of automatic outputs (from unused autoinst outputs)
// End of automatics
//
// modified due to bug 3017
output [48:0] tlu_restore_pc_w1;  // trap pc or pc on retry.
output [48:0] tlu_restore_npc_w1; // trap pc or pc on retry.
output [33:0] tlu_partial_trap_pc_w1;
// the tlu_exu_rsr_data_e will become obsolete, to be removed
// added for timing
// output [`TLU_ASR_DATA_WIDTH-1:0] tlu_exu_rsr_data_e; // rsr data to exu 
output [64-1:0] tlu_exu_rsr_data_m; // rsr data to exu 
// modified due to timing violations
// output [`TLU_ASR_DATA_WIDTH-1:0] tlu_pib_rsr_data_e; // trap pc or pc on retry.
//
// modified for hypervisor support
output [136-1:0] tsa_wdata; // wr data for tsa.
//
output [4-1:0] tlu_int_pstate_ie;   // interrupt enable
output [4-1:0] local_pstate_ie;   // interrupt enable
output [4-1:0] tlu_ifu_pstate_pef;  // fp enable
output [4-1:0] tlu_lsu_pstate_cle;  // current little endian
output [4-1:0] tlu_lsu_pstate_priv; // privilege mode
output [4-1:0] tlu_int_redmode;	  // redmode
output [4-1:0] tlu_lsu_redmode;	  // redmode
// modified for bug 1767
// output   [1:0] tlu_pstate0_mmodel; // mem. model - thread0
// output   [1:0] tlu_pstate1_mmodel; // mem. model - thread1
// output   [1:0] tlu_pstate2_mmodel; // mem. model - thread2
// output   [1:0] tlu_pstate3_mmodel; // mem. model - thread3
// output   [3:0] tlu_pstate_tle;	  // trap little endian
// output [`TLU_THRD_NUM-1:0] tlu_pstate_cle;  // current little endian
// output [`TLU_THRD_NUM-1:0] tlu_pstate_priv; // privilege mode
output [4-1:0] tlu_pstate_am;   // address mask
//
// removed for bug 2187
// output [`TLU_THRD_NUM-1:0] tlu_sftint_lvl14;
output [4-1:0] tlu_hpstate_priv; // hypervisor privilege	
output [4-1:0] tlu_hpstate_enb;  // hypervisor lite enb	
output [4-1:0] tlu_hpstate_tlz;  // hypervisor tlz 
output [4-1:0] tlu_hpstate_ibe;  // hypervisor instruction brkpt	
output [4-1:0] local_hpstate_priv; // hypervisor privilege	
output [4-1:0] tcl_hpstate_priv; // hypervisor privilege	
output [4-1:0] local_pstate_priv;  // pstate privilege	
output [4-1:0] local_hpstate_enb;  // hypervisor lite enb	
output [4-1:0] tcl_hpstate_enb;  // hypervisor lite enb	
output [3:0] tlu_sftint_id;	
// output       tlu_tick_match;	// tick to tick cmp match
// output       tlu_stick_match;	// stick to tick cmp match
// output       tlu_htick_match;	// htick to tick cmp match
// output [`TLU_ASR_DATA_WIDTH-1:0] tlu_tick_incr_din;
output [64-3:0] tlu_tick_incr_din;
//
// modified for hypervisor support
// output	[2:0]	tlu_restore_globals; // restored global regs
//
output [2-1:0] tlu_dnrtry_global_g; // restored globals 
output [4-1:0]     tlu_hintp;
// 
// current asi state 
output [8-1:0] tlu_asi_state_e;
//
// modified due to race key word limitation
// output [62:0] tlu_sscan_test_data;
output [51-1:0] tlu_sscan_test_data;
output		  so; // scan-out;

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
// End of automatics
//
// local reset was added to abide to the Niagara reset methodology 
wire        local_rst; // local reset
wire        se_l; // testmode_l replacement 
//
// rdpr muxe outputs
wire [64-1:0] tlu_rdpr_mx1_out;
wire [3:0]  tlu_rdpr_mx2_out;
wire [17-1:0]  tlu_rdpr_mx3_out;
wire [48-1:0]  tlu_rdpr_mx4_out;
// 
// constructing one-hot selects
wire rdpr_mx1_onehot_sel, rdpr_mx2_onehot_sel; 
wire rdpr_mx3_onehot_sel, rdpr_mx4_onehot_sel; 
wire rdpr_mx5_onehot_sel, rdpr_mx6_onehot_sel; 
//
wire  [32:0] true_tba0,true_tba1,true_tba2,true_tba3;
wire  [60:0] true_tick;
// modified due to bug 3017
wire  [48:0] true_pc0,true_pc1,true_pc2,true_pc3;
// wire  [47:0] sscan_pc; 
wire  [51-1:0] sscan_data_test0;
wire  [51-1:0] sscan_data_test1;
wire  [51-1:0] sscan_data_test2;
wire  [51-1:0] sscan_data_test3;
wire  [51-1:0] tdp_sscan_test_data;
wire  [4-1:0] sscan_tid_sel; 
wire  [48:0] true_npc0,true_npc1,true_npc2,true_npc3;
// wire  [47:0] true_npc0,true_npc1,true_npc2,true_npc3;
// wire  [47:0] true_pc0,true_pc1,true_pc2,true_pc3;
// wire  [47:0] sscan_pc; 
// wire  [47:0] normal_trap_pc, normal_trap_npc;
//
// modified for hypervisor support
wire [136-1:0] trap_tsa_wdata;
wire [136-1:0] trap0_tsa_wdata,trap1_tsa_wdata;
wire [136-1:0] trap2_tsa_wdata,trap3_tsa_wdata;
wire [136-1:0] wrpr_tsa_wdata;
wire [136-1:0] tsa_wdata;
wire [48-1:0]  tstate_rdata;
wire [1:0]  tstate_dummy_zero;
wire [29-1:0]   compose_tstate;
wire [4-1:0]  compose_htstate;
wire [2-1:0]   global_rdata;	
// wire [`TLU_ASR_DATA_WIDTH-1:0] wsr_data_w;	
wire [17-1:0] wsr_data_w;	
// reduced width to 48 due to lint violations
wire [47:0] wsr_data_w2;	
//
// modified for bug 3017
// wire  [47:2] trap_pc0,trap_pc1,trap_pc2,trap_pc3;
// wire  [47:2] trap_npc0,trap_npc1,trap_npc2,trap_npc3;
wire  [48:2] trap_pc0,trap_pc1,trap_pc2,trap_pc3;
wire  [48:2] trap_npc0,trap_npc1,trap_npc2,trap_npc3;
wire   [7:0] trap_ccr0,trap_ccr1,trap_ccr2,trap_ccr3;
wire   [7:0] trap_asi0,trap_asi1,trap_asi2,trap_asi3;
wire   [2:0] trap_cwp0,trap_cwp1,trap_cwp2,trap_cwp3;
wire   [2:0] tlu_cwp0,tlu_cwp1,tlu_cwp2,tlu_cwp3;
wire   [8-1:0] imm_asi_e; 
wire   [8-1:0] asi_state_reg_e; 
wire   [8-1:0] asi_state_final_e; 
wire   imm_asi_vld_e;
//
// modified due to tickcmp, stickcmp and sftint cleanup
// wire  [15:0] sftint0, sftint1, sftint2, sftint3;
// wire  [15:1] sftint_set_din, sftint_clr_din, sftint_wr_din;
wire  [17-1:0] sftint0, sftint1, sftint2, sftint3;
wire  [17-1:0] sftint_set_din, sftint_clr_din, sftint_wr_din;
wire [17-1:0] sftint_din;
wire [17-1:0] sftint;
wire [4-1:0] sftint_b0_din; 
wire [4-1:0] sftint_b0_en;
wire [4-1:0] sftint_b15_din; 
wire [4-1:0] sftint_b15_en;
wire [4-1:0] sftint_b16_din; 
wire [4-1:0] sftint_b16_en; 
wire [4-1:0] sftint_lvl14;
wire [3:0] sftin_din_mxsel;
// recoded for one-hot problem during reset
// wire sftint_sel_onehot_g;
//
// added for PIB support
wire	     tcmp0_clk, tcmp1_clk; 
wire	     tcmp2_clk, tcmp3_clk;
wire [14:0]  sftint_penc_din;
wire	     sftint0_clk,sftint1_clk;
wire	     sftint2_clk,sftint3_clk;
// 
wire [32:0] tba_data;
wire [32:0] tba_rdata;
wire [33:0] tlu_rstvaddr_base;
wire [34-1:0] htba_data;
wire        tba0_clk,tba1_clk,tba2_clk,tba3_clk;
// modified for bug 3017
// wire [46:0] tsa_pc_m,tsa_npc_m;
// wire [48:0] dnrtry_pc,dnrtry_npc;
wire [48:0] restore_pc_w2;
wire [48:0] restore_npc_w2;
// wire [48:0]	pc_new, npc_new;
// wire [48:0]	pc_new_w, npc_new_w;
wire [33:0] partial_trap_pc_w2;
wire        pc0_clk,pc1_clk,pc2_clk,pc3_clk;
// wire [`TLU_TSA_WIDTH-1:0] tsa_data_m;
wire [64-1:0] true_tickcmp0, true_tickcmp1;
wire [64-1:0] true_tickcmp2, true_tickcmp3;
wire [64-1:0] tickcmp_rdata;
wire [4-1:0] tickcmp_intdis_din;
wire [4-1:0] tickcmp_intdis_en;
wire [4-1:0] tickcmp_int;
wire [4-1:0] tlu_set_hintp_g;
wire [4-1:0] tlu_hintp_en_l_g;
wire tlu_htick_match;	// htick to tick cmp match
wire tick_match;
wire [64-4:0] tickcmp_data;
wire [64-2:2] tick_din;
// reg	 [`TLU_ASR_DATA_WIDTH-1:0] tlu_rsr_data_e;
wire [12-1:0] true_pstate0,true_pstate1;
wire [12-1:0] true_pstate2,true_pstate3;
// wire [`TLU_THRD_NUM-1:0] tlu_pstate_priv; // privilege mode
// added for hypervisor support 
wire [8-1:0] trap_pstate0,trap_pstate1;
wire [8-1:0] trap_pstate2,trap_pstate3;
//
// wire [`PSTATE_TRUE_WIDTH-1:0] dnrtry_pstate;
// wire [`PSTATE_TRUE_WIDTH-1:0] dnrtry_pstate_m;	
// wire [`PSTATE_TRUE_WIDTH-1:0] wsr_data_pstate_g;	
wire [6-1:0] dnrtry_pstate_m;	
wire [6-1:0] dnrtry_pstate_g;	
wire [6-1:0] dnrtry_pstate_w2;
// removed for timing
// wire [`WSR_PSTATE_VR_WIDTH-1:0] wsr_data_pstate_g;
wire [6-1:0] wsr_data_pstate_w2;	
//
// modified for bug 1767
//wire [`PSTATE_TRUE_WIDTH-1:0] ntrap_pstate;
// wire [`PSTATE_TRUE_WIDTH-1:0] ntrap_pstate0;
// wire [`PSTATE_TRUE_WIDTH-1:0] ntrap_pstate1;
// wire [`PSTATE_TRUE_WIDTH-1:0] ntrap_pstate2;
// wire [`PSTATE_TRUE_WIDTH-1:0] ntrap_pstate3;
wire [6-1:0] ntrap_pstate0;
wire [6-1:0] ntrap_pstate1;
wire [6-1:0] ntrap_pstate2;
wire [6-1:0] ntrap_pstate3;
// modified for bug 2161 and 2584
wire pstate_priv_set, hpstate_priv_set; 
wire [4-1:0] pstate_priv_thrd_set;
// wire [`TLU_THRD_NUM-1:0] pstate_priv_update_g;
wire [4-1:0] pstate_priv_update_w2;
// wire [`TLU_THRD_NUM-1:0] hpstate_dnrtry_priv_g;
wire [4-1:0] hpstate_dnrtry_priv_w2;
wire [4-1:0] hpstate_enb_set;
wire [4-1:0] hpstate_ibe_set;
wire [4-1:0] hpstate_tlz_set;
// wire [`TLU_THRD_NUM-1:0] hpstate_priv_update_g;
wire [4-1:0] hpstate_priv_update_w2;
//
// removed for bug 2588
// wire [1:0] tlu_select_mmodel0;
// wire [1:0] tlu_select_mmodel1;
// wire [1:0] tlu_select_mmodel2;
// wire [1:0] tlu_select_mmodel3;
wire [4-1:0] tlu_select_tle;
wire [4-1:0] tlu_select_cle;
// wire [1:0] tlu_pstate0_mmodel;	// mem. model - thread0
// wire [1:0] tlu_pstate1_mmodel;	// mem. model - thread1
// wire [1:0] tlu_pstate2_mmodel;	// mem. model - thread2
// wire [1:0] tlu_pstate3_mmodel;	// mem. model - thread3
wire [4-1:0] tlu_pstate_tle; // trap little endian
//
// modified for bug 1575
// wire	[`PSTATE_TRUE_WIDTH-1:0]	restore_pstate;
// wire [`PSTATE_TRUE_WIDTH-1:0]	restore_pstate0;
// wire [`PSTATE_TRUE_WIDTH-1:0]	restore_pstate1;
// wire [`PSTATE_TRUE_WIDTH-1:0]	restore_pstate2; 
// wire [`PSTATE_TRUE_WIDTH-1:0]	restore_pstate3;
wire [6-1:0]	restore_pstate0;
wire [6-1:0]	restore_pstate1;
wire [6-1:0]	restore_pstate2; 
wire [6-1:0]	restore_pstate3;
wire [6-1:0]	restore_pstate0_w3;
wire [6-1:0]	restore_pstate1_w3;
wire [6-1:0]	restore_pstate2_w3; 
wire [6-1:0]	restore_pstate3_w3;
wire tlu_pstate_nt_sel0, tlu_pstate_nt_sel1;
wire tlu_pstate_nt_sel2, tlu_pstate_nt_sel3;
wire tlu_pstate_wsr_sel0, tlu_pstate_wsr_sel1;
wire tlu_pstate_wsr_sel2, tlu_pstate_wsr_sel3;
wire hpstate_redmode;
wire pstate0_clk,pstate1_clk,pstate2_clk,pstate3_clk;

//
// added or modified for hypervisor support
// wire	[2:0]   global_sel;	
wire stcmp0_clk, stcmp1_clk, stcmp2_clk, stcmp3_clk;
wire htcmp0_clk, htcmp1_clk, htcmp2_clk, htcmp3_clk;
wire tlu_hpstate_hnt_sel0, tlu_hpstate_hnt_sel1;
wire tlu_hpstate_hnt_sel2, tlu_hpstate_hnt_sel3;
wire tlu_hpstate_wsr_sel0, tlu_hpstate_wsr_sel1;
wire tlu_hpstate_wsr_sel2, tlu_hpstate_wsr_sel3;
wire pc_bit15_sel;
wire htba0_clk,htba1_clk,htba2_clk,htba3_clk;
wire hpstate0_clk,hpstate1_clk,hpstate2_clk,hpstate3_clk;
wire hintp0_clk,hintp1_clk,hintp2_clk,hintp3_clk;
wire hintp_rdata;
wire [4-1:0]       hintp_din;
// added or modified due to stickcmp clean-up
// wire [`TLU_ASR_DATA_WIDTH-2:0] stickcmp_rdata;
// wire [`TLU_ASR_DATA_WIDTH-2:0] true_stickcmp0, true_stickcmp1;
// wire [`TLU_ASR_DATA_WIDTH-2:0] true_stickcmp2, true_stickcmp3;
wire [64-1:0] stickcmp_rdata;
wire [64-1:0] true_stickcmp0, true_stickcmp1;
wire [64-1:0] true_stickcmp2, true_stickcmp3;
wire [4-1:0] stickcmp_intdis_din;
wire [4-1:0] stickcmp_intdis_en; 
wire [4-1:0] stickcmp_int; 
wire stick_match;
wire [64-4:0] stickcmp_data;
//
wire [64-2:0] htickcmp_rdata;
wire [64-4:0] htickcmp_data;
wire [64-2:0] true_htickcmp0, true_htickcmp1;
wire [64-2:0] true_htickcmp2, true_htickcmp3;
wire [5-1:0]  true_hpstate0,true_hpstate1;
wire [5-1:0]  true_hpstate2,true_hpstate3;
wire [5-1:0]  true_hpstate;
wire [4-1:0]  tsa_dnrtry_hpstate_m; 
wire [4-1:0]  tsa_dnrtry_hpstate_g; 
wire [4-1:0]  tsa_dnrtry_hpstate_w2; 
// wire [`TLU_HPSTATE_WIDTH-1:0]  dnrtry_hpstate0_g, dnrtry_hpstate1_g; 
wire [5-1:0]  dnrtry_hpstate0_w2, dnrtry_hpstate1_w2; 
// wire [`TLU_HPSTATE_WIDTH-1:0]  dnrtry_hpstate2_g, dnrtry_hpstate3_g; 
wire [5-1:0]  dnrtry_hpstate2_w2, dnrtry_hpstate3_w2; 
// wire [`TLU_HPSTATE_WIDTH-1:0]  hntrap_hpstate0_g, hntrap_hpstate1_g; 
wire [5-1:0]  hntrap_hpstate0_w2, hntrap_hpstate1_w2; 
// wire [`TLU_HPSTATE_WIDTH-1:0]  hntrap_hpstate2_g, hntrap_hpstate3_g; 
wire [5-1:0]  hntrap_hpstate2_w2, hntrap_hpstate3_w2; 
wire [5-1:0]  wsr_data_hpstate_w2; 
wire [5-1:0]  restore_hpstate0, restore_hpstate1; 
wire [5-1:0]  restore_hpstate2, restore_hpstate3; 
wire [34-1:0]	   true_htba0, true_htba1;
wire [34-1:0]	   true_htba2, true_htba3;
wire [2-1:0]   dnrtry_global_m;	
wire [64-1:0] tlu_rdpr_mx5_out;
wire [17-1:0]       tlu_rdpr_mx6_out;
wire [64-1:0] tlu_rdpr_mx7_out;
wire [64-1:0] tlu_exu_rsr_data_e;
wire clk; 
//
//=========================================================================================
// create local reset

assign local_rst = tlu_rst;
assign se_l = ~se;

// clock rename
assign clk = rclk;

//=========================================================================================
// Design Notes :
// HTSTATE-	       4 (ENB from HPSTATE is not saved)	
// TPC-		      47 (48-2)VA+(1)VA_HOLE
// TNPC-		  47 (48-2)VA+(1)VA_HOLE
// TSTATE.GL-	   2 (Only two significant bits are saved)
// TSTATE.CCR-     8
// TSTATE.ASI-	   8
// TSTATE.PSTATE-  8 (RED, IG, MG and AG bits are not used)
// TSTATE.CWP-	   3
// TRAPTYPE-	   9
//========================================================
// Total         136

//=========================================================================================
//	Timing Diagram	
//=========================================================================================


// WRITE TO TSA and other trap related registers.
//	|	|	|		|		|
//	|E	|M	|	W	|  	W2	| Integer
//	|	|	| exceptions	| push tsa	|
//	|	|	| reported	| xmit pc	|
//	|	|	|		|		|
//	|E	|M	|	G 	|	W2	| Long-Latency
//	|	|	| exceptions	|		|
//	|	|	| reported	| push tsa	|
//	|	|	|		| xmit pc	|

//=========================================================================================
//	Generate TSA Control and Data
//=========================================================================================

// modified for bug 3017
assign  trap_pc0[48:2] =  true_pc0[48:2];
assign  trap_pc1[48:2] =  true_pc1[48:2];
assign  trap_pc2[48:2] =  true_pc2[48:2];
assign  trap_pc3[48:2] =  true_pc3[48:2];

assign  trap_npc0[48:2] = true_npc0[48:2]; 
assign  trap_npc1[48:2] = true_npc1[48:2];
assign  trap_npc2[48:2] = true_npc2[48:2];
assign  trap_npc3[48:2] = true_npc3[48:2];

assign	trap_ccr0[7:0] = exu_tlu_ccr0_w[7:0];
assign	trap_ccr1[7:0] = exu_tlu_ccr1_w[7:0];
assign	trap_ccr2[7:0] = exu_tlu_ccr2_w[7:0];
assign	trap_ccr3[7:0] = exu_tlu_ccr3_w[7:0];

// assign	trap_cwp0[2:0] = exu_tlu_cwp0_w[2:0];
// assign	trap_cwp1[2:0] = exu_tlu_cwp1_w[2:0];
// assign	trap_cwp2[2:0] = exu_tlu_cwp2_w[2:0];
// assign	trap_cwp3[2:0] = exu_tlu_cwp3_w[2:0];
//
// added for bug 3695
dff #(3) dff_tlu_cwp0 (
    .din (exu_tlu_cwp0[2:0]),
    .q   (tlu_cwp0[2:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff #(3) dff_tlu_cwp1 (
    .din (exu_tlu_cwp1[2:0]),
    .q   (tlu_cwp1[2:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff #(3) dff_tlu_cwp2 (
    .din (exu_tlu_cwp2[2:0]),
    .q   (tlu_cwp2[2:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff #(3) dff_tlu_cwp3 (
    .din (exu_tlu_cwp3[2:0]),
    .q   (tlu_cwp3[2:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
// 
// modified for bug 3499 and 3695
dffe #(3) dffe_trap_cwp0 (
    // .din (exu_tlu_cwp0[2:0]),
    .din (tlu_cwp0[2:0]),
    .q   (trap_cwp0[2:0]),
    .en  (tlu_trap_cwp_en[0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dffe #(3) dffe_trap_cwp1 (
    // .din (exu_tlu_cwp1[2:0]),
    .din (tlu_cwp1[2:0]),
    .q   (trap_cwp1[2:0]),
    .en  (tlu_trap_cwp_en[1]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dffe #(3) dffe_trap_cwp2 (
    // .din (exu_tlu_cwp2[2:0]),
    .din (tlu_cwp2[2:0]),
    .q   (trap_cwp2[2:0]),
    .en  (tlu_trap_cwp_en[2]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dffe #(3) dffe_trap_cwp3 (
    // .din (exu_tlu_cwp3[2:0]),
    .din (tlu_cwp3[2:0]),
    .q   (trap_cwp3[2:0]),
    .en  (tlu_trap_cwp_en[3]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

assign	trap_asi0[7:0] = lsu_asi_reg0[7:0];
assign	trap_asi1[7:0] = lsu_asi_reg1[7:0];
assign	trap_asi2[7:0] = lsu_asi_reg2[7:0];
assign	trap_asi3[7:0] = lsu_asi_reg3[7:0];
// 
// staging the immediate asi

dff #(8) dff_imm_asi_e (
    .din (ifu_lsu_imm_asi_d[8-1:0]),
    .q   (imm_asi_e[8-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dffr dffr_imm_asi_vld_e (
     .din (ifu_lsu_imm_asi_vld_d),
     .q   (imm_asi_vld_e),
     .clk (clk),
	 .rst (local_rst),
     .se  (se),
     .si  (),
     .so  ()
);
//
// generating the current asi state
mux4ds  #(8) mx_tlu_asi_state_e (
        .in0    (lsu_asi_reg0[8-1:0]),
        .in1    (lsu_asi_reg1[8-1:0]),
        .in2    (lsu_asi_reg2[8-1:0]),
        .in3    (lsu_asi_reg3[8-1:0]),
        .sel0   (tlu_thrd_rsel_e[0]),
        .sel1   (tlu_thrd_rsel_e[1]),
        .sel2   (tlu_thrd_rsel_e[2]),
        .sel3   (tlu_thrd_rsel_e[3]),
        // modified due to bug 2442
        // .dout   (tlu_asi_state_e[`TLU_ASI_STATE_WIDTH-1:0])
        .dout   (asi_state_reg_e[8-1:0])
); 
//
// added for bug 2442
// generating the current asi state
mux2ds #(8) mx_asi_state_final_e (
       .in0  (imm_asi_e[8-1:0]),
	   .in1  (asi_state_reg_e[8-1:0]),
       .sel0 (imm_asi_vld_e),  	
	   .sel1 (~imm_asi_vld_e),
       .dout (asi_state_final_e[8-1:0])
); 

assign tlu_asi_state_e[8-1:0] =
           asi_state_final_e[8-1:0];
//
// thread 0
assign trap_pstate0 = {
       true_pstate0[9:8], 
       2'b0, true_pstate0[4:1]};
//
// modified due to hpstate.ibe addition
assign trap0_tsa_wdata[135:132] = 
       {true_hpstate0[5-1],
        true_hpstate0[4-2:0]};
//
// modified for bug 3017
//
assign trap0_tsa_wdata[131:85] = 
           trap_pc0[48:2];
//
assign trap0_tsa_wdata[84:38] = 
           trap_npc0[48:2];
//
assign trap0_tsa_wdata[37:36] = 
       tlu_gl_lvl0[2-1:0]; 
//
assign trap0_tsa_wdata[35:28] = 
       trap_ccr0[8-1:0]; 
//
assign trap0_tsa_wdata[27:20] = 
       trap_asi0[8-1:0]; 
//
assign trap0_tsa_wdata[19:12] = 
       trap_pstate0[8-1:0]; 
//
assign trap0_tsa_wdata[11:9] = 
       trap_cwp0[3-1:0]; 
//
assign trap0_tsa_wdata[8:0] = 
       tlu_final_ttype_w2[9-1:0]; 
//
// thread 1
assign trap_pstate1 = {
       true_pstate1[9:8], 
       2'b0, true_pstate1[4:1]};
//
// modified due to hpstate.ibe addition
assign trap1_tsa_wdata[135:132] = 
       {true_hpstate1[5-1],
        true_hpstate1[4-2:0]};
//
assign trap1_tsa_wdata[131:85] = 
           trap_pc1[48:2];
//
assign trap1_tsa_wdata[84:38] = 
           trap_npc1[48:2];
//
assign trap1_tsa_wdata[37:36] = 
       tlu_gl_lvl1[2-1:0]; 
//
assign trap1_tsa_wdata[35:28] = 
       trap_ccr1[8-1:0]; 
//
assign trap1_tsa_wdata[27:20] = 
       trap_asi1[8-1:0]; 
//
assign trap1_tsa_wdata[19:12] = 
       trap_pstate1[8-1:0]; 
//
assign trap1_tsa_wdata[11:9] = 
       trap_cwp1[3-1:0]; 
//
assign trap1_tsa_wdata[8:0] = 
       tlu_final_ttype_w2[9-1:0]; 
//
// thread 2
assign trap_pstate2 = {
       true_pstate2[9:8], 
       2'b0, true_pstate2[4:1]};
//
// modified due to hpstate.ibe addition
assign trap2_tsa_wdata[135:132] = 
       {true_hpstate2[5-1],
        true_hpstate2[4-2:0]};
//
assign trap2_tsa_wdata[131:85] = 
           trap_pc2[48:2];
//
assign trap2_tsa_wdata[84:38] = 
           trap_npc2[48:2];
//
assign trap2_tsa_wdata[37:36] = 
       tlu_gl_lvl2[2-1:0]; 
//
assign trap2_tsa_wdata[35:28] = 
       trap_ccr2[8-1:0]; 
//
assign trap2_tsa_wdata[27:20] = 
       trap_asi2[8-1:0]; 
//
assign trap2_tsa_wdata[19:12] = 
       trap_pstate2[8-1:0]; 
//
assign trap2_tsa_wdata[11:9] = 
       trap_cwp2[3-1:0]; 
//
assign trap2_tsa_wdata[8:0] = 
       tlu_final_ttype_w2[9-1:0]; 
//
// thread 3
assign trap_pstate3 = {
       true_pstate3[9:8], 
       2'b0, true_pstate3[4:1]};
//
// modified due to hpstate.ibe addition
assign trap3_tsa_wdata[135:132] = 
       {true_hpstate3[5-1],
        true_hpstate3[4-2:0]};
//
assign trap3_tsa_wdata[131:85] = 
           trap_pc3[48:2];
//
assign trap3_tsa_wdata[84:38] = 
           trap_npc3[48:2];
//
assign trap3_tsa_wdata[37:36] = 
       tlu_gl_lvl3[2-1:0]; 
//
assign trap3_tsa_wdata[35:28] = 
       trap_ccr3[8-1:0]; 
//
assign trap3_tsa_wdata[27:20] = 
       trap_asi3[8-1:0]; 
//
assign trap3_tsa_wdata[19:12] = 
       trap_pstate3[8-1:0]; 
//
assign trap3_tsa_wdata[11:9] = 
       trap_cwp3[3-1:0]; 
//
assign trap3_tsa_wdata[8:0] = 
       tlu_final_ttype_w2[9-1:0]; 
//
// modified for timing: tlu_thrd_wsel_g -> tlu_thrd_wsel_w2



   
mux4ds  #(136) tsawdsel (
        .in0    (trap0_tsa_wdata[136-1:0]),
        .in1    (trap1_tsa_wdata[136-1:0]),
        .in2    (trap2_tsa_wdata[136-1:0]),
        .in3    (trap3_tsa_wdata[136-1:0]),
        .sel0   (tlu_thrd_wsel_w2[0]),
        .sel1   (tlu_thrd_wsel_w2[1]),
        .sel2   (tlu_thrd_wsel_w2[2]),
        .sel3   (tlu_thrd_wsel_w2[3]),
        .dout   (trap_tsa_wdata[136-1:0])
); 
 // !`ifdef FPGA_SYN_1THREAD
   
//
// modified for timing and lint violations
// assign wsr_data_w[`TLU_ASR_DATA_WIDTH-1:0] = 
//            tlu_wsr_data_w[`TLU_ASR_DATA_WIDTH-1:0];
assign wsr_data_w[17-1:0] = 
           tlu_wsr_data_w[17-1:0];
// 
// added for timing
// reduced width to 48 due to lint violations
dff #(48) dff_wsr_data_w2 (
    .din (tlu_wsr_data_w[47:0]),
    .q   (wsr_data_w2[47:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// extracting the relevant data for tstate from the WSR to be written
// modified due to timing changes
assign compose_tstate[29-1:0] = 
	  {wsr_data_w2[41:40],
       wsr_data_w2[39:32],
       wsr_data_w2[31:24],
       wsr_data_w2[17:16],
       2'b0,
       wsr_data_w2[12:9],
       wsr_data_w2[2:0]};
//
// extracting the relevant data from hstate from the WSR to be written
assign compose_htstate[4-1:0] = 
	  {wsr_data_w2[10],
       wsr_data_w2[5],
	   wsr_data_w2[2],
	   wsr_data_w2[0]};

// htstate
assign	wrpr_tsa_wdata[135:132]=
        compose_htstate[4-1:0];
// 
// modified for bug 3017 
// pc
assign wrpr_tsa_wdata[131:85]=
       {1'b0, wsr_data_w2[47:2]};
// npc
assign wrpr_tsa_wdata[84:38]=
       {1'b0, wsr_data_w2[47:2]};
// tstate data
assign wrpr_tsa_wdata[37:9]=
       compose_tstate[29-1:0];
// ttype data
assign wrpr_tsa_wdata[8:0]=
       wsr_data_w2[9-1:0];

mux2ds #(136) tsawdata_sel (
       .in0    ({trap_tsa_wdata[136-1:0]}),
	   .in1    ({wrpr_tsa_wdata[136-1:0]}),
       .sel0   (~tlu_wr_tsa_inst_w2),
       .sel1    (tlu_wr_tsa_inst_w2),
       .dout   ({tsa_wdata[136-1:0]})
); 

//=========================================================================================
//	SOFT INTERRUPT for Threads
//=========================================================================================

// Assumption is that softint state is unknown after reset.
// TICK_INT will be maintained separately. What is the relative order of
// setting and clearing this bit ? What takes precedence ?
//
// modified for bug 2204
// recoded due to one-hot problem during reset




   
mux4ds #(17) mx_sftint (
        .in0  (sftint0[17-1:0]),
        .in1  (sftint1[17-1:0]),
        .in2  (sftint2[17-1:0]),
        .in3  (sftint3[17-1:0]),
        .sel0 (tlu_sftint_mx_sel[0]),
        .sel1 (tlu_sftint_mx_sel[1]),
        .sel2 (tlu_sftint_mx_sel[2]),
        .sel3 (tlu_sftint_mx_sel[3]),
        .dout (sftint[17-1:0])
);
 // !`ifdef FPGA_SYN_1THREAD
   
/*
assign sftint_sel_onehot_g = 
           ~tlu_sftint_en_l_g[0] | (&tlu_sftint_en_l_g[3:1]); 

mux4ds #(`SFTINT_WIDTH) mx_sftint (
        .in0  (sftint0[`SFTINT_WIDTH-1:0]),
        .in1  (sftint1[`SFTINT_WIDTH-1:0]),
        .in2  (sftint2[`SFTINT_WIDTH-1:0]),
        .in3  (sftint3[`SFTINT_WIDTH-1:0]),
        .sel0 (sftint_sel_onehot_g),
        .sel1 (~tlu_sftint_en_l_g[1]),
        .sel2 (~tlu_sftint_en_l_g[2]),
        .sel3 (~tlu_sftint_en_l_g[3]),
        .dout (sftint[`SFTINT_WIDTH-1:0])
); 
*/

assign	sftint_set_din[17-1:0] = 
            (wsr_data_w[17-1:0] | sftint[17-1:0]);
assign	sftint_clr_din[17-1:0] = 
            (~wsr_data_w[17-1:0] & sftint[17-1:0]);
assign	sftint_wr_din[17-1:0]  =  
            wsr_data_w[17-1:0];

// consturcting the mux select for the sftin_din mux

assign sftin_din_mxsel[0] = ~tlu_set_sftint_l_g;
assign sftin_din_mxsel[1] = ~tlu_clr_sftint_l_g;
assign sftin_din_mxsel[2] = ~tlu_wr_sftint_l_g;
assign sftin_din_mxsel[3] =  
           tlu_set_sftint_l_g & tlu_clr_sftint_l_g & tlu_wr_sftint_l_g; 

mux4ds #(17) mx_sftint_din (
        .in0  (sftint_set_din[17-1:0]),
        .in1  (sftint_clr_din[17-1:0]),
        .in2  (sftint_wr_din[17-1:0]),
        .in3  (sftint[17-1:0]),
        .sel0 (sftin_din_mxsel[0]),
        .sel1 (sftin_din_mxsel[1]),
        .sel2 (sftin_din_mxsel[2]),
        .sel3 (sftin_din_mxsel[3]),
        .dout (sftint_din[17-1:0])
); 








































//		
// added for PIB support - modified to make inst count precise
assign sftint_b15_din[0] = 
           (pib_picl_wrap[0] | pib_pich_wrap[0] | sftint_din[15]);
assign sftint_b15_din[1] =                       
           (pib_picl_wrap[1] | pib_pich_wrap[1] | sftint_din[15]);
assign sftint_b15_din[2] =                       
           (pib_picl_wrap[2] | pib_pich_wrap[2] | sftint_din[15]);
assign sftint_b15_din[3] =                       
           (pib_picl_wrap[3] | pib_pich_wrap[3] | sftint_din[15]);

assign sftint_b15_en[0] = 
           (pib_picl_wrap[0] | pib_pich_wrap[0] | ~tlu_sftint_en_l_g[0]);
assign sftint_b15_en[1] = 
           (pib_picl_wrap[1] | pib_pich_wrap[1] | ~tlu_sftint_en_l_g[1]);
assign sftint_b15_en[2] = 
           (pib_picl_wrap[2] | pib_pich_wrap[2] | ~tlu_sftint_en_l_g[2]);
assign sftint_b15_en[3] = 
           (pib_picl_wrap[3] | pib_pich_wrap[3] | ~tlu_sftint_en_l_g[3]);
//		
// added due to sftint spec change 
// tickcmp interrupts
assign sftint_b0_din[0] = (tickcmp_int[0] | sftint_din[0]);
assign sftint_b0_din[1] = (tickcmp_int[1] | sftint_din[0]);
assign sftint_b0_din[2] = (tickcmp_int[2] | sftint_din[0]);
assign sftint_b0_din[3] = (tickcmp_int[3] | sftint_din[0]);

assign sftint_b0_en[0] = (tickcmp_int[0] | ~tlu_sftint_en_l_g[0]);
assign sftint_b0_en[1] = (tickcmp_int[1] | ~tlu_sftint_en_l_g[1]);
assign sftint_b0_en[2] = (tickcmp_int[2] | ~tlu_sftint_en_l_g[2]);
assign sftint_b0_en[3] = (tickcmp_int[3] | ~tlu_sftint_en_l_g[3]);
//
// stickcmp interrupts
assign sftint_b16_din[0] = (stickcmp_int[0] | sftint_din[16]);
assign sftint_b16_din[1] = (stickcmp_int[1] | sftint_din[16]);
assign sftint_b16_din[2] = (stickcmp_int[2] | sftint_din[16]);
assign sftint_b16_din[3] = (stickcmp_int[3] | sftint_din[16]);

assign sftint_b16_en[0] = (stickcmp_int[0] | ~tlu_sftint_en_l_g[0]);
assign sftint_b16_en[1] = (stickcmp_int[1] | ~tlu_sftint_en_l_g[1]);
assign sftint_b16_en[2] = (stickcmp_int[2] | ~tlu_sftint_en_l_g[2]);
assign sftint_b16_en[3] = (stickcmp_int[3] | ~tlu_sftint_en_l_g[3]);

// modified for sftint spec change - special treatments for bit 0, 15 and 16 
//
// thread 0

dffre #(14) dffr_sftint0 (
    .din (sftint_din[14:1]), 
    .q   (sftint0[14:1]),
    .en (~(tlu_sftint_en_l_g[0])), .clk(clk),
    .rst (local_rst),
    .se  (se),       
    .si  (),          
    .so  ()
);











dffre dffre_sftint0_b0 (
    .din (sftint_b0_din[0]), 
    .q   (sftint0[0]),
    .clk (clk),
    .rst (local_rst),
    .en  (sftint_b0_en[0]),
    .se  (se),
    .si  (),          
    .so  ()
);

dffre dffre_sftint0_b15 (
    .din (sftint_b15_din[0]), 
    .q   (sftint0[15]),
    .clk (clk),
    .rst (local_rst),
    .en  (sftint_b15_en[0]),
    .se  (se),
    .si  (),          
    .so  ()
);

dffre dffre_sftint0_b16 (
    .din (sftint_b16_din[0]), 
    .q   (sftint0[16]),
    .clk (clk),
    .rst (local_rst),
    .en  (sftint_b16_en[0]),
    .se  (se),
    .si  (),          
    .so  ()
);
//
// thread 1

dffre #(14) sftint1ff (
    .din (sftint_din[14:1]), 
    .q   (sftint1[14:1]),
    .en (~(tlu_sftint_en_l_g[1])), .clk(clk),
    .rst (local_rst),
    .se  (se),       
    .si  (),          
    .so  ()
);












dffre dffre_sftint1_b0 (
    .din (sftint_b0_din[1]), 
    .q   (sftint1[0]),
    .clk (clk),
    .rst (local_rst),
    .en  (sftint_b0_en[1]),
    .se  (se),
    .si  (),          
    .so  ()
);

dffre dffre_sftint1_b15 (
    .din (sftint_b15_din[1]), 
    .q   (sftint1[15]),
    .clk (clk),
    .rst (local_rst),
    .en  (sftint_b15_en[1]),
    .se  (se),
    .si  (),          
    .so  ()
);

dffre dffre_sftint1_b16 (
    .din (sftint_b16_din[1]), 
    .q   (sftint1[16]),
    .clk (clk),
    .rst (local_rst),
    .en  (sftint_b16_en[1]),
    .se  (se),
    .si  (),          
    .so  ()
);
//
// thread 2

dffre #(14) sftint2ff (
    .din (sftint_din[14:1]), 
    .q   (sftint2[14:1]),
    .en (~(tlu_sftint_en_l_g[2])), .clk(clk),
    .rst (local_rst),
    .se  (se),       
    .si  (),          
    .so  ()
);












dffre dffre_sftint2_b0 (
    .din (sftint_b0_din[2]), 
    .q   (sftint2[0]),
    .clk (clk),
    .rst (local_rst),
    .en  (sftint_b0_en[2]),
    .se  (se),
    .si  (),          
    .so  ()
);

dffre dffre_sftint2_b15 (
    .din (sftint_b15_din[2]), 
    .q   (sftint2[15]),
    .clk (clk),
    .rst (local_rst),
    .en  (sftint_b15_en[2]),
    .se  (se),
    .si  (),          
    .so  ()
);

dffre dffre_sftint2_b16 (
    .din (sftint_b16_din[2]), 
    .q   (sftint2[16]),
    .clk (clk),
    .rst (local_rst),
    .en  (sftint_b16_en[2]),
    .se  (se),
    .si  (),          
    .so  ()
);
//
// thread 3

dffre #(14) sftint3ff (
    .din (sftint_din[14:1]), 
    .q   (sftint3[14:1]),
    .en (~(tlu_sftint_en_l_g[3])), .clk(clk),
    .rst (local_rst),
    .se  (se),       
    .si  (),          
    .so  ()
);












dffre dffre_sftint3_b0 (
    .din (sftint_b0_din[3]), 
    .q   (sftint3[0]),
    .clk (clk),
    .rst (local_rst),
    .en  (sftint_b0_en[3]),
    .se  (se),
    .si  (),          
    .so  ()
);

dffre dffre_sftint3_b15 (
    .din (sftint_b15_din[3]), 
    .q   (sftint3[15]),
    .clk (clk),
    .rst (local_rst),
    .en  (sftint_b15_en[3]),
    .se  (se),
    .si  (),          
    .so  ()
);

dffre dffre_sftint3_b16 (
    .din (sftint_b16_din[3]), 
    .q   (sftint3[16]),
    .clk (clk),
    .rst (local_rst),
    .en  (sftint_b16_en[3]),
    .se  (se),
    .si  (),          
    .so  ()
);
// 
// Datapath priority encoder.
assign sftint_lvl14[0] = 
           sftint0[0] | sftint0[16] | 
           sftint0[14];
assign sftint_lvl14[1] = 
           sftint1[0] | sftint1[16] | 
           sftint1[14];
assign sftint_lvl14[2] = 
           sftint2[0] | sftint2[16] | 
           sftint2[14];
assign sftint_lvl14[3] = 
           sftint3[0] | sftint3[16] | 
           sftint3[14];
//
// modified to ensure one-hot mux check




   
mux4ds #(17-2) mx_sftint_penc_din (
    .in0  ({sftint0[15],sftint_lvl14[0],sftint0[13:1]}),
    .in1  ({sftint1[15],sftint_lvl14[1],sftint1[13:1]}),
    .in2  ({sftint2[15],sftint_lvl14[2],sftint2[13:1]}),
    .in3  ({sftint3[15],sftint_lvl14[3],sftint3[13:1]}),
    .sel0 (tlu_sftint_penc_sel[0]),
    .sel1 (tlu_sftint_penc_sel[1]),
    .sel2 (tlu_sftint_penc_sel[2]),
    .sel3 (tlu_sftint_penc_sel[3]),
    .dout (sftint_penc_din[14:0])
);
 // !`ifdef FPGA_SYN_1THREAD
   
tlu_prencoder16	prencoder16 (
			.din	(sftint_penc_din[14:0]),
			.dout	(tlu_sftint_id[3:0])
		);

//wire	[15:0]	sftint_rdata;
//
// modified for hypervisor support
// adding the SM bit
wire [17-1:0]	sftint_rdata;
// modified due to spec change
/*
mux4ds #(`SFTINT_WIDTH) sftint_mx_rsel (
    .in0  ({tlu_stick_int[0],sftint0[15:1],tlu_tick_int[0]}),
    .in1  ({tlu_stick_int[1],sftint1[15:1],tlu_tick_int[1]}),
    .in2  ({tlu_stick_int[2],sftint2[15:1],tlu_tick_int[2]}),
    .in3  ({tlu_stick_int[3],sftint3[15:1],tlu_tick_int[3]}),
    .sel0 (tlu_thrd_rsel_e[0]),
    .sel1 (tlu_thrd_rsel_e[1]),
    .sel2 (tlu_thrd_rsel_e[2]),
    .sel3 (tlu_thrd_rsel_e[3]),
    .dout (sftint_rdata[16:0])
);
*/



   
mux4ds #(17) sftint_mx_rsel (
    .in0  (sftint0[17-1:0]),
    .in1  (sftint1[17-1:0]),
    .in2  (sftint2[17-1:0]),
    .in3  (sftint3[17-1:0]),
    .sel0 (tlu_thrd_rsel_e[0]),
    .sel1 (tlu_thrd_rsel_e[1]),
    .sel2 (tlu_thrd_rsel_e[2]),
    .sel3 (tlu_thrd_rsel_e[3]),
    .dout (sftint_rdata[16:0])
);
 // !`ifdef FPGA_SYN_1THREAD
   
//=========================================================================================
//	TBA for Threads
//=========================================================================================

// Lower 15 bits are read as zero and ignored when written.









































// THREAD0


dffe #(33) tba0 (
    .din (tlu_wsr_data_w[47:15]), 
    .q   (true_tba0[32:0]),
    .en (~(tlu_tba_en_l[0])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// THREAD1


dffe #(33) tba1 (
    .din (tlu_wsr_data_w[47:15]), 
    .q  (true_tba1[32:0]),
    .en (~(tlu_tba_en_l[1])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// THREAD2


dffe #(33) tba2 (
    .din (tlu_wsr_data_w[47:15]), 
    .q   (true_tba2[32:0]),
    .en (~(tlu_tba_en_l[2])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// THREAD3


dffe #(33) tba3 (
    .din (tlu_wsr_data_w[47:15]), 
    .q  (true_tba3[32:0]),
    .en (~(tlu_tba_en_l[3])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// tba_data is for traps specifically
// modified for timing 






   
mux4ds #(33) mux_tba_data (
       .in0  (true_tba0[32:0]),
       .in1  (true_tba1[32:0]),
       .in2  (true_tba2[32:0]),
       .in3  (true_tba3[32:0]),
       .sel0 (tlu_thrd_wsel_w2[0]),
       .sel1 (tlu_thrd_wsel_w2[1]),
       .sel2 (tlu_thrd_wsel_w2[2]),
       .sel3 (tlu_thrd_wsel_w2[3]),
       .dout (tba_data[32:0])
);
   
/*
mux4ds #(33) tba_mx (
       .in0  (true_tba0[32:0]),
       .in1  (true_tba1[32:0]),
       .in2  (true_tba2[32:0]),
       .in3  (true_tba3[32:0]),
       .sel0 (tlu_thrd_rsel_g[0]),
       .sel1 (tlu_thrd_rsel_g[1]),
       .sel2 (tlu_thrd_rsel_g[2]),
       .sel3 (tlu_thrd_rsel_g[3]),
       .dout (tba_data[32:0])
);
*/
// tba_rdata is for read of tba regs specifically.
mux4ds #(33) tba_mx_rsel (
       .in0  (true_tba0[32:0]),
       .in1  (true_tba1[32:0]),
       .in2  (true_tba2[32:0]),
       .in3  (true_tba3[32:0]),
       .sel0 (tlu_thrd_rsel_e[0]),
       .sel1 (tlu_thrd_rsel_e[1]),
       .sel2 (tlu_thrd_rsel_e[2]),
       .sel3 (tlu_thrd_rsel_e[3]),
       .dout (tba_rdata[32:0])
); 
 // !`ifdef FPGA_SYN_1THREAD

// added for hypervisor support
//
// HTBA write - constructing clocks  







































//
// HTBA write - writing the registers
// lower 14 bits of HTBA are reserved, therefore, not stored
//
// Thread 0

dffe #(34) dff_true_htba0 (
    .din (tlu_wsr_data_w[47:14]), 
    .q   (true_htba0[34-1:0]),
    .en (~(tlu_htba_en_l[0])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);










//
// Thread 1

dffe #(34) dff_true_htba1 (
    .din (tlu_wsr_data_w[47:14]), 
    .q   (true_htba1[34-1:0]),
    .en (~(tlu_htba_en_l[1])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);










//
// Thread 2

dffe #(34) dff_true_htba2 (
    .din (tlu_wsr_data_w[47:14]), 
    .q   (true_htba2[34-1:0]),
    .en (~(tlu_htba_en_l[2])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);










//
// Thread 3

dffe #(34) dff_true_htba3 (
    .din (tlu_wsr_data_w[47:14]), 
    .q   (true_htba3[34-1:0]),
    .en (~(tlu_htba_en_l[3])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);










//
// constructing the rdata for HTBA
wire [34-1:0] htba_rdata;





   
mux4ds #(34) mux_htba_rdata (
       .in0  (true_htba0[34-1:0]),
       .in1  (true_htba1[34-1:0]),
       .in2  (true_htba2[34-1:0]),
       .in3  (true_htba3[34-1:0]),
       .sel0 (tlu_thrd_rsel_e[0]),
       .sel1 (tlu_thrd_rsel_e[1]),
       .sel2 (tlu_thrd_rsel_e[2]),
       .sel3 (tlu_thrd_rsel_e[3]),
       .dout (htba_rdata[34-1:0])
);
//
// selecting the htba base address to use 
// modified for timing
mux4ds #(34) mux_htba_data (
       .in0  (true_htba0[34-1:0]),
       .in1  (true_htba1[34-1:0]),
       .in2  (true_htba2[34-1:0]),
       .in3  (true_htba3[34-1:0]),
       .sel0 (tlu_thrd_wsel_w2[0]),
       .sel1 (tlu_thrd_wsel_w2[1]),
       .sel2 (tlu_thrd_wsel_w2[2]),
       .sel3 (tlu_thrd_wsel_w2[3]),
       .dout (htba_data[34-1:0])
);
 // !`ifdef FPGA_SYN_1THREAD
   
/*
mux4ds #(`TLU_HTBA_WIDTH) mux_htba_data (
       .in0  (true_htba0[`TLU_HTBA_WIDTH-1:0]),
       .in1  (true_htba1[`TLU_HTBA_WIDTH-1:0]),
       .in2  (true_htba2[`TLU_HTBA_WIDTH-1:0]),
       .in3  (true_htba3[`TLU_HTBA_WIDTH-1:0]),
       .sel0 (tlu_thrd_rsel_g[0]),
       .sel1 (tlu_thrd_rsel_g[1]),
       .sel2 (tlu_thrd_rsel_g[2]),
       .sel3 (tlu_thrd_rsel_g[3]),
       .dout (htba_data[`TLU_HTBA_WIDTH-1:0])
);
*/
//=========================================================================================
//	TICKS for Threads
//=========================================================================================

// npt needs to be muxed into read !!!


// THREAD0,1,2,3

mux2ds #(61) tick_sel (
       .in0  (tlu_wsr_data_w[62:2]), 	
	   .in1  (tlu_tick_incr_dout[60:0]),
       .sel0 (~tlu_tick_en_l),  	
	   .sel1 ( tlu_tick_en_l),
       .dout (tick_din[62:2])
); 
// 
// modified due to the switch to the soft macro
// assign	tlu_tick_incr_din[`TLU_ASR_DATA_WIDTH-1:0] = 
//         {3'b000,true_tick[60:0]};
assign	tlu_tick_incr_din[64-3:0] = 
         {1'b0,true_tick[60:0]};

// Does not need enable as either in increment or update state
dff #(61) tick0123 (
    .din (tick_din[62:2]), 
    .q  (true_tick[60:0]),
    .clk (clk),
    .se  (se),       
    .si (),          
    .so ()
);

//=========================================================================================
//	TICK COMPARE  for Threads
//=========================================================================================









































// thread 0
// added or modified due to tickcmp clean-up
assign tickcmp_intdis_din[0] = 
           tlu_wsr_data_w[63] | local_rst | 
           tlu_por_rstint_g[0];
// added and modified for bug 4763
assign tickcmp_intdis_en[0] = 
           ~tlu_tickcmp_en_l[0] | local_rst | tlu_por_rstint_g[0];  

dffe dffe_tickcmp_intdis0 (
    .din (tickcmp_intdis_din[0]),
	.q   (true_tickcmp0[63]),
    .en  (tickcmp_intdis_en[0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);


dffe #(64-1) tickcmp0 (
    .din (tlu_wsr_data_w[64-2:0]),
	.q   (true_tickcmp0[64-2:0]),
    .en (~(tlu_tickcmp_en_l[0])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// thread 1
// added or modified due to tickcmp clean-up
assign tickcmp_intdis_din[1] = 
           tlu_wsr_data_w[63] | local_rst | 
           tlu_por_rstint_g[1];
// added and modified for bug 4763
assign tickcmp_intdis_en[1] = 
           ~tlu_tickcmp_en_l[1] | local_rst | tlu_por_rstint_g[1];  

dffe dffe_tickcmp_intdis1 (
    .din (tickcmp_intdis_din[1]),
	.q   (true_tickcmp1[63]),
    .en  (tickcmp_intdis_en[1]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);


dffe #(64-1) tickcmp1 (
    .din (tlu_wsr_data_w[64-2:0]),
	.q   (true_tickcmp1[64-2:0]),
    .en (~(tlu_tickcmp_en_l[1])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// thread 2
// added or modified due to tickcmp clean-up
assign tickcmp_intdis_din[2] = 
           tlu_wsr_data_w[63] | local_rst | 
           tlu_por_rstint_g[2];
// added and modified for bug 4763
assign tickcmp_intdis_en[2] = 
           ~tlu_tickcmp_en_l[2] | local_rst | tlu_por_rstint_g[2];  

dffe dffe_tickcmp_intdis2 (
    .din (tickcmp_intdis_din[2]),
	.q   (true_tickcmp2[63]),
    .en  (tickcmp_intdis_en[2]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);


dffe #(64-1) tickcmp2 (
    .din (tlu_wsr_data_w[64-2:0]),
	.q   (true_tickcmp2[64-2:0]),
    .en (~(tlu_tickcmp_en_l[2])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// thread 3
// added or modified due to tickcmp clean-up
assign tickcmp_intdis_din[3] = 
           tlu_wsr_data_w[63] | local_rst | 
           tlu_por_rstint_g[3];
// added and modified for bug 4763
assign tickcmp_intdis_en[3] = 
           ~tlu_tickcmp_en_l[3] | local_rst | tlu_por_rstint_g[3];  

dffe dffe_tickcmp_intdis3 (
    .din (tickcmp_intdis_din[3]),
	.q   (true_tickcmp3[63]),
    .en  (tickcmp_intdis_en[3]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);


dffe #(64-1) tickcmp3 (
    .din (tlu_wsr_data_w[64-2:0]),
	.q   (true_tickcmp3[64-2:0]),
    .en (~(tlu_tickcmp_en_l[3])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// Select 1/4 sources. Assume compare is independent of read
// and thus needs separate mux




   
mux4ds #(64-3) tcmp_mx_sel (
       .in0  (true_tickcmp0[64-2:2]),
       .in1  (true_tickcmp1[64-2:2]),
       .in2  (true_tickcmp2[64-2:2]),
       .in3  (true_tickcmp3[64-2:2]),
       .sel0 (tlu_tickcmp_sel[0]),
       .sel1 (tlu_tickcmp_sel[1]),
       .sel2 (tlu_tickcmp_sel[2]),
       .sel3 (tlu_tickcmp_sel[3]),
       .dout (tickcmp_data[64-4:0])
);

// mux for read
mux4ds #(64) tcmp_mx_rsel (
       .in0  (true_tickcmp0[64-1:0]),
       .in1  (true_tickcmp1[64-1:0]),
       .in2  (true_tickcmp2[64-1:0]),
       .in3  (true_tickcmp3[64-1:0]),
       .sel0 (tlu_thrd_rsel_e[0]),
       .sel1 (tlu_thrd_rsel_e[1]),
       .sel2 (tlu_thrd_rsel_e[2]),
       .sel3 (tlu_thrd_rsel_e[3]),
       .dout (tickcmp_rdata[64-1:0])
);
 // !`ifdef FPGA_SYN_1THREAD
   
//
// evaluate for tickcmp match
assign tick_match = 
           (tickcmp_data[60:0] == 
            true_tick[60:0]);
//
// moved from tlu_tcl
assign	tickcmp_int[0] = 
            tick_match & ~true_tickcmp0[63] & tlu_tickcmp_sel[0];  
assign	tickcmp_int[1] = 
            tick_match & ~true_tickcmp1[63] & tlu_tickcmp_sel[1];
assign	tickcmp_int[2] = 
            tick_match & ~true_tickcmp2[63] & tlu_tickcmp_sel[2];
assign	tickcmp_int[3] = 
            tick_match & ~true_tickcmp3[63] & tlu_tickcmp_sel[3];

//=========================================================================================
//	STICK COMPARE  for Threads
//=========================================================================================
// added for hypervisor support









































// thread 0
// added or modified due to stickcmp clean-up
assign stickcmp_intdis_din[0] = tickcmp_intdis_din[0]; 
// added and modified for bug 4763
assign stickcmp_intdis_en[0] = 
           ~tlu_stickcmp_en_l[0] | local_rst | tlu_por_rstint_g[0];  

dffe dffe_stickcmp_intdis0 (
    .din (stickcmp_intdis_din[0]),
	.q   (true_stickcmp0[63]),
    .en  (stickcmp_intdis_en[0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);


dffe #(64-1) stickcmp0 (
    .din (tlu_wsr_data_w[64-2:0]),
	.q   (true_stickcmp0[64-2:0]),
    .en (~(tlu_stickcmp_en_l[0])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// thread 1
// added or modified due to stickcmp clean-up
assign stickcmp_intdis_din[1] = tickcmp_intdis_din[1]; 
// added and modified for bug 4763
assign stickcmp_intdis_en[1] = 
           ~tlu_stickcmp_en_l[1] | local_rst | tlu_por_rstint_g[1];  

dffe dffe_stickcmp_intdis1 (
    .din (stickcmp_intdis_din[1]),
	.q   (true_stickcmp1[63]),
    .en  (stickcmp_intdis_en[1]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);


dffe #(64-1) stickcmp1 (
    .din (tlu_wsr_data_w[64-2:0]),
	.q   (true_stickcmp1[64-2:0]),
    .en (~(tlu_stickcmp_en_l[1])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// thread 2
// added or modified due to stickcmp clean-up
assign stickcmp_intdis_din[2] = tickcmp_intdis_din[2]; 
// added for bug 4763
assign stickcmp_intdis_en[2] = 
           ~tlu_stickcmp_en_l[2] | local_rst | tlu_por_rstint_g[2];  

dffe dffe_stickcmp_intdis2 (
    .din (stickcmp_intdis_din[2]),
	.q   (true_stickcmp2[63]),
    .en  (stickcmp_intdis_en[2]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);


dffe #(64-1) stickcmp2 (
    .din (tlu_wsr_data_w[64-2:0]),
	.q   (true_stickcmp2[64-2:0]),
    .en (~(tlu_stickcmp_en_l[2])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// thread 3
// added or modified due to stickcmp clean-up
assign stickcmp_intdis_din[3] = tickcmp_intdis_din[3]; 
// added and modified for bug 4763
assign stickcmp_intdis_en[3] = 
           ~tlu_stickcmp_en_l[3] | local_rst | tlu_por_rstint_g[3];  

dffe dffe_stickcmp_intdis3 (
    .din (stickcmp_intdis_din[3]),
	.q   (true_stickcmp3[63]),
    .en  (stickcmp_intdis_en[3]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);


dffe #(64-1) stickcmp3 (
    .din (tlu_wsr_data_w[64-2:0]),
	.q   (true_stickcmp3[64-2:0]),
    .en (~(tlu_stickcmp_en_l[3])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);









 // !`ifdef FPGA_SYN_CLK_DFF
   
// Select 1/4 sources. Assume compare is independent of read
// and thus needs separate mux





   
mux4ds #(64-3) mux_stickcmp_data (
       .in0  (true_stickcmp0[64-2:2]),
       .in1  (true_stickcmp1[64-2:2]),
       .in2  (true_stickcmp2[64-2:2]),
       .in3  (true_stickcmp3[64-2:2]),
       .sel0 (tlu_tickcmp_sel[0]),
       .sel1 (tlu_tickcmp_sel[1]),
       .sel2 (tlu_tickcmp_sel[2]),
       .sel3 (tlu_tickcmp_sel[3]),
       .dout (stickcmp_data[64-4:0])
);
//
// mux for read
mux4ds #(64) mux_stickcmp_rdata (
       .in0  (true_stickcmp0[64-1:0]),
       .in1  (true_stickcmp1[64-1:0]),
       .in2  (true_stickcmp2[64-1:0]),
       .in3  (true_stickcmp3[64-1:0]),
       .sel0 (tlu_thrd_rsel_e[0]),
       .sel1 (tlu_thrd_rsel_e[1]),
       .sel2 (tlu_thrd_rsel_e[2]),
       .sel3 (tlu_thrd_rsel_e[3]),
       .dout (stickcmp_rdata[64-1:0])
);
 // !`ifdef FPGA_SYN_1THREAD
   
//
// evaluate for stickcmp match
assign stick_match = 
           (stickcmp_data[60:0] == 
            true_tick[60:0]);
//
// moved from tlu_tcl
assign	stickcmp_int[0] = 
            stick_match & ~true_stickcmp0[63] & tlu_tickcmp_sel[0];  
assign	stickcmp_int[1] = 
            stick_match & ~true_stickcmp1[63] & tlu_tickcmp_sel[1];
assign	stickcmp_int[2] = 
            stick_match & ~true_stickcmp2[63] & tlu_tickcmp_sel[2];
assign	stickcmp_int[3] = 
            stick_match & ~true_stickcmp3[63] & tlu_tickcmp_sel[3];

//=========================================================================================
//	HTICK COMPARE  for Threads
//=========================================================================================
// added for hypervisor support








































   
// THREAD0

dffe #(64-1) htickcmp0 (
    .din (tlu_wsr_data_w[64-2:0]),
	.q   (true_htickcmp0[64-2:0]),
    .en (~(tlu_htickcmp_en_l[0])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// THREAD1

dffe #(64-1) htickcmp1 (
    .din (tlu_wsr_data_w[64-2:0]),
	.q   (true_htickcmp1[64-2:0]),
    .en (~(tlu_htickcmp_en_l[1])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// THREAD2

dffe #(64-1) htickcmp2 (
    .din (tlu_wsr_data_w[64-2:0]),
	.q   (true_htickcmp2[64-2:0]),
    .en (~(tlu_htickcmp_en_l[2])), .clk(clk),
    .se  (se),
    .si  (),
    .so  ()
);











// THREAD3

dffe #(64-1) htickcmp3 (
    .din (tlu_wsr_data_w[64-2:0]),
	.q   (true_htickcmp3[64-2:0]),
    .en (~(tlu_htickcmp_en_l[3])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);












// Select 1/4 sources. Assume compare is independent of read
// and thus needs separate mux




   
mux4ds #(64-3) mux_htickcmp_data (
       .in0  (true_htickcmp0[64-2:2]),
       .in1  (true_htickcmp1[64-2:2]),
       .in2  (true_htickcmp2[64-2:2]),
       .in3  (true_htickcmp3[64-2:2]),
       .sel0 (tlu_tickcmp_sel[0]),
       .sel1 (tlu_tickcmp_sel[1]),
       .sel2 (tlu_tickcmp_sel[2]),
       .sel3 (tlu_tickcmp_sel[3]),
       .dout (htickcmp_data[64-4:0])
);
//
// mux for read
mux4ds #(64-1) mux_htickcmp_rdata (
       .in0  (true_htickcmp0[64-2:0]),
       .in1  (true_htickcmp1[64-2:0]),
       .in2  (true_htickcmp2[64-2:0]),
       .in3  (true_htickcmp3[64-2:0]),
       .sel0 (tlu_thrd_rsel_e[0]),
       .sel1 (tlu_thrd_rsel_e[1]),
       .sel2 (tlu_thrd_rsel_e[2]),
       .sel3 (tlu_thrd_rsel_e[3]),
       .dout (htickcmp_rdata[64-2:0])
);
 // !`ifdef FPGA_SYN_1THREAD
   
//
// evaluate for htickcmp match
assign tlu_htick_match = 
           (htickcmp_data[60:0] == 
            true_tick[60:0]);
//
//=========================================================================================
// HINTP REG for Threads
//=========================================================================================
// added for hypervisor support
// modified for timing
// creating clocks for accessing the hintp regs
assign tlu_hintp_en_l_g[0] = 
           ~(tlu_set_hintp_g[0] | tlu_wr_hintp_g[0]); 
assign tlu_hintp_en_l_g[1] = 
           ~(tlu_set_hintp_g[1] | tlu_wr_hintp_g[1]); 
assign tlu_hintp_en_l_g[2] = 
           ~(tlu_set_hintp_g[2] | tlu_wr_hintp_g[2]); 
assign tlu_hintp_en_l_g[3] = 
           ~(tlu_set_hintp_g[3] | tlu_wr_hintp_g[3]); 








































// 
// setting the value of hintp registers
//
// Thread 0
// added for timing
assign tlu_set_hintp_g[0] = 
           tlu_set_hintp_sel_g[0] & tlu_htick_match;

// modified to reflect the physical implementation
// assign hintp_din[0] = 
//            (tlu_set_hintp_g[0])? tlu_set_hintp_g[0]: wsr_data_w[0]; 

mux2ds mx_hintp_din_0 (
       .in0  (tlu_set_hintp_g[0]),
	   .in1  (wsr_data_w[0]),
       .sel0 (tlu_set_hintp_g[0]),  	
	   .sel1 (~tlu_set_hintp_g[0]),
       .dout (hintp_din[0])
); 


dffre dffr_hintp0 (
     .din (hintp_din[0]), 
     .q   (tlu_hintp[0]),
     .en (~(tlu_hintp_en_l_g[0])), .clk(clk),
	 .rst (local_rst),
     .se  (se),
     .si  (),
     .so  ()
);












// Thread 1
// added for timing
assign tlu_set_hintp_g[1] = 
           tlu_set_hintp_sel_g[1] & tlu_htick_match;

// modified to reflect the physical implementation
// assign hintp_din[1] = 
//            (tlu_set_hintp_g[1])? tlu_set_hintp_g[1]: wsr_data_w[0]; 

mux2ds mx_hintp_din_1 (
       .in0  (tlu_set_hintp_g[1]),
	   .in1  (wsr_data_w[0]),
       .sel0 (tlu_set_hintp_g[1]),  	
	   .sel1 (~tlu_set_hintp_g[1]),
       .dout (hintp_din[1])
); 


dffre dffr_hintp1 (
     .din (hintp_din[1]), 
     .q   (tlu_hintp[1]),
     .en (~(tlu_hintp_en_l_g[1])), .clk(clk),
	 .rst (local_rst),
     .se  (se),
     .si  (),
     .so  ()
);












// Thread 2
// added for timing
assign tlu_set_hintp_g[2] = 
           tlu_set_hintp_sel_g[2] & tlu_htick_match;

// modified to reflect the physical implementation
// assign hintp_din[2] = 
//            (tlu_set_hintp_g[2])? tlu_set_hintp_g[2]: wsr_data_w[0]; 

mux2ds mx_hintp_din_2 (
       .in0  (tlu_set_hintp_g[2]),
	   .in1  (wsr_data_w[0]),
       .sel0 (tlu_set_hintp_g[2]),  	
	   .sel1 (~tlu_set_hintp_g[2]),
       .dout (hintp_din[2])
); 


dffre dffr_hintp2 (
     .din (hintp_din[2]), 
     .q   (tlu_hintp[2]),
     .en (~(tlu_hintp_en_l_g[2])), .clk(clk),
	 .rst (local_rst),
     .se  (se),
     .si  (),
     .so  ()
);












// Thread 3
// added for timing
assign tlu_set_hintp_g[3] = 
           tlu_set_hintp_sel_g[3] & tlu_htick_match;

// modified to reflect the physical implementation
// assign hintp_din[3] = 
//            (tlu_set_hintp_g[3])? tlu_set_hintp_g[3]: wsr_data_w[0]; 

mux2ds mx_hintp_din_3 (
       .in0  (tlu_set_hintp_g[3]),
	   .in1  (wsr_data_w[0]),
       .sel0 (tlu_set_hintp_g[3]),  	
	   .sel1 (~tlu_set_hintp_g[3]),
       .dout (hintp_din[3])
); 


dffre dffr_hintp3 (
     .din (hintp_din[3]), 
     .q   (tlu_hintp[3]),
     .en (~(tlu_hintp_en_l_g[3])), .clk(clk),
	 .rst (local_rst),
     .se  (se),
     .si  (),
     .so  ()
);












//=========================================================================================
//	DONE/RETRY 
//=========================================================================================

// PC/nPC will be updated by pc/npc from IFU,
// OR, Done/Retry which reads TSA in E stage. Execution of Done/Retry will
// put pc/npc temporarily in bypass flop which will then update actual pc/npc
// in g. Update of pc/npc by inst_in_w or done/retry thus becomes aligned.
// recoded due to lint violations - individualized the components
/*
dff #(`TLU_TSA_WIDTH) poptsa_m (
    .din (tsa_rdata[`TLU_TSA_WIDTH-1:0]), 
	.q   (tsa_data_m[`TLU_TSA_WIDTH-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// added, modified for hypervisor and timing 
assign dnrtry_pstate_m = 
       {2'b0,  // old IG, MG - replaced by global register
        tsa_data_m[`TSA_PSTATE_VRANGE2_HI:`TSA_PSTATE_VRANGE2_LO],
        2'b0,  // memory model has been change to TSO only - bug 2588
        1'b0,  // old RED - replaced by hpstate.red
        tsa_data_m[`TSA_PSTATE_VRANGE1_HI:`TSA_PSTATE_VRANGE1_LO],
        1'b0}; // old AG - replaced by global register 
        
dff #(12) dff_pstate_g (
    .din (dnrtry_pstate_m[`PSTATE_TRUE_WIDTH-1:0]),
	.q   (dnrtry_pstate[`PSTATE_TRUE_WIDTH-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
    );
*/
// recoded due to lint violation

dff #(6) dff_dnrtry_pstate_m (
    .din ({tsa_rdata[19:18],
           tsa_rdata[15:12]}),
	.q   (dnrtry_pstate_m[6-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
        
dff #(6) dff_pstate_g (
    .din (dnrtry_pstate_m[6-1:0]),
	.q   (dnrtry_pstate_g[6-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff #(6) dff_pstate_w2 (
    .din (dnrtry_pstate_g[6-1:0]),
	.q   (dnrtry_pstate_w2[6-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
// assign dnrtry_pstate_m[`WSR_PSTATE_VR_WIDTH-1:0] = 
//        {tsa_data_m[`TSA_PSTATE_VRANGE2_HI:`TSA_PSTATE_VRANGE2_LO],
//         tsa_data_m[`TSA_PSTATE_VRANGE1_HI:`TSA_PSTATE_VRANGE1_LO]}; 
// 
// reading hpstate from tsa for recovery
// recoded due to lint violations

dff #(4) dff_tsa_dnrtry_hpstate_m (
    // .din (tsa_rdata[`TLU_HTSTATE_HI:`TLU_HTSTATE_LO]), 
    .din (tsa_rdata[133:130]), 
	.q   (tsa_dnrtry_hpstate_m[4-1:0]),
    .clk (clk),
    .se  (se),
    .si  (),          
    .so  ()
);

dff #(4) dff_tsa_dnrtry_hpstate_g (
//     .din (tsa_data_m[`TLU_HTSTATE_HI:`TLU_HTSTATE_LO]),
    .din (tsa_dnrtry_hpstate_m[4-1:0]),
	.q   (tsa_dnrtry_hpstate_g[4-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
// 
// added for timing
dff #(4) dff_tsa_dnrtry_hpstate_w2 (
    .din (tsa_dnrtry_hpstate_g[4-1:0]),
	.q   (tsa_dnrtry_hpstate_w2[4-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

// reading value of original global registers from tsa for recovery
// recoded due to lint cleanup
// assign dnrtry_global_m = tsa_data_m[`TLU_GL_HI:`TLU_GL_LO];

dff #(2) dff_dnrtry_global_m (
    .din (tsa_rdata[37:36]),
	.q   (dnrtry_global_m[2-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff #(2) dff_global_g (
    .din (dnrtry_global_m[2-1:0]),
	.q   (tlu_dnrtry_global_g[2-1:0]),
    .clk (clk),
    .se  (se), 
    .si  (),    
    .so  ()
);
//
/* logic moved to tlu_misctl
// added due to lint violations
dff #(47) dff_tsa_pc_m (
    .din (tsa_rdata[`TLU_PC_HI:`TLU_PC_LO]),
	.q   (tsa_pc_m[46:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff #(47) dff_tsa_npc_m (
    .din (tsa_rdata[`TLU_NPC_HI:`TLU_NPC_LO]),
	.q   (tsa_npc_m[46:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

// pstate may have to be staged by an additional cycle.
assign dnrtry_pc[48:0]  = {tsa_pc_m[46:0],2'b00};
assign dnrtry_npc[48:0] = {tsa_npc_m[46:0],2'b00};
*/

//=========================================================================================
//	PC/nPC
//=========================================================================================

// TRUE PC/NPC. AN INSTRUCTION'S PC/NPC IS VISIBLE IN W2.
// F:S:D:E:M:G:W2
// Modified by Done/Retry and inst

/* logic moved to tlu_misctl
// On done, npc will become pc. 
// modified due to bug 3017 
// pc width increase from 48 -> 49 bits
mux3ds #(49) finalpc_sel_m (
       .in0  (dnrtry_pc[48:0]), 	
	   .in1  (dnrtry_npc[48:0]),
	   .in2  (ifu_tlu_pc_m[48:0]),
       .sel0 (tlu_retry_inst_m),  	
	   .sel1 (tlu_done_inst_m),
	   .sel2 (tlu_dnrtry_inst_m_l),
       .dout (pc_new[48:0])
); 
// On done, npc will stay npc. The valid to the IFU will
// not be signaled along with npc for a done. 
// modified due to bug 3017 
// pc width increase from 48 -> 49 bits
mux2ds #(49) finalnpc_sel_m (
       .in0  (dnrtry_npc[48:0]), 	
       .in1  (ifu_tlu_npc_m[48:0]),
       .sel0 (~tlu_dnrtry_inst_m_l),  	
       .sel1 (tlu_dnrtry_inst_m_l),
       .dout (npc_new[48:0])
); 

dff #(49) dff_pc_new_w (
    .din (pc_new[48:0]), 	
    .q   (pc_new_w[48:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff #(49) dff_npc_new_w (
    .din (npc_new[48:0]), 	
    .q   (npc_new_w[48:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
*/
//






































	
//
// modified for bug 3017 
// all pc width has been increased from 48 -> 49 bits
// Thread 0
//

dffe #(49) pc0_true (
    .din (tlu_pc_new_w[48:0]), 
    .q   (true_pc0[48:0]),
    .en (~(tlu_update_pc_l_w[0])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// update_pc will be used for both pc and npc - in this case
// npc will contain gibberish but it's okay. 
// modified to avert area growth 

dffe #(49) npc0_true (
    .din (tlu_npc_new_w[48:0]), 	
    .q  (true_npc0[48:0]),
    .en (~(tlu_update_pc_l_w[0])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);










//
// THREAD1
//

dffe #(49) pc1_true (
    .din (tlu_pc_new_w[48:0]), 
    .q   (true_pc1[48:0]),
    .en (~(tlu_update_pc_l_w[1])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// update_pc will be used for both pc and npc - in this case
// npc will contain gibberish but it's okay. 

dffe #(49) npc1_true (
    .din (tlu_npc_new_w[48:0]), 	
    .q   (true_npc1[48:0]),
    .en (~(tlu_update_pc_l_w[1])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);










//
// THREAD2
//

dffe #(49) pc2_true (
    .din (tlu_pc_new_w[48:0]), 
    .q   (true_pc2[48:0]),
    .en (~(tlu_update_pc_l_w[2])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// update_pc will be used for both pc and npc - in this case
// npc will contain gibberish but it's okay. 

dffe #(49) npc2_true (
    .din (tlu_npc_new_w[48:0]), 	
    .q   (true_npc2[48:0]),
    .en (~(tlu_update_pc_l_w[2])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);










//
// THREAD3
//

dffe #(49) pc3_true (
    .din (tlu_pc_new_w[48:0]), 
    .q   (true_pc3[48:0]),
    .en (~(tlu_update_pc_l_w[3])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











// update_pc will be used for both pc and npc - in this case
// npc will contain gibberish but it's okay. 

dffe #(49) npc3_true (
    .din (tlu_npc_new_w[48:0]), 	
    .q   (true_npc3[48:0]),
    .en (~(tlu_update_pc_l_w[3])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











//=========================================================================================
//	Generating Trap Vector
//=========================================================================================
// 
// Normal Trap Processing.
mux2ds mux_pc_bit15_sel (
    .in0  (tlu_tl_gt_0_w2),
    .in1  (htba_data[0]),
    .sel0  (~tlu_trap_hpstate_enb),
    .sel1  (tlu_trap_hpstate_enb),
    .dout (pc_bit15_sel)
);
//
// modified to help speed up simulation time
//
assign tlu_rstvaddr_base[33:0] = 34'h3_ffff_c000;
mux3ds #(34) nrmlpc_sel_w2 (
       .in0  (tlu_rstvaddr_base[33:0]),
	   .in1  ({tba_data[32:0], tlu_tl_gt_0_w2}),
	   .in2  ({htba_data[33:1], pc_bit15_sel}),
       .sel0 (tlu_pc_mxsel_w2[0]),
	   .sel1 (tlu_pc_mxsel_w2[1]),
	   .sel2 (tlu_pc_mxsel_w2[2]),
       .dout (partial_trap_pc_w2[33:0])
);

assign tlu_partial_trap_pc_w1[33:0] = partial_trap_pc_w2[33:0]; 

// restore pc/npc select
// true pc muxed into restore pc; previously restore_pcx was muxed in.
// modified due to bug 3017




   
mux4ds  #(98) trprsel (
        .in0    ({true_pc0[48:0],true_npc0[48:0]}),
        .in1    ({true_pc1[48:0],true_npc1[48:0]}),
        .in2    ({true_pc2[48:0],true_npc2[48:0]}),
        .in3    ({true_pc3[48:0],true_npc3[48:0]}),
        .sel0   (tlu_thrd_wsel_w2[0]),
        .sel1   (tlu_thrd_wsel_w2[1]),
        .sel2   (tlu_thrd_wsel_w2[2]),
        .sel3   (tlu_thrd_wsel_w2[3]),
        .dout   ({restore_pc_w2[48:0],restore_npc_w2[48:0]})
);
 // !`ifdef FPGA_SYN_1THREAD
   
//
// the matching of the w1 and w2 is intentional
assign tlu_restore_pc_w1[48:0]  = restore_pc_w2[48:0];
assign tlu_restore_npc_w1[48:0] = restore_npc_w2[48:0];

//=========================================================================================
//	TAP PC OBSERVABILITY
//=========================================================================================
//
// modified due to spec change
// shadow scan 
// thread 0 data
assign sscan_data_test0[51-1:0] = 
           {true_hpstate0[2:0], 
            true_pstate0[2],
            true_pstate0[1],
            true_pc0[47:2]};
//
// thread 1 data
assign sscan_data_test1[51-1:0] = 
           {true_hpstate1[2:0], 
            true_pstate1[2],
            true_pstate1[1],
            true_pc1[47:2]};
//
// thread 2 data
assign sscan_data_test2[51-1:0] = 
           {true_hpstate2[2:0], 
            true_pstate2[2],
            true_pstate2[1],
            true_pc2[47:2]};
//
// thread 3 data
assign sscan_data_test3[51-1:0] = 
           {true_hpstate3[2:0], 
            true_pstate3[2],
            true_pstate3[1],
            true_pc3[47:2]};
//



   
mux4ds #(51) mx_sscan_test_data (
       .in0  (sscan_data_test0[51-1:0]),
       .in1  (sscan_data_test1[51-1:0]),
       .in2  (sscan_data_test2[51-1:0]),
       .in3  (sscan_data_test3[51-1:0]),
       .sel0 (sscan_tid_sel[0]),
       .sel1 (sscan_tid_sel[1]),
       .sel2 (sscan_tid_sel[2]),
       .sel3 (sscan_tid_sel[3]),
       .dout (tdp_sscan_test_data[51-1:0])
); 
 // !`ifdef FPGA_SYN_1THREAD
   
assign sscan_tid_sel[4-1:0] = ctu_sscan_tid[4-1:0]; 

assign tlu_sscan_test_data[51-1:0] =
          tdp_sscan_test_data[51-1:0]; 

//=========================================================================================
//	PSTATE for Threads
//=========================================================================================

// pstate needs to be updated on a trap. Assume for now that only non-RED state instruction
// related traps are handled.

// Normal traps, non-red mode.
assign pstate_priv_set = tlu_select_tba_w2 | local_rst | tlu_select_redmode;
//
assign pstate_priv_thrd_set[0] = pstate_priv_set | ~true_hpstate0[3];
assign pstate_priv_thrd_set[1] = pstate_priv_set | ~true_hpstate1[3];
assign pstate_priv_thrd_set[2] = pstate_priv_set | ~true_hpstate2[3];
assign pstate_priv_thrd_set[3] = pstate_priv_set | ~true_hpstate3[3];
//
// modified for bug 3349
assign pstate_priv_update_w2[0] = 
       ~(tlu_update_pstate_l_w2[0] & 
        (true_hpstate0[3] | tlu_update_hpstate_l_w2[0])) |
        (~wsr_data_w2[11] & tlu_hpstate_din_sel0[1]);
assign pstate_priv_update_w2[1] = 
       ~(tlu_update_pstate_l_w2[1] & 
        (true_hpstate1[3] | tlu_update_hpstate_l_w2[1])) |
        (~wsr_data_w2[11] & tlu_hpstate_din_sel1[1]);
assign pstate_priv_update_w2[2] = 
       ~(tlu_update_pstate_l_w2[2] & 
        (true_hpstate2[3] | tlu_update_hpstate_l_w2[2])) |
        (~wsr_data_w2[11] & tlu_hpstate_din_sel2[1]);
assign pstate_priv_update_w2[3] = 
       ~(tlu_update_pstate_l_w2[3] & 
        (true_hpstate3[3] | tlu_update_hpstate_l_w2[3])) |
        (~wsr_data_w2[11] & tlu_hpstate_din_sel3[1]);
//
assign hpstate_priv_update_w2[0] = 
       ~(tlu_update_hpstate_l_w2[0] & 
        (true_hpstate0[3] | tlu_update_pstate_l_w2[0]));
assign hpstate_priv_update_w2[1] = 
       ~(tlu_update_hpstate_l_w2[1] & 
        (true_hpstate1[3] | tlu_update_pstate_l_w2[1]));
assign hpstate_priv_update_w2[2] = 
       ~(tlu_update_hpstate_l_w2[2] & 
        (true_hpstate2[3] | tlu_update_pstate_l_w2[2]));
assign hpstate_priv_update_w2[3] = 
       ~(tlu_update_hpstate_l_w2[3] & 
        (true_hpstate3[3] | tlu_update_pstate_l_w2[3]));
//
// added for bug 2161 and modified for bug 2161
assign hpstate_enb_set[0] = true_hpstate0[3] & ~(local_rst | tlu_select_redmode); 
assign hpstate_enb_set[1] = true_hpstate1[3] & ~(local_rst | tlu_select_redmode); 
assign hpstate_enb_set[2] = true_hpstate2[3] & ~(local_rst | tlu_select_redmode);
assign hpstate_enb_set[3] = true_hpstate3[3] & ~(local_rst | tlu_select_redmode);

// added for hpstate.ibe ECO 
// modified due to timing - tlu_ibrkpt_trap_g has been delayed one stage to tlu_ibrkpt_trap_w2
assign hpstate_ibe_set[0] = 
           true_hpstate0[4] & ~(local_rst | tlu_select_redmode | tlu_ibrkpt_trap_w2);
assign hpstate_ibe_set[1] = 
           true_hpstate1[4] & ~(local_rst | tlu_select_redmode | tlu_ibrkpt_trap_w2);
assign hpstate_ibe_set[2] = 
           true_hpstate2[4] & ~(local_rst | tlu_select_redmode | tlu_ibrkpt_trap_w2);
assign hpstate_ibe_set[3] = 
           true_hpstate3[4] & ~(local_rst | tlu_select_redmode | tlu_ibrkpt_trap_w2);
//
// added due to TLZ spec change 
// modified for bug 3505
assign hpstate_tlz_set[0] = true_hpstate0[0] & ~(local_rst | tlu_select_redmode);
assign hpstate_tlz_set[1] = true_hpstate1[0] & ~(local_rst | tlu_select_redmode);
assign hpstate_tlz_set[2] = true_hpstate2[0] & ~(local_rst | tlu_select_redmode);
assign hpstate_tlz_set[3] = true_hpstate3[0] & ~(local_rst | tlu_select_redmode);
//
// thread 0
assign tlu_select_tle[0] =
           tlu_pstate_tle[0] & ~(tlu_select_redmode);
// modified for timing and bug 3417 
assign tlu_select_cle[0] =
           tlu_select_tle[0] & 
          (tlu_select_tba_w2 | ~true_hpstate0[3]); 
//         tlu_select_tle[0] & tlu_select_tba_w2; 
//
// modified for timing and width cleanup
/*
assign	ntrap_pstate0[`PSTATE_TRUE_WIDTH-1:0] = 
    {2'b0,  // tlu_select_int_global - replaced by gl register	
	        // tlu_select_mmu_global - replaced by gl register
	 tlu_select_cle[0], // cle<-tle, or 0	
	 tlu_select_tle[0], // keep old tle, or 0
     2'b0,
     1'b0,  // tlu_select_redmode - replaced by hpstate.red
	 1'b1,  // fp turned on
	 1'b0,  // address masking turned off
	 pstate_priv_thrd_set[0], // enter priv mode for priv traps
	 1'b0,  // interrupts disabled
	 1'b0}; // tlu_select_alt_global - replaced by gl register 
*/
assign	ntrap_pstate0[6-1:0] = 
    {tlu_select_cle[0], // cle<-tle, or 0	
	 tlu_select_tle[0], // keep old tle, or 0
	 1'b1,  // fp turned on
	 1'b0,  // address masking turned off
	 pstate_priv_thrd_set[0], // enter priv mode for priv traps
	 1'b0}; // interrupts disabled
//
// thread 1
assign tlu_select_tle[1] =
           tlu_pstate_tle[1] & ~(tlu_select_redmode);
// modified for timing and bug 3417 
assign tlu_select_cle[1] =
           tlu_select_tle[1] & 
          (tlu_select_tba_w2 | ~true_hpstate1[3]); 
//           tlu_select_tle[1] & tlu_select_tba_w2;
//
// modified due to timing
/*
assign	ntrap_pstate1[`PSTATE_TRUE_WIDTH-1:0] = 
    {2'b0,  // tlu_select_int_global - replaced by gl register	
	        // tlu_select_mmu_global - replaced by gl register
	 tlu_select_cle[1], // cle<-tle, or 0	
	 tlu_select_tle[1], // keep old tle, or 0
     2'b0,
     1'b0,  // tlu_select_redmode - replaced by hpstate.red
	 1'b1,  // fp turned on
	 1'b0,  // address masking turned off
	 pstate_priv_thrd_set[1], // enter priv mode for priv traps
	 1'b0,  // interrupts disabled
	 1'b0}; // tlu_select_alt_global - replaced by gl register 
*/
assign	ntrap_pstate1[6-1:0] = 
    {tlu_select_cle[1], // cle<-tle, or 0	
	 tlu_select_tle[1], // keep old tle, or 0
	 1'b1,  // fp turned on
	 1'b0,  // address masking turned off
	 pstate_priv_thrd_set[1], // enter priv mode for priv traps
	 1'b0}; // interrupts disabled// 
//
// thread 2
assign tlu_select_tle[2] =
           tlu_pstate_tle[2] & ~(tlu_select_redmode);
// modified for timing and bug 3417 
assign tlu_select_cle[2] =
           tlu_select_tle[2] & 
          (tlu_select_tba_w2 | ~true_hpstate2[3]); 
//           tlu_select_tle[2] & tlu_select_tba_w2; 
//
// modified for timing and width cleanup
/*
assign	ntrap_pstate2[`PSTATE_TRUE_WIDTH-1:0] = 
    {2'b0,  // tlu_select_int_global - replaced by gl register	
	        // tlu_select_mmu_global - replaced by gl register
	 tlu_select_cle[2], // cle<-tle, or 0	
	 tlu_select_tle[2], // keep old tle, or 0
     2'b0,
     1'b0,  // tlu_select_redmode - replaced by hpstate.red
	 1'b1,  // fp turned on
	 1'b0,  // address masking turned off
	 pstate_priv_thrd_set[2], // enter priv mode for priv traps
	 1'b0,  // interrupts disabled
	 1'b0}; // tlu_select_alt_global - replaced by gl register 
*/
assign	ntrap_pstate2[6-1:0] = 
    {tlu_select_cle[2], // cle<-tle, or 0	
	 tlu_select_tle[2], // keep old tle, or 0
	 1'b1,  // fp turned on
	 1'b0,  // address masking turned off
	 pstate_priv_thrd_set[2], // enter priv mode for priv traps
	 1'b0}; // interrupts disabled// 
//
// thread 3
assign tlu_select_tle[3] =
           tlu_pstate_tle[3] & ~(tlu_select_redmode);
// modified for timing and bug 3417 
assign tlu_select_cle[3] =
           tlu_select_tle[3] & 
          (tlu_select_tba_w2 | ~true_hpstate3[3]); 
//           tlu_select_tle[3] & tlu_select_tba_w2;
//
// modified for timing
/*
assign	ntrap_pstate3[`PSTATE_TRUE_WIDTH-1:0] = 
    {2'b0,  // tlu_select_int_global - replaced by gl register	
	        // tlu_select_mmu_global - replaced by gl register
	 tlu_select_cle[3], // cle<-tle, or 0	
	 tlu_select_tle[3], // keep old tle, or 0
     2'b0,
     1'b0,  // tlu_select_redmode - replaced by hpstate.red
	 1'b1,  // fp turned on
	 1'b0,  // address masking turned off
	 pstate_priv_thrd_set[3], // enter priv mode for priv traps
	 1'b0,  // interrupts disabled
	 1'b0}; // tlu_select_alt_global - replaced by gl register 
*/
assign	ntrap_pstate3[6-1:0] = 
    {tlu_select_cle[3], // cle<-tle, or 0	
	 tlu_select_tle[3], // keep old tle, or 0
	 1'b1,  // fp turned on
	 1'b0,  // address masking turned off
	 pstate_priv_thrd_set[3], // enter priv mode for priv traps
	 1'b0}; // interrupts disabled// 

// Clock Enable Buffers
//







































//
// added for hypervisor support 
// clock enable buffers for updating the hpstate registers
//







































// assign the initial value of hpstate.red mode
//
// modified for bug 1893
// assign hpstate_redmode = 
//            (local_rst)? 1'b1: tlu_select_redmode;
assign hpstate_redmode = 
           local_rst | (~local_rst & tlu_select_redmode); 
// 
// extracting hpstate from wsr_data
//
// modified for timing tlu_wsr_data_w -> wsr_data_w2
assign wsr_data_hpstate_w2[5-1:0] = 
     {wsr_data_w2[10],
      wsr_data_w2[11],
      wsr_data_w2[5],
      wsr_data_w2[2],
      wsr_data_w2[0]
     };
//
// added or modified for hypervisor support
// modified due to timing
/*
assign wsr_data_pstate_g[`PSTATE_TRUE_WIDTH-1:0] = 
    {2'b0,  // old IG, MG - replaced by global register
     tlu_wsr_data_w[`PSTATE_VRANGE2_HI:`PSTATE_VRANGE2_LO], 
     2'b0,  // memory model has been change to TSO only - bug 2588
     1'b0,  // old red, - replaced by hpstate.red 
     tlu_wsr_data_w[`PSTATE_VRANGE1_HI:`PSTATE_VRANGE1_LO], 
     1'b0};  // old AG - replaced by global register 

assign wsr_data_pstate_g[`WSR_PSTATE_VR_WIDTH-1:0] = 
       {tlu_wsr_data_w[`PSTATE_VRANGE2_HI:`PSTATE_VRANGE2_LO],
        tlu_wsr_data_w[`PSTATE_VRANGE1_HI:`PSTATE_VRANGE1_LO]};
*/
assign wsr_data_pstate_w2[6-1:0] = 
       {wsr_data_w2[9:8],
        wsr_data_w2[4:1]};
//
// THREAD0
// added for bug 1575
// modified for bug 2584
// assign tlu_pstate_nt_sel0 = ~|(tlu_pstate_din_sel0[1:0]);
assign tlu_pstate_nt_sel0 = 
          ~(tlu_pstate_din_sel0[0] | tlu_pstate_wsr_sel0);
// 
// modified for bug 3349
assign tlu_pstate_wsr_sel0 = 
           tlu_pstate_din_sel0[1] | 
           (~(true_hpstate0[3] & wsr_data_w2[11]) &
              tlu_hpstate_din_sel0[1]);
//            (~true_hpstate0[`HPSTATE_ENB] & tlu_hpstate_din_sel0[1]);

mux3ds #(6) mux_restore_pstate0(
       .in0  (dnrtry_pstate_w2[6-1:0]), 	
	   .in1  (wsr_data_pstate_w2[6-1:0]),
	   .in2  (ntrap_pstate0[6-1:0]),
       .sel0 (tlu_pstate_din_sel0[0]),  		
	   .sel1 (tlu_pstate_wsr_sel0),
	   .sel2 (tlu_pstate_nt_sel0),
       .dout (restore_pstate0[6-1:0])
);


dffe #(6-1) dff_restore_pstate0_w3 (
    .din ({restore_pstate0[5:3-1], 
           restore_pstate0[0]}), 
    .q   ({restore_pstate0_w3[5:3-1],
           restore_pstate0_w3[0]}),
    .en (~(tlu_update_pstate_l_w2[0])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);












//
dffe dffe_pstate0_priv (
    .din (restore_pstate0[1]),
    .q   (restore_pstate0_w3[1]),
    .en  (pstate_priv_update_w2[0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// true_pstate0 assignments
assign true_pstate0[12-1:0] = 
           {2'b0, // tlu_select_int_global - replaced by gl register
                  // tlu_select_mmu_global - replaced by gl register 
            restore_pstate0_w3[5:4],
            2'b0, // fixed mmodel - TSO
            1'b0, // redmode - replaced by hpstate.red
            restore_pstate0_w3[3:0],
            1'b0}; // tlu_select_alt_global - replaced by gl register 
//
// modified for timing
/*
mux3ds #(9) mux_restore_pstate0(
       .in0  (dnrtry_pstate[`PSTATE_TRUE_WIDTH-3:1]), 	
	   .in1  (wsr_data_pstate_g[`PSTATE_TRUE_WIDTH-3:1]),
	   .in2  (ntrap_pstate0[`PSTATE_TRUE_WIDTH-3:1]),
       .sel0 (tlu_pstate_din_sel0[0]),  		
       // modified for bug 2584
	   // .sel1 (tlu_pstate_din_sel0[1]),
	   .sel1 (tlu_pstate_wsr_sel0),
	   .sel2 (tlu_pstate_nt_sel0),
       .dout (restore_pstate0[`PSTATE_TRUE_WIDTH-3:1])
);

dff #(`PSTATE_TRUE_WIDTH) pstate0_1 (
    .din (restore_pstate0[`PSTATE_TRUE_WIDTH-1:0]), 
	.q   (true_pstate0[`PSTATE_TRUE_WIDTH-1:0]),
    .clk (pstate0_clk),
    .se  (se),       
    .si  (),          
    .so  ()
 );
//
dff #(`PSTATE_TRUE_WIDTH-1) dff_true_pstate0 (
    .din ({restore_pstate0[`PSTATE_TRUE_WIDTH-1:3], 
           restore_pstate0[1:0]}), 
    .q   ({true_pstate0[`PSTATE_TRUE_WIDTH-1:3], 
           true_pstate0[1:0]}), 
    .clk (pstate0_clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
dffe dffe_pstate0_priv (
    .din (restore_pstate0[`PSTATE_PRIV]),
    .q   (true_pstate0[`PSTATE_PRIV]),
    .en  (pstate_priv_update_g[0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
// modified for hypervisor support
assign restore_pstate0[11:10] = 2'b0;
assign restore_pstate0[0]     = 1'b0;
//
// modified to reflect the physical implementation
// assign hpstate_dnrtry_priv_w2[0] = 
           (true_hpstate0[`HPSTATE_ENB])? 
            tsa_dnrtry_hpstate_w2[`HPSTATE_PRIV] :
            dnrtry_pstate_w2[`WSR_PSTATE_VR_PRIV];
*/
mux2ds mx_hpstate_dnrtry_priv_w2_0 (
       .in0  (tsa_dnrtry_hpstate_w2[1]),
	   .in1  (dnrtry_pstate_w2[1]),
       .sel0 (true_hpstate0[3]),  	
	   .sel1 (~true_hpstate0[3]),
       .dout (hpstate_dnrtry_priv_w2[0])
); 
//
assign dnrtry_hpstate0_w2[5-1:0] = 
       {tsa_dnrtry_hpstate_w2[4-1],
        true_hpstate0[3],  
        tsa_dnrtry_hpstate_w2[2],
        hpstate_dnrtry_priv_w2[0],
        tsa_dnrtry_hpstate_w2[0]};

// added for bug 3747
assign hpstate_priv_set = ~(tlu_select_tba_w2) | tlu_select_redmode; 
//
// constructing the hpstate for hyper-privileged traps 
//
assign hntrap_hpstate0_w2[5-1:0] = 
       {hpstate_ibe_set[0],  
        hpstate_enb_set[0],  
        hpstate_redmode, // Redmode bit
        // modified for bug 3747
        hpstate_priv_set, // hyper-privileged bit
        hpstate_tlz_set[0]}; // TLZ interrupt bit 

assign tlu_hpstate_hnt_sel0 = 
       ~(tlu_hpstate_din_sel0[0] | tlu_hpstate_wsr_sel0);
//
assign tlu_hpstate_wsr_sel0 = 
           tlu_hpstate_din_sel0[1] | 
           (~true_hpstate0[3] & tlu_pstate_din_sel0[1]);

mux3ds #(5) mux_restore_hpstate0(
       .in0  (dnrtry_hpstate0_w2[5-1:0]), 	
	   .in1  (wsr_data_hpstate_w2[5-1:0]),
	   .in2  (hntrap_hpstate0_w2[5-1:0]),
       .sel0 (tlu_hpstate_din_sel0[0]),  		
       .sel1 (tlu_hpstate_wsr_sel0),
	   .sel2 (tlu_hpstate_hnt_sel0),
       .dout (restore_hpstate0[5-1:0])
);
//
// need to initialize hpstate.enb = 0
// need to initialize hpstate.ibe = 0
// modified due to the addition of hpstate.ibe

dffre #(2) dffr_true_hpst0_enb_ibe (
    .din (restore_hpstate0[5-1:5-2]),
	.q   (true_hpstate0[5-1:5-2]),
    .rst (local_rst),
    .en (~(tlu_update_hpstate_l_w2[0])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
 );











//

dffe #(2) dff_true_hpstate0 (
    .din ({restore_hpstate0[2], 
           restore_hpstate0[0]}),
    .q   ({true_hpstate0[2], 
           true_hpstate0[0]}),
    .en (~(tlu_update_hpstate_l_w2[0])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);












//
dffe dffe_hpstate0_priv (
    .din (restore_hpstate0[1]), 
    .q   (true_hpstate0[1]), 
    .en  (hpstate_priv_update_w2[0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

assign tlu_ifu_pstate_pef[0]   = true_pstate0[4];
assign tlu_lsu_pstate_cle[0]   = true_pstate0[9];
assign tlu_lsu_pstate_priv[0]  = true_pstate0[2];
assign tlu_int_pstate_ie[0]    = true_pstate0[1];
assign local_pstate_ie[0]      = true_pstate0[1];
// assign tlu_pstate_cle[0] 	   = true_pstate0[`PSTATE_CLE];
assign tlu_pstate_tle[0] 	   = true_pstate0[8];
// assign tlu_pstate_priv[0] 	   = true_pstate0[`PSTATE_PRIV];
assign local_pstate_priv[0]    = true_pstate0[2];
assign tlu_pstate_am[0] 	   = true_pstate0[3];
assign tlu_int_redmode[0] = true_hpstate0[2];
assign tlu_lsu_redmode[0] = true_hpstate0[2];
// 
// hypervisor privilege indicator
assign tlu_hpstate_priv[0]   = true_hpstate0[1];
assign local_hpstate_priv[0] = true_hpstate0[1];
assign tcl_hpstate_priv[0]   = true_hpstate0[1];
//
// hypervisor lite mode selector
assign tlu_hpstate_enb[0]   = true_hpstate0[3];
assign local_hpstate_enb[0] = true_hpstate0[3];
assign tcl_hpstate_enb[0]   = true_hpstate0[3];

// hypervisor tlz indicator
assign tlu_hpstate_tlz[0] = true_hpstate0[0];

// hypervisor instruction breakpt enable 
assign tlu_hpstate_ibe[0] = true_hpstate0[4];






















   
// THREAD 1
assign tlu_pstate_nt_sel1 = 
          ~(tlu_pstate_din_sel1[0] | tlu_pstate_wsr_sel1);
//
// modified for bug 3349
assign tlu_pstate_wsr_sel1 = 
              tlu_pstate_din_sel1[1] | 
           (~(true_hpstate1[3] & wsr_data_w2[11]) &
              tlu_hpstate_din_sel1[1]);
//            (~true_hpstate1[`HPSTATE_ENB] & tlu_hpstate_din_sel1[1]);

mux3ds #(6) mux_restore_pstate1(
       .in0  (dnrtry_pstate_w2[6-1:0]), 	
	   .in1  (wsr_data_pstate_w2[6-1:0]),
	   .in2  (ntrap_pstate1[6-1:0]),
       .sel0 (tlu_pstate_din_sel1[0]),  		
	   .sel1 (tlu_pstate_wsr_sel1),
	   .sel2 (tlu_pstate_nt_sel1),
       .dout (restore_pstate1[6-1:0])
);


dffe #(6-1) dff_restore_pstate1_w3 (
    .din ({restore_pstate1[5:3-1], 
           restore_pstate1[0]}), 
    .q   ({restore_pstate1_w3[5:3-1],
           restore_pstate1_w3[0]}),
    .en (~(tlu_update_pstate_l_w2[1])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);












//
dffe dffe_pstate1_priv (
    .din (restore_pstate1[1]),
    .q   (restore_pstate1_w3[1]),
    .en  (pstate_priv_update_w2[1]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// modified to reflect the physical implementation
/*
assign hpstate_dnrtry_priv_w2[1] = 
           (true_hpstate1[`HPSTATE_ENB])? 
            tsa_dnrtry_hpstate_w2[`HPSTATE_PRIV] :
            dnrtry_pstate_w2[`WSR_PSTATE_VR_PRIV];
*/
mux2ds mx_hpstate_dnrtry_priv_w2_1 (
       .in0  (tsa_dnrtry_hpstate_w2[1]),
	   .in1  (dnrtry_pstate_w2[1]),
       .sel0 (true_hpstate1[3]),  	
	   .sel1 (~true_hpstate1[3]),
       .dout (hpstate_dnrtry_priv_w2[1])
); 
//
assign dnrtry_hpstate1_w2[5-1:0] = 
       {tsa_dnrtry_hpstate_w2[4-1],
        true_hpstate1[3],  
        tsa_dnrtry_hpstate_w2[2],
        hpstate_dnrtry_priv_w2[1],
        tsa_dnrtry_hpstate_w2[0]};
//
// true_pstate1 assignments
assign true_pstate1[12-1:0] = 
           {2'b0, // tlu_select_int_global - replaced by gl register
                  // tlu_select_mmu_global - replaced by gl register 
            restore_pstate1_w3[5:4],
            2'b0, // fixed mmodel - TSO
            1'b0, // redmode - replaced by hpstate.red
            restore_pstate1_w3[3:0],
            1'b0}; // tlu_select_alt_global - replaced by gl register 
//
// modified for timing
/*
mux3ds #(9) mux_restore_pstate1(
       .in0  (dnrtry_pstate[`PSTATE_TRUE_WIDTH-3:1]),
	   .in1  (wsr_data_pstate_g[`PSTATE_TRUE_WIDTH-3:1]),
	   .in2  (ntrap_pstate1[`PSTATE_TRUE_WIDTH-3:1]),
       .sel0 (tlu_pstate_din_sel1[0]),  		
       // modified for bug 2584
	   // .sel1 (tlu_pstate_din_sel1[1]),
	   .sel1 (tlu_pstate_wsr_sel1),
	   .sel2 (tlu_pstate_nt_sel1),
       .dout (restore_pstate1[`PSTATE_TRUE_WIDTH-3:1])
);

`ifdef FPGA_SYN_CLK_DFF
dffe #(`PSTATE_TRUE_WIDTH) pstate1_1 (
    .din (restore_pstate1[`PSTATE_TRUE_WIDTH-1:0]), 
	.q   (true_pstate1[`PSTATE_TRUE_WIDTH-1:0]),
    .en (~(tlu_update_pstate_l_w2[1])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
    );
`else
dff #(`PSTATE_TRUE_WIDTH) pstate1_1 (
    .din (restore_pstate1[`PSTATE_TRUE_WIDTH-1:0]), 
	.q   (true_pstate1[`PSTATE_TRUE_WIDTH-1:0]),
    .clk (pstate1_clk),
    .se  (se),       
    .si  (),          
    .so  ()
    );
`endif
//
`ifdef FPGA_SYN_CLK_DFF
dffe #(`PSTATE_TRUE_WIDTH-1) dff_true_pstate1 (
    .din ({restore_pstate1[`PSTATE_TRUE_WIDTH-1:3], 
           restore_pstate1[1:0]}), 
    .q   ({true_pstate1[`PSTATE_TRUE_WIDTH-1:3], 
           true_pstate1[1:0]}), 
    .en (~(tlu_update_pstate_l_w2[1])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
`else
dff #(`PSTATE_TRUE_WIDTH-1) dff_true_pstate1 (
    .din ({restore_pstate1[`PSTATE_TRUE_WIDTH-1:3], 
           restore_pstate1[1:0]}), 
    .q   ({true_pstate1[`PSTATE_TRUE_WIDTH-1:3], 
           true_pstate1[1:0]}), 
    .clk (pstate1_clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
`endif
//
dffe dffe_pstate1_priv (
    .din (restore_pstate1[`PSTATE_PRIV]),
    .q   (true_pstate1[`PSTATE_PRIV]), 
    .en  (pstate_priv_update_g[1]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// modified for hypervisor support
assign restore_pstate1[11:10] = 2'b0;
assign restore_pstate1[0]     = 1'b0;
*/
//
// constructing the hpstate for hyper-privileged traps 
//
assign hntrap_hpstate1_w2[5-1:0] = 
       {hpstate_ibe_set[1],  
        hpstate_enb_set[1],  
        hpstate_redmode,  // Redmode bit
        hpstate_priv_set, // hyper-privileged bit
        hpstate_tlz_set[1]}; // TLZ interrupt bit 
//
assign tlu_hpstate_hnt_sel1 = 
       ~(tlu_hpstate_din_sel1[0] | tlu_hpstate_wsr_sel1);
//
assign tlu_hpstate_wsr_sel1 = 
           tlu_hpstate_din_sel1[1] | 
           (~true_hpstate1[3] & tlu_pstate_din_sel1[1]);

mux3ds #(5) mux_restore_hpstate1 (
       .in0  (dnrtry_hpstate1_w2[5-1:0]), 	
	   .in1  (wsr_data_hpstate_w2[5-1:0]),
	   .in2  (hntrap_hpstate1_w2[5-1:0]),
       .sel0 (tlu_hpstate_din_sel1[0]),  		
       .sel1 (tlu_hpstate_wsr_sel1),
	   .sel2 (tlu_hpstate_hnt_sel1),
       .dout (restore_hpstate1[5-1:0])
);

// need to initialize hpstate.enb = 0
// need to initialize hpstate.ibe = 0
// modified due to the addition of hpstate.ibe

dffre #(2) dffr_true_hpst1_enb_ibe (
    .din (restore_hpstate1[5-1:5-2]),
	.q   (true_hpstate1[5-1:5-2]),
    .rst (local_rst),
    .en (~(tlu_update_hpstate_l_w2[1])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











//

dffe #(2) dff_true_hpstate1 (
    .din ({restore_hpstate1[2], 
           restore_hpstate1[0]}),
    .q   ({true_hpstate1[2], 
           true_hpstate1[0]}),
    .en (~(tlu_update_hpstate_l_w2[1])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);












//
dffe dffe_hpstate1_priv (
    .din (restore_hpstate1[1]), 
    .q   (true_hpstate1[1]), 
    .en  (hpstate_priv_update_w2[1]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

assign tlu_ifu_pstate_pef[1]   = true_pstate1[4];
assign tlu_lsu_pstate_cle[1]   = true_pstate1[9];
assign tlu_lsu_pstate_priv[1]  = true_pstate1[2];
assign tlu_int_pstate_ie[1]    = true_pstate1[1];
assign local_pstate_ie[1]      = true_pstate1[1];
// assign tlu_pstate_cle[1] 	   = true_pstate1[`PSTATE_CLE];
assign tlu_pstate_tle[1] 	   = true_pstate1[8];
// assign tlu_pstate_priv[1] 	   = true_pstate1[`PSTATE_PRIV];
assign local_pstate_priv[1]    = true_pstate1[2];
assign tlu_pstate_am[1] 	   = true_pstate1[3];
// assign tlu_pstate1_mmodel[1:0] = true_pstate1[`PSTATE_MM_HI:`PSTATE_MM_LO];
//
assign tlu_int_redmode[1] = true_hpstate1[2];
assign tlu_lsu_redmode[1] = true_hpstate1[2];
// 
// hypervisor privilege indicator
assign tlu_hpstate_priv[1]   = true_hpstate1[1];
assign local_hpstate_priv[1] = true_hpstate1[1];
assign tcl_hpstate_priv[1]   = true_hpstate1[1];
//
// hypervisor lite mode selector
assign tlu_hpstate_enb[1]   = true_hpstate1[3];
assign local_hpstate_enb[1] = true_hpstate1[3];
assign tcl_hpstate_enb[1]   = true_hpstate1[3];

// hypervisor tlz indicator
assign tlu_hpstate_tlz[1] = true_hpstate1[0];

// hypervisor instruction breakpt enable 
assign tlu_hpstate_ibe[1] = true_hpstate1[4];

// THREAD2
// added for bug 1575
// modified for bug 2584
// assign tlu_pstate_nt_sel2 = ~|(tlu_pstate_din_sel2[1:0]);
assign tlu_pstate_nt_sel2 = 
          ~(tlu_pstate_din_sel2[0] | tlu_pstate_wsr_sel2);
// 
// modified for bug 3349
assign tlu_pstate_wsr_sel2 = 
           tlu_pstate_din_sel2[1] | 
           (~(true_hpstate2[3] & wsr_data_w2[11]) &
              tlu_hpstate_din_sel2[1]);
//            (~true_hpstate2[`HPSTATE_ENB] & tlu_hpstate_din_sel2[1]);

mux3ds #(6) mux_restore_pstate2(
       .in0  (dnrtry_pstate_w2[6-1:0]), 	
	   .in1  (wsr_data_pstate_w2[6-1:0]),
	   .in2  (ntrap_pstate2[6-1:0]),
       .sel0 (tlu_pstate_din_sel2[0]),  		
	   .sel1 (tlu_pstate_wsr_sel2),
	   .sel2 (tlu_pstate_nt_sel2),
       .dout (restore_pstate2[6-1:0])
);


dffe #(6-1) dff_restore_pstate2_w3 (
    .din ({restore_pstate2[5:3-1], 
           restore_pstate2[0]}), 
    .q   ({restore_pstate2_w3[5:3-1],
           restore_pstate2_w3[0]}),
    .en (~(tlu_update_pstate_l_w2[2])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);












//
dffe dffe_pstate2_priv (
    .din (restore_pstate2[1]),
    .q   (restore_pstate2_w3[1]),
    .en  (pstate_priv_update_w2[2]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// true_pstate2 assignments
assign true_pstate2[12-1:0] = 
           {2'b0, // tlu_select_int_global - replaced by gl register
                  // tlu_select_mmu_global - replaced by gl register 
            restore_pstate2_w3[5:4],
            2'b0, // fixed mmodel - TSO
            1'b0, // redmode - replaced by hpstate.red
            restore_pstate2_w3[3:0],
            1'b0}; // tlu_select_alt_global - replaced by gl register 
//
// modified for timing
/*
mux3ds #(9) mux_restore_pstate2( 
       .in0  (dnrtry_pstate[`PSTATE_TRUE_WIDTH-3:1]), 	
	   .in1  (wsr_data_pstate_g[`PSTATE_TRUE_WIDTH-3:1]),
	   .in2  (ntrap_pstate2[`PSTATE_TRUE_WIDTH-3:1]),
       .sel0 (tlu_pstate_din_sel2[0]),  		
       // modified for bug 2584
	   // .sel1 (tlu_pstate_din_sel2[1]),
	   .sel1 (tlu_pstate_wsr_sel2),
	   .sel2 (tlu_pstate_nt_sel2),
       .dout (restore_pstate2[`PSTATE_TRUE_WIDTH-3:1])
);

`ifdef FPGA_SYN_CLK_DFF
dffe #(`PSTATE_TRUE_WIDTH) pstate2_1 (
    .din (restore_pstate2[`PSTATE_TRUE_WIDTH-1:0]), 
	.q   (true_pstate2[`PSTATE_TRUE_WIDTH-1:0]),
    .en (~(tlu_update_pstate_l_w2[2])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
`else
dff #(`PSTATE_TRUE_WIDTH) pstate2_1 (
    .din (restore_pstate2[`PSTATE_TRUE_WIDTH-1:0]), 
	.q   (true_pstate2[`PSTATE_TRUE_WIDTH-1:0]),
    .clk (pstate2_clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
`endif
//
`ifdef FPGA_SYN_CLK_DFF
dffe #(`PSTATE_TRUE_WIDTH-1) dff_true_pstate2 (
    .din ({restore_pstate2[`PSTATE_TRUE_WIDTH-1:3], 
           restore_pstate2[1:0]}), 
    .q   ({true_pstate2[`PSTATE_TRUE_WIDTH-1:3], 
           true_pstate2[1:0]}), 
    .en (~(tlu_update_pstate_l_w2[2])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
`else
dff #(`PSTATE_TRUE_WIDTH-1) dff_true_pstate2 (
    .din ({restore_pstate2[`PSTATE_TRUE_WIDTH-1:3], 
           restore_pstate2[1:0]}), 
    .q   ({true_pstate2[`PSTATE_TRUE_WIDTH-1:3], 
           true_pstate2[1:0]}), 
    .clk (pstate2_clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
`endif
//
dffe dffe_pstate2_priv (
    .din (restore_pstate2[`PSTATE_PRIV]),
    .q   (true_pstate2[`PSTATE_PRIV]), 
    .en  (pstate_priv_update_g[2]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// modified for hypervisor support
assign restore_pstate2[11:10] = 2'b0;
assign restore_pstate2[0]     = 1'b0;
// modified to reflect the physical implementation
// restructing the hpstate for done/retry instructions
//
assign hpstate_dnrtry_priv_w2[2] = 
           (true_hpstate2[`HPSTATE_ENB])? 
            tsa_dnrtry_hpstate_w2[`HPSTATE_PRIV] :
            dnrtry_pstate_w2[`WSR_PSTATE_VR_PRIV];
*/
mux2ds mx_hpstate_dnrtry_priv_w2_2 (
       .in0  (tsa_dnrtry_hpstate_w2[1]),
	   .in1  (dnrtry_pstate_w2[1]),
       .sel0 (true_hpstate2[3]),  	
	   .sel1 (~true_hpstate2[3]),
       .dout (hpstate_dnrtry_priv_w2[2])
); 
//
assign dnrtry_hpstate2_w2[5-1:0] = 
       {tsa_dnrtry_hpstate_w2[4-1],
        true_hpstate2[3],  
        tsa_dnrtry_hpstate_w2[2],
        hpstate_dnrtry_priv_w2[2],
        tsa_dnrtry_hpstate_w2[0]};
//
// constructing the hpstate for hyper-privileged traps 
//
assign hntrap_hpstate2_w2[5-1:0] = 
       {hpstate_ibe_set[2],  
        hpstate_enb_set[2],  
        hpstate_redmode,  // Redmode bit
        hpstate_priv_set, // hyper-privileged bit
        hpstate_tlz_set[2]}; // TLZ interrupt bit 
//
assign tlu_hpstate_hnt_sel2 = 
       ~(tlu_hpstate_din_sel2[0] | tlu_hpstate_wsr_sel2);
//
assign tlu_hpstate_wsr_sel2 = 
           tlu_hpstate_din_sel2[1] | 
           (~true_hpstate2[3] & tlu_pstate_din_sel2[1]);

mux3ds #(5) mux_restore_hpstate2 (
       .in0  (dnrtry_hpstate2_w2[5-1:0]), 	
	   .in1  (wsr_data_hpstate_w2[5-1:0]),
	   .in2  (hntrap_hpstate2_w2[5-1:0]),
       .sel0 (tlu_hpstate_din_sel2[0]),  		
	   .sel1 (tlu_hpstate_wsr_sel2),
	   .sel2 (tlu_hpstate_hnt_sel2),
       .dout (restore_hpstate2[5-1:0])
);
//
// need to initialize hpstate.enb = 0
// need to initialize hpstate.ibe = 0
// modified due to the addition of hpstate.ibe

dffre #(2) dffr_true_hpst2_enb_ibe (
    .din (restore_hpstate2[5-1:5-2]),
	.q   (true_hpstate2[5-1:5-2]),
    .rst (local_rst),
    .en (~(tlu_update_hpstate_l_w2[2])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











//

dffe #(2) dff_true_hpstate2 (
    .din ({restore_hpstate2[2], 
           restore_hpstate2[0]}),
    .q   ({true_hpstate2[2], 
           true_hpstate2[0]}),
    .en (~(tlu_update_hpstate_l_w2[2])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);












//
dffe dffe_hpstate2_priv (
    .din (restore_hpstate2[1]), 
    .q   (true_hpstate2[1]), 
    .en  (hpstate_priv_update_w2[2]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

assign tlu_ifu_pstate_pef[2]   = true_pstate2[4];
assign tlu_lsu_pstate_cle[2]   = true_pstate2[9];
assign tlu_lsu_pstate_priv[2]  = true_pstate2[2];
assign tlu_int_pstate_ie[2]    = true_pstate2[1];
assign local_pstate_ie[2]      = true_pstate2[1];
// assign tlu_pstate_cle[2] 	   = true_pstate2[`PSTATE_CLE];
assign tlu_pstate_tle[2] 	   = true_pstate2[8];
// assign tlu_pstate_priv[2] 	   = true_pstate2[`PSTATE_PRIV];
assign local_pstate_priv[2]    = true_pstate2[2];
assign tlu_pstate_am[2] 	   = true_pstate2[3];
// assign tlu_pstate2_mmodel[1:0] = true_pstate2[`PSTATE_MM_HI:`PSTATE_MM_LO];
//
// modified for hypervisor support
// assign	tlu_int_redmode[2]	= true_pstate2[`PSTATE_RED];
assign tlu_int_redmode[2] = true_hpstate2[2];
assign tlu_lsu_redmode[2] = true_hpstate2[2];
// 
// hypervisor privilege indicator
assign tlu_hpstate_priv[2]   = true_hpstate2[1];
assign local_hpstate_priv[2] = true_hpstate2[1];
assign tcl_hpstate_priv[2]   = true_hpstate2[1];
//
// hypervisor lite mode selector
assign tlu_hpstate_enb[2]   = true_hpstate2[3];
assign local_hpstate_enb[2] = true_hpstate2[3];
assign tcl_hpstate_enb[2]   = true_hpstate2[3];

// hypervisor tlz indicator
assign tlu_hpstate_tlz[2] = true_hpstate2[0];

// hypervisor instruction breakpt enable 
assign tlu_hpstate_ibe[2] = true_hpstate2[4];

// THREAD3
// added for bug 1575
// modified for bug 2584
// assign tlu_pstate_nt_sel3 = ~|(tlu_pstate_din_sel3[1:0]);
assign tlu_pstate_nt_sel3 = 
          ~(tlu_pstate_din_sel3[0] | tlu_pstate_wsr_sel3);
//
// modified for bug 3349
assign tlu_pstate_wsr_sel3 = 
           tlu_pstate_din_sel3[1] | 
           (~(true_hpstate3[3] & wsr_data_w2[11]) &
              tlu_hpstate_din_sel3[1]);
//            (~true_hpstate3[`HPSTATE_ENB] & tlu_hpstate_din_sel3[1]);
//
mux3ds #(6) mux_restore_pstate3(
       .in0  (dnrtry_pstate_w2[6-1:0]), 	
	   .in1  (wsr_data_pstate_w2[6-1:0]),
	   .in2  (ntrap_pstate3[6-1:0]),
       .sel0 (tlu_pstate_din_sel3[0]),  		
	   .sel1 (tlu_pstate_wsr_sel3),
	   .sel2 (tlu_pstate_nt_sel3),
       .dout (restore_pstate3[6-1:0])
);


dffe #(6-1) dff_restore_pstate3_w3 (
    .din ({restore_pstate3[5:3-1], 
           restore_pstate3[0]}), 
    .q   ({restore_pstate3_w3[5:3-1],
           restore_pstate3_w3[0]}),
    .en (~(tlu_update_pstate_l_w2[3])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);












//
dffe dffe_pstate3_priv (
    .din (restore_pstate3[1]),
    .q   (restore_pstate3_w3[1]),
    .en  (pstate_priv_update_w2[3]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// true_pstate3 assignments
assign true_pstate3[12-1:0] = 
           {2'b0, // tlu_select_int_global - replaced by gl register
                  // tlu_select_mmu_global - replaced by gl register 
            restore_pstate3_w3[5:4],
            2'b0, // fixed mmodel - TSO
            1'b0, // redmode - replaced by hpstate.red
            restore_pstate3_w3[3:0],
            1'b0}; // tlu_select_alt_global - replaced by gl register 
//
// modified for timing
/*
mux3ds #(9) mux_restore_pstate3(
       .in0  (dnrtry_pstate[`PSTATE_TRUE_WIDTH-3:1]), 	
	   .in1  (wsr_data_pstate_g[`PSTATE_TRUE_WIDTH-3:1]),
	   .in2  (ntrap_pstate3[`PSTATE_TRUE_WIDTH-3:1]),
       .sel0 (tlu_pstate_din_sel3[0]),  		
       // modified for bug 2584
	   // .sel1 (tlu_pstate_din_sel3[1]),
	   .sel1 (tlu_pstate_wsr_sel3),
	   .sel2 (tlu_pstate_nt_sel3),
       .dout (restore_pstate3[`PSTATE_TRUE_WIDTH-3:1])
);
//
`ifdef FPGA_SYN_CLK_DFF
dffe #(`PSTATE_TRUE_WIDTH) pstate3_1 (
    .din (restore_pstate3[`PSTATE_TRUE_WIDTH-1:0]), 
	.q   (true_pstate3[`PSTATE_TRUE_WIDTH-1:0]),
    .en (~(tlu_update_pstate_l_w2[3])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
`else
dff #(`PSTATE_TRUE_WIDTH) pstate3_1 (
    .din (restore_pstate3[`PSTATE_TRUE_WIDTH-1:0]), 
	.q   (true_pstate3[`PSTATE_TRUE_WIDTH-1:0]),
    .clk (pstate3_clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
`endif
//
`ifdef FPGA_SYN_CLK_DFF
dffe #(`PSTATE_TRUE_WIDTH-1) pstate3_1 (
    .din ({restore_pstate3[`PSTATE_TRUE_WIDTH-1:3], 
           restore_pstate3[1:0]}), 
    .q   ({true_pstate3[`PSTATE_TRUE_WIDTH-1:3], 
           true_pstate3[1:0]}), 
    .en (~(tlu_update_pstate_l_w2[3])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
`else
dff #(`PSTATE_TRUE_WIDTH-1) pstate3_1 (
    .din ({restore_pstate3[`PSTATE_TRUE_WIDTH-1:3], 
           restore_pstate3[1:0]}), 
    .q   ({true_pstate3[`PSTATE_TRUE_WIDTH-1:3], 
           true_pstate3[1:0]}), 
    .clk (pstate3_clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
`endif
//
dffe dffe_pstate3_priv (
    .din (restore_pstate3[`PSTATE_PRIV]),
    .q   (true_pstate3[`PSTATE_PRIV]),
    .en  (pstate_priv_update_g[3]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// modified for hypervisor support
assign restore_pstate3[11:10] = 2'b0;
assign restore_pstate3[0]     = 1'b0;
//
// modified to reflect the physical implementation
assign hpstate_dnrtry_priv_w2[3] = 
           (true_hpstate3[`HPSTATE_ENB])? 
            tsa_dnrtry_hpstate_w2[`HPSTATE_PRIV] :
            dnrtry_pstate_w2[`WSR_PSTATE_VR_PRIV];
*/
mux2ds mx_hpstate_dnrtry_priv_w2_3 (
       .in0  (tsa_dnrtry_hpstate_w2[1]),
	   .in1  (dnrtry_pstate_w2[1]),
       .sel0 (true_hpstate3[3]),  	
	   .sel1 (~true_hpstate3[3]),
       .dout (hpstate_dnrtry_priv_w2[3])
); 
//
assign dnrtry_hpstate3_w2[5-1:0] = 
       {tsa_dnrtry_hpstate_w2[4-1],
        true_hpstate3[3],  
        tsa_dnrtry_hpstate_w2[2],
        hpstate_dnrtry_priv_w2[3],
        tsa_dnrtry_hpstate_w2[0]};
//
// constructing the hpstate for hyper-privileged traps 
//
assign hntrap_hpstate3_w2[5-1:0] = 
       {hpstate_ibe_set[3],  
        hpstate_enb_set[3],  
        hpstate_redmode,  // Redmode bit
        hpstate_priv_set, // hyper-privileged bit
        hpstate_tlz_set[3]}; // TLZ interrupt bit 

assign tlu_hpstate_hnt_sel3 = 
       ~(tlu_hpstate_din_sel3[0] | tlu_hpstate_wsr_sel3);
//
assign tlu_hpstate_wsr_sel3 = 
           tlu_hpstate_din_sel3[1] | 
           (~true_hpstate3[3] & tlu_pstate_din_sel3[1]);

mux3ds #(5) mux_restore_hpstate3 (
       .in0  (dnrtry_hpstate3_w2[5-1:0]),
	   .in1  (wsr_data_hpstate_w2[5-1:0]),
	   .in2  (hntrap_hpstate3_w2[5-1:0]),
       .sel0 (tlu_hpstate_din_sel3[0]),  		
	   .sel1 (tlu_hpstate_wsr_sel3),
	   .sel2 (tlu_hpstate_hnt_sel3),
       .dout (restore_hpstate3[5-1:0])
);
//
// need to initialize hpstate.enb = 0
// need to initialize hpstate.ibe = 0
// modified due to the addition of hpstate.ibe

dffre #(2) dffr_true_hpst3_enb_ibe (
    .din (restore_hpstate3[5-1:5-2]), 
	.q   (true_hpstate3[5-1:5-2]),
    .rst (local_rst),
    .en (~(tlu_update_hpstate_l_w2[3])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);











//
//

dffe #(2) dff_true_hpstate3 (
    .din ({restore_hpstate3[2], 
           restore_hpstate3[0]}),
    .q   ({true_hpstate3[2], 
           true_hpstate3[0]}),
    .en (~(tlu_update_hpstate_l_w2[3])), .clk(clk),
    .se  (se),       
    .si  (),          
    .so  ()
);












//
dffe dffe_hpstate3_priv (
    .din (restore_hpstate3[1]), 
    .q   (true_hpstate3[1]), 
    .en  (hpstate_priv_update_w2[3]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

assign tlu_ifu_pstate_pef[3]   = true_pstate3[4];
assign tlu_lsu_pstate_cle[3]   = true_pstate3[9];
assign tlu_lsu_pstate_priv[3]  = true_pstate3[2];
assign tlu_int_pstate_ie[3]    = true_pstate3[1];
assign local_pstate_ie[3]      = true_pstate3[1];
// assign tlu_pstate_cle[3] 	   = true_pstate3[`PSTATE_CLE];
assign tlu_pstate_tle[3] 	   = true_pstate3[8];
// assign tlu_pstate_priv[3] 	   = true_pstate3[`PSTATE_PRIV];
assign local_pstate_priv[3]    = true_pstate3[2];
assign tlu_pstate_am[3] 	   = true_pstate3[3];
// assign tlu_pstate3_mmodel[1:0] = true_pstate3[`PSTATE_MM_HI:`PSTATE_MM_LO];
//
// modified for hypervisor support
// assign	tlu_int_redmode[3]	= true_pstate3[`PSTATE_RED];
assign tlu_int_redmode[3] = true_hpstate3[2];
assign tlu_lsu_redmode[3] = true_hpstate3[2];
// 
// hypervisor privilege indicator
assign tlu_hpstate_priv[3]   = true_hpstate3[1];
assign local_hpstate_priv[3] = true_hpstate3[1];
assign tcl_hpstate_priv[3]   = true_hpstate3[1];
//
// hypervisor lite mode selector
assign tlu_hpstate_enb[3]   = true_hpstate3[3];
assign local_hpstate_enb[3] = true_hpstate3[3];
assign tcl_hpstate_enb[3]   = true_hpstate3[3];

// hypervisor tlz indicator
assign tlu_hpstate_tlz[3] = true_hpstate3[0];

// hypervisor instruction breakpt enable 
assign tlu_hpstate_ibe[3] = true_hpstate3[4];

 // !`ifdef FPGA_SYN_1THREAD
   
// Mux to choose the pstate register to read base on thread
wire [12-1:0] pstate_rdata;
wire [12-1:0] hpstate_rdata;





   
mux4ds #(12) pstate_mx_sel (
       .in0  (true_pstate0[12-1:0]),
       .in1  (true_pstate1[12-1:0]),
       .in2  (true_pstate2[12-1:0]),
       .in3  (true_pstate3[12-1:0]),
       .sel0 (tlu_thrd_rsel_e[0]),
       .sel1 (tlu_thrd_rsel_e[1]),
       .sel2 (tlu_thrd_rsel_e[2]),
       .sel3 (tlu_thrd_rsel_e[3]),
       .dout (pstate_rdata[12-1:0])
); 
//
// added for hypervisor support 
// mux to choose the pstate register to read base on thread

mux4ds #(5) hpstate_mx_sel (
       .in0  (true_hpstate0[5-1:0]),
       .in1  (true_hpstate1[5-1:0]),
       .in2  (true_hpstate2[5-1:0]),
       .in3  (true_hpstate3[5-1:0]),
       .sel0 (tlu_thrd_rsel_e[0]),
       .sel1 (tlu_thrd_rsel_e[1]),
       .sel2 (tlu_thrd_rsel_e[2]),
       .sel3 (tlu_thrd_rsel_e[3]),
       .dout (true_hpstate[5-1:0])
);
 // !`ifdef FPGA_SYN_1THREAD
   
// 
// assigned the stored hpstate bits to the ASR positions
//
assign hpstate_rdata[11]  = true_hpstate[3]; 
assign hpstate_rdata[10]  = true_hpstate[4]; 
assign hpstate_rdata[5]  = true_hpstate[2]; 
assign hpstate_rdata[2] = true_hpstate[1]; 
assign hpstate_rdata[0]  = true_hpstate[0]; 
//
// grounding the reserved bits
// modified due to the addition of hpstate.ibe 
// assign hpstate_rdata[`WSR_HPSTATE_ENB-1 :`WSR_HPSTATE_RED+1]  = 5'h00; 
assign hpstate_rdata[10-1 :5+1]  = 4'h0; 
assign hpstate_rdata[5-1 :2+1] = 2'b00; 
assign hpstate_rdata[2-1:0+1]  = 1'b0; 
//
// constructing data for htstate
//
wire [12-1:0] htstate_rdata;

// assign htstate_rdata[`WSR_HPSTATE_RED]  = tsa_rdata[`TLU_HTSTATE_HI]; 
// assign htstate_rdata[`WSR_HPSTATE_PRIV] = tsa_rdata[`TLU_HTSTATE_HI-1]; 
/* modified due to logic redistribution
assign htstate_rdata[`WSR_HPSTATE_IBE]  = tsa_rdata[`TLU_HTSTATE_HI]; 
assign htstate_rdata[`WSR_HPSTATE_RED]  = tsa_rdata[`TLU_HTSTATE_HI-1]; 
assign htstate_rdata[`WSR_HPSTATE_PRIV] = tsa_rdata[`TLU_HTSTATE_HI-2]; 
assign htstate_rdata[`WSR_HPSTATE_TLZ]  = tsa_rdata[`TLU_HTSTATE_LO]; 
*/
assign htstate_rdata[10]  = tsa_rdata[133]; 
assign htstate_rdata[5]  = tsa_rdata[133-1]; 
assign htstate_rdata[2] = tsa_rdata[133-2]; 
assign htstate_rdata[0]  = tsa_rdata[130]; 
//
// grounding the reserved bits
// modified due to addition of hpstate.ibe
// assign htstate_rdata[`RDSR_HPSTATE_WIDTH-1 :`WSR_HPSTATE_RED+1] = 6'h00; 
assign htstate_rdata[12-1] = 1'b0; 
assign htstate_rdata[10-1 :5+1]  = 4'h0; 
assign htstate_rdata[5-1 :2+1] = 2'b00; 
assign htstate_rdata[2-1:0+1]  = 1'b0; 

//=========================================================================================
//	RDPR - This section has been recoded due to timing
//=========================================================================================

// mux data width - 2b




   
			 
mux4ds #(2) mux_global_rdata (
       .in0  (tlu_gl_lvl0[2-1:0]),
       .in1  (tlu_gl_lvl1[2-1:0]),
       .in2  (tlu_gl_lvl2[2-1:0]),
       .in3  (tlu_gl_lvl3[2-1:0]),
       .sel0 (tlu_thrd_rsel_e[0]),
       .sel1 (tlu_thrd_rsel_e[1]),
       .sel2 (tlu_thrd_rsel_e[2]),
       .sel3 (tlu_thrd_rsel_e[3]),
       .dout (global_rdata[2-1:0])
);
// 
// htickcmp interrupt enable
//
mux4ds #(1) mux_hintp_rdata (
        .in0    (tlu_hintp[0]),
        .in1    (tlu_hintp[1]),
        .in2    (tlu_hintp[2]),
        .in3    (tlu_hintp[3]),
        .sel0   (tlu_thrd_rsel_e[0]),
        .sel1   (tlu_thrd_rsel_e[1]),
        .sel2   (tlu_thrd_rsel_e[2]),
        .sel3   (tlu_thrd_rsel_e[3]),
        .dout   (hintp_rdata)
);
 // !`ifdef FPGA_SYN_1THREAD
   
// 
// tstate.gl - 2b
assign tstate_rdata[41:40] = 
       tsa_rdata[37:36];
//
// tstate.ccr - 8b
assign tstate_rdata[39:32] = 
       tsa_rdata[35:28];
//
// tstate.asi - 8b
assign tstate_rdata[31:24] = 
       tsa_rdata[27:20];
//
// tstate.pstate(valid range 2) - 2b
assign tstate_rdata[17:16] = 
       tsa_rdata[19:18];
// 
// added for to please lint 
assign tstate_dummy_zero[1:0] = 
       tsa_rdata[18-1:15+1] & 2'b0; 
//
// tstate.pstate(valid range 1) - 4b
assign tstate_rdata[12:9] = 
       tsa_rdata[15:12];
//
// tstate.cwp - 3b
assign tstate_rdata[2:0] = 
       tsa_rdata[11:9];
//
// reserved bits with ASR - assign to  1'b0
assign tstate_rdata[48-1:41+1] = 
       6'h00; 
assign tstate_rdata[24-1:17+1] = 
       6'h00; 
assign tstate_rdata[16-1:12+1] = 
       {1'b0, tstate_dummy_zero[1:0]}; 
assign tstate_rdata[9-1:2+1] = 
       6'h00; 
//
//============================================================================
// new rdpr mux coding due to timing changes 
//============================================================================
//
// added for bug 2332
assign rdpr_mx1_onehot_sel = 
           ~(|tlu_rdpr_mx1_sel[3:1]);
// mux1- 64b
mux4ds #(64) rdpr_mx1(
	.in0({tlu_tick_npt,true_tick[60:0], 2'b0}),
	.in1(tickcmp_rdata[64-1:0]),
	.in2(stickcmp_rdata[64-1:0]),
	.in3({tlu_htickcmp_intdis,htickcmp_rdata[64-2:0]}),
	.sel0(rdpr_mx1_onehot_sel),
	.sel1(tlu_rdpr_mx1_sel[1]),
	.sel2(tlu_rdpr_mx1_sel[2]),
	.sel3(tlu_rdpr_mx1_sel[3]),
	.dout(tlu_rdpr_mx1_out[64-1:0])
);
// 
//
// added for bug 2332
assign rdpr_mx2_onehot_sel = 
           ~(|tlu_rdpr_mx2_sel[3:1]); 
//
// mux2 - 4b 
mux4ds #(4) rdpr_mx2(
	.in0({2'b0,global_rdata[2-1:0]}),
	.in1({3'b0,hintp_rdata}),
	.in2({1'b0,tlu_trp_lvl[2:0]}),
	.in3(tlu_pil[3:0]),
	.sel0(rdpr_mx2_onehot_sel),
	.sel1(tlu_rdpr_mx2_sel[1]),
	.sel2(tlu_rdpr_mx2_sel[2]),
	.sel3(tlu_rdpr_mx2_sel[3]),
	.dout(tlu_rdpr_mx2_out[3:0])
);
//
// added for bug 2332
assign rdpr_mx3_onehot_sel = 
           ~(|tlu_rdpr_mx3_sel[2:1]);
//
// mux3 - 17b
mux3ds #(17) rdpr_mx3(
	.in0(sftint_rdata[17-1:0]),
	.in1({5'b0,pstate_rdata[12-1:0]}),
	.in2({5'b0,hpstate_rdata[12-1:0]}),
	.sel0(rdpr_mx3_onehot_sel),
	.sel1(tlu_rdpr_mx3_sel[1]),
	.sel2(tlu_rdpr_mx3_sel[2]),
	.dout(tlu_rdpr_mx3_out[17-1:0])
);
//
// added for bug 2332
assign rdpr_mx4_onehot_sel = 
           ~(|tlu_rdpr_mx4_sel[2:1]);
//
// mux4 - 48b 
mux3ds #(48) rdpr_mx4(
	.in0({tsa_rdata[129:84],2'b00}),
	.in1({tsa_rdata[83:38],2'b00}),
	// .in0({tsa_rdata[`TLU_PC_HI-1:`TLU_PC_LO],2'b00}),
	// .in1({tsa_rdata[`TLU_NPC_HI-1:`TLU_NPC_LO],2'b00}),
    .in2(tstate_rdata[48-1:0]),
	.sel0(rdpr_mx4_onehot_sel),
	.sel1(tlu_rdpr_mx4_sel[1]), 
	.sel2(tlu_rdpr_mx4_sel[2]), 
	.dout(tlu_rdpr_mx4_out[48-1:0])
);
//
// added for bug 2332
assign rdpr_mx5_onehot_sel = 
           ~(|tlu_rdpr_mx5_sel[3:1]);
//
// mux5 - 64b 
mux4ds #(64) rdpr_mx5(
	.in0({{16{tba_rdata[33-1]}},
           tba_rdata[33-1:0],15'h0000}),
	.in1({{16{htba_rdata[34-1]}},
           htba_rdata[34-1:0],14'h0000}),
	.in2(tlu_rdpr_mx1_out[64-1:0]),
	.in3(tlu_pib_rsr_data_e[64-1:0]),
	.sel0(rdpr_mx5_onehot_sel),
	.sel1(tlu_rdpr_mx5_sel[1]),
	.sel2(tlu_rdpr_mx5_sel[2]),
	.sel3(tlu_rdpr_mx5_sel[3]),
	.dout(tlu_rdpr_mx5_out[64-1:0])
);
//
// added for bug 2332
assign rdpr_mx6_onehot_sel = 
           ~(|tlu_rdpr_mx6_sel[2:0]);
//
// mux6 - 12b 
mux4ds #(17) rdpr_mx6(
	.in0({8'b0,tsa_rdata[8:0]}),  // ttype
	.in1({5'b0,htstate_rdata[12-1:0]}),
	.in2({13'b0,tlu_rdpr_mx2_out[3:0]}),
	.in3({tlu_rdpr_mx3_out[17-1:0]}),
	.sel0(rdpr_mx6_onehot_sel),
	.sel1(tlu_rdpr_mx6_sel[0]),
	.sel2(tlu_rdpr_mx6_sel[1]),
	.sel3(tlu_rdpr_mx6_sel[2]),
	.dout(tlu_rdpr_mx6_out[17-1:0])
);
//
// mux7- 64b
mux4ds #(64) rdpr_mx7(
	.in0({{16{tlu_rdpr_mx4_out[48-1]}}, 
           tlu_rdpr_mx4_out[48-1:0]}),
	.in1(tlu_rdpr_mx5_out[64-1:0]),
	.in2({47'b0,tlu_rdpr_mx6_out[17-1:0]}),
	.in3({56'b0,lsu_tlu_rsr_data_e[7:0]}),
	.sel0(tlu_rdpr_mx7_sel[0]),
	.sel1(tlu_rdpr_mx7_sel[1]),
	.sel2(tlu_rdpr_mx7_sel[2]),
	.sel3(tlu_rdpr_mx7_sel[3]),
	.dout(tlu_rdpr_mx7_out[64-1:0])
);
/*
mux4ds #(`TLU_ASR_DATA_WIDTH) rdpr_mx7(
	.in0({{16{tlu_rdpr_mx4_out[`RDSR_TSTATE_WIDTH-1]}}, 
           tlu_rdpr_mx4_out[`RDSR_TSTATE_WIDTH-1:0]}),
	.in1(tlu_rdpr_mx5_out[`TLU_ASR_DATA_WIDTH-1:0]),
	.in2({47'b0,tlu_rdpr_mx6_out[`SFTINT_WIDTH-1:0]}),
	.in3({56'b0,lsu_tlu_rsr_data_e[7:0]}),
	.sel0(tlu_rdpr_mx7_sel[0]),
	.sel1(tlu_rdpr_mx7_sel[1]),
	.sel2(tlu_rdpr_mx7_sel[2]),
	.sel3(tlu_rdpr_mx7_sel[3]),
	.dout(tlu_rdpr_mx7_out[`TLU_ASR_DATA_WIDTH-1:0])
);
*/
//
// drive rsr data to exu
assign tlu_exu_rsr_data_e[64-1:0] = 
           tlu_rdpr_mx7_out[64-1:0];
//
// added for timing
dff #(64) dff_tlu_exu_rsr_data_m (
    .din (tlu_exu_rsr_data_e[64-1:0]),
    .q   (tlu_exu_rsr_data_m[64-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

endmodule
