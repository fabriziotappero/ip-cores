/*
 * Milkymist VJ SoC
 * Copyright (C) 2007, 2008, 2009 Sebastien Bourdeauducq
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

module hpdmc #(
	parameter csr_addr = 4'h0,
	/*
	 * The depth of the SDRAM array, in bytes.
	 * Capacity (in bytes) is 2^sdram_depth.
	 */
	parameter sdram_depth = 26,
	
	/*
	 * The number of column address bits of the SDRAM.
	 */
	parameter sdram_columndepth = 9
) (
	input sys_clk,
	input sys_clk_n,
	/*
	 * Clock used to generate DQS.
	 * Typically sys_clk phased out by 90 degrees,
	 * as data is sent synchronously to sys_clk.
	 */
	input dqs_clk,
	input dqs_clk_n,
	
	input sys_rst,
	
	/* Control interface */
	input [13:0] csr_a,
	input csr_we,
	input [31:0] csr_di,
	output [31:0] csr_do,
	
	/* Simple FML 4x64 interface to the memory contents */
	input [sdram_depth-1:0] fml_adr,
	input fml_stb,
	input fml_we,
	output fml_ack,
	input [7:0] fml_sel,
	input [63:0] fml_di,
	output [63:0] fml_do,
	
	/* SDRAM interface.
	 * The SDRAM clock should be driven synchronously to the system clock.
	 * It is not generated inside this core so you can take advantage of
	 * architecture-dependent clocking resources to generate a clean
	 * differential clock.
	 */
	output reg sdram_cke,
	output reg sdram_cs_n,
	output reg sdram_we_n,
	output reg sdram_cas_n,
	output reg sdram_ras_n,
	output reg [12:0] sdram_adr,
	output reg [1:0] sdram_ba,
	
	output [3:0] sdram_dm,
	inout [31:0] sdram_dq,
	inout [3:0] sdram_dqs,
	
	/* Interface to the DCM generating DQS */
	output dqs_psen,
	output dqs_psincdec,
	input dqs_psdone,

	input [1:0] pll_stat
);

/* Register all control signals, leaving the possibility to use IOB registers */
wire sdram_cke_r;
wire sdram_cs_n_r;
wire sdram_we_n_r;
wire sdram_cas_n_r;
wire sdram_ras_n_r;
wire [12:0] sdram_adr_r;
wire [1:0] sdram_ba_r;

always @(posedge sys_clk) begin
	sdram_cke <= sdram_cke_r;
	sdram_cs_n <= sdram_cs_n_r;
	sdram_we_n <= sdram_we_n_r;
	sdram_cas_n <= sdram_cas_n_r;
	sdram_ras_n <= sdram_ras_n_r;
	sdram_ba <= sdram_ba_r;
	sdram_adr <= sdram_adr_r;
end

/* Mux the control signals according to the "bypass" selection.
 * CKE always comes from the control interface.
 */
wire bypass;

wire sdram_cs_n_bypass;
wire sdram_we_n_bypass;
wire sdram_cas_n_bypass;
wire sdram_ras_n_bypass;
wire [12:0] sdram_adr_bypass;
wire [1:0] sdram_ba_bypass;

wire sdram_cs_n_mgmt;
wire sdram_we_n_mgmt;
wire sdram_cas_n_mgmt;
wire sdram_ras_n_mgmt;
wire [12:0] sdram_adr_mgmt;
wire [1:0] sdram_ba_mgmt;

assign sdram_cs_n_r = bypass ? sdram_cs_n_bypass : sdram_cs_n_mgmt;
assign sdram_we_n_r = bypass ? sdram_we_n_bypass : sdram_we_n_mgmt;
assign sdram_cas_n_r = bypass ? sdram_cas_n_bypass : sdram_cas_n_mgmt;
assign sdram_ras_n_r = bypass ? sdram_ras_n_bypass : sdram_ras_n_mgmt;
assign sdram_adr_r = bypass ? sdram_adr_bypass : sdram_adr_mgmt;
assign sdram_ba_r = bypass ? sdram_ba_bypass : sdram_ba_mgmt;

/* Control interface */
wire sdram_rst;

wire [2:0] tim_rp;
wire [2:0] tim_rcd;
wire tim_cas;
wire [10:0] tim_refi;
wire [3:0] tim_rfc;
wire [1:0] tim_wr;

wire idelay_rst;
wire idelay_ce;
wire idelay_inc;

