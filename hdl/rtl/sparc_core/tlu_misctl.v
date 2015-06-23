// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: tlu_misctl.v
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
//      Description:    Block that contain most of miscellaneous 
//                      control and datapath components 
//                      to alleviate tdp and tcp congestions 
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

module	tlu_misctl (/*AUTOARG*/
    // outputs
    tlu_exu_cwp_m, tlu_exu_ccr_m, tlu_lsu_asi_m, tlu_cwp_no_change_m, 
    tlu_sscan_misctl_data, tlu_ifu_trappc_w2, tlu_ifu_trapnpc_w2, 
    tlu_pc_new_w, tlu_npc_new_w, so, 
    // PIC experiment
    tlu_exu_pic_onebelow_m, tlu_exu_pic_twobelow_m, 
    // inputs
    ctu_sscan_tid, ifu_tlu_pc_m, exu_tlu_cwp0, exu_tlu_cwp1, exu_tlu_cwp2, 
    exu_tlu_cwp3, tlu_final_ttype_w2, tsa_wr_tid, tlu_true_pc_sel_w, 
    tsa1_wr_vld, tsa_ttype_en, tsa_rd_vld_e, tsa0_rdata_cwp, tsa0_rdata_pstate,
    tsa0_rdata_asi, tsa0_rdata_ccr, tsa0_rdata_gl, tsa0_rdata_pc, tsa1_rdata_ttype, 
    tsa1_rdata_npc, tsa1_rdata_htstate, tlu_thrd_rsel_e, tlu_final_offset_w1, 
    tlu_partial_trap_pc_w1,  tlu_restore_pc_w1, tlu_restore_npc_w1, 
    ifu_npc_w, tlu_restore_pc_sel_w1, tlu_pic_cnt_en_m, tlu_pic_onebelow_e,
    tlu_pic_twobelow_e, tlu_rst, si, se, rclk);
    // pich_threebelow_flg, pich_twobelow_flg, pich_onebelow_flg, 

//=================================================
// output
//=================================================
output [8-1:0] tlu_exu_ccr_m; // restored ccr
output [3-1:0] tlu_exu_cwp_m; // restored cwp
output [8-1:0] tlu_lsu_asi_m; // restored asi
output tlu_cwp_no_change_m; // cwp change indicator
//
// sscan output
output [9-1:0] tlu_sscan_misctl_data;
//
// trap pc and npc
output [48:0] tlu_ifu_trappc_w2, tlu_ifu_trapnpc_w2; 
output [48:0] tlu_pc_new_w, tlu_npc_new_w; 
// global nets
output so;
// PIC experiment
output       tlu_exu_pic_onebelow_m; // local traps send to exu 
output       tlu_exu_pic_twobelow_m; // local traps send to exu 

