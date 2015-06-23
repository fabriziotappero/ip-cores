// ===========================================================================
// File    : ti_phy_top.test_top.v
// Author  : cmagleby
// Date    : Mon Dec 3 11:03:46 MST 2007
// Project : TI PHY design
//
// Copyright (c) notice
// This code adheres to the GNU public license
// Please contact www.gutzlogic.com for details.
// cmagleby@gutzlogic.com; cwinward@gutzlogic.com
// ===========================================================================
//
// $Id: ti_phy_top.test_top.v,v 1.3 2008-01-15 03:25:07 cmagleby Exp $
//
// ===========================================================================
//
// $Log: not supported by cvs2svn $
// Revision 1.2  2007/12/05 23:00:33  cmagleby
// add sram for real rtl
//
// Revision 1.1.1.1  2007/12/05 18:37:07  cmagleby
// importing tb files
//
//
// ===========================================================================
// Function : This is the top level testbench file.
//
// ===========================================================================
// ===========================================================================
`timescale 1 ns/100 ps
module ti_phy_top_test_top;
   parameter simulation_cycle = 8;
   
   reg 	     SystemClock;
   wire      clk_50mhz;
   wire [1:0] PUSH_BUTTON;
   wire       FPGA_RESET_n;
   wire       PERST_n;
   wire       rxclk;
   wire [15:0] rxdata16;
   wire [1:0]  rxdatak16;
   wire        rxvalid16;
   wire        rxidle16;
   wire [2:0]  rxstatus;
   wire        phystatus;
   wire [7:0]  LED;
   wire        txclk;
   wire [15:0] txdata16;
   wire [1:0]  txdatak16;
   wire        txidle16;
   wire        rxdet_loopb;
   wire        txcomp;
   wire        rxpol;
   wire        phy_reset_n;
   wire [1:0]  pwrdwn;
   wire [16:0] sram_addr;
   wire        sram_adscn;
   wire        sram_adspn;
   wire        sram_advn;
   wire [3:0]  sram_ben;
   wire [2:0]  sram_ce;
   wire        sram_clk;
   wire        sram_gwn;
   wire        sram_mode;
   wire        sram_oen;
   wire        sram_wen;
   wire        sram_zz;
   wire [35:0] sram_data;
   assign      rxclk = SystemClock;
   assign      PERST_n = FPGA_RESET_n;
	       
`ifdef SYNOPSYS_NTB
	       ti_phy_top_test vshell(
				      .SystemClock (SystemClock),
				      .\ti_phy_top.clk_50mhz	(clk_50mhz),
				      .\ti_phy_top.PUSH_BUTTON	(PUSH_BUTTON),
				      .\ti_phy_top.FPGA_RESET_n	(FPGA_RESET_n),
				      .\ti_phy_top.PERST_n	(PERST_n),
				      .\ti_phy_top.rxclk	(rxclk),
				      .\ti_phy_top.rxdata16	(rxdata16),
				      .\ti_phy_top.rxdatak16	(rxdatak16),
				      .\ti_phy_top.rxvalid16	(rxvalid16),
				      .\ti_phy_top.rxidle16	(rxidle16),
				      .\ti_phy_top.rxstatus	(rxstatus),
				      .\ti_phy_top.phystatus	(phystatus),
				      .\ti_phy_top.sram_data	(sram_data),
				      .\ti_phy_top.LED	(LED),
				      .\ti_phy_top.txclk	(txclk),
				      .\ti_phy_top.txdata16	(txdata16),
				      .\ti_phy_top.txdatak16	(txdatak16),
				      .\ti_phy_top.txidle16	(txidle16),
				      .\ti_phy_top.rxdet_loopb	(rxdet_loopb),
				      .\ti_phy_top.txcomp	(txcomp),
				      .\ti_phy_top.rxpol	(rxpol),
				      .\ti_phy_top.phy_reset_n	(phy_reset_n),
				      .\ti_phy_top.pwrdwn	(pwrdwn),
				      .\ti_phy_top.sram_addr	(sram_addr),
				      .\ti_phy_top.sram_adscn	(sram_adscn),
				      .\ti_phy_top.sram_adspn	(sram_adspn),
				      .\ti_phy_top.sram_advn	(sram_advn),
				      .\ti_phy_top.sram_ben	(sram_ben),
				      .\ti_phy_top.sram_ce	(sram_ce),
				      .\ti_phy_top.sram_clk	(sram_clk),
				      .\ti_phy_top.sram_gwn	(sram_gwn),
				      .\ti_phy_top.sram_mode	(sram_mode),
				      .\ti_phy_top.sram_oen	(sram_oen),
				      .\ti_phy_top.sram_wen	(sram_wen),
				      .\ti_phy_top.sram_zz	(sram_zz)
				      );
