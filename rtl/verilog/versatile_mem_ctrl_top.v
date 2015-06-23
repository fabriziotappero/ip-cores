/*
module `BASE`MODULE ( 
`undef MODULE
	// wishbone slave side
	wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_bte_i, wbs_cti_i, wbs_we_i, wbs_cyc_i, wbs_stb_i, wbs_dat_o, wbs_ack_o, wbs_clk, wbs_rst,
	// wishbone master side
	wbm_dat_o, wbm_adr_o, wbm_sel_o, wbm_bte_o, wbm_cti_o, wbm_we_o, wbm_cyc_o, wbm_stb_o, wbm_dat_i, wbm_ack_i, wbm_clk, wbm_rst);

`ifdef WB3_ARBITER_TYPE1
`define MODULE wb3_arbiter_type1
module `BASE`MODULE (
`undef MODULE
    wbm_dat_o, wbm_adr_o, wbm_sel_o, wbm_cti_o, wbm_bte_o, wbm_we_o, wbm_stb_o, wbm_cyc_o,
    wbm_dat_i, wbm_ack_i, wbm_err_i, wbm_rty_i,
    wbs_dat_i, wbs_adr_i, wbs_sel_i, wbs_cti_i, wbs_bte_i, wbs_we_i, wbs_stb_i, wbs_cyc_i,
    wbs_dat_o, wbs_ack_o, wbs_err_o, wbs_rty_o,
    wb_clk, wb_rst
);
*/
//`include "versatile_mem_ctrl_defines.v"
`define MODULE top
module `BASE`MODULE (
`undef MODULE
    input  [31:0] wbs_1_dat_i,
    input  [`WB_ADR_SIZE-1:2] wbs_1_adr_i,
    input   [3:0] wbs_1_sel_i,
    input   [2:0] wbs_1_cti_i,
    input   [1:0] wbs_1_bte_i,
    input         wbs_1_we_i,
    input         wbs_1_stb_i,
    input         wbs_1_cyc_i,
    output [31:0] wbs_1_dat_o,
    output        wbs_1_ack_o,
    input         wbs_1_clk_i,
    input         wbs_1_rst_i,
`ifdef WB_GRPS_2
    input  [31:0] wbs_2_dat_i,
    input  [`WB_ADR_SIZE-1:2] wbs_2_adr_i,
    input   [3:0] wbs_2_sel_i,
    input   [2:0] wbs_2_cti_i,
    input   [1:0] wbs_2_bte_i,
    input         wbs_2_we_i,
    input         wbs_2_stb_i,
    input         wbs_2_cyc_i,
    output [31:0] wbs_2_dat_o,
    output        wbs_2_ack_o,
    input         wbs_2_clk_i,
    input         wbs_2_rst_i,
`endif
`ifdef WB_GRPS_3
    input  [31:0] wbs_3_dat_i,
    input  [`WB_ADR_SIZE-1:2] wbs_3_adr_i,
    input   [3:0] wbs_3_sel_i,
    input   [2:0] wbs_3_cti_i,
    input   [1:0] wbs_3_bte_i,
    input         wbs_3_we_i,
    input         wbs_3_stb_i,
    input         wbs_3_cyc_i,
    output [31:0] wbs_3_dat_o,
    output        wbs_3_ack_o,
    input         wbs_3_clk_i,
    input         wbs_3_rst_i,
`endif
`ifdef WB_GRPS_4
    input  [31:0] wbs_4_dat_i,
    input  [`WB_ADR_SIZE-1:2] wbs_4_adr_i,
    input   [3:0] wbs_4_sel_i,
    input   [2:0] wbs_4_cti_i,
    input   [1:0] wbs_4_bte_i,
    input         wbs_4_we_i,
    input         wbs_4_stb_i,
    input         wbs_4_cyc_i,
    output [31:0] wbs_4_dat_o,
    output        wbs_4_ack_o,
    input         wbs_4_clk_i,
    input         wbs_4_rst_i,
`endif
`ifdef WB_GRPS_5
    input  [31:0] wbs_5_dat_i,
    input  [`WB_ADR_SIZE-1:2] wbs_5_adr_i,
    input   [3:0] wbs_5_sel_i,
    input   [2:0] wbs_5_cti_i,
    input   [1:0] wbs_5_bte_i,
    input         wbs_5_we_i,
    input         wbs_5_stb_i,
    input         wbs_5_cyc_i,
    output [31:0] wbs_5_dat_o,
    output        wbs_5_ack_o,
    input         wbs_5_clk_i,
    input         wbs_5_rst_i,
`endif
`ifdef WB_GRPS_6
    input  [31:0] wbs_6_dat_i,
    input  [`WB_ADR_SIZE-1:2] wbs_6_adr_i,
    input   [3:0] wbs_6_sel_i,
    input   [2:0] wbs_6_cti_i,
    input   [1:0] wbs_6_bte_i,
    input         wbs_6_we_i,
    input         wbs_6_stb_i,
    input         wbs_6_cyc_i,
    output [31:0] wbs_6_dat_o,
    output        wbs_6_ack_o,
    input         wbs_6_clk_i,
    input         wbs_6_rst_i,
`endif
`ifdef WB_GRPS_7
    input  [31:0] wbs_7_dat_i,
    input  [`WB_ADR_SIZE-1:2] wbs_7_adr_i,
    input   [3:0] wbs_7_sel_i,
    input   [2:0] wbs_7_cti_i,
    input   [1:0] wbs_7_bte_i,
    input         wbs_7_we_i,
    input         wbs_7_stb_i,
    input         wbs_7_cyc_i,
    output [31:0] wbs_7_dat_o,
    output        wbs_7_ack_o,
    input         wbs_7_clk_i,
    input         wbs_7_rst_i,
`endif
`ifdef WB_GRPS_8
    input  [31:0] wbs_8_dat_i,
    input  [`WB_ADR_SIZE-1:2] wbs_8_adr_i,
    input   [3:0] wbs_8_sel_i,
    input   [2:0] wbs_8_cti_i,
    input   [1:0] wbs_8_bte_i,
    input         wbs_8_we_i,
    input         wbs_8_stb_i,
    input         wbs_8_cyc_i,
    output [31:0] wbs_8_dat_o,
    output        wbs_8_ack_o,
    input         wbs_8_clk_i,
    input         wbs_8_rst_i,
`endif
`ifdef SDR
    output  [1:0] ba,
    output [12:0] a,
    output  [2:0] cmd,
    output       cke,
    output       cs_n,
    output [`SDR_SDRAM_DATA_WIDTH/8-1:0] dqm,
    output [`SDR_SDRAM_DATA_WIDTH-1:0] dq_o,
    input  [`SDR_SDRAM_DATA_WIDTH-1:0] dq_i,
    output dq_oe,
`endif
`ifdef DDR3
    output [12:0] mem_addr,
    output [2:0] mem_ba,
    output mem_cas_n,
    output mem_cke,
    inout mem_clk,
    inout mem_clk_n,
    output mem_cs_n,
    output [1:0] mem_dm,
    inout [15:0] mem_dq,
    inout [1:0] mem_dqs,
    inout [1:0] mem_dqsn,
    output mem_odt,
    output mem_ras_n,
    input mem_reset_n,
    output mem_we_n,
    input mem_ref_clk, /* 100MHz */		       
`endif
    input mem_clk_i,
    input mem_rst_i
);

wire  [31:0] wbm_1_dat_o;
wire  [`WB_ADR_SIZE-1:2] wbm_1_adr_o;
wire   [3:0] wbm_1_sel_o;
wire   [2:0] wbm_1_cti_o;
wire   [1:0] wbm_1_bte_o;
wire         wbm_1_we_o;
wire         wbm_1_stb_o;
wire         wbm_1_cyc_o;
wire  [31:0] wbm_1_dat_i;
wire         wbm_1_ack_i;
`ifdef WB_GRPS_2
wire  [31:0] wbm_2_dat_o;
wire  [`WB_ADR_SIZE-1:2] wbm_2_adr_o;
wire   [3:0] wbm_2_sel_o;
wire   [2:0] wbm_2_cti_o;
wire   [1:0] wbm_2_bte_o;
wire         wbm_2_we_o;
wire         wbm_2_stb_o;
wire         wbm_2_cyc_o;
wire  [31:0] wbm_2_dat_i;
wire         wbm_2_ack_i;
`endif
`ifdef WB_GRPS_3
wire  [31:0] wbm_3_dat_o;
wire  [`WB_ADR_SIZE-1:2] wbm_3_adr_o;
wire   [3:0] wbm_3_sel_o;
wire   [2:0] wbm_3_cti_o;
wire   [1:0] wbm_3_bte_o;
wire         wbm_3_we_o;
wire         wbm_3_stb_o;
wire         wbm_3_cyc_o;
wire  [31:0] wbm_3_dat_i;
wire         wbm_3_ack_i;
`endif
`ifdef WB_GRPS_4
wire  [31:0] wbm_4_dat_o;
wire  [`WB_ADR_SIZE-1:2] wbm_4_adr_o;
wire   [3:0] wbm_4_sel_o;
wire   [2:0] wbm_4_cti_o;
wire   [1:0] wbm_4_bte_o;
wire         wbm_4_we_o;
wire         wbm_4_stb_o;
wire         wbm_4_cyc_o;
wire  [31:0] wbm_4_dat_i;
wire         wbm_4_ack_i;
`endif
`ifdef WB_GRPS_5
wire  [31:0] wbm_5_dat_o;
wire  [`WB_ADR_SIZE-1:2] wbm_5_adr_o;
wire   [3:0] wbm_5_sel_o;
wire   [2:0] wbm_5_cti_o;
wire   [1:0] wbm_5_bte_o;
wire         wbm_5_we_o;
wire         wbm_5_stb_o;
wire         wbm_5_cyc_o;
wire  [31:0] wbm_5_dat_i;
wire         wbm_5_ack_i;
`endif
`ifdef WB_GRPS_6
wire  [31:0] wbm_6_dat_o;
wire  [`WB_ADR_SIZE-1:2] wbm_6_adr_o;
wire   [3:0] wbm_6_sel_o;
wire   [2:0] wbm_6_cti_o;
wire   [1:0] wbm_6_bte_o;
wire         wbm_6_we_o;
wire         wbm_6_stb_o;
wire         wbm_6_cyc_o;
wire  [31:0] wbm_6_dat_i;
wire         wbm_6_ack_i;
`endif
`ifdef WB_GRPS_7
wire  [31:0] wbm_7_dat_o;
wire  [`WB_ADR_SIZE-1:2] wbm_7_adr_o;
wire   [3:0] wbm_7_sel_o;
wire   [2:0] wbm_7_cti_o;
wire   [1:0] wbm_7_bte_o;
wire         wbm_7_we_o;
wire         wbm_7_stb_o;
wire         wbm_7_cyc_o;
wire  [31:0] wbm_7_dat_i;
wire         wbm_7_ack_i;
`endif
`ifdef WB_GRPS_8
wire  [31:0] wbm_8_dat_o;
wire  [`WB_ADR_SIZE-1:2] wbm_8_adr_o;
wire   [3:0] wbm_8_sel_o;
wire   [2:0] wbm_8_cti_o;
wire   [1:0] wbm_8_bte_o;
wire         wbm_8_we_o;
wire         wbm_8_stb_o;
wire         wbm_8_cyc_o;
wire  [31:0] wbm_8_dat_i;
wire         wbm_8_ack_i;
`endif
wire  [31:0] wbs_dat_i;
wire  [`WB_ADR_SIZE-1:2] wbs_adr_i;
wire   [3:0] wbs_sel_i;
wire   [2:0] wbs_cti_i;
wire   [1:0] wbs_bte_i;
wire         wbs_we_i;
wire         wbs_stb_i;
wire         wbs_cyc_i;
wire  [31:0] wbs_dat_o;
wire         wbs_ack_o;

