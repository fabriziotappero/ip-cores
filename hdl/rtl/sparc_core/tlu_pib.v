// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: tlu_pib.v
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
//      Description:    Performance Instrumentation Block 
//                      Performance monitoring 2 of the 9 possible events
//                      can be tracked per thread
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

module	tlu_pib (/*AUTOARG*/
                 // input
                 ifu_tlu_imiss_e, ifu_tlu_immu_miss_m, ifu_tlu_thrid_d,
                 ifu_tlu_sraddr_d, ifu_tlu_rsr_inst_d, // ifu_tlu_wsr_inst_d, 
                 ifu_tlu_l2imiss, tlu_tcc_inst_w, lsu_tlu_wsr_inst_e, 
                 ffu_tlu_fpu_tid, ffu_tlu_fpu_cmplt, 
                 lsu_tlu_dmmu_miss_g, lsu_tlu_dcache_miss_w2, lsu_tlu_l2_dmiss,
                 lsu_tlu_stb_full_w2, exu_tlu_wsr_data_m, // tlu_tickcmp_sel, 
                 tlu_hpstate_priv, tlu_thread_inst_vld_g, tlu_wsr_inst_nq_g, 
                 tlu_full_flush_pipe_w2,  tlu_pstate_priv, tlu_thread_wsel_g, 
                 tlu_pib_rsr_data_e, tlu_hpstate_enb, ifu_tlu_flush_fd_w, 
//
// reset was modified to abide to the Niagara reset methodology 
                 rclk, arst_l, grst_l, si, se, // tlu_rst_l, rst_tri_en, 
                 // output

// tlu_pcr_ut_e, tlu_pcr_st_e,
                 pib_picl_wrap, pich_wrap_flg, pich_onebelow_flg, pich_twobelow_flg, 
                 tlu_pic_onebelow_e, tlu_pic_twobelow_e, pib_priv_act_trap_m, 
                 tlu_wsr_data_w, tlu_pcr_ut, tlu_pcr_st, tlu_pic_wrap_e, so);

// Input section
// Events generated by IFU
input	     ifu_tlu_imiss_e;	   // icache misses -- New interface  
input		 ifu_tlu_immu_miss_m;  // itlb misses 
input [1:0]	 ifu_tlu_thrid_d;	   //  thread id For instruction complete
input [4-1:0] tlu_thread_inst_vld_g; // For instruction complete
input [4-1:0] tlu_thread_wsel_g;  // thread of instruction fetched 
input [4-1:0] ifu_tlu_l2imiss; // l2 imiss -- new interface 

// ASR register read/write requests
input [7-1:0] ifu_tlu_sraddr_d;      
input ifu_tlu_rsr_inst_d; // valid rd sr(st/pr)
// input ifu_tlu_wsr_inst_d; // valid wr sr(st/pr)
input lsu_tlu_wsr_inst_e; // valid wr sr(st/pr)
// input tlu_wsr_inst_g; // valid wr sr(st/pr)
// modified for timing
input tlu_wsr_inst_nq_g; // valid wr sr(st/pr)
input [64-1:0] exu_tlu_wsr_data_m; // pr/st data to irf.
// modified due to timing
// input [`TLU_ASR_DATA_WIDTH-1:0] tlu_pib_rsr_data_e; // this was the tlu_exu_rsr_data_e 

// LSU generated events - also include L2 miss
input [4-1:0] lsu_tlu_dcache_miss_w2; // dcache miss -- new interface 
input [4-1:0] lsu_tlu_l2_dmiss;	     // l2 dmisses -- new interface 
input [4-1:0] lsu_tlu_stb_full_w2;	 // store buffer full -- new interface 
input lsu_tlu_dmmu_miss_g;	 // dtlb misses 
// FFU generated events - also include L2 miss
input [1:0] ffu_tlu_fpu_tid;   // ThrdID for the FF instr_cmplt -- new 
input       ffu_tlu_fpu_cmplt; // FF instru complete -- new 
// TLU information for event filtering
//
input [4-1:0] tlu_pstate_priv; // supervisor privilege information 
input [4-1:0] tlu_hpstate_priv;// hypervisor privilege information
input [4-1:0] tlu_hpstate_enb; // hyperlite enabling 
input tlu_tcc_inst_w; // For instruction complete 
input tlu_full_flush_pipe_w2; // For instruction complete 
input ifu_tlu_flush_fd_w; // For instruction complete 
// Global signals
input rclk;			
//
// reset was modified to abide to the Niagara reset methodology 
// input			reset;		
// input tlu_rst_l;		
input		grst_l;				// global reset - active log
input		arst_l;				// global reset - active log
input		si;				    // global scan-in 
input		se;				    // global scan-out 
// input		rst_tri_en;			// global reset - active log

// output section
// modified to make inst vld overflow trap precies
// output [`TLU_THRD_NUM-1:0] pib_pic_wrap;     // pic register wrap transition 
// output pib_rst_l;				// local unit reset - active low
output [4-1:0] pib_picl_wrap;       // pic register wrap transition 
output [4-1:0] pich_wrap_flg;       // pic register wrap transition 
output [4-1:0] pich_onebelow_flg;   // pic register wrap transition 
output [4-1:0] pich_twobelow_flg;   // pic register wrap transition 
// output [`TLU_THRD_NUM-1:0] pich_threebelow_flg; // pic register wrap transition 
// modified due to timing fixes
output [64-1:0] tlu_pib_rsr_data_e; // rsr data register data 
output tlu_pic_onebelow_e, tlu_pic_twobelow_e, tlu_pic_wrap_e; 
//
// modified for bug 5436 - Niagara 2.0
output [4-1:0] tlu_pcr_ut;   
output [4-1:0] tlu_pcr_st;   
wire tlu_pcr_ut_e, tlu_pcr_st_e; 


// 
// output [`TLU_THRD_NUM-1:0] pib_priv_act_trap;  // access privilege violation for pics 
output [4-1:0] pib_priv_act_trap_m;  // access privilege violation for pics 
// output [`TLU_ASR_DATA_WIDTH-1:0] tlu_exu_rsr_data_e; // Add in the final muxing of pib asr data 
output [64-1:0] tlu_wsr_data_w;     // flopped version of exu_tlu_wsr_data_m 
// output [47:0] tlu_ifu_trappc_w2;  // temporary for timing 
// output [47:0] tlu_ifu_trapnpc_w2; // temporary for timing 
output   so;				    // global scan-out 

//==============================================================================
// Local signal defines 
//==============================================================================
// decoded address for pcr and pic
wire pcr_rw_e, pcr_rw_m, pcr_rw_g; // pcr_rw_d, 
wire pic_priv_rw_e, pic_priv_rw_m, pic_priv_rw_g; // pic_priv_rw_d,  
wire pic_npriv_rw_e, pic_npriv_rw_m, pic_npriv_rw_g;// pic_npriv_rw_d, 
//
// read/write to pcr, evq and pic 
wire [4-1:0] wsr_thread_inst_g; 
wire [4-1:0] update_picl_sel, update_picl_wrap_en;
wire [4-1:0] picl_cnt_wrap_datain;
wire [4-1:0] update_pich_sel, update_pich_wrap_en;
wire [4-1:0] pich_cnt_wrap_datain;
wire [4-1:0] update_evq_sel;
wire [4-1:0] wsr_pcr_sel; 
wire [4-1:0] wsr_pic_sel; 
wire [4-1:0] update_pich_ovf; 
wire [4-1:0] update_picl_ovf; 
wire [4-1:0] inst_vld_w2; 
wire tcc_inst_w2;
// 
// added for bug 2919
wire [4-1:0] pic_update_ctl; 
wire [1:0] pic_update_sel_ctr; 
wire [1:0] pic_update_sel_incr; 
//
// modified for timing
// wire [`TLU_ASR_ADDR_WIDTH-1:0] pib_sraddr_d;      
wire [7-1:0] pib_sraddr_e;      
wire tlu_rsr_inst_e, tlu_wsr_inst_e;      
//
// picl masks
wire [8-1:0] picl_mask0, picl_mask1, picl_mask2, picl_mask3;
wire [8-1:0] picl_event0, picl_event1, picl_event2, picl_event3;
// added for bug2332
// wire incr_pich_onehot;
// pic counters
wire [4-1:0] incr_pich; 
wire [4-1:0] pich_mux_sel; 
wire [4-1:0] pich_cnt_wrap; 
wire [4-1:0] picl_cnt_wrap; 
wire [4-2:0] thread_rsel_d; 
wire [4-2:0] thread_rsel_e;
wire [4-1:0] pic_onebelow_e, pic_twobelow_e, pic_wrap_e; 
wire [33-1:0] picl_cnt0, picl_cnt1, picl_cnt2, picl_cnt3; 
wire [33-1:0] picl_cnt_din, picl_cnt_sum;
wire [33-1:0] picl_wsr_data; 
wire [33-1:0] update_picl0_data, update_picl1_data; 
wire [33-1:0] update_picl2_data, update_picl3_data; 
wire [33-1:0] pich_cnt0, pich_cnt1, pich_cnt2, pich_cnt3; 
wire [33-1:0] pich_cnt_din, pich_cnt_sum; 
wire [33-1:0] pich_wsr_data;
wire [33-1:0] update_pich0_data, update_pich1_data; 
wire [33-1:0] update_pich2_data, update_pich3_data; 
wire [64-1:0] pic_rdata_e;
wire [64-1:0] pcr_rdata_e;
wire [8-1:0] pcr_reg_rdata_e;
wire [8-1:0] pcr_wdata_in;
wire [4-1:0] picl_ovf_wdata_in;
wire [4-1:0] pich_ovf_wdata_in;
// experiment
wire [4-1:0] pich_fourbelow_din;
wire [4-1:0] pich_fourbelow_flg;
// wire [`TLU_THRD_NUM-1:0] pich_threebelow_flg;
// modified due to timing
// wire [2:0] rsr_data_sel_e;
wire [1:0] rsr_data_sel_e;
// picl evqs 
wire [3-1:0] picl_evq0, picl_evq1, picl_evq2, picl_evq3;
wire [3-1:0] picl_evq0_sum, picl_evq1_sum; 
wire [3-1:0] picl_evq2_sum, picl_evq3_sum; 
wire [3-1:0] update_evq0_data, update_evq1_data; 
wire [3-1:0] update_evq2_data, update_evq3_data; 
wire [3-1:0] picl_evq_din; 
wire [3-1:0] picl_evq0_din, picl_evq1_din; 
wire [3-1:0] picl_evq2_din, picl_evq3_din; 
wire [4-1:0] incr_evq_din, incr_evq;
// pcr registers
wire [8-1:0] pcr0, pcr1, pcr2, pcr3; 
// 
wire local_rst; // local active high reset
wire local_rst_l; // local active high reset
// counting enable indicator 
wire [4-1:0] pic_cnt_en, pic_cnt_en_w2;
//
// staged icache and itlb misses
wire imiss_m, imiss_g;
wire immu_miss_g;
//
// threaded icache, itlb, and dtlb misses
wire [4-1:0] imiss_thread_g;
wire [4-1:0] immu_miss_thread_g;
wire [4-1:0] dmmu_miss_thread_g;
wire [4-1:0] fpu_cmplt_thread;
//
// clock rename
wire clk; 