//=================================================
// input
//=================================================
// sscan related inputs
input [4-1:0] ctu_sscan_tid;
input [9-1:0] tlu_final_ttype_w2;
input [1:0] tsa_wr_tid;	
input tsa1_wr_vld, tsa_rd_vld_e; 
input tsa_ttype_en; 
// 
// current cwp value from exu
input [2:0]  exu_tlu_cwp0;  // cwp - thread0
input [2:0]  exu_tlu_cwp1;  // cwp - thread1
input [2:0]  exu_tlu_cwp2;  // cwp - thread2
input [2:0]  exu_tlu_cwp3;  // cwp - thread3
// 
// componets from trap stack arrays (tsas)
input [3-1:0] tsa0_rdata_cwp;
input [8-1:0] tsa0_rdata_pstate;
input [8-1:0] tsa0_rdata_ccr;
input [8-1:0] tsa0_rdata_asi;
input [2-1:0] tsa0_rdata_gl;
input [46:0] tsa0_rdata_pc;
input [9-1:0] tsa1_rdata_ttype;
input [46:0] tsa1_rdata_npc;
input [4-1:0] tsa1_rdata_htstate;
//
// trap pc calculations signals
input [48:0] ifu_tlu_pc_m;	  // pc
// input [48:0] ifu_tlu_npc_m;   // npc
input [9-1:0] tlu_final_offset_w1;
input [33:0] tlu_partial_trap_pc_w1;
input [48:0] tlu_restore_pc_w1;
input [48:0] tlu_restore_npc_w1;
// input [48:0] ifu_pc_w;
input [48:0] ifu_npc_w;
input tlu_restore_pc_sel_w1; 
//
// modified due to timing fix
input [2:0] tlu_true_pc_sel_w;
// input tlu_retry_inst_m;
// input tlu_done_inst_m;
// input tlu_dnrtry_inst_m_l;
//
input [4-1:0] tlu_thrd_rsel_e;
// global nets
input si, se;
//
//clk
input rclk;
//
// PIC trap experiment 
// input [`TLU_THRD_NUM-1:0] tlu_thread_inst_vld_w2; // valid inst for a thread
// input [`TLU_THRD_NUM-1:0] pich_threebelow_flg;
// input [`TLU_THRD_NUM-1:0] pich_twobelow_flg;
// input [`TLU_THRD_NUM-1:0] pich_onebelow_flg;
input tlu_pic_onebelow_e;
input tlu_pic_twobelow_e;
input tlu_pic_cnt_en_m;
input tlu_rst;

//=================================================
// local wires
//=================================================
// local clock
wire clk;
//
// staged thread id
wire [4-1:0] thrd_sel_m;
wire [4-1:0] tsa_wsel_thrd_w2;
// 
// staged tsa_controls
wire tsa_rd_vld_m; // tsa_rd_vld_e,  
// 
// components from tsas
// tsa0
wire [8-1:0] tsa0_asi_m;
wire [3-1:0] tsa0_cwp_m;
wire [8-1:0] tsa0_ccr_m;
wire [8-1:0] tsa0_pstate_m;
wire [2-1:0] tsa0_gl_m;
wire [46:0] tsa0_pc_m;
// tsa1
wire [9-1:0]   tsa1_ttype_m;
wire [4-1:0] tsa1_htstate_m;
wire [46:0] tsa1_npc_m;
//
// modified for timing
// wire [48:0] pc_new_m, npc_new_m;
wire [48:0] pc_new_w, npc_new_w, ifu_pc_w;
wire [46:0] tsa0_pc_w, tsa1_npc_w;
// 
// sscan related signals 
wire [4-1:0] sscan_tid_sel; 
wire [4-1:0] sscan_ttype_en;
wire [4-1:0] sscan_tt_rd_sel;
wire [4-1:0] sscan_tt_wr_sel;
wire [9-1:0] sscan_tt0_data;
wire [9-1:0] sscan_tt1_data;
wire [9-1:0] sscan_tt2_data;
wire [9-1:0] sscan_tt3_data;
wire [9-1:0] sscan_tt0_din;
wire [9-1:0] sscan_tt1_din;
wire [9-1:0] sscan_tt2_din;
wire [9-1:0] sscan_tt3_din;
wire [9-1:0] misctl_sscan_test_data;
//
// cwp logic 
wire cwp_no_change_m;
wire [3-1:0] cwp_xor_m, trap_old_cwp_m; 
wire [48:0] normal_trap_pc_w1, normal_trap_npc_w1; 
wire [48:0] trap_pc_w1, trap_npc_w1; 
wire [48:0] trap_pc_w2, trap_npc_w2; 
//
// PIC experiment
wire tlu_pic_onebelow_m, tlu_pic_twobelow_m; 
// wire [`TLU_THRD_NUM-1:0] pic_onebelow_e, pic_twobelow_e; 
wire local_rst;
// 
//=========================================================================================
// local clock
//=========================================================================================

assign clk = rclk; 

//=========================================================================================
//	TSA data capture
//=========================================================================================

dff #(8) dff_tsa0_ccr_m (
    .din (tsa0_rdata_ccr[8-1:0]),
    .q   (tsa0_ccr_m[8-1:0]),
    .clk (clk),
    .se  (se),
    .si  (),
    .so  ()
);

