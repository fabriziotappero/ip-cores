// ========== Copyright Header Begin ==========================================
// 
// OpenSPARC T1 Processor File: sparc.v
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
`include "sys.h"
`include "iop.h"
`include "ifu.h"
`include "tlu.h"
`include "lsu.h"
	 
module sparc (/*AUTOARG*/
   // Outputs
   spc_pcx_req_pq, spc_pcx_atom_pq, spc_pcx_data_pa, spc_sscan_so, 
   spc_scanout0, spc_scanout1, tst_ctu_mbist_done, 
   tst_ctu_mbist_fail, spc_efc_ifuse_data, spc_efc_dfuse_data, 
   // Inputs
   pcx_spc_grant_px, cpx_spc_data_rdy_cx2, cpx_spc_data_cx2, 
   const_cpuid, const_maskid, ctu_tck, ctu_sscan_se, ctu_sscan_snap, 
   ctu_sscan_tid, ctu_tst_mbist_enable, efc_spc_fuse_clk1, 
   efc_spc_fuse_clk2, efc_spc_ifuse_ashift, efc_spc_ifuse_dshift, 
   efc_spc_ifuse_data, efc_spc_dfuse_ashift, efc_spc_dfuse_dshift, 
   efc_spc_dfuse_data, ctu_tst_macrotest, ctu_tst_scan_disable, 
   ctu_tst_short_chain, global_shift_enable, ctu_tst_scanmode, 
   spc_scanin0, spc_scanin1, cluster_cken, gclk, cmp_grst_l, 
   cmp_arst_l, ctu_tst_pre_grst_l, adbginit_l, gdbginit_l
   );

   // these are the only legal IOs

   // pcx
   output [4:0]   spc_pcx_req_pq;    // processor to pcx request
   output         spc_pcx_atom_pq;   // processor to pcx atomic request
   output [`PCX_WIDTH-1:0] spc_pcx_data_pa;  // processor to pcx packet

   // shadow scan
   output     spc_sscan_so;         // From ifu of sparc_ifu.v
   output     spc_scanout0;         // From test_stub of test_stub_bist.v
   output     spc_scanout1;         // From test_stub of test_stub_bist.v

   // bist
   output     tst_ctu_mbist_done;  // From test_stub of test_stub_two_bist.v
   output     tst_ctu_mbist_fail;  // From test_stub of test_stub_two_bist.v

   // fuse
   output     spc_efc_ifuse_data;     // From ifu of sparc_ifu.v
   output     spc_efc_dfuse_data;     // From ifu of sparc_ifu.v


   // cpx interface
   input [4:0] pcx_spc_grant_px; // pcx to processor grant info  
   input       cpx_spc_data_rdy_cx2; // cpx data inflight to sparc  
   input [`CPX_WIDTH-1:0] cpx_spc_data_cx2;     // cpx to sparc data packet

   input [3:0]  const_cpuid;
   input [7:0]  const_maskid;           // To ifu of sparc_ifu.v

   // sscan
   input        ctu_tck;                // To ifu of sparc_ifu.v
   input        ctu_sscan_se;           // To ifu of sparc_ifu.v
   input        ctu_sscan_snap;         // To ifu of sparc_ifu.v
   input [3:0]  ctu_sscan_tid;          // To ifu of sparc_ifu.v

   // bist
   input        ctu_tst_mbist_enable;   // To test_stub of test_stub_bist.v

   // efuse
   input        efc_spc_fuse_clk1;
   input        efc_spc_fuse_clk2;
   input        efc_spc_ifuse_ashift;
   input        efc_spc_ifuse_dshift;
   input        efc_spc_ifuse_data;
   input        efc_spc_dfuse_ashift;
   input        efc_spc_dfuse_dshift;
   input        efc_spc_dfuse_data;
   
   // scan and macro test
   input        ctu_tst_macrotest;      // To test_stub of test_stub_bist.v
   input        ctu_tst_scan_disable;   // To test_stub of test_stub_bist.v
   input        ctu_tst_short_chain;    // To test_stub of test_stub_bist.v
   input        global_shift_enable;    // To test_stub of test_stub_two_bist.v
   input        ctu_tst_scanmode;       // To test_stub of test_stub_two_bist.v
   input        spc_scanin0;
   input        spc_scanin1;
   
   // clk
   input        cluster_cken;           // To spc_hdr of cluster_header.v
   input        gclk;                   // To spc_hdr of cluster_header.v

   // reset
   input        cmp_grst_l;
   input        cmp_arst_l;
   input        ctu_tst_pre_grst_l;     // To test_stub of test_stub_bist.v

   input        adbginit_l;             // To spc_hdr of cluster_header.v
   input        gdbginit_l;             // To spc_hdr of cluster_header.v


   // ----------------- End of IOs -------------------------- //

   /* AUTOOUTPUT*/
   /*AUTOINPUT*/
   // Beginning of automatic inputs (from unused autoinst inputs)
   // End of automatics

   // not hooked up yet
   wire [3:0]   tlu_dsfsr_flt_vld;      // To lsu of lsu.v
   wire         tlu_lsu_int_ld_ill_va_w2;// To lsu of lsu.v
   wire [9:0]   lsu_tlu_ldst_va_m;// To lsu of lsu.v
   wire [47:0]  lsu_ifu_stxa_data;	// From lsu of lsu.v

   wire         lsu_tlu_misalign_addr_ldst_atm_m ;// To tlu of tlu.v

   // name change at top level
   wire [3:0] 	tlu_ifu_sftint_vld;
   wire [3:0] 	tlu_hintp_vld;
   wire [3:0] 	tlu_rerr_vld;
   wire         lsu_exu_ldst_miss_g2;	// To exu of sparc_exu.v
   wire         lsu_ifu_ldst_miss_w;	// To exu of sparc_exu.v
   wire         lsu_exu_dfill_vld_g;
   wire [63:0]  lsu_exu_dfill_data_g;	// From lsu of lsu.v
   wire [62:0]  tlu_sscan_test_data;
   wire         lsu_ifu_tlb_data_ue;      // dtlb data asi rd parity error
   wire         lsu_ifu_tlb_tag_ue;       // dtlb tag asi rd parity error
   wire [8:0]   ifu_tlu_imm_asi_d;      // From ifu of sparc_ifu.v
   
   wire        ifu_lsu_wsr_inst_d;     // To lsu of lsu.v, ...
   wire        ifu_exu_wsr_inst_d; 

   // hypervisor stuff
   wire [3:0]   tlu_hpstate_enb,
                tlu_hpstate_priv,
                tlu_hpstate_ibe;

   // scan chain
   wire                    short_scan0_1;
   wire                    short_scan0_2;
   wire                    short_scan0_3;
   wire                    short_scan0_4;
   wire                    short_scan0_5;
   wire                    short_scan0_6;
   wire                    scan0_1;
   wire                    scan0_2;
   wire                    scan0_3;
   wire                    scan0_4;
   wire                    scan0_5;
   wire                    scan0_6;
   wire                    scan0_7;

   wire                    short_scan1_1;
   wire                    short_scan1_2;
   wire                    short_scan1_3;
   wire                    short_scan1_4;
   wire                    short_scan1_5;
   wire                    scan1_1;
   wire                    scan1_2;
   wire                    scan1_3;
   wire                    scan1_4;
   wire                    scan1_5;

   
   // bus width difference
   wire [12:0]	lsu_t0_pctxt_state;	// From lsu of lsu.v
   wire [12:0]	lsu_t1_pctxt_state;	// From lsu of lsu.v
   wire [12:0]	lsu_t2_pctxt_state;	// From lsu of lsu.v
   wire [12:0]	lsu_t3_pctxt_state;	// From lsu of lsu.v

   wire [6:0]  bist_ctl_reg_in;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [10:0]          bist_ctl_reg_out;       // From test_stub of test_stub_bist.v
   wire                 bist_ctl_reg_wr_en;     // From lsu of lsu.v
   wire [`CPX_WIDTH-1:0]cpx_spc_data_cx2_buf;   // From buf_cpx of cpx_spc_buf.v
   wire [`CPX_WIDTH-1:0]cpx_spc_data_cx3;       // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_rdy_cx2_buf;// From buf_cpx of cpx_spc_buf.v
   wire                 cpx_spc_data_rdy_cx3;   // From ff_cpx of cpx_spc_rpt.v
   wire                 exu_ffu_wsr_inst_e;     // From exu of sparc_exu.v
   wire [47:0]          exu_ifu_brpc_e;         // From exu of sparc_exu.v
   wire [7:0]           exu_ifu_cc_d;           // From exu of sparc_exu.v
   wire                 exu_ifu_ecc_ce_m;       // From exu of sparc_exu.v
   wire                 exu_ifu_ecc_ue_m;       // From exu of sparc_exu.v
   wire [7:0]           exu_ifu_err_reg_m;      // From exu of sparc_exu.v
   wire [7:0]           exu_ifu_err_synd_m;     // From exu of sparc_exu.v
   wire                 exu_ifu_inj_ack;        // From exu of sparc_exu.v
   wire [3:0]           exu_ifu_longop_done_g;  // From exu of sparc_exu.v
   wire [3:0]           exu_ifu_oddwin_s;       // From exu of sparc_exu.v
   wire                 exu_ifu_regn_e;         // From exu of sparc_exu.v
   wire                 exu_ifu_regz_e;         // From exu of sparc_exu.v
   wire                 exu_ifu_spill_e;        // From exu of sparc_exu.v
   wire                 exu_ifu_va_oor_m;       // From exu of sparc_exu.v
   wire [10:3]          exu_lsu_early_va_e;     // From exu of sparc_exu.v
   wire [47:0]          exu_lsu_ldst_va_e;      // From exu of sparc_exu.v
   wire                 exu_lsu_priority_trap_m;// From exu of sparc_exu.v
   wire [63:0]          exu_lsu_rs2_data_e;     // From exu of sparc_exu.v
   wire [63:0]          exu_lsu_rs3_data_e;     // From exu of sparc_exu.v
   wire [7:0]           exu_mmu_early_va_e;     // From exu of sparc_exu.v
   wire                 exu_mul_input_vld;      // From exu of sparc_exu.v
   wire [63:0]          exu_mul_rs1_data;       // From exu of sparc_exu.v
   wire [63:0]          exu_mul_rs2_data;       // From exu of sparc_exu.v
   wire [63:0]          exu_spu_rs3_data_e;     // From exu of sparc_exu.v
   wire [7:0]           exu_tlu_ccr0_w;         // From exu of sparc_exu.v
   wire [7:0]           exu_tlu_ccr1_w;         // From exu of sparc_exu.v
   wire [7:0]           exu_tlu_ccr2_w;         // From exu of sparc_exu.v
   wire [7:0]           exu_tlu_ccr3_w;         // From exu of sparc_exu.v
   wire [2:0]           exu_tlu_cwp0_w;         // From exu of sparc_exu.v
   wire [2:0]           exu_tlu_cwp1_w;         // From exu of sparc_exu.v
   wire [2:0]           exu_tlu_cwp2_w;         // From exu of sparc_exu.v
   wire [2:0]           exu_tlu_cwp3_w;         // From exu of sparc_exu.v
   wire                 exu_tlu_cwp_cmplt;      // From exu of sparc_exu.v
   wire [1:0]           exu_tlu_cwp_cmplt_tid;  // From exu of sparc_exu.v
   wire                 exu_tlu_cwp_retry;      // From exu of sparc_exu.v
   wire                 exu_tlu_misalign_addr_jmpl_rtn_m;// From exu of sparc_exu.v
   wire                 exu_tlu_spill;          // From exu of sparc_exu.v
   wire                 exu_tlu_spill_other;    // From exu of sparc_exu.v
   wire [1:0]           exu_tlu_spill_tid;      // From exu of sparc_exu.v
   wire [2:0]           exu_tlu_spill_wtype;    // From exu of sparc_exu.v
   wire [8:0]           exu_tlu_ttype_m;        // From exu of sparc_exu.v
   wire                 exu_tlu_ttype_vld_m;    // From exu of sparc_exu.v
   wire                 exu_tlu_va_oor_jl_ret_m;// From exu of sparc_exu.v
   wire                 exu_tlu_va_oor_m;       // From exu of sparc_exu.v
   wire [63:0]          exu_tlu_wsr_data_m;     // From exu of sparc_exu.v
   wire [63:0]          ffu_exu_rsr_data_m;     // From ffu of sparc_ffu.v
   wire [3:0]           ffu_ifu_cc_vld_w2;      // From ffu of sparc_ffu.v
   wire [7:0]           ffu_ifu_cc_w2;          // From ffu of sparc_ffu.v
   wire                 ffu_ifu_ecc_ce_w2;      // From ffu of sparc_ffu.v
   wire                 ffu_ifu_ecc_ue_w2;      // From ffu of sparc_ffu.v
   wire [5:0]           ffu_ifu_err_reg_w2;     // From ffu of sparc_ffu.v
   wire [13:0]          ffu_ifu_err_synd_w2;    // From ffu of sparc_ffu.v
   wire                 ffu_ifu_fpop_done_w2;   // From ffu of sparc_ffu.v
   wire                 ffu_ifu_fst_ce_w;       // From ffu of sparc_ffu.v
   wire                 ffu_ifu_inj_ack;        // From ffu of sparc_ffu.v
   wire                 ffu_ifu_stallreq;       // From ffu of sparc_ffu.v
   wire [1:0]           ffu_ifu_tid_w2;         // From ffu of sparc_ffu.v
   wire                 ffu_lsu_blk_st_e;       // From ffu of sparc_ffu.v
   wire [5:3]           ffu_lsu_blk_st_va_e;    // From ffu of sparc_ffu.v
   wire [80:0]          ffu_lsu_data;           // From ffu of sparc_ffu.v
   wire                 ffu_lsu_fpop_rq_vld;    // From ffu of sparc_ffu.v
   wire                 ffu_lsu_kill_fst_w;     // From ffu of sparc_ffu.v
   wire                 ffu_tlu_fpu_cmplt;      // From ffu of sparc_ffu.v
   wire [1:0]           ffu_tlu_fpu_tid;        // From ffu of sparc_ffu.v
   wire                 ffu_tlu_ill_inst_m;     // From ffu of sparc_ffu.v
   wire                 ffu_tlu_trap_ieee754;   // From ffu of sparc_ffu.v
   wire                 ffu_tlu_trap_other;     // From ffu of sparc_ffu.v
   wire                 ffu_tlu_trap_ue;        // From ffu of sparc_ffu.v
   wire                 ifu_exu_addr_mask_d;    // From ifu of sparc_ifu.v
   wire [2:0]           ifu_exu_aluop_d;        // From ifu of sparc_ifu.v
   wire                 ifu_exu_casa_d;         // From ifu of sparc_ifu.v
   wire                 ifu_exu_dbrinst_d;      // From ifu of sparc_ifu.v
   wire                 ifu_exu_disable_ce_e;   // From ifu of sparc_ifu.v
   wire                 ifu_exu_dontmv_regz0_e; // From ifu of sparc_ifu.v
   wire                 ifu_exu_dontmv_regz1_e; // From ifu of sparc_ifu.v
   wire [7:0]           ifu_exu_ecc_mask;       // From ifu of sparc_ifu.v
   wire                 ifu_exu_enshift_d;      // From ifu of sparc_ifu.v
   wire                 ifu_exu_flushw_e;       // From ifu of sparc_ifu.v
   wire                 ifu_exu_ialign_d;       // From ifu of sparc_ifu.v
   wire [31:0]          ifu_exu_imm_data_d;     // From ifu of sparc_ifu.v
   wire                 ifu_exu_inj_irferr;     // From ifu of sparc_ifu.v
   wire                 ifu_exu_inst_vld_e;     // From ifu of sparc_ifu.v
   wire                 ifu_exu_inst_vld_w;     // From ifu of sparc_ifu.v
   wire                 ifu_exu_invert_d;       // From ifu of sparc_ifu.v
   wire                 ifu_exu_kill_e;         // From ifu of sparc_ifu.v
   wire [4:0]           ifu_exu_muldivop_d;     // From ifu of sparc_ifu.v
   wire                 ifu_exu_muls_d;         // From ifu of sparc_ifu.v
   wire                 ifu_exu_nceen_e;        // From ifu of sparc_ifu.v
   wire [47:0]          ifu_exu_pc_d;           // From ifu of sparc_ifu.v
   wire [63:0]          ifu_exu_pcver_e;        // From ifu of sparc_ifu.v
   wire                 ifu_exu_range_check_jlret_d;// From ifu of sparc_ifu.v
   wire                 ifu_exu_range_check_other_d;// From ifu of sparc_ifu.v
   wire [4:0]           ifu_exu_rd_d;           // From ifu of sparc_ifu.v
   wire                 ifu_exu_rd_exusr_e;     // From ifu of sparc_ifu.v
   wire                 ifu_exu_rd_ffusr_e;     // From ifu of sparc_ifu.v
   wire                 ifu_exu_rd_ifusr_e;     // From ifu of sparc_ifu.v
   wire                 ifu_exu_ren1_s;         // From ifu of sparc_ifu.v
   wire                 ifu_exu_ren2_s;         // From ifu of sparc_ifu.v
   wire                 ifu_exu_ren3_s;         // From ifu of sparc_ifu.v
   wire                 ifu_exu_restore_d;      // From ifu of sparc_ifu.v
   wire                 ifu_exu_restored_e;     // From ifu of sparc_ifu.v
   wire                 ifu_exu_return_d;       // From ifu of sparc_ifu.v
   wire [4:0]           ifu_exu_rs1_s;          // From ifu of sparc_ifu.v
   wire                 ifu_exu_rs1_vld_d;      // From ifu of sparc_ifu.v
   wire [4:0]           ifu_exu_rs2_s;          // From ifu of sparc_ifu.v
   wire                 ifu_exu_rs2_vld_d;      // From ifu of sparc_ifu.v
   wire [4:0]           ifu_exu_rs3_s;          // From ifu of sparc_ifu.v
   wire                 ifu_exu_rs3e_vld_d;     // From ifu of sparc_ifu.v
   wire                 ifu_exu_rs3o_vld_d;     // From ifu of sparc_ifu.v
   wire                 ifu_exu_save_d;         // From ifu of sparc_ifu.v
   wire                 ifu_exu_saved_e;        // From ifu of sparc_ifu.v
   wire                 ifu_exu_setcc_d;        // From ifu of sparc_ifu.v
   wire                 ifu_exu_sethi_inst_d;   // From ifu of sparc_ifu.v
   wire [2:0]           ifu_exu_shiftop_d;      // From ifu of sparc_ifu.v
   wire                 ifu_exu_tagop_d;        // From ifu of sparc_ifu.v
   wire                 ifu_exu_tcc_e;          // From ifu of sparc_ifu.v
   wire [1:0]           ifu_exu_tid_s2;         // From ifu of sparc_ifu.v
   wire                 ifu_exu_ttype_vld_m;    // From ifu of sparc_ifu.v
   wire                 ifu_exu_tv_d;           // From ifu of sparc_ifu.v
   wire                 ifu_exu_use_rsr_e_l;    // From ifu of sparc_ifu.v
   wire                 ifu_exu_usecin_d;       // From ifu of sparc_ifu.v
   wire                 ifu_exu_useimm_d;       // From ifu of sparc_ifu.v
   wire                 ifu_exu_wen_d;          // From ifu of sparc_ifu.v
   wire [1:0]           ifu_ffu_fcc_num_d;      // From ifu of sparc_ifu.v
   wire                 ifu_ffu_fld_d;          // From ifu of sparc_ifu.v
   wire                 ifu_ffu_fpop1_d;        // From ifu of sparc_ifu.v
   wire                 ifu_ffu_fpop2_d;        // From ifu of sparc_ifu.v
   wire [8:0]           ifu_ffu_fpopcode_d;     // From ifu of sparc_ifu.v
   wire [4:0]           ifu_ffu_frd_d;          // From ifu of sparc_ifu.v
   wire [4:0]           ifu_ffu_frs1_d;         // From ifu of sparc_ifu.v
   wire [4:0]           ifu_ffu_frs2_d;         // From ifu of sparc_ifu.v
   wire                 ifu_ffu_fst_d;          // From ifu of sparc_ifu.v
   wire                 ifu_ffu_inj_frferr;     // From ifu of sparc_ifu.v
   wire                 ifu_ffu_ldfsr_d;        // From ifu of sparc_ifu.v
   wire                 ifu_ffu_ldst_size_d;    // From ifu of sparc_ifu.v
   wire                 ifu_ffu_ldxfsr_d;       // From ifu of sparc_ifu.v
   wire                 ifu_ffu_mvcnd_m;        // From ifu of sparc_ifu.v
   wire                 ifu_ffu_quad_op_e;      // From ifu of sparc_ifu.v
   wire                 ifu_ffu_stfsr_d;        // From ifu of sparc_ifu.v
   wire                 ifu_ffu_visop_d;        // From ifu of sparc_ifu.v
   wire                 ifu_lsu_alt_space_d;    // From ifu of sparc_ifu.v
   wire                 ifu_lsu_alt_space_e;    // From ifu of sparc_ifu.v
   wire                 ifu_lsu_asi_ack;        // From ifu of sparc_ifu.v
   wire                 ifu_lsu_asi_rd_unc;     // From ifu of sparc_ifu.v
   wire                 ifu_lsu_casa_e;         // From ifu of sparc_ifu.v
   wire [2:0]           ifu_lsu_destid_s;       // From ifu of sparc_ifu.v
   wire [3:0]           ifu_lsu_error_inj;      // From ifu of sparc_ifu.v
   wire                 ifu_lsu_fwd_data_vld;   // From ifu of sparc_ifu.v
   wire                 ifu_lsu_fwd_wr_ack;     // From ifu of sparc_ifu.v
   wire                 ifu_lsu_ibuf_busy;      // From ifu of sparc_ifu.v
   wire [7:0]           ifu_lsu_imm_asi_d;      // From ifu of sparc_ifu.v
   wire                 ifu_lsu_imm_asi_vld_d;  // From ifu of sparc_ifu.v
   wire                 ifu_lsu_inv_clear;      // From ifu of sparc_ifu.v
   wire                 ifu_lsu_ld_inst_e;      // From ifu of sparc_ifu.v
   wire                 ifu_lsu_ldst_dbl_e;     // From ifu of sparc_ifu.v
   wire                 ifu_lsu_ldst_fp_e;      // From ifu of sparc_ifu.v
   wire [1:0]           ifu_lsu_ldst_size_e;    // From ifu of sparc_ifu.v
   wire                 ifu_lsu_ldstub_e;       // From ifu of sparc_ifu.v
   wire                 ifu_lsu_ldxa_data_vld_w2;// From ifu of sparc_ifu.v
   wire [63:0]          ifu_lsu_ldxa_data_w2;   // From ifu of sparc_ifu.v
   wire                 ifu_lsu_ldxa_illgl_va_w2;// From ifu of sparc_ifu.v
   wire [1:0]           ifu_lsu_ldxa_tid_w2;    // From ifu of sparc_ifu.v
   wire                 ifu_lsu_memref_d;       // From ifu of sparc_ifu.v
   wire [3:0]           ifu_lsu_nceen;          // From ifu of sparc_ifu.v
   wire [51:0]          ifu_lsu_pcxpkt_e;       // From ifu of sparc_ifu.v
   wire                 ifu_lsu_pcxreq_d;       // From ifu of sparc_ifu.v
   wire                 ifu_lsu_pref_inst_e;    // From ifu of sparc_ifu.v
   wire [4:0]           ifu_lsu_rd_e;           // From ifu of sparc_ifu.v
   wire                 ifu_lsu_sign_ext_e;     // From ifu of sparc_ifu.v
   wire                 ifu_lsu_st_inst_e;      // From ifu of sparc_ifu.v
   wire                 ifu_lsu_swap_e;         // From ifu of sparc_ifu.v
   wire [1:0]           ifu_lsu_thrid_s;        // From ifu of sparc_ifu.v
   wire                 ifu_mmu_trap_m;         // From ifu of sparc_ifu.v
   wire                 ifu_spu_inst_vld_w;     // From ifu of sparc_ifu.v
   wire [3:0]           ifu_spu_nceen;          // From ifu of sparc_ifu.v
   wire                 ifu_spu_trap_ack;       // From ifu of sparc_ifu.v
   wire                 ifu_tlu_alt_space_d;    // From ifu of sparc_ifu.v
   wire                 ifu_tlu_done_inst_d;    // From ifu of sparc_ifu.v
   wire                 ifu_tlu_flsh_inst_e;    // From ifu of sparc_ifu.v
   wire                 ifu_tlu_flush_fd2_w;    // From lsu of lsu.v
   wire                 ifu_tlu_flush_fd3_w;    // From lsu of lsu.v
   wire                 ifu_tlu_flush_fd_w;     // From lsu of lsu.v
   wire                 ifu_tlu_flush_m;        // From ifu of sparc_ifu.v
   wire                 ifu_tlu_flush_w;        // From ifu of sparc_ifu.v
   wire                 ifu_tlu_hwint_m;        // From ifu of sparc_ifu.v
   wire                 ifu_tlu_icmiss_e;       // From ifu of sparc_ifu.v
   wire                 ifu_tlu_immu_miss_m;    // From ifu of sparc_ifu.v
   wire                 ifu_tlu_inst_vld_m;     // From ifu of sparc_ifu.v
   wire                 ifu_tlu_inst_vld_m_bf1; // From lsu of lsu.v
   wire                 ifu_tlu_inst_vld_w;     // From ifu of sparc_ifu.v
   wire                 ifu_tlu_itlb_done;      // From ifu of sparc_ifu.v
   wire [3:0]           ifu_tlu_l2imiss;        // From ifu of sparc_ifu.v
   wire                 ifu_tlu_mb_inst_e;      // From ifu of sparc_ifu.v
   wire [48:0]          ifu_tlu_npc_m;          // From ifu of sparc_ifu.v
   wire [48:0]          ifu_tlu_pc_m;           // From ifu of sparc_ifu.v
   wire                 ifu_tlu_pc_oor_e;       // From ifu of sparc_ifu.v
   wire                 ifu_tlu_priv_violtn_m;  // From ifu of sparc_ifu.v
   wire                 ifu_tlu_retry_inst_d;   // From ifu of sparc_ifu.v
   wire                 ifu_tlu_rsr_inst_d;     // From ifu of sparc_ifu.v
   wire                 ifu_tlu_rstint_m;       // From ifu of sparc_ifu.v
   wire                 ifu_tlu_sftint_m;       // From ifu of sparc_ifu.v
   wire                 ifu_tlu_sir_inst_m;     // From ifu of sparc_ifu.v
   wire [6:0]           ifu_tlu_sraddr_d;       // From ifu of sparc_ifu.v
   wire [6:0]           ifu_tlu_sraddr_d_v2;    // From ifu of sparc_ifu.v
   wire [1:0]           ifu_tlu_thrid_d;        // From ifu of sparc_ifu.v
   wire [1:0]           ifu_tlu_thrid_e;        // From ifu of sparc_ifu.v
   wire                 ifu_tlu_trap_m;         // From ifu of sparc_ifu.v
   wire [8:0]           ifu_tlu_ttype_m;        // From ifu of sparc_ifu.v
   wire                 ifu_tlu_ttype_vld_m;    // From ifu of sparc_ifu.v
   wire [7:0]           lsu_asi_reg0;           // From lsu of lsu.v
   wire [7:0]           lsu_asi_reg1;           // From lsu of lsu.v
   wire [7:0]           lsu_asi_reg2;           // From lsu of lsu.v
   wire [7:0]           lsu_asi_reg3;           // From lsu of lsu.v
   wire [7:0]           lsu_asi_state;          // From lsu of lsu.v
   wire [3:0]           lsu_dmmu_sfsr_trp_wr;   // From lsu of lsu.v
   wire [23:0]          lsu_dsfsr_din_g;        // From lsu of lsu.v
   wire                 lsu_exu_flush_pipe_w;   // From lsu of lsu.v
   wire [63:0]          lsu_exu_ldxa_data_g;    // From tlu of tlu.v
   wire                 lsu_exu_ldxa_m;         // From tlu of tlu.v
   wire [4:0]           lsu_exu_rd_m;           // From lsu of lsu.v
   wire                 lsu_exu_st_dtlb_perr_g; // From lsu of lsu.v
   wire [1:0]           lsu_exu_thr_m;          // From lsu of lsu.v
   wire                 lsu_ffu_ack;            // From lsu of lsu.v
   wire [2:0]           lsu_ffu_bld_cnt_w;      // From lsu of lsu.v
   wire                 lsu_ffu_blk_asi_e;      // From lsu of lsu.v
   wire                 lsu_ffu_flush_pipe_w;   // From lsu of lsu.v
   wire [63:0]          lsu_ffu_ld_data;        // From lsu of lsu.v
   wire                 lsu_ffu_ld_vld;         // From lsu of lsu.v
   wire                 lsu_ffu_stb_full0;      // From lsu of lsu.v
   wire                 lsu_ffu_stb_full1;      // From lsu of lsu.v
   wire                 lsu_ffu_stb_full2;      // From lsu of lsu.v
   wire                 lsu_ffu_stb_full3;      // From lsu of lsu.v
   wire [3:0]           lsu_ictag_mrgn;         // From lsu of lsu.v
   wire [17:0]          lsu_ifu_asi_addr;       // From lsu of lsu.v
   wire                 lsu_ifu_asi_load;       // From lsu of lsu.v
   wire [7:0]           lsu_ifu_asi_state;      // From lsu of lsu.v
   wire [1:0]           lsu_ifu_asi_thrid;      // From lsu of lsu.v
   wire                 lsu_ifu_asi_vld;        // From lsu of lsu.v
   wire [`CPX_VLD-1:0]  lsu_ifu_cpxpkt_i1;      // From lsu of lsu.v
   wire                 lsu_ifu_cpxpkt_vld_i1;  // From lsu of lsu.v
   wire                 lsu_ifu_dc_parity_error_w2;// From lsu of lsu.v
   wire                 lsu_ifu_dcache_data_perror;// From lsu of lsu.v
   wire                 lsu_ifu_dcache_tag_perror;// From lsu of lsu.v
   wire                 lsu_ifu_direct_map_l1;  // From lsu of lsu.v
   wire [47:4]          lsu_ifu_err_addr;       // From lsu of lsu.v
   wire [1:0]           lsu_ifu_error_tid;      // From lsu of lsu.v
   wire                 lsu_ifu_flush_pipe_w;   // From lsu of lsu.v
   wire [3:0]           lsu_ifu_icache_en;      // From lsu of lsu.v
   wire [3:0]           lsu_ifu_inj_ack;        // From tlu of tlu.v
   wire                 lsu_ifu_io_error;       // From lsu of lsu.v
   wire [3:0]           lsu_ifu_itlb_en;        // From lsu of lsu.v
   wire                 lsu_ifu_l2_corr_error;  // From lsu of lsu.v
   wire                 lsu_ifu_l2_unc_error;   // From lsu of lsu.v
   wire [11:5]          lsu_ifu_ld_icache_index;// From lsu of lsu.v
   wire [1:0]           lsu_ifu_ld_pcxpkt_tid;  // From lsu of lsu.v
   wire                 lsu_ifu_ld_pcxpkt_vld;  // From lsu of lsu.v
   wire [3:0]           lsu_ifu_ldst_cmplt;     // From lsu of lsu.v
   wire                 lsu_ifu_ldsta_internal_e;// From lsu of lsu.v
   wire                 lsu_ifu_pcxpkt_ack_d;   // From lsu of lsu.v
   wire                 lsu_ifu_stallreq;       // From lsu of lsu.v
   wire [3:0]           lsu_ifu_stbcnt0;        // From lsu of lsu.v
   wire [3:0]           lsu_ifu_stbcnt1;        // From lsu of lsu.v
   wire [3:0]           lsu_ifu_stbcnt2;        // From lsu of lsu.v
   wire [3:0]           lsu_ifu_stbcnt3;        // From lsu of lsu.v
   wire                 lsu_ifu_tlb_data_su;    // From lsu of lsu.v
   wire [7:0]           lsu_itlb_mrgn;          // From lsu of lsu.v
   wire [3:0]           lsu_mamem_mrgn;         // From lsu of lsu.v
   wire                 lsu_mmu_defr_trp_taken_g;// From lsu of lsu.v
   wire                 lsu_mmu_flush_pipe_w;   // From lsu of lsu.v
   wire [63:0]          lsu_mmu_rs3_data_g;     // From lsu of lsu.v
   wire [2:0]           lsu_pid_state0;         // From lsu of lsu.v
   wire [2:0]           lsu_pid_state1;         // From lsu of lsu.v
   wire [2:0]           lsu_pid_state2;         // From lsu of lsu.v
   wire [2:0]           lsu_pid_state3;         // From lsu of lsu.v
   wire [7:0]           lsu_spu_asi_state_e;    // From lsu of lsu.v
   wire                 lsu_spu_early_flush_g;  // From lsu of lsu.v
   wire                 lsu_spu_ldst_ack;       // From lsu of lsu.v
   wire [3:0]           lsu_spu_stb_empty;      // From lsu of lsu.v
   wire [1:0]           lsu_spu_strm_ack_cmplt; // From lsu of lsu.v
   wire [15:0]          lsu_sscan_data;         // From lsu of lsu.v
   wire [1:0]           lsu_tlu_async_tid_w2;   // From lsu of lsu.v
   wire                 lsu_tlu_async_ttype_vld_w2;// From lsu of lsu.v
   wire [6:0]           lsu_tlu_async_ttype_w2; // From lsu of lsu.v
   wire [3:0]           lsu_tlu_cpx_req;        // From lsu of lsu.v
   wire                 lsu_tlu_cpx_vld;        // From lsu of lsu.v
   wire                 lsu_tlu_daccess_excptn_g;// From lsu of lsu.v
   wire                 lsu_tlu_daccess_prot_g; // From lsu of lsu.v
   wire [3:0]           lsu_tlu_dcache_miss_w2; // From lsu of lsu.v
   wire                 lsu_tlu_defr_trp_taken_g;// From lsu of lsu.v
   wire                 lsu_tlu_dmmu_miss_g;    // From lsu of lsu.v
   wire [12:0]          lsu_tlu_dside_ctxt_m;   // From lsu of lsu.v
   wire                 lsu_tlu_dtlb_done;      // From lsu of lsu.v
   wire                 lsu_tlu_early_flush2_w; // From lsu of lsu.v
   wire                 lsu_tlu_early_flush_w;  // From lsu of lsu.v
   wire [17:0]          lsu_tlu_intpkt;         // From lsu of lsu.v
   wire [3:0]           lsu_tlu_l2_dmiss;       // From lsu of lsu.v
   wire                 lsu_tlu_nucleus_ctxt_m; // From lsu of lsu.v
   wire [12:0]          lsu_tlu_pctxt_m;        // From lsu of lsu.v
   wire                 lsu_tlu_pcxpkt_ack;     // From lsu of lsu.v
   wire                 lsu_tlu_priv_action_g;  // From lsu of lsu.v
   wire [63:0]          lsu_tlu_rs3_data_g;     // From lsu of lsu.v
   wire [7:0]           lsu_tlu_rsr_data_e;     // From lsu of lsu.v
   wire                 lsu_tlu_squash_va_oor_m;// From lsu of lsu.v
   wire [3:0]           lsu_tlu_stb_full_w2;    // From lsu of lsu.v
   wire [1:0]           lsu_tlu_thrid_d;        // From lsu of lsu.v
   wire [1:0]           lsu_tlu_tlb_access_tid_m;// From lsu of lsu.v
   wire [7:0]           lsu_tlu_tlb_asi_state_m;// From lsu of lsu.v
   wire [47:13]         lsu_tlu_tlb_dmp_va_m;   // From lsu of lsu.v
   wire                 lsu_tlu_tlb_ld_inst_m;  // From lsu of lsu.v
   wire [10:0]          lsu_tlu_tlb_ldst_va_m;  // From lsu of lsu.v
   wire                 lsu_tlu_tlb_st_inst_m;  // From lsu of lsu.v
   wire [2:0]           lsu_tlu_tte_pg_sz_g;    // From lsu of lsu.v
   wire [8:0]           lsu_tlu_ttype_m2;       // From lsu of lsu.v
   wire                 lsu_tlu_ttype_vld_m2;   // From lsu of lsu.v
   wire                 lsu_tlu_wsr_inst_e;     // From lsu of lsu.v
   wire                 lsu_tlu_wtchpt_trp_g;   // From lsu of lsu.v
   wire                 mbist_bisi_mode;        // From test_stub of test_stub_bist.v
   wire [71:0]          mbist_dcache_data_in;   // From lsu of lsu.v
   wire                 mbist_dcache_fail;      // From ifu of sparc_ifu.v
   wire [6:0]           mbist_dcache_index;     // From ifu of sparc_ifu.v
   wire                 mbist_dcache_read;      // From ifu of sparc_ifu.v
   wire [1:0]           mbist_dcache_way;       // From ifu of sparc_ifu.v
   wire                 mbist_dcache_word;      // From ifu of sparc_ifu.v
   wire                 mbist_dcache_write;     // From ifu of sparc_ifu.v
   wire                 mbist_done;             // From ifu of sparc_ifu.v
   wire                 mbist_icache_fail;      // From ifu of sparc_ifu.v
   wire                 mbist_loop_mode;        // From test_stub of test_stub_bist.v
   wire                 mbist_loop_on_addr;     // From test_stub of test_stub_bist.v
   wire                 mbist_start;            // From test_stub of test_stub_bist.v
   wire                 mbist_stop_on_fail;     // From test_stub of test_stub_bist.v
   wire                 mbist_stop_on_next_fail;// From test_stub of test_stub_bist.v
   wire                 mbist_userdata_mode;    // From test_stub of test_stub_bist.v
   wire [7:0]           mbist_write_data;       // From ifu of sparc_ifu.v
   wire                 mem_bypass;             // From test_stub of test_stub_bist.v
   wire                 mem_write_disable;      // From test_stub of test_stub_bist.v
   wire [63:0]          mul_data_out;           // From mul of sparc_mul_top.v
   wire                 mul_exu_ack;            // From mul of sparc_mul_top.v
   wire                 mul_spu_ack;            // From mul of sparc_mul_top.v
   wire                 mul_spu_shf_ack;        // From mul of sparc_mul_top.v
   wire                 mux_drive_disable;      // From test_stub of test_stub_bist.v
   wire                 rclk;                   // From spc_hdr of bw_clk_cl_sparc_cmp.v
   wire                 se;                     // From test_stub of test_stub_bist.v
   wire                 sehold;                 // From test_stub of test_stub_bist.v
   wire                 spc_dbginit_l;          // From spc_hdr of bw_clk_cl_sparc_cmp.v
   wire                 spc_grst_l;             // From spc_hdr of bw_clk_cl_sparc_cmp.v
   wire                 spu_ifu_corr_err_w2;    // From spu of spu.v
   wire [39:4]          spu_ifu_err_addr_w2;    // From spu of spu.v
   wire                 spu_ifu_int_w2;         // From spu of spu.v
   wire                 spu_ifu_mamem_err_w1;   // From spu of spu.v
   wire [1:0]           spu_ifu_ttype_tid_w2;   // From spu of spu.v
   wire                 spu_ifu_ttype_vld_w2;   // From spu of spu.v
   wire                 spu_ifu_ttype_w2;       // From spu of spu.v
   wire                 spu_ifu_unc_err_w1;     // From spu of spu.v
   wire [123:0]         spu_lsu_ldst_pckt;      // From spu of spu.v
   wire                 spu_lsu_ldxa_data_vld_w2;// From spu of spu.v
   wire [63:0]          spu_lsu_ldxa_data_w2;   // From spu of spu.v
   wire                 spu_lsu_ldxa_illgl_va_w2;// From spu of spu.v
   wire [1:0]           spu_lsu_ldxa_tid_w2;    // From spu of spu.v
   wire                 spu_lsu_stxa_ack;       // From spu of spu.v
   wire [1:0]           spu_lsu_stxa_ack_tid;   // From spu of spu.v
   wire                 spu_lsu_unc_error_w2;   // From spu of spu.v
   wire                 spu_mul_acc;            // From spu of spu.v
   wire                 spu_mul_areg_rst;       // From spu of spu.v
   wire                 spu_mul_areg_shf;       // From spu of spu.v
   wire                 spu_mul_mulres_lshft;   // From spu of spu.v
   wire [63:0]          spu_mul_op1_data;       // From spu of spu.v
   wire [63:0]          spu_mul_op2_data;       // From spu of spu.v
   wire                 spu_mul_req_vld;        // From spu of spu.v
   wire                 testmode_l;             // From test_stub of test_stub_bist.v
   wire                 tlu_dtlb_data_rd_g;     // From tlu of tlu.v
   wire                 tlu_dtlb_dmp_actxt_g;   // From tlu of tlu.v
   wire                 tlu_dtlb_dmp_all_g;     // From tlu of tlu.v
   wire                 tlu_dtlb_dmp_nctxt_g;   // From tlu of tlu.v
   wire                 tlu_dtlb_dmp_pctxt_g;   // From tlu of tlu.v
   wire                 tlu_dtlb_dmp_sctxt_g;   // From tlu of tlu.v
   wire                 tlu_dtlb_dmp_vld_g;     // From tlu of tlu.v
   wire                 tlu_dtlb_invalidate_all_g;// From tlu of tlu.v
   wire [5:0]           tlu_dtlb_rw_index_g;    // From tlu of tlu.v
   wire                 tlu_dtlb_rw_index_vld_g;// From tlu of tlu.v
   wire                 tlu_dtlb_tag_rd_g;      // From tlu of tlu.v
   wire [42:0]          tlu_dtlb_tte_data_w2;   // From tlu of tlu.v
   wire [58:0]          tlu_dtlb_tte_tag_w2;    // From tlu of tlu.v
   wire                 tlu_early_flush_pipe2_w;// From tlu of tlu.v
   wire                 tlu_early_flush_pipe_w; // From tlu of tlu.v
   wire [`TSA_GLOBAL_WIDTH-1:0]tlu_exu_agp;     // From tlu of tlu.v
   wire                 tlu_exu_agp_swap;       // From tlu of tlu.v
   wire [1:0]           tlu_exu_agp_tid;        // From tlu of tlu.v
   wire [7:0]           tlu_exu_ccr_m;          // From tlu of tlu.v
   wire [2:0]           tlu_exu_cwp_m;          // From tlu of tlu.v
   wire                 tlu_exu_cwp_retry_m;    // From tlu of tlu.v
   wire                 tlu_exu_cwpccr_update_m;// From tlu of tlu.v
   wire                 tlu_exu_early_flush_pipe_w;// From tlu of tlu.v
   wire                 tlu_exu_pic_onebelow_m; // From tlu of tlu.v
   wire                 tlu_exu_pic_twobelow_m; // From tlu of tlu.v
   wire                 tlu_exu_priv_trap_m;    // From tlu of tlu.v
   wire [`TLU_ASR_DATA_WIDTH-1:0]tlu_exu_rsr_data_m;// From tlu of tlu.v
   wire [40:0]          tlu_idtlb_dmp_key_g;    // From tlu of tlu.v
   wire [1:0]           tlu_idtlb_dmp_thrid_g;  // From tlu of tlu.v
   wire [3:0]           tlu_ifu_hwint_i3;       // From tlu of tlu.v
   wire                 tlu_ifu_nukeint_i2;     // From tlu of tlu.v
   wire [3:0]           tlu_ifu_pstate_ie;      // From tlu of tlu.v
   wire [3:0]           tlu_ifu_pstate_pef;     // From tlu of tlu.v
   wire                 tlu_ifu_resumint_i2;    // From tlu of tlu.v
   wire                 tlu_ifu_rstint_i2;      // From tlu of tlu.v
   wire [3:0]           tlu_ifu_rstthr_i2;      // From tlu of tlu.v
   wire [1:0]           tlu_ifu_trap_tid_w1;    // From tlu of tlu.v
   wire                 tlu_ifu_trapnpc_vld_w1; // From tlu of tlu.v
   wire [48:0]          tlu_ifu_trapnpc_w2;     // From tlu of tlu.v
   wire                 tlu_ifu_trappc_vld_w1;  // From tlu of tlu.v
   wire [48:0]          tlu_ifu_trappc_w2;      // From tlu of tlu.v
   wire                 tlu_itlb_data_rd_g;     // From tlu of tlu.v
   wire                 tlu_itlb_dmp_actxt_g;   // From tlu of tlu.v
   wire                 tlu_itlb_dmp_all_g;     // From tlu of tlu.v
   wire                 tlu_itlb_dmp_nctxt_g;   // From tlu of tlu.v
   wire                 tlu_itlb_dmp_vld_g;     // From tlu of tlu.v
   wire                 tlu_itlb_invalidate_all_g;// From tlu of tlu.v
   wire [5:0]           tlu_itlb_rw_index_g;    // From tlu of tlu.v
   wire                 tlu_itlb_rw_index_vld_g;// From tlu of tlu.v
   wire                 tlu_itlb_tag_rd_g;      // From tlu of tlu.v
   wire [42:0]          tlu_itlb_tte_data_w2;   // From tlu of tlu.v
   wire [58:0]          tlu_itlb_tte_tag_w2;    // From tlu of tlu.v
   wire                 tlu_itlb_wr_vld_g;      // From tlu of tlu.v
   wire [7:0]           tlu_lsu_asi_m;          // From tlu of tlu.v
   wire                 tlu_lsu_asi_update_m;   // From tlu of tlu.v
   wire [63:0]          tlu_lsu_int_ldxa_data_w2;// From tlu of tlu.v
   wire                 tlu_lsu_int_ldxa_vld_w2;// From tlu of tlu.v
   wire                 tlu_lsu_ldxa_async_data_vld;// From tlu of tlu.v
   wire [1:0]           tlu_lsu_ldxa_tid_w2;    // From tlu of tlu.v
   wire [25:0]          tlu_lsu_pcxpkt;         // From tlu of tlu.v
   wire                 tlu_lsu_priv_trap_m;    // From tlu of tlu.v
   wire [3:0]           tlu_lsu_pstate_am;      // From tlu of tlu.v
   wire [3:0]           tlu_lsu_pstate_cle;     // From tlu of tlu.v
   wire [3:0]           tlu_lsu_pstate_priv;    // From tlu of tlu.v
   wire [3:0]           tlu_lsu_redmode;        // From tlu of tlu.v
   wire [3:0]           tlu_lsu_redmode_rst_d1; // From tlu of tlu.v
   wire                 tlu_lsu_stxa_ack;       // From tlu of tlu.v
   wire [1:0]           tlu_lsu_stxa_ack_tid;   // From tlu of tlu.v
   wire [1:0]           tlu_lsu_tid_m;          // From tlu of tlu.v
   wire [`TLU_THRD_NUM-1:0]tlu_lsu_tl_zero;     // From tlu of tlu.v
   // End of automatics

   wire                 cpx_spc_data_cx3_b0;    // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b100;  // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b103;  // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b106;  // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b109;  // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b12;   // From ff_cpx of cpx_spc_rpt.v
   wire [`CPX_INV_CID_HI:`CPX_INV_CID_LO]cpx_spc_data_cx3_b120to118;// From ff_cpx of cpx_spc_rpt.v
   wire [`CPX_WIDTH-1:140]cpx_spc_data_cx3_b144to140;// From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b16;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b20;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b24;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b28;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b32;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b35;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b38;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b4;    // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b41;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b44;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b47;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b50;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b53;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b56;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b60;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b64;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b68;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b72;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b76;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b8;    // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b80;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b84;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b88;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b91;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b94;   // From ff_cpx of cpx_spc_rpt.v
   wire                 cpx_spc_data_cx3_b97;   // From ff_cpx of cpx_spc_rpt.v
   wire			lsu_ffu_st_dtlb_perr_g;
   wire			spu_tlu_rsrv_illgl_m;



   cpx_spc_buf buf_cpx (/*AUTOINST*/
                        // Outputs
                        .cpx_spc_data_cx2_buf(cpx_spc_data_cx2_buf[`CPX_WIDTH-1:0]),
                        .cpx_spc_data_rdy_cx2_buf(cpx_spc_data_rdy_cx2_buf),
                        // Inputs
                        .cpx_spc_data_cx2(cpx_spc_data_cx2[`CPX_WIDTH-1:0]),
                        .cpx_spc_data_rdy_cx2(cpx_spc_data_rdy_cx2));