`else
   
   vera_shell vshell(
		     .SystemClock (SystemClock),
		     .ti_phy_top_clk_50mhz	(clk_50mhz),
		     .ti_phy_top_PUSH_BUTTON	(PUSH_BUTTON),
		     .ti_phy_top_FPGA_RESET_n	(FPGA_RESET_),
		     .ti_phy_top_rxclk	(rxclk),
		     .ti_phy_top_rxdata16	(rxdata16),
		     .ti_phy_top_rxdatak16	(rxdatak16),
		     .ti_phy_top_rxvalid16	(rxvalid16),
		     .ti_phy_top_rxidle16	(rxidle16),
		     .ti_phy_top_rxstatus	(rxstatus),
		     .ti_phy_top_phystatus	(phystatus),
		     .ti_phy_top_sram_data	(sram_data),
		     .ti_phy_top_LED	(LED),
		     .ti_phy_top_txclk	(txclk),
		     .ti_phy_top_txdata16	(txdata16),
		     .ti_phy_top_txdatak16	(txdatak16),
		     .ti_phy_top_txidle16	(txidle16),
		     .ti_phy_top_rxdet_loopb	(rxdet_loopb),
		     .ti_phy_top_txcomp	(txcomp),
		     .ti_phy_top_rxpol	(rxpol),
		     .ti_phy_top_phy_reset_n	(phy_reset_n),
		     .ti_phy_top_pwrdwn	(pwrdwn),
		     .ti_phy_top_sram_addr	(sram_addr),
		     .ti_phy_top_sram_adscn	(sram_adscn),
		     .ti_phy_top_sram_adspn	(sram_adspn),
		     .ti_phy_top_sram_advn	(sram_advn),
		     .ti_phy_top_sram_ben	(sram_ben),
		     .ti_phy_top_sram_ce	(sram_ce),
		     .ti_phy_top_sram_clk	(sram_clk),
		     .ti_phy_top_sram_gwn	(sram_gwn),
		     .ti_phy_top_sram_mode	(sram_mode),
		     .ti_phy_top_sram_oen	(sram_oen),
		     .ti_phy_top_sram_wen	(sram_wen),
		     .ti_phy_top_sram_zz	(sram_zz)
		     );
`endif
   
   
   
`ifdef emu
   /* DUT is in emulator, so not instantiated here */
`else
   ti_phy_top dut(
		  .clk_50mhz	(clk_50mhz),
		  .PUSH_BUTTON	(PUSH_BUTTON),
		  .FPGA_RESET_n	(FPGA_RESET_n),
		  .PERST_n      (PERST_n),
		  .rxclk	(rxclk),
		  .rxdata16	(rxdata16),
		  .rxdatak16	(rxdatak16),
		  .rxvalid16	(rxvalid16),
		  .rxidle16	(rxidle16),
		  .rxstatus	(rxstatus),
		  .phystatus	(phystatus),
		  .sram_data	(sram_data),
		  .LED	(LED),
		  .txclk	(txclk),
		  .txdata16	(txdata16),
		  .txdatak16	(txdatak16),
		  .txidle16	(txidle16),
		  .rxdet_loopb	(rxdet_loopb),
		  .txcomp	(txcomp),
		  .rxpol	(rxpol),
		  .phy_reset_n	(phy_reset_n),
		  .pwrdwn	(pwrdwn),
		  .sram_addr	(sram_addr),
		  .sram_adscn	(sram_adscn),
		  .sram_adspn	(sram_adspn),
		  .sram_advn	(sram_advn),
		  .sram_ben	(sram_ben),
		  .sram_ce	(sram_ce),
		  .sram_clk	(sram_clk),
		  .sram_gwn	(sram_gwn),
		  .sram_mode	(sram_mode),
		  .sram_oen	(sram_oen),
		  .sram_wen	(sram_wen),
		  .sram_zz	(sram_zz)
		  );
