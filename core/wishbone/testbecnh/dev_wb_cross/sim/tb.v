//////////////////////////////////////////////////////////////////////////////////
// Company:         ;)
// Engineer:        Kuzmi4 (original src - des00)
// 
// Create Date:     14:39:52 05/19/2010 
// Design Name:     
// Module Name:     tb/wb_cross
// Project Name:    DS_DMA
// Target Devices:  no
// Tool versions:   any with SV support
// Description: 
//                  
//                  Multi-tests for WB_CROSS
//                      ==> oriented for 4KB MM division for WBS
//
// Revision: 
// Revision 0.01 - File Created
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

`include "wb_intf.sv"
`include "wb_tb_simple_ram_slave.v"

module tb;
//////////////////////////////////////////////////////////////////////////////////
/**/
localparam  lp_MASTER_Q =    8;
localparam  lp_SLAVE_Q  =   16;
//
localparam  lp_ADDR_W   =   32;
localparam  lp_DATA_W   =   64;
localparam  lp_SEL_W    =    8;

localparam  lp_FULL_ADDR_RANGE  =   33'h1_0000_0000;    // 
localparam  lp_MY_MEM_SIZE      =    512;               // 512 WORDS (512x64bit)
//localparam  lp_MY_MEM_SIZE      =   4096;               // 4K WORDS
                                                        //  ==> wb_tb_simple_ram_slave: bit [pD_W-1 : 0] ram [16*512 : 0] !!!
/*
parameter  lp_MASTER_Q =   2;
parameter  lp_SLAVE_Q  =   8;
//
parameter  lp_ADDR_W   =   32;
parameter  lp_DATA_W   =   64;
parameter  lp_SEL_W    =    8;*/
//
parameter bit [lp_ADDR_W-1 : 0] lp_SLAVE_ADDR_BASE [0 : lp_SLAVE_Q-1] = '{
                                                                            32'h000_00, 
                                                                            32'h010_00, 
                                                                            32'h020_00, 
                                                                            32'h030_00, 
                                                                            32'h040_00, 
                                                                            32'h050_00, 
                                                                            32'h060_00, 
                                                                            32'h070_00, 
                                                                            32'h080_00, 
                                                                            32'h090_00, 
                                                                            32'h0A0_00, 
                                                                            32'h0B0_00, 
                                                                            32'h0C0_00, 
                                                                            32'h0D0_00, 
                                                                            32'h0E0_00, 
                                                                            32'h0F0_00  
                                                                            
                                                                        } ;
                                                                        

//////////////////////////////////////////////////////////////////////////////////
//
parameter   p_Tclk  =   10ns;
parameter   p_Trst  =   120ns;
//////////////////////////////////////////////////////////////////////////////////
    // Declare SYS_CON stuff:
    reg     s_sys_clk;
    reg     s_sys_rst;
    //
    logic   [2:0]               wb_m_cti_i  [0 : lp_MASTER_Q-1] ;
    logic   [1:0]               wb_m_bte_i  [0 : lp_MASTER_Q-1] ;
    logic   [lp_MASTER_Q-1 : 0] wb_m_cyc_i                      ;
    logic   [lp_MASTER_Q-1 : 0] wb_m_stb_i                      ;
    logic   [lp_MASTER_Q-1 : 0] wb_m_we_i                       ;
    logic   [lp_ADDR_W-1 : 0]   wb_m_adr_i  [0 : lp_MASTER_Q-1] ;
    logic   [lp_DATA_W-1 : 0]   wb_m_dat_i  [0 : lp_MASTER_Q-1] ;
    logic   [lp_SEL_W-1 : 0]    wb_m_sel_i  [0 : lp_MASTER_Q-1] ;
    logic   [lp_MASTER_Q-1 : 0] wb_m_ack_o                      ;
    logic   [lp_MASTER_Q-1 : 0] wb_m_err_o                      ;
    logic   [lp_MASTER_Q-1 : 0] wb_m_rty_o                      ;
    logic   [lp_DATA_W-1 : 0]   wb_m_dat_o  [0 : lp_MASTER_Q-1] ;
    
    logic   [2:0]               wb_s_cti_o  [0 : lp_SLAVE_Q-1]  ;
    logic   [1:0]               wb_s_bte_o  [0 : lp_SLAVE_Q-1]  ;
    logic   [lp_SLAVE_Q-1 : 0]  wb_s_ack_i                      ;
    logic   [lp_SLAVE_Q-1 : 0]  wb_s_err_i                      ;
    logic   [lp_SLAVE_Q-1 : 0]  wb_s_rty_i                      ;
    logic   [lp_DATA_W-1 : 0]   wb_s_dat_i  [0 : lp_SLAVE_Q-1]  ;
    logic   [lp_SLAVE_Q-1 : 0]  wb_s_cyc_o                      ;
    logic   [lp_SLAVE_Q-1 : 0]  wb_s_stb_o                      ;
    logic   [lp_SLAVE_Q-1 : 0]  wb_s_we_o                       ;
    logic   [lp_ADDR_W-1 : 0]   wb_s_adr_o  [0 : lp_SLAVE_Q-1]  ;
    logic   [lp_DATA_W-1 : 0]   wb_s_dat_o  [0 : lp_SLAVE_Q-1]  ;
    logic   [lp_SEL_W-1 : 0]    wb_s_sel_o  [0 : lp_SLAVE_Q-1]  ;
    //
    int err_cnt = 0;