dff #(3) dff_tsa0_cwp_m (
    .din (tsa0_rdata_cwp[3-1:0]),
    .q   (tsa0_cwp_m[3-1:0]),
    .clk (clk),
    .se  (se),
    .si  (),
    .so  ()
);

dff #(8) dff_lsu_asi_m (
    .din (tsa0_rdata_asi[8-1:0]),
    .q   (tsa0_asi_m[8-1:0]),
    .clk (clk),
    .se  (se),
    .si  (),
    .so  ()
    );

dff #(8) dff_tsa0_pstate_m (
    .din (tsa0_rdata_pstate[8-1:0]),
    .q   (tsa0_pstate_m[8-1:0]),
    .clk (clk),
    .se  (se),
    .si  (),
    .so  ()
);

dff #(2) dff_tsa0_gl_m (
    .din (tsa0_rdata_gl[2-1:0]),
    .q   (tsa0_gl_m[2-1:0]),
    .clk (clk),
    .se  (se),
    .si  (),
    .so  ()
);

dff #(47) dff_tsa0_pc_m (
    .din (tsa0_rdata_pc[46:0]),
    .q   (tsa0_pc_m[46:0]),
    .clk (clk),
    .se  (se),
    .si  (),
    .so  ()
);

dff #(9) dff_tsa1_ttype_m (
    .din (tsa1_rdata_ttype[9-1:0]), 
	.q   (tsa1_ttype_m[9-1:0]),
    .clk (clk),
    .se  (se),
    .si  (),
    .so  ()
);

dff #(4) dff_tsa1_htstate_m (
    .din (tsa1_rdata_htstate[4-1:0]), 
	.q   (tsa1_htstate_m[4-1:0]),
    .clk (clk),
    .se  (se),
    .si  (),
    .so  ()
);

dff #(47) dff_tsa1_npc_m (
    .din (tsa1_rdata_npc[46:0]),
    .q   (tsa1_npc_m[46:0]),
    .clk (clk),
    .se  (se),
    .si  (),
    .so  ()
);
//
//=========================================================================================
//	CWP/CCR restoration
//=========================================================================================

assign tlu_exu_ccr_m[8-1:0] = 
           tsa0_ccr_m[8-1:0];
assign tlu_exu_cwp_m[3-1:0] = 
           tsa0_cwp_m[3-1:0];
assign tlu_lsu_asi_m[8-1:0] = 
           tsa0_asi_m[8-1:0];

// modified/added for timing violations
// moved the logic from exu to tlu due to timing violations

dff #(4) dff_thrd_sel_m (
    .din (tlu_thrd_rsel_e[4-1:0]),
	.q   (thrd_sel_m[4-1:0]),
    .clk (clk),
    .se  (se),
    .si  (),
    .so  ()
);

mux4ds #(3) mux_trap_old_cwp_m(
    .in0(exu_tlu_cwp0[3-1:0]),
    .in1(exu_tlu_cwp1[3-1:0]), 
    .in2(exu_tlu_cwp2[3-1:0]),
    .in3(exu_tlu_cwp3[3-1:0]),
    .sel0(thrd_sel_m[0]),
    .sel1(thrd_sel_m[1]),
    .sel2(thrd_sel_m[2]),
    .sel3(thrd_sel_m[3]),
    .dout(trap_old_cwp_m[3-1:0])
);

assign cwp_xor_m[3-1:0] = 
           trap_old_cwp_m[3-1:0] ^ tlu_exu_cwp_m[3-1:0];

assign cwp_no_change_m = ~|(cwp_xor_m[3-1:0]); 

assign tlu_cwp_no_change_m = cwp_no_change_m;

//=========================================================================================
//	Generate TTYPE SSCAN data 
//=========================================================================================
//
// staging the tsa_rd_vld signal
// moved to tlu_tcl for timing 
/* 
dff dff_tsa_rd_vld_e ( 
    .din (tsa_rd_vld),
	.q   (tsa_rd_vld_e),
    .clk (clk),
    .se  (se),
    .si  (),
    .so  ()
);
*/

