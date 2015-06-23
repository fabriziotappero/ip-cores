//`include "tb_defines.v"
`timescale 1ns/1ns
module versatile_mem_ctrl_tb
  (
   output OK
   );

`ifdef NR_OF_WBM
	parameter nr_of_wbm = `NR_OF_WBM;
`else
	parameter nr_of_wbm = 1;
`endif

`ifdef SDRAM_CLK_PERIOD
	parameter sdram_clk_period = `SDRAM_CLK_PERIOD;
`else
	parameter sdram_clk_period = 8;
`endif

`ifdef WB_CLK_PERIODS
	parameter [1:nr_of_wbm] wb_clk_periods = {`WB_CLK_PERIODS};
`else
	parameter [1:nr_of_wbm] wb_clk_periods = (20);
`endif
	parameter wb_clk_period = 20;
	
   wire [31:0] wbm_a_dat_o;
   wire [3:0]  wbm_a_sel_o;
   wire [31:0] wbm_a_adr_o;
   wire [2:0]  wbm_a_cti_o;
   wire [1:0]  wbm_a_bte_o;
   wire        wbm_a_we_o ;
   wire        wbm_a_cyc_o;
   wire        wbm_a_stb_o;
   wire [31:0] wbm_a_dat_i;
   wire        wbm_a_ack_i;
   reg         wbm_a_clk  ;
   reg         wbm_a_rst  ;

   wire [31:0] wbm_b_dat_o;
   wire [3:0]  wbm_b_sel_o;
   wire [31:2] wbm_b_adr_o;
   wire [2:0]  wbm_b_cti_o;
   wire [1:0]  wbm_b_bte_o;
   wire        wbm_b_we_o ;
   wire        wbm_b_cyc_o;
   wire        wbm_b_stb_o;
   wire [31:0] wbm_b_dat_i;
   wire        wbm_b_ack_i;

   wire [31:0] wb_sdram_dat_i;
   wire [3:0]  wb_sdram_sel_i;
   wire [31:2] wb_sdram_adr_i;
   wire [2:0]  wb_sdram_cti_i;
   wire [1:0]  wb_sdram_bte_i;
   wire        wb_sdram_we_i;
   wire        wb_sdram_cyc_i;
   wire        wb_sdram_stb_i;
   wire [31:0] wb_sdram_dat_o;
   wire        wb_sdram_ack_o;
   reg         wb_sdram_clk;
   reg         wb_sdram_rst;
                             
	wire wbm_OK;
	
	genvar i;
              
`define DUT sdr_sdram_16_ctrl
`define SDR 16
`ifdef SDR
	wire [1:0]  ba, ba_pad;
   	wire [12:0] a, a_pad;
   	wire [`SDR-1:0] dq_i, dq_o, dq_pad;
   	wire        dq_oe;
   	wire [1:0]  dqm, dqm_pad;
   	wire        cke, cke_pad, cs_n, cs_n_pad, ras, ras_pad, cas, cas_pad, we, we_pad;
 
    vl_o_dff # ( .width(20), .reset_value({2'b00, 13'h0,3'b111,2'b11})) o0(
        .d_i({ba,a,ras,cas,we,dqm}),
        .o_pad({ba_pad,a_pad,ras_pad, cas_pad, we_pad, dqm_pad}),
        .clk(wb_sdram_clk),
        .rst(wb_sdram_rst));
        /*
	assign #1 {ba_pad,a_pad} = {ba,a};
	assign #1 {ras_pad, cas_pad, we_pad} = {ras,cas,we};
	assign #1 dqm_pad = dqm;*/
	assign #1 cke_pad = cke;
	assign cs_n_pad = cs_n;
    vl_io_dff_oe # ( .width(16)) io0 (
        .d_i(dq_i),
        .d_o(dq_o),
        .oe(dq_oe),
        .io_pad(dq_pad),
        .clk(wb_sdram_clk),
        .rst(wb_sdram_rst));
        
	mt48lc16m16a2 mem(
	 	.Dq(dq_pad), 
	 	.Addr(a_pad), 
	 	.Ba(ba_pad), 
	 	.Clk(wb_sdram_clk), 
	 	.Cke(cke_pad), 
	 	.Cs_n(cs_n_pad), 
	 	.Ras_n(ras_pad), 
	 	.Cas_n(cas_pad), 
	 	.We_n(we_pad), 
	 	.Dqm(dqm_pad));

	`DUT
        # (.tRFC(9), .cl(3))
        DUT(
	// wisbone i/f
	.dat_i(wbm_b_dat_o), 
	.adr_i({wbm_b_adr_o[24:2],1'b0}), 
	.sel_i(wbm_b_sel_o),
`ifndef NO_BURST
	.bte_i(wbm_b_bte_o),
`endif
	.we_i (wbm_b_we_o), 
	.cyc_i(wbm_b_cyc_o), 
	.stb_i(wbm_b_stb_o), 
	.dat_o(wbm_b_dat_i), 
	.ack_o(wbm_b_ack_i),
	// SDR SDRAM
	.ba(ba), 
	.a(a), 
	.cmd({ras, cas, we}),
	.cke(cke),
	.cs_n(cs_n), 
	.dqm(dqm), 
	.dq_i(dq_i), 
	.dq_o(dq_o), 
	.dq_oe(dq_oe),
	// system
	.clk(wb_sdram_clk), .rst(wb_sdram_rst));
	 	
`endif        

// wishbone master
		
        wbm wbmi(
            .adr_o(wbm_a_adr_o),
            .bte_o(wbm_a_bte_o),
            .cti_o(wbm_a_cti_o),
            .dat_o(wbm_a_dat_o),
	    .sel_o(wbm_a_sel_o),
            .we_o (wbm_a_we_o),
            .cyc_o(wbm_a_cyc_o),
            .stb_o(wbm_a_stb_o),
            .dat_i(wbm_a_dat_i),
            .ack_i(wbm_a_ack_i),
            .clk(wbm_a_clk),
            .reset(wbm_a_rst),
            .OK(wbm_OK)
);

	vl_wb3wb3_bridge wbwb_bridgei (
	// wishbone slave side
	.wbs_dat_i(wbm_a_dat_o), 
	.wbs_adr_i(wbm_a_adr_o[31:2]), 
	.wbs_sel_i(wbm_a_sel_o), 
	.wbs_bte_i(wbm_a_bte_o), 
	.wbs_cti_i(wbm_a_cti_o), 
	.wbs_we_i (wbm_a_we_o), 
	.wbs_cyc_i(wbm_a_cyc_o), 
	.wbs_stb_i(wbm_a_stb_o), 
	.wbs_dat_o(wbm_a_dat_i), 
	.wbs_ack_o(wbm_a_ack_i), 
	.wbs_clk(wbm_a_clk), 
	.wbs_rst(wbm_a_rst),
	// wishbone master side
	.wbm_dat_o(wbm_b_dat_o), 
	.wbm_adr_o(wbm_b_adr_o), 
	.wbm_sel_o(wbm_b_sel_o), 
	.wbm_bte_o(wbm_b_bte_o), 
	.wbm_cti_o(wbm_b_cti_o), 
	.wbm_we_o (wbm_b_we_o), 
	.wbm_cyc_o(wbm_b_cyc_o), 
	.wbm_stb_o(wbm_b_stb_o), 
	.wbm_dat_i(wbm_b_dat_i), 
	.wbm_ack_i(wbm_b_ack_i), 
	.wbm_clk(wb_sdram_clk), 
	.wbm_rst(wb_sdram_rst));
		


	assign OK = wbm_OK;
	

   		// Wishbone reset
   		initial
     	begin
		#0      wbm_a_rst = 1'b1;
		#200    wbm_a_rst = 1'b0;	
     	end

   		// Wishbone clock
   		initial
     	begin
		#0 wbm_a_clk = 1'b0;
		forever
	  		#(wb_clk_period/2) wbm_a_clk = !wbm_a_clk;
     	end



   // SDRAM reset
   initial
     begin
	#0      wb_sdram_rst = 1'b1;
	#200    wb_sdram_rst = 1'b0;	
     end
   
   // SDRAM clock
   initial
     begin
	#0 wb_sdram_clk = 1'b0;
	forever
	  #(sdram_clk_period/2) wb_sdram_clk = !wb_sdram_clk;
     end
   
endmodule // versatile_mem_ctrl_tb