`endif

   always @ (posedge SystemClock) begin
      if (|rxdatak16)
	$display($time,":datak symbol");
   end
   
   reg set_once;
   //simulation short ts1 sets
`ifdef REAL_RTL
   always @ (posedge SystemClock) begin
      if (dut.phy_layer_top_inst.send_ts1 & ~set_once) begin
	 force dut.phy_layer_top_inst.tx_alignment_32_inst.ts_1024_count = 10'b1111000000;
	 set_once <= #1 1'b1;
	 
      end
      else begin
	 release dut.phy_layer_top_inst.tx_alignment_32_inst.ts_1024_count;
	 if (dut.phy_layer_top_inst.ltssm_32bit_inst.start_link_training_pm) begin
	    set_once <= #1 1'b0;
	 end
      end
   end // always @ (posedge ti_phy_top_inst.clk_125mhz)
   
   /* -----\/----- EXCLUDED -----\/-----
    idt71v25761s200 AUTO_TEMPLATE (
				  .D	(sram_data[31:0]),
				  .DP	(sram_data[35:32]),
				  // Inputs
				  .A	(sram_addr),
				  .oe_	(sram_oen),
				  .ce_	(sram_ce[0]),
				  .cs0	(sram_ce[1]),
				  .cs1_	(sram_ce[2]),
				  .lbo_	(sram_mode),
				  .gw_	(sram_gwn),
				  .bwe_	(sram_wen),
				  .bw4_	(sram_ben[3]),
				  .bw3_	(sram_ben[2]),
				  .bw2_	(sram_ben[1]),
				  .bw1_	(sram_ben[0]),
				  .adsp_(sram_adspn),
				  .adsc_(sram_adscn),
				  .adv_	(sram_advn),
				  .clk	(sram_clk));
    -----/\----- EXCLUDED -----/\----- */
   
   idt71v25761s200 SRAM_MODEL_inst (/*AUTOINST*/
				    // Inouts
				    .D	(sram_data[31:0]),	 // Templated
				    .DP	(sram_data[35:32]),	 // Templated
				    // Inputs
				    .A	(sram_addr),		 // Templated
				    .oe_	(sram_oen),		 // Templated
				    .ce_	(sram_ce[0]),		 // Templated
				    .cs0	(sram_ce[1]),		 // Templated
				    .cs1_	(sram_ce[2]),		 // Templated
				    .lbo_	(sram_mode),		 // Templated
				    .gw_	(sram_gwn),		 // Templated
				    .bwe_	(sram_wen),		 // Templated
				    .bw4_	(sram_ben[3]),		 // Templated
				    .bw3_	(sram_ben[2]),		 // Templated
				    .bw2_	(sram_ben[1]),		 // Templated
				    .bw1_	(sram_ben[0]),		 // Templated
				    .adsp_(sram_adspn),		 // Templated
				    .adsc_(sram_adscn),		 // Templated
				    .adv_	(sram_advn),		 // Templated
				    .clk	(sram_clk));		 // Templated
   
`endif
     
   initial begin
      //****************************************************************************************
      //force scramble bypass until the tb can scramble and de-scramble data. 
      //force dut.phy_layer_top_inst.make_rxdata_path16.scramble16_inst.scram_bypass = 2'b11;
      //force dut.phy_layer_top_inst.make_tx_data_path16.scramble16_inst.scram_bypass = 2'b11;
      //****************************************************************************************
      set_once = 0;
      SystemClock = 0;
      forever begin
	 #(simulation_cycle/2)
         SystemClock = ~SystemClock;       
      end
      
   end // initial begin
   
`ifdef REAL_RTL   
   initial begin
      $fsdbDumpfile("vera_test.fsdb");
      $fsdbDumpvars(dut);
   end
`endif
   
   
endmodule
