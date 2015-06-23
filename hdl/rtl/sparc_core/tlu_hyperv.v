// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: tlu_hyperv.v
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
////////////////////////////////////////////////////////////////////////
/*
//      Description:    Block that contain most of the Hypervisor support
//                      additions 
*/
////////////////////////////////////////////////////////////////////////
// Global header file includes
////////////////////////////////////////////////////////////////////////
// system level definition file which contains the/*
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


////////////////////////////////////////////////////////////////////////
// Local header file includes / local defines
////////////////////////////////////////////////////////////////////////

module	tlu_hyperv (/*AUTOARG*/
    // outputs
    tlu_htickcmp_rw_e, tlu_gl_rw_m, tlu_hpstate_din_sel0, tlu_hpstate_din_sel1,
    tlu_hpstate_din_sel2, tlu_hpstate_din_sel3, tlu_update_hpstate_l_w2,
    tlu_htickcmp_intdis, tlu_gl_lvl0, tlu_gl_lvl1, tlu_gl_lvl2, tlu_gl_lvl3, 
    tlu_htstate_rw_d, tlu_wr_hintp_g, tlu_htstate_rw_g, tlu_set_hintp_sel_g, 
    tlu_htba_en_l, tlu_scpd_wr_addr_g, tlu_scpd_wr_vld_g, tlu_scpd_rd_vld_m, 
    tlu_scpd_rd_addr_m, tlu_hscpd_dacc_excpt_m, tlu_hyperv_rdpr_sel, 
    tlu_exu_agp_swap, tlu_exu_agp, tlu_cpu_mondo_cmp, tlu_dev_mondo_cmp, 
    tlu_resum_err_cmp, tlu_asi_queue_rd_vld_g, tlu_asi_queue_data_g, tlu_ld_data_vld_g, 
    tlu_va_ill_g, tlu_asi_queue_rdata_g, tlu_qtail_dacc_excpt_m, tlu_asi_write_g, so, 
    inc_ind_asi_wr_indr, inc_ind_asi_wr_inrr, inc_ind_asi_rd_invr, tlu_local_thrid_g, 
    // inputs
    ifu_tlu_thrid_d, ifu_tlu_sraddr_d, tlu_wsr_data_w_global, tlu_tickcmp_sel, 
    tlu_thrd_traps_w2, tlu_wsr_inst_nq_g, tlu_dnrtry0_inst_g, tlu_dnrtry1_inst_g, 
    tlu_dnrtry2_inst_g, tlu_dnrtry3_inst_g, tlu_dnrtry_global_g, tlu_tick_ctl_din, 
    tlu_pstate_priv, tlu_select_tba_w2, tlu_hpstate_priv, tlu_hpstate_enb, 
    tlu_asi_state_e, ifu_lsu_alt_space_e, ifu_lsu_ld_inst_e, ifu_lsu_st_inst_e, 
    lsu_tlu_early_flush_w, tlu_por_rstint_g, tlu_agp_tid_w2, // exu_lsu_ldst_va_e, 
    tlu_local_flush_w, ifu_tlu_flush_fd_w, tlu_inst_vld_m, tlu_lsu_int_ldxa_vld_w2,
    tlu_asi_data_nf_vld_w2, lsu_tlu_ldst_va_m, arst_l, grst_l, rst_tri_en, 
    si, se, rclk);

//=================================================
// output
//=================================================
// mux select to tdp to access the hyper-privileged ASR registers
output tlu_htickcmp_rw_e;
output tlu_gl_rw_m;
// output tlu_gl_rw_g;

// global switch indicator - used to be in tlu_tcl
output [1:0] tlu_exu_agp; 
// output [1:0] tlu_exu_agp_tid;  
output tlu_exu_agp_swap; 
//
// global register outputs
output [2-1:0] tlu_gl_lvl0; // global register value t0 
output [2-1:0] tlu_gl_lvl1; // global register value t1 
output [2-1:0] tlu_gl_lvl2; // global register value t2 
output [2-1:0] tlu_gl_lvl3; // global register value t3 

// mux selects to choose source of data to store in the hpstate regs 
output [1:0] tlu_hpstate_din_sel0;
output [1:0] tlu_hpstate_din_sel1;
output [1:0] tlu_hpstate_din_sel2;
output [1:0] tlu_hpstate_din_sel3;
//
// mux selects to read out the ASR registers
// output [3:0] tlu_rdpr_mx5_sel; 
output [4:0] tlu_hyperv_rdpr_sel; 
// signal indicating mx5 is used
// output       tlu_rdpr_mx5_active; 
//
// hpstate write enable
// modified for timing
// output [`TLU_THRD_NUM-1:0] tlu_update_hpstate_l_g;
output [4-1:0] tlu_update_hpstate_l_w2;
//
// htick compare reg write enable 
// output [`TLU_THRD_NUM-1:0] htickcmp_intdis_en;
// htick compare interrupt disable
output tlu_htickcmp_intdis;

//  clock enable for hintp regs.
// output [`TLU_THRD_NUM-1:0] tlu_hintp_en_l_g;
// wr control for hintp regs.
output [4-1:0] tlu_wr_hintp_g;         
// set control for hintp regs.
// output [`TLU_THRD_NUM-1:0] tlu_set_hintp_g;
output [4-1:0] tlu_set_hintp_sel_g;
//
// update enable for the htba registers 
output [4-1:0] tlu_htba_en_l;
// 
// hypervisor lite indicator
// output [`TLU_THRD_NUM-1:0] tlu_hyper_lite;
// 
// hyper-privileged scratch-pad data access exception 
output tlu_hscpd_dacc_excpt_m;
//
// store instruction to alt space
output tlu_asi_write_g;
output [4-1:0] inc_ind_asi_wr_indr;
output [4-1:0] inc_ind_asi_wr_inrr;
output [4-1:0] inc_ind_asi_rd_invr;
output [4-1:0] tlu_local_thrid_g;

// read and write valids for the scratch-pad 
output tlu_scpd_rd_vld_m, tlu_scpd_wr_vld_g;
output [5-1:0] tlu_scpd_wr_addr_g;
output [5-1:0] tlu_scpd_rd_addr_m;
//
// decode of the htstate register write/read
output tlu_htstate_rw_d; 
output tlu_htstate_rw_g; 
// 
// select for rdpr read in tlu_tdp
// output tlu_htba_rsr_sel; 
// 
// 
output [4-1:0] tlu_cpu_mondo_cmp; 
output [4-1:0] tlu_dev_mondo_cmp; 
output [4-1:0] tlu_resum_err_cmp; 
output tlu_qtail_dacc_excpt_m; 
//
// asi queue rdata output
output [8-1:0] tlu_asi_queue_rdata_g;
output tlu_asi_queue_rd_vld_g;
output tlu_ld_data_vld_g;
// output tlu_scpd_rd_vld_g;
output tlu_va_ill_g;
// output tlu_va_all_zero_g;
output tlu_lsu_int_ldxa_vld_w2;
//
// global nets
output so;

//=================================================
// input
//=================================================
// non-thread specific por reset indicator
// modified for timing
// input [1:0] ifu_tlu_thrid_e; 
input [1:0] ifu_tlu_thrid_d; 
// 
// staged write asr instruction
// modified for timing 
// input tlu_wsr_inst_g;
input tlu_wsr_inst_nq_g;

// non-threaded por instruciton 
input [4-1:0] tlu_por_rstint_g;
// 
// addr of sr(st/pr)
input [7-1:0] ifu_tlu_sraddr_d;      
//
// staged pr/st data from irf.
input [4-1:0] tlu_wsr_data_w_global; 

// restored global value for done/retry instructions 
input [2-1:0] tlu_dnrtry_global_g;

// thread specific done and retry signals
input tlu_dnrtry0_inst_g, tlu_dnrtry1_inst_g;
input tlu_dnrtry2_inst_g, tlu_dnrtry3_inst_g;
// 
// thread specific trap assetion signals
// modified due to timing
// input tlu_thrd0_traps, tlu_thrd1_traps;
// input tlu_thrd2_traps, tlu_thrd3_traps;
input [4-1:0] tlu_thrd_traps_w2; 
// 
// indicating whether the trap is supervisor or hypervisor 
// added for bug 2889
// modified due to timing
// input tlu_select_tba_g; 
input tlu_select_tba_w2; 
//
input tlu_tick_ctl_din;
// htick compare match
// input tlu_htick_match;	
//
// select src for tickcmp 
input [4-1:0] tlu_tickcmp_sel;   
// 
// pstate - supervisor privilege  
input [4-1:0] tlu_pstate_priv;   
// hpstate - hypervisor privilege  
input [4-1:0] tlu_hpstate_priv;   
// hpstate - hypervisor lite enb  
input [4-1:0] tlu_hpstate_enb;   
// thread id for the agp that needs swap
// modified for timing
// input [1:0] tlu_agp_tid_g;
input [1:0] tlu_agp_tid_w2;
// ASI addresses and valid bits for decode to 
// access the ASI registers
input 	    ifu_lsu_alt_space_e; // valid bit for the ASI data
input 	    ifu_lsu_ld_inst_e;  // read enable
input 	    ifu_lsu_st_inst_e;  // write enable
// replaced due to timing violations
// input 	    tlu_nlsu_flush_w;   // trap flush 
input 	    tlu_local_flush_w;   // trap flush 
input 	    ifu_tlu_flush_fd_w;   // trap flush 
input 	    lsu_tlu_early_flush_w;   // trap flush 
input 	    tlu_asi_data_nf_vld_w2;   // trap flush 
input 	    tlu_inst_vld_m;     // instruciton valid 
//
// asi to be read/written
input [8-1:0] tlu_asi_state_e;  
// input [`TLU_ASI_VA_WIDTH-1:0] exu_lsu_ldst_va_e;  
input [10-1:0] lsu_tlu_ldst_va_m; 
// head and tail pointers
input [8-1:0] tlu_asi_queue_data_g;

//reset
// input tlu_rst_l;  // unit reset
input grst_l ;  // unit reset
input arst_l ;  // unit reset
input rst_tri_en ;  // unit reset
//clk
input rclk;
//
// global nets
input si, se;

/*AUTOOUTPUT*/
//
// staged thread id
wire [1:0] thrid_e, thrid_m, thrid_g;
// decoded thread id
wire [4-1:0] thread_sel_id_e; 
wire [4-1:0] thread_sel_id_m; 
wire [4-1:0] thread_sel_id_g; 
wire [4-1:0] thread_sel_id_w2; 
// 
// flush due to "early traps"
wire 	    local_flush_all_w;   // trap flush 
wire 	    local_flush_all_w2;   // trap flush 
//
// por indicators generations 
wire por_rstint0_g, por_rstint1_g;
wire por_rstint2_g, por_rstint3_g;
//
// GL register definitions - one GL register/thread
wire [2-1:0] gl_lvl0, gl_lvl1, gl_lvl2, gl_lvl3;  
// updated value of the GL registers 
wire [2-1:0] gl_lvl0_new, gl_lvl1_new;  
wire [2-1:0] gl_lvl2_new, gl_lvl3_new;  
wire [2-1:0] gl_lvl0_update_g, gl_lvl1_update_g;  
wire [2-1:0] gl_lvl2_update_g, gl_lvl3_update_g;  
wire [2-1:0] gl_lvl0_update_w2, gl_lvl1_update_w2;  
wire [2-1:0] gl_lvl2_update_w2, gl_lvl3_update_w2;  
wire [2-1:0] wsr_gl_lvl0_data, wsr_gl_lvl1_data;  
wire [2-1:0] wsr_gl_lvl2_data, wsr_gl_lvl3_data;  
wire [2-1:0] dnrtry_gl_lvl0_data, dnrtry_gl_lvl1_data;  
wire [2-1:0] dnrtry_gl_lvl2_data, dnrtry_gl_lvl3_data;  
// value to be incremented for the GL registers
// modified due to timing
// wire gl0_incr_sel, gl1_incr_sel, gl2_incr_sel, gl3_incr_sel; 
// wire[1:0] gl_lvl0_incr, gl_lvl1_incr, gl_lvl2_incr, gl_lvl3_incr; 
// indicators to signal gl is at certain pre-defined values 
// added for timing
wire [4-1:0] gl_incr_sel_w2; 
wire [4-1:0] gl_update_sel_g; 
wire [4-1:0] gl_update_sel_w2; 
wire [4-1:0] gl_priv_max_sel_w2; 
wire gl_lvl0_at_maxgl, gl_lvl1_at_maxgl; 
wire gl_lvl2_at_maxgl, gl_lvl3_at_maxgl;
wire gl_lvl0_at_maxstl, gl_lvl1_at_maxstl;
wire gl_lvl2_at_maxstl, gl_lvl3_at_maxstl;
// gl write enables  
wire gl0_en, gl1_en, gl2_en, gl3_en; 
wire [4-1:0] dnrtry_inst_w2;
// maxgl control
wire [4-1:0] maxstl_gl_dnrtry_sel;
wire [4-1:0] maxstl_gl_wr_sel;
wire [4-1:0] maxgl_gl_wr_sel;
// decoded thread info for agp swap
// wire [`TLU_THRD_NUM-1:0] agp_thrid;
wire [4-1:0] agp_thrid_w2;
// modified for for timing fix
// wire agp_swap; 
// wire [1:0] agp_new; 
wire wsr_inst_g, wsr_inst_w2; 
wire agp_swap_w2, agp_swap_w3; 
wire [1:0] agp_new_w2, agp_new_w3; 
//
// hyper-privileged ASR registers
wire [4-1:0] tlu_wr_hintp_g;         
wire htba_rw_d, hpstate_rw_d, htstate_rw_d, hintp_rw_d; 
wire htickcmp_rw_d, gl_rw_d; 
wire htba_rw_e, hpstate_rw_e, htstate_rw_e, hintp_rw_e; 
wire htickcmp_rw_e, gl_rw_e;
wire htba_rw_m, hpstate_rw_m, htstate_rw_m, hintp_rw_m; 
wire htickcmp_rw_m, gl_rw_m; 
wire htba_rw_g, hpstate_rw_g, htstate_rw_g, hintp_rw_g; 
wire htickcmp_rw_g, gl_rw_g;
wire [4-1:0] htickcmp_intdis_en;
wire hpstate_rw_w2;
//
// hyper-lite mode indicator
wire [4-1:0] tlu_hyper_lite;
// 
// contorls to update the hpstate registers
// wire update_hpstate0_g, update_hpstate1_g;
// wire update_hpstate2_g, update_hpstate3_g;
wire [4-1:0] update_hpstate_g; 
wire [4-1:0] update_hpstate_w2; 
//
// htick interrupt disable control
wire htick_intdis0, htick_intdis1;
wire htick_intdis2, htick_intdis3;
//
// local addr of sr(st/pr) 
wire [7-3:0] sraddr;

