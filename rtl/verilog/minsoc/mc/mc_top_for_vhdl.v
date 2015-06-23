/*
 * Xiang Li, olivercamel@gmail.com
 * Last Revised: 2008/08/01
 *
 * This file is created as the new top level entity of
 * Memory Controller IP Core, which is nothing
 * but a wrapper of mc_top with some port names changed.
 * The reason of doing so is because identifiers in the
 * format of "xxx_" are not supported in VHDL,
 * but are valid in Verilog. So we have to use the wrapper
 * to make MC can be used in higher level VHDL entities.
 */

module mc_top_for_vhdl(
	clk_i, rst_i,

	wb_data_i, wb_data_o, wb_addr_i, wb_sel_i, wb_we_i, wb_cyc_i,
	wb_stb_i, wb_ack_o, wb_err_o, 

	susp_req_i, resume_req_i, suspended_o, poc_o,

	mc_clk_i, mc_br_pad_i, mc_bg_pad_o, mc_ack_pad_i,
	mc_addr_pad_o, mc_data_pad_i, mc_data_pad_o, mc_dp_pad_i,
	mc_dp_pad_o, mc_doe_pad_doe_o, mc_dqm_pad_o, mc_oe_pad_o,
	mc_we_pad_o, mc_cas_pad_o, mc_ras_pad_o, mc_cke_pad_o,
	mc_cs_pad_o, mc_sts_pad_i, mc_rp_pad_o, mc_vpen_pad_o,
	mc_adsc_pad_o, mc_adv_pad_o, mc_zz_pad_o, mc_coe_pad_coe_o
	);

input             clk_i, rst_i;

// --------------------------------------
// WISHBONE SLAVE INTERFACE 
input  [31:0]     wb_data_i;
output [31:0]     wb_data_o;
input  [31:0]     wb_addr_i;
input  [3:0]      wb_sel_i;
input             wb_we_i;
input             wb_cyc_i;
input             wb_stb_i;
output            wb_ack_o;
output            wb_err_o;

// --------------------------------------
// Suspend Resume Interface
input             susp_req_i;
input             resume_req_i;
output            suspended_o;

// POC
output [31:0]     poc_o;

// --------------------------------------
// Memory Bus Signals
input             mc_clk_i;
input             mc_br_pad_i;
output            mc_bg_pad_o;
input             mc_ack_pad_i;
output [23:0]     mc_addr_pad_o;
input  [31:0]     mc_data_pad_i;
output [31:0]     mc_data_pad_o;
input  [3:0]      mc_dp_pad_i;
output [3:0]      mc_dp_pad_o;
output            mc_doe_pad_doe_o;
output [3:0]      mc_dqm_pad_o;
output            mc_oe_pad_o;
output            mc_we_pad_o;
output            mc_cas_pad_o;
output            mc_ras_pad_o;
output            mc_cke_pad_o;
output [7:0]      mc_cs_pad_o;
input             mc_sts_pad_i;
output            mc_rp_pad_o;
output            mc_vpen_pad_o;
output            mc_adsc_pad_o;
output            mc_adv_pad_o;
output            mc_zz_pad_o;
output            mc_coe_pad_coe_o;

mc_top u0(
.clk_i            (clk_i),
.rst_i            (rst_i),

.wb_data_i        (wb_data_i),
.wb_data_o        (wb_data_o),
.wb_addr_i        (wb_addr_i),
.wb_sel_i         (wb_sel_i),
.wb_we_i          (wb_we_i),
.wb_cyc_i         (wb_cyc_i),
.wb_stb_i         (wb_stb_i),
.wb_ack_o         (wb_ack_o),
.wb_err_o         (wb_err_o),

.susp_req_i       (susp_req_i),
.resume_req_i     (resume_req_i),
.suspended_o      (suspended_o),
.poc_o            (poc_o),

.mc_clk_i         (mc_clk_i),
.mc_br_pad_i      (mc_br_pad_i),
.mc_bg_pad_o      (mc_bg_pad_o),
.mc_ack_pad_i     (mc_ack_pad_i),
.mc_addr_pad_o    (mc_addr_pad_o),
.mc_data_pad_i    (mc_data_pad_i),
.mc_data_pad_o    (mc_data_pad_o),
.mc_dp_pad_i      (mc_dp_pad_i),
.mc_dp_pad_o      (mc_dp_pad_o),
.mc_doe_pad_doe_o (mc_doe_pad_doe_o),
.mc_dqm_pad_o     (mc_dqm_pad_o),
.mc_oe_pad_o_     (mc_oe_pad_o),
.mc_we_pad_o_     (mc_we_pad_o),
.mc_cas_pad_o_    (mc_cas_pad_o),
.mc_ras_pad_o_    (mc_ras_pad_o),
.mc_cke_pad_o_    (mc_cke_pad_o),
.mc_cs_pad_o_     (mc_cs_pad_o),
.mc_sts_pad_i     (mc_sts_pad_i),
.mc_rp_pad_o_     (mc_rp_pad_o),
.mc_vpen_pad_o    (mc_vpen_pad_o),
.mc_adsc_pad_o_   (mc_adsc_pad_o),
.mc_adv_pad_o_    (mc_adv_pad_o),
.mc_zz_pad_o      (mc_zz_pad_o),
.mc_coe_pad_coe_o (mc_coe_pad_coe_o)
);

endmodule
