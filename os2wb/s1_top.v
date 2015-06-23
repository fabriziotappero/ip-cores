/*
 * Simply RISC S1 Core Top-Level
 *
 * (C) 2007 Simply RISC LLP
 * AUTHOR: Fabrizio Fazzino <fabrizio.fazzino@srisc.com>
 *
 * LICENSE:
 * This is a Free Hardware Design; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * version 2 as published by the Free Software Foundation.
 * The above named program is distributed in the hope that it will
 * be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * DESCRIPTION:
 * This block implements the top-level of the S1 Core.
 * It is just a schematic with four instances:
 * 1) one single SPARC Core of the OpenSPARC T1;
 * 2) a SPARC Core to Wishbone Master bridge;
 * 3) a Reset Controller;
 * 4) an Interrupt Controller.
 *
 */
	 
module s1_top (
    input         sys_clock_i, 
    input         sys_reset_i, 
    
    input         eth_irq_i,
    
    input         wbm_ack_i, 
    input  [63:0] wbm_data_i,
    output        wbm_cycle_o, 
    output        wbm_strobe_o, 
    output        wbm_we_o, 
    output [63:0] wbm_addr_o, 
    output [63:0] wbm_data_o, 
    output [ 7:0] wbm_sel_o
);
  /*
   * Wires
   */

  // Wires connected to SPARC Core outputs

  // pcx
  wire [4:0]   spc_pcx_req_pq;    // processor to pcx request
  wire         spc_pcx_atom_pq;   // processor to pcx atomic request
  wire [123:0] spc_pcx_data_pa;  // processor to pcx packet
  wire [4:0]   spc1_pcx_req_pq;    // processor to pcx request
  wire         spc1_pcx_atom_pq;   // processor to pcx atomic request
  wire [123:0] spc1_pcx_data_pa;  // processor to pcx packet

  // shadow scan
  wire     spc_sscan_so;         // From ifu of sparc_ifu.v
  wire     spc_scanout0;         // From test_stub of test_stub_bist.v
  wire     spc_scanout1;         // From test_stub of test_stub_bist.v

  // bist
  wire     tst_ctu_mbist_done;  // From test_stub of test_stub_two_bist.v
  wire     tst_ctu_mbist_fail;  // From test_stub of test_stub_two_bist.v

  // fuse
  wire     spc_efc_ifuse_data;     // From ifu of sparc_ifu.v
  wire     spc_efc_dfuse_data;     // From ifu of sparc_ifu.v

  // Wires connected to SPARC Core inputs

  // cpx interface
  wire [4:0] pcx_spc_grant_px; // pcx to processor grant info  
  wire       cpx_spc_data_rdy_cx2; // cpx data inflight to sparc  
  wire [144:0] cpx_spc_data_cx2;     // cpx to sparc data packet
  wire [4:0] pcx1_spc_grant_px; // pcx to processor grant info  
  wire       cpx1_spc_data_rdy_cx2; // cpx data inflight to sparc  
  wire [144:0] cpx1_spc_data_cx2;     // cpx to sparc data packet

  wire [3:0]  const_cpuid;
  wire [3:0]  const_cpuid1;
  wire [7:0]  const_maskid;           // To ifu of sparc_ifu.v

  // sscan
  wire        ctu_tck;                // To ifu of sparc_ifu.v
  wire        ctu_sscan_se;           // To ifu of sparc_ifu.v
  wire        ctu_sscan_snap;         // To ifu of sparc_ifu.v
  wire [3:0]  ctu_sscan_tid;          // To ifu of sparc_ifu.v

  // bist
  wire        ctu_tst_mbist_enable;   // To test_stub of test_stub_bist.v

  // efuse
  wire        efc_spc_fuse_clk1;
  wire        efc_spc_fuse_clk2;
  wire        efc_spc_ifuse_ashift;
  wire        efc_spc_ifuse_dshift;
  wire        efc_spc_ifuse_data;
  wire        efc_spc_dfuse_ashift;
  wire        efc_spc_dfuse_dshift;
  wire        efc_spc_dfuse_data;

  // scan and macro test
  wire        ctu_tst_macrotest;      // To test_stub of test_stub_bist.v
  wire        ctu_tst_scan_disable;   // To test_stub of test_stub_bist.v
  wire        ctu_tst_short_chain;    // To test_stub of test_stub_bist.v
  wire        global_shift_enable;    // To test_stub of test_stub_two_bist.v
  wire        ctu_tst_scanmode;       // To test_stub of test_stub_two_bist.v
  wire        spc_scanin0;
  wire        spc_scanin1;
   
  // clk
  wire        cluster_cken;           // To spc_hdr of cluster_header.v
  wire        gclk;                   // To spc_hdr of cluster_header.v

  // reset
  wire        cmp_grst_l;
  wire        cmp_arst_l;
  wire        ctu_tst_pre_grst_l;     // To test_stub of test_stub_bist.v

  wire        adbginit_l;             // To spc_hdr of cluster_header.v
  wire        gdbginit_l;             // To spc_hdr of cluster_header.v

  // Reset signal from the reset controller to the bridge
  wire sys_reset_final;

  // Interrupt Source from the interrupt controller to the bridge

  /*
   * SPARC Core module instance
   */