// ASI_QUEUE for hyper visor
// thread 0
wire [8-1:0] cpu_mondo0_head;
wire [8-1:0] cpu_mondo0_tail;
wire [8-1:0] dev_mondo0_head;
wire [8-1:0] dev_mondo0_tail;
wire [8-1:0] resum_err0_head;
wire [8-1:0] resum_err0_tail;
wire [8-1:0] nresum_err0_head;
wire [8-1:0] nresum_err0_tail;
// thread 1
wire [8-1:0] cpu_mondo1_head;
wire [8-1:0] cpu_mondo1_tail;
wire [8-1:0] dev_mondo1_head;
wire [8-1:0] dev_mondo1_tail;
wire [8-1:0] resum_err1_head;
wire [8-1:0] resum_err1_tail;
wire [8-1:0] nresum_err1_head;
wire [8-1:0] nresum_err1_tail;
// thread 2
wire [8-1:0] cpu_mondo2_head;
wire [8-1:0] cpu_mondo2_tail;
wire [8-1:0] dev_mondo2_head;
wire [8-1:0] dev_mondo2_tail;
wire [8-1:0] resum_err2_head;
wire [8-1:0] resum_err2_tail;
wire [8-1:0] nresum_err2_head;
wire [8-1:0] nresum_err2_tail;
// thread 3
wire [8-1:0] cpu_mondo3_head;
wire [8-1:0] cpu_mondo3_tail;
wire [8-1:0] dev_mondo3_head;
wire [8-1:0] dev_mondo3_tail;
wire [8-1:0] resum_err3_head;
wire [8-1:0] resum_err3_tail;
wire [8-1:0] nresum_err3_head;
wire [8-1:0] nresum_err3_tail;
//
// read asi data from the asi queues
wire [8-1:0] cpu_mondo_hd_rdata;
wire [8-1:0] cpu_mondo_ta_rdata;
wire [8-1:0] dev_mondo_hd_rdata;
wire [8-1:0] dev_mondo_ta_rdata;
wire [8-1:0] resum_err_hd_rdata;
wire [8-1:0] resum_err_ta_rdata;
wire [8-1:0] nresum_err_hd_rdata;
wire [8-1:0] nresum_err_ta_rdata;
wire [8-1:0] asi_queue_rdata1_g;
wire [8-1:0] asi_queue_rdata2_g;
wire asi_qrdata_mx_sel2;
//
// head and tail comparison results
// modified due to timing violations
// wire cpu_mondo_head_rw_e,  cpu_mondo_tail_rw_e;
// wire dev_mondo_head_rw_e,  dev_mondo_tail_rw_e;
// wire resum_err_head_rw_e,  resum_err_tail_rw_e;
// wire nresum_err_head_rw_e, nresum_err_tail_rw_e;
//
wire cpu_mondo_head_rw_m,  cpu_mondo_tail_rw_m;
wire dev_mondo_head_rw_m,  dev_mondo_tail_rw_m;
wire resum_err_head_rw_m,  resum_err_tail_rw_m;
wire nresum_err_head_rw_m, nresum_err_tail_rw_m;
//
wire cpu_mondo_head_rw_g,  cpu_mondo_tail_rw_g;
wire dev_mondo_head_rw_g,  dev_mondo_tail_rw_g;
wire resum_err_head_rw_g,  resum_err_tail_rw_g;
wire nresum_err_head_rw_g, nresum_err_tail_rw_g;
// creating one-hot selects
// wire cpu_mondo_hd_onehot_g, cpu_mondo_ta_onehot_g;
// wire dev_mondo_hd_onehot_g, dev_mondo_ta_onehot_g;
// wire resum_err_hd_onehot_g, resum_err_ta_onehot_g;
// wire nresum_err_hd_onehot_g, nresum_err_ta_onehot_g;
// read 
wire [4-1:0] cpu_mondo_head_rd_g;
wire cpu_mondo_hd_rd_g;
wire [4-1:0] cpu_mondo_tail_rd_g;
wire cpu_mondo_ta_rd_g;
wire [4-1:0] dev_mondo_head_rd_g;
wire dev_mondo_hd_rd_g;
wire [4-1:0] dev_mondo_tail_rd_g;
wire dev_mondo_ta_rd_g;
wire [4-1:0] resum_err_head_rd_g;
wire resum_err_hd_rd_g;
wire [4-1:0] resum_err_tail_rd_g;
wire resum_err_ta_rd_g;
wire [4-1:0] nresum_err_head_rd_g; 
wire nresum_err_hd_rd_g; 
wire [4-1:0] nresum_err_tail_rd_g;
wire nresum_err_ta_rd_g;
wire [3:0] asi_qrdata_mx1_sel;
wire [3:0] asi_qrdata_mx2_sel;
// write 
wire [4-1:0] cpu_mondo_head_wr_g;
wire [4-1:0] cpu_mondo_tail_wr_g;
wire [4-1:0] dev_mondo_head_wr_g;
wire [4-1:0] dev_mondo_tail_wr_g;
wire [4-1:0] resum_err_head_wr_g;
wire [4-1:0] resum_err_tail_wr_g;
wire [4-1:0] nresum_err_head_wr_g; 
wire [4-1:0] nresum_err_tail_wr_g;
// 
// ASI va address
// modified due to timing fix
// wire [`TLU_ASI_VA_WIDTH-1:0] tlu_ldst_va_e;
wire [10-1:0] tlu_ldst_va_m;
//
// ASI read or write enables
wire asi_queue_write_e;
wire asi_queue_read_e;
wire asi_queue_write_pq_m; 
wire asi_queue_read_pq_m;
wire asi_queue_write_m; 
wire asi_queue_read_m;
wire asi_queue_write_uf_g; 
// wire asi_queue_read_uf_g;
wire asi_queue_write_g; 
wire asi_queue_read_g;
//
// decoded ASI addresses 
// ASI QUE
wire asi_queue_rw_e, asi_queue_rw_m, asi_queue_rw_g;
wire asi_inrr_rw_e, asi_inrr_rw_m, asi_inrr_rw_g; 
wire asi_indr_rw_e, asi_indr_rw_m, asi_indr_rw_g; 
wire asi_invr_rw_e, asi_invr_rw_m, asi_invr_rw_g; 
// supervisor scratch-pad asi state
wire asi_scpd_rw_e, asi_scpd_rw_m; 
// hypervisor scratch-pad asi state
wire asi_hscpd_rw_e, asi_hscpd_rw_m; 
wire asi_scpd_rw_vld_m, asi_scpd_rw_vld_g; 
// legal va addresses
// modified due to timing
// wire que_legal_va_e;
wire que_legal_va_m;
// modified due to timing
// illegal va range indicator
// wire que_ill_va_e, 
wire que_ill_va_m, que_ill_va_g;
// modified due to timing
// wire scpd_ill_va_e, 
wire scpd_ill_va_m, scpd_ill_va_g;
// alignment checking
wire va_not_baligned_m; 
// no longer necessary
// wire va_all_zero_e, va_all_zero_m, va_all_zero_g;
// write operation to queue tails 
wire qtail_write_m;
//
// data_access_exception for hyper-privileged scratch-pad
wire hscpd_data_acc_excpt_m;
wire hscpd_data_acc_excpt_pq_m;
// write to hypervisor scratch-pad using 0x20 ASI state
wire hscpd_priv_asi_acc_m;
// access hypervisor scratchpad va addresses
wire hscpd_va_rw_m; 
//
// relevant portion of the va address for the scratch-pad 
// modified due to timing fix
// wire [`TLU_ASI_SCPD_VA_HI:0]       scpd_addr_va_e;
wire [3-1:0] scpd_addr_va_m;
wire [3-1:0] scpd_addr_va_g;
//
// load instruction data valid
wire asi_ld_addr_vld_m, asi_ld_addr_vld_g;

// privilege or hyper-privileged address indicators
wire asr_hyperp, asr_priv;
//
// local reset
wire local_rst_l; 
wire local_rst; 
// local clk
wire clk; 

////////////////////////////////////////////////////////////////////////
// local reset
////////////////////////////////////////////////////////////////////////

dffrl_async dffrl_local_rst_l(
    .din  (grst_l),
    .clk  (clk),
    .rst_l(arst_l),
    .q    (local_rst_l),
    .se   (se),
    .si   (),
    .so   ()
); 

assign local_rst = ~local_rst_l;

////////////////////////////////////////////////////////////////////////
// local clock
////////////////////////////////////////////////////////////////////////

assign clk = rclk; 

////////////////////////////////////////////////////////////////////////
// Hyper-lite mode indicator
////////////////////////////////////////////////////////////////////////

assign tlu_hyper_lite[0] = 
           tlu_hpstate_priv[0]| (~tlu_hpstate_enb[0] & tlu_pstate_priv[0]); 
assign tlu_hyper_lite[1] = 
           tlu_hpstate_priv[1]| (~tlu_hpstate_enb[1] & tlu_pstate_priv[1]); 
assign tlu_hyper_lite[2] = 
           tlu_hpstate_priv[2]| (~tlu_hpstate_enb[2] & tlu_pstate_priv[2]); 
assign tlu_hyper_lite[3] = 
           tlu_hpstate_priv[3]| (~tlu_hpstate_enb[3] & tlu_pstate_priv[3]); 

////////////////////////////////////////////////////////////////////////
// Thread ID staging and decoding 
////////////////////////////////////////////////////////////////////////
//
assign	thread_sel_id_e[0] = ~thrid_e[1] & ~thrid_e[0];
assign	thread_sel_id_e[1] = ~thrid_e[1] &  thrid_e[0];
assign	thread_sel_id_e[2] =  thrid_e[1] & ~thrid_e[0];
assign	thread_sel_id_e[3] =  thrid_e[1] &  thrid_e[0];