dff dff_tsa_rd_vld_m (
    .din (tsa_rd_vld_e),
	.q   (tsa_rd_vld_m),
    .clk (clk),
    .se  (se),
    .si  (),
    .so  ()
);

assign	tsa_wsel_thrd_w2[0] = ~tsa_wr_tid[1] & ~tsa_wr_tid[0];
assign	tsa_wsel_thrd_w2[1] = ~tsa_wr_tid[1] &  tsa_wr_tid[0];
assign	tsa_wsel_thrd_w2[2]=   tsa_wr_tid[1] & ~tsa_wr_tid[0];
assign	tsa_wsel_thrd_w2[3] =  tsa_wr_tid[1] &  tsa_wr_tid[0];

// generating write indicators of ttype to the tsa
assign sscan_tt_wr_sel[0] = 
           tsa_ttype_en & tsa1_wr_vld & tsa_wsel_thrd_w2[0]; 
assign sscan_tt_wr_sel[1] = 
           tsa_ttype_en & tsa1_wr_vld & tsa_wsel_thrd_w2[1]; 
assign sscan_tt_wr_sel[2] = 
           tsa_ttype_en & tsa1_wr_vld & tsa_wsel_thrd_w2[2]; 
assign sscan_tt_wr_sel[3] = 
           tsa_ttype_en & tsa1_wr_vld & tsa_wsel_thrd_w2[3];
//
// generating read indicators of ttype from the tsa
assign sscan_tt_rd_sel[0] = 
           tsa_rd_vld_m & thrd_sel_m[0]; 
assign sscan_tt_rd_sel[1] = 
           tsa_rd_vld_m & thrd_sel_m[1]; 
assign sscan_tt_rd_sel[2] = 
           tsa_rd_vld_m & thrd_sel_m[2]; 
assign sscan_tt_rd_sel[3] = 
           tsa_rd_vld_m & thrd_sel_m[3]; 

assign sscan_ttype_en[0] = 
           sscan_tt_rd_sel[0] | sscan_tt_wr_sel[0]; 
assign sscan_ttype_en[1] = 
           sscan_tt_rd_sel[1] | sscan_tt_wr_sel[1]; 
assign sscan_ttype_en[2] = 
           sscan_tt_rd_sel[2] | sscan_tt_wr_sel[2]; 
assign sscan_ttype_en[3] = 
           sscan_tt_rd_sel[3] | sscan_tt_wr_sel[3]; 
//
assign sscan_tt0_din[9-1:0] = 
           (sscan_tt_wr_sel[0]) ? 
            tlu_final_ttype_w2[9-1:0] :
            tsa1_ttype_m[9-1:0];  
assign sscan_tt1_din[9-1:0] = 
           (sscan_tt_wr_sel[1]) ? 
            tlu_final_ttype_w2[9-1:0] :
            tsa1_ttype_m[9-1:0];  
assign sscan_tt2_din[9-1:0] = 
           (sscan_tt_wr_sel[2]) ? 
            tlu_final_ttype_w2[9-1:0] :
            tsa1_ttype_m[9-1:0];  
assign sscan_tt3_din[9-1:0] = 
           (sscan_tt_wr_sel[3]) ? 
            tlu_final_ttype_w2[9-1:0] :
            tsa1_ttype_m[9-1:0];  
//
dffe #(9) dffe_sscan_tt0_data (
    .din (sscan_tt0_din[9-1:0]), 
    .q   (sscan_tt0_data[9-1:0]),
    .en  (sscan_ttype_en[0]), 
    .clk (clk),
    .se  (se),
    .si  (),
    .so  ()
);

dffe #(9) dffe_sscan_tt1_data (
    .din (sscan_tt1_din[9-1:0]), 
    .q   (sscan_tt1_data[9-1:0]),
    .en  (sscan_ttype_en[1]), 
    .clk (clk),
    .se  (se),
    .si  (),
    .so  ()
);