/*   cpx_spc_rpt AUTO_TEMPLATE  (
                       .cpx_spc_data_cx2(cpx_spc_data_cx2_buf[`CPX_WIDTH-1:0]),
                       .cpx_spc_data_rdy_cx2(cpx_spc_data_rdy_cx2_buf),
                        .si             (short_scan0_6),
                        .so             (scan0_1));
*/

   cpx_spc_rpt ff_cpx  (
                         .cpx_spc_data_cx3_b144to140(cpx_spc_data_cx3_b144to140[`CPX_WIDTH-1:140]),
                         .cpx_spc_data_cx3_b120to118(cpx_spc_data_cx3_b120to118[`CPX_INV_CID_HI:`CPX_INV_CID_LO]),
                         .cpx_spc_data_cx3_b0(cpx_spc_data_cx3_b0),
                         .cpx_spc_data_cx3_b4(cpx_spc_data_cx3_b4),
                         .cpx_spc_data_cx3_b8(cpx_spc_data_cx3_b8),
                         .cpx_spc_data_cx3_b12(cpx_spc_data_cx3_b12),
                         .cpx_spc_data_cx3_b16(cpx_spc_data_cx3_b16),
                         .cpx_spc_data_cx3_b20(cpx_spc_data_cx3_b20),
                         .cpx_spc_data_cx3_b24(cpx_spc_data_cx3_b24),
                         .cpx_spc_data_cx3_b28(cpx_spc_data_cx3_b28),
                         .cpx_spc_data_cx3_b32(cpx_spc_data_cx3_b32),
                         .cpx_spc_data_cx3_b35(cpx_spc_data_cx3_b35),
                         .cpx_spc_data_cx3_b38(cpx_spc_data_cx3_b38),
                         .cpx_spc_data_cx3_b41(cpx_spc_data_cx3_b41),
                         .cpx_spc_data_cx3_b44(cpx_spc_data_cx3_b44),
                         .cpx_spc_data_cx3_b47(cpx_spc_data_cx3_b47),
                         .cpx_spc_data_cx3_b50(cpx_spc_data_cx3_b50),
                         .cpx_spc_data_cx3_b53(cpx_spc_data_cx3_b53),
                         .cpx_spc_data_cx3_b56(cpx_spc_data_cx3_b56),
                         .cpx_spc_data_cx3_b60(cpx_spc_data_cx3_b60),
                         .cpx_spc_data_cx3_b64(cpx_spc_data_cx3_b64),
                         .cpx_spc_data_cx3_b68(cpx_spc_data_cx3_b68),
                         .cpx_spc_data_cx3_b72(cpx_spc_data_cx3_b72),
                         .cpx_spc_data_cx3_b76(cpx_spc_data_cx3_b76),
                         .cpx_spc_data_cx3_b80(cpx_spc_data_cx3_b80),
                         .cpx_spc_data_cx3_b84(cpx_spc_data_cx3_b84),
                         .cpx_spc_data_cx3_b88(cpx_spc_data_cx3_b88),
                         .cpx_spc_data_cx3_b91(cpx_spc_data_cx3_b91),
                         .cpx_spc_data_cx3_b94(cpx_spc_data_cx3_b94),
                         .cpx_spc_data_cx3_b97(cpx_spc_data_cx3_b97),
                         .cpx_spc_data_cx3_b100(cpx_spc_data_cx3_b100),
                         .cpx_spc_data_cx3_b103(cpx_spc_data_cx3_b103),
                         .cpx_spc_data_cx3_b106(cpx_spc_data_cx3_b106),
                         .cpx_spc_data_cx3_b109(cpx_spc_data_cx3_b109),

                         /*AUTOINST*/
                        // Outputs
                        .so             (scan0_1),               // Templated
                        .cpx_spc_data_cx3(cpx_spc_data_cx3[`CPX_WIDTH-1:0]),
                        .cpx_spc_data_rdy_cx3(cpx_spc_data_rdy_cx3),
                        // Inputs
                        .rclk           (rclk),
                        .si             (short_scan0_6),         // Templated
                        .se             (se),
                        .cpx_spc_data_cx2(cpx_spc_data_cx2_buf[`CPX_WIDTH-1:0]), // Templated
                        .cpx_spc_data_rdy_cx2(cpx_spc_data_rdy_cx2_buf)); // Templated

`ifdef FPGA_SYN_NO_SPU

      sparc_ifu ifu(
                 // scan
                 .short_si0              (spc_scanin0),
                 .short_si1              (spc_scanin1),
                 .short_so0              (short_scan0_1),
                 .short_so1              (short_scan1_1),
                 .si0                    (scan0_1),
                 .so0                    (scan0_2),
                 // reset stuff and clk 
                 .grst_l                 (spc_grst_l),
                 .arst_l                 (cmp_arst_l),
                 .gdbginit_l             (spc_dbginit_l),
                 
                 // quad ldst disabled
                 .lsu_ifu_quad_asi_e    (1'b0),

                 // tlb on condition changes with hypervisor
                 // itlb_en is the bit from the lsu control register
                 // with no additional logic
                 .lsu_ifu_addr_real_l  (lsu_ifu_itlb_en[3:0]),
                 
                 // name change
		             .lsu_ifu_dtlb_data_ue	(lsu_ifu_tlb_data_ue),
		             .lsu_ifu_dtlb_tag_ue	(lsu_ifu_tlb_tag_ue),
                 .lsu_ifu_dtlb_data_su  (lsu_ifu_tlb_data_su),

	               .tlu_ifu_hintp_vld	    (tlu_hintp_vld[3:0]),
	               .tlu_ifu_rerr_vld	    (tlu_rerr_vld[3:0]),

		             .lsu_ifu_t0_tlz    	(tlu_lsu_tl_zero[0]),
		             .lsu_ifu_t1_tlz    	(tlu_lsu_tl_zero[1]),
		             .lsu_ifu_t2_tlz	    (tlu_lsu_tl_zero[2]),
		             .lsu_ifu_t3_tlz	    (tlu_lsu_tl_zero[3]),
                 
                 .lsu_ifu_ldst_miss_g   (lsu_ifu_ldst_miss_w),
                 .tlu_ifu_flush_pipe_w  (lsu_ifu_flush_pipe_w),

                 .lsu_idtlb_mrgn        (lsu_itlb_mrgn[7:0]),

                 .mbist_loop_on_address (mbist_loop_on_addr),
                 
                 .tlu_sscan_data        (tlu_sscan_test_data[62:0]),
                 .sparc_sscan_so        (spc_sscan_so),
                 .ifu_tlu_imm_asi_d     (ifu_tlu_imm_asi_d[8:0]),

                 // bus width difference
                 .lsu_ifu_cpxpkt_i1     ({lsu_ifu_cpxpkt_vld_i1,
                                          lsu_ifu_cpxpkt_i1[`CPX_VLD-1:0]}),
                 
		             /*AUTOINST*/
                 // Outputs
                 .ifu_exu_addr_mask_d   (ifu_exu_addr_mask_d),
                 .ifu_tlu_inst_vld_w    (ifu_tlu_inst_vld_w),
                 .ifu_tlu_flush_w       (ifu_tlu_flush_w),
                 .ifu_lsu_alt_space_e   (ifu_lsu_alt_space_e),
                 .ifu_tlu_ttype_vld_m   (ifu_tlu_ttype_vld_m),
                 .ifu_exu_muldivop_d    (ifu_exu_muldivop_d[4:0]),
                 .ifu_lsu_thrid_s       (ifu_lsu_thrid_s[1:0]),
                 .mbist_write_data      (mbist_write_data[7:0]),
                 .ifu_exu_aluop_d       (ifu_exu_aluop_d[2:0]),
                 .ifu_exu_casa_d        (ifu_exu_casa_d),
                 .ifu_exu_dbrinst_d     (ifu_exu_dbrinst_d),
                 .ifu_exu_disable_ce_e  (ifu_exu_disable_ce_e),
                 .ifu_exu_dontmv_regz0_e(ifu_exu_dontmv_regz0_e),
                 .ifu_exu_dontmv_regz1_e(ifu_exu_dontmv_regz1_e),
                 .ifu_exu_ecc_mask      (ifu_exu_ecc_mask[7:0]),
                 .ifu_exu_enshift_d     (ifu_exu_enshift_d),
                 .ifu_exu_flushw_e      (ifu_exu_flushw_e),
                 .ifu_exu_ialign_d      (ifu_exu_ialign_d),
                 .ifu_exu_imm_data_d    (ifu_exu_imm_data_d[31:0]),
                 .ifu_exu_inj_irferr    (ifu_exu_inj_irferr),
                 .ifu_exu_inst_vld_e    (ifu_exu_inst_vld_e),
                 .ifu_exu_inst_vld_w    (ifu_exu_inst_vld_w),
                 .ifu_exu_invert_d      (ifu_exu_invert_d),
                 .ifu_exu_kill_e        (ifu_exu_kill_e),
                 .ifu_exu_muls_d        (ifu_exu_muls_d),
                 .ifu_exu_nceen_e       (ifu_exu_nceen_e),
                 .ifu_exu_pc_d          (ifu_exu_pc_d[47:0]),
                 .ifu_exu_pcver_e       (ifu_exu_pcver_e[63:0]),
                 .ifu_exu_range_check_jlret_d(ifu_exu_range_check_jlret_d),
                 .ifu_exu_range_check_other_d(ifu_exu_range_check_other_d),
                 .ifu_exu_rd_d          (ifu_exu_rd_d[4:0]),
                 .ifu_exu_rd_exusr_e    (ifu_exu_rd_exusr_e),
                 .ifu_exu_rd_ffusr_e    (ifu_exu_rd_ffusr_e),
                 .ifu_exu_rd_ifusr_e    (ifu_exu_rd_ifusr_e),
                 .ifu_exu_ren1_s        (ifu_exu_ren1_s),
                 .ifu_exu_ren2_s        (ifu_exu_ren2_s),
                 .ifu_exu_ren3_s        (ifu_exu_ren3_s),
                 .ifu_exu_restore_d     (ifu_exu_restore_d),
                 .ifu_exu_restored_e    (ifu_exu_restored_e),
                 .ifu_exu_return_d      (ifu_exu_return_d),
                 .ifu_exu_rs1_s         (ifu_exu_rs1_s[4:0]),
                 .ifu_exu_rs1_vld_d     (ifu_exu_rs1_vld_d),
                 .ifu_exu_rs2_s         (ifu_exu_rs2_s[4:0]),
                 .ifu_exu_rs2_vld_d     (ifu_exu_rs2_vld_d),
                 .ifu_exu_rs3_s         (ifu_exu_rs3_s[4:0]),
                 .ifu_exu_rs3e_vld_d    (ifu_exu_rs3e_vld_d),
                 .ifu_exu_rs3o_vld_d    (ifu_exu_rs3o_vld_d),
                 .ifu_exu_save_d        (ifu_exu_save_d),
                 .ifu_exu_saved_e       (ifu_exu_saved_e),
                 .ifu_exu_setcc_d       (ifu_exu_setcc_d),
                 .ifu_exu_sethi_inst_d  (ifu_exu_sethi_inst_d),
                 .ifu_exu_shiftop_d     (ifu_exu_shiftop_d[2:0]),
                 .ifu_exu_tagop_d       (ifu_exu_tagop_d),
                 .ifu_exu_tcc_e         (ifu_exu_tcc_e),
                 .ifu_exu_tid_s2        (ifu_exu_tid_s2[1:0]),
                 .ifu_exu_ttype_vld_m   (ifu_exu_ttype_vld_m),
                 .ifu_exu_tv_d          (ifu_exu_tv_d),
                 .ifu_exu_use_rsr_e_l   (ifu_exu_use_rsr_e_l),
                 .ifu_exu_usecin_d      (ifu_exu_usecin_d),
                 .ifu_exu_useimm_d      (ifu_exu_useimm_d),
                 .ifu_exu_wen_d         (ifu_exu_wen_d),
                 .ifu_exu_wsr_inst_d    (ifu_exu_wsr_inst_d),
                 .ifu_ffu_fcc_num_d     (ifu_ffu_fcc_num_d[1:0]),
                 .ifu_ffu_fld_d         (ifu_ffu_fld_d),
                 .ifu_ffu_fpop1_d       (ifu_ffu_fpop1_d),
                 .ifu_ffu_fpop2_d       (ifu_ffu_fpop2_d),
                 .ifu_ffu_fpopcode_d    (ifu_ffu_fpopcode_d[8:0]),
                 .ifu_ffu_frd_d         (ifu_ffu_frd_d[4:0]),
                 .ifu_ffu_frs1_d        (ifu_ffu_frs1_d[4:0]),
                 .ifu_ffu_frs2_d        (ifu_ffu_frs2_d[4:0]),
                 .ifu_ffu_fst_d         (ifu_ffu_fst_d),
                 .ifu_ffu_inj_frferr    (ifu_ffu_inj_frferr),
                 .ifu_ffu_ldfsr_d       (ifu_ffu_ldfsr_d),
                 .ifu_ffu_ldst_size_d   (ifu_ffu_ldst_size_d),
                 .ifu_ffu_ldxfsr_d      (ifu_ffu_ldxfsr_d),
                 .ifu_ffu_mvcnd_m       (ifu_ffu_mvcnd_m),
                 .ifu_ffu_quad_op_e     (ifu_ffu_quad_op_e),
                 .ifu_ffu_stfsr_d       (ifu_ffu_stfsr_d),
                 .ifu_ffu_visop_d       (ifu_ffu_visop_d),
                 .ifu_lsu_alt_space_d   (ifu_lsu_alt_space_d),
                 .ifu_lsu_asi_ack       (ifu_lsu_asi_ack),
                 .ifu_lsu_asi_rd_unc    (ifu_lsu_asi_rd_unc),
                 .ifu_lsu_casa_e        (ifu_lsu_casa_e),
                 .ifu_lsu_destid_s      (ifu_lsu_destid_s[2:0]),
                 .ifu_lsu_error_inj     (ifu_lsu_error_inj[3:0]),
                 .ifu_lsu_fwd_data_vld  (ifu_lsu_fwd_data_vld),
                 .ifu_lsu_fwd_wr_ack    (ifu_lsu_fwd_wr_ack),
                 .ifu_lsu_ibuf_busy     (ifu_lsu_ibuf_busy),
                 .ifu_lsu_imm_asi_d     (ifu_lsu_imm_asi_d[7:0]),
                 .ifu_lsu_imm_asi_vld_d (ifu_lsu_imm_asi_vld_d),
                 .ifu_lsu_inv_clear     (ifu_lsu_inv_clear),
                 .ifu_lsu_ld_inst_e     (ifu_lsu_ld_inst_e),
                 .ifu_lsu_ldst_dbl_e    (ifu_lsu_ldst_dbl_e),
                 .ifu_lsu_ldst_fp_e     (ifu_lsu_ldst_fp_e),
                 .ifu_lsu_ldst_size_e   (ifu_lsu_ldst_size_e[1:0]),
                 .ifu_lsu_ldstub_e      (ifu_lsu_ldstub_e),
                 .ifu_lsu_ldxa_data_vld_w2(ifu_lsu_ldxa_data_vld_w2),
                 .ifu_lsu_ldxa_data_w2  (ifu_lsu_ldxa_data_w2[63:0]),
                 .ifu_lsu_ldxa_illgl_va_w2(ifu_lsu_ldxa_illgl_va_w2),
                 .ifu_lsu_ldxa_tid_w2   (ifu_lsu_ldxa_tid_w2[1:0]),
                 .ifu_lsu_memref_d      (ifu_lsu_memref_d),
                 .ifu_lsu_nceen         (ifu_lsu_nceen[3:0]),
                 .ifu_lsu_pcxpkt_e      (ifu_lsu_pcxpkt_e[51:0]),
                 .ifu_lsu_pcxreq_d      (ifu_lsu_pcxreq_d),
                 .ifu_lsu_pref_inst_e   (ifu_lsu_pref_inst_e),
                 .ifu_lsu_rd_e          (ifu_lsu_rd_e[4:0]),
                 .ifu_lsu_sign_ext_e    (ifu_lsu_sign_ext_e),
                 .ifu_lsu_st_inst_e     (ifu_lsu_st_inst_e),
                 .ifu_lsu_swap_e        (ifu_lsu_swap_e),
                 .ifu_lsu_wsr_inst_d    (ifu_lsu_wsr_inst_d),
                 .ifu_mmu_trap_m        (ifu_mmu_trap_m),
                 .ifu_spu_inst_vld_w    (),
                 .ifu_spu_nceen         (),
                 .ifu_spu_trap_ack      (),
                 .ifu_tlu_alt_space_d   (ifu_tlu_alt_space_d),
                 .ifu_tlu_done_inst_d   (ifu_tlu_done_inst_d),
                 .ifu_tlu_flsh_inst_e   (ifu_tlu_flsh_inst_e),
                 .ifu_tlu_flush_m       (ifu_tlu_flush_m),
                 .ifu_tlu_hwint_m       (ifu_tlu_hwint_m),
                 .ifu_tlu_icmiss_e      (ifu_tlu_icmiss_e),
                 .ifu_tlu_immu_miss_m   (ifu_tlu_immu_miss_m),
                 .ifu_tlu_inst_vld_m    (ifu_tlu_inst_vld_m),
                 .ifu_tlu_itlb_done     (ifu_tlu_itlb_done),
                 .ifu_tlu_l2imiss       (ifu_tlu_l2imiss[3:0]),
                 .ifu_tlu_mb_inst_e     (ifu_tlu_mb_inst_e),
                 .ifu_tlu_npc_m         (ifu_tlu_npc_m[48:0]),
                 .ifu_tlu_pc_m          (ifu_tlu_pc_m[48:0]),
                 .ifu_tlu_pc_oor_e      (ifu_tlu_pc_oor_e),
                 .ifu_tlu_priv_violtn_m (ifu_tlu_priv_violtn_m),
                 .ifu_tlu_retry_inst_d  (ifu_tlu_retry_inst_d),
                 .ifu_tlu_rsr_inst_d    (ifu_tlu_rsr_inst_d),
                 .ifu_tlu_rstint_m      (ifu_tlu_rstint_m),
                 .ifu_tlu_sftint_m      (ifu_tlu_sftint_m),
                 .ifu_tlu_sir_inst_m    (ifu_tlu_sir_inst_m),
                 .ifu_tlu_sraddr_d      (ifu_tlu_sraddr_d[6:0]),
                 .ifu_tlu_sraddr_d_v2   (ifu_tlu_sraddr_d_v2[6:0]),
                 .ifu_tlu_thrid_d       (ifu_tlu_thrid_d[1:0]),
                 .ifu_tlu_thrid_e       (ifu_tlu_thrid_e[1:0]),
                 .ifu_tlu_trap_m        (ifu_tlu_trap_m),
                 .ifu_tlu_ttype_m       (ifu_tlu_ttype_m[8:0]),
                 .mbist_dcache_fail     (mbist_dcache_fail),
                 .mbist_dcache_index    (mbist_dcache_index[6:0]),
                 .mbist_dcache_read     (mbist_dcache_read),
                 .mbist_dcache_way      (mbist_dcache_way[1:0]),
                 .mbist_dcache_word     (mbist_dcache_word),
                 .mbist_dcache_write    (mbist_dcache_write),
                 .mbist_done            (mbist_done),
                 .mbist_icache_fail     (mbist_icache_fail),
                 .spc_efc_ifuse_data    (spc_efc_ifuse_data),
                 // Inputs
                 .mem_write_disable     (mem_write_disable),
                 .mux_drive_disable     (mux_drive_disable),
                 .exu_tlu_wsr_data_m    (exu_tlu_wsr_data_m[2:0]),
                 .lsu_ictag_mrgn        (lsu_ictag_mrgn[3:0]),
                 .tlu_itlb_tte_tag_w2   (tlu_itlb_tte_tag_w2[58:0]),
                 .tlu_itlb_tte_data_w2  (tlu_itlb_tte_data_w2[42:0]),
                 .tlu_itlb_rw_index_vld_g(tlu_itlb_rw_index_vld_g),
                 .tlu_itlb_rw_index_g   (tlu_itlb_rw_index_g[5:0]),
                 .tlu_idtlb_dmp_key_g   (tlu_idtlb_dmp_key_g[40:0]),
                 .tlu_itlb_dmp_all_g    (tlu_itlb_dmp_all_g),
                 .lsu_sscan_data        (lsu_sscan_data[15:0]),
                 .const_cpuid           (const_cpuid[3:0]),
                 .const_maskid          (const_maskid[7:0]),
                 .ctu_sscan_se          (ctu_sscan_se),
                 .ctu_sscan_snap        (ctu_sscan_snap),
                 .ctu_sscan_tid         (ctu_sscan_tid[3:0]),
                 .ctu_tck               (ctu_tck),
                 .efc_spc_fuse_clk1     (efc_spc_fuse_clk1),
                 .efc_spc_fuse_clk2     (efc_spc_fuse_clk2),
                 .efc_spc_ifuse_ashift  (efc_spc_ifuse_ashift),
                 .efc_spc_ifuse_data    (efc_spc_ifuse_data),
                 .efc_spc_ifuse_dshift  (efc_spc_ifuse_dshift),
                 .exu_ifu_brpc_e        (exu_ifu_brpc_e[47:0]),
                 .exu_ifu_cc_d          (exu_ifu_cc_d[7:0]),
                 .exu_ifu_ecc_ce_m      (exu_ifu_ecc_ce_m),
                 .exu_ifu_ecc_ue_m      (exu_ifu_ecc_ue_m),
                 .exu_ifu_err_reg_m     (exu_ifu_err_reg_m[7:0]),
                 .exu_ifu_err_synd_m    (exu_ifu_err_synd_m[7:0]),
                 .exu_ifu_inj_ack       (exu_ifu_inj_ack),
                 .exu_ifu_longop_done_g (exu_ifu_longop_done_g[3:0]),
                 .exu_ifu_oddwin_s      (exu_ifu_oddwin_s[3:0]),
                 .exu_ifu_regn_e        (exu_ifu_regn_e),
                 .exu_ifu_regz_e        (exu_ifu_regz_e),
                 .exu_ifu_spill_e       (exu_ifu_spill_e),
                 .exu_ifu_va_oor_m      (exu_ifu_va_oor_m),
                 .ffu_ifu_cc_vld_w2     (ffu_ifu_cc_vld_w2[3:0]),
                 .ffu_ifu_cc_w2         (ffu_ifu_cc_w2[7:0]),
                 .ffu_ifu_ecc_ce_w2     (ffu_ifu_ecc_ce_w2),
                 .ffu_ifu_ecc_ue_w2     (ffu_ifu_ecc_ue_w2),
                 .ffu_ifu_err_reg_w2    (ffu_ifu_err_reg_w2[5:0]),
                 .ffu_ifu_err_synd_w2   (ffu_ifu_err_synd_w2[13:0]),
                 .ffu_ifu_fpop_done_w2  (ffu_ifu_fpop_done_w2),
                 .ffu_ifu_fst_ce_w      (ffu_ifu_fst_ce_w),
                 .ffu_ifu_inj_ack       (ffu_ifu_inj_ack),
                 .ffu_ifu_stallreq      (ffu_ifu_stallreq),
                 .ffu_ifu_tid_w2        (ffu_ifu_tid_w2[1:0]),
                 .lsu_ifu_asi_addr      (lsu_ifu_asi_addr[17:0]),
                 .lsu_ifu_asi_load      (lsu_ifu_asi_load),
                 .lsu_ifu_asi_state     (lsu_ifu_asi_state[7:0]),
                 .lsu_ifu_asi_thrid     (lsu_ifu_asi_thrid[1:0]),
                 .lsu_ifu_asi_vld       (lsu_ifu_asi_vld),
                 .lsu_ifu_dc_parity_error_w2(lsu_ifu_dc_parity_error_w2),
                 .lsu_ifu_dcache_data_perror(lsu_ifu_dcache_data_perror),
                 .lsu_ifu_dcache_tag_perror(lsu_ifu_dcache_tag_perror),
                 .lsu_ifu_direct_map_l1 (lsu_ifu_direct_map_l1),
                 .lsu_ifu_err_addr      (lsu_ifu_err_addr[47:4]),
                 .lsu_ifu_error_tid     (lsu_ifu_error_tid[1:0]),
                 .lsu_ifu_icache_en     (lsu_ifu_icache_en[3:0]),
                 .lsu_ifu_inj_ack       (lsu_ifu_inj_ack[3:0]),
                 .lsu_ifu_io_error      (lsu_ifu_io_error),
                 .lsu_ifu_l2_corr_error (lsu_ifu_l2_corr_error),
                 .lsu_ifu_l2_unc_error  (lsu_ifu_l2_unc_error),
                 .lsu_ifu_ld_icache_index(lsu_ifu_ld_icache_index[`IC_IDX_HI:5]),
                 .lsu_ifu_ld_pcxpkt_tid (lsu_ifu_ld_pcxpkt_tid[1:0]),
                 .lsu_ifu_ld_pcxpkt_vld (lsu_ifu_ld_pcxpkt_vld),
                 .lsu_ifu_ldst_cmplt    (lsu_ifu_ldst_cmplt[3:0]),
                 .lsu_ifu_ldsta_internal_e(lsu_ifu_ldsta_internal_e),
                 .lsu_ifu_pcxpkt_ack_d  (lsu_ifu_pcxpkt_ack_d),
                 .lsu_ifu_stallreq      (lsu_ifu_stallreq),
                 .lsu_ifu_stbcnt0       (lsu_ifu_stbcnt0[3:0]),
                 .lsu_ifu_stbcnt1       (lsu_ifu_stbcnt1[3:0]),
                 .lsu_ifu_stbcnt2       (lsu_ifu_stbcnt2[3:0]),
                 .lsu_ifu_stbcnt3       (lsu_ifu_stbcnt3[3:0]),
                 .lsu_ifu_stxa_data     (lsu_ifu_stxa_data[47:0]),
                 .lsu_pid_state0        (lsu_pid_state0[2:0]),
                 .lsu_pid_state1        (lsu_pid_state1[2:0]),
                 .lsu_pid_state2        (lsu_pid_state2[2:0]),
                 .lsu_pid_state3        (lsu_pid_state3[2:0]),
                 .lsu_t0_pctxt_state    (lsu_t0_pctxt_state[12:0]),
                 .lsu_t1_pctxt_state    (lsu_t1_pctxt_state[12:0]),
                 .lsu_t2_pctxt_state    (lsu_t2_pctxt_state[12:0]),
                 .lsu_t3_pctxt_state    (lsu_t3_pctxt_state[12:0]),
                 .mbist_bisi_mode       (mbist_bisi_mode),
                 .mbist_dcache_data_in  (mbist_dcache_data_in[71:0]),
                 .mbist_loop_mode       (mbist_loop_mode),
                 .mbist_start           (mbist_start),
                 .mbist_stop_on_fail    (mbist_stop_on_fail),
                 .mbist_stop_on_next_fail(mbist_stop_on_next_fail),
                 .mbist_userdata_mode   (mbist_userdata_mode),
                 .rclk                  (rclk),
                 .se                    (se),
                 .sehold                (sehold),
                 .spu_ifu_corr_err_w2   (1'b0),
                 .spu_ifu_err_addr_w2   (36'h000000000),
                 .spu_ifu_int_w2        (1'b0),
                 .spu_ifu_mamem_err_w1  (1'b0),
                 .spu_ifu_ttype_tid_w2  (2'b00),
                 .spu_ifu_ttype_vld_w2  (1'b0),
                 .spu_ifu_ttype_w2      (1'b0),
                 .spu_ifu_unc_err_w1    (1'b0),
                 .testmode_l            (testmode_l),
                 .tlu_hpstate_enb       (tlu_hpstate_enb[3:0]),
                 .tlu_hpstate_ibe       (tlu_hpstate_ibe[3:0]),
                 .tlu_hpstate_priv      (tlu_hpstate_priv[3:0]),
                 .tlu_idtlb_dmp_thrid_g (tlu_idtlb_dmp_thrid_g[1:0]),
                 .tlu_ifu_hwint_i3      (tlu_ifu_hwint_i3[3:0]),
                 .tlu_ifu_nukeint_i2    (tlu_ifu_nukeint_i2),
                 .tlu_ifu_pstate_ie     (tlu_ifu_pstate_ie[3:0]),
                 .tlu_ifu_pstate_pef    (tlu_ifu_pstate_pef[3:0]),
                 .tlu_ifu_resumint_i2   (tlu_ifu_resumint_i2),
                 .tlu_ifu_rstint_i2     (tlu_ifu_rstint_i2),
                 .tlu_ifu_rstthr_i2     (tlu_ifu_rstthr_i2[3:0]),
                 .tlu_ifu_sftint_vld    (tlu_ifu_sftint_vld[3:0]),
                 .tlu_ifu_trap_tid_w1   (tlu_ifu_trap_tid_w1[1:0]),
                 .tlu_ifu_trapnpc_vld_w1(tlu_ifu_trapnpc_vld_w1),
                 .tlu_ifu_trapnpc_w2    (tlu_ifu_trapnpc_w2[48:0]),
                 .tlu_ifu_trappc_vld_w1 (tlu_ifu_trappc_vld_w1),
                 .tlu_ifu_trappc_w2     (tlu_ifu_trappc_w2[48:0]),
                 .tlu_itlb_data_rd_g    (tlu_itlb_data_rd_g),
                 .tlu_itlb_dmp_actxt_g  (tlu_itlb_dmp_actxt_g),
                 .tlu_itlb_dmp_nctxt_g  (tlu_itlb_dmp_nctxt_g),
                 .tlu_itlb_dmp_vld_g    (tlu_itlb_dmp_vld_g),
                 .tlu_itlb_invalidate_all_g(tlu_itlb_invalidate_all_g),
                 .tlu_itlb_tag_rd_g     (tlu_itlb_tag_rd_g),
                 .tlu_itlb_wr_vld_g     (tlu_itlb_wr_vld_g),
                 .tlu_lsu_pstate_am     (tlu_lsu_pstate_am[3:0]),
                 .tlu_lsu_pstate_priv   (tlu_lsu_pstate_priv[3:0]),
                 .tlu_lsu_redmode       (tlu_lsu_redmode[3:0]));

`else
   
   sparc_ifu ifu(
                 // scan
                 .short_si0              (spc_scanin0),
                 .short_si1              (spc_scanin1),
                 .short_so0              (short_scan0_1),
                 .short_so1              (short_scan1_1),
                 .si0                    (scan0_1),
                 .so0                    (scan0_2),
                 // reset stuff and clk 
                 .grst_l                 (spc_grst_l),
                 .arst_l                 (cmp_arst_l),
                 .gdbginit_l             (spc_dbginit_l),
                 
                 // quad ldst disabled
                 .lsu_ifu_quad_asi_e    (1'b0),

                 // tlb on condition changes with hypervisor
                 // itlb_en is the bit from the lsu control register
                 // with no additional logic
                 .lsu_ifu_addr_real_l  (lsu_ifu_itlb_en[3:0]),
                 
                 // name change
		             .lsu_ifu_dtlb_data_ue	(lsu_ifu_tlb_data_ue),
		             .lsu_ifu_dtlb_tag_ue	(lsu_ifu_tlb_tag_ue),
                 .lsu_ifu_dtlb_data_su  (lsu_ifu_tlb_data_su),

	               .tlu_ifu_hintp_vld	    (tlu_hintp_vld[3:0]),
	               .tlu_ifu_rerr_vld	    (tlu_rerr_vld[3:0]),

		             .lsu_ifu_t0_tlz    	(tlu_lsu_tl_zero[0]),
		             .lsu_ifu_t1_tlz    	(tlu_lsu_tl_zero[1]),
		             .lsu_ifu_t2_tlz	    (tlu_lsu_tl_zero[2]),
		             .lsu_ifu_t3_tlz	    (tlu_lsu_tl_zero[3]),
                 
                 .lsu_ifu_ldst_miss_g   (lsu_ifu_ldst_miss_w),
                 .tlu_ifu_flush_pipe_w  (lsu_ifu_flush_pipe_w),

                 .lsu_idtlb_mrgn        (lsu_itlb_mrgn[7:0]),

                 .mbist_loop_on_address (mbist_loop_on_addr),
                 
                 .tlu_sscan_data        (tlu_sscan_test_data[62:0]),
                 .sparc_sscan_so        (spc_sscan_so),
                 .ifu_tlu_imm_asi_d     (ifu_tlu_imm_asi_d[8:0]),

                 // bus width difference
                 .lsu_ifu_cpxpkt_i1     ({lsu_ifu_cpxpkt_vld_i1,
                                          lsu_ifu_cpxpkt_i1[`CPX_VLD-1:0]}),
                 
		             /*AUTOINST*/
                 // Outputs
                 .ifu_exu_addr_mask_d   (ifu_exu_addr_mask_d),
                 .ifu_tlu_inst_vld_w    (ifu_tlu_inst_vld_w),
                 .ifu_tlu_flush_w       (ifu_tlu_flush_w),
                 .ifu_lsu_alt_space_e   (ifu_lsu_alt_space_e),
                 .ifu_tlu_ttype_vld_m   (ifu_tlu_ttype_vld_m),
                 .ifu_exu_muldivop_d    (ifu_exu_muldivop_d[4:0]),
                 .ifu_lsu_thrid_s       (ifu_lsu_thrid_s[1:0]),
                 .mbist_write_data      (mbist_write_data[7:0]),
                 .ifu_exu_aluop_d       (ifu_exu_aluop_d[2:0]),
                 .ifu_exu_casa_d        (ifu_exu_casa_d),
                 .ifu_exu_dbrinst_d     (ifu_exu_dbrinst_d),
                 .ifu_exu_disable_ce_e  (ifu_exu_disable_ce_e),
                 .ifu_exu_dontmv_regz0_e(ifu_exu_dontmv_regz0_e),
                 .ifu_exu_dontmv_regz1_e(ifu_exu_dontmv_regz1_e),
                 .ifu_exu_ecc_mask      (ifu_exu_ecc_mask[7:0]),
                 .ifu_exu_enshift_d     (ifu_exu_enshift_d),
                 .ifu_exu_flushw_e      (ifu_exu_flushw_e),
                 .ifu_exu_ialign_d      (ifu_exu_ialign_d),
                 .ifu_exu_imm_data_d    (ifu_exu_imm_data_d[31:0]),
                 .ifu_exu_inj_irferr    (ifu_exu_inj_irferr),
                 .ifu_exu_inst_vld_e    (ifu_exu_inst_vld_e),
                 .ifu_exu_inst_vld_w    (ifu_exu_inst_vld_w),
                 .ifu_exu_invert_d      (ifu_exu_invert_d),
                 .ifu_exu_kill_e        (ifu_exu_kill_e),
                 .ifu_exu_muls_d        (ifu_exu_muls_d),
                 .ifu_exu_nceen_e       (ifu_exu_nceen_e),
                 .ifu_exu_pc_d          (ifu_exu_pc_d[47:0]),
                 .ifu_exu_pcver_e       (ifu_exu_pcver_e[63:0]),
                 .ifu_exu_range_check_jlret_d(ifu_exu_range_check_jlret_d),
                 .ifu_exu_range_check_other_d(ifu_exu_range_check_other_d),
                 .ifu_exu_rd_d          (ifu_exu_rd_d[4:0]),
                 .ifu_exu_rd_exusr_e    (ifu_exu_rd_exusr_e),
                 .ifu_exu_rd_ffusr_e    (ifu_exu_rd_ffusr_e),
                 .ifu_exu_rd_ifusr_e    (ifu_exu_rd_ifusr_e),
                 .ifu_exu_ren1_s        (ifu_exu_ren1_s),
                 .ifu_exu_ren2_s        (ifu_exu_ren2_s),
                 .ifu_exu_ren3_s        (ifu_exu_ren3_s),
                 .ifu_exu_restore_d     (ifu_exu_restore_d),
                 .ifu_exu_restored_e    (ifu_exu_restored_e),
                 .ifu_exu_return_d      (ifu_exu_return_d),
                 .ifu_exu_rs1_s         (ifu_exu_rs1_s[4:0]),
                 .ifu_exu_rs1_vld_d     (ifu_exu_rs1_vld_d),
                 .ifu_exu_rs2_s         (ifu_exu_rs2_s[4:0]),
                 .ifu_exu_rs2_vld_d     (ifu_exu_rs2_vld_d),
                 .ifu_exu_rs3_s         (ifu_exu_rs3_s[4:0]),
                 .ifu_exu_rs3e_vld_d    (ifu_exu_rs3e_vld_d),
                 .ifu_exu_rs3o_vld_d    (ifu_exu_rs3o_vld_d),
                 .ifu_exu_save_d        (ifu_exu_save_d),
                 .ifu_exu_saved_e       (ifu_exu_saved_e),
                 .ifu_exu_setcc_d       (ifu_exu_setcc_d),
                 .ifu_exu_sethi_inst_d  (ifu_exu_sethi_inst_d),
                 .ifu_exu_shiftop_d     (ifu_exu_shiftop_d[2:0]),
                 .ifu_exu_tagop_d       (ifu_exu_tagop_d),
                 .ifu_exu_tcc_e         (ifu_exu_tcc_e),
                 .ifu_exu_tid_s2        (ifu_exu_tid_s2[1:0]),
                 .ifu_exu_ttype_vld_m   (ifu_exu_ttype_vld_m),
                 .ifu_exu_tv_d          (ifu_exu_tv_d),
                 .ifu_exu_use_rsr_e_l   (ifu_exu_use_rsr_e_l),
                 .ifu_exu_usecin_d      (ifu_exu_usecin_d),
                 .ifu_exu_useimm_d      (ifu_exu_useimm_d),
                 .ifu_exu_wen_d         (ifu_exu_wen_d),
                 .ifu_exu_wsr_inst_d    (ifu_exu_wsr_inst_d),
                 .ifu_ffu_fcc_num_d     (ifu_ffu_fcc_num_d[1:0]),
                 .ifu_ffu_fld_d         (ifu_ffu_fld_d),
                 .ifu_ffu_fpop1_d       (ifu_ffu_fpop1_d),
                 .ifu_ffu_fpop2_d       (ifu_ffu_fpop2_d),
                 .ifu_ffu_fpopcode_d    (ifu_ffu_fpopcode_d[8:0]),
                 .ifu_ffu_frd_d         (ifu_ffu_frd_d[4:0]),
                 .ifu_ffu_frs1_d        (ifu_ffu_frs1_d[4:0]),
                 .ifu_ffu_frs2_d        (ifu_ffu_frs2_d[4:0]),
                 .ifu_ffu_fst_d         (ifu_ffu_fst_d),
                 .ifu_ffu_inj_frferr    (ifu_ffu_inj_frferr),
                 .ifu_ffu_ldfsr_d       (ifu_ffu_ldfsr_d),
                 .ifu_ffu_ldst_size_d   (ifu_ffu_ldst_size_d),
                 .ifu_ffu_ldxfsr_d      (ifu_ffu_ldxfsr_d),
                 .ifu_ffu_mvcnd_m       (ifu_ffu_mvcnd_m),
                 .ifu_ffu_quad_op_e     (ifu_ffu_quad_op_e),
                 .ifu_ffu_stfsr_d       (ifu_ffu_stfsr_d),
                 .ifu_ffu_visop_d       (ifu_ffu_visop_d),
                 .ifu_lsu_alt_space_d   (ifu_lsu_alt_space_d),
                 .ifu_lsu_asi_ack       (ifu_lsu_asi_ack),
                 .ifu_lsu_asi_rd_unc    (ifu_lsu_asi_rd_unc),
                 .ifu_lsu_casa_e        (ifu_lsu_casa_e),
                 .ifu_lsu_destid_s      (ifu_lsu_destid_s[2:0]),
                 .ifu_lsu_error_inj     (ifu_lsu_error_inj[3:0]),
                 .ifu_lsu_fwd_data_vld  (ifu_lsu_fwd_data_vld),
                 .ifu_lsu_fwd_wr_ack    (ifu_lsu_fwd_wr_ack),
                 .ifu_lsu_ibuf_busy     (ifu_lsu_ibuf_busy),
                 .ifu_lsu_imm_asi_d     (ifu_lsu_imm_asi_d[7:0]),
                 .ifu_lsu_imm_asi_vld_d (ifu_lsu_imm_asi_vld_d),
                 .ifu_lsu_inv_clear     (ifu_lsu_inv_clear),
                 .ifu_lsu_ld_inst_e     (ifu_lsu_ld_inst_e),
                 .ifu_lsu_ldst_dbl_e    (ifu_lsu_ldst_dbl_e),
                 .ifu_lsu_ldst_fp_e     (ifu_lsu_ldst_fp_e),
                 .ifu_lsu_ldst_size_e   (ifu_lsu_ldst_size_e[1:0]),
                 .ifu_lsu_ldstub_e      (ifu_lsu_ldstub_e),
                 .ifu_lsu_ldxa_data_vld_w2(ifu_lsu_ldxa_data_vld_w2),
                 .ifu_lsu_ldxa_data_w2  (ifu_lsu_ldxa_data_w2[63:0]),
                 .ifu_lsu_ldxa_illgl_va_w2(ifu_lsu_ldxa_illgl_va_w2),
                 .ifu_lsu_ldxa_tid_w2   (ifu_lsu_ldxa_tid_w2[1:0]),
                 .ifu_lsu_memref_d      (ifu_lsu_memref_d),
                 .ifu_lsu_nceen         (ifu_lsu_nceen[3:0]),
                 .ifu_lsu_pcxpkt_e      (ifu_lsu_pcxpkt_e[51:0]),
                 .ifu_lsu_pcxreq_d      (ifu_lsu_pcxreq_d),
                 .ifu_lsu_pref_inst_e   (ifu_lsu_pref_inst_e),
                 .ifu_lsu_rd_e          (ifu_lsu_rd_e[4:0]),
                 .ifu_lsu_sign_ext_e    (ifu_lsu_sign_ext_e),
                 .ifu_lsu_st_inst_e     (ifu_lsu_st_inst_e),
                 .ifu_lsu_swap_e        (ifu_lsu_swap_e),
                 .ifu_lsu_wsr_inst_d    (ifu_lsu_wsr_inst_d),
                 .ifu_mmu_trap_m        (ifu_mmu_trap_m),
                 .ifu_spu_inst_vld_w    (ifu_spu_inst_vld_w),
                 .ifu_spu_nceen         (ifu_spu_nceen[3:0]),
                 .ifu_spu_trap_ack      (ifu_spu_trap_ack),
                 .ifu_tlu_alt_space_d   (ifu_tlu_alt_space_d),
                 .ifu_tlu_done_inst_d   (ifu_tlu_done_inst_d),
                 .ifu_tlu_flsh_inst_e   (ifu_tlu_flsh_inst_e),
                 .ifu_tlu_flush_m       (ifu_tlu_flush_m),
                 .ifu_tlu_hwint_m       (ifu_tlu_hwint_m),
                 .ifu_tlu_icmiss_e      (ifu_tlu_icmiss_e),
                 .ifu_tlu_immu_miss_m   (ifu_tlu_immu_miss_m),
                 .ifu_tlu_inst_vld_m    (ifu_tlu_inst_vld_m),
                 .ifu_tlu_itlb_done     (ifu_tlu_itlb_done),
                 .ifu_tlu_l2imiss       (ifu_tlu_l2imiss[3:0]),
                 .ifu_tlu_mb_inst_e     (ifu_tlu_mb_inst_e),
                 .ifu_tlu_npc_m         (ifu_tlu_npc_m[48:0]),
                 .ifu_tlu_pc_m          (ifu_tlu_pc_m[48:0]),
                 .ifu_tlu_pc_oor_e      (ifu_tlu_pc_oor_e),
                 .ifu_tlu_priv_violtn_m (ifu_tlu_priv_violtn_m),
                 .ifu_tlu_retry_inst_d  (ifu_tlu_retry_inst_d),
                 .ifu_tlu_rsr_inst_d    (ifu_tlu_rsr_inst_d),
                 .ifu_tlu_rstint_m      (ifu_tlu_rstint_m),
                 .ifu_tlu_sftint_m      (ifu_tlu_sftint_m),
                 .ifu_tlu_sir_inst_m    (ifu_tlu_sir_inst_m),
                 .ifu_tlu_sraddr_d      (ifu_tlu_sraddr_d[6:0]),
                 .ifu_tlu_sraddr_d_v2   (ifu_tlu_sraddr_d_v2[6:0]),
                 .ifu_tlu_thrid_d       (ifu_tlu_thrid_d[1:0]),
                 .ifu_tlu_thrid_e       (ifu_tlu_thrid_e[1:0]),
                 .ifu_tlu_trap_m        (ifu_tlu_trap_m),
                 .ifu_tlu_ttype_m       (ifu_tlu_ttype_m[8:0]),
                 .mbist_dcache_fail     (mbist_dcache_fail),
                 .mbist_dcache_index    (mbist_dcache_index[6:0]),
                 .mbist_dcache_read     (mbist_dcache_read),
                 .mbist_dcache_way      (mbist_dcache_way[1:0]),
                 .mbist_dcache_word     (mbist_dcache_word),
                 .mbist_dcache_write    (mbist_dcache_write),
                 .mbist_done            (mbist_done),
                 .mbist_icache_fail     (mbist_icache_fail),
                 .spc_efc_ifuse_data    (spc_efc_ifuse_data),
                 // Inputs
                 .mem_write_disable     (mem_write_disable),
                 .mux_drive_disable     (mux_drive_disable),
                 .exu_tlu_wsr_data_m    (exu_tlu_wsr_data_m[2:0]),
                 .lsu_ictag_mrgn        (lsu_ictag_mrgn[3:0]),
                 .tlu_itlb_tte_tag_w2   (tlu_itlb_tte_tag_w2[58:0]),
                 .tlu_itlb_tte_data_w2  (tlu_itlb_tte_data_w2[42:0]),
                 .tlu_itlb_rw_index_vld_g(tlu_itlb_rw_index_vld_g),
                 .tlu_itlb_rw_index_g   (tlu_itlb_rw_index_g[5:0]),
                 .tlu_idtlb_dmp_key_g   (tlu_idtlb_dmp_key_g[40:0]),
                 .tlu_itlb_dmp_all_g    (tlu_itlb_dmp_all_g),
                 .lsu_sscan_data        (lsu_sscan_data[15:0]),
                 .const_cpuid           (const_cpuid[3:0]),
                 .const_maskid          (const_maskid[7:0]),
                 .ctu_sscan_se          (ctu_sscan_se),
                 .ctu_sscan_snap        (ctu_sscan_snap),
                 .ctu_sscan_tid         (ctu_sscan_tid[3:0]),
                 .ctu_tck               (ctu_tck),
                 .efc_spc_fuse_clk1     (efc_spc_fuse_clk1),
                 .efc_spc_fuse_clk2     (efc_spc_fuse_clk2),
                 .efc_spc_ifuse_ashift  (efc_spc_ifuse_ashift),
                 .efc_spc_ifuse_data    (efc_spc_ifuse_data),
                 .efc_spc_ifuse_dshift  (efc_spc_ifuse_dshift),
                 .exu_ifu_brpc_e        (exu_ifu_brpc_e[47:0]),
                 .exu_ifu_cc_d          (exu_ifu_cc_d[7:0]),
                 .exu_ifu_ecc_ce_m      (exu_ifu_ecc_ce_m),
                 .exu_ifu_ecc_ue_m      (exu_ifu_ecc_ue_m),
                 .exu_ifu_err_reg_m     (exu_ifu_err_reg_m[7:0]),
                 .exu_ifu_err_synd_m    (exu_ifu_err_synd_m[7:0]),
                 .exu_ifu_inj_ack       (exu_ifu_inj_ack),
                 .exu_ifu_longop_done_g (exu_ifu_longop_done_g[3:0]),
                 .exu_ifu_oddwin_s      (exu_ifu_oddwin_s[3:0]),
                 .exu_ifu_regn_e        (exu_ifu_regn_e),
                 .exu_ifu_regz_e        (exu_ifu_regz_e),
                 .exu_ifu_spill_e       (exu_ifu_spill_e),
                 .exu_ifu_va_oor_m      (exu_ifu_va_oor_m),
                 .ffu_ifu_cc_vld_w2     (ffu_ifu_cc_vld_w2[3:0]),
                 .ffu_ifu_cc_w2         (ffu_ifu_cc_w2[7:0]),
                 .ffu_ifu_ecc_ce_w2     (ffu_ifu_ecc_ce_w2),
                 .ffu_ifu_ecc_ue_w2     (ffu_ifu_ecc_ue_w2),
                 .ffu_ifu_err_reg_w2    (ffu_ifu_err_reg_w2[5:0]),
                 .ffu_ifu_err_synd_w2   (ffu_ifu_err_synd_w2[13:0]),
                 .ffu_ifu_fpop_done_w2  (ffu_ifu_fpop_done_w2),
                 .ffu_ifu_fst_ce_w      (ffu_ifu_fst_ce_w),
                 .ffu_ifu_inj_ack       (ffu_ifu_inj_ack),
                 .ffu_ifu_stallreq      (ffu_ifu_stallreq),
                 .ffu_ifu_tid_w2        (ffu_ifu_tid_w2[1:0]),
                 .lsu_ifu_asi_addr      (lsu_ifu_asi_addr[17:0]),
                 .lsu_ifu_asi_load      (lsu_ifu_asi_load),
                 .lsu_ifu_asi_state     (lsu_ifu_asi_state[7:0]),
                 .lsu_ifu_asi_thrid     (lsu_ifu_asi_thrid[1:0]),
                 .lsu_ifu_asi_vld       (lsu_ifu_asi_vld),
                 .lsu_ifu_dc_parity_error_w2(lsu_ifu_dc_parity_error_w2),
                 .lsu_ifu_dcache_data_perror(lsu_ifu_dcache_data_perror),
                 .lsu_ifu_dcache_tag_perror(lsu_ifu_dcache_tag_perror),
                 .lsu_ifu_direct_map_l1 (lsu_ifu_direct_map_l1),
                 .lsu_ifu_err_addr      (lsu_ifu_err_addr[47:4]),
                 .lsu_ifu_error_tid     (lsu_ifu_error_tid[1:0]),
                 .lsu_ifu_icache_en     (lsu_ifu_icache_en[3:0]),
                 .lsu_ifu_inj_ack       (lsu_ifu_inj_ack[3:0]),
                 .lsu_ifu_io_error      (lsu_ifu_io_error),
                 .lsu_ifu_l2_corr_error (lsu_ifu_l2_corr_error),
                 .lsu_ifu_l2_unc_error  (lsu_ifu_l2_unc_error),
                 .lsu_ifu_ld_icache_index(lsu_ifu_ld_icache_index[`IC_IDX_HI:5]),
                 .lsu_ifu_ld_pcxpkt_tid (lsu_ifu_ld_pcxpkt_tid[1:0]),
                 .lsu_ifu_ld_pcxpkt_vld (lsu_ifu_ld_pcxpkt_vld),
                 .lsu_ifu_ldst_cmplt    (lsu_ifu_ldst_cmplt[3:0]),
                 .lsu_ifu_ldsta_internal_e(lsu_ifu_ldsta_internal_e),
                 .lsu_ifu_pcxpkt_ack_d  (lsu_ifu_pcxpkt_ack_d),
                 .lsu_ifu_stallreq      (lsu_ifu_stallreq),
                 .lsu_ifu_stbcnt0       (lsu_ifu_stbcnt0[3:0]),
                 .lsu_ifu_stbcnt1       (lsu_ifu_stbcnt1[3:0]),
                 .lsu_ifu_stbcnt2       (lsu_ifu_stbcnt2[3:0]),
                 .lsu_ifu_stbcnt3       (lsu_ifu_stbcnt3[3:0]),
                 .lsu_ifu_stxa_data     (lsu_ifu_stxa_data[47:0]),
                 .lsu_pid_state0        (lsu_pid_state0[2:0]),
                 .lsu_pid_state1        (lsu_pid_state1[2:0]),
                 .lsu_pid_state2        (lsu_pid_state2[2:0]),
                 .lsu_pid_state3        (lsu_pid_state3[2:0]),
                 .lsu_t0_pctxt_state    (lsu_t0_pctxt_state[12:0]),
                 .lsu_t1_pctxt_state    (lsu_t1_pctxt_state[12:0]),
                 .lsu_t2_pctxt_state    (lsu_t2_pctxt_state[12:0]),
                 .lsu_t3_pctxt_state    (lsu_t3_pctxt_state[12:0]),
                 .mbist_bisi_mode       (mbist_bisi_mode),
                 .mbist_dcache_data_in  (mbist_dcache_data_in[71:0]),
                 .mbist_loop_mode       (mbist_loop_mode),
                 .mbist_start           (mbist_start),
                 .mbist_stop_on_fail    (mbist_stop_on_fail),
                 .mbist_stop_on_next_fail(mbist_stop_on_next_fail),
                 .mbist_userdata_mode   (mbist_userdata_mode),
                 .rclk                  (rclk),
                 .se                    (se),
                 .sehold                (sehold),
                 .spu_ifu_corr_err_w2   (spu_ifu_corr_err_w2),
                 .spu_ifu_err_addr_w2   (spu_ifu_err_addr_w2[39:4]),
                 .spu_ifu_int_w2        (spu_ifu_int_w2),
                 .spu_ifu_mamem_err_w1  (spu_ifu_mamem_err_w1),
                 .spu_ifu_ttype_tid_w2  (spu_ifu_ttype_tid_w2[1:0]),
                 .spu_ifu_ttype_vld_w2  (spu_ifu_ttype_vld_w2),
                 .spu_ifu_ttype_w2      (spu_ifu_ttype_w2),
                 .spu_ifu_unc_err_w1    (spu_ifu_unc_err_w1),
                 .testmode_l            (testmode_l),
                 .tlu_hpstate_enb       (tlu_hpstate_enb[3:0]),
                 .tlu_hpstate_ibe       (tlu_hpstate_ibe[3:0]),
                 .tlu_hpstate_priv      (tlu_hpstate_priv[3:0]),
                 .tlu_idtlb_dmp_thrid_g (tlu_idtlb_dmp_thrid_g[1:0]),
                 .tlu_ifu_hwint_i3      (tlu_ifu_hwint_i3[3:0]),
                 .tlu_ifu_nukeint_i2    (tlu_ifu_nukeint_i2),
                 .tlu_ifu_pstate_ie     (tlu_ifu_pstate_ie[3:0]),
                 .tlu_ifu_pstate_pef    (tlu_ifu_pstate_pef[3:0]),
                 .tlu_ifu_resumint_i2   (tlu_ifu_resumint_i2),
                 .tlu_ifu_rstint_i2     (tlu_ifu_rstint_i2),
                 .tlu_ifu_rstthr_i2     (tlu_ifu_rstthr_i2[3:0]),
                 .tlu_ifu_sftint_vld    (tlu_ifu_sftint_vld[3:0]),
                 .tlu_ifu_trap_tid_w1   (tlu_ifu_trap_tid_w1[1:0]),
                 .tlu_ifu_trapnpc_vld_w1(tlu_ifu_trapnpc_vld_w1),
                 .tlu_ifu_trapnpc_w2    (tlu_ifu_trapnpc_w2[48:0]),
                 .tlu_ifu_trappc_vld_w1 (tlu_ifu_trappc_vld_w1),
                 .tlu_ifu_trappc_w2     (tlu_ifu_trappc_w2[48:0]),
                 .tlu_itlb_data_rd_g    (tlu_itlb_data_rd_g),
                 .tlu_itlb_dmp_actxt_g  (tlu_itlb_dmp_actxt_g),
                 .tlu_itlb_dmp_nctxt_g  (tlu_itlb_dmp_nctxt_g),
                 .tlu_itlb_dmp_vld_g    (tlu_itlb_dmp_vld_g),
                 .tlu_itlb_invalidate_all_g(tlu_itlb_invalidate_all_g),
                 .tlu_itlb_tag_rd_g     (tlu_itlb_tag_rd_g),
                 .tlu_itlb_wr_vld_g     (tlu_itlb_wr_vld_g),
                 .tlu_lsu_pstate_am     (tlu_lsu_pstate_am[3:0]),
                 .tlu_lsu_pstate_priv   (tlu_lsu_pstate_priv[3:0]),
                 .tlu_lsu_redmode       (tlu_lsu_redmode[3:0]));

`endif //  `ifdef FPGA_SYN_NO_SPU
   

`ifdef FPGA_SYN_NO_SPU

      lsu lsu(
           // temp - name change
           .ifu_tlu_wsr_inst_d          (ifu_lsu_wsr_inst_d),
	   // eco 6529 .
	   .lsu_ffu_st_dtlb_perr_g		(lsu_ffu_st_dtlb_perr_g),
	   // Bug 4799.
	   .tlu_lsu_priv_trap_m		(tlu_lsu_priv_trap_m),

           .short_si0              (short_scan0_1),
           .short_si1              (short_scan1_1),
           .short_so0              (short_scan0_2),
           .short_so1              (short_scan1_2),
           .si0                          (scan0_3),
           .si1                          (short_scan1_4),
           .so0                          (scan0_4),
           .so1                          (scan1_1),
           // reset stuff
           .grst_l                       (spc_grst_l),
           .arst_l                       (cmp_arst_l),
           .clk                          (rclk),
	         .lsu_exu_dfill_data_w2	(lsu_exu_dfill_data_g[63:0]),
	         .lsu_exu_dfill_vld_w2	(lsu_exu_dfill_vld_g),
	         .lsu_exu_ldst_miss_w2	(lsu_exu_ldst_miss_g2),
           //.cpx_spc_data_cx             (cpx_spc_data_cx3[`CPX_WIDTH-1:0]),
           .cpx_spc_data_cx             ({cpx_spc_data_cx3_b144to140[`CPX_WIDTH-1:140],
                                          cpx_spc_data_cx3[139:121],
                                          cpx_spc_data_cx3_b120to118[`CPX_INV_CID_HI:`CPX_INV_CID_LO],
                                          cpx_spc_data_cx3[117:110],
                                          cpx_spc_data_cx3_b109,
                                          cpx_spc_data_cx3[108:107],
                                          cpx_spc_data_cx3_b106,
                                          cpx_spc_data_cx3[105:104],
                                          cpx_spc_data_cx3_b103,
                                          cpx_spc_data_cx3[102:101],
                                          cpx_spc_data_cx3_b100,
                                          cpx_spc_data_cx3[99:98],
                                          cpx_spc_data_cx3_b97,
                                          cpx_spc_data_cx3[96:95],
                                          cpx_spc_data_cx3_b94,
                                          cpx_spc_data_cx3[93:92],
                                          cpx_spc_data_cx3_b91,
                                          cpx_spc_data_cx3[90:89],
                                          cpx_spc_data_cx3_b88,
                                          cpx_spc_data_cx3[87:85],
                                          cpx_spc_data_cx3_b84,
                                          cpx_spc_data_cx3[83:81],
                                          cpx_spc_data_cx3_b80,
                                          cpx_spc_data_cx3[79:77],
                                          cpx_spc_data_cx3_b76,
                                          cpx_spc_data_cx3[75:73],
                                          cpx_spc_data_cx3_b72,
                                          cpx_spc_data_cx3[71:69],
                                          cpx_spc_data_cx3_b68,
                                          cpx_spc_data_cx3[67:65],
                                          cpx_spc_data_cx3_b64,
                                          cpx_spc_data_cx3[63:61],
                                          cpx_spc_data_cx3_b60,
                                          cpx_spc_data_cx3[59:57],
                                          cpx_spc_data_cx3_b56,
                                          cpx_spc_data_cx3[55:54],
                                          cpx_spc_data_cx3_b53,
                                          cpx_spc_data_cx3[52:51],
                                          cpx_spc_data_cx3_b50,
                                          cpx_spc_data_cx3[49:48],
                                          cpx_spc_data_cx3_b47,
                                          cpx_spc_data_cx3[46:45],
                                          cpx_spc_data_cx3_b44,
                                          cpx_spc_data_cx3[43:42],
                                          cpx_spc_data_cx3_b41,
                                          cpx_spc_data_cx3[40:39],
                                          cpx_spc_data_cx3_b38,
                                          cpx_spc_data_cx3[37:36],
                                          cpx_spc_data_cx3_b35,
                                          cpx_spc_data_cx3[34:33],
                                          cpx_spc_data_cx3_b32,
                                          cpx_spc_data_cx3[31:29],
                                          cpx_spc_data_cx3_b28,
                                          cpx_spc_data_cx3[27:25],
                                          cpx_spc_data_cx3_b24,
                                          cpx_spc_data_cx3[23:21],
                                          cpx_spc_data_cx3_b20,
                                          cpx_spc_data_cx3[19:17],
                                          cpx_spc_data_cx3_b16,
                                          cpx_spc_data_cx3[15:13],
                                          cpx_spc_data_cx3_b12,
                                          cpx_spc_data_cx3[11:9],
                                          cpx_spc_data_cx3_b8,
                                          cpx_spc_data_cx3[7:5],
                                          cpx_spc_data_cx3_b4,
                                          cpx_spc_data_cx3[3:1],
                                          cpx_spc_data_cx3_b0}),
           .exu_tlu_wsr_data_m          (exu_tlu_wsr_data_m[7:0]),
           
	   // Hypervisor related
      	   .tlu_lsu_hpv_priv      	(tlu_hpstate_priv[3:0]),
           .tlu_lsu_hpstate_en     	(tlu_hpstate_enb[3:0]),

	         .spu_lsu_int_w2		(1'b0),
           .gdbginit_l             	(spc_dbginit_l),
           /*AUTOINST*/
           // Outputs
           .bist_ctl_reg_in             (bist_ctl_reg_in[6:0]),
           .bist_ctl_reg_wr_en          (bist_ctl_reg_wr_en),
           .ifu_tlu_flush_fd2_w         (ifu_tlu_flush_fd2_w),
           .ifu_tlu_flush_fd3_w         (ifu_tlu_flush_fd3_w),
           .ifu_tlu_flush_fd_w          (ifu_tlu_flush_fd_w),
           .lsu_asi_reg0                (lsu_asi_reg0[7:0]),
           .lsu_asi_reg1                (lsu_asi_reg1[7:0]),
           .lsu_asi_reg2                (lsu_asi_reg2[7:0]),
           .lsu_asi_reg3                (lsu_asi_reg3[7:0]),
           .lsu_dmmu_sfsr_trp_wr        (lsu_dmmu_sfsr_trp_wr[3:0]),
           .lsu_dsfsr_din_g             (lsu_dsfsr_din_g[23:0]),
           .lsu_exu_flush_pipe_w        (lsu_exu_flush_pipe_w),
           .lsu_exu_rd_m                (lsu_exu_rd_m[4:0]),
           .lsu_exu_st_dtlb_perr_g      (lsu_exu_st_dtlb_perr_g),
           .lsu_exu_thr_m               (lsu_exu_thr_m[1:0]),
           .lsu_ffu_ack                 (lsu_ffu_ack),
           .lsu_ffu_blk_asi_e           (lsu_ffu_blk_asi_e),
           .lsu_ffu_flush_pipe_w        (lsu_ffu_flush_pipe_w),
           .lsu_ffu_ld_data             (lsu_ffu_ld_data[63:0]),
           .lsu_ffu_ld_vld              (lsu_ffu_ld_vld),
           .lsu_ffu_stb_full0           (lsu_ffu_stb_full0),
           .lsu_ffu_stb_full1           (lsu_ffu_stb_full1),
           .lsu_ffu_stb_full2           (lsu_ffu_stb_full2),
           .lsu_ffu_stb_full3           (lsu_ffu_stb_full3),
           .lsu_ictag_mrgn              (lsu_ictag_mrgn[3:0]),
           .lsu_ifu_asi_addr            (lsu_ifu_asi_addr[17:0]),
           .lsu_ifu_asi_load            (lsu_ifu_asi_load),
           .lsu_ifu_asi_state           (lsu_ifu_asi_state[7:0]),
           .lsu_ifu_asi_thrid           (lsu_ifu_asi_thrid[1:0]),
           .lsu_ifu_asi_vld             (lsu_ifu_asi_vld),
           .lsu_ifu_cpxpkt_i1           (lsu_ifu_cpxpkt_i1[`CPX_VLD-1:0]),
           .lsu_ifu_cpxpkt_vld_i1       (lsu_ifu_cpxpkt_vld_i1),
           .lsu_ifu_dc_parity_error_w2  (lsu_ifu_dc_parity_error_w2),
           .lsu_ifu_dcache_data_perror  (lsu_ifu_dcache_data_perror),
           .lsu_ifu_dcache_tag_perror   (lsu_ifu_dcache_tag_perror),
           .lsu_ifu_direct_map_l1       (lsu_ifu_direct_map_l1),
           .lsu_ifu_error_tid           (lsu_ifu_error_tid[1:0]),
           .lsu_ifu_flush_pipe_w        (lsu_ifu_flush_pipe_w),
           .lsu_ifu_icache_en           (lsu_ifu_icache_en[3:0]),
           .lsu_ifu_io_error            (lsu_ifu_io_error),
           .lsu_ifu_itlb_en             (lsu_ifu_itlb_en[3:0]),
           .lsu_ifu_l2_corr_error       (lsu_ifu_l2_corr_error),
           .lsu_ifu_l2_unc_error        (lsu_ifu_l2_unc_error),
           .lsu_ifu_ld_icache_index     (lsu_ifu_ld_icache_index[11:5]),
           .lsu_ifu_ld_pcxpkt_tid       (lsu_ifu_ld_pcxpkt_tid[1:0]),
           .lsu_ifu_ld_pcxpkt_vld       (lsu_ifu_ld_pcxpkt_vld),
           .lsu_ifu_ldst_cmplt          (lsu_ifu_ldst_cmplt[3:0]),
           .lsu_ifu_ldst_miss_w         (lsu_ifu_ldst_miss_w),
           .lsu_ifu_ldsta_internal_e    (lsu_ifu_ldsta_internal_e),
           .lsu_ifu_pcxpkt_ack_d        (lsu_ifu_pcxpkt_ack_d),
           .lsu_ifu_stallreq            (lsu_ifu_stallreq),
           .lsu_ifu_stbcnt0             (lsu_ifu_stbcnt0[3:0]),
           .lsu_ifu_stbcnt1             (lsu_ifu_stbcnt1[3:0]),
           .lsu_ifu_stbcnt2             (lsu_ifu_stbcnt2[3:0]),
           .lsu_ifu_stbcnt3             (lsu_ifu_stbcnt3[3:0]),
           .lsu_ifu_stxa_data           (lsu_ifu_stxa_data[47:0]),
           .lsu_ifu_tlb_data_su         (lsu_ifu_tlb_data_su),
           .lsu_ifu_tlb_data_ue         (lsu_ifu_tlb_data_ue),
           .lsu_ifu_tlb_tag_ue          (lsu_ifu_tlb_tag_ue),
           .lsu_itlb_mrgn               (lsu_itlb_mrgn[7:0]),
           .lsu_mamem_mrgn              (),
           .lsu_mmu_defr_trp_taken_g    (lsu_mmu_defr_trp_taken_g),
           .lsu_mmu_flush_pipe_w        (lsu_mmu_flush_pipe_w),
           .lsu_mmu_rs3_data_g          (lsu_mmu_rs3_data_g[63:0]),
           .lsu_pid_state0              (lsu_pid_state0[2:0]),
           .lsu_pid_state1              (lsu_pid_state1[2:0]),
           .lsu_pid_state2              (lsu_pid_state2[2:0]),
           .lsu_pid_state3              (lsu_pid_state3[2:0]),
           .lsu_spu_asi_state_e         (),
           .lsu_spu_early_flush_g       (),
           .lsu_spu_ldst_ack            (),
           .lsu_spu_stb_empty           (),
           .lsu_spu_strm_ack_cmplt      (),
           .lsu_t0_pctxt_state          (lsu_t0_pctxt_state[12:0]),
           .lsu_t1_pctxt_state          (lsu_t1_pctxt_state[12:0]),
           .lsu_t2_pctxt_state          (lsu_t2_pctxt_state[12:0]),
           .lsu_t3_pctxt_state          (lsu_t3_pctxt_state[12:0]),
           .lsu_tlu_async_tid_w2        (lsu_tlu_async_tid_w2[1:0]),
           .lsu_tlu_async_ttype_vld_w2  (lsu_tlu_async_ttype_vld_w2),
           .lsu_tlu_async_ttype_w2      (lsu_tlu_async_ttype_w2[6:0]),
           .lsu_tlu_cpx_req             (lsu_tlu_cpx_req[3:0]),
           .lsu_tlu_cpx_vld             (lsu_tlu_cpx_vld),
           .lsu_tlu_daccess_excptn_g    (lsu_tlu_daccess_excptn_g),
           .lsu_tlu_dcache_miss_w2      (lsu_tlu_dcache_miss_w2[3:0]),
           .lsu_tlu_defr_trp_taken_g    (lsu_tlu_defr_trp_taken_g),
           .lsu_tlu_dmmu_miss_g         (lsu_tlu_dmmu_miss_g),
           .lsu_tlu_dside_ctxt_m        (lsu_tlu_dside_ctxt_m[12:0]),
           .lsu_tlu_dtlb_done           (lsu_tlu_dtlb_done),
           .lsu_tlu_early_flush2_w      (lsu_tlu_early_flush2_w),
           .lsu_tlu_early_flush_w       (lsu_tlu_early_flush_w),
           .lsu_tlu_intpkt              (lsu_tlu_intpkt[17:0]),
           .lsu_tlu_l2_dmiss            (lsu_tlu_l2_dmiss[3:0]),
           .lsu_tlu_ldst_va_m           (lsu_tlu_ldst_va_m[9:0]),
           .lsu_tlu_misalign_addr_ldst_atm_m(lsu_tlu_misalign_addr_ldst_atm_m),
           .lsu_tlu_pctxt_m             (lsu_tlu_pctxt_m[12:0]),
           .lsu_tlu_pcxpkt_ack          (lsu_tlu_pcxpkt_ack),
           .lsu_tlu_rs3_data_g          (lsu_tlu_rs3_data_g[63:0]),
           .lsu_tlu_rsr_data_e          (lsu_tlu_rsr_data_e[7:0]),
           .lsu_tlu_stb_full_w2         (lsu_tlu_stb_full_w2[3:0]),
           .lsu_tlu_thrid_d             (lsu_tlu_thrid_d[1:0]),
           .lsu_tlu_tlb_access_tid_m    (lsu_tlu_tlb_access_tid_m[1:0]),
           .lsu_tlu_tlb_asi_state_m     (lsu_tlu_tlb_asi_state_m[7:0]),
           .lsu_tlu_tlb_dmp_va_m        (lsu_tlu_tlb_dmp_va_m[47:13]),
           .lsu_tlu_tlb_ld_inst_m       (lsu_tlu_tlb_ld_inst_m),
           .lsu_tlu_tlb_ldst_va_m       (lsu_tlu_tlb_ldst_va_m[10:0]),
           .lsu_tlu_tlb_st_inst_m       (lsu_tlu_tlb_st_inst_m),
           .lsu_tlu_ttype_m2            (lsu_tlu_ttype_m2[8:0]),
           .lsu_tlu_ttype_vld_m2        (lsu_tlu_ttype_vld_m2),
           .lsu_tlu_wsr_inst_e          (lsu_tlu_wsr_inst_e),
           .mbist_dcache_data_in        (mbist_dcache_data_in[71:0]),
           .spc_efc_dfuse_data          (spc_efc_dfuse_data),
           .spc_pcx_atom_pq             (spc_pcx_atom_pq),
           .spc_pcx_data_pa             (spc_pcx_data_pa[`PCX_WIDTH-1:0]),
           .spc_pcx_req_pq              (spc_pcx_req_pq[4:0]),
           .lsu_asi_state               (lsu_asi_state[7:0]),
           .lsu_ifu_err_addr            (lsu_ifu_err_addr[47:4]),
           .lsu_sscan_data              (lsu_sscan_data[15:0]),
           .ifu_tlu_inst_vld_m_bf1      (ifu_tlu_inst_vld_m_bf1),
           .lsu_ffu_bld_cnt_w           (lsu_ffu_bld_cnt_w[2:0]),
           .lsu_tlu_nucleus_ctxt_m      (lsu_tlu_nucleus_ctxt_m),
           .lsu_tlu_tte_pg_sz_g         (lsu_tlu_tte_pg_sz_g[2:0]),
           .lsu_tlu_squash_va_oor_m     (lsu_tlu_squash_va_oor_m),
           .lsu_tlu_wtchpt_trp_g        (lsu_tlu_wtchpt_trp_g),
           .lsu_tlu_daccess_prot_g      (lsu_tlu_daccess_prot_g),
           .lsu_tlu_priv_action_g       (lsu_tlu_priv_action_g),
           // Inputs
           .bist_ctl_reg_out            (bist_ctl_reg_out[10:0]),
           .const_cpuid                 (const_cpuid[2:0]),
           .ctu_sscan_tid               (ctu_sscan_tid[3:0]),
           .efc_spc_dfuse_ashift        (efc_spc_dfuse_ashift),
           .efc_spc_dfuse_data          (efc_spc_dfuse_data),
           .efc_spc_dfuse_dshift        (efc_spc_dfuse_dshift),
           .efc_spc_fuse_clk1           (efc_spc_fuse_clk1),
           .efc_spc_fuse_clk2           (efc_spc_fuse_clk2),
           .exu_lsu_rs2_data_e          (exu_lsu_rs2_data_e[63:0]),
           .exu_lsu_rs3_data_e          (exu_lsu_rs3_data_e[63:0]),
           .exu_tlu_misalign_addr_jmpl_rtn_m(exu_tlu_misalign_addr_jmpl_rtn_m),
           .exu_tlu_va_oor_m            (exu_tlu_va_oor_m),
           .ffu_lsu_blk_st_e            (ffu_lsu_blk_st_e),
           .ffu_lsu_blk_st_va_e         (ffu_lsu_blk_st_va_e[5:3]),
           .ffu_lsu_fpop_rq_vld         (ffu_lsu_fpop_rq_vld),
           .ffu_lsu_kill_fst_w          (ffu_lsu_kill_fst_w),
           .ifu_lsu_alt_space_d         (ifu_lsu_alt_space_d),
           .ifu_lsu_alt_space_e         (ifu_lsu_alt_space_e),
           .ifu_lsu_asi_ack             (ifu_lsu_asi_ack),
           .ifu_lsu_asi_rd_unc          (ifu_lsu_asi_rd_unc),
           .ifu_lsu_casa_e              (ifu_lsu_casa_e),
           .ifu_lsu_destid_s            (ifu_lsu_destid_s[2:0]),
           .ifu_lsu_fwd_data_vld        (ifu_lsu_fwd_data_vld),
           .ifu_lsu_fwd_wr_ack          (ifu_lsu_fwd_wr_ack),
           .ifu_lsu_ibuf_busy           (ifu_lsu_ibuf_busy),
           .ifu_lsu_imm_asi_d           (ifu_lsu_imm_asi_d[7:0]),
           .ifu_lsu_imm_asi_vld_d       (ifu_lsu_imm_asi_vld_d),
           .ifu_lsu_inv_clear           (ifu_lsu_inv_clear),
           .ifu_lsu_ld_inst_e           (ifu_lsu_ld_inst_e),
           .ifu_lsu_ldst_dbl_e          (ifu_lsu_ldst_dbl_e),
           .ifu_lsu_ldst_fp_e           (ifu_lsu_ldst_fp_e),
           .ifu_lsu_ldst_size_e         (ifu_lsu_ldst_size_e[1:0]),
           .ifu_lsu_ldstub_e            (ifu_lsu_ldstub_e),
           .ifu_lsu_ldxa_data_vld_w2    (ifu_lsu_ldxa_data_vld_w2),
           .ifu_lsu_ldxa_data_w2        (ifu_lsu_ldxa_data_w2[63:0]),
           .ifu_lsu_ldxa_illgl_va_w2    (ifu_lsu_ldxa_illgl_va_w2),
           .ifu_lsu_ldxa_tid_w2         (ifu_lsu_ldxa_tid_w2[1:0]),
           .ifu_lsu_memref_d            (ifu_lsu_memref_d),
           .ifu_lsu_nceen               (ifu_lsu_nceen[3:0]),
           .ifu_lsu_pcxpkt_e            (ifu_lsu_pcxpkt_e[51:0]),
           .ifu_lsu_pcxreq_d            (ifu_lsu_pcxreq_d),
           .ifu_lsu_pref_inst_e         (ifu_lsu_pref_inst_e),
           .ifu_lsu_rd_e                (ifu_lsu_rd_e[4:0]),
           .ifu_lsu_sign_ext_e          (ifu_lsu_sign_ext_e),
           .ifu_lsu_st_inst_e           (ifu_lsu_st_inst_e),
           .ifu_lsu_swap_e              (ifu_lsu_swap_e),
           .ifu_lsu_thrid_s             (ifu_lsu_thrid_s[1:0]),
           .ifu_tlu_flsh_inst_e         (ifu_tlu_flsh_inst_e),
           .ifu_tlu_flush_m             (ifu_tlu_flush_m),
           .ifu_tlu_inst_vld_m          (ifu_tlu_inst_vld_m),
           .ifu_tlu_mb_inst_e           (ifu_tlu_mb_inst_e),
           .ifu_tlu_sraddr_d            (ifu_tlu_sraddr_d[6:0]),
           .ifu_tlu_thrid_e             (ifu_tlu_thrid_e[1:0]),
           .mbist_dcache_index          (mbist_dcache_index[6:0]),
           .mbist_dcache_read           (mbist_dcache_read),
           .mbist_dcache_way            (mbist_dcache_way[1:0]),
           .mbist_dcache_word           (mbist_dcache_word),
           .mbist_dcache_write          (mbist_dcache_write),
           .mbist_write_data            (mbist_write_data[7:0]),
           .mem_write_disable           (mem_write_disable),
           .mux_drive_disable           (mux_drive_disable),
           .pcx_spc_grant_px            (pcx_spc_grant_px[4:0]),
           .se                          (se),
           .sehold                      (sehold),
           .spu_lsu_ldxa_data_vld_w2    (1'b0),
           .spu_lsu_ldxa_data_w2        (64'h0000000000000000),
           .spu_lsu_ldxa_illgl_va_w2    (1'b0),
           .spu_lsu_ldxa_tid_w2         (2'b00),
           .spu_lsu_stxa_ack            (1'b0),
           .spu_lsu_stxa_ack_tid        (2'b00),
           .spu_lsu_unc_error_w2        (1'b0),
           .testmode_l                  (testmode_l),
           .tlu_dsfsr_flt_vld           (tlu_dsfsr_flt_vld[3:0]),
           .tlu_dtlb_data_rd_g          (tlu_dtlb_data_rd_g),
           .tlu_dtlb_dmp_actxt_g        (tlu_dtlb_dmp_actxt_g),
           .tlu_dtlb_dmp_all_g          (tlu_dtlb_dmp_all_g),
           .tlu_dtlb_dmp_nctxt_g        (tlu_dtlb_dmp_nctxt_g),
           .tlu_dtlb_dmp_pctxt_g        (tlu_dtlb_dmp_pctxt_g),
           .tlu_dtlb_dmp_sctxt_g        (tlu_dtlb_dmp_sctxt_g),
           .tlu_dtlb_dmp_vld_g          (tlu_dtlb_dmp_vld_g),
           .tlu_dtlb_invalidate_all_g   (tlu_dtlb_invalidate_all_g),
           .tlu_dtlb_rw_index_g         (tlu_dtlb_rw_index_g[5:0]),
           .tlu_dtlb_rw_index_vld_g     (tlu_dtlb_rw_index_vld_g),
           .tlu_dtlb_tag_rd_g           (tlu_dtlb_tag_rd_g),
           .tlu_dtlb_tte_data_w2        (tlu_dtlb_tte_data_w2[42:0]),
           .tlu_dtlb_tte_tag_w2         (tlu_dtlb_tte_tag_w2[58:0]),
           .tlu_early_flush_pipe2_w     (tlu_early_flush_pipe2_w),
           .tlu_early_flush_pipe_w      (tlu_early_flush_pipe_w),
           .tlu_exu_early_flush_pipe_w  (tlu_exu_early_flush_pipe_w),
           .tlu_idtlb_dmp_key_g         (tlu_idtlb_dmp_key_g[40:0]),
           .tlu_idtlb_dmp_thrid_g       (tlu_idtlb_dmp_thrid_g[1:0]),
           .tlu_lsu_asi_m               (tlu_lsu_asi_m[7:0]),
           .tlu_lsu_asi_update_m        (tlu_lsu_asi_update_m),
           .tlu_lsu_int_ld_ill_va_w2    (tlu_lsu_int_ld_ill_va_w2),
           .tlu_lsu_int_ldxa_data_w2    (tlu_lsu_int_ldxa_data_w2[63:0]),
           .tlu_lsu_int_ldxa_vld_w2     (tlu_lsu_int_ldxa_vld_w2),
           .tlu_lsu_ldxa_async_data_vld (tlu_lsu_ldxa_async_data_vld),
           .tlu_lsu_ldxa_tid_w2         (tlu_lsu_ldxa_tid_w2[1:0]),
           .tlu_lsu_pcxpkt              (tlu_lsu_pcxpkt[25:0]),
           .tlu_lsu_pstate_am           (tlu_lsu_pstate_am[3:0]),
           .tlu_lsu_pstate_cle          (tlu_lsu_pstate_cle[3:0]),
           .tlu_lsu_pstate_priv         (tlu_lsu_pstate_priv[3:0]),
           .tlu_lsu_redmode             (tlu_lsu_redmode[3:0]),
           .tlu_lsu_redmode_rst_d1      (tlu_lsu_redmode_rst_d1[3:0]),
           .tlu_lsu_stxa_ack            (tlu_lsu_stxa_ack),
           .tlu_lsu_stxa_ack_tid        (tlu_lsu_stxa_ack_tid[1:0]),
           .tlu_lsu_tid_m               (tlu_lsu_tid_m[1:0]),
           .tlu_lsu_tl_zero             (tlu_lsu_tl_zero[3:0]),
           .spu_lsu_ldst_pckt           (124'h0000000000000000000000000000000),
           .exu_lsu_ldst_va_e           (exu_lsu_ldst_va_e[47:0]),
           .exu_lsu_early_va_e          (exu_lsu_early_va_e[10:3]),
           .ffu_lsu_data                (ffu_lsu_data[80:0])); 

`else
     
   lsu lsu(
           // temp - name change
           .ifu_tlu_wsr_inst_d          (ifu_lsu_wsr_inst_d),
	   // eco 6529 .
	   .lsu_ffu_st_dtlb_perr_g		(lsu_ffu_st_dtlb_perr_g),
	   // Bug 4799.
	   .tlu_lsu_priv_trap_m		(tlu_lsu_priv_trap_m),

           .short_si0              (short_scan0_1),
           .short_si1              (short_scan1_1),
           .short_so0              (short_scan0_2),
           .short_so1              (short_scan1_2),
           .si0                          (scan0_3),
           .si1                          (short_scan1_5),
           .so0                          (scan0_4),
           .so1                          (scan1_1),
           // reset stuff
           .grst_l                       (spc_grst_l),
           .arst_l                       (cmp_arst_l),
           .clk                          (rclk),
	         .lsu_exu_dfill_data_w2	(lsu_exu_dfill_data_g[63:0]),
	         .lsu_exu_dfill_vld_w2	(lsu_exu_dfill_vld_g),
	         .lsu_exu_ldst_miss_w2	(lsu_exu_ldst_miss_g2),
           //.cpx_spc_data_cx             (cpx_spc_data_cx3[`CPX_WIDTH-1:0]),
           .cpx_spc_data_cx             ({cpx_spc_data_cx3_b144to140[`CPX_WIDTH-1:140],
                                          cpx_spc_data_cx3[139:121],
                                          cpx_spc_data_cx3_b120to118[`CPX_INV_CID_HI:`CPX_INV_CID_LO],
                                          cpx_spc_data_cx3[117:110],
                                          cpx_spc_data_cx3_b109,
                                          cpx_spc_data_cx3[108:107],
                                          cpx_spc_data_cx3_b106,
                                          cpx_spc_data_cx3[105:104],
                                          cpx_spc_data_cx3_b103,
                                          cpx_spc_data_cx3[102:101],
                                          cpx_spc_data_cx3_b100,
                                          cpx_spc_data_cx3[99:98],
                                          cpx_spc_data_cx3_b97,
                                          cpx_spc_data_cx3[96:95],
                                          cpx_spc_data_cx3_b94,
                                          cpx_spc_data_cx3[93:92],
                                          cpx_spc_data_cx3_b91,
                                          cpx_spc_data_cx3[90:89],
                                          cpx_spc_data_cx3_b88,
                                          cpx_spc_data_cx3[87:85],
                                          cpx_spc_data_cx3_b84,
                                          cpx_spc_data_cx3[83:81],
                                          cpx_spc_data_cx3_b80,
                                          cpx_spc_data_cx3[79:77],
                                          cpx_spc_data_cx3_b76,
                                          cpx_spc_data_cx3[75:73],
                                          cpx_spc_data_cx3_b72,
                                          cpx_spc_data_cx3[71:69],
                                          cpx_spc_data_cx3_b68,
                                          cpx_spc_data_cx3[67:65],
                                          cpx_spc_data_cx3_b64,
                                          cpx_spc_data_cx3[63:61],
                                          cpx_spc_data_cx3_b60,
                                          cpx_spc_data_cx3[59:57],
                                          cpx_spc_data_cx3_b56,
                                          cpx_spc_data_cx3[55:54],
                                          cpx_spc_data_cx3_b53,
                                          cpx_spc_data_cx3[52:51],
                                          cpx_spc_data_cx3_b50,
                                          cpx_spc_data_cx3[49:48],
                                          cpx_spc_data_cx3_b47,
                                          cpx_spc_data_cx3[46:45],
                                          cpx_spc_data_cx3_b44,
                                          cpx_spc_data_cx3[43:42],
                                          cpx_spc_data_cx3_b41,
                                          cpx_spc_data_cx3[40:39],
                                          cpx_spc_data_cx3_b38,
                                          cpx_spc_data_cx3[37:36],
                                          cpx_spc_data_cx3_b35,
                                          cpx_spc_data_cx3[34:33],
                                          cpx_spc_data_cx3_b32,
                                          cpx_spc_data_cx3[31:29],
                                          cpx_spc_data_cx3_b28,
                                          cpx_spc_data_cx3[27:25],
                                          cpx_spc_data_cx3_b24,
                                          cpx_spc_data_cx3[23:21],
                                          cpx_spc_data_cx3_b20,
                                          cpx_spc_data_cx3[19:17],
                                          cpx_spc_data_cx3_b16,
                                          cpx_spc_data_cx3[15:13],
                                          cpx_spc_data_cx3_b12,
                                          cpx_spc_data_cx3[11:9],
                                          cpx_spc_data_cx3_b8,
                                          cpx_spc_data_cx3[7:5],
                                          cpx_spc_data_cx3_b4,
                                          cpx_spc_data_cx3[3:1],
                                          cpx_spc_data_cx3_b0}),
           .exu_tlu_wsr_data_m          (exu_tlu_wsr_data_m[7:0]),
           
	   // Hypervisor related
      	   .tlu_lsu_hpv_priv      	(tlu_hpstate_priv[3:0]),
           .tlu_lsu_hpstate_en     	(tlu_hpstate_enb[3:0]),

	         .spu_lsu_int_w2		(1'b0),
           .gdbginit_l             	(spc_dbginit_l),
           /*AUTOINST*/
           // Outputs
           .bist_ctl_reg_in             (bist_ctl_reg_in[6:0]),
           .bist_ctl_reg_wr_en          (bist_ctl_reg_wr_en),
           .ifu_tlu_flush_fd2_w         (ifu_tlu_flush_fd2_w),
           .ifu_tlu_flush_fd3_w         (ifu_tlu_flush_fd3_w),
           .ifu_tlu_flush_fd_w          (ifu_tlu_flush_fd_w),
           .lsu_asi_reg0                (lsu_asi_reg0[7:0]),
           .lsu_asi_reg1                (lsu_asi_reg1[7:0]),
           .lsu_asi_reg2                (lsu_asi_reg2[7:0]),
           .lsu_asi_reg3                (lsu_asi_reg3[7:0]),
           .lsu_dmmu_sfsr_trp_wr        (lsu_dmmu_sfsr_trp_wr[3:0]),
           .lsu_dsfsr_din_g             (lsu_dsfsr_din_g[23:0]),
           .lsu_exu_flush_pipe_w        (lsu_exu_flush_pipe_w),
           .lsu_exu_rd_m                (lsu_exu_rd_m[4:0]),
           .lsu_exu_st_dtlb_perr_g      (lsu_exu_st_dtlb_perr_g),
           .lsu_exu_thr_m               (lsu_exu_thr_m[1:0]),
           .lsu_ffu_ack                 (lsu_ffu_ack),
           .lsu_ffu_blk_asi_e           (lsu_ffu_blk_asi_e),
           .lsu_ffu_flush_pipe_w        (lsu_ffu_flush_pipe_w),
           .lsu_ffu_ld_data             (lsu_ffu_ld_data[63:0]),
           .lsu_ffu_ld_vld              (lsu_ffu_ld_vld),
           .lsu_ffu_stb_full0           (lsu_ffu_stb_full0),
           .lsu_ffu_stb_full1           (lsu_ffu_stb_full1),
           .lsu_ffu_stb_full2           (lsu_ffu_stb_full2),
           .lsu_ffu_stb_full3           (lsu_ffu_stb_full3),
           .lsu_ictag_mrgn              (lsu_ictag_mrgn[3:0]),
           .lsu_ifu_asi_addr            (lsu_ifu_asi_addr[17:0]),
           .lsu_ifu_asi_load            (lsu_ifu_asi_load),
           .lsu_ifu_asi_state           (lsu_ifu_asi_state[7:0]),
           .lsu_ifu_asi_thrid           (lsu_ifu_asi_thrid[1:0]),
           .lsu_ifu_asi_vld             (lsu_ifu_asi_vld),
           .lsu_ifu_cpxpkt_i1           (lsu_ifu_cpxpkt_i1[`CPX_VLD-1:0]),
           .lsu_ifu_cpxpkt_vld_i1       (lsu_ifu_cpxpkt_vld_i1),
           .lsu_ifu_dc_parity_error_w2  (lsu_ifu_dc_parity_error_w2),
           .lsu_ifu_dcache_data_perror  (lsu_ifu_dcache_data_perror),
           .lsu_ifu_dcache_tag_perror   (lsu_ifu_dcache_tag_perror),
           .lsu_ifu_direct_map_l1       (lsu_ifu_direct_map_l1),
           .lsu_ifu_error_tid           (lsu_ifu_error_tid[1:0]),
           .lsu_ifu_flush_pipe_w        (lsu_ifu_flush_pipe_w),
           .lsu_ifu_icache_en           (lsu_ifu_icache_en[3:0]),
           .lsu_ifu_io_error            (lsu_ifu_io_error),
           .lsu_ifu_itlb_en             (lsu_ifu_itlb_en[3:0]),
           .lsu_ifu_l2_corr_error       (lsu_ifu_l2_corr_error),
           .lsu_ifu_l2_unc_error        (lsu_ifu_l2_unc_error),
           .lsu_ifu_ld_icache_index     (lsu_ifu_ld_icache_index[11:5]),
           .lsu_ifu_ld_pcxpkt_tid       (lsu_ifu_ld_pcxpkt_tid[1:0]),
           .lsu_ifu_ld_pcxpkt_vld       (lsu_ifu_ld_pcxpkt_vld),
           .lsu_ifu_ldst_cmplt          (lsu_ifu_ldst_cmplt[3:0]),
           .lsu_ifu_ldst_miss_w         (lsu_ifu_ldst_miss_w),
           .lsu_ifu_ldsta_internal_e    (lsu_ifu_ldsta_internal_e),
           .lsu_ifu_pcxpkt_ack_d        (lsu_ifu_pcxpkt_ack_d),
           .lsu_ifu_stallreq            (lsu_ifu_stallreq),
           .lsu_ifu_stbcnt0             (lsu_ifu_stbcnt0[3:0]),
           .lsu_ifu_stbcnt1             (lsu_ifu_stbcnt1[3:0]),
           .lsu_ifu_stbcnt2             (lsu_ifu_stbcnt2[3:0]),
           .lsu_ifu_stbcnt3             (lsu_ifu_stbcnt3[3:0]),
           .lsu_ifu_stxa_data           (lsu_ifu_stxa_data[47:0]),
           .lsu_ifu_tlb_data_su         (lsu_ifu_tlb_data_su),
           .lsu_ifu_tlb_data_ue         (lsu_ifu_tlb_data_ue),
           .lsu_ifu_tlb_tag_ue          (lsu_ifu_tlb_tag_ue),
           .lsu_itlb_mrgn               (lsu_itlb_mrgn[7:0]),
           .lsu_mamem_mrgn              (lsu_mamem_mrgn[3:0]),
           .lsu_mmu_defr_trp_taken_g    (lsu_mmu_defr_trp_taken_g),
           .lsu_mmu_flush_pipe_w        (lsu_mmu_flush_pipe_w),
           .lsu_mmu_rs3_data_g          (lsu_mmu_rs3_data_g[63:0]),
           .lsu_pid_state0              (lsu_pid_state0[2:0]),
           .lsu_pid_state1              (lsu_pid_state1[2:0]),
           .lsu_pid_state2              (lsu_pid_state2[2:0]),
           .lsu_pid_state3              (lsu_pid_state3[2:0]),
           .lsu_spu_asi_state_e         (lsu_spu_asi_state_e[7:0]),
           .lsu_spu_early_flush_g       (lsu_spu_early_flush_g),
           .lsu_spu_ldst_ack            (lsu_spu_ldst_ack),
           .lsu_spu_stb_empty           (lsu_spu_stb_empty[3:0]),
           .lsu_spu_strm_ack_cmplt      (lsu_spu_strm_ack_cmplt[1:0]),
           .lsu_t0_pctxt_state          (lsu_t0_pctxt_state[12:0]),
           .lsu_t1_pctxt_state          (lsu_t1_pctxt_state[12:0]),
           .lsu_t2_pctxt_state          (lsu_t2_pctxt_state[12:0]),
           .lsu_t3_pctxt_state          (lsu_t3_pctxt_state[12:0]),
           .lsu_tlu_async_tid_w2        (lsu_tlu_async_tid_w2[1:0]),
           .lsu_tlu_async_ttype_vld_w2  (lsu_tlu_async_ttype_vld_w2),
           .lsu_tlu_async_ttype_w2      (lsu_tlu_async_ttype_w2[6:0]),
           .lsu_tlu_cpx_req             (lsu_tlu_cpx_req[3:0]),
           .lsu_tlu_cpx_vld             (lsu_tlu_cpx_vld),
           .lsu_tlu_daccess_excptn_g    (lsu_tlu_daccess_excptn_g),
           .lsu_tlu_dcache_miss_w2      (lsu_tlu_dcache_miss_w2[3:0]),
           .lsu_tlu_defr_trp_taken_g    (lsu_tlu_defr_trp_taken_g),
           .lsu_tlu_dmmu_miss_g         (lsu_tlu_dmmu_miss_g),
           .lsu_tlu_dside_ctxt_m        (lsu_tlu_dside_ctxt_m[12:0]),
           .lsu_tlu_dtlb_done           (lsu_tlu_dtlb_done),
           .lsu_tlu_early_flush2_w      (lsu_tlu_early_flush2_w),
           .lsu_tlu_early_flush_w       (lsu_tlu_early_flush_w),
           .lsu_tlu_intpkt              (lsu_tlu_intpkt[17:0]),
           .lsu_tlu_l2_dmiss            (lsu_tlu_l2_dmiss[3:0]),
           .lsu_tlu_ldst_va_m           (lsu_tlu_ldst_va_m[9:0]),
           .lsu_tlu_misalign_addr_ldst_atm_m(lsu_tlu_misalign_addr_ldst_atm_m),
           .lsu_tlu_pctxt_m             (lsu_tlu_pctxt_m[12:0]),
           .lsu_tlu_pcxpkt_ack          (lsu_tlu_pcxpkt_ack),
           .lsu_tlu_rs3_data_g          (lsu_tlu_rs3_data_g[63:0]),
           .lsu_tlu_rsr_data_e          (lsu_tlu_rsr_data_e[7:0]),
           .lsu_tlu_stb_full_w2         (lsu_tlu_stb_full_w2[3:0]),
           .lsu_tlu_thrid_d             (lsu_tlu_thrid_d[1:0]),
           .lsu_tlu_tlb_access_tid_m    (lsu_tlu_tlb_access_tid_m[1:0]),
           .lsu_tlu_tlb_asi_state_m     (lsu_tlu_tlb_asi_state_m[7:0]),
           .lsu_tlu_tlb_dmp_va_m        (lsu_tlu_tlb_dmp_va_m[47:13]),
           .lsu_tlu_tlb_ld_inst_m       (lsu_tlu_tlb_ld_inst_m),
           .lsu_tlu_tlb_ldst_va_m       (lsu_tlu_tlb_ldst_va_m[10:0]),
           .lsu_tlu_tlb_st_inst_m       (lsu_tlu_tlb_st_inst_m),
           .lsu_tlu_ttype_m2            (lsu_tlu_ttype_m2[8:0]),
           .lsu_tlu_ttype_vld_m2        (lsu_tlu_ttype_vld_m2),
           .lsu_tlu_wsr_inst_e          (lsu_tlu_wsr_inst_e),
           .mbist_dcache_data_in        (mbist_dcache_data_in[71:0]),
           .spc_efc_dfuse_data          (spc_efc_dfuse_data),
           .spc_pcx_atom_pq             (spc_pcx_atom_pq),
           .spc_pcx_data_pa             (spc_pcx_data_pa[`PCX_WIDTH-1:0]),
           .spc_pcx_req_pq              (spc_pcx_req_pq[4:0]),
           .lsu_asi_state               (lsu_asi_state[7:0]),
           .lsu_ifu_err_addr            (lsu_ifu_err_addr[47:4]),
           .lsu_sscan_data              (lsu_sscan_data[15:0]),
           .ifu_tlu_inst_vld_m_bf1      (ifu_tlu_inst_vld_m_bf1),
           .lsu_ffu_bld_cnt_w           (lsu_ffu_bld_cnt_w[2:0]),
           .lsu_tlu_nucleus_ctxt_m      (lsu_tlu_nucleus_ctxt_m),
           .lsu_tlu_tte_pg_sz_g         (lsu_tlu_tte_pg_sz_g[2:0]),
           .lsu_tlu_squash_va_oor_m     (lsu_tlu_squash_va_oor_m),
           .lsu_tlu_wtchpt_trp_g        (lsu_tlu_wtchpt_trp_g),
           .lsu_tlu_daccess_prot_g      (lsu_tlu_daccess_prot_g),
           .lsu_tlu_priv_action_g       (lsu_tlu_priv_action_g),
           // Inputs
           .bist_ctl_reg_out            (bist_ctl_reg_out[10:0]),
           .const_cpuid                 (const_cpuid[2:0]),
           .ctu_sscan_tid               (ctu_sscan_tid[3:0]),
           .efc_spc_dfuse_ashift        (efc_spc_dfuse_ashift),
           .efc_spc_dfuse_data          (efc_spc_dfuse_data),
           .efc_spc_dfuse_dshift        (efc_spc_dfuse_dshift),
           .efc_spc_fuse_clk1           (efc_spc_fuse_clk1),
           .efc_spc_fuse_clk2           (efc_spc_fuse_clk2),
           .exu_lsu_rs2_data_e          (exu_lsu_rs2_data_e[63:0]),
           .exu_lsu_rs3_data_e          (exu_lsu_rs3_data_e[63:0]),
           .exu_tlu_misalign_addr_jmpl_rtn_m(exu_tlu_misalign_addr_jmpl_rtn_m),
           .exu_tlu_va_oor_m            (exu_tlu_va_oor_m),
           .ffu_lsu_blk_st_e            (ffu_lsu_blk_st_e),
           .ffu_lsu_blk_st_va_e         (ffu_lsu_blk_st_va_e[5:3]),
           .ffu_lsu_fpop_rq_vld         (ffu_lsu_fpop_rq_vld),
           .ffu_lsu_kill_fst_w          (ffu_lsu_kill_fst_w),
           .ifu_lsu_alt_space_d         (ifu_lsu_alt_space_d),
           .ifu_lsu_alt_space_e         (ifu_lsu_alt_space_e),
           .ifu_lsu_asi_ack             (ifu_lsu_asi_ack),
           .ifu_lsu_asi_rd_unc          (ifu_lsu_asi_rd_unc),
           .ifu_lsu_casa_e              (ifu_lsu_casa_e),
           .ifu_lsu_destid_s            (ifu_lsu_destid_s[2:0]),
           .ifu_lsu_fwd_data_vld        (ifu_lsu_fwd_data_vld),
           .ifu_lsu_fwd_wr_ack          (ifu_lsu_fwd_wr_ack),
           .ifu_lsu_ibuf_busy           (ifu_lsu_ibuf_busy),
           .ifu_lsu_imm_asi_d           (ifu_lsu_imm_asi_d[7:0]),
           .ifu_lsu_imm_asi_vld_d       (ifu_lsu_imm_asi_vld_d),
           .ifu_lsu_inv_clear           (ifu_lsu_inv_clear),
           .ifu_lsu_ld_inst_e           (ifu_lsu_ld_inst_e),
           .ifu_lsu_ldst_dbl_e          (ifu_lsu_ldst_dbl_e),
           .ifu_lsu_ldst_fp_e           (ifu_lsu_ldst_fp_e),
           .ifu_lsu_ldst_size_e         (ifu_lsu_ldst_size_e[1:0]),
           .ifu_lsu_ldstub_e            (ifu_lsu_ldstub_e),
           .ifu_lsu_ldxa_data_vld_w2    (ifu_lsu_ldxa_data_vld_w2),
           .ifu_lsu_ldxa_data_w2        (ifu_lsu_ldxa_data_w2[63:0]),
           .ifu_lsu_ldxa_illgl_va_w2    (ifu_lsu_ldxa_illgl_va_w2),
           .ifu_lsu_ldxa_tid_w2         (ifu_lsu_ldxa_tid_w2[1:0]),
           .ifu_lsu_memref_d            (ifu_lsu_memref_d),
           .ifu_lsu_nceen               (ifu_lsu_nceen[3:0]),
           .ifu_lsu_pcxpkt_e            (ifu_lsu_pcxpkt_e[51:0]),
           .ifu_lsu_pcxreq_d            (ifu_lsu_pcxreq_d),
           .ifu_lsu_pref_inst_e         (ifu_lsu_pref_inst_e),
           .ifu_lsu_rd_e                (ifu_lsu_rd_e[4:0]),
           .ifu_lsu_sign_ext_e          (ifu_lsu_sign_ext_e),
           .ifu_lsu_st_inst_e           (ifu_lsu_st_inst_e),
           .ifu_lsu_swap_e              (ifu_lsu_swap_e),
           .ifu_lsu_thrid_s             (ifu_lsu_thrid_s[1:0]),
           .ifu_tlu_flsh_inst_e         (ifu_tlu_flsh_inst_e),
           .ifu_tlu_flush_m             (ifu_tlu_flush_m),
           .ifu_tlu_inst_vld_m          (ifu_tlu_inst_vld_m),
           .ifu_tlu_mb_inst_e           (ifu_tlu_mb_inst_e),
           .ifu_tlu_sraddr_d            (ifu_tlu_sraddr_d[6:0]),
           .ifu_tlu_thrid_e             (ifu_tlu_thrid_e[1:0]),
           .mbist_dcache_index          (mbist_dcache_index[6:0]),
           .mbist_dcache_read           (mbist_dcache_read),
           .mbist_dcache_way            (mbist_dcache_way[1:0]),
           .mbist_dcache_word           (mbist_dcache_word),
           .mbist_dcache_write          (mbist_dcache_write),
           .mbist_write_data            (mbist_write_data[7:0]),
           .mem_write_disable           (mem_write_disable),
           .mux_drive_disable           (mux_drive_disable),
           .pcx_spc_grant_px            (pcx_spc_grant_px[4:0]),
           .se                          (se),
           .sehold                      (sehold),
           .spu_lsu_ldxa_data_vld_w2    (spu_lsu_ldxa_data_vld_w2),
           .spu_lsu_ldxa_data_w2        (spu_lsu_ldxa_data_w2[63:0]),
           .spu_lsu_ldxa_illgl_va_w2    (spu_lsu_ldxa_illgl_va_w2),
           .spu_lsu_ldxa_tid_w2         (spu_lsu_ldxa_tid_w2[1:0]),
           .spu_lsu_stxa_ack            (spu_lsu_stxa_ack),
           .spu_lsu_stxa_ack_tid        (spu_lsu_stxa_ack_tid[1:0]),
           .spu_lsu_unc_error_w2        (spu_lsu_unc_error_w2),
           .testmode_l                  (testmode_l),
           .tlu_dsfsr_flt_vld           (tlu_dsfsr_flt_vld[3:0]),
           .tlu_dtlb_data_rd_g          (tlu_dtlb_data_rd_g),
           .tlu_dtlb_dmp_actxt_g        (tlu_dtlb_dmp_actxt_g),
           .tlu_dtlb_dmp_all_g          (tlu_dtlb_dmp_all_g),
           .tlu_dtlb_dmp_nctxt_g        (tlu_dtlb_dmp_nctxt_g),
           .tlu_dtlb_dmp_pctxt_g        (tlu_dtlb_dmp_pctxt_g),
           .tlu_dtlb_dmp_sctxt_g        (tlu_dtlb_dmp_sctxt_g),
           .tlu_dtlb_dmp_vld_g          (tlu_dtlb_dmp_vld_g),
           .tlu_dtlb_invalidate_all_g   (tlu_dtlb_invalidate_all_g),
           .tlu_dtlb_rw_index_g         (tlu_dtlb_rw_index_g[5:0]),
           .tlu_dtlb_rw_index_vld_g     (tlu_dtlb_rw_index_vld_g),
           .tlu_dtlb_tag_rd_g           (tlu_dtlb_tag_rd_g),
           .tlu_dtlb_tte_data_w2        (tlu_dtlb_tte_data_w2[42:0]),
           .tlu_dtlb_tte_tag_w2         (tlu_dtlb_tte_tag_w2[58:0]),
           .tlu_early_flush_pipe2_w     (tlu_early_flush_pipe2_w),
           .tlu_early_flush_pipe_w      (tlu_early_flush_pipe_w),
           .tlu_exu_early_flush_pipe_w  (tlu_exu_early_flush_pipe_w),
           .tlu_idtlb_dmp_key_g         (tlu_idtlb_dmp_key_g[40:0]),
           .tlu_idtlb_dmp_thrid_g       (tlu_idtlb_dmp_thrid_g[1:0]),
           .tlu_lsu_asi_m               (tlu_lsu_asi_m[7:0]),
           .tlu_lsu_asi_update_m        (tlu_lsu_asi_update_m),
           .tlu_lsu_int_ld_ill_va_w2    (tlu_lsu_int_ld_ill_va_w2),
           .tlu_lsu_int_ldxa_data_w2    (tlu_lsu_int_ldxa_data_w2[63:0]),
           .tlu_lsu_int_ldxa_vld_w2     (tlu_lsu_int_ldxa_vld_w2),
           .tlu_lsu_ldxa_async_data_vld (tlu_lsu_ldxa_async_data_vld),
           .tlu_lsu_ldxa_tid_w2         (tlu_lsu_ldxa_tid_w2[1:0]),
           .tlu_lsu_pcxpkt              (tlu_lsu_pcxpkt[25:0]),
           .tlu_lsu_pstate_am           (tlu_lsu_pstate_am[3:0]),
           .tlu_lsu_pstate_cle          (tlu_lsu_pstate_cle[3:0]),
           .tlu_lsu_pstate_priv         (tlu_lsu_pstate_priv[3:0]),
           .tlu_lsu_redmode             (tlu_lsu_redmode[3:0]),
           .tlu_lsu_redmode_rst_d1      (tlu_lsu_redmode_rst_d1[3:0]),
           .tlu_lsu_stxa_ack            (tlu_lsu_stxa_ack),
           .tlu_lsu_stxa_ack_tid        (tlu_lsu_stxa_ack_tid[1:0]),
           .tlu_lsu_tid_m               (tlu_lsu_tid_m[1:0]),
           .tlu_lsu_tl_zero             (tlu_lsu_tl_zero[3:0]),
           .spu_lsu_ldst_pckt           (spu_lsu_ldst_pckt[`PCX_WIDTH-1:0]),
           .exu_lsu_ldst_va_e           (exu_lsu_ldst_va_e[47:0]),
           .exu_lsu_early_va_e          (exu_lsu_early_va_e[10:3]),
           .ffu_lsu_data                (ffu_lsu_data[80:0])); 

`endif //  `ifdef FPGA_SYN_NO_SPU

`ifdef FPGA_SYN_NO_SPU

   sparc_exu exu   (
                 .short_si0              (short_scan0_2),
                 .short_so0              (short_scan0_3),
                 .short_si1 (short_scan1_2),
                 .short_so1 (short_scan1_3),
                 .si0 (scan0_2),
                 .so0 (scan0_3),
                 // reset stuff
                 .grst_l                (spc_grst_l),
                 .arst_l                (cmp_arst_l),
                 .mul_exu_data_g (mul_data_out[63:0]),
                 .ifu_tlu_wsr_inst_d (ifu_exu_wsr_inst_d),
                 //
                 .exu_tlu_ue_trap_m     (),
                 
		             /*AUTOINST*/
                 // Outputs
                 .exu_ffu_wsr_inst_e    (exu_ffu_wsr_inst_e),
                 .exu_ifu_brpc_e        (exu_ifu_brpc_e[47:0]),
                 .exu_ifu_cc_d          (exu_ifu_cc_d[7:0]),
                 .exu_ifu_ecc_ce_m      (exu_ifu_ecc_ce_m),
                 .exu_ifu_ecc_ue_m      (exu_ifu_ecc_ue_m),
                 .exu_ifu_err_reg_m     (exu_ifu_err_reg_m[7:0]),
                 .exu_ifu_inj_ack       (exu_ifu_inj_ack),
                 .exu_ifu_longop_done_g (exu_ifu_longop_done_g[3:0]),
                 .exu_ifu_oddwin_s      (exu_ifu_oddwin_s[3:0]),
                 .exu_ifu_regn_e        (exu_ifu_regn_e),
                 .exu_ifu_regz_e        (exu_ifu_regz_e),
                 .exu_ifu_spill_e       (exu_ifu_spill_e),
                 .exu_ifu_va_oor_m      (exu_ifu_va_oor_m),
                 .exu_lsu_early_va_e    (exu_lsu_early_va_e[10:3]),
                 .exu_lsu_ldst_va_e     (exu_lsu_ldst_va_e[47:0]),
                 .exu_lsu_priority_trap_m(exu_lsu_priority_trap_m),
                 .exu_lsu_rs2_data_e    (exu_lsu_rs2_data_e[63:0]),
                 .exu_lsu_rs3_data_e    (exu_lsu_rs3_data_e[63:0]),
                 .exu_mmu_early_va_e    (exu_mmu_early_va_e[7:0]),
                 .exu_mul_input_vld     (exu_mul_input_vld),
                 .exu_mul_rs1_data      (exu_mul_rs1_data[63:0]),
                 .exu_mul_rs2_data      (exu_mul_rs2_data[63:0]),
                 .exu_spu_rs3_data_e    (),
                 .exu_tlu_ccr0_w        (exu_tlu_ccr0_w[7:0]),
                 .exu_tlu_ccr1_w        (exu_tlu_ccr1_w[7:0]),
                 .exu_tlu_ccr2_w        (exu_tlu_ccr2_w[7:0]),
                 .exu_tlu_ccr3_w        (exu_tlu_ccr3_w[7:0]),
                 .exu_tlu_cwp0_w        (exu_tlu_cwp0_w[2:0]),
                 .exu_tlu_cwp1_w        (exu_tlu_cwp1_w[2:0]),
                 .exu_tlu_cwp2_w        (exu_tlu_cwp2_w[2:0]),
                 .exu_tlu_cwp3_w        (exu_tlu_cwp3_w[2:0]),
                 .exu_tlu_cwp_cmplt     (exu_tlu_cwp_cmplt),
                 .exu_tlu_cwp_cmplt_tid (exu_tlu_cwp_cmplt_tid[1:0]),
                 .exu_tlu_cwp_retry     (exu_tlu_cwp_retry),
                 .exu_tlu_misalign_addr_jmpl_rtn_m(exu_tlu_misalign_addr_jmpl_rtn_m),
                 .exu_tlu_spill         (exu_tlu_spill),
                 .exu_tlu_spill_other   (exu_tlu_spill_other),
                 .exu_tlu_spill_tid     (exu_tlu_spill_tid[1:0]),
                 .exu_tlu_spill_wtype   (exu_tlu_spill_wtype[2:0]),
                 .exu_tlu_ttype_m       (exu_tlu_ttype_m[8:0]),
                 .exu_tlu_ttype_vld_m   (exu_tlu_ttype_vld_m),
                 .exu_tlu_va_oor_jl_ret_m(exu_tlu_va_oor_jl_ret_m),
                 .exu_tlu_va_oor_m      (exu_tlu_va_oor_m),
                 .exu_tlu_wsr_data_m    (exu_tlu_wsr_data_m[63:0]),
                 .exu_ifu_err_synd_m    (exu_ifu_err_synd_m[7:0]),
                 // Inputs
                 .mux_drive_disable     (mux_drive_disable),
                 .mem_write_disable     (mem_write_disable),
                 .ffu_exu_rsr_data_m    (ffu_exu_rsr_data_m[63:0]),
                 .ifu_exu_addr_mask_d   (ifu_exu_addr_mask_d),
                 .ifu_exu_aluop_d       (ifu_exu_aluop_d[2:0]),
                 .ifu_exu_casa_d        (ifu_exu_casa_d),
                 .ifu_exu_dbrinst_d     (ifu_exu_dbrinst_d),
                 .ifu_exu_disable_ce_e  (ifu_exu_disable_ce_e),
                 .ifu_exu_dontmv_regz0_e(ifu_exu_dontmv_regz0_e),
                 .ifu_exu_dontmv_regz1_e(ifu_exu_dontmv_regz1_e),
                 .ifu_exu_ecc_mask      (ifu_exu_ecc_mask[7:0]),
                 .ifu_exu_enshift_d     (ifu_exu_enshift_d),
                 .ifu_exu_flushw_e      (ifu_exu_flushw_e),
                 .ifu_exu_ialign_d      (ifu_exu_ialign_d),
                 .ifu_exu_imm_data_d    (ifu_exu_imm_data_d[31:0]),
                 .ifu_exu_inj_irferr    (ifu_exu_inj_irferr),
                 .ifu_exu_inst_vld_e    (ifu_exu_inst_vld_e),
                 .ifu_exu_inst_vld_w    (ifu_exu_inst_vld_w),
                 .ifu_exu_invert_d      (ifu_exu_invert_d),
                 .ifu_exu_kill_e        (ifu_exu_kill_e),
                 .ifu_exu_muldivop_d    (ifu_exu_muldivop_d[4:0]),
                 .ifu_exu_muls_d        (ifu_exu_muls_d),
                 .ifu_exu_nceen_e       (ifu_exu_nceen_e),
                 .ifu_exu_pc_d          (ifu_exu_pc_d[47:0]),
                 .ifu_exu_pcver_e       (ifu_exu_pcver_e[63:0]),
                 .ifu_exu_range_check_jlret_d(ifu_exu_range_check_jlret_d),
                 .ifu_exu_range_check_other_d(ifu_exu_range_check_other_d),
                 .ifu_exu_rd_d          (ifu_exu_rd_d[4:0]),
                 .ifu_exu_rd_exusr_e    (ifu_exu_rd_exusr_e),
                 .ifu_exu_rd_ffusr_e    (ifu_exu_rd_ffusr_e),
                 .ifu_exu_rd_ifusr_e    (ifu_exu_rd_ifusr_e),
                 .ifu_exu_ren1_s        (ifu_exu_ren1_s),
                 .ifu_exu_ren2_s        (ifu_exu_ren2_s),
                 .ifu_exu_ren3_s        (ifu_exu_ren3_s),
                 .ifu_exu_restore_d     (ifu_exu_restore_d),
                 .ifu_exu_restored_e    (ifu_exu_restored_e),
                 .ifu_exu_return_d      (ifu_exu_return_d),
                 .ifu_exu_rs1_s         (ifu_exu_rs1_s[4:0]),
                 .ifu_exu_rs1_vld_d     (ifu_exu_rs1_vld_d),
                 .ifu_exu_rs2_s         (ifu_exu_rs2_s[4:0]),
                 .ifu_exu_rs2_vld_d     (ifu_exu_rs2_vld_d),
                 .ifu_exu_rs3_s         (ifu_exu_rs3_s[4:0]),
                 .ifu_exu_rs3e_vld_d    (ifu_exu_rs3e_vld_d),
                 .ifu_exu_rs3o_vld_d    (ifu_exu_rs3o_vld_d),
                 .ifu_exu_save_d        (ifu_exu_save_d),
                 .ifu_exu_saved_e       (ifu_exu_saved_e),
                 .ifu_exu_setcc_d       (ifu_exu_setcc_d),
                 .ifu_exu_sethi_inst_d  (ifu_exu_sethi_inst_d),
                 .ifu_exu_shiftop_d     (ifu_exu_shiftop_d[2:0]),
                 .ifu_exu_tagop_d       (ifu_exu_tagop_d),
                 .ifu_exu_tcc_e         (ifu_exu_tcc_e),
                 .ifu_exu_tid_s2        (ifu_exu_tid_s2[1:0]),
                 .ifu_exu_ttype_vld_m   (ifu_exu_ttype_vld_m),
                 .ifu_exu_tv_d          (ifu_exu_tv_d),
                 .ifu_exu_use_rsr_e_l   (ifu_exu_use_rsr_e_l),
                 .ifu_exu_usecin_d      (ifu_exu_usecin_d),
                 .ifu_exu_useimm_d      (ifu_exu_useimm_d),
                 .ifu_exu_wen_d         (ifu_exu_wen_d),
                 .ifu_tlu_flush_m       (ifu_tlu_flush_m),
                 .ifu_tlu_sraddr_d      (ifu_tlu_sraddr_d[6:0]),
                 .lsu_exu_dfill_data_g  (lsu_exu_dfill_data_g[63:0]),
                 .lsu_exu_dfill_vld_g   (lsu_exu_dfill_vld_g),
                 .lsu_exu_flush_pipe_w  (lsu_exu_flush_pipe_w),
                 .lsu_exu_ldst_miss_g2  (lsu_exu_ldst_miss_g2),
                 .lsu_exu_ldxa_data_g   (lsu_exu_ldxa_data_g[63:0]),
                 .lsu_exu_ldxa_m        (lsu_exu_ldxa_m),
                 .lsu_exu_rd_m          (lsu_exu_rd_m[4:0]),
                 .lsu_exu_st_dtlb_perr_g(lsu_exu_st_dtlb_perr_g),
                 .lsu_exu_thr_m         (lsu_exu_thr_m[1:0]),
                 .mul_exu_ack           (mul_exu_ack),
                 .rclk                  (rclk),
                 .se                    (se),
                 .sehold                (sehold),
                 .tlu_exu_agp           (tlu_exu_agp[1:0]),
                 .tlu_exu_agp_swap      (tlu_exu_agp_swap),
                 .tlu_exu_agp_tid       (tlu_exu_agp_tid[1:0]),
                 .tlu_exu_ccr_m         (tlu_exu_ccr_m[7:0]),
                 .tlu_exu_cwp_m         (tlu_exu_cwp_m[2:0]),
                 .tlu_exu_cwp_retry_m   (tlu_exu_cwp_retry_m),
                 .tlu_exu_cwpccr_update_m(tlu_exu_cwpccr_update_m),
                 .tlu_exu_pic_onebelow_m(tlu_exu_pic_onebelow_m),
                 .tlu_exu_pic_twobelow_m(tlu_exu_pic_twobelow_m),
                 .tlu_exu_priv_trap_m   (tlu_exu_priv_trap_m),
                 .tlu_exu_rsr_data_m    (tlu_exu_rsr_data_m[63:0]));

`else
   
sparc_exu exu   (
                 .short_si0              (short_scan0_2),
                 .short_so0              (short_scan0_3),
                 .short_si1 (short_scan1_2),
                 .short_so1 (short_scan1_3),
                 .si0 (scan0_2),
                 .so0 (scan0_3),
                 // reset stuff
                 .grst_l                (spc_grst_l),
                 .arst_l                (cmp_arst_l),
                 .mul_exu_data_g (mul_data_out[63:0]),
                 .ifu_tlu_wsr_inst_d (ifu_exu_wsr_inst_d),
                 //
                 .exu_tlu_ue_trap_m     (),
                 
		             /*AUTOINST*/
                 // Outputs
                 .exu_ffu_wsr_inst_e    (exu_ffu_wsr_inst_e),
                 .exu_ifu_brpc_e        (exu_ifu_brpc_e[47:0]),
                 .exu_ifu_cc_d          (exu_ifu_cc_d[7:0]),
                 .exu_ifu_ecc_ce_m      (exu_ifu_ecc_ce_m),
                 .exu_ifu_ecc_ue_m      (exu_ifu_ecc_ue_m),
                 .exu_ifu_err_reg_m     (exu_ifu_err_reg_m[7:0]),
                 .exu_ifu_inj_ack       (exu_ifu_inj_ack),
                 .exu_ifu_longop_done_g (exu_ifu_longop_done_g[3:0]),
                 .exu_ifu_oddwin_s      (exu_ifu_oddwin_s[3:0]),
                 .exu_ifu_regn_e        (exu_ifu_regn_e),
                 .exu_ifu_regz_e        (exu_ifu_regz_e),
                 .exu_ifu_spill_e       (exu_ifu_spill_e),
                 .exu_ifu_va_oor_m      (exu_ifu_va_oor_m),
                 .exu_lsu_early_va_e    (exu_lsu_early_va_e[10:3]),
                 .exu_lsu_ldst_va_e     (exu_lsu_ldst_va_e[47:0]),
                 .exu_lsu_priority_trap_m(exu_lsu_priority_trap_m),
                 .exu_lsu_rs2_data_e    (exu_lsu_rs2_data_e[63:0]),
                 .exu_lsu_rs3_data_e    (exu_lsu_rs3_data_e[63:0]),
                 .exu_mmu_early_va_e    (exu_mmu_early_va_e[7:0]),
                 .exu_mul_input_vld     (exu_mul_input_vld),
                 .exu_mul_rs1_data      (exu_mul_rs1_data[63:0]),
                 .exu_mul_rs2_data      (exu_mul_rs2_data[63:0]),
                 .exu_spu_rs3_data_e    (exu_spu_rs3_data_e[63:0]),
                 .exu_tlu_ccr0_w        (exu_tlu_ccr0_w[7:0]),
                 .exu_tlu_ccr1_w        (exu_tlu_ccr1_w[7:0]),
                 .exu_tlu_ccr2_w        (exu_tlu_ccr2_w[7:0]),
                 .exu_tlu_ccr3_w        (exu_tlu_ccr3_w[7:0]),
                 .exu_tlu_cwp0_w        (exu_tlu_cwp0_w[2:0]),
                 .exu_tlu_cwp1_w        (exu_tlu_cwp1_w[2:0]),
                 .exu_tlu_cwp2_w        (exu_tlu_cwp2_w[2:0]),
                 .exu_tlu_cwp3_w        (exu_tlu_cwp3_w[2:0]),
                 .exu_tlu_cwp_cmplt     (exu_tlu_cwp_cmplt),
                 .exu_tlu_cwp_cmplt_tid (exu_tlu_cwp_cmplt_tid[1:0]),
                 .exu_tlu_cwp_retry     (exu_tlu_cwp_retry),
                 .exu_tlu_misalign_addr_jmpl_rtn_m(exu_tlu_misalign_addr_jmpl_rtn_m),
                 .exu_tlu_spill         (exu_tlu_spill),
                 .exu_tlu_spill_other   (exu_tlu_spill_other),
                 .exu_tlu_spill_tid     (exu_tlu_spill_tid[1:0]),
                 .exu_tlu_spill_wtype   (exu_tlu_spill_wtype[2:0]),
                 .exu_tlu_ttype_m       (exu_tlu_ttype_m[8:0]),
                 .exu_tlu_ttype_vld_m   (exu_tlu_ttype_vld_m),
                 .exu_tlu_va_oor_jl_ret_m(exu_tlu_va_oor_jl_ret_m),
                 .exu_tlu_va_oor_m      (exu_tlu_va_oor_m),
                 .exu_tlu_wsr_data_m    (exu_tlu_wsr_data_m[63:0]),
                 .exu_ifu_err_synd_m    (exu_ifu_err_synd_m[7:0]),
                 // Inputs
                 .mux_drive_disable     (mux_drive_disable),
                 .mem_write_disable     (mem_write_disable),
                 .ffu_exu_rsr_data_m    (ffu_exu_rsr_data_m[63:0]),
                 .ifu_exu_addr_mask_d   (ifu_exu_addr_mask_d),
                 .ifu_exu_aluop_d       (ifu_exu_aluop_d[2:0]),
                 .ifu_exu_casa_d        (ifu_exu_casa_d),
                 .ifu_exu_dbrinst_d     (ifu_exu_dbrinst_d),
                 .ifu_exu_disable_ce_e  (ifu_exu_disable_ce_e),
                 .ifu_exu_dontmv_regz0_e(ifu_exu_dontmv_regz0_e),
                 .ifu_exu_dontmv_regz1_e(ifu_exu_dontmv_regz1_e),
                 .ifu_exu_ecc_mask      (ifu_exu_ecc_mask[7:0]),
                 .ifu_exu_enshift_d     (ifu_exu_enshift_d),
                 .ifu_exu_flushw_e      (ifu_exu_flushw_e),
                 .ifu_exu_ialign_d      (ifu_exu_ialign_d),
                 .ifu_exu_imm_data_d    (ifu_exu_imm_data_d[31:0]),
                 .ifu_exu_inj_irferr    (ifu_exu_inj_irferr),
                 .ifu_exu_inst_vld_e    (ifu_exu_inst_vld_e),
                 .ifu_exu_inst_vld_w    (ifu_exu_inst_vld_w),
                 .ifu_exu_invert_d      (ifu_exu_invert_d),
                 .ifu_exu_kill_e        (ifu_exu_kill_e),
                 .ifu_exu_muldivop_d    (ifu_exu_muldivop_d[4:0]),
                 .ifu_exu_muls_d        (ifu_exu_muls_d),
                 .ifu_exu_nceen_e       (ifu_exu_nceen_e),
                 .ifu_exu_pc_d          (ifu_exu_pc_d[47:0]),
                 .ifu_exu_pcver_e       (ifu_exu_pcver_e[63:0]),
                 .ifu_exu_range_check_jlret_d(ifu_exu_range_check_jlret_d),
                 .ifu_exu_range_check_other_d(ifu_exu_range_check_other_d),
                 .ifu_exu_rd_d          (ifu_exu_rd_d[4:0]),
                 .ifu_exu_rd_exusr_e    (ifu_exu_rd_exusr_e),
                 .ifu_exu_rd_ffusr_e    (ifu_exu_rd_ffusr_e),
                 .ifu_exu_rd_ifusr_e    (ifu_exu_rd_ifusr_e),
                 .ifu_exu_ren1_s        (ifu_exu_ren1_s),
                 .ifu_exu_ren2_s        (ifu_exu_ren2_s),
                 .ifu_exu_ren3_s        (ifu_exu_ren3_s),
                 .ifu_exu_restore_d     (ifu_exu_restore_d),
                 .ifu_exu_restored_e    (ifu_exu_restored_e),
                 .ifu_exu_return_d      (ifu_exu_return_d),
                 .ifu_exu_rs1_s         (ifu_exu_rs1_s[4:0]),
                 .ifu_exu_rs1_vld_d     (ifu_exu_rs1_vld_d),
                 .ifu_exu_rs2_s         (ifu_exu_rs2_s[4:0]),
                 .ifu_exu_rs2_vld_d     (ifu_exu_rs2_vld_d),
                 .ifu_exu_rs3_s         (ifu_exu_rs3_s[4:0]),
                 .ifu_exu_rs3e_vld_d    (ifu_exu_rs3e_vld_d),
                 .ifu_exu_rs3o_vld_d    (ifu_exu_rs3o_vld_d),
                 .ifu_exu_save_d        (ifu_exu_save_d),
                 .ifu_exu_saved_e       (ifu_exu_saved_e),
                 .ifu_exu_setcc_d       (ifu_exu_setcc_d),
                 .ifu_exu_sethi_inst_d  (ifu_exu_sethi_inst_d),
                 .ifu_exu_shiftop_d     (ifu_exu_shiftop_d[2:0]),
                 .ifu_exu_tagop_d       (ifu_exu_tagop_d),
                 .ifu_exu_tcc_e         (ifu_exu_tcc_e),
                 .ifu_exu_tid_s2        (ifu_exu_tid_s2[1:0]),
                 .ifu_exu_ttype_vld_m   (ifu_exu_ttype_vld_m),
                 .ifu_exu_tv_d          (ifu_exu_tv_d),
                 .ifu_exu_use_rsr_e_l   (ifu_exu_use_rsr_e_l),
                 .ifu_exu_usecin_d      (ifu_exu_usecin_d),
                 .ifu_exu_useimm_d      (ifu_exu_useimm_d),
                 .ifu_exu_wen_d         (ifu_exu_wen_d),
                 .ifu_tlu_flush_m       (ifu_tlu_flush_m),
                 .ifu_tlu_sraddr_d      (ifu_tlu_sraddr_d[6:0]),
                 .lsu_exu_dfill_data_g  (lsu_exu_dfill_data_g[63:0]),
                 .lsu_exu_dfill_vld_g   (lsu_exu_dfill_vld_g),
                 .lsu_exu_flush_pipe_w  (lsu_exu_flush_pipe_w),
                 .lsu_exu_ldst_miss_g2  (lsu_exu_ldst_miss_g2),
                 .lsu_exu_ldxa_data_g   (lsu_exu_ldxa_data_g[63:0]),
                 .lsu_exu_ldxa_m        (lsu_exu_ldxa_m),
                 .lsu_exu_rd_m          (lsu_exu_rd_m[4:0]),
                 .lsu_exu_st_dtlb_perr_g(lsu_exu_st_dtlb_perr_g),
                 .lsu_exu_thr_m         (lsu_exu_thr_m[1:0]),
                 .mul_exu_ack           (mul_exu_ack),
                 .rclk                  (rclk),
                 .se                    (se),
                 .sehold                (sehold),
                 .tlu_exu_agp           (tlu_exu_agp[1:0]),
                 .tlu_exu_agp_swap      (tlu_exu_agp_swap),
                 .tlu_exu_agp_tid       (tlu_exu_agp_tid[1:0]),
                 .tlu_exu_ccr_m         (tlu_exu_ccr_m[7:0]),
                 .tlu_exu_cwp_m         (tlu_exu_cwp_m[2:0]),
                 .tlu_exu_cwp_retry_m   (tlu_exu_cwp_retry_m),
                 .tlu_exu_cwpccr_update_m(tlu_exu_cwpccr_update_m),
                 .tlu_exu_pic_onebelow_m(tlu_exu_pic_onebelow_m),
                 .tlu_exu_pic_twobelow_m(tlu_exu_pic_twobelow_m),
                 .tlu_exu_priv_trap_m   (tlu_exu_priv_trap_m),
                 .tlu_exu_rsr_data_m    (tlu_exu_rsr_data_m[63:0]));

`endif
   
`ifdef FPGA_SYN_NO_SPU

      tlu tlu(
           .short_si0              (short_scan0_3),
           .short_si1              (short_scan1_3),
           .short_so0              (short_scan0_4),
           .short_so1              (short_scan1_4),
           .si0 (scan0_4),
           .si1 (scan1_1),
           .so0 (scan0_5),
           .so1 (scan1_2),
           .grst_l                (spc_grst_l),
           .arst_l                (cmp_arst_l),
	       .tlu_sftint_vld		    (tlu_ifu_sftint_vld[3:0]),
	       .ifu_tlu_swint_m		    (ifu_tlu_sftint_m),
           .exu_tlu_cwp0                (exu_tlu_cwp0_w[2:0]),
           .exu_tlu_cwp1                (exu_tlu_cwp1_w[2:0]),
           .exu_tlu_cwp2                (exu_tlu_cwp2_w[2:0]),
           .exu_tlu_cwp3                (exu_tlu_cwp3_w[2:0]),

           // fix for bug 5953
           .exu_tlu_ue_trap_m           (1'b0),

           // temporary fix for bug 5863
           // TBD: change for TO 2.0
	   // fixed for eco 6660
           .spu_tlu_rsrv_illgl_m        (1'b0),

           // new interface to the pib block
           .ifu_lsu_imm_asi_d           (ifu_tlu_imm_asi_d[8:0]),
           
           .ifu_tlu_imiss_e       (ifu_tlu_icmiss_e),
           // MMU_ASI_RD_CHANGE
           .ifu_tlu_thrid_d             (lsu_tlu_thrid_d[1:0]),
           .lsu_tlu_st_rs3_data_g       (lsu_mmu_rs3_data_g[63:0]),
           .lsu_tlu_async_ttype_g       (lsu_tlu_async_ttype_w2[6:0]),
           .lsu_tlu_async_tid_g         (lsu_tlu_async_tid_w2[1:0]),
           .lsu_tlu_async_ttype_vld_g   (lsu_tlu_async_ttype_vld_w2),
       // end of new interface to the pib
	   /*AUTOINST*/
           // Outputs
           .tlu_lsu_int_ldxa_data_w2    (tlu_lsu_int_ldxa_data_w2[63:0]),
           .tlu_lsu_int_ld_ill_va_w2    (tlu_lsu_int_ld_ill_va_w2),
           .tlu_lsu_int_ldxa_vld_w2     (tlu_lsu_int_ldxa_vld_w2),
           .tlu_dtlb_data_rd_g          (tlu_dtlb_data_rd_g),
           .tlu_dtlb_dmp_actxt_g        (tlu_dtlb_dmp_actxt_g),
           .tlu_dtlb_dmp_all_g          (tlu_dtlb_dmp_all_g),
           .tlu_dtlb_dmp_nctxt_g        (tlu_dtlb_dmp_nctxt_g),
           .tlu_dtlb_dmp_pctxt_g        (tlu_dtlb_dmp_pctxt_g),
           .tlu_dtlb_dmp_sctxt_g        (tlu_dtlb_dmp_sctxt_g),
           .tlu_dtlb_dmp_vld_g          (tlu_dtlb_dmp_vld_g),
           .tlu_dtlb_invalidate_all_g   (tlu_dtlb_invalidate_all_g),
           .tlu_dtlb_rw_index_g         (tlu_dtlb_rw_index_g[5:0]),
           .tlu_dtlb_rw_index_vld_g     (tlu_dtlb_rw_index_vld_g),
           .tlu_dtlb_tag_rd_g           (tlu_dtlb_tag_rd_g),
           .tlu_dtlb_tte_data_w2        (tlu_dtlb_tte_data_w2[42:0]),
           .tlu_dtlb_tte_tag_w2         (tlu_dtlb_tte_tag_w2[58:0]),
           .lsu_ifu_inj_ack             (lsu_ifu_inj_ack[3:0]),
           .tlu_exu_agp                 (tlu_exu_agp[`TSA_GLOBAL_WIDTH-1:0]),
           .tlu_exu_agp_swap            (tlu_exu_agp_swap),
           .tlu_exu_agp_tid             (tlu_exu_agp_tid[1:0]),
           .tlu_exu_ccr_m               (tlu_exu_ccr_m[7:0]),
           .tlu_exu_cwp_m               (tlu_exu_cwp_m[2:0]),
           .tlu_exu_cwp_retry_m         (tlu_exu_cwp_retry_m),
           .tlu_exu_cwpccr_update_m     (tlu_exu_cwpccr_update_m),
           .tlu_exu_rsr_data_m          (tlu_exu_rsr_data_m[`TLU_ASR_DATA_WIDTH-1:0]),
           .tlu_idtlb_dmp_key_g         (tlu_idtlb_dmp_key_g[40:0]),
           .tlu_idtlb_dmp_thrid_g       (tlu_idtlb_dmp_thrid_g[1:0]),
           .tlu_ifu_hwint_i3            (tlu_ifu_hwint_i3[3:0]),
           .tlu_ifu_nukeint_i2          (tlu_ifu_nukeint_i2),
           .tlu_ifu_pstate_ie           (tlu_ifu_pstate_ie[3:0]),
           .tlu_ifu_pstate_pef          (tlu_ifu_pstate_pef[3:0]),
           .tlu_ifu_resumint_i2         (tlu_ifu_resumint_i2),
           .tlu_ifu_rstint_i2           (tlu_ifu_rstint_i2),
           .tlu_ifu_rstthr_i2           (tlu_ifu_rstthr_i2[3:0]),
           .tlu_ifu_trap_tid_w1         (tlu_ifu_trap_tid_w1[1:0]),
           .tlu_ifu_trapnpc_vld_w1      (tlu_ifu_trapnpc_vld_w1),
           .tlu_ifu_trapnpc_w2          (tlu_ifu_trapnpc_w2[48:0]),
           .tlu_ifu_trappc_w2           (tlu_ifu_trappc_w2[48:0]),
           .tlu_ifu_trappc_vld_w1       (tlu_ifu_trappc_vld_w1),
           .tlu_itlb_data_rd_g          (tlu_itlb_data_rd_g),
           .tlu_itlb_dmp_actxt_g        (tlu_itlb_dmp_actxt_g),
           .tlu_itlb_dmp_all_g          (tlu_itlb_dmp_all_g),
           .tlu_itlb_dmp_nctxt_g        (tlu_itlb_dmp_nctxt_g),
           .tlu_itlb_dmp_vld_g          (tlu_itlb_dmp_vld_g),
           .tlu_itlb_invalidate_all_g   (tlu_itlb_invalidate_all_g),
           .tlu_itlb_rw_index_g         (tlu_itlb_rw_index_g[5:0]),
           .tlu_itlb_rw_index_vld_g     (tlu_itlb_rw_index_vld_g),
           .tlu_itlb_tag_rd_g           (tlu_itlb_tag_rd_g),
           .tlu_itlb_tte_data_w2        (tlu_itlb_tte_data_w2[42:0]),
           .tlu_itlb_tte_tag_w2         (tlu_itlb_tte_tag_w2[58:0]),
           .tlu_itlb_wr_vld_g           (tlu_itlb_wr_vld_g),
           .tlu_lsu_asi_m               (tlu_lsu_asi_m[7:0]),
           .tlu_lsu_asi_update_m        (tlu_lsu_asi_update_m),
           .tlu_sscan_test_data         (tlu_sscan_test_data[62:0]),
           .tlu_lsu_ldxa_tid_w2         (tlu_lsu_ldxa_tid_w2[1:0]),
           .tlu_lsu_pcxpkt              (tlu_lsu_pcxpkt[25:0]),
           .tlu_lsu_pstate_am           (tlu_lsu_pstate_am[3:0]),
           .tlu_lsu_pstate_cle          (tlu_lsu_pstate_cle[3:0]),
           .tlu_lsu_pstate_priv         (tlu_lsu_pstate_priv[3:0]),
           .tlu_lsu_redmode             (tlu_lsu_redmode[3:0]),
           .tlu_lsu_redmode_rst_d1      (tlu_lsu_redmode_rst_d1[3:0]),
           .tlu_lsu_stxa_ack            (tlu_lsu_stxa_ack),
           .tlu_lsu_stxa_ack_tid        (tlu_lsu_stxa_ack_tid[1:0]),
           .tlu_lsu_tid_m               (tlu_lsu_tid_m[1:0]),
           .tlu_lsu_tl_zero             (tlu_lsu_tl_zero[`TLU_THRD_NUM-1:0]),
           .tlu_hintp_vld               (tlu_hintp_vld[`TLU_THRD_NUM-1:0]),
           .tlu_rerr_vld                (tlu_rerr_vld[`TLU_THRD_NUM-1:0]),
           .tlu_early_flush_pipe_w      (tlu_early_flush_pipe_w),
           .tlu_early_flush_pipe2_w     (tlu_early_flush_pipe2_w),
           .tlu_exu_early_flush_pipe_w  (tlu_exu_early_flush_pipe_w),
           .tlu_lsu_ldxa_async_data_vld (tlu_lsu_ldxa_async_data_vld),
           .tlu_hpstate_priv            (tlu_hpstate_priv[`TLU_THRD_NUM-1:0]),
           .tlu_hpstate_enb             (tlu_hpstate_enb[`TLU_THRD_NUM-1:0]),
           .tlu_hpstate_ibe             (tlu_hpstate_ibe[`TLU_THRD_NUM-1:0]),
           .tlu_exu_priv_trap_m         (tlu_exu_priv_trap_m),
           .tlu_lsu_priv_trap_m         (tlu_lsu_priv_trap_m),
           .tlu_exu_pic_onebelow_m      (tlu_exu_pic_onebelow_m),
           .tlu_exu_pic_twobelow_m      (tlu_exu_pic_twobelow_m),
           .lsu_exu_ldxa_m              (lsu_exu_ldxa_m),
           .lsu_exu_ldxa_data_g         (lsu_exu_ldxa_data_g[63:0]),
           .tlu_dsfsr_flt_vld           (tlu_dsfsr_flt_vld[3:0]),
           // Inputs
           .rclk                        (rclk),
           .const_cpuid                 (const_cpuid[3:0]),
           .exu_lsu_ldst_va_e           (exu_lsu_ldst_va_e[`ASI_VA_WIDTH-1:0]),
           .lsu_tlu_ldst_va_m           (lsu_tlu_ldst_va_m[`TLU_ASI_VA_WIDTH-1:0]),
           .exu_mmu_early_va_e          (exu_mmu_early_va_e[7:0]),
           .exu_tlu_ccr0_w              (exu_tlu_ccr0_w[7:0]),
           .exu_tlu_ccr1_w              (exu_tlu_ccr1_w[7:0]),
           .exu_tlu_ccr2_w              (exu_tlu_ccr2_w[7:0]),
           .exu_tlu_ccr3_w              (exu_tlu_ccr3_w[7:0]),
           .exu_tlu_cwp_cmplt           (exu_tlu_cwp_cmplt),
           .exu_tlu_cwp_cmplt_tid       (exu_tlu_cwp_cmplt_tid[1:0]),
           .exu_tlu_cwp_retry           (exu_tlu_cwp_retry),
           .exu_tlu_misalign_addr_jmpl_rtn_m(exu_tlu_misalign_addr_jmpl_rtn_m),
           .exu_tlu_spill               (exu_tlu_spill),
           .exu_tlu_spill_tid           (exu_tlu_spill_tid[1:0]),
           .exu_tlu_spill_other         (exu_tlu_spill_other),
           .exu_tlu_spill_wtype         (exu_tlu_spill_wtype[2:0]),
           .exu_tlu_ttype_m             (exu_tlu_ttype_m[8:0]),
           .exu_tlu_ttype_vld_m         (exu_tlu_ttype_vld_m),
           .exu_tlu_va_oor_jl_ret_m     (exu_tlu_va_oor_jl_ret_m),
           .exu_tlu_va_oor_m            (exu_tlu_va_oor_m),
           .ffu_tlu_ill_inst_m          (ffu_tlu_ill_inst_m),
           .ffu_ifu_tid_w2              (ffu_ifu_tid_w2[1:0]),
           .ffu_tlu_trap_ieee754        (ffu_tlu_trap_ieee754),
           .ffu_tlu_trap_other          (ffu_tlu_trap_other),
           .ffu_tlu_trap_ue             (ffu_tlu_trap_ue),
           .ifu_lsu_ld_inst_e           (ifu_lsu_ld_inst_e),
           .ifu_lsu_memref_d            (ifu_lsu_memref_d),
           .ifu_lsu_st_inst_e           (ifu_lsu_st_inst_e),
           .ifu_tlu_done_inst_d         (ifu_tlu_done_inst_d),
           .ifu_tlu_flush_m             (ifu_tlu_flush_m),
           .ifu_tlu_flush_fd_w          (ifu_tlu_flush_fd_w),
           .ifu_tlu_flush_fd2_w         (ifu_tlu_flush_fd2_w),
           .ifu_tlu_flush_fd3_w         (ifu_tlu_flush_fd3_w),
           .lsu_tlu_early_flush_w       (lsu_tlu_early_flush_w),
           .lsu_tlu_early_flush2_w      (lsu_tlu_early_flush2_w),
           .ifu_tlu_hwint_m             (ifu_tlu_hwint_m),
           .ifu_tlu_immu_miss_m         (ifu_tlu_immu_miss_m),
           .ifu_tlu_pc_oor_e            (ifu_tlu_pc_oor_e),
           .ifu_tlu_l2imiss             (ifu_tlu_l2imiss[`TLU_THRD_NUM-1:0]),
           .ifu_tlu_inst_vld_m          (ifu_tlu_inst_vld_m),
           .ifu_tlu_inst_vld_m_bf1      (ifu_tlu_inst_vld_m_bf1),
           .ifu_tlu_itlb_done           (ifu_tlu_itlb_done),
           .ifu_tlu_npc_m               (ifu_tlu_npc_m[48:0]),
           .ifu_tlu_pc_m                (ifu_tlu_pc_m[48:0]),
           .ifu_tlu_priv_violtn_m       (ifu_tlu_priv_violtn_m),
           .ifu_tlu_retry_inst_d        (ifu_tlu_retry_inst_d),
           .ifu_tlu_rstint_m            (ifu_tlu_rstint_m),
           .ifu_tlu_sir_inst_m          (ifu_tlu_sir_inst_m),
           .ifu_lsu_thrid_s             (ifu_lsu_thrid_s[1:0]),
           .ifu_tlu_ttype_m             (ifu_tlu_ttype_m[8:0]),
           .ifu_tlu_ttype_vld_m         (ifu_tlu_ttype_vld_m),
           .ifu_mmu_trap_m              (ifu_mmu_trap_m),
           .ifu_tlu_trap_m              (ifu_tlu_trap_m),
           .lsu_asi_reg0                (lsu_asi_reg0[7:0]),
           .lsu_asi_reg1                (lsu_asi_reg1[7:0]),
           .lsu_asi_reg2                (lsu_asi_reg2[7:0]),
           .lsu_asi_reg3                (lsu_asi_reg3[7:0]),
           .lsu_asi_state               (lsu_asi_state[`TLU_ASI_STATE_WIDTH-1:0]),
           .lsu_tlu_defr_trp_taken_g    (lsu_tlu_defr_trp_taken_g),
           .lsu_mmu_defr_trp_taken_g    (lsu_mmu_defr_trp_taken_g),
           .lsu_tlu_cpx_req             (lsu_tlu_cpx_req[3:0]),
           .lsu_tlu_cpx_vld             (lsu_tlu_cpx_vld),
           .lsu_tlu_daccess_excptn_g    (lsu_tlu_daccess_excptn_g),
           .lsu_tlu_daccess_prot_g      (lsu_tlu_daccess_prot_g),
           .lsu_tlu_dmmu_miss_g         (lsu_tlu_dmmu_miss_g),
           .lsu_tlu_dside_ctxt_m        (lsu_tlu_dside_ctxt_m[12:0]),
           .lsu_tlu_dtlb_done           (lsu_tlu_dtlb_done),
           .lsu_tlu_intpkt              (lsu_tlu_intpkt[17:0]),
           .ctu_sscan_tid               (ctu_sscan_tid[`TLU_THRD_NUM-1:0]),
           .lsu_tlu_misalign_addr_ldst_atm_m(lsu_tlu_misalign_addr_ldst_atm_m),
           .lsu_tlu_pctxt_m             (lsu_tlu_pctxt_m[12:0]),
           .lsu_tlu_pcxpkt_ack          (lsu_tlu_pcxpkt_ack),
           .lsu_tlu_priv_action_g       (lsu_tlu_priv_action_g),
           .lsu_tlu_rs3_data_g          (lsu_tlu_rs3_data_g[63:0]),
           .lsu_tlu_tlb_access_tid_m    (lsu_tlu_tlb_access_tid_m[1:0]),
           .lsu_tlu_tlb_asi_state_m     (lsu_tlu_tlb_asi_state_m[7:0]),
           .lsu_tlu_tlb_dmp_va_m        (lsu_tlu_tlb_dmp_va_m[47:13]),
           .lsu_tlu_tlb_ld_inst_m       (lsu_tlu_tlb_ld_inst_m),
           .lsu_tlu_tlb_ldst_va_m       (lsu_tlu_tlb_ldst_va_m[10:0]),
           .lsu_tlu_tlb_st_inst_m       (lsu_tlu_tlb_st_inst_m),
           .lsu_tlu_ttype_m2            (lsu_tlu_ttype_m2[8:0]),
           .lsu_tlu_ttype_vld_m2        (lsu_tlu_ttype_vld_m2),
           .lsu_tlu_wtchpt_trp_g        (lsu_tlu_wtchpt_trp_g),
           .mem_write_disable           (mem_write_disable),
           .mux_drive_disable           (mux_drive_disable),
           .sehold                      (sehold),
           .se                          (se),
           .ifu_tlu_sraddr_d            (ifu_tlu_sraddr_d[`TLU_ASR_ADDR_WIDTH-1:0]),
           .ifu_tlu_sraddr_d_v2         (ifu_tlu_sraddr_d_v2[`TLU_ASR_ADDR_WIDTH-1:0]),
           .ifu_tlu_rsr_inst_d          (ifu_tlu_rsr_inst_d),
           .lsu_tlu_wsr_inst_e          (lsu_tlu_wsr_inst_e),
           .exu_tlu_wsr_data_m          (exu_tlu_wsr_data_m[63:0]),
           .lsu_tlu_rsr_data_e          (lsu_tlu_rsr_data_e[7:0]),
           .ifu_lsu_alt_space_e         (ifu_lsu_alt_space_e),
           .ifu_tlu_alt_space_d         (ifu_tlu_alt_space_d),
           .lsu_tlu_squash_va_oor_m     (lsu_tlu_squash_va_oor_m),
           .lsu_tlu_dcache_miss_w2      (lsu_tlu_dcache_miss_w2[3:0]),
           .lsu_tlu_l2_dmiss            (lsu_tlu_l2_dmiss[3:0]),
           .lsu_tlu_stb_full_w2         (lsu_tlu_stb_full_w2[3:0]),
           .ffu_tlu_fpu_tid             (ffu_tlu_fpu_tid[1:0]),
           .ffu_tlu_fpu_cmplt           (ffu_tlu_fpu_cmplt),
           .lsu_pid_state0              (lsu_pid_state0[2:0]),
           .lsu_pid_state1              (lsu_pid_state1[2:0]),
           .lsu_pid_state2              (lsu_pid_state2[2:0]),
           .lsu_pid_state3              (lsu_pid_state3[2:0]),
           .lsu_tlu_nucleus_ctxt_m      (lsu_tlu_nucleus_ctxt_m),
           .lsu_tlu_tte_pg_sz_g         (lsu_tlu_tte_pg_sz_g[2:0]),
           .ifu_lsu_error_inj           (ifu_lsu_error_inj[3:0]),
           .ifu_lsu_imm_asi_vld_d       (ifu_lsu_imm_asi_vld_d),
           .lsu_dsfsr_din_g             (lsu_dsfsr_din_g[23:0]),
           .lsu_dmmu_sfsr_trp_wr        (lsu_dmmu_sfsr_trp_wr[3:0]),
           .lsu_mmu_flush_pipe_w        (lsu_mmu_flush_pipe_w),
           .exu_lsu_priority_trap_m     (exu_lsu_priority_trap_m));
   
`else
   
   tlu tlu(
           .short_si0              (short_scan0_3),
           .short_si1              (short_scan1_3),
           .short_so0              (short_scan0_4),
           .short_so1              (short_scan1_4),
           .si0 (scan0_4),
           .si1 (scan1_1),
           .so0 (scan0_5),
           .so1 (scan1_2),
           .grst_l                (spc_grst_l),
           .arst_l                (cmp_arst_l),
	       .tlu_sftint_vld		    (tlu_ifu_sftint_vld[3:0]),
	       .ifu_tlu_swint_m		    (ifu_tlu_sftint_m),
           .exu_tlu_cwp0                (exu_tlu_cwp0_w[2:0]),
           .exu_tlu_cwp1                (exu_tlu_cwp1_w[2:0]),
           .exu_tlu_cwp2                (exu_tlu_cwp2_w[2:0]),
           .exu_tlu_cwp3                (exu_tlu_cwp3_w[2:0]),

           // fix for bug 5953
           .exu_tlu_ue_trap_m           (1'b0),

           // temporary fix for bug 5863
           // TBD: change for TO 2.0
	   // fixed for eco 6660
           .spu_tlu_rsrv_illgl_m        (spu_tlu_rsrv_illgl_m),

           // new interface to the pib block
           .ifu_lsu_imm_asi_d           (ifu_tlu_imm_asi_d[8:0]),
           
           .ifu_tlu_imiss_e       (ifu_tlu_icmiss_e),
           // MMU_ASI_RD_CHANGE
           .ifu_tlu_thrid_d             (lsu_tlu_thrid_d[1:0]),
           .lsu_tlu_st_rs3_data_g       (lsu_mmu_rs3_data_g[63:0]),
           .lsu_tlu_async_ttype_g       (lsu_tlu_async_ttype_w2[6:0]),
           .lsu_tlu_async_tid_g         (lsu_tlu_async_tid_w2[1:0]),
           .lsu_tlu_async_ttype_vld_g   (lsu_tlu_async_ttype_vld_w2),
       // end of new interface to the pib
	   /*AUTOINST*/
           // Outputs
           .tlu_lsu_int_ldxa_data_w2    (tlu_lsu_int_ldxa_data_w2[63:0]),
           .tlu_lsu_int_ld_ill_va_w2    (tlu_lsu_int_ld_ill_va_w2),
           .tlu_lsu_int_ldxa_vld_w2     (tlu_lsu_int_ldxa_vld_w2),
           .tlu_dtlb_data_rd_g          (tlu_dtlb_data_rd_g),
           .tlu_dtlb_dmp_actxt_g        (tlu_dtlb_dmp_actxt_g),
           .tlu_dtlb_dmp_all_g          (tlu_dtlb_dmp_all_g),
           .tlu_dtlb_dmp_nctxt_g        (tlu_dtlb_dmp_nctxt_g),
           .tlu_dtlb_dmp_pctxt_g        (tlu_dtlb_dmp_pctxt_g),
           .tlu_dtlb_dmp_sctxt_g        (tlu_dtlb_dmp_sctxt_g),
           .tlu_dtlb_dmp_vld_g          (tlu_dtlb_dmp_vld_g),
           .tlu_dtlb_invalidate_all_g   (tlu_dtlb_invalidate_all_g),
           .tlu_dtlb_rw_index_g         (tlu_dtlb_rw_index_g[5:0]),
           .tlu_dtlb_rw_index_vld_g     (tlu_dtlb_rw_index_vld_g),
           .tlu_dtlb_tag_rd_g           (tlu_dtlb_tag_rd_g),
           .tlu_dtlb_tte_data_w2        (tlu_dtlb_tte_data_w2[42:0]),
           .tlu_dtlb_tte_tag_w2         (tlu_dtlb_tte_tag_w2[58:0]),
           .lsu_ifu_inj_ack             (lsu_ifu_inj_ack[3:0]),
           .tlu_exu_agp                 (tlu_exu_agp[`TSA_GLOBAL_WIDTH-1:0]),
           .tlu_exu_agp_swap            (tlu_exu_agp_swap),
           .tlu_exu_agp_tid             (tlu_exu_agp_tid[1:0]),
           .tlu_exu_ccr_m               (tlu_exu_ccr_m[7:0]),
           .tlu_exu_cwp_m               (tlu_exu_cwp_m[2:0]),
           .tlu_exu_cwp_retry_m         (tlu_exu_cwp_retry_m),
           .tlu_exu_cwpccr_update_m     (tlu_exu_cwpccr_update_m),
           .tlu_exu_rsr_data_m          (tlu_exu_rsr_data_m[`TLU_ASR_DATA_WIDTH-1:0]),
           .tlu_idtlb_dmp_key_g         (tlu_idtlb_dmp_key_g[40:0]),
           .tlu_idtlb_dmp_thrid_g       (tlu_idtlb_dmp_thrid_g[1:0]),
           .tlu_ifu_hwint_i3            (tlu_ifu_hwint_i3[3:0]),
           .tlu_ifu_nukeint_i2          (tlu_ifu_nukeint_i2),
           .tlu_ifu_pstate_ie           (tlu_ifu_pstate_ie[3:0]),
           .tlu_ifu_pstate_pef          (tlu_ifu_pstate_pef[3:0]),
           .tlu_ifu_resumint_i2         (tlu_ifu_resumint_i2),
           .tlu_ifu_rstint_i2           (tlu_ifu_rstint_i2),
           .tlu_ifu_rstthr_i2           (tlu_ifu_rstthr_i2[3:0]),
           .tlu_ifu_trap_tid_w1         (tlu_ifu_trap_tid_w1[1:0]),
           .tlu_ifu_trapnpc_vld_w1      (tlu_ifu_trapnpc_vld_w1),
           .tlu_ifu_trapnpc_w2          (tlu_ifu_trapnpc_w2[48:0]),
           .tlu_ifu_trappc_w2           (tlu_ifu_trappc_w2[48:0]),
           .tlu_ifu_trappc_vld_w1       (tlu_ifu_trappc_vld_w1),
           .tlu_itlb_data_rd_g          (tlu_itlb_data_rd_g),
           .tlu_itlb_dmp_actxt_g        (tlu_itlb_dmp_actxt_g),
           .tlu_itlb_dmp_all_g          (tlu_itlb_dmp_all_g),
           .tlu_itlb_dmp_nctxt_g        (tlu_itlb_dmp_nctxt_g),
           .tlu_itlb_dmp_vld_g          (tlu_itlb_dmp_vld_g),
           .tlu_itlb_invalidate_all_g   (tlu_itlb_invalidate_all_g),
           .tlu_itlb_rw_index_g         (tlu_itlb_rw_index_g[5:0]),
           .tlu_itlb_rw_index_vld_g     (tlu_itlb_rw_index_vld_g),
           .tlu_itlb_tag_rd_g           (tlu_itlb_tag_rd_g),
           .tlu_itlb_tte_data_w2        (tlu_itlb_tte_data_w2[42:0]),
           .tlu_itlb_tte_tag_w2         (tlu_itlb_tte_tag_w2[58:0]),
           .tlu_itlb_wr_vld_g           (tlu_itlb_wr_vld_g),
           .tlu_lsu_asi_m               (tlu_lsu_asi_m[7:0]),
           .tlu_lsu_asi_update_m        (tlu_lsu_asi_update_m),
           .tlu_sscan_test_data         (tlu_sscan_test_data[62:0]),
           .tlu_lsu_ldxa_tid_w2         (tlu_lsu_ldxa_tid_w2[1:0]),
           .tlu_lsu_pcxpkt              (tlu_lsu_pcxpkt[25:0]),
           .tlu_lsu_pstate_am           (tlu_lsu_pstate_am[3:0]),
           .tlu_lsu_pstate_cle          (tlu_lsu_pstate_cle[3:0]),
           .tlu_lsu_pstate_priv         (tlu_lsu_pstate_priv[3:0]),
           .tlu_lsu_redmode             (tlu_lsu_redmode[3:0]),
           .tlu_lsu_redmode_rst_d1      (tlu_lsu_redmode_rst_d1[3:0]),
           .tlu_lsu_stxa_ack            (tlu_lsu_stxa_ack),
           .tlu_lsu_stxa_ack_tid        (tlu_lsu_stxa_ack_tid[1:0]),
           .tlu_lsu_tid_m               (tlu_lsu_tid_m[1:0]),
           .tlu_lsu_tl_zero             (tlu_lsu_tl_zero[`TLU_THRD_NUM-1:0]),
           .tlu_hintp_vld               (tlu_hintp_vld[`TLU_THRD_NUM-1:0]),
           .tlu_rerr_vld                (tlu_rerr_vld[`TLU_THRD_NUM-1:0]),
           .tlu_early_flush_pipe_w      (tlu_early_flush_pipe_w),
           .tlu_early_flush_pipe2_w     (tlu_early_flush_pipe2_w),
           .tlu_exu_early_flush_pipe_w  (tlu_exu_early_flush_pipe_w),
           .tlu_lsu_ldxa_async_data_vld (tlu_lsu_ldxa_async_data_vld),
           .tlu_hpstate_priv            (tlu_hpstate_priv[`TLU_THRD_NUM-1:0]),
           .tlu_hpstate_enb             (tlu_hpstate_enb[`TLU_THRD_NUM-1:0]),
           .tlu_hpstate_ibe             (tlu_hpstate_ibe[`TLU_THRD_NUM-1:0]),
           .tlu_exu_priv_trap_m         (tlu_exu_priv_trap_m),
           .tlu_lsu_priv_trap_m         (tlu_lsu_priv_trap_m),
           .tlu_exu_pic_onebelow_m      (tlu_exu_pic_onebelow_m),
           .tlu_exu_pic_twobelow_m      (tlu_exu_pic_twobelow_m),
           .lsu_exu_ldxa_m              (lsu_exu_ldxa_m),
           .lsu_exu_ldxa_data_g         (lsu_exu_ldxa_data_g[63:0]),
           .tlu_dsfsr_flt_vld           (tlu_dsfsr_flt_vld[3:0]),
           // Inputs
           .rclk                        (rclk),
           .const_cpuid                 (const_cpuid[3:0]),
           .exu_lsu_ldst_va_e           (exu_lsu_ldst_va_e[`ASI_VA_WIDTH-1:0]),
           .lsu_tlu_ldst_va_m           (lsu_tlu_ldst_va_m[`TLU_ASI_VA_WIDTH-1:0]),
           .exu_mmu_early_va_e          (exu_mmu_early_va_e[7:0]),
           .exu_tlu_ccr0_w              (exu_tlu_ccr0_w[7:0]),
           .exu_tlu_ccr1_w              (exu_tlu_ccr1_w[7:0]),
           .exu_tlu_ccr2_w              (exu_tlu_ccr2_w[7:0]),
           .exu_tlu_ccr3_w              (exu_tlu_ccr3_w[7:0]),
           .exu_tlu_cwp_cmplt           (exu_tlu_cwp_cmplt),
           .exu_tlu_cwp_cmplt_tid       (exu_tlu_cwp_cmplt_tid[1:0]),
           .exu_tlu_cwp_retry           (exu_tlu_cwp_retry),
           .exu_tlu_misalign_addr_jmpl_rtn_m(exu_tlu_misalign_addr_jmpl_rtn_m),
           .exu_tlu_spill               (exu_tlu_spill),
           .exu_tlu_spill_tid           (exu_tlu_spill_tid[1:0]),
           .exu_tlu_spill_other         (exu_tlu_spill_other),
           .exu_tlu_spill_wtype         (exu_tlu_spill_wtype[2:0]),
           .exu_tlu_ttype_m             (exu_tlu_ttype_m[8:0]),
           .exu_tlu_ttype_vld_m         (exu_tlu_ttype_vld_m),
           .exu_tlu_va_oor_jl_ret_m     (exu_tlu_va_oor_jl_ret_m),
           .exu_tlu_va_oor_m            (exu_tlu_va_oor_m),
           .ffu_tlu_ill_inst_m          (ffu_tlu_ill_inst_m),
           .ffu_ifu_tid_w2              (ffu_ifu_tid_w2[1:0]),
           .ffu_tlu_trap_ieee754        (ffu_tlu_trap_ieee754),
           .ffu_tlu_trap_other          (ffu_tlu_trap_other),
           .ffu_tlu_trap_ue             (ffu_tlu_trap_ue),
           .ifu_lsu_ld_inst_e           (ifu_lsu_ld_inst_e),
           .ifu_lsu_memref_d            (ifu_lsu_memref_d),
           .ifu_lsu_st_inst_e           (ifu_lsu_st_inst_e),
           .ifu_tlu_done_inst_d         (ifu_tlu_done_inst_d),
           .ifu_tlu_flush_m             (ifu_tlu_flush_m),
           .ifu_tlu_flush_fd_w          (ifu_tlu_flush_fd_w),
           .ifu_tlu_flush_fd2_w         (ifu_tlu_flush_fd2_w),
           .ifu_tlu_flush_fd3_w         (ifu_tlu_flush_fd3_w),
           .lsu_tlu_early_flush_w       (lsu_tlu_early_flush_w),
           .lsu_tlu_early_flush2_w      (lsu_tlu_early_flush2_w),
           .ifu_tlu_hwint_m             (ifu_tlu_hwint_m),
           .ifu_tlu_immu_miss_m         (ifu_tlu_immu_miss_m),
           .ifu_tlu_pc_oor_e            (ifu_tlu_pc_oor_e),
           .ifu_tlu_l2imiss             (ifu_tlu_l2imiss[`TLU_THRD_NUM-1:0]),
           .ifu_tlu_inst_vld_m          (ifu_tlu_inst_vld_m),
           .ifu_tlu_inst_vld_m_bf1      (ifu_tlu_inst_vld_m_bf1),
           .ifu_tlu_itlb_done           (ifu_tlu_itlb_done),
           .ifu_tlu_npc_m               (ifu_tlu_npc_m[48:0]),
           .ifu_tlu_pc_m                (ifu_tlu_pc_m[48:0]),
           .ifu_tlu_priv_violtn_m       (ifu_tlu_priv_violtn_m),
           .ifu_tlu_retry_inst_d        (ifu_tlu_retry_inst_d),
           .ifu_tlu_rstint_m            (ifu_tlu_rstint_m),
           .ifu_tlu_sir_inst_m          (ifu_tlu_sir_inst_m),
           .ifu_lsu_thrid_s             (ifu_lsu_thrid_s[1:0]),
           .ifu_tlu_ttype_m             (ifu_tlu_ttype_m[8:0]),
           .ifu_tlu_ttype_vld_m         (ifu_tlu_ttype_vld_m),
           .ifu_mmu_trap_m              (ifu_mmu_trap_m),
           .ifu_tlu_trap_m              (ifu_tlu_trap_m),
           .lsu_asi_reg0                (lsu_asi_reg0[7:0]),
           .lsu_asi_reg1                (lsu_asi_reg1[7:0]),
           .lsu_asi_reg2                (lsu_asi_reg2[7:0]),
           .lsu_asi_reg3                (lsu_asi_reg3[7:0]),
           .lsu_asi_state               (lsu_asi_state[`TLU_ASI_STATE_WIDTH-1:0]),
           .lsu_tlu_defr_trp_taken_g    (lsu_tlu_defr_trp_taken_g),
           .lsu_mmu_defr_trp_taken_g    (lsu_mmu_defr_trp_taken_g),
           .lsu_tlu_cpx_req             (lsu_tlu_cpx_req[3:0]),
           .lsu_tlu_cpx_vld             (lsu_tlu_cpx_vld),
           .lsu_tlu_daccess_excptn_g    (lsu_tlu_daccess_excptn_g),
           .lsu_tlu_daccess_prot_g      (lsu_tlu_daccess_prot_g),
           .lsu_tlu_dmmu_miss_g         (lsu_tlu_dmmu_miss_g),
           .lsu_tlu_dside_ctxt_m        (lsu_tlu_dside_ctxt_m[12:0]),
           .lsu_tlu_dtlb_done           (lsu_tlu_dtlb_done),
           .lsu_tlu_intpkt              (lsu_tlu_intpkt[17:0]),
           .ctu_sscan_tid               (ctu_sscan_tid[`TLU_THRD_NUM-1:0]),
           .lsu_tlu_misalign_addr_ldst_atm_m(lsu_tlu_misalign_addr_ldst_atm_m),
           .lsu_tlu_pctxt_m             (lsu_tlu_pctxt_m[12:0]),
           .lsu_tlu_pcxpkt_ack          (lsu_tlu_pcxpkt_ack),
           .lsu_tlu_priv_action_g       (lsu_tlu_priv_action_g),
           .lsu_tlu_rs3_data_g          (lsu_tlu_rs3_data_g[63:0]),
           .lsu_tlu_tlb_access_tid_m    (lsu_tlu_tlb_access_tid_m[1:0]),
           .lsu_tlu_tlb_asi_state_m     (lsu_tlu_tlb_asi_state_m[7:0]),
           .lsu_tlu_tlb_dmp_va_m        (lsu_tlu_tlb_dmp_va_m[47:13]),
           .lsu_tlu_tlb_ld_inst_m       (lsu_tlu_tlb_ld_inst_m),
           .lsu_tlu_tlb_ldst_va_m       (lsu_tlu_tlb_ldst_va_m[10:0]),
           .lsu_tlu_tlb_st_inst_m       (lsu_tlu_tlb_st_inst_m),
           .lsu_tlu_ttype_m2            (lsu_tlu_ttype_m2[8:0]),
           .lsu_tlu_ttype_vld_m2        (lsu_tlu_ttype_vld_m2),
           .lsu_tlu_wtchpt_trp_g        (lsu_tlu_wtchpt_trp_g),
           .mem_write_disable           (mem_write_disable),
           .mux_drive_disable           (mux_drive_disable),
           .sehold                      (sehold),
           .se                          (se),
           .ifu_tlu_sraddr_d            (ifu_tlu_sraddr_d[`TLU_ASR_ADDR_WIDTH-1:0]),
           .ifu_tlu_sraddr_d_v2         (ifu_tlu_sraddr_d_v2[`TLU_ASR_ADDR_WIDTH-1:0]),
           .ifu_tlu_rsr_inst_d          (ifu_tlu_rsr_inst_d),
           .lsu_tlu_wsr_inst_e          (lsu_tlu_wsr_inst_e),
           .exu_tlu_wsr_data_m          (exu_tlu_wsr_data_m[63:0]),
           .lsu_tlu_rsr_data_e          (lsu_tlu_rsr_data_e[7:0]),
           .ifu_lsu_alt_space_e         (ifu_lsu_alt_space_e),
           .ifu_tlu_alt_space_d         (ifu_tlu_alt_space_d),
           .lsu_tlu_squash_va_oor_m     (lsu_tlu_squash_va_oor_m),
           .lsu_tlu_dcache_miss_w2      (lsu_tlu_dcache_miss_w2[3:0]),
           .lsu_tlu_l2_dmiss            (lsu_tlu_l2_dmiss[3:0]),
           .lsu_tlu_stb_full_w2         (lsu_tlu_stb_full_w2[3:0]),
           .ffu_tlu_fpu_tid             (ffu_tlu_fpu_tid[1:0]),
           .ffu_tlu_fpu_cmplt           (ffu_tlu_fpu_cmplt),
           .lsu_pid_state0              (lsu_pid_state0[2:0]),
           .lsu_pid_state1              (lsu_pid_state1[2:0]),
           .lsu_pid_state2              (lsu_pid_state2[2:0]),
           .lsu_pid_state3              (lsu_pid_state3[2:0]),
           .lsu_tlu_nucleus_ctxt_m      (lsu_tlu_nucleus_ctxt_m),
           .lsu_tlu_tte_pg_sz_g         (lsu_tlu_tte_pg_sz_g[2:0]),
           .ifu_lsu_error_inj           (ifu_lsu_error_inj[3:0]),
           .ifu_lsu_imm_asi_vld_d       (ifu_lsu_imm_asi_vld_d),
           .lsu_dsfsr_din_g             (lsu_dsfsr_din_g[23:0]),
           .lsu_dmmu_sfsr_trp_wr        (lsu_dmmu_sfsr_trp_wr[3:0]),
           .lsu_mmu_flush_pipe_w        (lsu_mmu_flush_pipe_w),
           .exu_lsu_priority_trap_m     (exu_lsu_priority_trap_m));

`endif //  `ifdef FPGA_SYN_NO_SPU


   spu spu(
           .short_si0 			(short_scan0_4),
           .short_so0 			(short_scan0_5),
           .short_si1              	(short_scan1_4),
           .short_so1              	(short_scan1_5),
           .si1 (scan1_2),
           .so1 (scan1_3),
           // reset stuff
           .grst_l                 	(spc_grst_l),
           .arst_l                 	(cmp_arst_l),
           .mem_bypass (mem_bypass),
           
           .tlu_spu_flush_w 		(tlu_exu_early_flush_pipe_w),
           .ifu_spu_flush_w       	(ifu_tlu_flush_w),

           .cpx_spu_data_cx     	({cpx_spc_data_cx3[144:140],cpx_spc_data_cx3[138:137],
						cpx_spc_data_cx3[127:0]}),

           .exu_spu_rsrv_data_e         (exu_spu_rs3_data_e[8:6]),
           .exu_lsu_rs3_data_e          (exu_spu_rs3_data_e[63:0]),

	         .mux_drive_disable     	(mux_drive_disable),
           .lsu_spu_strm_ack_cmplt      (lsu_spu_strm_ack_cmplt[1:0]),

           //
           .spu_tlu_rsrv_illgl_m        (spu_tlu_rsrv_illgl_m),
           
	   /*AUTOINST*/
           // Outputs
           .spu_ifu_ttype_w2            (spu_ifu_ttype_w2),
           .spu_ifu_ttype_vld_w2        (spu_ifu_ttype_vld_w2),
           .spu_ifu_ttype_tid_w2        (spu_ifu_ttype_tid_w2[1:0]),
           .spu_lsu_ldst_pckt           (spu_lsu_ldst_pckt[123:0]),
           .spu_mul_req_vld             (spu_mul_req_vld),
           .spu_mul_areg_shf            (spu_mul_areg_shf),
           .spu_mul_areg_rst            (spu_mul_areg_rst),
           .spu_mul_acc                 (spu_mul_acc),
           .spu_mul_op1_data            (spu_mul_op1_data[63:0]),
           .spu_mul_op2_data            (spu_mul_op2_data[63:0]),
           .spu_lsu_ldxa_data_w2        (spu_lsu_ldxa_data_w2[63:0]),
           .spu_lsu_ldxa_data_vld_w2    (spu_lsu_ldxa_data_vld_w2),
           .spu_lsu_ldxa_tid_w2         (spu_lsu_ldxa_tid_w2[1:0]),
           .spu_lsu_stxa_ack            (spu_lsu_stxa_ack),
           .spu_lsu_stxa_ack_tid        (spu_lsu_stxa_ack_tid[1:0]),
           .spu_mul_mulres_lshft        (spu_mul_mulres_lshft),
           .spu_ifu_corr_err_w2         (spu_ifu_corr_err_w2),
           .spu_ifu_unc_err_w1          (spu_ifu_unc_err_w1),
           .spu_lsu_unc_error_w2        (spu_lsu_unc_error_w2),
           .spu_ifu_err_addr_w2         (spu_ifu_err_addr_w2[39:4]),
           .spu_ifu_mamem_err_w1        (spu_ifu_mamem_err_w1),
           .spu_ifu_int_w2              (spu_ifu_int_w2),
           .spu_lsu_ldxa_illgl_va_w2    (spu_lsu_ldxa_illgl_va_w2),
           // Inputs
           .se                          (se),
           .rclk                        (rclk),
           .mem_write_disable           (mem_write_disable),
           .sehold                      (sehold),
           .const_cpuid                 (const_cpuid[2:0]),
           .lsu_spu_ldst_ack            (lsu_spu_ldst_ack),
           .mul_spu_ack                 (mul_spu_ack),
           .mul_spu_shf_ack             (mul_spu_shf_ack),
           .mul_data_out                (mul_data_out[63:0]),
           .lsu_spu_asi_state_e         (lsu_spu_asi_state_e[7:0]),
           .ifu_spu_inst_vld_w          (ifu_spu_inst_vld_w),
           .ifu_lsu_ld_inst_e           (ifu_lsu_ld_inst_e),
           .ifu_lsu_st_inst_e           (ifu_lsu_st_inst_e),
           .ifu_lsu_alt_space_e         (ifu_lsu_alt_space_e),
           .ifu_tlu_thrid_e             (ifu_tlu_thrid_e[1:0]),
           .exu_lsu_ldst_va_e           (exu_lsu_ldst_va_e[7:0]),
           .ifu_spu_trap_ack            (ifu_spu_trap_ack),
           .lsu_spu_stb_empty           (lsu_spu_stb_empty[3:0]),
           .lsu_spu_early_flush_g       (lsu_spu_early_flush_g),
           .ifu_spu_nceen               (ifu_spu_nceen[3:0]),
           .lsu_mamem_mrgn              (lsu_mamem_mrgn[3:0]));
  

`ifdef FPGA_SYN_NO_SPU

      sparc_mul_top mul(
                     .si                (scan1_2),
                     .so                (scan1_4),
                     //
                     .grst_l             (spc_grst_l),
                     .arst_l                 	(cmp_arst_l),
                     /*AUTOINST*/
                     // Outputs
                     .mul_exu_ack       (mul_exu_ack),
                     .mul_spu_ack       (),
                     .mul_spu_shf_ack   (),
                     .mul_data_out      (mul_data_out[63:0]),
                     // Inputs
                     .rclk              (rclk),
                     .se                (se),
                     .exu_mul_input_vld (exu_mul_input_vld),
                     .exu_mul_rs1_data  (exu_mul_rs1_data[63:0]),
                     .exu_mul_rs2_data  (exu_mul_rs2_data[63:0]),
                     .spu_mul_req_vld   (1'b0),
                     .spu_mul_acc       (1'b0),
                     .spu_mul_areg_shf  (1'b0),
                     .spu_mul_areg_rst  (1'b0),
                     .spu_mul_op1_data  (64'h0000000000000000),
                     .spu_mul_op2_data  (64'h0000000000000000),
                     .spu_mul_mulres_lshft(spu_mul_mulres_lshft));
   
`else
   
   sparc_mul_top mul(
                     .si                (scan1_3),
                     .so                (scan1_4),
                     //
                     .grst_l             (spc_grst_l),
                     .arst_l                 	(cmp_arst_l),
                     /*AUTOINST*/
                     // Outputs
                     .mul_exu_ack       (mul_exu_ack),
                     .mul_spu_ack       (mul_spu_ack),
                     .mul_spu_shf_ack   (mul_spu_shf_ack),
                     .mul_data_out      (mul_data_out[63:0]),
                     // Inputs
                     .rclk              (rclk),
                     .se                (se),
                     .exu_mul_input_vld (exu_mul_input_vld),
                     .exu_mul_rs1_data  (exu_mul_rs1_data[63:0]),
                     .exu_mul_rs2_data  (exu_mul_rs2_data[63:0]),
                     .spu_mul_req_vld   (spu_mul_req_vld),
                     .spu_mul_acc       (spu_mul_acc),
                     .spu_mul_areg_shf  (spu_mul_areg_shf),
                     .spu_mul_areg_rst  (spu_mul_areg_rst),
                     .spu_mul_op1_data  (spu_mul_op1_data[63:0]),
                     .spu_mul_op2_data  (spu_mul_op2_data[63:0]),
                     .spu_mul_mulres_lshft(spu_mul_mulres_lshft));
   
`endif //  `ifdef FPGA_SYN_NO_SPU

`ifdef FPGA_SYN_NO_SPU

   sparc_ffu ffu(
                 .short_si0             (short_scan0_4),
                 .short_so0             (short_scan0_6),
                 .si                    (scan0_5),
                 .so                    (scan0_6),
                 // reset stuff
                 .grst_l                (spc_grst_l),
                 .arst_l                (cmp_arst_l),
                 
	   // eco 6529 .
	   .lsu_ffu_st_dtlb_perr_g		(lsu_ffu_st_dtlb_perr_g),

                 .exu_ffu_ist_e         (ifu_lsu_st_inst_e),
                 .ifu_ffu_tid_d         (ifu_tlu_thrid_d[1:0]),
                 .cpx_fpu_data          (cpx_spc_data_cx2_buf[63:0]),
                 .cpx_vld             (cpx_spc_data_cx2_buf[`CPX_VLD]),
                 .cpx_fcmp            (cpx_spc_data_cx2_buf[69]),
                 .cpx_req             (cpx_spc_data_cx2_buf[`CPX_RQ_HI:`CPX_RQ_LO]),
                 .cpx_fccval          (cpx_spc_data_cx2_buf[68:67]),
                 .cpx_fpexc           (cpx_spc_data_cx2_buf[76:72]),                   
                 .exu_ffu_gsr_mask_m  (exu_tlu_wsr_data_m[63:32]),
                 .exu_ffu_gsr_scale_m (exu_tlu_wsr_data_m[7:3]),
                 .exu_ffu_gsr_align_m (exu_tlu_wsr_data_m[2:0]),
                 .exu_ffu_gsr_rnd_m   (exu_tlu_wsr_data_m[27:25]),
                 .ifu_ffu_ldst_single_d   (ifu_ffu_ldst_size_d),
		             /*AUTOINST*/
                 // Outputs
                 .ffu_lsu_data          (ffu_lsu_data[80:0]),
                 .ffu_ifu_cc_vld_w2     (ffu_ifu_cc_vld_w2[3:0]),
                 .ffu_ifu_cc_w2         (ffu_ifu_cc_w2[7:0]),
                 .ffu_ifu_ecc_ce_w2     (ffu_ifu_ecc_ce_w2),
                 .ffu_ifu_ecc_ue_w2     (ffu_ifu_ecc_ue_w2),
                 .ffu_ifu_err_reg_w2    (ffu_ifu_err_reg_w2[5:0]),
                 .ffu_ifu_err_synd_w2   (ffu_ifu_err_synd_w2[13:0]),
                 .ffu_ifu_fpop_done_w2  (ffu_ifu_fpop_done_w2),
                 .ffu_ifu_fst_ce_w      (ffu_ifu_fst_ce_w),
                 .ffu_ifu_inj_ack       (ffu_ifu_inj_ack),
                 .ffu_ifu_stallreq      (ffu_ifu_stallreq),
                 .ffu_ifu_tid_w2        (ffu_ifu_tid_w2[1:0]),
                 .ffu_lsu_blk_st_e      (ffu_lsu_blk_st_e),
                 .ffu_lsu_blk_st_va_e   (ffu_lsu_blk_st_va_e[5:3]),
                 .ffu_lsu_fpop_rq_vld   (ffu_lsu_fpop_rq_vld),
                 .ffu_lsu_kill_fst_w    (ffu_lsu_kill_fst_w),
                 .ffu_tlu_fpu_cmplt     (ffu_tlu_fpu_cmplt),
                 .ffu_tlu_fpu_tid       (ffu_tlu_fpu_tid[1:0]),
                 .ffu_tlu_ill_inst_m    (ffu_tlu_ill_inst_m),
                 .ffu_tlu_trap_ieee754  (ffu_tlu_trap_ieee754),
                 .ffu_tlu_trap_other    (ffu_tlu_trap_other),
                 .ffu_tlu_trap_ue       (ffu_tlu_trap_ue),
                 .ffu_exu_rsr_data_m    (ffu_exu_rsr_data_m[63:0]),
                 // Inputs
                 .mux_drive_disable     (mux_drive_disable),
                 .mem_write_disable     (mem_write_disable),
                 .exu_ffu_wsr_inst_e    (exu_ffu_wsr_inst_e),
                 .ifu_exu_disable_ce_e  (ifu_exu_disable_ce_e),
                 .ifu_exu_ecc_mask      (ifu_exu_ecc_mask[6:0]),
                 .ifu_exu_nceen_e       (ifu_exu_nceen_e),
                 .ifu_ffu_fcc_num_d     (ifu_ffu_fcc_num_d[1:0]),
                 .ifu_ffu_fld_d         (ifu_ffu_fld_d),
                 .ifu_ffu_fpop1_d       (ifu_ffu_fpop1_d),
                 .ifu_ffu_fpop2_d       (ifu_ffu_fpop2_d),
                 .ifu_ffu_fpopcode_d    (ifu_ffu_fpopcode_d[8:0]),
                 .ifu_ffu_frd_d         (ifu_ffu_frd_d[4:0]),
                 .ifu_ffu_frs1_d        (ifu_ffu_frs1_d[4:0]),
                 .ifu_ffu_frs2_d        (ifu_ffu_frs2_d[4:0]),
                 .ifu_ffu_fst_d         (ifu_ffu_fst_d),
                 .ifu_ffu_inj_frferr    (ifu_ffu_inj_frferr),
                 .ifu_ffu_ldfsr_d       (ifu_ffu_ldfsr_d),
                 .ifu_ffu_ldxfsr_d      (ifu_ffu_ldxfsr_d),
                 .ifu_ffu_mvcnd_m       (ifu_ffu_mvcnd_m),
                 .ifu_ffu_quad_op_e     (ifu_ffu_quad_op_e),
                 .ifu_ffu_stfsr_d       (ifu_ffu_stfsr_d),
                 .ifu_ffu_visop_d       (ifu_ffu_visop_d),
                 .ifu_lsu_ld_inst_e     (ifu_lsu_ld_inst_e),
                 .ifu_tlu_flsh_inst_e   (ifu_tlu_flsh_inst_e),
                 .ifu_tlu_flush_w       (ifu_tlu_flush_w),
                 .ifu_tlu_inst_vld_w    (ifu_tlu_inst_vld_w),
                 .ifu_tlu_sraddr_d      (ifu_tlu_sraddr_d[6:0]),
                 .lsu_ffu_ack           (lsu_ffu_ack),
                 .lsu_ffu_bld_cnt_w     (lsu_ffu_bld_cnt_w[2:0]),
                 .lsu_ffu_blk_asi_e     (lsu_ffu_blk_asi_e),
                 .lsu_ffu_flush_pipe_w  (lsu_ffu_flush_pipe_w),
                 .lsu_ffu_ld_data       (lsu_ffu_ld_data[63:0]),
                 .lsu_ffu_ld_vld        (lsu_ffu_ld_vld),
                 .lsu_ffu_stb_full0     (lsu_ffu_stb_full0),
                 .lsu_ffu_stb_full1     (lsu_ffu_stb_full1),
                 .lsu_ffu_stb_full2     (lsu_ffu_stb_full2),
                 .lsu_ffu_stb_full3     (lsu_ffu_stb_full3),
                 .rclk                  (rclk),
                 .se                    (se),
                 .sehold                (sehold));
  
`else
  
   sparc_ffu ffu(
                 .short_si0             (short_scan0_5),
                 .short_so0             (short_scan0_6),
                 .si                    (scan0_5),
                 .so                    (scan0_6),
                 // reset stuff
                 .grst_l                (spc_grst_l),
                 .arst_l                (cmp_arst_l),
                 
	   // eco 6529 .
	   .lsu_ffu_st_dtlb_perr_g		(lsu_ffu_st_dtlb_perr_g),

                 .exu_ffu_ist_e         (ifu_lsu_st_inst_e),
                 .ifu_ffu_tid_d         (ifu_tlu_thrid_d[1:0]),
                 .cpx_fpu_data          (cpx_spc_data_cx2_buf[63:0]),
                 .cpx_vld             (cpx_spc_data_cx2_buf[`CPX_VLD]),
                 .cpx_fcmp            (cpx_spc_data_cx2_buf[69]),
                 .cpx_req             (cpx_spc_data_cx2_buf[`CPX_RQ_HI:`CPX_RQ_LO]),
                 .cpx_fccval          (cpx_spc_data_cx2_buf[68:67]),
                 .cpx_fpexc           (cpx_spc_data_cx2_buf[76:72]),                   
                 .exu_ffu_gsr_mask_m  (exu_tlu_wsr_data_m[63:32]),
                 .exu_ffu_gsr_scale_m (exu_tlu_wsr_data_m[7:3]),
                 .exu_ffu_gsr_align_m (exu_tlu_wsr_data_m[2:0]),
                 .exu_ffu_gsr_rnd_m   (exu_tlu_wsr_data_m[27:25]),
                 .ifu_ffu_ldst_single_d   (ifu_ffu_ldst_size_d),
		             /*AUTOINST*/
                 // Outputs
                 .ffu_lsu_data          (ffu_lsu_data[80:0]),
                 .ffu_ifu_cc_vld_w2     (ffu_ifu_cc_vld_w2[3:0]),
                 .ffu_ifu_cc_w2         (ffu_ifu_cc_w2[7:0]),
                 .ffu_ifu_ecc_ce_w2     (ffu_ifu_ecc_ce_w2),
                 .ffu_ifu_ecc_ue_w2     (ffu_ifu_ecc_ue_w2),
                 .ffu_ifu_err_reg_w2    (ffu_ifu_err_reg_w2[5:0]),
                 .ffu_ifu_err_synd_w2   (ffu_ifu_err_synd_w2[13:0]),
                 .ffu_ifu_fpop_done_w2  (ffu_ifu_fpop_done_w2),
                 .ffu_ifu_fst_ce_w      (ffu_ifu_fst_ce_w),
                 .ffu_ifu_inj_ack       (ffu_ifu_inj_ack),
                 .ffu_ifu_stallreq      (ffu_ifu_stallreq),
                 .ffu_ifu_tid_w2        (ffu_ifu_tid_w2[1:0]),
                 .ffu_lsu_blk_st_e      (ffu_lsu_blk_st_e),
                 .ffu_lsu_blk_st_va_e   (ffu_lsu_blk_st_va_e[5:3]),
                 .ffu_lsu_fpop_rq_vld   (ffu_lsu_fpop_rq_vld),
                 .ffu_lsu_kill_fst_w    (ffu_lsu_kill_fst_w),
                 .ffu_tlu_fpu_cmplt     (ffu_tlu_fpu_cmplt),
                 .ffu_tlu_fpu_tid       (ffu_tlu_fpu_tid[1:0]),
                 .ffu_tlu_ill_inst_m    (ffu_tlu_ill_inst_m),
                 .ffu_tlu_trap_ieee754  (ffu_tlu_trap_ieee754),
                 .ffu_tlu_trap_other    (ffu_tlu_trap_other),
                 .ffu_tlu_trap_ue       (ffu_tlu_trap_ue),
                 .ffu_exu_rsr_data_m    (ffu_exu_rsr_data_m[63:0]),
                 // Inputs
                 .mux_drive_disable     (mux_drive_disable),
                 .mem_write_disable     (mem_write_disable),
                 .exu_ffu_wsr_inst_e    (exu_ffu_wsr_inst_e),
                 .ifu_exu_disable_ce_e  (ifu_exu_disable_ce_e),
                 .ifu_exu_ecc_mask      (ifu_exu_ecc_mask[6:0]),
                 .ifu_exu_nceen_e       (ifu_exu_nceen_e),
                 .ifu_ffu_fcc_num_d     (ifu_ffu_fcc_num_d[1:0]),
                 .ifu_ffu_fld_d         (ifu_ffu_fld_d),
                 .ifu_ffu_fpop1_d       (ifu_ffu_fpop1_d),
                 .ifu_ffu_fpop2_d       (ifu_ffu_fpop2_d),
                 .ifu_ffu_fpopcode_d    (ifu_ffu_fpopcode_d[8:0]),
                 .ifu_ffu_frd_d         (ifu_ffu_frd_d[4:0]),
                 .ifu_ffu_frs1_d        (ifu_ffu_frs1_d[4:0]),
                 .ifu_ffu_frs2_d        (ifu_ffu_frs2_d[4:0]),
                 .ifu_ffu_fst_d         (ifu_ffu_fst_d),
                 .ifu_ffu_inj_frferr    (ifu_ffu_inj_frferr),
                 .ifu_ffu_ldfsr_d       (ifu_ffu_ldfsr_d),
                 .ifu_ffu_ldxfsr_d      (ifu_ffu_ldxfsr_d),
                 .ifu_ffu_mvcnd_m       (ifu_ffu_mvcnd_m),
                 .ifu_ffu_quad_op_e     (ifu_ffu_quad_op_e),
                 .ifu_ffu_stfsr_d       (ifu_ffu_stfsr_d),
                 .ifu_ffu_visop_d       (ifu_ffu_visop_d),
                 .ifu_lsu_ld_inst_e     (ifu_lsu_ld_inst_e),
                 .ifu_tlu_flsh_inst_e   (ifu_tlu_flsh_inst_e),
                 .ifu_tlu_flush_w       (ifu_tlu_flush_w),
                 .ifu_tlu_inst_vld_w    (ifu_tlu_inst_vld_w),
                 .ifu_tlu_sraddr_d      (ifu_tlu_sraddr_d[6:0]),
                 .lsu_ffu_ack           (lsu_ffu_ack),
                 .lsu_ffu_bld_cnt_w     (lsu_ffu_bld_cnt_w[2:0]),
                 .lsu_ffu_blk_asi_e     (lsu_ffu_blk_asi_e),
                 .lsu_ffu_flush_pipe_w  (lsu_ffu_flush_pipe_w),
                 .lsu_ffu_ld_data       (lsu_ffu_ld_data[63:0]),
                 .lsu_ffu_ld_vld        (lsu_ffu_ld_vld),
                 .lsu_ffu_stb_full0     (lsu_ffu_stb_full0),
                 .lsu_ffu_stb_full1     (lsu_ffu_stb_full1),
                 .lsu_ffu_stb_full2     (lsu_ffu_stb_full2),
                 .lsu_ffu_stb_full3     (lsu_ffu_stb_full3),
                 .rclk                  (rclk),
                 .se                    (se),
                 .sehold                (sehold));

`endif //  `ifdef FPGA_SYN_NO_SPU
   
/*   test_stub_bist AUTO_TEMPLATE(
                                  // Outputs
                                  .so_0 (spc_scanout0),
                                  .so_1 (spc_scanout1),
                                  .mbist_data_mode(mbist_userdata_mode),
 
                                  // Inputs
                                  .mbist_err ({1'b0, mbist_dcache_fail, mbist_icache_fail}),
                                  .cluster_grst_l  (spc_grst_l),
                                  .arst_l (cmp_arst_l));
 */
   
`ifdef FPGA_SYN_NO_SPU

      test_stub_bist test_stub(
                            // unused
                            .so_2             (),
                            .long_chain_so_2  (1'b0),
                            .short_chain_so_2 (1'b0),

                            // connect with scan stitch
                            .si(scan1_4),
                            .so (scan1_5),
                            .long_chain_so_0  (scan0_7),
                            .short_chain_so_0 (short_scan0_6),
                            .long_chain_so_1  (scan1_5),
                            .short_chain_so_1 (short_scan1_4),
                            
                            // from LSU
                            .bist_ctl_reg_in(bist_ctl_reg_in[6:0]),
                            
                            /*AUTOINST*/
                            // Outputs
                            .mux_drive_disable(mux_drive_disable),
                            .mem_write_disable(mem_write_disable),
                            .sehold     (sehold),
                            .se         (se),
                            .testmode_l (testmode_l),
                            .mem_bypass (),
                            .so_0       (spc_scanout0),          // Templated
                            .so_1       (spc_scanout1),          // Templated
                            .tst_ctu_mbist_done(tst_ctu_mbist_done),
                            .tst_ctu_mbist_fail(tst_ctu_mbist_fail),
                            .bist_ctl_reg_out(bist_ctl_reg_out[10:0]),
                            .mbist_bisi_mode(mbist_bisi_mode),
                            .mbist_stop_on_next_fail(mbist_stop_on_next_fail),
                            .mbist_stop_on_fail(mbist_stop_on_fail),
                            .mbist_loop_mode(mbist_loop_mode),
                            .mbist_loop_on_addr(mbist_loop_on_addr),
                            .mbist_data_mode(mbist_userdata_mode), // Templated
                            .mbist_start(mbist_start),
                            // Inputs
                            .ctu_tst_pre_grst_l(ctu_tst_pre_grst_l),
                            .arst_l     (cmp_arst_l),            // Templated
                            .cluster_grst_l(spc_grst_l),         // Templated
                            .global_shift_enable(global_shift_enable),
                            .ctu_tst_scan_disable(ctu_tst_scan_disable),
                            .ctu_tst_scanmode(ctu_tst_scanmode),
                            .ctu_tst_macrotest(ctu_tst_macrotest),
                            .ctu_tst_short_chain(ctu_tst_short_chain),
                            .ctu_tst_mbist_enable(ctu_tst_mbist_enable),
                            .rclk       (rclk),
                            .bist_ctl_reg_wr_en(bist_ctl_reg_wr_en),
                            .mbist_done (mbist_done),
                            .mbist_err  ({1'b0, mbist_dcache_fail, mbist_icache_fail})); // Templated

`else

   test_stub_bist test_stub(
                            // unused
                            .so_2             (),
                            .long_chain_so_2  (1'b0),
                            .short_chain_so_2 (1'b0),

                            // connect with scan stitch
                            .si(scan1_4),
                            .so (scan1_5),
                            .long_chain_so_0  (scan0_7),
                            .short_chain_so_0 (short_scan0_6),
                            .long_chain_so_1  (scan1_5),
                            .short_chain_so_1 (short_scan1_5),
                            
                            // from LSU
                            .bist_ctl_reg_in(bist_ctl_reg_in[6:0]),
                            
                            /*AUTOINST*/
                            // Outputs
                            .mux_drive_disable(mux_drive_disable),
                            .mem_write_disable(mem_write_disable),
                            .sehold     (sehold),
                            .se         (se),
                            .testmode_l (testmode_l),
                            .mem_bypass (mem_bypass),
                            .so_0       (spc_scanout0),          // Templated
                            .so_1       (spc_scanout1),          // Templated
                            .tst_ctu_mbist_done(tst_ctu_mbist_done),
                            .tst_ctu_mbist_fail(tst_ctu_mbist_fail),
                            .bist_ctl_reg_out(bist_ctl_reg_out[10:0]),
                            .mbist_bisi_mode(mbist_bisi_mode),
                            .mbist_stop_on_next_fail(mbist_stop_on_next_fail),
                            .mbist_stop_on_fail(mbist_stop_on_fail),
                            .mbist_loop_mode(mbist_loop_mode),
                            .mbist_loop_on_addr(mbist_loop_on_addr),
                            .mbist_data_mode(mbist_userdata_mode), // Templated
                            .mbist_start(mbist_start),
                            // Inputs
                            .ctu_tst_pre_grst_l(ctu_tst_pre_grst_l),
                            .arst_l     (cmp_arst_l),            // Templated
                            .cluster_grst_l(spc_grst_l),         // Templated
                            .global_shift_enable(global_shift_enable),
                            .ctu_tst_scan_disable(ctu_tst_scan_disable),
                            .ctu_tst_scanmode(ctu_tst_scanmode),
                            .ctu_tst_macrotest(ctu_tst_macrotest),
                            .ctu_tst_short_chain(ctu_tst_short_chain),
                            .ctu_tst_mbist_enable(ctu_tst_mbist_enable),
                            .rclk       (rclk),
                            .bist_ctl_reg_wr_en(bist_ctl_reg_wr_en),
                            .mbist_done (mbist_done),
                            .mbist_err  ({1'b0, mbist_dcache_fail, mbist_icache_fail})); // Templated

`endif //  `ifdef FPGA_SYN_NO_SPU
   

/*  bw_clk_cl_sparc_cmp AUTO_TEMPLATE(
                               .si      (scan0_6),
                               .so      (scan0_7),                               
                           .arst_l       (cmp_arst_l),
                           .grst_l       (cmp_grst_l),
                           // Outputs
                           .dbginit_l    (spc_dbginit_l),
                           .cluster_grst_l   (spc_grst_l));
 */
   bw_clk_cl_sparc_cmp spc_hdr(/*AUTOINST*/
                               // Outputs
                               .cluster_grst_l(spc_grst_l),      // Templated
                               .dbginit_l(spc_dbginit_l),        // Templated
                               .rclk    (rclk),
                               .so      (scan0_7),               // Templated
                               // Inputs
                               .adbginit_l(adbginit_l),
                               .arst_l  (cmp_arst_l),            // Templated
                               .cluster_cken(cluster_cken),
                               .gclk    (gclk),
                               .gdbginit_l(gdbginit_l),
                               .grst_l  (cmp_grst_l),            // Templated
                               .se      (se),
                               .si      (scan0_6));               // Templated
endmodule // sparc


// Local Variables:
// verilog-library-directories:("../tlu/rtl" "../ifu/rtl" "../exu/rtl" "../lsu/rtl" "../spu/rtl" "../mul/rtl" "../ffu/rtl/" "../../common/rtl" ".")
// End:

     