dff #(4) dff_thread_sel_id_m (
    .din (thread_sel_id_e[4-1:0]),
    .q   (thread_sel_id_m[4-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff #(4) dff_thread_id_sel_g (
    .din (thread_sel_id_m[4-1:0]),
    .q   (thread_sel_id_g[4-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff #(4) dff_thread_id_sel_w2 (
    .din (thread_sel_id_g[4-1:0]),
    .q   (thread_sel_id_w2[4-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff #(2) dff_thrid_e (
    .din (ifu_tlu_thrid_d[1:0]),
    .q   (thrid_e[1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff #(2) dff_thrid_m (
    .din (thrid_e[1:0]),
    .q   (thrid_m[1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff #(2) dff_thrid_g (
    .din (thrid_m[1:0]),
    .q   (thrid_g[1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// modified due to rte failure
assign tlu_local_thrid_g[0] = ~(|thrid_g[1:0]); 
assign tlu_local_thrid_g[1] = ~thrid_g[1] &  thrid_g[0]; 
assign tlu_local_thrid_g[2] =  thrid_g[1] & ~thrid_g[0]; 
assign tlu_local_thrid_g[3] =  (&thrid_g[1:0]); 

/*
assign tlu_local_thrid_g[`TLU_THRD_NUM-1:0] = 
           thread_sel_id_g[`TLU_THRD_NUM-1:0];
*/

////////////////////////////////////////////////////////////////////////
// POR indicator generation 
////////////////////////////////////////////////////////////////////////
//
// modified for bug 1945
/*
assign	por_rstint0_g = tlu_por_rstint_g & thread_sel_id_g[0];
assign	por_rstint1_g = tlu_por_rstint_g & thread_sel_id_g[1];
assign	por_rstint2_g = tlu_por_rstint_g & thread_sel_id_g[2];
assign	por_rstint3_g = tlu_por_rstint_g & thread_sel_id_g[3];
*/
assign	por_rstint0_g = tlu_por_rstint_g[0];
assign	por_rstint1_g = tlu_por_rstint_g[1];
assign	por_rstint2_g = tlu_por_rstint_g[2];
assign	por_rstint3_g = tlu_por_rstint_g[3];

////////////////////////////////////////////////////////////////////////
// Hyper-privileged ASR decodes 
////////////////////////////////////////////////////////////////////////
//
// flush signal - modified for timing
// assign  local_flush_all_w = tlu_nlsu_flush_w | lsu_tlu_early_flush_w;
assign  local_flush_all_w = 
            tlu_local_flush_w | lsu_tlu_early_flush_w | ifu_tlu_flush_fd_w;

dffr dffr_local_flush_all_w2 (
    .din (local_flush_all_w),
    .q   (local_flush_all_w2),
    .rst (local_rst),
    .clk (clk),
    .se  (se),
    .si  (),
    .so ()
);

// added for timing
assign tlu_lsu_int_ldxa_vld_w2 = 
           tlu_asi_data_nf_vld_w2 & ~local_flush_all_w2;

assign  asr_hyperp = ifu_tlu_sraddr_d[7-1];
assign  asr_priv   = ifu_tlu_sraddr_d[7-2];

assign	sraddr[7-3:0]	=	
            ifu_tlu_sraddr_d[7-3:0];

// hypervisor tick compare - 0x1f - hyper-priviledged
assign htickcmp_rw_d = sraddr[4] & sraddr[3] & sraddr[2] & sraddr[1] & sraddr[0] &
			           asr_hyperp;
//
// hypervisor processor state - 0x00 - hyper-priviledged
assign hpstate_rw_d = ~sraddr[4] & ~sraddr[3] & ~sraddr[2] & ~sraddr[1] & ~sraddr[0] &
			           asr_hyperp;
// 
// hypervisor trap state - 0x01 - hyper-priviledged
assign htstate_rw_d = ~sraddr[4] & ~sraddr[3] & ~sraddr[2] & ~sraddr[1] & sraddr[0] &
			           asr_hyperp;

assign tlu_htstate_rw_d = htstate_rw_d;
// 
// hypervisor interrupt pending - 0x03 - hyper-priviledged
assign hintp_rw_d = ~sraddr[4] & ~sraddr[3] & ~sraddr[2] & sraddr[1] & sraddr[0] &
			         asr_hyperp;
// 
// hypervisor trap base address - 0x05 - hyper-priviledged
assign htba_rw_d = ~sraddr[4] & ~sraddr[3] & sraddr[2] & ~sraddr[1] & sraddr[0] &
			       asr_hyperp;	

// global register - 0x10 - privileged
assign gl_rw_d = sraddr[4] & ~sraddr[3] & ~sraddr[2] & ~sraddr[1] & ~sraddr[0] &
			     asr_priv;
//
// staging of the ASR decoded controls
// staging from d to e stage
dff dff_htba_rw_d_e (
    .din (htba_rw_d),
    .q   (htba_rw_e),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_hpstate_rw_d_e (
    .din (hpstate_rw_d),
    .q   (hpstate_rw_e),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_htstate_rw_d_e (
    .din (htstate_rw_d),
    .q   (htstate_rw_e),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_hintp_rw_e (
    .din (hintp_rw_d),
    .q   (hintp_rw_e),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_htickcmp_rw_d_e (
    .din (htickcmp_rw_d),
    .q   (htickcmp_rw_e),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_gl_rw_d_e (
    .din (gl_rw_d),
    .q   (gl_rw_e),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

// staging from e to m stage
dff dff_htba_rw_m_m (
    .din (htba_rw_e),
    .q   (htba_rw_m),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_hpstate_rw_m_m (
    .din (hpstate_rw_e),
    .q   (hpstate_rw_m),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_htstate_rw_m_m (
    .din (htstate_rw_e),
    .q   (htstate_rw_m),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_hintp_rw_m_m (
    .din (hintp_rw_e),
    .q   (hintp_rw_m),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_htickcmp_rw_m_m (
    .din (htickcmp_rw_e),
    .q   (htickcmp_rw_m),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_gl_rw_m_m (
    .din (gl_rw_e),
    .q   (gl_rw_m),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

// staging from e to g stage
dff dff_gl_rw_m_g (
    .din (gl_rw_m),
    .q   (gl_rw_g),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_hpstate_rw_m_g (
    .din (hpstate_rw_m),
    .q   (hpstate_rw_g),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_htickcmp_rw_m_g (
    .din (htickcmp_rw_m),
    .q   (htickcmp_rw_g),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_htba_rw_m_g (
    .din (htba_rw_m),
    .q   (htba_rw_g),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_hintp_rw_g (
    .din (hintp_rw_m),
    .q   (hintp_rw_g),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_htstate_rw_m_g (
    .din (htstate_rw_m),
    .q   (htstate_rw_g),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// stage to w2
dff dff_hpstate_rw_m_w2 (
    .din (hpstate_rw_g),
    .q   (hpstate_rw_w2),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

// constructing the mux select to access the 
// hyper-privileged ASR registers
//
assign tlu_htickcmp_rw_e = htickcmp_rw_e;
assign tlu_htstate_rw_g = htstate_rw_g;
// 
// using htba_rw_e as one of the selects for rdpr read in tlu_tdp
// assign tlu_htba_rsr_sel = htba_rw_e;
//
// construciton mux selects for tlu_rdpr_mx5 in tlu_tdp to read out
// the ASR information
//
assign	tlu_hyperv_rdpr_sel[0] = gl_rw_e; 
assign	tlu_hyperv_rdpr_sel[1] = hintp_rw_e; 
assign	tlu_hyperv_rdpr_sel[2] = hpstate_rw_e; 
assign	tlu_hyperv_rdpr_sel[3] = htstate_rw_e; 
assign	tlu_hyperv_rdpr_sel[4] = htba_rw_e; 
// assign  tlu_rdpr_mx5_active = |(tlu_rdpr_mx5_sel[3:0]);
//
// buffer gl_rw_g for agp_tid_sel in tlu_tcl
// modified for timing 
// assign tlu_gl_rw_g = gl_rw_g;
assign tlu_gl_rw_m = gl_rw_m;

////////////////////////////////////////////////////////////////////////
// GL register controls 
////////////////////////////////////////////////////////////////////////

dffr #(4)  dffr_gl_update_sel_w2 (
    .din (gl_update_sel_g[4-1:0]), 
    .q   (gl_update_sel_w2[4-1:0]),
    .rst (local_rst),
    .clk (clk),
    .se  (se),
    .si  (),
    .so ()
);

dffr #(4) dffr_dnrtry_inst_w2 (
    .din ({tlu_dnrtry3_inst_g, tlu_dnrtry2_inst_g,
           tlu_dnrtry1_inst_g,tlu_dnrtry0_inst_g}),
    .q   (dnrtry_inst_w2[4-1:0]),
    .rst (local_rst),
    .clk (clk),
    .se  (se),
    .si  (),
    .so ()
);
//
// added for timing 
assign wsr_inst_g = tlu_wsr_inst_nq_g & ~ifu_tlu_flush_fd_w;

dffr dffr_wsr_inst_w2 (
    .din (wsr_inst_g),
    .q   (wsr_inst_w2),
    .rst (local_rst),
    .clk (clk),
    .se  (se),
    .si  (),
    .so ()
);

// THREAD0

assign gl_lvl0_at_maxgl  = (gl_lvl0[2-1:0] == 2'b11);
assign gl_lvl0_at_maxstl = (gl_lvl0[2-1:0] == 2'b10);
// 
// generate the control to prevent writing beyond maxstl or maxgl

assign maxstl_gl_wr_sel[0] = 
           ~tlu_hyper_lite[0] & 
           (tlu_wsr_data_w_global[4-1:0] > {1'b0,3'b010}); 
assign maxstl_gl_wr_sel[1] = 
           ~tlu_hyper_lite[1] & 
           (tlu_wsr_data_w_global[4-1:0] > {1'b0,3'b010}); 
assign maxstl_gl_wr_sel[2] = 
           ~tlu_hyper_lite[2] & 
           (tlu_wsr_data_w_global[4-1:0] > {1'b0,3'b010});
assign maxstl_gl_wr_sel[3] = 
           ~tlu_hyper_lite[3] & 
           (tlu_wsr_data_w_global[4-1:0] > {1'b0,3'b010}); 
//
// added for bug 79252 
assign maxstl_gl_dnrtry_sel[0] = 
           ~tlu_hyper_lite[0] & 
           (&tlu_dnrtry_global_g[2-1:0]);
assign maxstl_gl_dnrtry_sel[1] = 
           ~tlu_hyper_lite[1] & 
           (&tlu_dnrtry_global_g[2-1:0]);
assign maxstl_gl_dnrtry_sel[2] = 
           ~tlu_hyper_lite[2] & 
           (&tlu_dnrtry_global_g[2-1:0]);
assign maxstl_gl_dnrtry_sel[3] = 
           ~tlu_hyper_lite[3] & 
           (&tlu_dnrtry_global_g[2-1:0]); 
//
// added for bug 79252
assign dnrtry_gl_lvl0_data[2-1:0] = 
            (maxstl_gl_dnrtry_sel[0])? 2'b10:
            tlu_dnrtry_global_g[2-1:0];
assign dnrtry_gl_lvl1_data[2-1:0] = 
            (maxstl_gl_dnrtry_sel[1])? 2'b10:
            tlu_dnrtry_global_g[2-1:0];
assign dnrtry_gl_lvl2_data[2-1:0] = 
            (maxstl_gl_dnrtry_sel[2])? 2'b10:
            tlu_dnrtry_global_g[2-1:0];
assign dnrtry_gl_lvl3_data[2-1:0] = 
            (maxstl_gl_dnrtry_sel[3])? 2'b10:
            tlu_dnrtry_global_g[2-1:0];

// 
// maxgl cap
assign maxgl_gl_wr_sel[0] = 
           tlu_hyper_lite[0] & 
           (tlu_wsr_data_w_global[4-1:0] > 4'b0011); 
assign maxgl_gl_wr_sel[1] = 
           tlu_hyper_lite[1] & 
           (tlu_wsr_data_w_global[4-1:0] > 4'b0011); 
assign maxgl_gl_wr_sel[2] = 
           tlu_hyper_lite[2] & 
           (tlu_wsr_data_w_global[4-1:0] > 4'b0011); 
assign maxgl_gl_wr_sel[3] = 
           tlu_hyper_lite[3] & 
           (tlu_wsr_data_w_global[4-1:0] > 4'b0011); 
//
// trap level to be incremented if thread not at MAXGL and not in redmode
// modified for bug 2889
// modified due to timing
/*
assign gl0_incr_sel = 
           tlu_thrd0_traps & (~(gl_lvl0_at_maxgl | tlu_select_tba_g) |  
           (~gl_lvl0_at_maxstl & tlu_select_tba_g));
           
assign gl_lvl0_incr[1:0] = {1'b0, gl0_incr_sel};

assign gl0_en = (gl_rw_g & wsr_inst_g & thread_sel_id_g[0]) | 
			     gl0_incr_sel | local_rst |	por_rstint0_g   | 
                 tlu_dnrtry0_inst_g;  

assign gl_lvl0_new[`TSA_GLOBAL_WIDTH-1:0] = 
	        (gl_rw_g & wsr_inst_g & thread_sel_id_g[0]) ? 
			 wsr_gl_lvl0_data[`TSA_GLOBAL_WIDTH-1:0] : 
	       ((local_rst | por_rstint0_g) ? `MAXGL_GL :
		   ((tlu_dnrtry0_inst_g) ? 
			 tlu_dnrtry_global_g[`TSA_GLOBAL_WIDTH-1:0] :     // done/retry restore
			 gl_lvl0[`TSA_GLOBAL_WIDTH-1:0] + gl_lvl0_incr[1:0])); // trap increments
*/
// modified for bug 79252 
assign wsr_gl_lvl0_data[2-1:0] = 
            (maxstl_gl_wr_sel[0])? 2'b10:
           ((maxgl_gl_wr_sel[0]) ? 2'b11 : 
            tlu_wsr_data_w_global[2-1:0]);
assign gl_lvl0_update_g[2-1:0] = 
	        (gl_rw_g & wsr_inst_g & thread_sel_id_g[0]) ? 
			 wsr_gl_lvl0_data[2-1:0] : 
	       ((local_rst | por_rstint0_g) ? 2'b11 :
			 dnrtry_gl_lvl0_data[2-1:0]);     // done/retry restore
			 // tlu_dnrtry_global_g[`TSA_GLOBAL_WIDTH-1:0]);     // done/retry restore

dffe #(2) dffe_gl_lvl0_update_w2 (
     .din (gl_lvl0_update_g[2-1:0]), 
     .q   (gl_lvl0_update_w2[2-1:0]),
     .en  (gl_update_sel_g[0]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
//
// modified for bug3468 and bug3505
assign gl_incr_sel_w2[0] = 
            tlu_thrd_traps_w2[0] & ~(gl_lvl0_at_maxgl | 
           (gl_lvl0_at_maxstl & tlu_select_tba_w2));
//            tlu_thrd_traps_w2[0] & (~(gl_lvl0_at_maxgl | tlu_select_tba_w2) |  
assign gl_update_sel_g[0] = 
           (gl_rw_g & wsr_inst_g & thread_sel_id_g[0]) | 
			local_rst |	por_rstint0_g | tlu_dnrtry0_inst_g;  
//
// modified for bug3468
assign gl_priv_max_sel_w2[0] =
           (gl_lvl0_at_maxgl & tlu_select_tba_w2) & tlu_thrd_traps_w2[0];
assign gl0_en = 
           gl_incr_sel_w2[0] | gl_update_sel_w2[0] | gl_priv_max_sel_w2[0]; 
// assign gl0_en = gl_incr_sel_w2[0] | gl_update_sel_w2[0]; 

assign gl_lvl0_new[2-1:0] = 
           (gl_update_sel_w2[0]) ? gl_lvl0_update_w2:
           (~gl_update_sel_w2[0] & gl_priv_max_sel_w2[0]) ? 
            2'b10: 
            gl_lvl0[2-1:0] + 2'b01;

// Reset required as processor will start out at gl=1 after reset.
/****************************
   to fix bug 6028 manually in the gate netlist, the following needs
   to be a mux_flop with recirculating path from q to d0 input. But
   to make it resetable, need to brake this recirculating path and
   insert an AND gate such that local_rst_l is ANDed with the q output.

dffe #(`TSA_GLOBAL_WIDTH) dffe_gl0 (
     .din (gl_lvl0_new[`TSA_GLOBAL_WIDTH-1:0]), 
     .q   (gl_lvl0[`TSA_GLOBAL_WIDTH-1:0]),
     .en  (gl0_en), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
******************************/

wire [1:0] gl_lvl0_or_rst, gl_lvl0_or_rst_or_new;

assign gl_lvl0_or_rst[1:0] = gl_lvl0[1:0] & {2{~local_rst}};

assign gl_lvl0_or_rst_or_new[1:0] = (gl0_en&~local_rst) ? gl_lvl0_new[1:0] : gl_lvl0_or_rst[1:0];

dff    #(2) dffe_gl0 (
        .din(gl_lvl0_or_rst_or_new[1:0]) ,
        .q(gl_lvl0[1:0]),
        .clk (clk), .se(se), .si(), .so());

/******************************/


assign tlu_gl_lvl0[2-1:0] = gl_lvl0[2-1:0];



   
// THREAD1

assign gl_lvl1_at_maxgl  = (gl_lvl1[2-1:0] == 2'b11);
assign gl_lvl1_at_maxstl = (gl_lvl1[2-1:0] == 2'b10);
//
// trap level to be incremented if thread not at MAXGL and not in redmode
// modified for bug 2889
// modified due to timing 
/*
assign gl1_incr_sel = 
           tlu_thrd1_traps & (~(gl_lvl1_at_maxgl | tlu_select_tba_g) |  
           (~gl_lvl1_at_maxstl & tlu_select_tba_g));

assign gl_lvl1_incr[1:0] = {1'b0, gl1_incr_sel};

assign gl1_en = (gl_rw_g & wsr_inst_g & thread_sel_id_g[1]) | 
			     gl1_incr_sel | local_rst |	por_rstint1_g   | 
                 tlu_dnrtry1_inst_g;  

assign gl_lvl1_new[`TSA_GLOBAL_WIDTH-1:0] = 
	        (gl_rw_g & wsr_inst_g & thread_sel_id_g[1])? 
			 wsr_gl_lvl1_data[`TSA_GLOBAL_WIDTH-1:0] : 
		   ((local_rst | por_rstint1_g) ? `MAXGL_GL :
		   ((tlu_dnrtry1_inst_g) ? 
			 dnrtry_gl_lvl1_data[`TSA_GLOBAL_WIDTH-1:0] :     // done/retry restore
			 // tlu_dnrtry_global_g[`TSA_GLOBAL_WIDTH-1:0] :     // done/retry restore
			 gl_lvl1[`TSA_GLOBAL_WIDTH-1:0] + gl_lvl1_incr[1:0])); // trap increments

*/
assign wsr_gl_lvl1_data[2-1:0] = 
            (maxstl_gl_wr_sel[1])? 2'b10:
           ((maxgl_gl_wr_sel[1]) ? 2'b11 : 
            tlu_wsr_data_w_global[2-1:0]);
assign gl_lvl1_update_g[2-1:0] = 
	        (gl_rw_g & wsr_inst_g & thread_sel_id_g[1]) ? 
			 wsr_gl_lvl1_data[2-1:0] : 
	       ((local_rst | por_rstint1_g) ? 2'b11 :
			 dnrtry_gl_lvl1_data[2-1:0]);     // done/retry restore
			 // tlu_dnrtry_global_g[`TSA_GLOBAL_WIDTH-1:0]);     // done/retry restore

dffe #(2) dffe_gl_lvl1_update_w2 (
     .din (gl_lvl1_update_g[2-1:0]), 
     .q   (gl_lvl1_update_w2[2-1:0]),
     .en  (gl_update_sel_g[1]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
//
// modified for bug3468 and bug3505
assign gl_incr_sel_w2[1] = 
            tlu_thrd_traps_w2[1] & ~(gl_lvl1_at_maxgl | 
           (gl_lvl1_at_maxstl & tlu_select_tba_w2));
//            tlu_thrd_traps_w2[1] & (~(gl_lvl1_at_maxgl | tlu_select_tba_w2) |  
assign gl_update_sel_g[1] = 
           (gl_rw_g & wsr_inst_g & thread_sel_id_g[1]) | 
			local_rst |	por_rstint1_g | tlu_dnrtry1_inst_g;  
//
// modified for bug3468
assign gl_priv_max_sel_w2[1] =
           (gl_lvl1_at_maxgl & tlu_select_tba_w2) & tlu_thrd_traps_w2[1];
// 
assign gl1_en = 
           gl_incr_sel_w2[1] | gl_update_sel_w2[1] | gl_priv_max_sel_w2[1]; 
// assign gl1_en = gl_incr_sel_w2[1] | gl_update_sel_w2[1]; 

assign gl_lvl1_new[2-1:0] = 
           (gl_update_sel_w2[1]) ? gl_lvl1_update_w2:
           (~gl_update_sel_w2[1] & gl_priv_max_sel_w2[1]) ? 
            2'b10: 
            gl_lvl1[2-1:0] + 2'b01;

// Reset required as processor will start out at gl=1 after reset.
/****************************
   to fix bug 6028 manually in the gate netlist, the following needs
   to be a mux_flop with recirculating path from q to d0 input. But
   to make it resetable, need to brake this recirculating path and
   insert an AND gate such that local_rst_l is ANDed with the q output.
dffe #(`TSA_GLOBAL_WIDTH) dffe_gl1 (
     .din (gl_lvl1_new[`TSA_GLOBAL_WIDTH-1:0]), 
     .q   (gl_lvl1[`TSA_GLOBAL_WIDTH-1:0]),
     .en  (gl1_en), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
******************************/

wire [1:0] gl_lvl1_or_rst, gl_lvl1_or_rst_or_new;

assign gl_lvl1_or_rst[1:0] = gl_lvl1[1:0] & {2{~local_rst}};

assign gl_lvl1_or_rst_or_new[1:0] = (gl1_en&~local_rst) ? gl_lvl1_new[1:0] : gl_lvl1_or_rst[1:0];

dff    #(2) dffe_gl1 (
        .din(gl_lvl1_or_rst_or_new[1:0]) ,
        .q(gl_lvl1[1:0]),
        .clk (clk), .se(se), .si(), .so());

/******************************/


assign tlu_gl_lvl1[2-1:0] = gl_lvl1[2-1:0];

// THREAD2

assign gl_lvl2_at_maxgl  = (gl_lvl2[2-1:0] == 2'b11);
assign gl_lvl2_at_maxstl = (gl_lvl2[2-1:0] == 2'b10);
//
// trap level to be incremented if thread not at MAXGL and not in redmode
// modified for bug 2889
// modified due to timing
/*
assign gl2_incr_sel = 
           tlu_thrd2_traps & (~(gl_lvl2_at_maxgl | tlu_select_tba_g) |  
           (~gl_lvl2_at_maxstl & tlu_select_tba_g));

assign gl_lvl2_incr[1:0] = {1'b0, gl2_incr_sel};

assign gl2_en = (gl_rw_g & wsr_inst_g & thread_sel_id_g[2]) | 
			     gl2_incr_sel | local_rst |	por_rstint2_g   | 
                 tlu_dnrtry2_inst_g;  

assign gl_lvl2_new[`TSA_GLOBAL_WIDTH-1:0] = 
	        (gl_rw_g & wsr_inst_g & thread_sel_id_g[2])? 
			 wsr_gl_lvl2_data[`TSA_GLOBAL_WIDTH-1:0] : 
		   ((local_rst | por_rstint2_g) ? `MAXGL_GL :
		   ((tlu_dnrtry2_inst_g) ? 
			 tlu_dnrtry_global_g[`TSA_GLOBAL_WIDTH-1:0] :     // done/retry restore
			 gl_lvl2[`TSA_GLOBAL_WIDTH-1:0] + gl_lvl2_incr[1:0])); // trap increments
*/
assign wsr_gl_lvl2_data[2-1:0] = 
            (maxstl_gl_wr_sel[2])? 2'b10:
           ((maxgl_gl_wr_sel[2]) ? 2'b11 : 
            tlu_wsr_data_w_global[2-1:0]);
assign gl_lvl2_update_g[2-1:0] = 
	        (gl_rw_g & wsr_inst_g & thread_sel_id_g[2]) ? 
			 wsr_gl_lvl2_data[2-1:0] : 
	       ((local_rst | por_rstint2_g) ? 2'b11 :
			 dnrtry_gl_lvl2_data[2-1:0]);     // done/retry restore
			 // tlu_dnrtry_global_g[`TSA_GLOBAL_WIDTH-1:0]);     // done/retry restore

dffe #(2) dffe_gl_lvl2_update_w2 (
     .din (gl_lvl2_update_g[2-1:0]), 
     .q   (gl_lvl2_update_w2[2-1:0]),
     .en  (gl_update_sel_g[2]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
//
// modified for bug3468 and bug3505
assign gl_incr_sel_w2[2] = 
           tlu_thrd_traps_w2[2] & ~(gl_lvl2_at_maxgl | 
           (gl_lvl2_at_maxstl & tlu_select_tba_w2));
//            tlu_thrd_traps_w2[2] & (~(gl_lvl2_at_maxgl | tlu_select_tba_w2) |  
assign gl_update_sel_g[2] = 
           (gl_rw_g & wsr_inst_g & thread_sel_id_g[2]) | 
			local_rst |	por_rstint2_g | tlu_dnrtry2_inst_g;  
// 
// modified for bug3468
assign gl_priv_max_sel_w2[2] =
           (gl_lvl2_at_maxgl & tlu_select_tba_w2) & tlu_thrd_traps_w2[2];
//
assign gl2_en = 
           gl_incr_sel_w2[2] | gl_update_sel_w2[2] | gl_priv_max_sel_w2[2]; 
// assign gl2_en = gl_incr_sel_w2[2] | gl_update_sel_w2[2]; 

assign gl_lvl2_new[2-1:0] = 
           (gl_update_sel_w2[2]) ? gl_lvl2_update_w2:
           (~gl_update_sel_w2[2] & gl_priv_max_sel_w2[2]) ? 
            2'b10: 
            gl_lvl2[2-1:0] + 2'b01;

// Reset required as processor will start out at gl=1 after reset.
/****************************
   to fix bug 6028 manually in the gate netlist, the following needs
   to be a mux_flop with recirculating path from q to d0 input. But
   to make it resetable, need to brake this recirculating path and
   insert an AND gate such that local_rst_l is ANDed with the q output.
dffe #(`TSA_GLOBAL_WIDTH) dffe_gl2 (
     .din (gl_lvl2_new[`TSA_GLOBAL_WIDTH-1:0]), 
     .q   (gl_lvl2[`TSA_GLOBAL_WIDTH-1:0]),
     .en  (gl2_en), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
******************************/

wire [1:0] gl_lvl2_or_rst, gl_lvl2_or_rst_or_new;

assign gl_lvl2_or_rst[1:0] = gl_lvl2[1:0] & {2{~local_rst}};

assign gl_lvl2_or_rst_or_new[1:0] = (gl2_en&~local_rst) ? gl_lvl2_new[1:0] : gl_lvl2_or_rst[1:0];

dff    #(2) dffe_gl2 (
        .din(gl_lvl2_or_rst_or_new[1:0]) ,
        .q(gl_lvl2[1:0]),
        .clk (clk), .se(se), .si(), .so());

/******************************/

assign tlu_gl_lvl2[2-1:0] = gl_lvl2[2-1:0];

// THREAD3

assign gl_lvl3_at_maxgl  = (gl_lvl3[2-1:0] == 2'b11);
assign gl_lvl3_at_maxstl = (gl_lvl3[2-1:0] == 2'b10);
//
// trap level to be incremented if thread not at MAXGL and not in redmode
// modified for bug 2889
// modified due to timing
/*
assign gl3_incr_sel = 
           tlu_thrd3_traps & (~(gl_lvl3_at_maxgl | tlu_select_tba_g) |  
           (~gl_lvl3_at_maxstl & tlu_select_tba_g));

assign gl_lvl3_incr = {1'b0, gl3_incr_sel};

assign gl3_en = (gl_rw_g & wsr_inst_g & thread_sel_id_g[3]) |
			     gl3_incr_sel | local_rst |	por_rstint3_g   | 
                 tlu_dnrtry3_inst_g;  

assign gl_lvl3_new[`TSA_GLOBAL_WIDTH-1:0] = 
	        (gl_rw_g & wsr_inst_g & thread_sel_id_g[3])? 
			 wsr_gl_lvl3_data[`TSA_GLOBAL_WIDTH-1:0] : 
	       ((local_rst | por_rstint3_g) ? `MAXGL_GL :
		   ((tlu_dnrtry3_inst_g) ? 
			 tlu_dnrtry_global_g[`TSA_GLOBAL_WIDTH-1:0] :     // done/retry restore
		     gl_lvl3[`TSA_GLOBAL_WIDTH-1:0] + gl_lvl3_incr[1:0])); // trap increments
*/
assign wsr_gl_lvl3_data[2-1:0] = 
            (maxstl_gl_wr_sel[3])? 2'b10:
           ((maxgl_gl_wr_sel[3]) ? 2'b11 : 
            tlu_wsr_data_w_global[2-1:0]);
assign gl_lvl3_update_g[2-1:0] = 
	        (gl_rw_g & wsr_inst_g & thread_sel_id_g[3]) ? 
			 wsr_gl_lvl3_data[2-1:0] : 
	       ((local_rst | por_rstint3_g) ? 2'b11 :
			 dnrtry_gl_lvl3_data[2-1:0]);     // done/retry restore
			 // tlu_dnrtry_global_g[`TSA_GLOBAL_WIDTH-1:0]);     // done/retry restore

dffe #(2) dffe_gl_lvl3_update_w2 (
     .din (gl_lvl3_update_g[2-1:0]), 
     .q   (gl_lvl3_update_w2[2-1:0]),
     .en  (gl_update_sel_g[3]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
//
// modified for bug3468
assign gl_incr_sel_w2[3] = 
           tlu_thrd_traps_w2[3] & ~(gl_lvl3_at_maxgl | 
           (gl_lvl3_at_maxstl & tlu_select_tba_w2));
//            tlu_thrd_traps_w2[3] & (~(gl_lvl3_at_maxgl | tlu_select_tba_w2) |  
assign gl_update_sel_g[3] = 
           (gl_rw_g & wsr_inst_g & thread_sel_id_g[3]) | 
			local_rst |	por_rstint3_g | tlu_dnrtry3_inst_g;  
//
// modified for bug3468
assign gl_priv_max_sel_w2[3] =
           (gl_lvl3_at_maxgl & tlu_select_tba_w2) & tlu_thrd_traps_w2[3];
// 
assign gl3_en = 
           gl_incr_sel_w2[3] | gl_update_sel_w2[3] | gl_priv_max_sel_w2[3];
// assign gl3_en = gl_incr_sel_w2[3] | gl_update_sel_w2[3]; 

assign gl_lvl3_new[2-1:0] = 
           (gl_update_sel_w2[3]) ? gl_lvl3_update_w2:
           (~gl_update_sel_w2[3] & gl_priv_max_sel_w2[3]) ? 
            2'b10: 
            gl_lvl3[2-1:0] + 2'b01;

// Reset required as processor will start out at gl1 after reset.
/****************************
   to fix bug 6028 manually in the gate netlist, the following needs
   to be a mux_flop with recirculating path from q to d0 input. But
   to make it resetable, need to brake this recirculating path and
   insert an AND gate such that local_rst_l is ANDed with the q output.
dffe #(`TSA_GLOBAL_WIDTH) dffe_gl3 (
     .din (gl_lvl3_new[`TSA_GLOBAL_WIDTH-1:0]), 
     .q   (gl_lvl3[`TSA_GLOBAL_WIDTH-1:0]),
     .en  (gl3_en), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
******************************/

wire [1:0] gl_lvl3_or_rst, gl_lvl3_or_rst_or_new;

assign gl_lvl3_or_rst[1:0] = gl_lvl3[1:0] & {2{~local_rst}};

assign gl_lvl3_or_rst_or_new[1:0] = (gl3_en&~local_rst) ? gl_lvl3_new[1:0] : gl_lvl3_or_rst[1:0];

dff    #(2) dffe_gl3 (
        .din(gl_lvl3_or_rst_or_new[1:0]) ,
        .q(gl_lvl3[1:0]),
        .clk (clk), .se(se), .si(), .so());

/******************************/

assign tlu_gl_lvl3[2-1:0] = gl_lvl3[2-1:0];

 // !`ifdef FPGA_SYN_1THREAD
   
////////////////////////////////////////////////////////////////////////
// Global swap 
////////////////////////////////////////////////////////////////////////
// modified due to timing
/*
assign agp_thrid[0] = ~tlu_agp_tid_g[0] & ~tlu_agp_tid_g[1] & gl0_en; 
assign agp_thrid[1] =  tlu_agp_tid_g[0] & ~tlu_agp_tid_g[1] & gl1_en; 
assign agp_thrid[2] = ~tlu_agp_tid_g[0] &  tlu_agp_tid_g[1] & gl2_en; 
assign agp_thrid[3] =  tlu_agp_tid_g[0] &  tlu_agp_tid_g[1] & gl3_en; 

assign agp_swap = 
           (agp_thrid[0])? 
               |(gl_lvl0_new[1:0] ^ gl_lvl0[1:0]): 
               ((agp_thrid[1])? 
                     |(gl_lvl1_new[1:0] ^ gl_lvl1[1:0]): 
                     ((agp_thrid[2])? 
                         |(gl_lvl2_new[1:0] ^ gl_lvl2[1:0]): 
                         ((agp_thrid[3])? 
                            |(gl_lvl3_new[1:0] ^ gl_lvl3[1:0]):1'b0)));

assign agp_new[1:0] = 
           (agp_thrid[1])? gl_lvl1_new[1:0] :
               ((agp_thrid[2])? gl_lvl2_new[1:0] :
                   ((agp_thrid[3])? gl_lvl3_new[1:0] : 
                        gl_lvl0_new[1:0])); 

dffr dffr_tlu_exu_agp_swap (
    .din (agp_swap),
    .q   (tlu_exu_agp_swap),
    .clk (clk),
    .rst (local_rst),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff #(2) dff_tlu_exu_agp (
    .din (agp_new[1:0]),
    .q   (tlu_exu_agp[1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff #(2) dff_tlu_exu_agp_tid (
    .din (tlu_agp_tid_g[1:0]),
    .q   (tlu_exu_agp_tid[1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
*/

assign agp_thrid_w2[0] = ~tlu_agp_tid_w2[0] & ~tlu_agp_tid_w2[1] & gl0_en; 




















   
assign agp_thrid_w2[1] =  tlu_agp_tid_w2[0] & ~tlu_agp_tid_w2[1] & gl1_en; 
assign agp_thrid_w2[2] = ~tlu_agp_tid_w2[0] &  tlu_agp_tid_w2[1] & gl2_en; 
assign agp_thrid_w2[3] =  tlu_agp_tid_w2[0] &  tlu_agp_tid_w2[1] & gl3_en; 
   
assign agp_swap_w2 = 
           (agp_thrid_w2[0])? 
               |(gl_lvl0_new[1:0] ^ gl_lvl0[1:0]): 
               ((agp_thrid_w2[1])? 
                     |(gl_lvl1_new[1:0] ^ gl_lvl1[1:0]): 
                     ((agp_thrid_w2[2])? 
                         |(gl_lvl2_new[1:0] ^ gl_lvl2[1:0]): 
                         ((agp_thrid_w2[3])? 
                            |(gl_lvl3_new[1:0] ^ gl_lvl3[1:0]):1'b0)));

dffr dffr_agp_swap_w3 (
    .din (agp_swap_w2),
    .q   (agp_swap_w3),
    .rst (local_rst),
    .clk (clk),
    .se  (se),
    .si  (),
    .so ()
);

assign agp_new_w2[1:0] = 
           (agp_thrid_w2[1])? gl_lvl1_new[1:0] :
               ((agp_thrid_w2[2])? gl_lvl2_new[1:0] :
                   ((agp_thrid_w2[3])? gl_lvl3_new[1:0] : 
                        gl_lvl0_new[1:0])); 
 // !`ifdef FPGA_SYN_1THREAD

//
// added for timing fixes
dff #(2) dff_agp_new_w3 (
    .din (agp_new_w2[1:0]),
    .q   (agp_new_w3[1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
assign tlu_exu_agp_swap = agp_swap_w3;
assign tlu_exu_agp[1:0] = agp_new_w3[1:0];

////////////////////////////////////////////////////////////////////////
// HPSTATE register controls 
////////////////////////////////////////////////////////////////////////
//
// added for timing
dffr #(4) dffr_update_hpstate_w2 (
    .din (update_hpstate_g[4-1:0]),
    .q   (update_hpstate_w2[4-1:0]),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

// thread 0
assign tlu_hpstate_din_sel0[0] = dnrtry_inst_w2[0] & ~rst_tri_en; 
assign tlu_hpstate_din_sel0[1] = (hpstate_rw_w2 & wsr_inst_w2) & 
                                 ~rst_tri_en                   & 
                                 ~tlu_hpstate_din_sel0[0]      &  
                                  thread_sel_id_w2[0];
//
// generating write enables to update the hpstate registers
// modified for timing 
/*
assign tlu_hpstate_din_sel0[0] = tlu_dnrtry0_inst_g; 
assign tlu_hpstate_din_sel0[1] = (hpstate_rw_g & wsr_inst_g) & 
                                 ~tlu_hpstate_din_sel0[0]        &  
                                  thread_sel_id_g[0];
assign update_hpstate0_g =  tlu_thrd0_traps | tlu_dnrtry0_inst_g | 
		                  ((hpstate_rw_g & wsr_inst_g) & 
                            thread_sel_id_g[0]);

assign tlu_update_hpstate_l_g[0] = ~(update_hpstate0_g | local_rst);
*/
assign update_hpstate_g[0] =  
           tlu_dnrtry0_inst_g | ((hpstate_rw_g & wsr_inst_g) & 
           thread_sel_id_g[0]);

assign tlu_update_hpstate_l_w2[0] = 
           ~(update_hpstate_w2[0] | local_rst | tlu_thrd_traps_w2[0]);
//
// thread 1
assign tlu_hpstate_din_sel1[0] = dnrtry_inst_w2[1] & ~rst_tri_en;
assign tlu_hpstate_din_sel1[1] = (hpstate_rw_w2 & wsr_inst_w2) & 
                                 ~rst_tri_en                   & 
                                 ~tlu_hpstate_din_sel1[0]      &  
                                  thread_sel_id_w2[1];
//
// generating write enables to update the hpstate registers
// modified for timing 
/*
assign tlu_hpstate_din_sel1[0] = tlu_dnrtry1_inst_g; 
assign tlu_hpstate_din_sel1[1] = (hpstate_rw_g & wsr_inst_g) & 
                                 ~tlu_hpstate_din_sel1[0]        &  
                                  thread_sel_id_g[1];
assign update_hpstate1_g =  tlu_thrd1_traps | tlu_dnrtry1_inst_g |
		                  ((hpstate_rw_g & wsr_inst_g) & 
                            thread_sel_id_g[1]);

assign tlu_update_hpstate_l_g[1] = ~(update_hpstate1_g | local_rst);
*/
assign update_hpstate_g[1] =  
           tlu_dnrtry1_inst_g | ((hpstate_rw_g & wsr_inst_g) & 
           thread_sel_id_g[1]);

assign tlu_update_hpstate_l_w2[1] = 
           ~(update_hpstate_w2[1] | local_rst | tlu_thrd_traps_w2[1]);
//
// thread 2
assign tlu_hpstate_din_sel2[0] = dnrtry_inst_w2[2] & ~rst_tri_en;
assign tlu_hpstate_din_sel2[1] = (hpstate_rw_w2 & wsr_inst_w2) & 
                                 ~rst_tri_en                   & 
                                 ~tlu_hpstate_din_sel2[0]      &  
                                  thread_sel_id_w2[2];
//
// generating write enables to update the hpstate registers
// modified for timing
/*
assign tlu_hpstate_din_sel2[0] = tlu_dnrtry2_inst_g; 
assign tlu_hpstate_din_sel2[1] = (hpstate_rw_g & wsr_inst_g) & 
                                 ~tlu_hpstate_din_sel2[0]        &  
                                  thread_sel_id_g[2];
assign update_hpstate2_g =  tlu_thrd2_traps | tlu_dnrtry2_inst_g | 
		                  ((hpstate_rw_g & wsr_inst_g) & 
                            thread_sel_id_g[2]);

assign tlu_update_hpstate_l_g[2] = ~(update_hpstate2_g | local_rst);
*/
assign update_hpstate_g[2] =  
           tlu_dnrtry2_inst_g | ((hpstate_rw_g & wsr_inst_g) & 
           thread_sel_id_g[2]);

assign tlu_update_hpstate_l_w2[2] = 
           ~(update_hpstate_w2[2] | local_rst | tlu_thrd_traps_w2[2]);
//
// thread 3
assign tlu_hpstate_din_sel3[0] = dnrtry_inst_w2[3] & ~rst_tri_en;
assign tlu_hpstate_din_sel3[1] = (hpstate_rw_w2 & wsr_inst_w2) & 
                                 ~tlu_hpstate_din_sel3[0]      &  
                                 ~rst_tri_en                   & 
                                  thread_sel_id_w2[3];
//
// generating write enables to update the hpstate registers
// modified for timing
/*
assign tlu_hpstate_din_sel3[0] = tlu_dnrtry3_inst_g; 
assign tlu_hpstate_din_sel3[1] = (hpstate_rw_g & wsr_inst_g) & 
                                 ~tlu_hpstate_din_sel3[0]        &  
                                  thread_sel_id_g[3];
assign update_hpstate3_g =  tlu_thrd3_traps | tlu_dnrtry3_inst_g | 
		                  ((hpstate_rw_g & wsr_inst_g) & 
                            thread_sel_id_g[3]);

assign tlu_update_hpstate_l_g[3] = ~(update_hpstate3_g | local_rst);
*/
assign update_hpstate_g[3] =  
           tlu_dnrtry3_inst_g | ((hpstate_rw_g & wsr_inst_g) & 
           thread_sel_id_g[3]);

assign tlu_update_hpstate_l_w2[3] = 
           ~(update_hpstate_w2[3] | local_rst | tlu_thrd_traps_w2[3]);

////////////////////////////////////////////////////////////////////////
// HTICKCMP register controls 
////////////////////////////////////////////////////////////////////////
// thread 0
assign htickcmp_intdis_en[0] = 
           (htickcmp_rw_g & wsr_inst_g & thread_sel_id_g[0]) | 
            local_rst | por_rstint0_g;
// 
// HTICK_CMP.INT_DIS
dffe dffe_hintdis0  (
     .din (tlu_tick_ctl_din), 
     .q   (htick_intdis0),
     .en  (htickcmp_intdis_en[0]), 
     .clk (clk),
     .se  (se),       
     .si  (),
     .so ()
);

// thread 1
assign htickcmp_intdis_en[1] = 
           (htickcmp_rw_g & wsr_inst_g & thread_sel_id_g[1]) |
			local_rst | por_rstint1_g;
// 
// HTICK_CMP.INT_DIS
dffe dffe_hintdis1  (
     .din (tlu_tick_ctl_din), 
     .q   (htick_intdis1),
     .en  (htickcmp_intdis_en[1]), 
     .clk (clk),
     .se  (se),       
     .si  (),
     .so ()
);

// thread 2
assign htickcmp_intdis_en[2] = 
           (htickcmp_rw_g & wsr_inst_g & thread_sel_id_g[2]) |
			local_rst | por_rstint2_g;
// 
// HTICK_CMP.INT_DIS
dffe dffe_hintdis2  (
     .din (tlu_tick_ctl_din), 
     .q   (htick_intdis2),
     .en  (htickcmp_intdis_en[2]), 
     .clk (clk),
     .se  (se),       
     .si  (),
     .so ()
);

// thread 3
assign htickcmp_intdis_en[3] = 
           (htickcmp_rw_g & wsr_inst_g & thread_sel_id_g[3]) |
			local_rst | por_rstint3_g;
// HTICK_CMP.INT_DIS
//
dffe dffe_hintdis3  (
     .din (tlu_tick_ctl_din), 
     .q   (htick_intdis3),
     .en  (htickcmp_intdis_en[3]), 
     .clk (clk),
     .se  (se),       
     .si  (),
     .so ()
);
//
// generating for the non-thread specific htick_cmp
// interrupt disable
assign tlu_htickcmp_intdis =
	       (thread_sel_id_e[0] & htick_intdis0) | (thread_sel_id_e[1] & htick_intdis1) |
		   (thread_sel_id_e[2] & htick_intdis2) | (thread_sel_id_e[3] & htick_intdis3);

////////////////////////////////////////////////////////////////////////
// HINTP register controls 
////////////////////////////////////////////////////////////////////////
// thread 0 
// 
// modified for timing
// assign tlu_set_hintp_g[0] = 
//            (~htick_intdis0 & tlu_tickcmp_sel[0])? tlu_htick_match: 1'b0;
assign tlu_set_hintp_sel_g[0] = ~htick_intdis0 & tlu_tickcmp_sel[0];
// modified for bug 4886
assign tlu_wr_hintp_g[0] = 
           (hintp_rw_g & wsr_inst_g & thread_sel_id_g[0]) | local_rst; 
//
// modified for timing - moved to tlu_tdp
// assign tlu_hintp_en_l_g[0] = 
// 	      ~(tlu_set_hintp_g[0] | tlu_wr_hintp_g[0]);
//
// thread 1 
//
// modified for timing
// assign tlu_set_hintp_g[1] = 
//            (~htick_intdis1 & tlu_tickcmp_sel[1])? tlu_htick_match: 1'b0;
assign tlu_set_hintp_sel_g[1] = ~htick_intdis1 & tlu_tickcmp_sel[1];
assign tlu_wr_hintp_g[1] = 
           (hintp_rw_g & wsr_inst_g & thread_sel_id_g[1]) | local_rst; 
//
// modified for timing - moved to tlu_tdp
// assign tlu_hintp_en_l_g[1] = 
//	      ~(tlu_set_hintp_g[1] | tlu_wr_hintp_g[1]);
//
// thread 2 
// 
// modified for timing 
// assign tlu_set_hintp_g[2] = 
//            (~htick_intdis2 & tlu_tickcmp_sel[2])? tlu_htick_match: 1'b0;
assign tlu_set_hintp_sel_g[2] = ~htick_intdis2 & tlu_tickcmp_sel[2];
assign tlu_wr_hintp_g[2] = 
           (hintp_rw_g & wsr_inst_g & thread_sel_id_g[2]) | local_rst; 
//
// modified for timing - moved to tlu_tdp
// assign tlu_hintp_en_l_g[2] = 
// 	      ~(tlu_set_hintp_g[2] | tlu_wr_hintp_g[2]);
//
// thread 3 
//
// modified for timing
// assign tlu_set_hintp_g[3] = 
//            (~htick_intdis3 & tlu_tickcmp_sel[3])? tlu_htick_match: 1'b0;
assign tlu_set_hintp_sel_g[3] = ~htick_intdis3 & tlu_tickcmp_sel[3];
assign tlu_wr_hintp_g[3] = 
           (hintp_rw_g & wsr_inst_g & thread_sel_id_g[3]) | local_rst; 
//
// modified for timing - moved to tlu_tdp
// assign tlu_hintp_en_l_g[3] = 
// 	      ~(tlu_set_hintp_g[3] | tlu_wr_hintp_g[3]);

////////////////////////////////////////////////////////////////////////
// HTBA register controls 
////////////////////////////////////////////////////////////////////////

assign tlu_htba_en_l[0]	= ~(htba_rw_g & wsr_inst_g & thread_sel_id_g[0]);
assign tlu_htba_en_l[1]	= ~(htba_rw_g & wsr_inst_g & thread_sel_id_g[1]);
assign tlu_htba_en_l[2]	= ~(htba_rw_g & wsr_inst_g & thread_sel_id_g[2]);
assign tlu_htba_en_l[3]	= ~(htba_rw_g & wsr_inst_g & thread_sel_id_g[3]);

////////////////////////////////////////////////////////////////////////
// ASI QUEUE register controls and data 
////////////////////////////////////////////////////////////////////////
// ASI read or write op
//
assign asi_queue_write_e = ifu_lsu_alt_space_e & ifu_lsu_st_inst_e;
assign asi_queue_read_e  = ifu_lsu_alt_space_e & ifu_lsu_ld_inst_e;
// 
// qualify the asi write and read controls
assign asi_queue_write_m = tlu_inst_vld_m & asi_queue_write_pq_m;
assign asi_queue_read_m  = tlu_inst_vld_m & asi_queue_read_pq_m;
//
// modified due to timing violations
// assign asi_queue_write_g = 
//      ~(tlu_flush_pipe_w | ifu_tlu_flush_w) & asi_queue_write_uf_g;
assign asi_queue_write_g = 
           ~local_flush_all_w & asi_queue_write_uf_g;
assign tlu_asi_write_g = asi_queue_write_g;

// assign asi_queue_read_g  = 
//     ~(tlu_flush_pipe_w | ifu_tlu_flush_w) & asi_queue_read_uf_g;
//
// staging the asi controls
dffr #(2) dffr_asi_ctl_m (
    .din ({asi_queue_write_e, asi_queue_read_e}),
    .q   ({asi_queue_write_pq_m, asi_queue_read_pq_m}),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dffr #(2) dffr_asi_ctl_g (
    .din ({asi_queue_write_m, asi_queue_read_m}),
    .q   ({asi_queue_write_uf_g, asi_queue_read_g}),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
// 
// ASI address decode 
// decoding the ASI state 0x25 for the ASI_QUEUES
assign asi_queue_rw_e = 
          (ifu_lsu_alt_space_e)? 
          (tlu_asi_state_e[8-1:0]==8'h25):
           1'b0;
//
// staging the asi controls
dffr dffr_asi_queue_rw_m (
    .din (asi_queue_rw_e),
    .q   (asi_queue_rw_m),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dffr dffr_asi_queue_rw_g (
    .din (asi_queue_rw_m),
    .q   (asi_queue_rw_g),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// modified due to timing violations
/*
// assign tlu_ldst_va_e[`TLU_ASI_VA_WIDTH-1:0] = 
//          exu_lsu_ldst_va_e[`TLU_ASI_VA_WIDTH-1:0];  
dff #(`TLU_ASI_VA_WIDTH) dff_tlu_ldst_va_m (
    .din (exu_lsu_ldst_va_e[`TLU_ASI_VA_WIDTH-1:0]),
    .q   (tlu_ldst_va_m[`TLU_ASI_VA_WIDTH-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

// modified for timing
assign que_legal_va_e = 
           cpu_mondo_head_rw_e  | cpu_mondo_tail_rw_e |
           dev_mondo_head_rw_e  | dev_mondo_tail_rw_e |
           resum_err_head_rw_e  | resum_err_tail_rw_e |
           nresum_err_head_rw_e | nresum_err_tail_rw_e; 

assign que_ill_va_e = 
           (ifu_lsu_alt_space_e)?
           (((|exu_lsu_ldst_va_e[`ASI_VA_WIDTH-1:`TLU_ASI_QUE_VA_HI+1]) |
           (|exu_lsu_ldst_va_e[`TLU_ASI_QUE_VA_LO-1:0]) | ~que_legal_va_e) & 
            asi_queue_pq_rw_e): 1'b0; 
*/
assign tlu_ldst_va_m[10-1:0] = 
           lsu_tlu_ldst_va_m[10-1:0];

assign que_legal_va_m = 
           cpu_mondo_head_rw_m  | cpu_mondo_tail_rw_m |
           dev_mondo_head_rw_m  | dev_mondo_tail_rw_m |
           resum_err_head_rw_m  | resum_err_tail_rw_m |
           nresum_err_head_rw_m | nresum_err_tail_rw_m; 

//
// illegal range check for queue va 
assign que_ill_va_m = 
           (asi_queue_rw_m)? ~que_legal_va_m : 1'b0;
//
// staged illegal va range 
//
dffr dffr_que_ill_va_g (
    .din (que_ill_va_m),
    .q   (que_ill_va_g),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
// 
// added for timing - interrupt register decodes
// interrupt receiver registers
assign asi_inrr_rw_e = 
          (ifu_lsu_alt_space_e)? 
          (tlu_asi_state_e[8-1:0]==8'h72):
           1'b0;

dffr dffr_asi_inrr_rw_m (
    .din (asi_inrr_rw_e),
    .q   (asi_inrr_rw_m),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dffr dffr_asi_inrr_rw_g (
    .din (asi_inrr_rw_m),
    .q   (asi_inrr_rw_g),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

assign inc_ind_asi_wr_inrr[0] = 
           (asi_inrr_rw_g & asi_queue_write_uf_g   & 
           ~local_flush_all_w & thread_sel_id_g[0]);
assign inc_ind_asi_wr_inrr[1] = 
           (asi_inrr_rw_g & asi_queue_write_uf_g   & 
           ~local_flush_all_w & thread_sel_id_g[1]);
assign inc_ind_asi_wr_inrr[2] = 
           (asi_inrr_rw_g & asi_queue_write_uf_g   & 
           ~local_flush_all_w & thread_sel_id_g[2]);
assign inc_ind_asi_wr_inrr[3] = 
           (asi_inrr_rw_g & asi_queue_write_uf_g   & 
           ~local_flush_all_w & thread_sel_id_g[3]);
//
// interrupt dispatch registers
assign asi_indr_rw_e = 
          (ifu_lsu_alt_space_e)? 
          (tlu_asi_state_e[8-1:0]==8'h73):
           1'b0;

dffr dffr_asi_indr_rw_m (
    .din (asi_indr_rw_e),
    .q   (asi_indr_rw_m),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dffr dffr_asi_indr_rw_g (
    .din (asi_indr_rw_m),
    .q   (asi_indr_rw_g),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

assign inc_ind_asi_wr_indr[0] = 
           asi_indr_rw_g & ~local_flush_all_w & asi_queue_write_uf_g & 
           thread_sel_id_g[0];
assign inc_ind_asi_wr_indr[1] = 
           asi_indr_rw_g & ~local_flush_all_w & asi_queue_write_uf_g & 
           thread_sel_id_g[1];
assign inc_ind_asi_wr_indr[2] = 
           asi_indr_rw_g & ~local_flush_all_w & asi_queue_write_uf_g & 
           thread_sel_id_g[2];
assign inc_ind_asi_wr_indr[3] = 
           asi_indr_rw_g & ~local_flush_all_w & asi_queue_write_uf_g & 
           thread_sel_id_g[3];

//
// interrupt vector registers
assign asi_invr_rw_e = 
          (ifu_lsu_alt_space_e)? 
          (tlu_asi_state_e[8-1:0]==8'h74):
           1'b0;

dffr dffr_asi_invr_rw_m (
    .din (asi_invr_rw_e),
    .q   (asi_invr_rw_m),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dffr dffr_asi_invr_rw_g (
    .din (asi_invr_rw_m),
    .q   (asi_invr_rw_g),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

assign inc_ind_asi_rd_invr[0] = 
           (asi_invr_rw_g & asi_queue_read_g & 
           ~local_flush_all_w & thread_sel_id_g[0]);
assign inc_ind_asi_rd_invr[1] = 
           (asi_invr_rw_g & asi_queue_read_g & 
           ~local_flush_all_w & thread_sel_id_g[1]);
assign inc_ind_asi_rd_invr[2] = 
           (asi_invr_rw_g & asi_queue_read_g & 
           ~local_flush_all_w & thread_sel_id_g[2]);
assign inc_ind_asi_rd_invr[3] = 
           (asi_invr_rw_g & asi_queue_read_g & 
           ~local_flush_all_w & thread_sel_id_g[3]);
//
// timing changes: all va e stage signals have been moved to m-stage
// decoding the VA portion of the ASI address
// cpu_mondo_head: 0x3c0
assign cpu_mondo_head_rw_m = 
          (tlu_ldst_va_m[10-1:0]==10'h3c0);
//
// cpu_mondo_tail: 0x3c8
assign cpu_mondo_tail_rw_m = 
          (tlu_ldst_va_m[10-1:0]==10'h3c8);
//
// dev_mondo_head: 0x3d0
assign dev_mondo_head_rw_m = 
          (tlu_ldst_va_m[10-1:0]==10'h3d0);
//
// dev_mondo_tail: 0x3d8
assign dev_mondo_tail_rw_m = 
          (tlu_ldst_va_m[10-1:0]==10'h3d8);
//
// resum_err_head: 0x3e0
assign resum_err_head_rw_m = 
          (tlu_ldst_va_m[10-1:0]==10'h3e0);
//
// resum_err_tail: 0x3e8
assign resum_err_tail_rw_m = 
          (tlu_ldst_va_m[10-1:0]==10'h3e8);
//
// nresum_err_head: 0x3f0
assign nresum_err_head_rw_m = 
          (tlu_ldst_va_m[10-1:0]==10'h3f0);
//
// nresum_err_tail: 0x3f8
assign nresum_err_tail_rw_m = 
          (tlu_ldst_va_m[10-1:0]==10'h3f8);
//
// timing change: replaced by flopped tlu_ldst_va_m decodes
// staging the ASI queue rw decodes
// cpu_mondo_head
/*
dff dff_cpu_mondo_head_rw_m (
     .din (cpu_mondo_head_rw_e), 
     .q   (cpu_mondo_head_rw_m),
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dff dff_dev_mondo_head_rw_m (
     .din (dev_mondo_head_rw_e), 
     .q   (dev_mondo_head_rw_m),
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dff dff_resum_err_head_rw_m (
     .din (resum_err_head_rw_e), 
     .q   (resum_err_head_rw_m),
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dff dff_nresum_err_head_rw_m (
     .din (nresum_err_head_rw_e), 
     .q   (nresum_err_head_rw_m),
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dff dff_cpu_mondo_tail_rw_m (
     .din (cpu_mondo_tail_rw_e), 
     .q   (cpu_mondo_tail_rw_m),
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dff dff_dev_mondo_tail_rw_m (
     .din (dev_mondo_tail_rw_e), 
     .q   (dev_mondo_tail_rw_m),
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dff dff_resum_err_tail_rw_m (
     .din (resum_err_tail_rw_e), 
     .q   (resum_err_tail_rw_m),
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dff dff_nresum_err_tail_rw_m (
     .din (nresum_err_tail_rw_e), 
     .q   (nresum_err_tail_rw_m),
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
//
// illegal range check
dffr dffr_que_ill_va_m (
    .din (que_ill_va_e),
    .q   (que_ill_va_m),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
*/

// staging the ASI queue rw decodes
// cpu_mondo_head
dff dff_cpu_mondo_head_rw_g (
     .din (cpu_mondo_head_rw_m), 
     .q   (cpu_mondo_head_rw_g),
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
//
// dev_mondo_head
dff dff_dev_mondo_head_rw_g (
     .din (dev_mondo_head_rw_m), 
     .q   (dev_mondo_head_rw_g),
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
//
// resum_err_head
dff dff_resum_err_head_rw_g (
     .din (resum_err_head_rw_m), 
     .q   (resum_err_head_rw_g),
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
//
// nresum_err_head
dff dff_nresum_err_head_rw_g (
     .din (nresum_err_head_rw_m), 
     .q   (nresum_err_head_rw_g),
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
// 
// cpu_mondo_tail
//
dff dff_cpu_mondo_tail_rw_g (
     .din (cpu_mondo_tail_rw_m), 
     .q   (cpu_mondo_tail_rw_g),
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
//
// dev_mondo_tail
//
dff dff_dev_mondo_tail_rw_g (
     .din (dev_mondo_tail_rw_m), 
     .q   (dev_mondo_tail_rw_g),
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
//
// resum_err_tail
//
dff dff_resum_err_tail_rw_g (
     .din (resum_err_tail_rw_m), 
     .q   (resum_err_tail_rw_g),
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
//
// nresum_err_tail
//
dff dff_nresum_err_tail_rw_g (
     .din (nresum_err_tail_rw_m), 
     .q   (nresum_err_tail_rw_g),
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
// 
// generating thread specific read and write enables  
//
// cpu_mondo_head read
// assign cpu_mondo_head_rd_g[0] = 
//            asi_queue_read_g & cpu_mondo_head_rw_g & 
//            asi_queue_rw_g   & thread_sel_id_g[0];
assign cpu_mondo_head_rd_g[0] = 
           ~(|cpu_mondo_head_rd_g[3:1]);
assign cpu_mondo_head_rd_g[1] = 
           asi_queue_read_g & cpu_mondo_head_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[1];
assign cpu_mondo_head_rd_g[2] = 
           asi_queue_read_g & cpu_mondo_head_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[2];
assign cpu_mondo_head_rd_g[3] = 
           asi_queue_read_g & cpu_mondo_head_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[3];
//
// non-thread specific read
assign cpu_mondo_hd_rd_g = 
           asi_queue_read_g & cpu_mondo_head_rw_g & 
           asi_queue_rw_g;
// 
// cpu_mondo_head write 
//
assign cpu_mondo_head_wr_g[0] = 
           ~local_flush_all_w & asi_queue_write_uf_g & cpu_mondo_head_rw_g & 
           asi_queue_rw_g & thread_sel_id_g[0];
assign cpu_mondo_head_wr_g[1] = 
           ~local_flush_all_w & asi_queue_write_uf_g & cpu_mondo_head_rw_g & 
           asi_queue_rw_g & thread_sel_id_g[1];
assign cpu_mondo_head_wr_g[2] = 
           ~local_flush_all_w & asi_queue_write_uf_g & cpu_mondo_head_rw_g & 
           asi_queue_rw_g & thread_sel_id_g[2];
assign cpu_mondo_head_wr_g[3] = 
           ~local_flush_all_w & asi_queue_write_uf_g & cpu_mondo_head_rw_g & 
           asi_queue_rw_g & thread_sel_id_g[3];
//
// cpu_mondo_tail read
// assign cpu_mondo_tail_rd_g[0] = 
//            asi_queue_read_g & cpu_mondo_tail_rw_g & 
//            asi_queue_rw_g   & thread_sel_id_g[0];
assign cpu_mondo_tail_rd_g[0] = 
           ~(|cpu_mondo_tail_rd_g[3:1]);
assign cpu_mondo_tail_rd_g[1] = 
           asi_queue_read_g & cpu_mondo_tail_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[1];
assign cpu_mondo_tail_rd_g[2] = 
           asi_queue_read_g & cpu_mondo_tail_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[2];
assign cpu_mondo_tail_rd_g[3] = 
           asi_queue_read_g & cpu_mondo_tail_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[3];
//
// non-thread specific read
assign cpu_mondo_ta_rd_g = 
           asi_queue_read_g & cpu_mondo_tail_rw_g & 
           asi_queue_rw_g;
// 
// cpu_mondo_tail write 
// 
assign cpu_mondo_tail_wr_g[0] = 
           ~local_flush_all_w & asi_queue_write_uf_g & cpu_mondo_tail_rw_g & 
           asi_queue_rw_g & thread_sel_id_g[0];
assign cpu_mondo_tail_wr_g[1] = 
           ~local_flush_all_w & asi_queue_write_uf_g & cpu_mondo_tail_rw_g & 
           asi_queue_rw_g & thread_sel_id_g[1];
assign cpu_mondo_tail_wr_g[2] = 
           ~local_flush_all_w & asi_queue_write_uf_g & cpu_mondo_tail_rw_g & 
           asi_queue_rw_g & thread_sel_id_g[2];
assign cpu_mondo_tail_wr_g[3] = 
           ~local_flush_all_w & asi_queue_write_uf_g & cpu_mondo_tail_rw_g & 
           asi_queue_rw_g & thread_sel_id_g[3];
//
// dev_mondo_head read
// assign dev_mondo_head_rd_g[0] = 
//            asi_queue_read_g & dev_mondo_head_rw_g & 
//            asi_queue_rw_g   & thread_sel_id_g[0];
assign dev_mondo_head_rd_g[0] = 
           ~(|dev_mondo_head_rd_g[3:1]);
assign dev_mondo_head_rd_g[1] = 
           asi_queue_read_g & dev_mondo_head_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[1];
assign dev_mondo_head_rd_g[2] = 
           asi_queue_read_g & dev_mondo_head_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[2];
assign dev_mondo_head_rd_g[3] = 
           asi_queue_read_g & dev_mondo_head_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[3];
//
// non-thread specific read
assign dev_mondo_hd_rd_g = 
           asi_queue_read_g & dev_mondo_head_rw_g & 
           asi_queue_rw_g;
// 
// dev_mondo_head write 
//
assign dev_mondo_head_wr_g[0] = 
           ~local_flush_all_w & asi_queue_write_uf_g & dev_mondo_head_rw_g & 
           asi_queue_rw_g & thread_sel_id_g[0];
assign dev_mondo_head_wr_g[1] = 
           ~local_flush_all_w & asi_queue_write_uf_g & dev_mondo_head_rw_g & 
           asi_queue_rw_g & thread_sel_id_g[1];
assign dev_mondo_head_wr_g[2] = 
           ~local_flush_all_w & asi_queue_write_uf_g & dev_mondo_head_rw_g & 
           asi_queue_rw_g & thread_sel_id_g[2];
assign dev_mondo_head_wr_g[3] = 
           ~local_flush_all_w & asi_queue_write_uf_g & dev_mondo_head_rw_g & 
           asi_queue_rw_g & thread_sel_id_g[3];
//
// dev_mondo_tail read
// assign dev_mondo_tail_rd_g[0] = 
//            asi_queue_read_g & dev_mondo_tail_rw_g & 
//            asi_queue_rw_g   & thread_sel_id_g[0];
assign dev_mondo_tail_rd_g[0] = 
           ~(|dev_mondo_tail_rd_g[3:1]);
assign dev_mondo_tail_rd_g[1] = 
           asi_queue_read_g & dev_mondo_tail_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[1];
assign dev_mondo_tail_rd_g[2] = 
           asi_queue_read_g & dev_mondo_tail_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[2];
assign dev_mondo_tail_rd_g[3] = 
           asi_queue_read_g & dev_mondo_tail_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[3];
//
// non-thread specific read
assign dev_mondo_ta_rd_g = 
           asi_queue_read_g & dev_mondo_tail_rw_g & 
           asi_queue_rw_g;
// 
// dev_mondo_tail write 
// 
assign dev_mondo_tail_wr_g[0] = 
           ~local_flush_all_w & asi_queue_write_uf_g & dev_mondo_tail_rw_g & 
           asi_queue_rw_g & thread_sel_id_g[0];
assign dev_mondo_tail_wr_g[1] = 
           ~local_flush_all_w & asi_queue_write_uf_g & dev_mondo_tail_rw_g & 
           asi_queue_rw_g & thread_sel_id_g[1];
assign dev_mondo_tail_wr_g[2] = 
           ~local_flush_all_w & asi_queue_write_uf_g & dev_mondo_tail_rw_g & 
           asi_queue_rw_g & thread_sel_id_g[2];
assign dev_mondo_tail_wr_g[3] = 
           ~local_flush_all_w & asi_queue_write_uf_g & dev_mondo_tail_rw_g & 
           asi_queue_rw_g & thread_sel_id_g[3];
//
// resum_err_head read
// assign resum_err_head_rd_g[0] = 
//            asi_queue_read_g & resum_err_head_rw_g & 
//            asi_queue_rw_g   & thread_sel_id_g[0];
assign resum_err_head_rd_g[0] = 
           ~(|resum_err_head_rd_g[3:1]);
assign resum_err_head_rd_g[1] = 
           asi_queue_read_g & resum_err_head_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[1];
assign resum_err_head_rd_g[2] = 
           asi_queue_read_g & resum_err_head_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[2];
assign resum_err_head_rd_g[3] = 
           asi_queue_read_g & resum_err_head_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[3];
//
// non-thread specific read
assign resum_err_hd_rd_g = 
           asi_queue_read_g & resum_err_head_rw_g & 
           asi_queue_rw_g;
// 
// resum_err_head write 
//
assign resum_err_head_wr_g[0] = 
           asi_queue_write_g & resum_err_head_rw_g & 
           asi_queue_rw_g    & thread_sel_id_g[0];
assign resum_err_head_wr_g[1] = 
           asi_queue_write_g & resum_err_head_rw_g & 
           asi_queue_rw_g    & thread_sel_id_g[1];
assign resum_err_head_wr_g[2] = 
           asi_queue_write_g & resum_err_head_rw_g & 
           asi_queue_rw_g    & thread_sel_id_g[2];
assign resum_err_head_wr_g[3] = 
           asi_queue_write_g & resum_err_head_rw_g & 
           asi_queue_rw_g    & thread_sel_id_g[3];
//
// resum_err_tail read
// assign resum_err_tail_rd_g[0] = 
//            asi_queue_read_g & resum_err_tail_rw_g & 
//            asi_queue_rw_g   & thread_sel_id_g[0];
assign resum_err_tail_rd_g[0] = 
           ~(|resum_err_tail_rd_g[3:1]);
assign resum_err_tail_rd_g[1] = 
           asi_queue_read_g & resum_err_tail_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[1];
assign resum_err_tail_rd_g[2] = 
           asi_queue_read_g & resum_err_tail_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[2];
assign resum_err_tail_rd_g[3] = 
           asi_queue_read_g & resum_err_tail_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[3];
//
// non-thread specific read
assign resum_err_ta_rd_g = 
           asi_queue_read_g & resum_err_tail_rw_g & 
           asi_queue_rw_g;
// 
// resum_err_tail write 
// 
assign resum_err_tail_wr_g[0] = 
           asi_queue_write_g & resum_err_tail_rw_g & 
           asi_queue_rw_g    & thread_sel_id_g[0];
assign resum_err_tail_wr_g[1] = 
           asi_queue_write_g & resum_err_tail_rw_g & 
           asi_queue_rw_g    & thread_sel_id_g[1];
assign resum_err_tail_wr_g[2] = 
           asi_queue_write_g & resum_err_tail_rw_g & 
           asi_queue_rw_g    & thread_sel_id_g[2];
assign resum_err_tail_wr_g[3] = 
           asi_queue_write_g & resum_err_tail_rw_g & 
           asi_queue_rw_g    & thread_sel_id_g[3];
//
// nresum_err_head read
// assign nresum_err_head_rd_g[0] = 
//            asi_queue_read_g & nresum_err_head_rw_g & 
//            asi_queue_rw_g   & thread_sel_id_g[0];
assign nresum_err_head_rd_g[0] = 
           ~(|nresum_err_head_rd_g[3:1]);
assign nresum_err_head_rd_g[1] = 
           asi_queue_read_g & nresum_err_head_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[1];
assign nresum_err_head_rd_g[2] = 
           asi_queue_read_g & nresum_err_head_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[2];
assign nresum_err_head_rd_g[3] = 
           asi_queue_read_g & nresum_err_head_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[3];
//
// non-thread specific read
assign nresum_err_hd_rd_g = 
           asi_queue_read_g & nresum_err_head_rw_g & 
           asi_queue_rw_g;
// 
// nresum_err_head write 
//
assign nresum_err_head_wr_g[0] = 
           asi_queue_write_g & nresum_err_head_rw_g & 
           asi_queue_rw_g    & thread_sel_id_g[0];
assign nresum_err_head_wr_g[1] = 
           asi_queue_write_g & nresum_err_head_rw_g & 
           asi_queue_rw_g    & thread_sel_id_g[1];
assign nresum_err_head_wr_g[2] = 
           asi_queue_write_g & nresum_err_head_rw_g & 
           asi_queue_rw_g    & thread_sel_id_g[2];
assign nresum_err_head_wr_g[3] = 
           asi_queue_write_g & nresum_err_head_rw_g & 
           asi_queue_rw_g    & thread_sel_id_g[3];
//
// nresum_err_tail read
// assign nresum_err_tail_rd_g[0] = 
//            asi_queue_read_g & nresum_err_tail_rw_g & 
//            asi_queue_rw_g   & thread_sel_id_g[0];
assign nresum_err_tail_rd_g[0] = 
           ~(|nresum_err_tail_rd_g[3:1]);
assign nresum_err_tail_rd_g[1] = 
           asi_queue_read_g & nresum_err_tail_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[1];
assign nresum_err_tail_rd_g[2] = 
           asi_queue_read_g & nresum_err_tail_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[2];
assign nresum_err_tail_rd_g[3] = 
           asi_queue_read_g & nresum_err_tail_rw_g & 
           asi_queue_rw_g   & thread_sel_id_g[3];
//
// non-thread specific read
assign nresum_err_ta_rd_g = 
           asi_queue_read_g & nresum_err_tail_rw_g & 
           asi_queue_rw_g;
// 
// nresum_err_tail write 
// 
assign nresum_err_tail_wr_g[0] = 
           asi_queue_write_g & nresum_err_tail_rw_g & 
           asi_queue_rw_g    & thread_sel_id_g[0];
assign nresum_err_tail_wr_g[1] = 
           asi_queue_write_g & nresum_err_tail_rw_g & 
           asi_queue_rw_g    & thread_sel_id_g[1];
assign nresum_err_tail_wr_g[2] = 
           asi_queue_write_g & nresum_err_tail_rw_g & 
           asi_queue_rw_g    & thread_sel_id_g[2];
assign nresum_err_tail_wr_g[3] = 
           asi_queue_write_g & nresum_err_tail_rw_g & 
           asi_queue_rw_g    & thread_sel_id_g[3];
//
// storing the head and pointers for the queues
// thread 0
//
dffe #(8) dffe_cpu_mondo0_head (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (cpu_mondo0_head[8-1:0]),
     .en  (cpu_mondo_head_wr_g[0]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_cpu_mondo0_tail (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (cpu_mondo0_tail[8-1:0]),
     .en  (cpu_mondo_tail_wr_g[0]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_dev_mondo0_head (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (dev_mondo0_head[8-1:0]),
     .en  (dev_mondo_head_wr_g[0]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_dev_mondo0_tail (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (dev_mondo0_tail[8-1:0]),
     .en  (dev_mondo_tail_wr_g[0]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_resum_err0_head (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (resum_err0_head[8-1:0]),
     .en  (resum_err_head_wr_g[0]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_resum_err0_tail (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (resum_err0_tail[8-1:0]),
     .en  (resum_err_tail_wr_g[0]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_nresum_err0_head (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (nresum_err0_head[8-1:0]),
     .en  (nresum_err_head_wr_g[0]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_nresum_err0_tail (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (nresum_err0_tail[8-1:0]),
     .en  (nresum_err_tail_wr_g[0]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
//
// thread 1
//
dffe #(8) dffe_cpu_mondo1_head (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (cpu_mondo1_head[8-1:0]),
     .en  (cpu_mondo_head_wr_g[1]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_cpu_mondo1_tail (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (cpu_mondo1_tail[8-1:0]),
     .en  (cpu_mondo_tail_wr_g[1]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_dev_mondo1_head (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (dev_mondo1_head[8-1:0]),
     .en  (dev_mondo_head_wr_g[1]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_dev_mondo1_tail (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (dev_mondo1_tail[8-1:0]),
     .en  (dev_mondo_tail_wr_g[1]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_resum_err1_head (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (resum_err1_head[8-1:0]),
     .en  (resum_err_head_wr_g[1]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_resum_err1_tail (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (resum_err1_tail[8-1:0]),
     .en  (resum_err_tail_wr_g[1]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_nresum_err1_head (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (nresum_err1_head[8-1:0]),
     .en  (nresum_err_head_wr_g[1]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_nresum_err1_tail (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (nresum_err1_tail[8-1:0]),
     .en  (nresum_err_tail_wr_g[1]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
//
// thread 2
//
dffe #(8) dffe_cpu_mondo2_head (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (cpu_mondo2_head[8-1:0]),
     .en  (cpu_mondo_head_wr_g[2]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_cpu_mondo2_tail (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (cpu_mondo2_tail[8-1:0]),
     .en  (cpu_mondo_tail_wr_g[2]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_dev_mondo2_head (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (dev_mondo2_head[8-1:0]),
     .en  (dev_mondo_head_wr_g[2]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_dev_mondo2_tail (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (dev_mondo2_tail[8-1:0]),
     .en  (dev_mondo_tail_wr_g[2]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_resum_err2_head (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (resum_err2_head[8-1:0]),
     .en  (resum_err_head_wr_g[2]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_resum_err2_tail (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (resum_err2_tail[8-1:0]),
     .en  (resum_err_tail_wr_g[2]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_nresum_err2_head (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (nresum_err2_head[8-1:0]),
     .en  (nresum_err_head_wr_g[2]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_nresum_err2_tail (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (nresum_err2_tail[8-1:0]),
     .en  (nresum_err_tail_wr_g[2]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
//
// thread 3
//
dffe #(8) dffe_cpu_mondo3_head (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (cpu_mondo3_head[8-1:0]),
     .en  (cpu_mondo_head_wr_g[3]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_cpu_mondo3_tail (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (cpu_mondo3_tail[8-1:0]),
     .en  (cpu_mondo_tail_wr_g[3]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_dev_mondo3_head (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (dev_mondo3_head[8-1:0]),
     .en  (dev_mondo_head_wr_g[3]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_dev_mondo3_tail (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (dev_mondo3_tail[8-1:0]),
     .en  (dev_mondo_tail_wr_g[3]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_resum_err3_head (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (resum_err3_head[8-1:0]),
     .en  (resum_err_head_wr_g[3]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_resum_err3_tail (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (resum_err3_tail[8-1:0]),
     .en  (resum_err_tail_wr_g[3]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_nresum_err3_head (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (nresum_err3_head[8-1:0]),
     .en  (nresum_err_head_wr_g[3]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);

dffe #(8) dffe_nresum_err3_tail (
     .din (tlu_asi_queue_data_g[8-1:0]), 
     .q   (nresum_err3_tail[8-1:0]),
     .en  (nresum_err_tail_wr_g[3]), 
     .clk (clk),
     .se  (se),       
     .si  (),          
     .so  ()
);
//
// reading out the asi queues 
// 
// added for bug2332
// assign cpu_mondo_hd_onehot_g = 
//            ~(|cpu_mondo_head_rd_g[3:1]);
// cpu_mondo_head
mux4ds #(8) mx_cpu_mondo_head (
    .in0  (cpu_mondo0_head[8-1:0]),
    .in1  (cpu_mondo1_head[8-1:0]),
    .in2  (cpu_mondo2_head[8-1:0]),
    .in3  (cpu_mondo3_head[8-1:0]),
    .sel0 (cpu_mondo_head_rd_g[0]),
    .sel1 (cpu_mondo_head_rd_g[1]),
    .sel2 (cpu_mondo_head_rd_g[2]),
    .sel3 (cpu_mondo_head_rd_g[3]),
    .dout (cpu_mondo_hd_rdata[8-1:0])
); 
//
// added for bug2332
// assign cpu_mondo_ta_onehot_g = 
//            ~(|cpu_mondo_tail_rd_g[3:1]);
// cpu_mondo_tail
mux4ds #(8) mx_cpu_mondo_tail (
    .in0  (cpu_mondo0_tail[8-1:0]),
    .in1  (cpu_mondo1_tail[8-1:0]),
    .in2  (cpu_mondo2_tail[8-1:0]),
    .in3  (cpu_mondo3_tail[8-1:0]),
    .sel0 (cpu_mondo_tail_rd_g[0]),
    .sel1 (cpu_mondo_tail_rd_g[1]),
    .sel2 (cpu_mondo_tail_rd_g[2]),
    .sel3 (cpu_mondo_tail_rd_g[3]),
    .dout (cpu_mondo_ta_rdata[8-1:0])
); 
//
// added for bug2332
// assign dev_mondo_hd_onehot_g = 
//            ~(|dev_mondo_head_rd_g[3:1]);
// dev_mondo_head
mux4ds #(8) mx_dev_mondo_head (
    .in0  (dev_mondo0_head[8-1:0]),
    .in1  (dev_mondo1_head[8-1:0]),
    .in2  (dev_mondo2_head[8-1:0]),
    .in3  (dev_mondo3_head[8-1:0]),
    .sel0 (dev_mondo_head_rd_g[0]),
    .sel1 (dev_mondo_head_rd_g[1]),
    .sel2 (dev_mondo_head_rd_g[2]),
    .sel3 (dev_mondo_head_rd_g[3]),
    .dout (dev_mondo_hd_rdata[8-1:0])
); 
//
// added for bug2332
// assign dev_mondo_ta_onehot_g = 
//            ~(|dev_mondo_tail_rd_g[3:1]);
// dev_mondo_tail
mux4ds #(8) mx_dev_mondo_tail (
    .in0  (dev_mondo0_tail[8-1:0]),
    .in1  (dev_mondo1_tail[8-1:0]),
    .in2  (dev_mondo2_tail[8-1:0]),
    .in3  (dev_mondo3_tail[8-1:0]),
    .sel0 (dev_mondo_tail_rd_g[0]),
    .sel1 (dev_mondo_tail_rd_g[1]),
    .sel2 (dev_mondo_tail_rd_g[2]),
    .sel3 (dev_mondo_tail_rd_g[3]),
    .dout (dev_mondo_ta_rdata[8-1:0])
); 
//
// added for bug2332
// assign resum_err_hd_onehot_g = 
//            ~(|resum_err_head_rd_g[3:1]);
// resum_err_head
mux4ds #(8) mx_resum_err_head (
    .in0  (resum_err0_head[8-1:0]),
    .in1  (resum_err1_head[8-1:0]),
    .in2  (resum_err2_head[8-1:0]),
    .in3  (resum_err3_head[8-1:0]),
    .sel0 (resum_err_head_rd_g[0]),
    .sel1 (resum_err_head_rd_g[1]),
    .sel2 (resum_err_head_rd_g[2]),
    .sel3 (resum_err_head_rd_g[3]),
    .dout (resum_err_hd_rdata[8-1:0])
); 
//
// added for bug2332
// assign resum_err_ta_onehot_g = 
//            ~(|resum_err_tail_rd_g[3:1]);
// resum_err_tail
mux4ds #(8) mx_resum_err_tail (
    .in0  (resum_err0_tail[8-1:0]),
    .in1  (resum_err1_tail[8-1:0]),
    .in2  (resum_err2_tail[8-1:0]),
    .in3  (resum_err3_tail[8-1:0]),
    .sel0 (resum_err_tail_rd_g[0]),
    .sel1 (resum_err_tail_rd_g[1]),
    .sel2 (resum_err_tail_rd_g[2]),
    .sel3 (resum_err_tail_rd_g[3]),
    .dout (resum_err_ta_rdata[8-1:0])
); 
//
// added for bug2332
// assign nresum_err_hd_onehot_g = 
//            ~(|nresum_err_head_rd_g[3:1]);
// nresum_err_head
mux4ds #(8) mx_nresum_err_head (
    .in0  (nresum_err0_head[8-1:0]),
    .in1  (nresum_err1_head[8-1:0]),
    .in2  (nresum_err2_head[8-1:0]),
    .in3  (nresum_err3_head[8-1:0]),
    .sel0 (nresum_err_head_rd_g[0]),
    .sel1 (nresum_err_head_rd_g[1]),
    .sel2 (nresum_err_head_rd_g[2]),
    .sel3 (nresum_err_head_rd_g[3]),
    .dout (nresum_err_hd_rdata[8-1:0])
); 
//
// added for bug2332
// assign nresum_err_ta_onehot_g = 
//            ~(|nresum_err_tail_rd_g[3:1]);
// nresum_err_tail
mux4ds #(8) mx_nresum_err_tail (
    .in0  (nresum_err0_tail[8-1:0]),
    .in1  (nresum_err1_tail[8-1:0]),
    .in2  (nresum_err2_tail[8-1:0]),
    .in3  (nresum_err3_tail[8-1:0]),
    .sel0 (nresum_err_tail_rd_g[0]),
    .sel1 (nresum_err_tail_rd_g[1]),
    .sel2 (nresum_err_tail_rd_g[2]),
    .sel3 (nresum_err_tail_rd_g[3]),
    .dout (nresum_err_ta_rdata[8-1:0])
); 
// 
// added for bug 2332
assign asi_qrdata_mx1_sel[0] = cpu_mondo_hd_rd_g | 
                               ~(|asi_qrdata_mx1_sel[3:1]);
assign asi_qrdata_mx1_sel[1] = cpu_mondo_ta_rd_g;
assign asi_qrdata_mx1_sel[2] = dev_mondo_hd_rd_g;
assign asi_qrdata_mx1_sel[3] = dev_mondo_ta_rd_g;
// 
// selecting between the eight queues
mux4ds #(8) mx1_asi_queue_rdata (
    .in0  (cpu_mondo_hd_rdata[8-1:0]),
    .in1  (cpu_mondo_ta_rdata[8-1:0]),
    .in2  (dev_mondo_hd_rdata[8-1:0]),
    .in3  (dev_mondo_ta_rdata[8-1:0]),
    .sel0 (asi_qrdata_mx1_sel[0]),
    .sel1 (asi_qrdata_mx1_sel[1]),
    .sel2 (asi_qrdata_mx1_sel[2]),
    .sel3 (asi_qrdata_mx1_sel[3]),
    .dout (asi_queue_rdata1_g[8-1:0])
);
// 
// added for bug 2332
assign asi_qrdata_mx2_sel[0] = resum_err_hd_rd_g | 
                               ~(|asi_qrdata_mx2_sel[3:1]);
assign asi_qrdata_mx2_sel[1] = resum_err_ta_rd_g;
assign asi_qrdata_mx2_sel[2] = nresum_err_hd_rd_g;
assign asi_qrdata_mx2_sel[3] = nresum_err_ta_rd_g;

mux4ds #(8) mx2_asi_queue_rdata (
    .in0  (resum_err_hd_rdata[8-1:0]),
    .in1  (resum_err_ta_rdata[8-1:0]),
    .in2  (nresum_err_hd_rdata[8-1:0]),
    .in3  (nresum_err_ta_rdata[8-1:0]),
    .sel0 (asi_qrdata_mx2_sel[0]),
    .sel1 (asi_qrdata_mx2_sel[1]),
    .sel2 (asi_qrdata_mx2_sel[2]),
    .sel3 (asi_qrdata_mx2_sel[3]),
    .dout (asi_queue_rdata2_g[8-1:0])
);
//
// constructing the select for the final asi queue rdata output
assign asi_qrdata_mx_sel2 = 
           resum_err_hd_rd_g  | resum_err_ta_rd_g |  
           nresum_err_hd_rd_g | nresum_err_ta_rd_g;   
//
mux2ds #(8) mx_tlu_asi_queue_rdata (
    .in0  (asi_queue_rdata2_g[8-1:0]),
    .in1  (asi_queue_rdata1_g[8-1:0]),
    .sel0 (asi_qrdata_mx_sel2),
    .sel1 (~asi_qrdata_mx_sel2),
    .dout (tlu_asi_queue_rdata_g[8-1:0])
);
//
// forming the valid signal for the asi queue rdata
assign tlu_asi_queue_rd_vld_g =
       asi_qrdata_mx_sel2 | cpu_mondo_hd_rd_g | cpu_mondo_ta_rd_g |
       dev_mondo_hd_rd_g  | dev_mondo_ta_rd_g; 

assign tlu_ld_data_vld_g = asi_ld_addr_vld_g; 

////////////////////////////////////////////////////////////////////////
// SCPD and HSCPD control logic
////////////////////////////////////////////////////////////////////////
//
// privileged scratch pad access
assign asi_scpd_rw_e = 
           ifu_lsu_alt_space_e & 
          (tlu_asi_state_e[8-1:0]==8'h20);

// hyprivileged scratch pad access
assign asi_hscpd_rw_e = 
           ifu_lsu_alt_space_e & 
          (tlu_asi_state_e[8-1:0]==8'h4f);
//
// staged the scpd/hscpd rw ctls
dffr #(2) dffr_asi_scpd_rw_ctls (
    .din ({asi_hscpd_rw_e, asi_scpd_rw_e}),
    .q   ({asi_hscpd_rw_m, asi_scpd_rw_m}),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

// address generation
//
// modified due to timing fix  
/*
 assign scpd_addr_va_e[`SCPD_ASI_VA_ADDR_WIDTH-1:0] = 
            tlu_ldst_va_e[`TLU_ASI_SCPD_VA_HI:`TLU_ASI_SCPD_VA_LO];

 staged the shifted va address
 modified due to timing fix

dff #(`SCPD_ASI_VA_ADDR_WIDTH) dff_scpd_addr_va_m (
    .din (scpd_addr_va_e[`SCPD_ASI_VA_ADDR_WIDTH-1:0]),
    .q   (scpd_addr_va_m[`SCPD_ASI_VA_ADDR_WIDTH-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
*/

assign scpd_addr_va_m[3-1:0] = 
            tlu_ldst_va_m[5:3];

dff #(3) dff_scpd_addr_va_g (
    .din (scpd_addr_va_m[3-1:0]),
    .q   (scpd_addr_va_g[3-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

assign tlu_scpd_rd_addr_m[5-1:0] = 
           {thrid_m[1:0], scpd_addr_va_m[3-1:0]}; 

assign tlu_scpd_wr_addr_g[5-1:0] = 
           {thrid_g[1:0], scpd_addr_va_g[3-1:0]}; 
//
// illegal range check for scratch-pd va 
// modified due to timing
/*
assign scpd_ill_va_e = 
           (ifu_lsu_alt_space_e)?
           ((asi_scpd_rw_e | asi_hscpd_rw_e) & 
           ((|exu_lsu_ldst_va_e[`ASI_VA_WIDTH-1:`TLU_ASI_SCPD_VA_HI+1]) |
            (|exu_lsu_ldst_va_e[`TLU_ASI_SCPD_VA_LO-1:0]))) :
            1'b0;
// staged illegal va range 
dffr dffr_scpd_ill_va_m (
    .din (scpd_ill_va_e),
    .q   (scpd_ill_va_m),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
*/
//
assign va_not_baligned_m = (|tlu_ldst_va_m[3-1:0]); 
assign scpd_ill_va_m = 
           (asi_scpd_rw_m | asi_hscpd_rw_m) & 
            va_not_baligned_m;
       
// 
dffr dffr_scpd_ill_va_g (
    .din (scpd_ill_va_m),
    .q   (scpd_ill_va_g),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// generating read and write valid 
assign asi_scpd_rw_vld_m = 
            (asi_scpd_rw_m | asi_hscpd_rw_m) & 
           ~(hscpd_data_acc_excpt_m | va_not_baligned_m);

dffr dffr_asi_scpd_rw_vld_g (
    .din (asi_scpd_rw_vld_m),
    .q   (asi_scpd_rw_vld_g),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

assign tlu_scpd_wr_vld_g = 
           asi_queue_write_g & asi_scpd_rw_vld_g; 
//
// control to the memory macro for the read
// modified due to timing 
assign tlu_scpd_rd_vld_m = 
           // asi_queue_read_m & asi_scpd_rw_vld_m; 
           asi_queue_read_pq_m & asi_scpd_rw_vld_m; 
//
// control to the int block for the selection of read data 
// replaced by queue vld
// assign tlu_scpd_rd_vld_g = 
//            asi_queue_read_g & asi_scpd_rw_vld_g; 

// decoding for hypervisor only scratch-pad
assign hscpd_va_rw_m = 
          ((scpd_addr_va_m[3-1:0] == 
            3'h4) | 
           (scpd_addr_va_m[3-1:0] == 
            3'h5));  

////////////////////////////////////////////////////////////////////////
// Potential trap indicators 
////////////////////////////////////////////////////////////////////////
// possible traps are: 
// 1) head ptr <> tail ptr (with the exception of nresum_err_queue)
// 2) write to tail by supervisor - data_access_exception 

//
// write to hypervisor scratch-pad using 0x20 ASI state

assign hscpd_priv_asi_acc_m = 
       hscpd_va_rw_m & asi_scpd_rw_m; 

// modified due to timing - moved the inst_vld qualification to tlu_tcl
assign hscpd_data_acc_excpt_pq_m = 
           hscpd_priv_asi_acc_m & 
           (asi_queue_write_pq_m | asi_queue_read_pq_m);
/*
           hscpd_priv_asi_acc_m & 
           // (asi_queue_write_m | asi_queue_read_m)  &
           (asi_queue_write_pq_m | asi_queue_read_pq_m) &
           ((thread_sel_id_m[0] & ~tlu_hyper_lite[0]) |
            (thread_sel_id_m[1] & ~tlu_hyper_lite[1]) |
            (thread_sel_id_m[2] & ~tlu_hyper_lite[2]) |
            (thread_sel_id_m[3] & ~tlu_hyper_lite[3])); 
*/
//
// data_access_exception to access the hyper-privileged scratch-pad 

assign tlu_hscpd_dacc_excpt_m = hscpd_data_acc_excpt_pq_m;
//
// revised for bug 3586

assign hscpd_data_acc_excpt_m = 
           hscpd_data_acc_excpt_pq_m & 
           ((thread_sel_id_m[0] & ~tlu_hyper_lite[0]) |
            (thread_sel_id_m[1] & ~tlu_hyper_lite[1]) |
            (thread_sel_id_m[2] & ~tlu_hyper_lite[2]) |
            (thread_sel_id_m[3] & ~tlu_hyper_lite[3])); 

// illegal va range indicator
assign tlu_va_ill_g = 
           (que_ill_va_g | scpd_ill_va_g) & asi_queue_read_g; 

// load instruction valid - scpd or asi queue 
assign asi_ld_addr_vld_m  = 
             asi_queue_read_m & (asi_queue_rw_m | 
           ((asi_hscpd_rw_m | asi_scpd_rw_m) & 
            ~hscpd_data_acc_excpt_m));

// staging the ld address valid 
dffr dffr_asi_ld_addr_vld_g (
    .din (asi_ld_addr_vld_m),
    .q   (asi_ld_addr_vld_g),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// redefined va illegal checking - the following code is 
// no longer necessary
// zero va range detector
/* 
assign va_all_zero_e = 
            (~(|exu_lsu_ldst_va_e[`ASI_VA_WIDTH-1:0])) &
             asi_queue_read_g;
//
// staged illegal va range 
dffr dffr_va_all_zero_m (
    .din (va_all_zero_e),
    .q   (va_all_zero_m),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
// 
dffr dffr_va_all_zero_g (
    .din (va_all_zero_m),
    .q   (va_all_zero_g),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

assign tlu_va_all_zero_g = va_all_zero_g; 
*/

////////////////////////////////////////////////////////////////////////
// queue traps - head ptr <> tail ptr
////////////////////////////////////////////////////////////////////////
// note: these traps are level-sensitive
//
// thread 0

assign tlu_cpu_mondo_cmp[0] = 
           (|(cpu_mondo0_head[8-1:0] ^
              cpu_mondo0_tail[8-1:0]));
assign tlu_dev_mondo_cmp[0]= 
           (|(dev_mondo0_head[8-1:0] ^
              dev_mondo0_tail[8-1:0]));
assign tlu_resum_err_cmp[0] = 
           (|(resum_err0_head[8-1:0] ^ 
              resum_err0_tail[8-1:0]));
// thread 1

assign tlu_cpu_mondo_cmp[1] = 
           (|(cpu_mondo1_head[8-1:0] ^
              cpu_mondo1_tail[8-1:0]));
assign tlu_dev_mondo_cmp[1]= 
           (|(dev_mondo1_head[8-1:0] ^
              dev_mondo1_tail[8-1:0]));
assign tlu_resum_err_cmp[1] = 
           (|(resum_err1_head[8-1:0] ^ 
              resum_err1_tail[8-1:0]));
//
// thread 2

assign tlu_cpu_mondo_cmp[2] = 
           (|(cpu_mondo2_head[8-1:0] ^
              cpu_mondo2_tail[8-1:0]));
assign tlu_dev_mondo_cmp[2]= 
           (|(dev_mondo2_head[8-1:0] ^
              dev_mondo2_tail[8-1:0]));
assign tlu_resum_err_cmp[2] = 
           (|(resum_err2_head[8-1:0] ^ 
              resum_err2_tail[8-1:0]));
// thread 3

assign tlu_cpu_mondo_cmp[3] = 
           (|(cpu_mondo3_head[8-1:0] ^
              cpu_mondo3_tail[8-1:0]));
assign tlu_dev_mondo_cmp[3]= 
           (|(dev_mondo3_head[8-1:0] ^
              dev_mondo3_tail[8-1:0]));
assign tlu_resum_err_cmp[3] = 
           (|(resum_err3_head[8-1:0] ^ 
              resum_err3_tail[8-1:0]));

// write to tail by supervisor
// modified due to timing - moved the inst_vld qualification to tlu_tcl
assign qtail_write_m = 
           (nresum_err_tail_rw_m | resum_err_tail_rw_m  | 
            cpu_mondo_tail_rw_m  | dev_mondo_tail_rw_m) &
            asi_queue_write_pq_m & asi_queue_rw_m;
            // asi_queue_write_m & asi_queue_rw_m;

//
// modified for timing - qualification moved to tcl
assign tlu_qtail_dacc_excpt_m = qtail_write_m;
/*
           ((thread_sel_id_m[0] & que_trap_en[0] & tlu_pstate_priv[0])  |
            (thread_sel_id_m[1] & que_trap_en[1] & tlu_pstate_priv[1])  |
            (thread_sel_id_m[2] & que_trap_en[2] & tlu_pstate_priv[2])  |
            (thread_sel_id_m[3] & que_trap_en[3] & tlu_pstate_priv[3])) & 
             qtail_write_m;
*/
              
endmodule