//////////////////////////////////////////////////////////////////////////////////
//
// Use CLASS
//
`include "wb_tb_simple_master.sv"

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
// Instaniate WB_SLAVEs:
//
  generate
    for (genvar i = 0; i < lp_SLAVE_Q; i++) begin : slave_ram_gen
      wb_tb_simple_ram_slave
      #(
        .pA_W   ( lp_ADDR_W ) ,
        .pD_W   ( lp_DATA_W ) ,
        .pSEL_W ( lp_SEL_W  ) 
      )
      ram_slave
      (
        .clk   ( s_sys_clk         ) ,
        .rst   ( s_sys_rst         ) ,
        //
        .cyc_i ( wb_s_cyc_o [i] ) ,
        .stb_i ( wb_s_stb_o [i] ) ,
        .we_i  ( wb_s_we_o  [i] ) ,
        .adr_i ( {20'b0, wb_s_adr_o [i][11:0]} ) ,   // NB!!! 4KB WORD-ADDR ROUTE for now
        .dat_i ( wb_s_dat_o [i] ) ,
        .sel_i ( wb_s_sel_o [i] ) ,
        //
        .ack_o ( wb_s_ack_i [i] ) ,
        .err_o ( wb_s_err_i [i] ) ,
        .rty_o ( wb_s_rty_i [i] ) ,
        .dat_o ( wb_s_dat_i [i] )
      );
    end
  endgenerate
//////////////////////////////////////////////////////////////////////////////////
//
// Deal with WB MASTER stuff:
//
// wb_master if:
wb_m_if #(lp_ADDR_W, lp_DATA_W, lp_SEL_W) m_if[0 : lp_MASTER_Q-1] (s_sys_clk, s_sys_rst);
// wb master class:
wb_tb_simple_master wbm [lp_MASTER_Q];
// route wires
  generate
    for (genvar i = 0; i < lp_MASTER_Q ; i++) begin :   WBM_ROUTE
      assign wb_m_cyc_i[i] = m_if[i].cyc_o;
      assign wb_m_stb_i[i] = m_if[i].stb_o;
      assign wb_m_we_i [i] = m_if[i].we_o ;
      assign wb_m_adr_i[i] = m_if[i].adr_o;
      assign wb_m_dat_i[i] = m_if[i].dat_o;
      assign wb_m_sel_i[i] = m_if[i].sel_o;

      assign m_if[i].ack_i = wb_m_ack_o[i];
      assign m_if[i].err_i = wb_m_err_o[i];
      assign m_if[i].rty_i = wb_m_rty_o[i];
      assign m_if[i].dat_i = wb_m_dat_o[i];
    end
  endgenerate
// 
  generate
    for (genvar i = 0; i < lp_MASTER_Q; i++) begin  :   CRE_WBM
      initial begin : menthor_hack
        wbm[i] = new("master", m_if[i]);
      end
    end
  endgenerate
//////////////////////////////////////////////////////////////////////////////////
//
// Instaniate DEFAULT CLOCKING BLOCK:
//
  default clocking cb @(s_sys_clk);
  endclocking
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
    
    // PowerOnReset case
    s_sys_rst   <= 1; #p_Trst;
    s_sys_rst   <= 0;
    
end

initial
begin   :   CRE_WB_CTI_BTE
    
    for (int i=0;i<lp_MASTER_Q;i++)
        begin
            wb_m_cti_i[i] = i+$urandom_range(0, lp_MASTER_Q-1);
            wb_m_bte_i[i] = i+1+$urandom_range(0, lp_MASTER_Q-1);
        end
    
end
//////////////////////////////////////////////////////////////////////////////////
//
// Test: 
//
initial
begin   :   TB
    // Init MSG:
    $display("==> test start.");
    // Provide WB_MASTERs INIT:
    foreach (wbm[i]) begin
      wbm[i].init();
    end;
    // W8 PowerOnReset:
    do @(posedge s_sys_clk);
    while (s_sys_rst); #1us;
    // Main tests:
    single_master_multi_slave_test(1);      // 
    multi_master_single_slave_test(1, 0);   // nlock
    multi_master_single_slave_test(1, 1);   //  lock
    multi_master_multi_slave_test (1, 0);   // nlock
    multi_master_multi_slave_test (1, 1);   //  lock
    /**/
    // Final:
    $display("==> test done. errors = %0d", err_cnt);
    #100ns;
    $finish(2);
end

initial
begin   :   WB_CTI_BTE_PROCESS
    //
    // W8 PowerOnReset:
    do @(posedge s_sys_clk);
    while (s_sys_rst); #1us;
    //
    // START req stuff:
    for (int i=0;i<lp_MASTER_Q;i++)
        monitor_wb_cti_bte(i);
    
end
//////////////////////////////////////////////////////////////////////////////////
//
// 
//
wb_conmax_top   DUT
(
// SYS_CON
.clk_i      ( s_sys_clk     ), 
.rst_i      ( s_sys_rst     ), 
// 
// Master #0
// Wishbone Master interface
.m0_data_i  ( wb_m_dat_i[0] ), 
.m0_addr_i  ( wb_m_adr_i[0] ), 
.m0_sel_i   ( wb_m_sel_i[0] ), 
.m0_we_i    ( wb_m_we_i [0] ), 
.m0_cyc_i   ( wb_m_cyc_i[0] ), 
.m0_stb_i   ( wb_m_stb_i[0] ), 
.m0_cti_i   ( wb_m_cti_i[0] ),
.m0_bte_i   ( wb_m_bte_i[0] ),

.m0_data_o  ( wb_m_dat_o[0] ), 
.m0_ack_o   ( wb_m_ack_o[0] ), 
.m0_err_o   ( wb_m_err_o[0] ), 
.m0_rty_o   ( wb_m_rty_o[0] ), 
//
// Master #1
// Wishbone Master interface
.m1_data_i  ( wb_m_dat_i[1] ), 
.m1_addr_i  ( wb_m_adr_i[1] ), 
.m1_sel_i   ( wb_m_sel_i[1] ), 
.m1_we_i    ( wb_m_we_i [1] ), 
.m1_cyc_i   ( wb_m_cyc_i[1] ),
.m1_stb_i   ( wb_m_stb_i[1] ), 
.m1_cti_i   ( wb_m_cti_i[1] ),
.m1_bte_i   ( wb_m_bte_i[1] ),

.m1_data_o  ( wb_m_dat_o[1] ), 
.m1_ack_o   ( wb_m_ack_o[1] ), 
.m1_err_o   ( wb_m_err_o[1] ), 
.m1_rty_o   ( wb_m_rty_o[1] ), 
//
// Master #2
// Wishbone Master interface
.m2_data_i  ( wb_m_dat_i[2] ),
.m2_addr_i  ( wb_m_adr_i[2] ),
.m2_sel_i   ( wb_m_sel_i[2] ),
.m2_we_i    ( wb_m_we_i [2] ),
.m2_cyc_i   ( wb_m_cyc_i[2] ),
.m2_stb_i   ( wb_m_stb_i[2] ),
.m2_cti_i   ( wb_m_cti_i[2] ),
.m2_bte_i   ( wb_m_bte_i[2] ),

.m2_data_o  ( wb_m_dat_o[2] ),
.m2_ack_o   ( wb_m_ack_o[2] ),
.m2_err_o   ( wb_m_err_o[2] ),
.m2_rty_o   ( wb_m_rty_o[2] ),
//
// Master #3
// Wishbone Master interface
.m3_data_i  ( wb_m_dat_i[3] ),
.m3_addr_i  ( wb_m_adr_i[3] ),
.m3_sel_i   ( wb_m_sel_i[3] ),
.m3_we_i    ( wb_m_we_i [3] ),
.m3_cyc_i   ( wb_m_cyc_i[3] ),
.m3_stb_i   ( wb_m_stb_i[3] ),
.m3_cti_i   ( wb_m_cti_i[3] ),
.m3_bte_i   ( wb_m_bte_i[3] ),

.m3_data_o  ( wb_m_dat_o[3] ),
.m3_ack_o   ( wb_m_ack_o[3] ),
.m3_err_o   ( wb_m_err_o[3] ),
.m3_rty_o   ( wb_m_rty_o[3] ),
//
// Master #4
// Wishbone Master interface
.m4_data_i  ( wb_m_dat_i[4] ),
.m4_addr_i  ( wb_m_adr_i[4] ),
.m4_sel_i   ( wb_m_sel_i[4] ),
.m4_we_i    ( wb_m_we_i [4] ),
.m4_cyc_i   ( wb_m_cyc_i[4] ),
.m4_stb_i   ( wb_m_stb_i[4] ),
.m4_cti_i   ( wb_m_cti_i[4] ),
.m4_bte_i   ( wb_m_bte_i[4] ),

.m4_data_o  ( wb_m_dat_o[4] ),
.m4_ack_o   ( wb_m_ack_o[4] ),
.m4_err_o   ( wb_m_err_o[4] ),
.m4_rty_o   ( wb_m_rty_o[4] ),
//
// Master #5
// Wishbone Master interface
.m5_data_i  ( wb_m_dat_i[5] ),
.m5_addr_i  ( wb_m_adr_i[5] ),
.m5_sel_i   ( wb_m_sel_i[5] ),
.m5_we_i    ( wb_m_we_i [5] ),
.m5_cyc_i   ( wb_m_cyc_i[5] ),
.m5_stb_i   ( wb_m_stb_i[5] ),
.m5_cti_i   ( wb_m_cti_i[5] ),
.m5_bte_i   ( wb_m_bte_i[5] ),

.m5_data_o  ( wb_m_dat_o[5] ),
.m5_ack_o   ( wb_m_ack_o[5] ),
.m5_err_o   ( wb_m_err_o[5] ),
.m5_rty_o   ( wb_m_rty_o[5] ),
//
// Master #6
// Wishbone Master interfac
.m6_data_i  ( wb_m_dat_i[6] ),
.m6_addr_i  ( wb_m_adr_i[6] ),
.m6_sel_i   ( wb_m_sel_i[6] ),
.m6_we_i    ( wb_m_we_i [6] ),
.m6_cyc_i   ( wb_m_cyc_i[6] ),
.m6_stb_i   ( wb_m_stb_i[6] ),
.m6_cti_i   ( wb_m_cti_i[6] ),
.m6_bte_i   ( wb_m_bte_i[6] ),

.m6_data_o  ( wb_m_dat_o[6] ),
.m6_ack_o   ( wb_m_ack_o[6] ),
.m6_err_o   ( wb_m_err_o[6] ),
.m6_rty_o   ( wb_m_rty_o[6] ),
//
// Master #7
// Wishbone Master interface
.m7_data_i  ( wb_m_dat_i[7] ),
.m7_addr_i  ( wb_m_adr_i[7] ),
.m7_sel_i   ( wb_m_sel_i[7] ),
.m7_we_i    ( wb_m_we_i [7] ),
.m7_cyc_i   ( wb_m_cyc_i[7] ),
.m7_stb_i   ( wb_m_stb_i[7] ),
.m7_cti_i   ( wb_m_cti_i[7] ),
.m7_bte_i   ( wb_m_bte_i[7] ),

.m7_data_o  ( wb_m_dat_o[7] ),
.m7_ack_o   ( wb_m_ack_o[7] ),
.m7_err_o   ( wb_m_err_o[7] ),
.m7_rty_o   ( wb_m_rty_o[7] ),

//
// Slave #0
// Wishbone Slave interface
.s0_data_o  ( wb_s_dat_o[0] ),
.s0_addr_o  ( wb_s_adr_o[0] ),
.s0_sel_o   ( wb_s_sel_o[0] ),
.s0_we_o    ( wb_s_we_o [0] ),
.s0_cyc_o   ( wb_s_cyc_o[0] ),
.s0_stb_o   ( wb_s_stb_o[0] ),
.s0_cti_o   ( wb_s_cti_o[0] ),
.s0_bte_o   ( wb_s_bte_o[0] ),

.s0_data_i  ( wb_s_dat_i[0] ),
.s0_ack_i   ( wb_s_ack_i[0] ),
.s0_err_i   ( wb_s_err_i[0] ),
.s0_rty_i   ( wb_s_rty_i[0] ),
//
// Slave #1
// Wishbone Slave interface
.s1_data_o  ( wb_s_dat_o[1] ),
.s1_addr_o  ( wb_s_adr_o[1] ),
.s1_sel_o   ( wb_s_sel_o[1] ),
.s1_we_o    ( wb_s_we_o [1] ),
.s1_cyc_o   ( wb_s_cyc_o[1] ),
.s1_stb_o   ( wb_s_stb_o[1] ),
.s1_cti_o   ( wb_s_cti_o[1] ),
.s1_bte_o   ( wb_s_bte_o[1] ),

.s1_data_i  ( wb_s_dat_i[1] ),
.s1_ack_i   ( wb_s_ack_i[1] ),
.s1_err_i   ( wb_s_err_i[1] ),
.s1_rty_i   ( wb_s_rty_i[1] ),
//
// Slave #2
// Wishbone Slave interface
.s2_data_o  ( wb_s_dat_o[2] ),
.s2_addr_o  ( wb_s_adr_o[2] ),
.s2_sel_o   ( wb_s_sel_o[2] ),
.s2_we_o    ( wb_s_we_o [2] ),
.s2_cyc_o   ( wb_s_cyc_o[2] ),
.s2_stb_o   ( wb_s_stb_o[2] ),
.s2_cti_o   ( wb_s_cti_o[2] ),
.s2_bte_o   ( wb_s_bte_o[2] ),

.s2_data_i  ( wb_s_dat_i[2] ),
.s2_ack_i   ( wb_s_ack_i[2] ),
.s2_err_i   ( wb_s_err_i[2] ),
.s2_rty_i   ( wb_s_rty_i[2] ),
//
// Slave #3
// Wishbone Slave interface
.s3_data_o  ( wb_s_dat_o[3] ),
.s3_addr_o  ( wb_s_adr_o[3] ),
.s3_sel_o   ( wb_s_sel_o[3] ),
.s3_we_o    ( wb_s_we_o [3] ),
.s3_cyc_o   ( wb_s_cyc_o[3] ),
.s3_stb_o   ( wb_s_stb_o[3] ),
.s3_cti_o   ( wb_s_cti_o[3] ),
.s3_bte_o   ( wb_s_bte_o[3] ),

.s3_data_i  ( wb_s_dat_i[3] ),
.s3_ack_i   ( wb_s_ack_i[3] ),
.s3_err_i   ( wb_s_err_i[3] ),
.s3_rty_i   ( wb_s_rty_i[3] ),
//
// Slave #4
// Wishbone Slave interface
.s4_data_o  ( wb_s_dat_o[4] ),
.s4_addr_o  ( wb_s_adr_o[4] ),
.s4_sel_o   ( wb_s_sel_o[4] ),
.s4_we_o    ( wb_s_we_o [4] ),
.s4_cyc_o   ( wb_s_cyc_o[4] ),
.s4_stb_o   ( wb_s_stb_o[4] ),
.s4_cti_o   ( wb_s_cti_o[4] ),
.s4_bte_o   ( wb_s_bte_o[4] ),

.s4_data_i  ( wb_s_dat_i[4] ),
.s4_ack_i   ( wb_s_ack_i[4] ),
.s4_err_i   ( wb_s_err_i[4] ),
.s4_rty_i   ( wb_s_rty_i[4] ),
//
// Slave #5
// Wishbone Slave interface
.s5_data_o  ( wb_s_dat_o[5] ),
.s5_addr_o  ( wb_s_adr_o[5] ),
.s5_sel_o   ( wb_s_sel_o[5] ),
.s5_we_o    ( wb_s_we_o [5] ),
.s5_cyc_o   ( wb_s_cyc_o[5] ),
.s5_stb_o   ( wb_s_stb_o[5] ),
.s5_cti_o   ( wb_s_cti_o[5] ),
.s5_bte_o   ( wb_s_bte_o[5] ),

.s5_data_i  ( wb_s_dat_i[5] ),
.s5_ack_i   ( wb_s_ack_i[5] ),
.s5_err_i   ( wb_s_err_i[5] ),
.s5_rty_i   ( wb_s_rty_i[5] ),
//
// Slave #6
// Wishbone Slave interface
.s6_data_o  ( wb_s_dat_o[6] ),
.s6_addr_o  ( wb_s_adr_o[6] ),
.s6_sel_o   ( wb_s_sel_o[6] ),
.s6_we_o    ( wb_s_we_o [6] ),
.s6_cyc_o   ( wb_s_cyc_o[6] ),
.s6_stb_o   ( wb_s_stb_o[6] ),
.s6_cti_o   ( wb_s_cti_o[6] ),
.s6_bte_o   ( wb_s_bte_o[6] ),

.s6_data_i  ( wb_s_dat_i[6] ),
.s6_ack_i   ( wb_s_ack_i[6] ),
.s6_err_i   ( wb_s_err_i[6] ),
.s6_rty_i   ( wb_s_rty_i[6] ),
//
// Slave #7
// Wishbone Slave interface
.s7_data_o  ( wb_s_dat_o[7] ),
.s7_addr_o  ( wb_s_adr_o[7] ),
.s7_sel_o   ( wb_s_sel_o[7] ),
.s7_we_o    ( wb_s_we_o [7] ),
.s7_cyc_o   ( wb_s_cyc_o[7] ),
.s7_stb_o   ( wb_s_stb_o[7] ),
.s7_cti_o   ( wb_s_cti_o[7] ),
.s7_bte_o   ( wb_s_bte_o[7] ),

.s7_data_i  ( wb_s_dat_i[7] ),
.s7_ack_i   ( wb_s_ack_i[7] ),
.s7_err_i   ( wb_s_err_i[7] ),
.s7_rty_i   ( wb_s_rty_i[7] ),
//
// Slave #8
// Wishbone Slave interface
.s8_data_o  ( wb_s_dat_o[8] ),
.s8_addr_o  ( wb_s_adr_o[8] ),
.s8_sel_o   ( wb_s_sel_o[8] ),
.s8_we_o    ( wb_s_we_o [8] ),
.s8_cyc_o   ( wb_s_cyc_o[8] ),
.s8_stb_o   ( wb_s_stb_o[8] ),
.s8_cti_o   ( wb_s_cti_o[8] ),
.s8_bte_o   ( wb_s_bte_o[8] ),

.s8_data_i  ( wb_s_dat_i[8] ),
.s8_ack_i   ( wb_s_ack_i[8] ),
.s8_err_i   ( wb_s_err_i[8] ),
.s8_rty_i   ( wb_s_rty_i[8] ),
//
// Slave #9
// Wishbone Slave interface
.s9_data_o  ( wb_s_dat_o[9] ),
.s9_addr_o  ( wb_s_adr_o[9] ),
.s9_sel_o   ( wb_s_sel_o[9] ),
.s9_we_o    ( wb_s_we_o [9] ),
.s9_cyc_o   ( wb_s_cyc_o[9] ),
.s9_stb_o   ( wb_s_stb_o[9] ),
.s9_cti_o   ( wb_s_cti_o[9] ),
.s9_bte_o   ( wb_s_bte_o[9] ),

.s9_data_i  ( wb_s_dat_i[9] ),
.s9_ack_i   ( wb_s_ack_i[9] ),
.s9_err_i   ( wb_s_err_i[9] ),
.s9_rty_i   ( wb_s_rty_i[9] ),
//
// Slave #10
// Wishbone Slave interface
.s10_data_o  ( wb_s_dat_o[10] ),
.s10_addr_o  ( wb_s_adr_o[10] ),
.s10_sel_o   ( wb_s_sel_o[10] ),
.s10_we_o    ( wb_s_we_o [10] ),
.s10_cyc_o   ( wb_s_cyc_o[10] ),
.s10_stb_o   ( wb_s_stb_o[10] ),
.s10_cti_o   ( wb_s_cti_o[10] ),
.s10_bte_o   ( wb_s_bte_o[10] ),

.s10_data_i  ( wb_s_dat_i[10] ),
.s10_ack_i   ( wb_s_ack_i[10] ),
.s10_err_i   ( wb_s_err_i[10] ),
.s10_rty_i   ( wb_s_rty_i[10] ),
//
// Slave #11
// Wishbone Slave interface
.s11_data_o  ( wb_s_dat_o[11] ),
.s11_addr_o  ( wb_s_adr_o[11] ),
.s11_sel_o   ( wb_s_sel_o[11] ),
.s11_we_o    ( wb_s_we_o [11] ),
.s11_cyc_o   ( wb_s_cyc_o[11] ),
.s11_stb_o   ( wb_s_stb_o[11] ),
.s11_cti_o   ( wb_s_cti_o[11] ),
.s11_bte_o   ( wb_s_bte_o[11] ),

.s11_data_i  ( wb_s_dat_i[11] ),
.s11_ack_i   ( wb_s_ack_i[11] ),
.s11_err_i   ( wb_s_err_i[11] ),
.s11_rty_i   ( wb_s_rty_i[11] ),
//
// Slave #12
// Wishbone Slave interface
.s12_data_o  ( wb_s_dat_o[12] ),
.s12_addr_o  ( wb_s_adr_o[12] ),
.s12_sel_o   ( wb_s_sel_o[12] ),
.s12_we_o    ( wb_s_we_o [12] ),
.s12_cyc_o   ( wb_s_cyc_o[12] ),
.s12_stb_o   ( wb_s_stb_o[12] ),
.s12_cti_o   ( wb_s_cti_o[12] ),
.s12_bte_o   ( wb_s_bte_o[12] ),

.s12_data_i  ( wb_s_dat_i[12] ),
.s12_ack_i   ( wb_s_ack_i[12] ),
.s12_err_i   ( wb_s_err_i[12] ),
.s12_rty_i   ( wb_s_rty_i[12] ),
//
// Slave #13
// Wishbone Slave interface
.s13_data_o  ( wb_s_dat_o[13] ),
.s13_addr_o  ( wb_s_adr_o[13] ),
.s13_sel_o   ( wb_s_sel_o[13] ),
.s13_we_o    ( wb_s_we_o [13] ),
.s13_cyc_o   ( wb_s_cyc_o[13] ),
.s13_stb_o   ( wb_s_stb_o[13] ),
.s13_cti_o   ( wb_s_cti_o[13] ),
.s13_bte_o   ( wb_s_bte_o[13] ),

.s13_data_i  ( wb_s_dat_i[13] ),
.s13_ack_i   ( wb_s_ack_i[13] ),
.s13_err_i   ( wb_s_err_i[13] ),
.s13_rty_i   ( wb_s_rty_i[13] ),
//
// Slave #14
// Wishbone Slave interface
.s14_data_o  ( wb_s_dat_o[14] ),
.s14_addr_o  ( wb_s_adr_o[14] ),
.s14_sel_o   ( wb_s_sel_o[14] ),
.s14_we_o    ( wb_s_we_o [14] ),
.s14_cyc_o   ( wb_s_cyc_o[14] ),
.s14_stb_o   ( wb_s_stb_o[14] ),
.s14_cti_o   ( wb_s_cti_o[14] ),
.s14_bte_o   ( wb_s_bte_o[14] ),

.s14_data_i  ( wb_s_dat_i[14] ),
.s14_ack_i   ( wb_s_ack_i[14] ),
.s14_err_i   ( wb_s_err_i[14] ),
.s14_rty_i   ( wb_s_rty_i[14] ),
//
// Slave #15
// Wishbone Slave interface
.s15_data_o  ( wb_s_dat_o[15] ),
.s15_addr_o  ( wb_s_adr_o[15] ),
.s15_sel_o   ( wb_s_sel_o[15] ),
.s15_we_o    ( wb_s_we_o [15] ),
.s15_cyc_o   ( wb_s_cyc_o[15] ),
.s15_stb_o   ( wb_s_stb_o[15] ),
.s15_cti_o   ( wb_s_cti_o[15] ),
.s15_bte_o   ( wb_s_bte_o[15] ),

.s15_data_i  ( wb_s_dat_i[15] ),
.s15_ack_i   ( wb_s_ack_i[15] ),
.s15_err_i   ( wb_s_err_i[15] ),
.s15_rty_i   ( wb_s_rty_i[15] ) 
);
    defparam    DUT.dw  =   64;
    defparam    DUT.aw  =   32;
//////////////////////////////////////////////////////////////////////////////////
//
//
//
task monitor_wb_cti_bte (int ii_master_num);
    //
    fork
        // 
        automatic int master_num = ii_master_num;
        // 
        $display("[%t]: %m START, MASTER idx=%h", $time, master_num[7:0]);
        forever
            begin
                ##1;
                if (wb_m_ack_o[master_num])
                    begin   :   WB_ACK
                        // WB_CTI:
                        if (wb_m_cti_i[master_num]!=wb_s_cti_o[get_slave_idx(wb_m_adr_i[master_num])])
                            begin   :   WB_CTI_ERR
                                $display("[%t]: %m, wb_m_cti_i[master_num]==%b", $time, wb_m_cti_i[master_num]);
                                $display("[%t]: %m, wb_m_adr_i[master_num]==%h", $time, wb_m_adr_i[master_num]);
                                $display("[%t]: %m, get_slave_idx(wb_s_adr_o[master_num])==%h", $time, get_slave_idx(wb_s_adr_o[master_num]));
                                $display("[%t]: %m, wb_s_cti_o[get_slave_idx(wb_s_adr_o[master_num])==%b", 
                                $time, 
                                wb_s_cti_o[get_slave_idx(wb_s_adr_o[master_num])]
                                        );
                                
                                $display("[%t]: %m, master_num==%h", $time, master_num[7:0]); #1ns;
                                $stop;
                            end
                        // WB_BTE:
                        if (wb_m_bte_i[master_num]!=wb_s_bte_o[get_slave_idx(wb_s_adr_o[master_num])])
                            begin   :   WB_BTE_ERR
                                $display("[%t]: %m, master_num==%h", $time, master_num[7:0]);
                                $stop;
                            end
                    end
            end
    join_none
    //
endtask
/**/
//
// test when only 1 master is active and access to all slaves, NB!!! ==> USE ==> 512 WORDS
//
  task single_master_multi_slave_test (int num = 1);
    $display("%t single master multi slave test begin", $time);
    test_begin();
    //
    for (int i = 0; i < num; i++) begin
      for (int m = 0; m < lp_MASTER_Q; m++) begin
        for (int j=0;j<lp_SLAVE_Q;j++) begin
            //$display("[%t]: %m, SLAVE[%h] & MASTER[%h] begin", $time, j[7:0], m[7:0]);
            // WBS#i check 
            wbm[m].generate_data_packet(lp_MY_MEM_SIZE);           // ==> operate with lp_MY_MEM_SIZE WORDS 
            wbm[m].max_ws = 2+$urandom_range(0, j);
            // use rnd mode
            wbm[m].write_data_packet_locked(lp_SLAVE_ADDR_BASE[j], 1);
            wbm[m].read_data_packet_locked(lp_SLAVE_ADDR_BASE[j], 1);
            ##10;
            wbm[m].write_data_packet_nlocked(lp_SLAVE_ADDR_BASE[j], 1);
            wbm[m].read_data_packet_nlocked(lp_SLAVE_ADDR_BASE[j], 1);
            ##10;
            //$display("[%t]: %m, SLAVE[%h] & MASTER[%h] end", $time, j[7:0], m[7:0]);
        end
      end
    end
    //
    $display("%t single master multi slave test end", $time);
    test_end();
  endtask

//
// test when multi masters is active and access to 1 slave
//
  task multi_master_single_slave_test (int num = 1, lock = 0);
    int slave_size;
    int master_size;
    int start_address ;
  begin
    if (lock)
      $display("%t multi master single slave test with lock begin", $time);
    else
      $display("%t multi master single slave test with nlock begin", $time);
    test_begin();
    //
    slave_size  = lp_MY_MEM_SIZE/lp_SLAVE_Q;     // let's all slaves have same size    NB!!! ==> USE lp_MY_MEM_SIZE WORDS
    master_size = slave_size/lp_MASTER_Q;  // let's each master use same size of slave
    //$display("%m, slave_size==%h", slave_size); $display("%m, master_size==%h", master_size);
    for (int i = 0; i < num; i++) begin
      for (int s = 0; s < lp_SLAVE_Q; s++) begin
        for (int m = 0; m < lp_MASTER_Q; m++) begin
          wbm[m].generate_data_packet(master_size);
          wbm[m].max_ws = 2;
          start_address = lp_SLAVE_ADDR_BASE[s] + m*master_size;

          fork
            automatic int _m = m;
            automatic int _start_address = start_address;
            begin
              if (lock) begin
                wbm[_m].write_data_packet_locked (_start_address, 1);
                wbm[_m].read_data_packet_locked  (_start_address, 1);
              end
              else begin
                wbm[_m].write_data_packet_nlocked (_start_address, 1);
                wbm[_m].read_data_packet_nlocked  (_start_address, 1);
              end
            end
          join_none

        end
        wait fork;
      end
    end
    //
    if (lock)
      $display("%t multi master single slave with lock test end", $time);
    else
      $display("%t multi master single slave with nlock test end", $time);
    test_end();
  end
  endtask

  //
  // test when multi masters is active and access to multi slave
  //

  task multi_master_multi_slave_test (int num = 1, lock = 0);
    int ram_size;
    int master_size;
    int slave_size;
    int start_address ;
  begin
    if (lock)
      $display("%t multi master multi slave test with lock begin", $time);
    else
      $display("%t multi master multi slave test with nlock begin", $time);
    test_begin();
    //
    ram_size    = lp_MY_MEM_SIZE;     // --> NB!!! ==> USE lp_MY_MEM_SIZE WORDS
    master_size = ram_size/lp_MASTER_Q;   // let's each master use same size of ram address
    slave_size  = ram_size/lp_SLAVE_Q;    // let's each slave use same size or ram address
    //
    for (int i = 0; i < num; i++) begin
      for (int s = 0; s < lp_SLAVE_Q; s++) begin
        for (int m = 0; m < lp_MASTER_Q; m++) begin
          wbm[m].generate_data_packet(master_size); //$display("%m, s==%h, master_size==%h", s, master_size);
          wbm[m].max_ws = 2;
          start_address = (s*slave_size + m*master_size) % ram_size;

          fork
            automatic int _m = m;
            automatic int _start_address = start_address;
            begin
              if (lock) begin
                wbm[_m].write_data_packet_locked (_start_address, 1);
                wbm[_m].read_data_packet_locked  (_start_address, 1);
              end
              else begin
                wbm[_m].write_data_packet_nlocked (_start_address, 1); //$display("%m, write_data_packet_nlocked, _m==%h, _start_address==%h", _m, _start_address);
                wbm[_m].read_data_packet_nlocked  (_start_address, 1); //$display("%m, read_data_packet_nlocked,  _m==%h, _start_address==%h", _m, _start_address);
              end
            end
          join_none

        end // m
        wait fork;
      end // s
    end // i
    //
    if (lock)
      $display("%t multi master multi slave with lock test end", $time);
    else
      $display("%t multi master multi slave with nlock test end", $time);
    test_end();
  end
  endtask
//////////////////////////////////////////////////////////////////////////////////
//
// service functions
//

  function void test_begin ();
   foreach (wbm[i]) begin
      wbm[i].err_cnt = 0;
    end
  endfunction

  function void test_end ();
    foreach (wbm[i]) begin
      wbm[i].log();
      err_cnt += wbm[i].err_cnt;
    end
  endfunction
/**/
function automatic int get_slave_idx( input bit [lp_ADDR_W-1:0] iv_addr);
    //
        for (int i=1;i<lp_SLAVE_Q;i++) // process all slaves
            begin
                if (iv_addr>=lp_SLAVE_ADDR_BASE[i-1] & iv_addr<lp_SLAVE_ADDR_BASE[i])   // ADDR in slave[i] range
                    return (i-1);
            end
        // ELSE - return MAX_VALUE
        return ('1);
    //
endfunction
/**/
//////////////////////////////////////////////////////////////////////////////////
endmodule