dffe #(9) dffe_sscan_tt2_data (
    .din (sscan_tt2_din[9-1:0]), 
    .q   (sscan_tt2_data[9-1:0]),
    .en  (sscan_ttype_en[2]), 
    .clk (clk),
    .se  (se),
    .si  (),
    .so  ()
);

dffe #(9) dffe_sscan_tt3_data (
    .din (sscan_tt3_din[9-1:0]), 
    .q   (sscan_tt3_data[9-1:0]),
    .en  (sscan_ttype_en[3]), 
    .clk (clk),
    .se  (se),
    .si  (),
    .so  ()
);

assign sscan_tid_sel[4-1:0] = 
           ctu_sscan_tid[4-1:0]; 

mux4ds #(9) mx_sscan_test_data (
       .in0  (sscan_tt0_data[9-1:0]),
       .in1  (sscan_tt1_data[9-1:0]),
       .in2  (sscan_tt2_data[9-1:0]),
       .in3  (sscan_tt3_data[9-1:0]),
       .sel0 (sscan_tid_sel[0]),
       .sel1 (sscan_tid_sel[1]),
       .sel2 (sscan_tid_sel[2]),
       .sel3 (sscan_tid_sel[3]),
       .dout (misctl_sscan_test_data[9-1:0])
); 

assign tlu_sscan_misctl_data[9-1:0] = 
           misctl_sscan_test_data[9-1:0]; 