//==============================================================================
// Code starts here
//==============================================================================
//	reset

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
// assign pib_rst_l = local_rst_l;
// assign local_rst = ~tlu_rst_l;
//
// rename clock 
assign clk = rclk;

//
// privilege action trap due to user access of pic register when
// PRIV bit is set in pcr
// modified for timing fixes
/*
assign pib_priv_act_trap = (pic_npriv_rw_g ) & 
           ((pcr0[`PIB_PCR_PRIV]  & tlu_thread_inst_vld_g[0]) & 
             ~tlu_pstate_priv[0]) |
           ((pcr1[`PIB_PCR_PRIV]  & tlu_thread_inst_vld_g[1]) & 
             ~tlu_pstate_priv[1]) |
           ((pcr2[`PIB_PCR_PRIV]  & tlu_thread_inst_vld_g[2]) & 
             ~tlu_pstate_priv[2]) |
           ((pcr3[`PIB_PCR_PRIV]  & tlu_thread_inst_vld_g[3]) & 
             ~tlu_pstate_priv[3]);
*/
assign pib_priv_act_trap_m[0] = pic_npriv_rw_m & pcr0[0]; 
assign pib_priv_act_trap_m[1] = pic_npriv_rw_m & pcr1[0]; 
assign pib_priv_act_trap_m[2] = pic_npriv_rw_m & pcr2[0]; 
assign pib_priv_act_trap_m[3] = pic_npriv_rw_m & pcr3[0]; 
             
