//////////////////////////////////////////////////////////////////////////////////
// Company:         ;)
// Engineer:        Kuzmi4
// 
// Create Date:     14:39:52 05/19/2010 
// Design Name:     
// Module Name:     tb/block_test_generate_wb
// Project Name:    DS_DMA
// Target Devices:  no
// Tool versions:   any with SV support
// Description: 
//                  
//                  Simple TB, waveform oriented ;)
//
// Revision: 
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

`include "ds_dma_test_gen_burst_master_if.v"

module tb;
//////////////////////////////////////////////////////////////////////////////////
//
parameter   p_Tclk  =   10ns;
parameter   p_Trst  =   120ns;
//////////////////////////////////////////////////////////////////////////////////
    // Declare SYS_CON stuff:
    reg     s_sys_clk;
    reg     s_sys_rst;
        // Declare 
    logic   [63:0]  sv_ds_dma_income_data_0;
    logic   [63:0]  sv_ds_dma_income_data_1 [512];
//////////////////////////////////////////////////////////////////////////////////
//
ds_dma_test_gen_burst_master_if     DS_DMA_BM_IF(s_sys_clk);
//////////////////////////////////////////////////////////////////////////////////
//
// System Clock:
//
always
begin   :   SYS_CLK
    #(p_Tclk/2) s_sys_clk <= !s_sys_clk;
end
//////////////////////////////////////////////////////////////////////////////////
//
// Local Initial PowerOnReset:
//
initial
begin   :   init_POR
    //
    $timeformat(-9, 3, " ns", 10);
    //
    s_sys_clk   <= 0;
    s_sys_rst   <= 0;
    
    DS_DMA_BM_IF.init();
    
    // PowerOnReset case
    s_sys_rst   <= 1; #p_Trst;
    s_sys_rst   <= 0;
    
end
//////////////////////////////////////////////////////////////////////////////////
//
// Test:
//
initial
begin   :   TB
    //
    do @(posedge s_sys_clk);
    while (s_sys_rst); #1us;
    #1us;
    force DUT.sv_test_gen_ctrl  = 16'h22; 
    force DUT.sv_test_gen_size  = 16'h01; 
    force DUT.sv_test_gen_cnt1  = 16'h00; 
    force DUT.sv_test_gen_cnt2  = 16'h00; #6us;
    //
    repeat (2)
        DS_DMA_BM_IF.read_512_word(sv_ds_dma_income_data_1); #100ns;
    //
    force DUT.sv_test_gen_ctrl  = 16'h00; 
    DS_DMA_BM_IF.read_512_word(sv_ds_dma_income_data_1); #100ns;
    #6us;
    $finish(2);
end
//////////////////////////////////////////////////////////////////////////////////
//
// Instantiate DUT
//
block_test_generate_wb  DUT
( 
//
// SYS_CON
.i_clk  (s_sys_clk),
.i_rst  (s_sys_rst),
//
// WB CFG SLAVE IF
.iv_wbs_cfg_addr     (), 
.iv_wbs_cfg_data     (), 
.iv_wbs_cfg_sel      (), 
.i_wbs_cfg_we        (), 
.i_wbs_cfg_cyc       (), 
.i_wbs_cfg_stb       (), 
.iv_wbs_cfg_cti      (), 
.iv_wbs_cfg_bte      (), 

.ov_wbs_cfg_data     (), 
.o_wbs_cfg_ack       (), 
.o_wbs_cfg_err       (), 
.o_wbs_cfg_rty       (), 
//
// WB BURST SLAVE IF (READ-ONLY IF)
.iv_wbs_burst_addr   (DS_DMA_BM_IF.ov_wbs_burst_addr), 
.iv_wbs_burst_sel    (DS_DMA_BM_IF.ov_wbs_burst_sel), 
.i_wbs_burst_we      (DS_DMA_BM_IF.o_wbs_burst_we), 
.i_wbs_burst_cyc     (DS_DMA_BM_IF.o_wbs_burst_cyc), 
.i_wbs_burst_stb     (DS_DMA_BM_IF.o_wbs_burst_stb), 
.iv_wbs_burst_cti    (DS_DMA_BM_IF.ov_wbs_burst_cti), 
.iv_wbs_burst_bte    (DS_DMA_BM_IF.ov_wbs_burst_bte), 

.ov_wbs_burst_data   (DS_DMA_BM_IF.iv_wbs_burst_data), 
.o_wbs_burst_ack     (DS_DMA_BM_IF.i_wbs_burst_ack), 
.o_wbs_burst_err     (DS_DMA_BM_IF.i_wbs_burst_err), 
.o_wbs_burst_rty     (DS_DMA_BM_IF.i_wbs_burst_rty), 
//
// WB IRQ lines
.o_wbs_irq_0         (), 
.o_wbs_irq_dmar      ()
);
//////////////////////////////////////////////////////////////////////////////////
endmodule