reg [  4:0] pcx_spc_grant_px_fifo;
reg [  4:0] pcx1_spc_grant_px_fifo;

  sparc sparc_0 (

    // Wires connected to SPARC Core outputs
    .spc_pcx_req_pq(spc_pcx_req_pq),
    .spc_pcx_atom_pq(spc_pcx_atom_pq),
    .spc_pcx_data_pa(spc_pcx_data_pa),
    .spc_sscan_so(spc_sscan_so),
    .spc_scanout0(spc_scanout0),
    .spc_scanout1(spc_scanout1),
    .tst_ctu_mbist_done(tst_ctu_mbist_done),
    .tst_ctu_mbist_fail(tst_ctu_mbist_fail),
    .spc_efc_ifuse_data(spc_efc_ifuse_data),
    .spc_efc_dfuse_data(spc_efc_dfuse_data),

    // Wires connected to SPARC Core inputs
    .pcx_spc_grant_px(pcx_spc_grant_px),
    .cpx_spc_data_rdy_cx2(cpx_spc_data_rdy_cx2),
    .cpx_spc_data_cx2(cpx_spc_data_cx2),
    .const_cpuid(const_cpuid),
    .const_maskid(const_maskid),
    .ctu_tck(ctu_tck),
    .ctu_sscan_se(ctu_sscan_se),
    .ctu_sscan_snap(ctu_sscan_snap),
    .ctu_sscan_tid(ctu_sscan_tid),
    .ctu_tst_mbist_enable(ctu_tst_mbist_enable),
    .efc_spc_fuse_clk1(efc_spc_fuse_clk1),
    .efc_spc_fuse_clk2(efc_spc_fuse_clk2),
    .efc_spc_ifuse_ashift(efc_spc_ifuse_ashift),
    .efc_spc_ifuse_dshift(efc_spc_ifuse_dshift),
    .efc_spc_ifuse_data(efc_spc_ifuse_data),
    .efc_spc_dfuse_ashift(efc_spc_dfuse_ashift),
    .efc_spc_dfuse_dshift(efc_spc_dfuse_dshift),
    .efc_spc_dfuse_data(efc_spc_dfuse_data),
    .ctu_tst_macrotest(ctu_tst_macrotest),
    .ctu_tst_scan_disable(ctu_tst_scan_disable),
    .ctu_tst_short_chain(ctu_tst_short_chain),
    .global_shift_enable(global_shift_enable),
    .ctu_tst_scanmode(ctu_tst_scanmode),
    .spc_scanin0(spc_scanin0),
    .spc_scanin1(spc_scanin1),
    .cluster_cken(cluster_cken),
    .gclk(gclk),
    .cmp_grst_l(cmp_grst_l),
    .cmp_arst_l(cmp_arst_l),
    .ctu_tst_pre_grst_l(ctu_tst_pre_grst_l),
    .adbginit_l(adbginit_l),
    .gdbginit_l(gdbginit_l)

  );

  sparc sparc_1 (

    // Wires connected to SPARC Core outputs
    .spc_pcx_req_pq(spc1_pcx_req_pq),
    .spc_pcx_atom_pq(spc1_pcx_atom_pq),
    .spc_pcx_data_pa(spc1_pcx_data_pa),
    .spc_sscan_so(spc_sscan_so),
    .spc_scanout0(spc_scanout0),
    .spc_scanout1(spc_scanout1),
    .tst_ctu_mbist_done(tst_ctu_mbist_done),
    .tst_ctu_mbist_fail(tst_ctu_mbist_fail),
    .spc_efc_ifuse_data(spc_efc_ifuse_data),
    .spc_efc_dfuse_data(spc_efc_dfuse_data),

    // Wires connected to SPARC Core inputs
    .pcx_spc_grant_px(pcx1_spc_grant_px),
    .cpx_spc_data_rdy_cx2(cpx1_spc_data_rdy_cx2),
    .cpx_spc_data_cx2(cpx1_spc_data_cx2),
    .const_cpuid(const_cpuid1),
    .const_maskid(const_maskid),
    .ctu_tck(ctu_tck),
    .ctu_sscan_se(ctu_sscan_se),
    .ctu_sscan_snap(ctu_sscan_snap),
    .ctu_sscan_tid(ctu_sscan_tid),
    .ctu_tst_mbist_enable(ctu_tst_mbist_enable),
    .efc_spc_fuse_clk1(efc_spc_fuse_clk1),
    .efc_spc_fuse_clk2(efc_spc_fuse_clk2),
    .efc_spc_ifuse_ashift(efc_spc_ifuse_ashift),
    .efc_spc_ifuse_dshift(efc_spc_ifuse_dshift),
    .efc_spc_ifuse_data(efc_spc_ifuse_data),
    .efc_spc_dfuse_ashift(efc_spc_dfuse_ashift),
    .efc_spc_dfuse_dshift(efc_spc_dfuse_dshift),
    .efc_spc_dfuse_data(efc_spc_dfuse_data),
    .ctu_tst_macrotest(ctu_tst_macrotest),
    .ctu_tst_scan_disable(ctu_tst_scan_disable),
    .ctu_tst_short_chain(ctu_tst_short_chain),
    .global_shift_enable(global_shift_enable),
    .ctu_tst_scanmode(ctu_tst_scanmode),
    .spc_scanin0(spc_scanin0),
    .spc_scanin1(spc_scanin1),
    .cluster_cken(cluster_cken),
    .gclk(gclk),
    .cmp_grst_l(cmp_grst_l),
    .cmp_arst_l(cmp_arst_l),
    .ctu_tst_pre_grst_l(ctu_tst_pre_grst_l),
    .adbginit_l(adbginit_l),
    .gdbginit_l(gdbginit_l)

  );

  /*
   * SPARC Core to Wishbone Master bridge
   */

