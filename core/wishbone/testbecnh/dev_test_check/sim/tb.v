//////////////////////////////////////////////////////////////////////////////////
// Company:         ;)
// Engineer:        Kuzmi4
// 
// Create Date:     14:39:52 05/19/2010 
// Design Name:     
// Module Name:     tb/block_test_check_wb
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

`include "ds_dma_test_check_burst_master_if.v"

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
    logic   [63:0]  sv_ds_dma_outgoing_data_0;
    
//////////////////////////////////////////////////////////////////////////////////
// 
// Instantiate TEST IF:
//
ds_dma_test_check_burst_master_if       DS_DMA_WBM_IF(s_sys_clk);

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
    sv_ds_dma_outgoing_data_0   =   $random();
    
    DS_DMA_WBM_IF.init();
    
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
    //
    DS_DMA_WBM_IF.write_512_word(sv_ds_dma_outgoing_data_0, 0); #100ns;
    DS_DMA_WBM_IF.write_512_word(sv_ds_dma_outgoing_data_0, 0); #100ns;
    // 
    #6us;
    $finish(2);
end
//////////////////////////////////////////////////////////////////////////////////
//
// Instantiate DUT:
//
block_test_check_wb DUT
( 
//
// SYS_CON
.i_clk  (s_sys_clk),
.i_rst  (s_sys_rst),
//
// WB CFG SLAVE IF
.iv_wbs_cfg_addr     (8'b0), 
.iv_wbs_cfg_data     (64'b0), 
.iv_wbs_cfg_sel      (8'b0), 
.i_wbs_cfg_we        (1'b0), 
.i_wbs_cfg_cyc       (1'b0), 
.i_wbs_cfg_stb       (1'b0), 
.iv_wbs_cfg_cti      (3'b0), 
.iv_wbs_cfg_bte      (2'b0), 

.ov_wbs_cfg_data     (), 
.o_wbs_cfg_ack       (), 
.o_wbs_cfg_err       (), 
.o_wbs_cfg_rty       (), 
//
// WB BURST SLAVE IF (READ-ONLY IF)
.iv_wbs_burst_addr   (DS_DMA_WBM_IF.ov_wbs_burst_addr), 
.iv_wbs_burst_data   (DS_DMA_WBM_IF.ov_wbs_burst_data),
.iv_wbs_burst_sel    (DS_DMA_WBM_IF.ov_wbs_burst_sel), 
.i_wbs_burst_we      (DS_DMA_WBM_IF.o_wbs_burst_we), 
.i_wbs_burst_cyc     (DS_DMA_WBM_IF.o_wbs_burst_cyc), 
.i_wbs_burst_stb     (DS_DMA_WBM_IF.o_wbs_burst_stb), 
.iv_wbs_burst_cti    (DS_DMA_WBM_IF.ov_wbs_burst_cti), 
.iv_wbs_burst_bte    (DS_DMA_WBM_IF.ov_wbs_burst_bte), 

.o_wbs_burst_ack     (DS_DMA_WBM_IF.i_wbs_burst_ack), 
.o_wbs_burst_err     (DS_DMA_WBM_IF.i_wbs_burst_err), 
.o_wbs_burst_rty     (DS_DMA_WBM_IF.i_wbs_burst_rty), 
//
// WB IRQ lines
.o_wbs_irq_0         (), 
.o_wbs_irq_dmar      ()
);
//////////////////////////////////////////////////////////////////////////////////
endmodule