hpdmc_ctlif #(
	.csr_addr(csr_addr)
) ctlif (
	.sys_clk(sys_clk),
	.sys_rst(sys_rst),
	
	.csr_a(csr_a),
	.csr_we(csr_we),
	.csr_di(csr_di),
	.csr_do(csr_do),
	
	.bypass(bypass),
	.sdram_rst(sdram_rst),
	
	.sdram_cke(sdram_cke_r),
	.sdram_cs_n(sdram_cs_n_bypass),
	.sdram_we_n(sdram_we_n_bypass),
	.sdram_cas_n(sdram_cas_n_bypass),
	.sdram_ras_n(sdram_ras_n_bypass),
	.sdram_adr(sdram_adr_bypass),
	.sdram_ba(sdram_ba_bypass),
	
	.tim_rp(tim_rp),
	.tim_rcd(tim_rcd),
	.tim_cas(tim_cas),
	.tim_refi(tim_refi),
	.tim_rfc(tim_rfc),
	.tim_wr(tim_wr),
	
	.idelay_rst(idelay_rst),
	.idelay_ce(idelay_ce),
	.idelay_inc(idelay_inc),
	
	.dqs_psen(dqs_psen),
	.dqs_psincdec(dqs_psincdec),
	.dqs_psdone(dqs_psdone),

	.pll_stat(pll_stat)
);

/* SDRAM management unit */
wire mgmt_stb;
wire mgmt_we;
wire [sdram_depth-3-1:0] mgmt_address;
wire mgmt_ack;

wire read;
wire write;
wire [3:0] concerned_bank;
wire read_safe;
wire write_safe;
wire [3:0] precharge_safe;

hpdmc_mgmt #(
	.sdram_depth(sdram_depth),
	.sdram_columndepth(sdram_columndepth)
) mgmt (
	.sys_clk(sys_clk),
	.sdram_rst(sdram_rst),
	
	.tim_rp(tim_rp),
	.tim_rcd(tim_rcd),
	.tim_refi(tim_refi),
	.tim_rfc(tim_rfc),
	
	.stb(mgmt_stb),
	.we(mgmt_we),
	.address(mgmt_address),
	.ack(mgmt_ack),
	
	.read(read),
	.write(write),
	.concerned_bank(concerned_bank),
	.read_safe(read_safe),
	.write_safe(write_safe),
	.precharge_safe(precharge_safe),
	
	.sdram_cs_n(sdram_cs_n_mgmt),
	.sdram_we_n(sdram_we_n_mgmt),
	.sdram_cas_n(sdram_cas_n_mgmt),
	.sdram_ras_n(sdram_ras_n_mgmt),
	.sdram_adr(sdram_adr_mgmt),
	.sdram_ba(sdram_ba_mgmt)
);

/* Bus interface */
wire data_ack;

hpdmc_busif #(
	.sdram_depth(sdram_depth)
) busif (
	.sys_clk(sys_clk),
	.sdram_rst(sdram_rst),
	
	.fml_adr(fml_adr),
	.fml_stb(fml_stb),
	.fml_we(fml_we),
	.fml_ack(fml_ack),
	
	.mgmt_stb(mgmt_stb),
	.mgmt_we(mgmt_we),
	.mgmt_address(mgmt_address),
	.mgmt_ack(mgmt_ack),
	
	.data_ack(data_ack)
);

/* Data path controller */
wire direction;
wire direction_r;

hpdmc_datactl datactl(
	.sys_clk(sys_clk),
	.sdram_rst(sdram_rst),
	
	.read(read),
	.write(write),
	.concerned_bank(concerned_bank),
	.read_safe(read_safe),
	.write_safe(write_safe),
	.precharge_safe(precharge_safe),
	
	.ack(data_ack),
	.direction(direction),
	.direction_r(direction_r),
	
	.tim_cas(tim_cas),
	.tim_wr(tim_wr)
);

/* Data path */
hpdmc_ddrio ddrio(
	.sys_clk(sys_clk),
	.sys_clk_n(sys_clk_n),
	.dqs_clk(dqs_clk),
	.dqs_clk_n(dqs_clk_n),
	
	.direction(direction),
	.direction_r(direction_r),
	/* Bit meaning is the opposite between
	 * the FML selection signal and SDRAM DM pins.
	 */
	.mo(~fml_sel),
	.do(fml_di),
	.di(fml_do),
	
	.sdram_dm(sdram_dm),
	.sdram_dq(sdram_dq),
	.sdram_dqs(sdram_dqs),
	
	.idelay_rst(idelay_rst),
	.idelay_ce(idelay_ce),
	.idelay_inc(idelay_inc)
);

endmodule