//
// staging the exu_tlu_wsr_data_w signal for timing
//
dff #(64) dff_tlu_wsr_data_w (
    .din (exu_tlu_wsr_data_m[64-1:0]), 
    .q   (tlu_wsr_data_w[64-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
//================================
// address decode for PCR and PICs 
//================================
// added and modified for timing
// assign pib_sraddr_d[`TLU_ASR_ADDR_WIDTH-1:0] =
//            ifu_tlu_sraddr_d[`TLU_ASR_ADDR_WIDTH-1:0]; 

dff #(7) dff_pib_sraddr_e (
    .din (ifu_tlu_sraddr_d[7-1:0]),
    .q   (pib_sraddr_e[7-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dffr dffr_tlu_rsr_inst_e (
    .din (ifu_tlu_rsr_inst_d),
    .q   (tlu_rsr_inst_e),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// modified for timing
/*
dffr dffr_tlu_wsr_inst_e (
    .din (ifu_tlu_wsr_inst_d),
    .q   (tlu_wsr_inst_e),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
*/
assign tlu_wsr_inst_e = lsu_tlu_wsr_inst_e;
//
assign pcr_rw_e = 
           (pib_sraddr_e[7-1:0] == 7'b0010000); 
assign pic_priv_rw_e = 
           (pib_sraddr_e[7-1:0] == 7'b0110001);
assign pic_npriv_rw_e = 
           (pib_sraddr_e[7-1:0] == 7'b0010001) &
           (tlu_rsr_inst_e | tlu_wsr_inst_e);
//
// staging of the ASR decoded controls
//
// staging from d to e stage
// deleted for timing
/*
dff dff_pcr_rw_d_e (
    .din (pcr_rw_d),
    .q   (pcr_rw_e),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_pic_priv_rw_d_e (
    .din (pic_priv_rw_d),
    .q   (pic_priv_rw_e),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_pic_npriv_rw_d_e (
    .din (pic_npriv_rw_d),
    .q   (pic_npriv_rw_e),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
*/
//
// staging from e to m stage
dff dff_pcr_rw_e_m (
    .din (pcr_rw_e),
    .q   (pcr_rw_m),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_pic_priv_rw_e_m (
    .din (pic_priv_rw_e),
    .q   (pic_priv_rw_m),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_pic_npriv_rw_e_m (
    .din (pic_npriv_rw_e),
    .q   (pic_npriv_rw_m),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_imiss_e_m (
    .din (ifu_tlu_imiss_e),
    .q   (imiss_m),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// staging from m to g stage
dff dff_pcr_rw_m_g (
    .din (pcr_rw_m),
    .q   (pcr_rw_g),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_pic_priv_rw_m_g (
    .din (pic_priv_rw_m),
    .q   (pic_priv_rw_g),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_pic_npriv_rw_m_g (
    .din (pic_npriv_rw_m),
    .q   (pic_npriv_rw_g),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_imiss_m_g (
    .din (imiss_m),
    .q   (imiss_g),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff dff_immu_miss_m_g (
    .din (ifu_tlu_immu_miss_m),
    .q   (immu_miss_g),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

//
//=========================
// update for PCR registers   
//=========================
//
assign wsr_thread_inst_g[0] = 
           tlu_wsr_inst_nq_g & ~ifu_tlu_flush_fd_w & tlu_thread_wsel_g[0];
assign wsr_thread_inst_g[1] = 
           tlu_wsr_inst_nq_g & ~ifu_tlu_flush_fd_w & tlu_thread_wsel_g[1];
assign wsr_thread_inst_g[2] = 
           tlu_wsr_inst_nq_g & ~ifu_tlu_flush_fd_w & tlu_thread_wsel_g[2];
assign wsr_thread_inst_g[3] = 
           tlu_wsr_inst_nq_g & ~ifu_tlu_flush_fd_w & tlu_thread_wsel_g[3];
// 
// extracting the relevant bits from the wsr data bus
assign pcr_wdata_in = 
    {tlu_wsr_data_w[9:8],
     tlu_wsr_data_w[6:4],
     tlu_wsr_data_w[2:0]};
//
// thread 0
assign wsr_pcr_sel[0] = wsr_thread_inst_g[0] & pcr_rw_g; 

assign update_picl_ovf[0] = 
           (wsr_thread_inst_g[0] & pcr_rw_g) |
           (picl_cnt_wrap[0] ^ picl_cnt0[33-1]);

assign update_pich_ovf[0] = 
           (wsr_thread_inst_g[0] & pcr_rw_g) |
           (pich_cnt_wrap[0] ^ pich_cnt0[33-1]);
//
// modified for bug 2291
dffre #(8-2) dffre_pcr0 (
 //   .din (tlu_wsr_data_w[`PIB_PCR_WIDTH-1:0]),
    .din (pcr_wdata_in[8-3:0]),
    .q   (pcr0[8-3:0]),
    .rst (local_rst),
    .en  (wsr_pcr_sel[0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

mux2ds mux_pcr0_picl_ovf (
	.in0(pcr_wdata_in[6]),  
	.in1(picl_cnt_wrap[0] ^ picl_cnt0[33-1]),
	.sel0(wsr_pcr_sel[0]),
	.sel1(~wsr_pcr_sel[0]),
	.dout(picl_ovf_wdata_in[0])
);

// added for the new bug 2588
dffre dffre_pcr0_picl_ovf (
    .din (picl_ovf_wdata_in[0]),
    .q   (pcr0[6]),
    .clk (clk),
    .en  (update_picl_ovf[0]),
    .rst (local_rst),
    .se  (se),       
    .si  (),          
    .so  ()
);

mux2ds mux_pcr0_pich_ovf (
	.in0(pcr_wdata_in[7]),  
	.in1(pich_cnt_wrap[0] ^ pich_cnt0[33-1]),
	.sel0(wsr_pcr_sel[0]),
	.sel1(~wsr_pcr_sel[0]),
	.dout(pich_ovf_wdata_in[0])
);

dffre dffre_pcr0_pich_ovf (
    .din (pich_ovf_wdata_in[0]),
    .q   (pcr0[7]),
    .clk (clk),
    .en  (update_pich_ovf[0]),
    .rst (local_rst),
    .se  (se),       
    .si  (),          
    .so  ()
);
// 
// thread 1

assign wsr_pcr_sel[1] = wsr_thread_inst_g[1] & pcr_rw_g; 

assign update_picl_ovf[1] = 
           (wsr_thread_inst_g[1] & pcr_rw_g) |
           (picl_cnt_wrap[1] ^ picl_cnt1[33-1]);

assign update_pich_ovf[1] = 
           (wsr_thread_inst_g[1] & pcr_rw_g) |
           (pich_cnt_wrap[1] ^ pich_cnt1[33-1]);

dffre #(8-2) dffre_pcr1 (
 //   .din (tlu_wsr_data_w[`PIB_PCR_WIDTH-1:0]),
    .din (pcr_wdata_in[8-3:0]),
    .q   (pcr1[8-3:0]),
    .rst (local_rst),
    .en  (wsr_pcr_sel[1]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

mux2ds mux_pcr1_picl_ovf (
	.in0(pcr_wdata_in[6]),  
	.in1(picl_cnt_wrap[1] ^ picl_cnt1[33-1]),
	.sel0(wsr_pcr_sel[1]),
	.sel1(~wsr_pcr_sel[1]),
	.dout(picl_ovf_wdata_in[1])
);
// added for the new bug 2588
dffre dffre_pcr1_picl_ovf (
    .din (picl_ovf_wdata_in[1]),
    .q   (pcr1[6]),
    .clk (clk),
    .en  (update_picl_ovf[1]),
    .rst (local_rst),
    .se  (se),       
    .si  (),          
    .so  ()
);

mux2ds mux_pcr1_pich_ovf (
	.in0(pcr_wdata_in[7]),  
	.in1(pich_cnt_wrap[1] ^ pich_cnt1[33-1]),
	.sel0(wsr_pcr_sel[1]),
	.sel1(~wsr_pcr_sel[1]),
	.dout(pich_ovf_wdata_in[1])
);

dffre dffre_pcr1_pich_ovf (
    .din (pich_ovf_wdata_in[1]),
    .q   (pcr1[7]),
    .clk (clk),
    .en  (update_pich_ovf[1]),
    .rst (local_rst),
    .se  (se),       
    .si  (),          
    .so  ()
);
// 
// thread 2

assign wsr_pcr_sel[2] = wsr_thread_inst_g[2] & pcr_rw_g; 

assign update_picl_ovf[2] = 
           (wsr_thread_inst_g[2] & pcr_rw_g) |
           (picl_cnt_wrap[2] ^ picl_cnt2[33-1]);

assign update_pich_ovf[2] = 
           (wsr_thread_inst_g[2] & pcr_rw_g) |
           (pich_cnt_wrap[2] ^ pich_cnt2[33-1]);

dffre #(8-2) dffre_pcr2 (
 //   .din (tlu_wsr_data_w[`PIB_PCR_WIDTH-1:0]),
    .din (pcr_wdata_in[8-3:0]),
    .q   (pcr2[8-3:0]),
    .rst (local_rst),
    .en  (wsr_pcr_sel[2]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

mux2ds mux_pcr2_picl_ovf (
	.in0(pcr_wdata_in[6]),  
	.in1(picl_cnt_wrap[2] ^ picl_cnt2[33-1]),
	.sel0(wsr_pcr_sel[2]),
	.sel1(~wsr_pcr_sel[2]),
	.dout(picl_ovf_wdata_in[2])
);

// added for the new bug 2588
dffre dffre_pcr2_picl_ovf (
    .din (picl_ovf_wdata_in[2]),
    .q   (pcr2[6]),
    .clk (clk),
    .en  (update_picl_ovf[2]),
    .rst (local_rst),
    .se  (se),       
    .si  (),          
    .so  ()
);

mux2ds mux_pcr2_pich_ovf (
	.in0(pcr_wdata_in[7]),  
	.in1(pich_cnt_wrap[2] ^ pich_cnt2[33-1]),
	.sel0(wsr_pcr_sel[2]),
	.sel1(~wsr_pcr_sel[2]),
	.dout(pich_ovf_wdata_in[2])
);

dffre dffre_pcr2_pich_ovf (
    .din (pich_ovf_wdata_in[2]),
    .q   (pcr2[7]),
    .clk (clk),
    .en  (update_pich_ovf[2]),
    .rst (local_rst),
    .se  (se),       
    .si  (),          
    .so  ()
);
// 
// thread 3

assign wsr_pcr_sel[3] = wsr_thread_inst_g[3] & pcr_rw_g; 

assign update_picl_ovf[3] = 
           (wsr_thread_inst_g[3] & pcr_rw_g) |
           (picl_cnt_wrap[3] ^ picl_cnt3[33-1]);

assign update_pich_ovf[3] = 
           (wsr_thread_inst_g[3] & pcr_rw_g) |
           (pich_cnt_wrap[3] ^ pich_cnt3[33-1]);

dffre #(8-2) dffre_pcr3 (
 //   .din (tlu_wsr_data_w[`PIB_PCR_WIDTH-1:0]),
    .din (pcr_wdata_in[8-3:0]),
    .q   (pcr3[8-3:0]),
    .rst (local_rst),
    .en  (wsr_pcr_sel[3]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

mux2ds mux_pcr3_picl_ovf (
	.in0(pcr_wdata_in[6]),  
	.in1(picl_cnt_wrap[3] ^ picl_cnt3[33-1]),
	.sel0(wsr_pcr_sel[3]),
	.sel1(~wsr_pcr_sel[3]),
	.dout(picl_ovf_wdata_in[3])
);

// added for the new bug 2588
dffre dffre_pcr3_picl_ovf (
    .din (picl_ovf_wdata_in[3]),
    .q   (pcr3[6]),
    .clk (clk),
    .en  (update_picl_ovf[3]),
    .rst (local_rst),
    .se  (se),       
    .si  (),          
    .so  ()
);

mux2ds mux_pcr3_pich_ovf (
	.in0(pcr_wdata_in[7]),  
	.in1(pich_cnt_wrap[3] ^ pich_cnt3[33-1]),
	.sel0(wsr_pcr_sel[3]),
	.sel1(~wsr_pcr_sel[3]),
	.dout(pich_ovf_wdata_in[3])
);

dffre dffre_pcr3_pich_ovf (
    .din (pich_ovf_wdata_in[3]),
    .q   (pcr3[7]),
    .clk (clk),
    .en  (update_pich_ovf[3]),
    .rst (local_rst),
    .se  (se),       
    .si  (),          
    .so  ()
);

//
//====================
// threading of events 
//====================
//
// icache misses
assign imiss_thread_g[0] = imiss_g & tlu_thread_wsel_g[0];
assign imiss_thread_g[1] = imiss_g & tlu_thread_wsel_g[1];
assign imiss_thread_g[2] = imiss_g & tlu_thread_wsel_g[2];
assign imiss_thread_g[3] = imiss_g & tlu_thread_wsel_g[3];
//
// itlb misses
assign immu_miss_thread_g[0] = immu_miss_g & tlu_thread_wsel_g[0];
assign immu_miss_thread_g[1] = immu_miss_g & tlu_thread_wsel_g[1];
assign immu_miss_thread_g[2] = immu_miss_g & tlu_thread_wsel_g[2];
assign immu_miss_thread_g[3] = immu_miss_g & tlu_thread_wsel_g[3];
//
// dtlb misses
assign dmmu_miss_thread_g[0] = lsu_tlu_dmmu_miss_g & tlu_thread_wsel_g[0];
assign dmmu_miss_thread_g[1] = lsu_tlu_dmmu_miss_g & tlu_thread_wsel_g[1];
assign dmmu_miss_thread_g[2] = lsu_tlu_dmmu_miss_g & tlu_thread_wsel_g[2];
assign dmmu_miss_thread_g[3] = lsu_tlu_dmmu_miss_g & tlu_thread_wsel_g[3];
//
// itlb misses
assign fpu_cmplt_thread[0] = 
           ffu_tlu_fpu_cmplt & (~ffu_tlu_fpu_tid[0] & ~ffu_tlu_fpu_tid[1]); 
assign fpu_cmplt_thread[1] = 
           ffu_tlu_fpu_cmplt & (ffu_tlu_fpu_tid[0]  & ~ffu_tlu_fpu_tid[1]); 
assign fpu_cmplt_thread[2] = 
           ffu_tlu_fpu_cmplt & (~ffu_tlu_fpu_tid[0] &  ffu_tlu_fpu_tid[1]); 
assign fpu_cmplt_thread[3] = 
           ffu_tlu_fpu_cmplt & (ffu_tlu_fpu_tid[0]  &  ffu_tlu_fpu_tid[1]); 

//====================
// assigning of events 
//====================
//
// thread 0
assign picl_event0[0]   = lsu_tlu_stb_full_w2[0]; 
assign picl_event0[1]   = fpu_cmplt_thread[0]; 
assign picl_event0[2]   = imiss_thread_g[0]; 
assign picl_event0[3]   = lsu_tlu_dcache_miss_w2[0]; 
assign picl_event0[4] = immu_miss_thread_g[0]; 
assign picl_event0[5] = dmmu_miss_thread_g[0]; 
assign picl_event0[6]  = ifu_tlu_l2imiss[0]; 
assign picl_event0[7]  = lsu_tlu_l2_dmiss[0]; 
//
// thread 1
assign picl_event1[0]   = lsu_tlu_stb_full_w2[1]; 
assign picl_event1[1]   = fpu_cmplt_thread[1]; 
assign picl_event1[2]   = imiss_thread_g[1]; 
assign picl_event1[3]   = lsu_tlu_dcache_miss_w2[1]; 
assign picl_event1[4] = immu_miss_thread_g[1]; 
assign picl_event1[5] = dmmu_miss_thread_g[1]; 
assign picl_event1[6]  = ifu_tlu_l2imiss[1]; 
assign picl_event1[7]  = lsu_tlu_l2_dmiss[1]; 
//
// thread 2
assign picl_event2[0]   = lsu_tlu_stb_full_w2[2]; 
assign picl_event2[1]   = fpu_cmplt_thread[2]; 
assign picl_event2[2]   = imiss_thread_g[2]; 
assign picl_event2[3]   = lsu_tlu_dcache_miss_w2[2]; 
assign picl_event2[4] = immu_miss_thread_g[2]; 
assign picl_event2[5] = dmmu_miss_thread_g[2]; 
assign picl_event2[6]  = ifu_tlu_l2imiss[2]; 
assign picl_event2[7]  = lsu_tlu_l2_dmiss[2]; 
//
// thread 3
assign picl_event3[0]   = lsu_tlu_stb_full_w2[3]; 
assign picl_event3[1]   = fpu_cmplt_thread[3]; 
assign picl_event3[2]   = imiss_thread_g[3]; 
assign picl_event3[3]   = lsu_tlu_dcache_miss_w2[3]; 
assign picl_event3[4] = immu_miss_thread_g[3]; 
assign picl_event3[5] = dmmu_miss_thread_g[3]; 
assign picl_event3[6]  = ifu_tlu_l2imiss[3]; 
assign picl_event3[7]  = lsu_tlu_l2_dmiss[3]; 

//======================
// decode for PIC events   
//======================
// 
// thread 0

assign pic_cnt_en[0] = 
            (~tlu_hpstate_priv[0] & ~tlu_pstate_priv[0] & pcr0[2])   | 
            (~tlu_hpstate_enb[0]  & tlu_hpstate_priv[0] & pcr0[1])   |
            (tlu_hpstate_enb[0]   & tlu_pstate_priv[0]  & ~tlu_hpstate_priv[0] & 
             pcr0[1]); 
//
// picl mask decodes
assign picl_mask0[0] =  
           ((pcr0[5:3] == 3'b000) &
             pic_cnt_en[0]);
assign picl_mask0[1] =  
           ((pcr0[5:3] == 3'b001) &
             pic_cnt_en[0]);
assign picl_mask0[2] =  
           ((pcr0[5:3] == 3'b010) &
             pic_cnt_en[0]);
assign picl_mask0[3] =  
           ((pcr0[5:3] == 3'b011) &
             pic_cnt_en[0]);
assign picl_mask0[4] =  
           ((pcr0[5:3] == 3'b100) &
             pic_cnt_en[0]);
assign picl_mask0[5] =  
           ((pcr0[5:3] == 3'b101) &
             pic_cnt_en[0]);
assign picl_mask0[6] =  
           ((pcr0[5:3] == 3'b110) &
             pic_cnt_en[0]);
assign picl_mask0[7] =  
           ((pcr0[5:3] == 3'b111) &
             pic_cnt_en[0]);
// 
// thread 1

assign pic_cnt_en[1] = 
            (~tlu_hpstate_priv[1] & ~tlu_pstate_priv[1] & pcr1[2])   | 
            (~tlu_hpstate_enb[1]  & tlu_hpstate_priv[1] & pcr1[1])   |
            (tlu_hpstate_enb[1]   & tlu_pstate_priv[1]  & ~tlu_hpstate_priv[1] & 
             pcr1[1]); 
//
// picl mask decodes
assign picl_mask1[0] =  
           ((pcr1[5:3] == 3'b000) &
             pic_cnt_en[1]);
assign picl_mask1[1] =  
           ((pcr1[5:3] == 3'b001) &
             pic_cnt_en[1]);
assign picl_mask1[2] =  
           ((pcr1[5:3] == 3'b010) &
             pic_cnt_en[1]);
assign picl_mask1[3] =  
           ((pcr1[5:3] == 3'b011) &
             pic_cnt_en[1]);
assign picl_mask1[4] =  
           ((pcr1[5:3] == 3'b100) &
             pic_cnt_en[1]);
assign picl_mask1[5] =  
           ((pcr1[5:3] == 3'b101) &
             pic_cnt_en[1]);
assign picl_mask1[6] =  
           ((pcr1[5:3] == 3'b110) &
             pic_cnt_en[1]);
assign picl_mask1[7] =  
           ((pcr1[5:3] == 3'b111) &
             pic_cnt_en[1]);
// 
// thread 2

assign pic_cnt_en[2] = 
            (~tlu_hpstate_priv[2] & ~tlu_pstate_priv[2] & pcr2[2])   | 
            (~tlu_hpstate_enb[2]  & tlu_hpstate_priv[2] & pcr2[1])   |
            (tlu_hpstate_enb[2]   & tlu_pstate_priv[2]  & ~tlu_hpstate_priv[2] & 
             pcr2[1]); 
//
// picl mask decodes
assign picl_mask2[0] =  
           ((pcr2[5:3] == 3'b000) &
             pic_cnt_en[2]);
assign picl_mask2[1] =  
           ((pcr2[5:3] == 3'b001) &
             pic_cnt_en[2]);
assign picl_mask2[2] =  
           ((pcr2[5:3] == 3'b010) &
             pic_cnt_en[2]);
assign picl_mask2[3] =  
           ((pcr2[5:3] == 3'b011) &
             pic_cnt_en[2]);
assign picl_mask2[4] =  
           ((pcr2[5:3] == 3'b100) &
             pic_cnt_en[2]);
assign picl_mask2[5] =  
           ((pcr2[5:3] == 3'b101) &
             pic_cnt_en[2]);
assign picl_mask2[6] =  
           ((pcr2[5:3] == 3'b110) &
             pic_cnt_en[2]);
assign picl_mask2[7] =  
           ((pcr2[5:3] == 3'b111) &
             pic_cnt_en[2]);
// 
// thread 3

assign pic_cnt_en[3] = 
            (~tlu_hpstate_priv[3] & ~tlu_pstate_priv[3] & pcr3[2])   | 
            (~tlu_hpstate_enb[3]  & tlu_hpstate_priv[3] & pcr3[1])   |
            (tlu_hpstate_enb[3]   & tlu_pstate_priv[3]  & ~tlu_hpstate_priv[3] & 
             pcr3[1]); 
//
// added for timing
dff #(4) dff_pic_cnt_en_w2 (
    .din (pic_cnt_en[4-1:0]),
    .q   (pic_cnt_en_w2[4-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

//
// picl mask decodes
assign picl_mask3[0] =  
           ((pcr3[5:3] == 3'b000) &
             pic_cnt_en[3]);
assign picl_mask3[1] =  
           ((pcr3[5:3] == 3'b001) &
             pic_cnt_en[3]);
assign picl_mask3[2] =  
           ((pcr3[5:3] == 3'b010) &
             pic_cnt_en[3]);
assign picl_mask3[3] =  
           ((pcr3[5:3] == 3'b011) &
             pic_cnt_en[3]);
assign picl_mask3[4] =  
           ((pcr3[5:3] == 3'b100) &
             pic_cnt_en[3]);
assign picl_mask3[5] =  
           ((pcr3[5:3] == 3'b101) &
             pic_cnt_en[3]);
assign picl_mask3[6] =  
           ((pcr3[5:3] == 3'b110) &
             pic_cnt_en[3]);
assign picl_mask3[7] =  
           ((pcr3[5:3] == 3'b111) &
             pic_cnt_en[3]);

//==================================================================
// update the picls - could be sperated into a dp block if needed 
//==================================================================
// added for bug 2919
// rrobin scheduler to choose thread to update
dffr #(2) dffr_pic_update_sel_ctr (
    .din (pic_update_sel_incr[1:0]),
    .q   (pic_update_sel_ctr[1:0]),
    .rst (local_rst),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

assign pic_update_sel_incr[1:0] = 
           pic_update_sel_ctr[1:0] + 2'b01;

assign pic_update_ctl[0] = 
           ~|(pic_update_sel_incr[1:0]); 
assign pic_update_ctl[1] = 
           ~pic_update_sel_incr[1] &  pic_update_sel_incr[0]; 
assign pic_update_ctl[2] = 
           pic_update_sel_incr[1]  & ~pic_update_sel_incr[0]; 
assign pic_update_ctl[3] = 
           &(pic_update_sel_incr[1:0]); 
// 
// EVQs for PICL
//
// masking events for increment for picl evq update
assign incr_evq_din[0] = 
           (|(picl_mask0[8-1:0] & 
             picl_event0[8-1:0]));
assign incr_evq_din[1] = 
           (|(picl_mask1[8-1:0] & 
             picl_event1[8-1:0]));
assign incr_evq_din[2] = 
           (|(picl_mask2[8-1:0] & 
             picl_event2[8-1:0]));
assign incr_evq_din[3] = 
           (|(picl_mask3[8-1:0] & 
             picl_event3[8-1:0])); 
//
// added due to timing 
dff #(4) dff_incr_evq (
    .din (incr_evq_din[4-1:0]),
    .q   (incr_evq[4-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// constructing controls to update the picl_evq
assign update_evq_sel[0] = (local_rst | pic_update_ctl[0] | incr_evq[0]); 
assign update_evq_sel[1] = (local_rst | pic_update_ctl[1] | incr_evq[1]); 
assign update_evq_sel[2] = (local_rst | pic_update_ctl[2] | incr_evq[2]); 
assign update_evq_sel[3] = (local_rst | pic_update_ctl[3] | incr_evq[3]); 
//
// increment evq count for each thread
// thread 0
tlu_addern_32 #(3,1) picl_evq0_adder (
    .din  (picl_evq0[3-1:0]),
    .incr (1'b1),
    .sum  (picl_evq0_sum[3-1:0])
) ;

mux2ds #(3) mux_update_evq0_data (
       .in0  ({3{1'b0}}),
       .in1  (picl_evq0_sum[3-1:0]),
       .sel0 (local_rst | pic_update_ctl[0]),
       .sel1 (~(local_rst | pic_update_ctl[0])),
       .dout (update_evq0_data[3-1:0])
);

dffe #(3) dff_picl_evq0 (
    .din (update_evq0_data[3-1:0]),
    .q   (picl_evq0[3-1:0]),
    .clk (clk),
    .en  (update_evq_sel[0]),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// thread 1
tlu_addern_32 #(3,1) picl_evq1_adder (
    .din  (picl_evq1[3-1:0]),
    .incr (1'b1),
    .sum  (picl_evq1_sum[3-1:0])
) ;

mux2ds #(3) mux_update_evq1_data (
       .in0  ({3{1'b0}}),
       .in1  (picl_evq1_sum[3-1:0]),
       .sel0 (local_rst | pic_update_ctl[1]),
       .sel1 (~(local_rst | pic_update_ctl[1])),
       .dout (update_evq1_data[3-1:0])
);

dffe #(3) dff_picl_evq1 (
    .din (update_evq1_data[3-1:0]),
    .q   (picl_evq1[3-1:0]),
    .clk (clk),
    .en  (update_evq_sel[1]),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// thread 2
tlu_addern_32 #(3,1) picl_evq2_adder (
    .din  (picl_evq2[3-1:0]),
    .incr (1'b1),
    .sum  (picl_evq2_sum[3-1:0])
) ;

mux2ds #(3) mux_update_evq2_data (
       .in0  ({3{1'b0}}),
       .in1  (picl_evq2_sum[3-1:0]),
       .sel0 (local_rst | pic_update_ctl[2]),
       .sel1 (~(local_rst | pic_update_ctl[2])),
       .dout (update_evq2_data[3-1:0])
);

dffe #(3) dff_picl_evq2 (
    .din (update_evq2_data[3-1:0]),
    .q   (picl_evq2[3-1:0]),
    .clk (clk),
    .en  (update_evq_sel[2]),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// thread 3
tlu_addern_32 #(3,1) picl_evq3_adder (
    .din  (picl_evq3[3-1:0]),
    .incr (1'b1),
    .sum  (picl_evq3_sum[3-1:0])
) ;

mux2ds #(3) mux_update_evq3_data (
       .in0  ({3{1'b0}}),
       .in1  (picl_evq3_sum[3-1:0]),
       .sel0 (local_rst | pic_update_ctl[3]),
       .sel1 (~(local_rst | pic_update_ctl[3])),
       .dout (update_evq3_data[3-1:0])
);

dffe #(3) dff_picl_evq3 (
    .din (update_evq3_data[3-1:0]),
    .q   (picl_evq3[3-1:0]),
    .clk (clk),
    .en  (update_evq_sel[3]),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// selelcting the thread for incrementing for picl
//
mux4ds #(33) mux_picl_cnt_din (
       .in0  (picl_cnt0[33-1:0]),
       .in1  (picl_cnt1[33-1:0]),
       .in2  (picl_cnt2[33-1:0]),
       .in3  (picl_cnt3[33-1:0]),
       .sel0 (pic_update_ctl[0]),
       .sel1 (pic_update_ctl[1]),
       .sel2 (pic_update_ctl[2]),
       .sel3 (pic_update_ctl[3]),
       .dout (picl_cnt_din[33-1:0])
);
//
// selecting the correct input for incrementing the picl
// thread0
mux2ds #(3) mux_picl_evq0_din (
       .in0  (picl_evq0_sum[3-1:0]),
       .in1  (picl_evq0[3-1:0]),
       .sel0 (incr_evq[0]),
       .sel1 (~incr_evq[0]),
       .dout (picl_evq0_din[3-1:0])
);
//
// thread1
mux2ds #(3) mux_picl_evq1_din (
       .in0  (picl_evq1_sum[3-1:0]),
       .in1  (picl_evq1[3-1:0]),
       .sel0 (incr_evq[1]),
       .sel1 (~incr_evq[1]),
       .dout (picl_evq1_din[3-1:0])
);
//
// thread2
mux2ds #(3) mux_picl_evq2_din (
       .in0  (picl_evq2_sum[3-1:0]),
       .in1  (picl_evq2[3-1:0]),
       .sel0 (incr_evq[2]),
       .sel1 (~incr_evq[2]),
       .dout (picl_evq2_din[3-1:0])
);
//
// thread3
mux2ds #(3) mux_picl_evq3_din (
       .in0  (picl_evq3_sum[3-1:0]),
       .in1  (picl_evq3[3-1:0]),
       .sel0 (incr_evq[3]),
       .sel1 (~incr_evq[3]),
       .dout (picl_evq3_din[3-1:0])
);

//
mux4ds #(3) mux_picl_evq_din (
       .in0  (picl_evq0_din[3-1:0]),
       .in1  (picl_evq1_din[3-1:0]),
       .in2  (picl_evq2_din[3-1:0]),
       .in3  (picl_evq3_din[3-1:0]),
       .sel0 (pic_update_ctl[0]),
       .sel1 (pic_update_ctl[1]),
       .sel2 (pic_update_ctl[2]),
       .sel3 (pic_update_ctl[3]),
       .dout (picl_evq_din[3-1:0])
);
//
// picl incrementor  - shared between four threads
//
tlu_addern_32 #(33,3) picl_adder (
    .din  (picl_cnt_din[33-1:0]),
    .incr (picl_evq_din[3-1:0]),
    .sum  (picl_cnt_sum[33-1:0])
) ;
//
// construction mux selects for picl update

assign wsr_pic_sel[0] = wsr_thread_inst_g[0] & (pic_npriv_rw_g | pic_priv_rw_g);
assign wsr_pic_sel[1] = wsr_thread_inst_g[1] & (pic_npriv_rw_g | pic_priv_rw_g);
assign wsr_pic_sel[2] = wsr_thread_inst_g[2] & (pic_npriv_rw_g | pic_priv_rw_g);
assign wsr_pic_sel[3] = wsr_thread_inst_g[3] & (pic_npriv_rw_g | pic_priv_rw_g);

assign update_picl_sel[0] = (local_rst | pic_update_ctl[0] | wsr_pic_sel[0]); 
assign update_picl_sel[1] = (local_rst | pic_update_ctl[1] | wsr_pic_sel[1]); 
assign update_picl_sel[2] = (local_rst | pic_update_ctl[2] | wsr_pic_sel[2]); 
assign update_picl_sel[3] = (local_rst | pic_update_ctl[3] | wsr_pic_sel[3]); 

// constructing the selects to choose to update the pich wrap - added for bug 2588 
assign update_picl_wrap_en[0] = 
           update_picl_sel[0] | wsr_pcr_sel[0]; 
assign update_picl_wrap_en[1] = 
           update_picl_sel[1] | wsr_pcr_sel[1]; 
assign update_picl_wrap_en[2] = 
           update_picl_sel[2] | wsr_pcr_sel[2]; 
assign update_picl_wrap_en[3] = 
           update_picl_sel[3] | wsr_pcr_sel[3]; 
//
// extracting the wsr_data information to update the picls
//
assign picl_wsr_data = {1'b0, tlu_wsr_data_w[31:0]}; 
//
// selecting the data for picl update
// thread 0 
mux3ds #(33) mux_update_picl0_data (
       .in0  ({33{1'b0}}),
       .in1  (picl_wsr_data[33-1:0]),
       .in2  (picl_cnt_sum[33-1:0]),
       .sel0 (local_rst),
       .sel1 (wsr_pic_sel[0] & ~local_rst),
       .sel2 (~(wsr_pic_sel[0] | local_rst)),
       .dout (update_picl0_data[33-1:0])
);

dffe #(33) dff_picl_cnt0 (
    .din (update_picl0_data[33-1:0]),
    .q   (picl_cnt0[33-1:0]),
    .clk (clk),
    .en  (update_picl_sel[0]),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// thread 1
mux3ds #(33) mux_update_picl1_data (
       .in0  ({33{1'b0}}),
       .in1  (picl_wsr_data[33-1:0]),
       .in2  (picl_cnt_sum[33-1:0]),
       .sel0 (local_rst),
       .sel1 (wsr_pic_sel[1] & ~local_rst),
       .sel2 (~(wsr_pic_sel[1] | local_rst)),
       .dout (update_picl1_data[33-1:0])
);

dffe #(33) dff_picl_cnt1 (
    .din (update_picl1_data[33-1:0]),
    .q   (picl_cnt1[33-1:0]),
    .clk (clk),
    .en  (update_picl_sel[1]),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// thread 2
mux3ds #(33) mux_update_picl2_data (
       .in0  ({33{1'b0}}),
       .in1  (picl_wsr_data[33-1:0]),
       .in2  (picl_cnt_sum[33-1:0]),
       .sel0 (local_rst),
       .sel1 (wsr_pic_sel[2] & ~local_rst),
       .sel2 (~(wsr_pic_sel[2] | local_rst)),
       .dout (update_picl2_data[33-1:0])
);

dffe #(33) dff_picl_cnt2 (
    .din (update_picl2_data[33-1:0]),
    .q   (picl_cnt2[33-1:0]),
    .clk (clk),
    .en  (update_picl_sel[2]),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// thread 3
mux3ds #(33) mux_update_picl3_data (
       .in0  ({33{1'b0}}),
       .in1  (picl_wsr_data[33-1:0]),
       .in2  (picl_cnt_sum[33-1:0]),
       .sel0 (local_rst),
       .sel1 (wsr_pic_sel[3] & ~local_rst),
       .sel2 (~(wsr_pic_sel[3] | local_rst)),
       .dout (update_picl3_data[33-1:0])
);

dffe #(33) dff_picl_cnt3 (
    .din (update_picl3_data[33-1:0]),
    .q   (picl_cnt3[33-1:0]),
    .clk (clk),
    .en  (update_picl_sel[3]),
    .se  (se),       
    .si  (),          
    .so  ()
);

//==================================================================
// update the pichs - could be sperated into a dp block if needed 
//==================================================================
//
dffr #(4) dffr_inst_vld_w2 (
    .din (tlu_thread_inst_vld_g[4-1:0]),
    .q   (inst_vld_w2[4-1:0]),
    .clk (clk),
    .rst (local_rst), 
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// added for bug 4395
dffr dffr_tcc_inst_w2 (
    .din (tlu_tcc_inst_w),
    .q   (tcc_inst_w2),
    .clk (clk),
    .rst (local_rst), 
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// modified for bug 4478
assign incr_pich[0] = pic_cnt_en_w2[0] & inst_vld_w2[0] & 
                      (~tlu_full_flush_pipe_w2 | tcc_inst_w2); 
assign incr_pich[1] = pic_cnt_en_w2[1] & inst_vld_w2[1] & 
                      (~tlu_full_flush_pipe_w2 | tcc_inst_w2);
assign incr_pich[2] = pic_cnt_en_w2[2] & inst_vld_w2[2] & 
                      (~tlu_full_flush_pipe_w2 | tcc_inst_w2);
assign incr_pich[3] = pic_cnt_en_w2[3] & inst_vld_w2[3] & 
                      (~tlu_full_flush_pipe_w2 | tcc_inst_w2);

assign pich_mux_sel[0] = pic_cnt_en_w2[0] & inst_vld_w2[0]; 
assign pich_mux_sel[1] = pic_cnt_en_w2[1] & inst_vld_w2[1];
assign pich_mux_sel[2] = pic_cnt_en_w2[2] & inst_vld_w2[2];
assign pich_mux_sel[3] = pic_cnt_en_w2[3] & inst_vld_w2[3];

// added for to make inst count overflow trap precise.
// added for bug 4314
assign pich_wrap_flg[0] = 
           (pich_cnt_wrap[0] ^ pich_cnt0[33-1]) & pic_cnt_en_w2[0]; 
assign pich_wrap_flg[1] = 
           (pich_cnt_wrap[1] ^ pich_cnt1[33-1]) & pic_cnt_en_w2[1];
assign pich_wrap_flg[2] = 
           (pich_cnt_wrap[2] ^ pich_cnt2[33-1]) & pic_cnt_en_w2[2];
assign pich_wrap_flg[3] = 
           (pich_cnt_wrap[3] ^ pich_cnt3[33-1]) & pic_cnt_en_w2[3];

// modified for bug 4270
// pic experiment
assign pich_fourbelow_din[0] = 
           (&pich_cnt0[33-2:2]) & pic_cnt_en_w2[0];
assign pich_fourbelow_din[1] = 
           (&pich_cnt1[33-2:2]) & pic_cnt_en_w2[1];
assign pich_fourbelow_din[2] = 
           (&pich_cnt2[33-2:2]) & pic_cnt_en_w2[2];
assign pich_fourbelow_din[3] = 
           (&pich_cnt3[33-2:2]) & pic_cnt_en_w2[3];
//
dff #(4) dff_pich_fourbelow_flg (
    .din (pich_fourbelow_din[4-1:0]),
    .q   (pich_fourbelow_flg[4-1:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

// modified for bug 4270
assign pich_onebelow_flg[0] = 
       (pich_fourbelow_flg[0] & pich_cnt0[1] & pich_cnt0[0]) & pic_cnt_en_w2[0]; 
assign pich_onebelow_flg[1] = 
       (pich_fourbelow_flg[1] & pich_cnt1[1] & pich_cnt1[0]) & pic_cnt_en_w2[1]; 
assign pich_onebelow_flg[2] = 
       (pich_fourbelow_flg[2] & pich_cnt2[1] & pich_cnt2[0]) & pic_cnt_en_w2[2]; 
assign pich_onebelow_flg[3] = 
       (pich_fourbelow_flg[3] & pich_cnt3[1] & pich_cnt3[0]) & pic_cnt_en_w2[3]; 
// 
assign pich_twobelow_flg[0] = 
       (pich_fourbelow_flg[0] & pich_cnt0[1] & ~pich_cnt0[0]) & pic_cnt_en_w2[0]; 
assign pich_twobelow_flg[1] = 
       (pich_fourbelow_flg[1] & pich_cnt1[1] & ~pich_cnt1[0]) & pic_cnt_en_w2[1]; 
assign pich_twobelow_flg[2] = 
       (pich_fourbelow_flg[2] & pich_cnt2[1] & ~pich_cnt2[0]) & pic_cnt_en_w2[2]; 
assign pich_twobelow_flg[3] = 
       (pich_fourbelow_flg[3] & pich_cnt3[1] & ~pich_cnt3[0]) & pic_cnt_en_w2[3]; 
//
/*
assign pich_threebelow_flg[0] = 
       (pich_fourbelow_flg[0] & ~pich_cnt0[1] & pich_cnt0[0]) & pic_cnt_en_w2[0]; 
assign pich_threebelow_flg[1] = 
       (pich_fourbelow_flg[1] & ~pich_cnt1[1] & pich_cnt1[0]) & pic_cnt_en_w2[1]; 
assign pich_threebelow_flg[2] = 
       (pich_fourbelow_flg[2] & ~pich_cnt2[1] & pich_cnt2[0]) & pic_cnt_en_w2[2]; 
assign pich_threebelow_flg[3] = 
       (pich_fourbelow_flg[3] & ~pich_cnt3[1] & pich_cnt3[0]) & pic_cnt_en_w2[3]; 
*/
//
// added for bug 4836 
assign pic_twobelow_e[0] = 
       pich_mux_sel[0]? (pich_fourbelow_flg[0] & ~pich_cnt0[1] & pich_cnt0[0]):
       (pich_fourbelow_flg[0] & pich_cnt0[1] & ~pich_cnt0[0]);
assign pic_twobelow_e[1] = 
       pich_mux_sel[1]? (pich_fourbelow_flg[1] & ~pich_cnt1[1] & pich_cnt1[0]):
       (pich_fourbelow_flg[1] & pich_cnt1[1] & ~pich_cnt1[0]);
assign pic_twobelow_e[2] = 
       pich_mux_sel[2]? (pich_fourbelow_flg[2] & ~pich_cnt2[1] & pich_cnt2[0]):
       (pich_fourbelow_flg[2] & pich_cnt2[1] & ~pich_cnt2[0]);
assign pic_twobelow_e[3] = 
       pich_mux_sel[3]? (pich_fourbelow_flg[3] & ~pich_cnt3[1] & pich_cnt3[0]):
       (pich_fourbelow_flg[3] & pich_cnt3[1] & ~pich_cnt3[0]);

assign tlu_pic_twobelow_e = 
           (thread_rsel_e[0]) ? pic_twobelow_e[0]:
           (thread_rsel_e[1]) ? pic_twobelow_e[1]:
           (thread_rsel_e[2]) ? pic_twobelow_e[2]:
            pic_twobelow_e[3];
//
assign pic_onebelow_e[0] = 
       pich_mux_sel[0]? (pich_fourbelow_flg[0] & pich_cnt0[1] & ~pich_cnt0[0]):
       (pich_fourbelow_flg[0] & pich_cnt0[1] & pich_cnt0[0]);
assign pic_onebelow_e[1] = 
       pich_mux_sel[1]? (pich_fourbelow_flg[1] & pich_cnt1[1] & ~pich_cnt1[0]):
       (pich_fourbelow_flg[1] & pich_cnt1[1] & pich_cnt1[0]);
assign pic_onebelow_e[2] = 
       pich_mux_sel[2]? (pich_fourbelow_flg[2] & pich_cnt2[1] & ~pich_cnt2[0]):
       (pich_fourbelow_flg[2] & pich_cnt2[1] & pich_cnt2[0]);
assign pic_onebelow_e[3] = 
       pich_mux_sel[3]? (pich_fourbelow_flg[3] & pich_cnt3[1] & ~pich_cnt3[0]):
       (pich_fourbelow_flg[3] & pich_cnt3[1] & pich_cnt3[0]);

assign tlu_pic_onebelow_e = 
           (thread_rsel_e[0]) ? pic_onebelow_e[0]:
           (thread_rsel_e[1]) ? pic_onebelow_e[1]:
           (thread_rsel_e[2]) ? pic_onebelow_e[2]:
            pic_onebelow_e[3];
//
assign pic_wrap_e[0] = 
       pich_mux_sel[0]? (pich_fourbelow_flg[0] & pich_cnt0[1] & pich_cnt0[0]):
       (pich_cnt_wrap[0] ^ pich_cnt0[33-1]);
assign pic_wrap_e[1] = 
       pich_mux_sel[1]? (pich_fourbelow_flg[1] & pich_cnt1[1] & pich_cnt1[0]):
       (pich_cnt_wrap[1] ^ pich_cnt1[33-1]);
assign pic_wrap_e[2] = 
       pich_mux_sel[2]? (pich_fourbelow_flg[2] & pich_cnt2[1] & pich_cnt2[0]):
       (pich_cnt_wrap[2] ^ pich_cnt2[33-1]);
assign pic_wrap_e[3] = 
       pich_mux_sel[3]? (pich_fourbelow_flg[3] & pich_cnt3[1] & pich_cnt3[0]):
       (pich_cnt_wrap[3] ^ pich_cnt3[33-1]);

assign tlu_pic_wrap_e = 
           (thread_rsel_e[0]) ? pic_wrap_e[0]:
           (thread_rsel_e[1]) ? pic_wrap_e[1]:
           (thread_rsel_e[2]) ? pic_wrap_e[2]:
            pic_wrap_e[3];
//
//
// modified for bug 5436: Niagara 2.0
assign tlu_pcr_ut[0] = pcr0[2];
assign tlu_pcr_ut[1] = pcr1[2];
assign tlu_pcr_ut[2] = pcr2[2];
assign tlu_pcr_ut[3] = pcr3[2];
//
assign tlu_pcr_st[0] = pcr0[1];
assign tlu_pcr_st[1] = pcr1[1];
assign tlu_pcr_st[2] = pcr2[1];
assign tlu_pcr_st[3] = pcr3[1];

assign tlu_pcr_ut_e = 
           (thread_rsel_e[0]) ? pcr0[2]: 
           (thread_rsel_e[1]) ? pcr1[2]: 
           (thread_rsel_e[2]) ? pcr2[2]:
            pcr3[2]; 

assign tlu_pcr_st_e = 
           (thread_rsel_e[0]) ? pcr0[1]:
           (thread_rsel_e[1]) ? pcr1[1]:
           (thread_rsel_e[2]) ? pcr2[1]:
            pcr3[1];

       
// reporting over-flow trap - needed to be precise, therefore
// bypassing tlb-miss traps 
// 
// selelcting the thread for incrementing for pich
// added for bug2332
//
// one-hot mux change
assign pich_cnt_din[33-1:0] =
       (pich_mux_sel[1])? pich_cnt1[33-1:0]:
       (pich_mux_sel[2])? pich_cnt2[33-1:0]:
       (pich_mux_sel[3])? pich_cnt3[33-1:0]:
       pich_cnt0[33-1:0];
/*
assign incr_pich_onehot = ~(|incr_pich[3:1]) | rst_tri_en;
mux4ds #(`PIB_PIC_CNT_WIDTH) mux_pich_cnt_din (
       .in0  (pich_cnt0[`PIB_PIC_CNT_WIDTH-1:0]),
       .in1  (pich_cnt1[`PIB_PIC_CNT_WIDTH-1:0]),
       .in2  (pich_cnt2[`PIB_PIC_CNT_WIDTH-1:0]),
       .in3  (pich_cnt3[`PIB_PIC_CNT_WIDTH-1:0]),
       .sel0 (incr_pich_onehot),
       .sel1 (incr_pich[1] & ~rst_tri_en),
       .sel2 (incr_pich[2] & ~rst_tri_en),
       .sel3 (incr_pich[3] & ~rst_tri_en),
       .dout (pich_cnt_din[`PIB_PIC_CNT_WIDTH-1:0])
);
*/
//
// pich incrementor  - shared between four threads
//
tlu_addern_32 #(33,1) pich_adder (
    .din  (pich_cnt_din[33-1:0]),
    .incr (1'b1),
    .sum  (pich_cnt_sum[33-1:0])
) ;
//
// extracting the wsr_data information to update the picls
//
assign pich_wsr_data = {1'b0, tlu_wsr_data_w[63:32]}; 

// constructing the selects to choose to update the pich 
assign update_pich_sel[0] = (local_rst | incr_pich[0] | wsr_pic_sel[0]); 
assign update_pich_sel[1] = (local_rst | incr_pich[1] | wsr_pic_sel[1]); 
assign update_pich_sel[2] = (local_rst | incr_pich[2] | wsr_pic_sel[2]); 
assign update_pich_sel[3] = (local_rst | incr_pich[3] | wsr_pic_sel[3]); 

// constructing the selects to choose to update the pich wrap 
assign update_pich_wrap_en[0] = 
           update_pich_sel[0] | wsr_pcr_sel[0]; 
assign update_pich_wrap_en[1] = 
           update_pich_sel[1] | wsr_pcr_sel[1]; 
assign update_pich_wrap_en[2] = 
           update_pich_sel[2] | wsr_pcr_sel[2]; 
assign update_pich_wrap_en[3] = 
           update_pich_sel[3] | wsr_pcr_sel[3]; 
//
// selecting the data for pich update
// thread 0 
mux3ds #(33) mux_update_pich0_data (
       .in0  ({33{1'b0}}),
       .in1  (pich_wsr_data[33-1:0]),
       .in2  (pich_cnt_sum[33-1:0]),
       .sel0 (local_rst),
       .sel1 (wsr_pic_sel[0] & ~local_rst),
       .sel2 (~(wsr_pic_sel[0] | local_rst)),
       .dout (update_pich0_data[33-1:0])
);

dffe #(33) dff_pich_cnt0 (
    .din (update_pich0_data[33-1:0]),
    .q   (pich_cnt0[33-1:0]),
    .clk (clk),
    .en  (update_pich_sel[0]),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// thread 1 
mux3ds #(33) mux_update_pich1_data (
       .in0  ({33{1'b0}}),
       .in1  (pich_wsr_data[33-1:0]),
       .in2  (pich_cnt_sum[33-1:0]),
       .sel0 (local_rst),
       .sel1 (wsr_pic_sel[1] & ~local_rst),
       .sel2 (~(wsr_pic_sel[1] | local_rst)), 
       .dout (update_pich1_data[33-1:0])
);

dffe #(33) dff_pich_cnt1 (
    .din (update_pich1_data[33-1:0]),
    .q   (pich_cnt1[33-1:0]),
    .clk (clk),
    .en  (update_pich_sel[1]),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// thread 2 
mux3ds #(33) mux_update_pich2_data (
       .in0  ({33{1'b0}}),
       .in1  (pich_wsr_data[33-1:0]),
       .in2  (pich_cnt_sum[33-1:0]),
       .sel0 (local_rst),
       .sel1 (wsr_pic_sel[2] & ~local_rst),
       .sel2 (~(wsr_pic_sel[2] | local_rst)),
       .dout (update_pich2_data[33-1:0])
);

dffe #(33) dff_pich_cnt2 (
    .din (update_pich2_data[33-1:0]),
    .q   (pich_cnt2[33-1:0]),
    .clk (clk),
    .en  (update_pich_sel[2]),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// thread 3
mux3ds #(33) mux_update_pich3_data (
       .in0  ({33{1'b0}}),
       .in1  (pich_wsr_data[33-1:0]),
       .in2  (pich_cnt_sum[33-1:0]),
       .sel0 (local_rst),
       .sel1 (wsr_pic_sel[3] & ~local_rst),
       .sel2 (~(wsr_pic_sel[3] | local_rst)),
       .dout (update_pich3_data[33-1:0])
);

dffe #(33) dff_pich_cnt3 (
    .din (update_pich3_data[33-1:0]),
    .q   (pich_cnt3[33-1:0]),
    .clk (clk),
    .en  (update_pich_sel[3]),
    .se  (se),       
    .si  (),          
    .so  ()
);

//==========================
// reading the PCRs and PICs 
//==========================
// decoding the thread information for rsr instruction from IFU
// modified due to timing
/*
assign thread_rsel_e[0] = ~(|ifu_tlu_thrid_e[1:0]);
assign thread_rsel_e[1] = ~ifu_tlu_thrid_e[1] &  ifu_tlu_thrid_e[0];
assign thread_rsel_e[2] =  ifu_tlu_thrid_e[1] & ~ifu_tlu_thrid_e[0];
assign thread_rsel_e[3] =  (&ifu_tlu_thrid_e[1:0]);
*/
assign thread_rsel_d[0] = ~(|ifu_tlu_thrid_d[1:0]);
assign thread_rsel_d[1] = ~ifu_tlu_thrid_d[1] &  ifu_tlu_thrid_d[0];
assign thread_rsel_d[2] =  ifu_tlu_thrid_d[1] & ~ifu_tlu_thrid_d[0];
// assign thread_rsel_d[3] =  (&ifu_tlu_thrid_d[1:0]);
//
dff #(4-1) dff_thread_rsel_e (
    .din (thread_rsel_d[4-2:0]),
    .q   (thread_rsel_e[4-2:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);
// selecting the correct pic for rdpr
// modified to avoid rte failure
assign pic_rdata_e[64-1:0] = 
       (thread_rsel_e[0])?
       {pich_cnt0[33-2:0], picl_cnt0[33-2:0]}:
       (thread_rsel_e[1])?
       {pich_cnt1[33-2:0], picl_cnt1[33-2:0]}:
       (thread_rsel_e[2])?
       {pich_cnt2[33-2:0], picl_cnt2[33-2:0]}:
       {pich_cnt3[33-2:0], picl_cnt3[33-2:0]};
/*
mux4ds #(`TLU_ASR_DATA_WIDTH) mux_pic_rdata (
        .in0    ({pich_cnt0[`PIB_PIC_CNT_WIDTH-2:0], picl_cnt0[`PIB_PIC_CNT_WIDTH-2:0]}),
        .in1    ({pich_cnt1[`PIB_PIC_CNT_WIDTH-2:0], picl_cnt1[`PIB_PIC_CNT_WIDTH-2:0]}),
        .in2    ({pich_cnt2[`PIB_PIC_CNT_WIDTH-2:0], picl_cnt2[`PIB_PIC_CNT_WIDTH-2:0]}),
        .in3    ({pich_cnt3[`PIB_PIC_CNT_WIDTH-2:0], picl_cnt3[`PIB_PIC_CNT_WIDTH-2:0]}),
        .sel0   (thread_rsel_e[0]),
        .sel1   (thread_rsel_e[1]),
        .sel2   (thread_rsel_e[2]),
        .sel3   (thread_rsel_e[3]),
        .dout   (pic_rdata_e[`TLU_ASR_DATA_WIDTH-1:0])
);

// selecting the correct pcr for rdpr
// modified for bug 2391
mux4ds #(`TLU_ASR_DATA_WIDTH) mux_pcr_rdata (
        .in0    ({58'b0,pcr0[`PIB_PCR_WIDTH-1:0]}), 
        .in1    ({58'b0,pcr1[`PIB_PCR_WIDTH-1:0]}),
        .in2    ({58'b0,pcr2[`PIB_PCR_WIDTH-1:0]}),
        .in3    ({58'b0,pcr3[`PIB_PCR_WIDTH-1:0]}),
        .sel0   (thread_rsel_e[0]),
        .sel1   (thread_rsel_e[1]),
        .sel2   (thread_rsel_e[2]),
        .sel3   (thread_rsel_e[3]),
        .dout   (pcr_rdata_e[`TLU_ASR_DATA_WIDTH-1:0])
);

mux4ds #(`PIB_PCR_WIDTH) mux_pcr_rdata (
        .in0    (pcr0[`PIB_PCR_WIDTH-1:0]), 
        .in1    (pcr1[`PIB_PCR_WIDTH-1:0]),
        .in2    (pcr2[`PIB_PCR_WIDTH-1:0]),
        .in3    (pcr3[`PIB_PCR_WIDTH-1:0]),
        .sel0   (thread_rsel_e[0]),
        .sel1   (thread_rsel_e[1]),
        .sel2   (thread_rsel_e[2]),
        .sel3   (thread_rsel_e[3]),
        .dout   (pcr_reg_rdata_e[`PIB_PCR_WIDTH-1:0])
);
*/

assign pcr_reg_rdata_e[8-1:0] =
       (thread_rsel_e[0])? pcr0[8-1:0]:
       (thread_rsel_e[1])? pcr1[8-1:0]:
       (thread_rsel_e[2])? pcr2[8-1:0]:
       pcr3[8-1:0];

assign pcr_rdata_e[64-1:0] =
           {54'b0, // rsvd bits 
            pcr_reg_rdata_e[7:6], 
            1'b0,  // rsvd bit
            pcr_reg_rdata_e[5:3], 
            1'b0,  // rsvd bit
            pcr_reg_rdata_e[2:0]}; 

// constructing the mux select for the output mux for rsr inst
assign rsr_data_sel_e[0] = pcr_rw_e;
assign rsr_data_sel_e[1] = ~pcr_rw_e; 

// modified due to timing 
// assign rsr_data_sel_e[1] = ~pcr_rw_e & (pic_npriv_rw_e | pic_priv_rw_e);
// assign rsr_data_sel_e[2] = ~(|rsr_data_sel_e[1:0]);
/*
mux3ds #(`TLU_ASR_DATA_WIDTH) mux_exu_rsr_data_e (
	.in0(pcr_rdata_e[`TLU_ASR_DATA_WIDTH-1:0]),  
	.in1(pic_rdata_e[`TLU_ASR_DATA_WIDTH-1:0]),
	.in2(tlu_pib_rsr_data_e[`TLU_ASR_DATA_WIDTH-1:0]),
	.sel0(rsr_data_sel_e[0]),
	.sel1(rsr_data_sel_e[1]),
	.sel2(rsr_data_sel_e[2]),
	.dout(tlu_exu_rsr_data_e[`TLU_ASR_DATA_WIDTH-1:0])
);
*/
mux2ds #(64) mux_tlu_pib_rsr_data_e (
	.in0(pcr_rdata_e[64-1:0]),  
	.in1(pic_rdata_e[64-1:0]),
	.sel0(rsr_data_sel_e[0]),
	.sel1(rsr_data_sel_e[1]),
	.dout(tlu_pib_rsr_data_e[64-1:0])
);
//==========================
// over_flow trap 
//==========================
// staged the wrap bit for comparison
//
// thread 0 - modified for bug 3937
mux2ds mux_picl_cnt_wrap_datain_0 (
	.in0(picl_cnt0[33-1] ^ pcr_wdata_in[6]),
	.in1(picl_cnt0[33-1]),
	.sel0(wsr_pcr_sel[0]),
	.sel1(~wsr_pcr_sel[0]),
	.dout(picl_cnt_wrap_datain[0])
);

mux2ds mux_pich_cnt_wrap_datain_0 (
	.in0(pich_cnt0[33-1] ^ pcr_wdata_in[7]),
	.in1(pich_cnt0[33-1]),
	.sel0(wsr_pcr_sel[0]),
	.sel1(~wsr_pcr_sel[0]),
	.dout(pich_cnt_wrap_datain[0])
);
/*
assign picl_cnt_wrap_datain[0] = 
           (picl_cnt0[`PIB_PIC_CNT_WIDTH-1] ^ pcr_wdata_in[`PIB_PCR_CL_OVF]);

assign pich_cnt_wrap_datain[0] = 
           (pich_cnt0[`PIB_PIC_CNT_WIDTH-1] ^ pcr_wdata_in[`PIB_PCR_CH_OVF]);
*/

dffre dffre_picl0_wrap (
    .din (picl_cnt_wrap_datain[0]),
    .q   (picl_cnt_wrap[0]),
    .clk (clk),
    .en  (update_picl_wrap_en[0]),
    .rst (local_rst | wsr_pic_sel[0]),
    .se  (se),       
    .si  (),          
    .so  ()
);

dffre dffre_pich0_wrap (
    .din (pich_cnt_wrap_datain[0]),
    .q   (pich_cnt_wrap[0]),
    .clk (clk),
    .en  (update_pich_wrap_en[0]),
    .rst (local_rst | wsr_pic_sel[0]),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// thread 1 - modified for bug 3937
mux2ds mux_picl_cnt_wrap_datain_1 (
	.in0(picl_cnt1[33-1] ^ pcr_wdata_in[6]),
	.in1(picl_cnt1[33-1]),
	.sel0(wsr_pcr_sel[1]),
	.sel1(~wsr_pcr_sel[1]),
	.dout(picl_cnt_wrap_datain[1])
);

mux2ds mux_pich_cnt_wrap_datain_1 (
	.in0(pich_cnt1[33-1] ^ pcr_wdata_in[7]),
	.in1(pich_cnt1[33-1]),
	.sel0(wsr_pcr_sel[1]),
	.sel1(~wsr_pcr_sel[1]),
	.dout(pich_cnt_wrap_datain[1])
);
/*
assign picl_cnt_wrap_datain[1] = 
           (picl_cnt1[`PIB_PIC_CNT_WIDTH-1] ^ pcr_wdata_in[`PIB_PCR_CL_OVF]); 

assign pich_cnt_wrap_datain[1] = 
           (pich_cnt1[`PIB_PIC_CNT_WIDTH-1] ^ pcr_wdata_in[`PIB_PCR_CH_OVF]); 
*/

dffre dffre_picl1_wrap (
    .din (picl_cnt_wrap_datain[1]),
    .q   (picl_cnt_wrap[1]),
    .clk (clk),
    .en  (update_picl_wrap_en[1]),
    .rst (local_rst | wsr_pic_sel[1]),
    .se  (se),       
    .si  (),          
    .so  ()
);

dffre dffre_pich1_wrap (
    .din (pich_cnt_wrap_datain[1]),
    .q   (pich_cnt_wrap[1]),
    .clk (clk),
    .en  (update_pich_wrap_en[1]),
    .rst (local_rst | wsr_pic_sel[1]),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// thread 2 - modified for bug 3937
mux2ds mux_picl_cnt_wrap_datain_2 (
	.in0(picl_cnt2[33-1] ^ pcr_wdata_in[6]),
	.in1(picl_cnt2[33-1]),
	.sel0(wsr_pcr_sel[2]),
	.sel1(~wsr_pcr_sel[2]),
	.dout(picl_cnt_wrap_datain[2])
);

mux2ds mux_pich_cnt_wrap_datain_2 (
	.in0(pich_cnt2[33-1] ^ pcr_wdata_in[7]),
	.in1(pich_cnt2[33-1]),
	.sel0(wsr_pcr_sel[2]),
	.sel1(~wsr_pcr_sel[2]),
	.dout(pich_cnt_wrap_datain[2])
);
/*
assign picl_cnt_wrap_datain[2] = 
           (picl_cnt2[`PIB_PIC_CNT_WIDTH-1] ^ pcr_wdata_in[`PIB_PCR_CL_OVF]); 

assign pich_cnt_wrap_datain[2] = 
           (pich_cnt2[`PIB_PIC_CNT_WIDTH-1] ^ pcr_wdata_in[`PIB_PCR_CH_OVF]); 
*/

dffre dffre_picl2_wrap (
    .din (picl_cnt_wrap_datain[2]),
    .q   (picl_cnt_wrap[2]),
    .clk (clk),
    .en  (update_picl_wrap_en[2]),
    .rst (local_rst | wsr_pic_sel[2]),
    .se  (se),       
    .si  (),          
    .so  ()
);

dffre dffre_pich2_wrap (
    .din (pich_cnt_wrap_datain[2]),
    .q   (pich_cnt_wrap[2]),
    .clk (clk),
    .en  (update_pich_wrap_en[2]),
    .rst (local_rst | wsr_pic_sel[2]),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// thread 3 - modified for bug 3937
mux2ds mux_picl_cnt_wrap_datain_3 (
	.in0(picl_cnt3[33-1] ^ pcr_wdata_in[6]),
	.in1(picl_cnt3[33-1]),
	.sel0(wsr_pcr_sel[3]),
	.sel1(~wsr_pcr_sel[3]),
	.dout(picl_cnt_wrap_datain[3])
);

mux2ds mux_pich_cnt_wrap_datain_3 (
	.in0(pich_cnt3[33-1] ^ pcr_wdata_in[7]),
	.in1(pich_cnt3[33-1]),
	.sel0(wsr_pcr_sel[3]),
	.sel1(~wsr_pcr_sel[3]),
	.dout(pich_cnt_wrap_datain[3])
);
/*
assign picl_cnt_wrap_datain[3] = 
           (picl_cnt3[`PIB_PIC_CNT_WIDTH-1] ^ pcr_wdata_in[`PIB_PCR_CL_OVF]);

assign pich_cnt_wrap_datain[3] = 
           (pich_cnt3[`PIB_PIC_CNT_WIDTH-1] ^ pcr_wdata_in[`PIB_PCR_CH_OVF]); 
*/

dffre dffre_picl3_wrap (
    .din (picl_cnt_wrap_datain[3]),
    .q   (picl_cnt_wrap[3]),
    .clk (clk),
    .en  (update_picl_wrap_en[3]),
    .rst (local_rst | wsr_pic_sel[3]),
    .se  (se),       
    .si  (),          
    .so  ()
);

dffre dffre_pich3_wrap (
    .din (pich_cnt_wrap_datain[3]),
    .q   (pich_cnt_wrap[3]),
    .clk (clk),
    .en  (update_pich_wrap_en[3]),
    .rst (local_rst | wsr_pic_sel[3]),
    .se  (se),       
    .si  (),          
    .so  ()
);
//
// generating the over-flow (0->1) to be set in sftint[15]
assign pib_picl_wrap[0] = 
         ((picl_cnt_wrap[0] ^ picl_cnt0[33-1]) & incr_evq[0]);  
assign pib_picl_wrap[1] = 
         ((picl_cnt_wrap[1] ^ picl_cnt1[33-1]) & incr_evq[1]);  
assign pib_picl_wrap[2] = 
         ((picl_cnt_wrap[2] ^ picl_cnt2[33-1]) & incr_evq[2]);  
assign pib_picl_wrap[3] = 
         ((picl_cnt_wrap[3] ^ picl_cnt3[33-1]) & incr_evq[3]);  
//
endmodule