wire         fp_req;
wire [123:0] fp_pcx;
wire [  7:0] fp_rdy;
wire [144:0] fp_cpx;

os2wb_dual os2wb_inst (
    .clk(sys_clock_i), 
    .rstn(~sys_reset_final), 
    
    .pcx_req(spc_pcx_req_pq), 
    .pcx_atom(spc_pcx_atom_pq), 
    .pcx_data(spc_pcx_data_pa), 
    .pcx_grant(pcx_spc_grant_px), 
    .cpx_ready(cpx_spc_data_rdy_cx2), 
    .cpx_packet(cpx_spc_data_cx2), 
	 
    .pcx1_req(spc1_pcx_req_pq), 
    .pcx1_atom(spc1_pcx_atom_pq), 
    .pcx1_data(spc1_pcx_data_pa), 
    .pcx1_grant(pcx1_spc_grant_px), 
    .cpx1_ready(cpx1_spc_data_rdy_cx2), 
    .cpx1_packet(cpx1_spc_data_cx2), 

    .wb_data_i(wbm_data_i), 
    .wb_ack(wbm_ack_i), 
    .wb_cycle(wbm_cycle_o), 
    .wb_strobe(wbm_strobe_o), 
    .wb_we(wbm_we_o), 
    .wb_sel(wbm_sel_o), 
    .wb_addr(wbm_addr_o), 
    .wb_data_o(wbm_data_o),
    
    .fp_pcx(fp_pcx),
    .fp_req(fp_req),
    .fp_cpx(fp_cpx),
    .fp_rdy(fp_rdy!=8'h00),
    
    .eth_int(0/*eth_irq_i*/)
);

// FPU
fpu fpu_inst(
	.pcx_fpio_data_rdy_px2(fp_req),
	.pcx_fpio_data_px2(fp_pcx),
	.arst_l(cmp_arst_l),
	.grst_l(cmp_grst_l),
	.gclk(gclk),
	.cluster_cken(cluster_cken),
	
	.fp_cpx_req_cq(fp_rdy),
	.fp_cpx_data_ca(fp_cpx),

	.ctu_tst_pre_grst_l(ctu_tst_pre_grst_l),
	.global_shift_enable(global_shift_enable),
	.ctu_tst_scan_disable(ctu_tst_scan_disable),
	.ctu_tst_scanmode(ctu_tst_scanmode),
	.ctu_tst_macrotest(ctu_tst_macrotest),
	.ctu_tst_short_chain(ctu_tst_short_chain),

	.si(0),
	.so()
);

  /*
   * Reset Controller
   */

  rst_ctrl rst_ctrl_0 (

    // Top-level system inputs
    .sys_clock_i(sys_clock_i),
    .sys_reset_i(sys_reset_i),

    // Reset Controller outputs connected to SPARC Core inputs
    .cluster_cken_o(cluster_cken),
    .gclk_o(gclk),
    .cmp_grst_o(cmp_grst_l),
    .cmp_arst_o(cmp_arst_l),
    .ctu_tst_pre_grst_o(ctu_tst_pre_grst_l),
    .adbginit_o(adbginit_l),
    .gdbginit_o(gdbginit_l),
    .sys_reset_final_o(sys_reset_final)

  );

  /*
   * Continuous assignments
   */

  assign const_cpuid = 4'h0;
  assign const_cpuid1 = 4'h1;
  assign const_maskid = 8'h20;

  // sscan
  assign ctu_tck = 1'b0;
  assign ctu_sscan_se = 1'b0;
  assign ctu_sscan_snap = 1'b0;
  assign ctu_sscan_tid = 4'h1;

  // bist
  assign ctu_tst_mbist_enable = 1'b0;

  // efuse
  assign efc_spc_fuse_clk1 = 1'b0;     // Activity
  assign efc_spc_fuse_clk2 = 1'b0;     // Activity
  assign efc_spc_ifuse_ashift = 1'b0;
  assign efc_spc_ifuse_dshift = 1'b0;
  assign efc_spc_ifuse_data = 1'b0;    // Activity
  assign efc_spc_dfuse_ashift = 1'b0;
  assign efc_spc_dfuse_dshift = 1'b0;
  assign efc_spc_dfuse_data = 1'b0;    // Activity

  // scan and macro test
  assign ctu_tst_macrotest = 1'b0;
  assign ctu_tst_scan_disable = 1'b0;
  assign ctu_tst_short_chain = 1'b0;
  assign global_shift_enable = 1'b0;
  assign ctu_tst_scanmode = 1'b0;
  assign spc_scanin0 = 1'b0;
  assign spc_scanin1 = 1'b0;

endmodule