//
// code moved from tlu_tcl - trap pc delivery logic
// 
assign	normal_trap_pc_w1[48:0] = 
            {1'b0, tlu_partial_trap_pc_w1[33:0],
             tlu_final_offset_w1[9-1:0], 5'b00000};
assign	normal_trap_npc_w1[48:0] = 
            {1'b0, tlu_partial_trap_pc_w1[33:0],
             tlu_final_offset_w1[9-1:0], 5'b00100};
//
// code moved from tlu_tdp
mux2ds #(49) mx_trap_pc_w1 (
       .in0  (normal_trap_pc_w1[48:0]), 
       .in1  (tlu_restore_pc_w1[48:0]),
       .sel0 (~tlu_restore_pc_sel_w1),  
       .sel1 (tlu_restore_pc_sel_w1),
       .dout (trap_pc_w1[48:0])
);           
//
dff #(49) dff_trap_pc_w2 (
    .din (trap_pc_w1[48:0]), 	
    .q   (trap_pc_w2[48:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

assign tlu_ifu_trappc_w2[48:0] = trap_pc_w2[48:0];

mux2ds #(49) mx_trap_npc_w1 (
       .in0  (normal_trap_npc_w1[48:0]), 
       .in1  (tlu_restore_npc_w1[48:0]),
       .sel0 (~tlu_restore_pc_sel_w1),  
       .sel1 (tlu_restore_pc_sel_w1),
       .dout (trap_npc_w1[48:0])
);           
//
dff #(49) dff_trap_npc_w2 (
    .din (trap_npc_w1[48:0]), 	
    .q   (trap_npc_w2[48:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

assign tlu_ifu_trapnpc_w2[48:0] = trap_npc_w2[48:0];

//--------------------------------------------------------------------------------
// Recovery PC and NPC selection 
//--------------------------------------------------------------------------------
// On done, npc will become pc. 
// modified for timing
//
dff #(47) dff_tsa0_pc_w (
    .din (tsa0_pc_m[46:0]), 	
    .q   (tsa0_pc_w[46:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

dff #(49) dff_ifu_pc_w (
    .din (ifu_tlu_pc_m[48:0]), 	
    .q   (ifu_pc_w[48:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

mux3ds #(49) mux_pc_new_w (
       .in0  ({tsa0_pc_w[46:0], 2'b00}), 	
	   .in1  ({tsa1_npc_w[46:0], 2'b00}),
	   .in2  (ifu_pc_w[48:0]),
       .sel0 (tlu_true_pc_sel_w[0]),  	
	   .sel1 (tlu_true_pc_sel_w[1]),
	   .sel2 (tlu_true_pc_sel_w[2]),
       .dout (pc_new_w[48:0])
); 

assign tlu_pc_new_w[48:0] = pc_new_w[48:0];

//
// On done, npc will become pc. 
// On done, npc will stay npc. The valid to the IFU will
// not be signaled along with npc for a done. 
// modified for timing
dff #(47) dff_tsa1_npc_w (
    .din (tsa1_npc_m[46:0]), 	
    .q   (tsa1_npc_w[46:0]),
    .clk (clk),
    .se  (se),       
    .si  (),          
    .so  ()
);

mux2ds #(49) mux_npc_new_w (
       .in0  ({tsa1_npc_w[46:0],2'b00}), 	
       .in1  (ifu_npc_w[48:0]),
       .sel0 (~tlu_true_pc_sel_w[2]),  	
       .sel1 (tlu_true_pc_sel_w[2]),
       .dout (npc_new_w[48:0])
); 

assign tlu_npc_new_w[48:0] = npc_new_w[48:0];

//--------------------------------------------------------------------------------
// PIC trap experiment 
//--------------------------------------------------------------------------------

// added for bug 4785
assign local_rst = tlu_rst;

dffr dffr_tlu_exu_pic_onebelow_m (
   .din (tlu_pic_onebelow_e),
   .q   (tlu_pic_onebelow_m),
   .rst (local_rst),
   .clk (clk),
   .se  (se),       
   .si  (),          
   .so  ()
);

dffr dffr_tlu_exu_pic_twobelow_m (
   .din (tlu_pic_twobelow_e),
   .q   (tlu_pic_twobelow_m),
   .rst (local_rst),
   .clk (clk),
   .se  (se),       
   .si  (),          
   .so  ()
);

assign tlu_exu_pic_onebelow_m = 
           tlu_pic_onebelow_m & tlu_pic_cnt_en_m;

assign tlu_exu_pic_twobelow_m = 
           tlu_pic_twobelow_m & tlu_pic_cnt_en_m;

/*
assign pic_onebelow_e[0] = 
       tlu_thread_inst_vld_w2[0]? pich_twobelow_flg[0]: pich_onebelow_flg[0];
assign pic_onebelow_e[1] = 
       tlu_thread_inst_vld_w2[1]? pich_twobelow_flg[1]: pich_onebelow_flg[1];
assign pic_onebelow_e[2] = 
       tlu_thread_inst_vld_w2[2]? pich_twobelow_flg[2]: pich_onebelow_flg[2];
assign pic_onebelow_e[3] = 
       tlu_thread_inst_vld_w2[3]? pich_twobelow_flg[3]: pich_onebelow_flg[3];

assign tlu_pic_onebelow_e = 
           (tlu_thrd_rsel_e[0]) ? pic_onebelow_e[0]:
           (tlu_thrd_rsel_e[1]) ? pic_onebelow_e[1]:
           (tlu_thrd_rsel_e[2]) ? pic_onebelow_e[2]:
            pic_onebelow_e[3];

assign pic_twobelow_e[0] = 
       tlu_thread_inst_vld_w2[0]? pich_threebelow_flg[0]: pich_twobelow_flg[0];
assign pic_twobelow_e[1] = 
       tlu_thread_inst_vld_w2[1]? pich_threebelow_flg[1]: pich_twobelow_flg[1];
assign pic_twobelow_e[2] = 
       tlu_thread_inst_vld_w2[2]? pich_threebelow_flg[2]: pich_twobelow_flg[2];
assign pic_twobelow_e[3] = 
       tlu_thread_inst_vld_w2[3]? pich_threebelow_flg[3]: pich_twobelow_flg[3];

assign tlu_pic_twobelow_e = 
           (tlu_thrd_rsel_e[0]) ? pic_twobelow_e[0]:
           (tlu_thrd_rsel_e[1]) ? pic_twobelow_e[1]:
           (tlu_thrd_rsel_e[2]) ? pic_twobelow_e[2]:
            pic_twobelow_e[3];
*/

endmodule
