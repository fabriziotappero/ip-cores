//////////////////////////////////////////////////////////////////////////////////
// Company:         ;)
// Engineer:        Kuzmi4
// 
// Create Date:     14:39:52 05/19/2010 
// Design Name:     
// Module Name:     tb/core64_pb_wishbone_ctrl
// Project Name:    DS_DMA
// Target Devices:  no
// Tool versions:   any with SV support
// Description: 
//                  
//                  Simple TB, waveform oriented.
//                  
//
// Revision: 
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

//
`include "ds_dma_pb_if.v"
`include "wb_simple_ram_slave_if.v"
`include "wb_slave_if.v"

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
// System Clock:
//
always
begin   :   SYS_CLK
    #(p_Tclk/2) s_sys_clk <= !s_sys_clk;
end
//////////////////////////////////////////////////////////////////////////////////
//
// Instantiate TEST IF's:
//
// PB_IF:
ds_dma_pb_if                        DS_DMA_PB_IF(s_sys_clk);
// WBS IF (+TB params):
wb_simple_ram_slave_if #(32, 64, 8) WB_SLAVE(s_sys_clk, s_sys_rst);
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
    DS_DMA_PB_IF.init();
    
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
    DS_DMA_PB_IF.write_1_word  (32'h1234_5678, 64'h0123_4567_89AB_CDEF); #100ns;
    DS_DMA_PB_IF.write_1_word  (32'h5678_1234, 64'h89AB_CDEF_0123_4567); #100ns;
    DS_DMA_PB_IF.write_512_word(32'h8765_4321, 64'h0000_0000_0000_0001); #100ns;#6us; // for now, req w8 while previous transfer ends
    DS_DMA_PB_IF.read_1_word   (32'h5612_7834, sv_ds_dma_income_data_0); #100ns;
    DS_DMA_PB_IF.read_512_word (32'h7834_1256, sv_ds_dma_income_data_1); #100ns;
    //DS_DMA_PB_IF.write_512_word(32'h8765_4321, 64'hCDEF_4567_89AB_0123); #1us;
    // 
    #6us;
    $finish(2);
end
//////////////////////////////////////////////////////////////////////////////////
//
// Instantiate DesignUnderTest:
//
core64_pb_wishbone_ctrl     
                    DUT     
(
// SYS_CON (same for PB/WB bus)
.i_clk              (s_sys_clk),
.i_rst              (s_sys_rst),
//
// PB_MASTER (in) IF
.i_pb_master_stb0   (DS_DMA_PB_IF.o_pb_master_stb0),   // CMD STB
.i_pb_master_stb1   (DS_DMA_PB_IF.o_pb_master_stb1),   // DATA STB
.iv_pb_master_cmd   (DS_DMA_PB_IF.ov_pb_master_cmd),   // CMD
.iv_pb_master_addr  (DS_DMA_PB_IF.ov_pb_master_addr),  // ADDR
.iv_pb_master_data  (DS_DMA_PB_IF.ov_pb_master_data),  // DATA
//
// PB_SLAVE (out) IF:
.o_pb_slave_ready   (DS_DMA_PB_IF.i_pb_slave_ready),    // 
.o_pb_slave_complete(DS_DMA_PB_IF.i_pb_slave_complete), // 
.o_pb_slave_stb0    (DS_DMA_PB_IF.i_pb_slave_stb0),     // WR CMD ACK STB   (to pcie_core64_m6)
.o_pb_slave_stb1    (DS_DMA_PB_IF.i_pb_slave_stb1),     // DATA ACK STB     (to pcie_core64_m6)
.ov_pb_slave_data   (DS_DMA_PB_IF.iv_pb_slave_data),    // DATA             (to pcie_core64_m6)
.ov_pb_slave_dmar   (DS_DMA_PB_IF.iv_pb_slave_dmar),    // ...
.o_pb_slave_irq     (DS_DMA_PB_IF.i_pb_slave_irq),      // ...
//
// WB BUS:
.ov_wbm_addr        (WB_SLAVE.adr_i),    
.ov_wbm_data        (WB_SLAVE.dat_i),    
.ov_wbm_sel         (WB_SLAVE.sel_i),     
.o_wbm_we           (WB_SLAVE.we_i),       
.o_wbm_cyc          (WB_SLAVE.cyc_i),      
.o_wbm_stb          (WB_SLAVE.stb_i),      
.ov_wbm_cti         (),     // Cycle Type Identifier Address Tag
.ov_wbm_bte         (),     // Burst Type Extension Address Tag

.iv_wbm_data        (WB_SLAVE.dat_o),       // 
.i_wbm_ack          (WB_SLAVE.ack_o),       // 
.i_wbm_err          (WB_SLAVE.err_o),       // error input - abnormal cycle termination
.i_wbm_rty          (WB_SLAVE.rty_o),       // retry input - interface is not ready

.i_wdm_irq_0        (1'b0),
.iv_wbm_irq_dmar    (2'b0)
    
);
//////////////////////////////////////////////////////////////////////////////////
endmodule