`define MODULE wb3wb3_bridge

`ifdef WB1_CLK
wire [31-(`WB_ADR_SIZE):0] dummy1;
`VLBASE`MODULE wbwb1 ( 
    // wishbone slave side
    .wbs_dat_i(wbs_1_dat_i),
    .wbs_adr_i({{32-(`WB_ADR_SIZE){1'b0}},wbs_1_adr_i}),
    .wbs_sel_i(wbs_1_sel_i),
    .wbs_bte_i(wbs_1_bte_i),
    .wbs_cti_i(wbs_1_cti_i),
    .wbs_we_i (wbs_1_we_i),
    .wbs_cyc_i(wbs_1_cyc_i),
    .wbs_stb_i(wbs_1_stb_i),
    .wbs_dat_o(wbs_1_dat_o),
    .wbs_ack_o(wbs_1_ack_o),
    .wbs_clk(wbs_1_clk_i),
    .wbs_rst(wbs_1_rst_i),
    // wishbone master side
    .wbm_dat_o(wbm_1_dat_o),
    .wbm_adr_o({dummy1,wbm_1_adr_o}),
    .wbm_sel_o(wbm_1_sel_o),
    .wbm_bte_o(wbm_1_bte_o),
    .wbm_cti_o(wbm_1_cti_o),
    .wbm_we_o(wbm_1_we_o),
    .wbm_cyc_o(wbm_1_cyc_o),
    .wbm_stb_o(wbm_1_stb_o),
    .wbm_dat_i(wbm_1_dat_i),
    .wbm_ack_i(wbm_1_ack_i),
    .wbm_clk(mem_clk_i),
    .wbm_rst(mem_rst_i));
`endif
`ifdef WB1_MEM_CLK
    assign wbm_1_dat_o = wbs_1_dat_i;
    assign wbm_1_adr_o = wbs_1_adr_i;
    assign wbm_1_sel_o = wbs_1_sel_i;
    assign wbm_1_bte_o = wbs_1_bte_i;
    assign wbm_1_cti_o = wbs_1_cti_i;
    assign wbm_1_we_o  = wbs_1_we_i;
    assign wbm_1_cyc_o = wbs_1_cyc_i;
    assign wbm_1_stb_o = wbs_1_stb_i;
    assign wbs_1_dat_o = wbm_1_dat_i;
    assign wbs_1_ack_o = wbm_1_ack_i;
`endif

`ifdef WB_GRPS_2
`ifdef WB2_CLK
wire [31-(`WB_ADR_SIZE):0] dummy2;
`VLBASE`MODULE wbwb2 ( 
    // wishbone slave side
    .wbs_dat_i(wbs_2_dat_i),
    .wbs_adr_i({{32-(`WB_ADR_SIZE){1'b0}},wbs_2_adr_i}),
    .wbs_sel_i(wbs_2_sel_i),
    .wbs_bte_i(wbs_2_bte_i),
    .wbs_cti_i(wbs_2_cti_i),
    .wbs_we_i (wbs_2_we_i),
    .wbs_cyc_i(wbs_2_cyc_i),
    .wbs_stb_i(wbs_2_stb_i),
    .wbs_dat_o(wbs_2_dat_o),
    .wbs_ack_o(wbs_2_ack_o),
    .wbs_clk(wbs_2_clk_i),
    .wbs_rst(wbs_2_rst_i),
    // wishbone master side
    .wbm_dat_o(wbm_2_dat_o),
    .wbm_adr_o({dummy2,wbm_2_adr_o}),
    .wbm_sel_o(wbm_2_sel_o),
    .wbm_bte_o(wbm_2_bte_o),
    .wbm_cti_o(wbm_2_cti_o),
    .wbm_we_o(wbm_2_we_o),
    .wbm_cyc_o(wbm_2_cyc_o),
    .wbm_stb_o(wbm_2_stb_o),
    .wbm_dat_i(wbm_2_dat_i),
    .wbm_ack_i(wbm_2_ack_i),
    .wbm_clk(mem_clk_i),
    .wbm_rst(mem_rst_i));
`endif
`ifdef WB2_MEM_CLK
    assign wbm_2_dat_o = wbs_2_dat_i;
    assign wbm_2_adr_o = wbs_2_adr_i;
    assign wbm_2_sel_o = wbs_2_sel_i;
    assign wbm_2_bte_o = wbs_2_bte_i;
    assign wbm_2_cti_o = wbs_2_cti_i;
    assign wbm_2_we_o  = wbs_2_we_i;
    assign wbm_2_cyc_o = wbs_2_cyc_i;
    assign wbm_2_stb_o = wbs_2_stb_i;
    assign wbs_2_dat_o = wbm_2_dat_i;
    assign wbs_2_ack_o = wbm_2_ack_i;
`endif
`endif

`ifdef WB_GRPS_3
`ifdef WB3_CLK
wire [31-(`WB_ADR_SIZE):0] dummy3;
`VLBASE`MODULE wbwb3 ( 
    // wishbone slave side
    .wbs_dat_i(wbs_3_dat_i),
    .wbs_adr_i({{32-(`WB_ADR_SIZE){1'b0}},wbs_3_adr_i}),
    .wbs_sel_i(wbs_3_sel_i),
    .wbs_bte_i(wbs_3_bte_i),
    .wbs_cti_i(wbs_3_cti_i),
    .wbs_we_i (wbs_3_we_i),
    .wbs_cyc_i(wbs_3_cyc_i),
    .wbs_stb_i(wbs_3_stb_i),
    .wbs_dat_o(wbs_3_dat_o),
    .wbs_ack_o(wbs_3_ack_o),
    .wbs_clk(wbs_3_clk_i),
    .wbs_rst(wbs_3_rst_i),
    // wishbone master side
    .wbm_dat_o(wbm_3_dat_o),
    .wbm_adr_o({dummy3,wbm_3_adr_o}),
    .wbm_sel_o(wbm_3_sel_o),
    .wbm_bte_o(wbm_3_bte_o),
    .wbm_cti_o(wbm_3_cti_o),
    .wbm_we_o(wbm_3_we_o),
    .wbm_cyc_o(wbm_3_cyc_o),
    .wbm_stb_o(wbm_3_stb_o),
    .wbm_dat_i(wbm_3_dat_i),
    .wbm_ack_i(wbm_3_ack_i),
    .wbm_clk(mem_clk_i),
    .wbm_rst(mem_rst_i));
`endif
`ifdef WB3_MEM_CLK
    assign wbm_3_dat_o = wbs_3_dat_i;
    assign wbm_3_adr_o = wbs_3_adr_i;
    assign wbm_3_sel_o = wbs_3_sel_i;
    assign wbm_3_bte_o = wbs_3_bte_i;
    assign wbm_3_cti_o = wbs_3_cti_i;
    assign wbm_3_we_o  = wbs_3_we_i;
    assign wbm_3_cyc_o = wbs_3_cyc_i;
    assign wbm_3_stb_o = wbs_3_stb_i;
    assign wbs_3_dat_o = wbm_3_dat_i;
    assign wbs_3_ack_o = wbm_3_ack_i;
`endif
`endif

`ifdef WB_GRPS_4
`ifdef WB4_CLK
wire [31-(`WB_ADR_SIZE):0] dummy4;
`VLBASE`MODULE wbwb4 ( 
    // wishbone slave side
    .wbs_dat_i(wbs_4_dat_i),
    .wbs_adr_i({{32-(`WB_ADR_SIZE){1'b0}},wbs_4_adr_i}),
    .wbs_sel_i(wbs_4_sel_i),
    .wbs_bte_i(wbs_4_bte_i),
    .wbs_cti_i(wbs_4_cti_i),
    .wbs_we_i (wbs_4_we_i),
    .wbs_cyc_i(wbs_4_cyc_i),
    .wbs_stb_i(wbs_4_stb_i),
    .wbs_dat_o(wbs_4_dat_o),
    .wbs_ack_o(wbs_4_ack_o),
    .wbs_clk(wbs_4_clk_i),
    .wbs_rst(wbs_4_rst_i),
    // wishbone master side
    .wbm_dat_o(wbm_4_dat_o),
    .wbm_adr_o({dummy4,wbm_4_adr_o}),
    .wbm_sel_o(wbm_4_sel_o),
    .wbm_bte_o(wbm_4_bte_o),
    .wbm_cti_o(wbm_4_cti_o),
    .wbm_we_o(wbm_4_we_o),
    .wbm_cyc_o(wbm_4_cyc_o),
    .wbm_stb_o(wbm_4_stb_o),
    .wbm_dat_i(wbm_4_dat_i),
    .wbm_ack_i(wbm_4_ack_i),
    .wbm_clk(mem_clk_i),
    .wbm_rst(mem_rst_i));
`endif
`ifdef WB4_MEM_CLK
    assign wbm_4_dat_o = wbs_4_dat_i;
    assign wbm_4_adr_o = wbs_4_adr_i;
    assign wbm_4_sel_o = wbs_4_sel_i;
    assign wbm_4_bte_o = wbs_4_bte_i;
    assign wbm_4_cti_o = wbs_4_cti_i;
    assign wbm_4_we_o  = wbs_4_we_i;
    assign wbm_4_cyc_o = wbs_4_cyc_i;
    assign wbm_4_stb_o = wbs_4_stb_i;
    assign wbs_4_dat_o = wbm_4_dat_i;
    assign wbs_4_ack_o = wbm_4_ack_i;
`endif
`endif

`ifdef WB_GRPS_5
`ifdef WB5_CLK
wire [31-(`WB_ADR_SIZE):0] dummy5;
`VLBASE`MODULE wbwb5 ( 
    // wishbone slave side
    .wbs_dat_i(wbs_5_dat_i),
    .wbs_adr_i({{32-(`WB_ADR_SIZE){1'b0}},wbs_5_adr_i}),
    .wbs_sel_i(wbs_5_sel_i),
    .wbs_bte_i(wbs_5_bte_i),
    .wbs_cti_i(wbs_5_cti_i),
    .wbs_we_i (wbs_5_we_i),
    .wbs_cyc_i(wbs_5_cyc_i),
    .wbs_stb_i(wbs_5_stb_i),
    .wbs_dat_o(wbs_5_dat_o),
    .wbs_ack_o(wbs_5_ack_o),
    .wbs_clk(wbs_5_clk_i),
    .wbs_rst(wbs_5_rst_i),
    // wishbone master side
    .wbm_dat_o(wbm_5_dat_o),
    .wbm_adr_o({dummy5,wbm_5_adr_o}),
    .wbm_sel_o(wbm_5_sel_o),
    .wbm_bte_o(wbm_5_bte_o),
    .wbm_cti_o(wbm_5_cti_o),
    .wbm_we_o(wbm_5_we_o),
    .wbm_cyc_o(wbm_5_cyc_o),
    .wbm_stb_o(wbm_5_stb_o),
    .wbm_dat_i(wbm_5_dat_i),
    .wbm_ack_i(wbm_5_ack_i),
    .wbm_clk(mem_clk_i),
    .wbm_rst(mem_rst_i));
`endif
`ifdef WB5_MEM_CLK
    assign wbm_5_dat_o = wbs_5_dat_i;
    assign wbm_5_adr_o = wbs_5_adr_i;
    assign wbm_5_sel_o = wbs_5_sel_i;
    assign wbm_5_bte_o = wbs_5_bte_i;
    assign wbm_5_cti_o = wbs_5_cti_i;
    assign wbm_5_we_o  = wbs_5_we_i;
    assign wbm_5_cyc_o = wbs_5_cyc_i;
    assign wbm_5_stb_o = wbs_5_stb_i;
    assign wbs_5_dat_o = wbm_5_dat_i;
    assign wbs_5_ack_o = wbm_5_ack_i;
`endif
`endif

`ifdef WB_GRPS_6
`ifdef WB6_CLK
wire [31-(`WB_ADR_SIZE):0] dummy6;
`VLBASE`MODULE wbwb6 ( 
    // wishbone slave side
    .wbs_dat_i(wbs_6_dat_i),
    .wbs_adr_i({{32-(`WB_ADR_SIZE){1'b0}},wbs_6_adr_i}),
    .wbs_sel_i(wbs_6_sel_i),
    .wbs_bte_i(wbs_6_bte_i),
    .wbs_cti_i(wbs_6_cti_i),
    .wbs_we_i (wbs_6_we_i),
    .wbs_cyc_i(wbs_6_cyc_i),
    .wbs_stb_i(wbs_6_stb_i),
    .wbs_dat_o(wbs_6_dat_o),
    .wbs_ack_o(wbs_6_ack_o),
    .wbs_clk(wbs_6_clk_i),
    .wbs_rst(wbs_6_rst_i),
    // wishbone master side
    .wbm_dat_o(wbm_6_dat_o),
    .wbm_adr_o({dummy6,wbm_6_adr_o}),
    .wbm_sel_o(wbm_6_sel_o),
    .wbm_bte_o(wbm_6_bte_o),
    .wbm_cti_o(wbm_6_cti_o),
    .wbm_we_o(wbm_6_we_o),
    .wbm_cyc_o(wbm_6_cyc_o),
    .wbm_stb_o(wbm_6_stb_o),
    .wbm_dat_i(wbm_6_dat_i),
    .wbm_ack_i(wbm_6_ack_i),
    .wbm_clk(mem_clk_i),
    .wbm_rst(mem_rst_i));
`endif
`ifdef WB6_MEM_CLK
    assign wbm_6_dat_o = wbs_6_dat_i;
    assign wbm_6_adr_o = wbs_6_adr_i;
    assign wbm_6_sel_o = wbs_6_sel_i;
    assign wbm_6_bte_o = wbs_6_bte_i;
    assign wbm_6_cti_o = wbs_6_cti_i;
    assign wbm_6_we_o  = wbs_6_we_i;
    assign wbm_6_cyc_o = wbs_6_cyc_i;
    assign wbm_6_stb_o = wbs_6_stb_i;
    assign wbs_6_dat_o = wbm_6_dat_i;
    assign wbs_6_ack_o = wbm_6_ack_i;
`endif
`endif

`ifdef WB_GRPS_7
`ifdef WB7_CLK
wire [31-(`WB_ADR_SIZE):0] dummy7;
`VLBASE`MODULE wbwb7 ( 
    // wishbone slave side
    .wbs_dat_i(wbs_7_dat_i),
    .wbs_adr_i({{32-(`WB_ADR_SIZE){1'b0}},wbs_7_adr_i}),
    .wbs_sel_i(wbs_7_sel_i),
    .wbs_bte_i(wbs_7_bte_i),
    .wbs_cti_i(wbs_7_cti_i),
    .wbs_we_i (wbs_7_we_i),
    .wbs_cyc_i(wbs_7_cyc_i),
    .wbs_stb_i(wbs_7_stb_i),
    .wbs_dat_o(wbs_7_dat_o),
    .wbs_ack_o(wbs_7_ack_o),
    .wbs_clk(wbs_7_clk_i),
    .wbs_rst(wbs_7_rst_i),
    // wishbone master side
    .wbm_dat_o(wbm_7_dat_o),
    .wbm_adr_o({dummy7,wbm_7_adr_o}),
    .wbm_sel_o(wbm_7_sel_o),
    .wbm_bte_o(wbm_7_bte_o),
    .wbm_cti_o(wbm_7_cti_o),
    .wbm_we_o(wbm_7_we_o),
    .wbm_cyc_o(wbm_7_cyc_o),
    .wbm_stb_o(wbm_7_stb_o),
    .wbm_dat_i(wbm_7_dat_i),
    .wbm_ack_i(wbm_7_ack_i),
    .wbm_clk(mem_clk_i),
    .wbm_rst(mem_rst_i));
`endif
`ifdef WB7_MEM_CLK
    assign wbm_7_dat_o = wbs_7_dat_i;
    assign wbm_7_adr_o = wbs_7_adr_i;
    assign wbm_7_sel_o = wbs_7_sel_i;
    assign wbm_7_bte_o = wbs_7_bte_i;
    assign wbm_7_cti_o = wbs_7_cti_i;
    assign wbm_7_we_o  = wbs_7_we_i;
    assign wbm_7_cyc_o = wbs_7_cyc_i;
    assign wbm_7_stb_o = wbs_7_stb_i;
    assign wbs_7_dat_o = wbm_7_dat_i;
    assign wbs_7_ack_o = wbm_7_ack_i;
`endif
`endif

`ifdef WB_GRPS_8
`ifdef WB8_CLK
wire [31-(`WB_ADR_SIZE):0] dummy8;
`VLBASE`MODULE wbwb8 ( 
    // wishbone slave side
    .wbs_dat_i(wbs_8_dat_i),
    .wbs_adr_i({{32-(`WB_ADR_SIZE){1'b0}},wbs_8_adr_i}),
    .wbs_sel_i(wbs_8_sel_i),
    .wbs_bte_i(wbs_8_bte_i),
    .wbs_cti_i(wbs_8_cti_i),
    .wbs_we_i (wbs_8_we_i),
    .wbs_cyc_i(wbs_8_cyc_i),
    .wbs_stb_i(wbs_8_stb_i),
    .wbs_dat_o(wbs_8_dat_o),
    .wbs_ack_o(wbs_8_ack_o),
    .wbs_clk(wbs_8_clk_i),
    .wbs_rst(wbs_8_rst_i),
    // wishbone master side
    .wbm_dat_o(wbm_8_dat_o),
    .wbm_adr_o({dummy8,wbm_8_adr_o}),
    .wbm_sel_o(wbm_8_sel_o),
    .wbm_bte_o(wbm_8_bte_o),
    .wbm_cti_o(wbm_8_cti_o),
    .wbm_we_o(wbm_8_we_o),
    .wbm_cyc_o(wbm_8_cyc_o),
    .wbm_stb_o(wbm_8_stb_o),
    .wbm_dat_i(wbm_8_dat_i),
    .wbm_ack_i(wbm_8_ack_i),
    .wbm_clk(mem_clk_i),
    .wbm_rst(mem_rst_i));
`endif
`ifdef WB8_MEM_CLK
    assign wbm_8_dat_o = wbs_8_dat_i;
    assign wbm_8_adr_o = wbs_8_adr_i;
    assign wbm_8_sel_o = wbs_8_sel_i;
    assign wbm_8_bte_o = wbs_8_bte_i;
    assign wbm_8_cti_o = wbs_8_cti_i;
    assign wbm_8_we_o  = wbs_8_we_i;
    assign wbm_8_cyc_o = wbs_8_cyc_i;
    assign wbm_8_stb_o = wbs_8_stb_i;
    assign wbs_8_dat_o = wbm_8_dat_i;
    assign wbs_8_ack_o = wbm_8_ack_i;
`endif
`endif

`undef MODULE

`ifdef WB_GRPS_2
// we have at least two ports and need an arbiter
`define MODULE wb3_arbiter_type1
`VLBASE`MODULE
# (.nr_of_ports(`NR_OF_PORTS), .adr_size(`WB_ADR_SIZE))
wb0(
`undef MODULE
    .wbm_dat_o({wbm_1_dat_o,wbm_2_dat_o
`ifdef WB_GRPS_3
    ,wbm_3_dat_o
`endif
`ifdef WB_GRPS_4
    ,wbm_4_dat_o
`endif
`ifdef WB_GRPS_5
    ,wbm_5_dat_o
`endif
`ifdef WB_GRPS_6
    ,wbm_6_dat_o
`endif
`ifdef WB_GRPS_7
    ,wbm_7_dat_o
`endif
`ifdef WB_GRPS_8
    ,wbm_8_dat_o
`endif
    }),
    .wbm_adr_o({wbm_1_adr_o,wbm_2_adr_o
`ifdef WB_GRPS_3
    ,wbm_3_adr_o
`endif
`ifdef WB_GRPS_4
    ,wbm_4_adr_o
`endif
`ifdef WB_GRPS_5
    ,wbm_5_adr_o
`endif
`ifdef WB_GRPS_6
    ,wbm_6_adr_o
`endif
`ifdef WB_GRPS_7
    ,wbm_7_adr_o
`endif
`ifdef WB_GRPS_8
    ,wbm_8_adr_o
`endif
    }),
    .wbm_sel_o({wbm_1_sel_o,wbm_2_sel_o
`ifdef WB_GRPS_3
    ,wbm_3_sel_o
`endif
`ifdef WB_GRPS_4
    ,wbm_4_sel_o
`endif
`ifdef WB_GRPS_5
    ,wbm_5_sel_o
`endif
`ifdef WB_GRPS_6
    ,wbm_6_sel_o
`endif
`ifdef WB_GRPS_7
    ,wbm_7_sel_o
`endif
`ifdef WB_GRPS_8
    ,wbm_8_sel_o
`endif
    }),
    .wbm_cti_o({wbm_1_cti_o,wbm_2_cti_o
`ifdef WB_GRPS_3
    ,wbm_3_cti_o
`endif
`ifdef WB_GRPS_4
    ,wbm_4_cti_o
`endif
`ifdef WB_GRPS_5
    ,wbm_5_cti_o
`endif
`ifdef WB_GRPS_6
    ,wbm_6_cti_o
`endif
`ifdef WB_GRPS_7
    ,wbm_7_cti_o
`endif
`ifdef WB_GRPS_8
    ,wbm_8_cti_o
`endif
    }),
    .wbm_bte_o({wbm_1_bte_o,wbm_2_bte_o
`ifdef WB_GRPS_3
    ,wbm_3_bte_o
`endif
`ifdef WB_GRPS_4
    ,wbm_4_bte_o
`endif
`ifdef WB_GRPS_5
    ,wbm_5_bte_o
`endif
`ifdef WB_GRPS_6
    ,wbm_6_bte_o
`endif
`ifdef WB_GRPS_7
    ,wbm_7_bte_o
`endif
`ifdef WB_GRPS_8
    ,wbm_8_bte_o
`endif
    }),
    .wbm_we_o({wbm_1_we_o,wbm_2_we_o
`ifdef WB_GRPS_3
    ,wbm_3_we_o
`endif
`ifdef WB_GRPS_4
    ,wbm_4_we_o
`endif
`ifdef WB_GRPS_5
    ,wbm_5_we_o
`endif
`ifdef WB_GRPS_6
    ,wbm_6_we_o
`endif
`ifdef WB_GRPS_7
    ,wbm_7_we_o
`endif
`ifdef WB_GRPS_8
    ,wbm_8_we_o
`endif
    }),
    .wbm_stb_o({wbm_1_stb_o,wbm_2_stb_o
`ifdef WB_GRPS_3
    ,wbm_3_stb_o
`endif
`ifdef WB_GRPS_4
    ,wbm_4_stb_o
`endif
`ifdef WB_GRPS_5
    ,wbm_5_stb_o
`endif
`ifdef WB_GRPS_6
    ,wbm_6_stb_o
`endif
`ifdef WB_GRPS_7
    ,wbm_7_stb_o
`endif
`ifdef WB_GRPS_8
    ,wbm_8_stb_o
`endif
    }),
    .wbm_cyc_o({wbm_1_cyc_o,wbm_2_cyc_o
`ifdef WB_GRPS_3
    ,wbm_3_cyc_o
`endif
`ifdef WB_GRPS_4
    ,wbm_4_cyc_o
`endif
`ifdef WB_GRPS_5
    ,wbm_5_cyc_o
`endif
`ifdef WB_GRPS_6
    ,wbm_6_cyc_o
`endif
`ifdef WB_GRPS_7
    ,wbm_7_cyc_o
`endif
`ifdef WB_GRPS_8
    ,wbm_8_cyc_o
`endif
    }),
    .wbm_dat_i({wbm_1_dat_i,wbm_2_dat_i
`ifdef WB_GRPS_3
    ,wbm_3_dat_i
`endif
`ifdef WB_GRPS_4
    ,wbm_4_dat_i
`endif
`ifdef WB_GRPS_5
    ,wbm_5_dat_i
`endif
`ifdef WB_GRPS_6
    ,wbm_6_dat_i
`endif
`ifdef WB_GRPS_7
    ,wbm_7_dat_i
`endif
`ifdef WB_GRPS_8
    ,wbm_8_dat_i
`endif
    }),
    .wbm_ack_i({wbm_1_ack_i,wbm_2_ack_i
`ifdef WB_GRPS_3
    ,wbm_3_ack_i
`endif
`ifdef WB_GRPS_4
    ,wbm_4_ack_i
`endif
`ifdef WB_GRPS_5
    ,wbm_5_ack_i
`endif
`ifdef WB_GRPS_6
    ,wbm_6_ack_i
`endif
`ifdef WB_GRPS_7
    ,wbm_7_ack_i
`endif
`ifdef WB_GRPS_8
    ,wbm_8_ack_i
`endif
    }),
    .wbm_err_i({wbm_1_err_i,wbm_2_err_i
`ifdef WB_GRPS_3
    ,wbm_3_err_i
`endif
`ifdef WB_GRPS_4
    ,wbm_4_err_i
`endif
`ifdef WB_GRPS_5
    ,wbm_5_err_i
`endif
`ifdef WB_GRPS_6
    ,wbm_6_err_i
`endif
`ifdef WB_GRPS_7
    ,wbm_7_err_i
`endif
`ifdef WB_GRPS_8
    ,wbm_8_err_i
`endif
    }),
    .wbm_rty_i({wbm_1_rty_i,wbm_2_rty_i
`ifdef WB_GRPS_3
    ,wbm_3_rty_i
`endif
`ifdef WB_GRPS_4
    ,wbm_4_rty_i
`endif
`ifdef WB_GRPS_5
    ,wbm_5_rty_i
`endif
`ifdef WB_GRPS_6
    ,wbm_6_rty_i
`endif
`ifdef WB_GRPS_7
    ,wbm_7_rty_i
`endif
`ifdef WB_GRPS_8
    ,wbm_8_rty_i
`endif
    }),
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_cti_i(wbs_cti_i),
    .wbs_bte_i(wbs_bte_i),
    .wbs_we_i(wbs_we_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_cyc_i(wbs_cyc_i),
    .wbs_dat_o(wbs_dat_o),
    .wbs_ack_o(wbs_ack_o),
    .wbs_err_o(wbs_err_o),
    .wbs_rty_o(wbs_rty_o),
    .wb_clk(mem_clk),
    .wb_rst(mem_clk)
);

`else
// only one external port an no need for arbiter
assign wbs_dat_i = wbm_dat_i;
assign wbs_adr_i = wbm_adr_i;
assign wbs_sel_i = wbm_sel_i;
assign wbs_cti_i = wbm_cti_i;
assign wbs_bte_i = wbm_bte_i;
assign wbs_we_i  = wbm_we_i;
assign wbs_stb_i = wbm_stb_i;
assign wbs_cyc_i = wbm_cyc_i;
assign wbm_dat_o = wbs_dat_o;
assign wbm_ack_o = wbs_ack_o;
`endif

`ifdef SHADOW_RAM
wire [31:0] wbs_ram_dat_o;
wire        wbs_ram_ack_o;
wire [31:0] wbs_sdram_dat_o;
wire        wbs_sdram_ack_o;
assign select_sdram = wbs_adr_i > (`RAM_MEM_SIZE-1);
assign wbs_dat_o = select_sdram ? wbs_sdram_dat_o : wbs_ram_dat_o;
assign wbs_ack_o = select_sdram ? wbs_sdram_ack_o : wbs_ram_ack_o;
`endif

`ifdef RAM
`define MODULE wb_b3_ram_be
`VLBASE`MODULE
`undef MODULE
# (
    .adr_size(`RAM_ADR_SIZE),
    .mem_size(`RAM_MEM_SIZE),
    .memory_init(`RAM_MEM_INIT),
    .memory_file(`RAM_MEM_INIT_FILE)
)
ram0 (
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_cti_i(wbs_cti_i),
    .wbs_bte_i(wbs_bte_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_we_i(wbs_we_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_cyc_i(wbs_cyc_i), 
    .wbs_dat_o(wbs_dat_o),
    .wbs_ack_o(wbs_ack_o),
    .wb_clk(mem_clk),
    .wb_rst(mem_rst));
`else
`ifdef SHADOW_RAM
`define MODULE wb_b3_ram_be
`VLBASE`MODULE
`undef MODULE
# (
    .adr_size(`RAM_ADR_SIZE),
    .mem_size(`RAM_MEM_SIZE),
    .memory_init(`RAM_MEM_INIT),
    .memory_file(`RAM_MEM_INIT_FILE)
)
ram0 (
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i[`WB_RAM_ADR_SIZE-2-1:0]),
    .wbs_cti_i(wbs_cti_i),
    .wbs_bte_i(wbs_bte_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_we_i(wbs_we_i),
    .wbs_stb_i(wbs_stb_i),    
    .wbs_cyc_i(wbs_cyc_i & ~select_sdram), 
    .wbs_dat_o(wbs_ram_dat_o),
    .wbs_ack_o(wbs_ram_ack_o),
    .wb_clk(mem_clk),
    .wb_rst(mem_rst));
`endif
`endif

`ifdef SDR
`define MODULE sdr16
`BASE`MODULE sdr16_0(
`undef MODULE
    // wisbone i/f
    .dat_i(wbs_dat_i),
    .adr_i({wbs_adr_i,1'b0}),
    .sel_i(wbs_sel_i),
`ifndef SDR_NO_BURST
    .bte_i(wbs_bte_i),
`endif
    .we_i(wbs_we_i),
`ifdef SHADOW_RAM
    .cyc_i(wbs_cyc_i & select_sdram),
`else
    .cyc_i(wbs_cyc_i),
`endif
    .stb_i(wbs_stb_i),
`ifdef SHADOW_RAM
    .dat_o(wbs_sdram_dat_o),
    .ack_o(wbs_sdram_ack_o),
`else
    .dat_o(wbs_dat_o),
    .ack_o(wbs_ack_o),
`endif
    // SDR SDRAM
    .ba(ba),
    .a(a),
    .cmd(cmd),
    .cke(cke),
    .cs_n(cs_n),
    .dqm(dqm),
    .dq_i(dq_i),
    .dq_o(dq_o),
    .dq_oe(dq_oe),
    // system
    .clk(mem_clk),
    .rst(mem_rst));
`endif

`ifdef DDR2
`endif

`ifdef DDR3
`ifdef DDR3_BOARD_2AGX125N
ddr3_2agx125n_if ddr3_0 (
    .wb_adr_i(wbs_adr_i),
    .wb_stb_i(wbs_stb_i),
`ifdef SHADOW_RAM
    .wb_cyc_i(wbs_cyc_i & select_sdram),
`else
    .wb_cyc_i(wbs_cyc_i),
`endif
    .wb_cti_i(wbs_cti_i),
    .wb_bte_i(wbs_bte_i),
    .wb_we_i (wbs_we_i),
    .wb_sel_i(wbs_sel_i),
    .wb_dat_i(wbs_dat_i),
`ifdef SHADOW_RAM
    .wb_dat_o(wbs_sdram_dat_o),
    .wb_ack_o(wbs_sdram_ack_o),
`else
    .wb_dat_o(wbs_dat_o),
    .wb_ack_o(wbs_ack_o),
`endif

    .mem_addr(mem_addr),
    .mem_ba(mem_ba),
    .mem_cas_n(mem_cas_n),
    .mem_cke(mem_cke),
    .mem_clk(mem_clk),
    .mem_clk_n(mem_clk_n),
    .mem_cs_n(mem_cs_n),
    .mem_dm(mem_dm),
    .mem_dq(mem_dq),
    .mem_dqs(mem_dqs),
    .mem_dqsn(mem_dqsn),
    .mem_odt(mem_odt),
    .mem_ras_n(mem_ras_n),
    .mem_reset_n(mem_reset_n),
    .mem_we_n(mem_we_n),
    .mem_ref_clk(mem_ref_clk), /* 100MHz */		       

    .wb_clk(mem_clk),
    .wb_rst(mem_rst));
`endif
`endif

endmodule
