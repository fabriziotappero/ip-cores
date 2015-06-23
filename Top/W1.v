`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  (C) Athree, 2009
// Engineer: Dmitry Rozhdestvenskiy 
// Email dmitry.rozhdestvenskiy@srisc.com dmitryr@a3.spb.ru divx4log@narod.ru
// 
// Design Name:    SPARC SoC single-core top level for Altera StratixIV devkit
// Module Name:    W1 
// Project Name:   SPARC SoC single-core
//
// LICENSE:
// This is a Free Hardware Design; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// version 2 as published by the Free Software Foundation.
// The above named program is distributed in the hope that it will
// be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
//////////////////////////////////////////////////////////////////////////////////

module W1(

   input         sysclk,
   input         sysrst,

   // ddr3 memory interface
   inout  [63:0] ddr3_dq,
   inout  [ 7:0] ddr3_dqs,
   inout  [ 7:0] ddr3_dqs_n,
   inout         ddr3_ck,
   inout         ddr3_ck_n,
   output        ddr3_reset,
   output [12:0] ddr3_a,
   output [ 2:0] ddr3_ba,
   output        ddr3_ras_n,
   output        ddr3_cas_n,
   output        ddr3_we_n,
   output        ddr3_cs_n,
   output        ddr3_odt,
   output        ddr3_ce,
   output [ 7:0] ddr3_dm,

   output        phy_init_done, // LED
   input         rup,
   input         rdn,
	
   // Console interface
   input  srx,
   output stx,
   input  [1:0] flash_rev,
   
   /* MII interface replaced by SGMII
   
   input        mtx_clk_pad_i, 
   output [3:0] mtxd_pad_o, 
   output       mtxen_pad_o, 
   output       mtxerr_pad_o, 
   input        mrx_clk_pad_i, 
   input  [3:0] mrxd_pad_i, 
   input        mrxdv_pad_i, 
   input        mrxerr_pad_i, 
   input        mcoll_pad_i, 
   input        mcrs_pad_i, */
   output       mdc, 
   inout        md, 
   
   output eth_rst,
   output eth_tx,
   input  eth_rx,
   
   output led_10,
   output led_100,
   output led_1000,
   output led_link,
   output led_disp_err,
   output led_char_err,
   output led_an,
	
   output     [24:0] flash_addr,
   input      [15:0] flash_data,
   output            flash_oen,
   output            flash_wen,
   output            flash_cen,
   output            flash_clk,
   output            flash_adv,
   output            flash_rst
);

wire wb_rst_i;
wire [35:0] CONTROL0;
wire [35:0] CONTROL1;
wire [35:0] CONTROL2;
wire [1:0] VIO_SIG;

reg [31:0] cycle_count;

assign flash_clk=1;
assign flash_adv=0;
assign flash_rst=!wb_rst_i;

wire [63:0] m0_dat_i;
wire [63:0] m0_dat_o;
wire [63:0] m0_adr_i;
wire [ 7:0] m0_sel_i;
wire        m0_we_i;
wire        m0_cyc_i; 
wire        m0_stb_i;
wire        m0_ack_o;

wire [63:0] m1_dat_i;
wire [63:0] m1_dat_o;
wire [63:0] m1_adr_i;
wire [ 7:0] m1_sel_i;
wire        m1_we_i;
wire        m1_cyc_i; 
wire        m1_stb_i;
wire        m1_ack_o;

wire [63:0] s0_dat_i; 
wire [63:0] s0_dat_o;
wire [63:0] s0_adr_o;
wire [ 7:0] s0_sel_o;
wire        s0_we_o;
wire        s0_cyc_o; 
wire        s0_stb_o;
wire        s0_ack_i;

wire [63:0] s1_dat_i; 
wire [63:0] s1_dat_o;
wire [63:0] s1_adr_o;
wire [ 7:0] s1_sel_o;
wire        s1_we_o;
wire        s1_cyc_o; 
wire        s1_stb_o;
wire        s1_ack_i;

wire [63:0] s2_dat_i; 
wire [63:0] s2_dat_o;
wire [63:0] s2_adr_o;
wire [ 7:0] s2_sel_o;
wire        s2_we_o;
wire        s2_cyc_o; 
wire        s2_stb_o;
wire        s2_ack_i;

wire [63:0] s3_dat_i; 
wire [63:0] s3_dat_o;
wire [63:0] s3_adr_o;
wire [ 7:0] s3_sel_o;
wire        s3_we_o;
wire        s3_cyc_o; 
wire        s3_stb_o;
wire        s3_ack_i;

wire [63:0] s4_dat_i; 
wire [63:0] s4_dat_o;
wire [63:0] s4_adr_o;
wire [ 7:0] s4_sel_o;
wire        s4_we_o;
wire        s4_cyc_o; 
wire        s4_stb_o;
wire        s4_ack_i;

wb_conbus_top wishbone (
    .clk_i(wb_clk_i), 
    .rst_i(wb_rst_i), 
    
    //CPU
    .m0_dat_i(m0_dat_i), 
    .m0_dat_o(m0_dat_o), 
    .m0_adr_i(m0_adr_i), 
    .m0_sel_i(m0_sel_i), 
    .m0_we_i(m0_we_i), 
    .m0_cyc_i(m0_cyc_i), 
    .m0_stb_i(m0_stb_i), 
    .m0_ack_o(m0_ack_o), 
    .m0_err_o(), 
    .m0_rty_o(), 
    .m0_cab_i(0),
    
    //Ethernet
    .m1_dat_i(m1_dat_i), 
    .m1_dat_o(m1_dat_o), 
    .m1_adr_i(m1_adr_i), 
    .m1_sel_i(m1_sel_i), 
    .m1_we_i(m1_we_i), 
    .m1_cyc_i(m1_cyc_i), 
    .m1_stb_i(m1_stb_i), 
    .m1_ack_o(m1_ack_o), 
    .m1_err_o(m1_err_o), 
    .m1_rty_o(m1_rty_o), 
    .m1_cab_i(m1_cab_i), 

    .m2_dat_i(0), 
    .m2_dat_o(), 
    .m2_adr_i(0), 
    .m2_sel_i(0), 
    .m2_we_i(0), 
    .m2_cyc_i(0), 
    .m2_stb_i(0), 
    .m2_ack_o(), 
    .m2_err_o(), 
    .m2_rty_o(), 
    .m2_cab_i(0), 

    .m3_dat_i(0), 
    .m3_dat_o(), 
    .m3_adr_i(0), 
    .m3_sel_i(0), 
    .m3_we_i(0), 
    .m3_cyc_i(0), 
    .m3_stb_i(0), 
    .m3_ack_o(), 
    .m3_err_o(), 
    .m3_rty_o(), 
    .m3_cab_i(0), 

    .m4_dat_i(0), 
    .m4_dat_o(), 
    .m4_adr_i(0), 
    .m4_sel_i(0), 
    .m4_we_i(0), 
    .m4_cyc_i(0), 
    .m4_stb_i(0), 
    .m4_ack_o(), 
    .m4_err_o(), 
    .m4_rty_o(), 
    .m4_cab_i(0), 

    .m5_dat_i(0), 
    .m5_dat_o(), 
    .m5_adr_i(0), 
    .m5_sel_i(0), 
    .m5_we_i(0), 
    .m5_cyc_i(0), 
    .m5_stb_i(0), 
    .m5_ack_o(), 
    .m5_err_o(), 
    .m5_rty_o(), 
    .m5_cab_i(0), 

    .m6_dat_i(0), 
    .m6_dat_o(), 
    .m6_adr_i(0), 
    .m6_sel_i(0), 
    .m6_we_i(0), 
    .m6_cyc_i(0), 
    .m6_stb_i(0), 
    .m6_ack_o(), 
    .m6_err_o(), 
    .m6_rty_o(), 
    .m6_cab_i(0), 

    .m7_dat_i(0), 
    .m7_dat_o(), 
    .m7_adr_i(0), 
    .m7_sel_i(0), 
    .m7_we_i(0), 
    .m7_cyc_i(0), 
    .m7_stb_i(0), 
    .m7_ack_o(), 
    .m7_err_o(), 
    .m7_rty_o(), 
    .m7_cab_i(0), 

    //DRAM
    .s0_dat_i(s0_dat_i), 
    .s0_dat_o(s0_dat_o), 
    .s0_adr_o(s0_adr_o), 
    .s0_sel_o(s0_sel_o), 
    .s0_we_o(s0_we_o), 
    .s0_cyc_o(s0_cyc_o), 
    .s0_stb_o(s0_stb_o), 
    .s0_ack_i(s0_ack_i), 
    .s0_err_i(0), 
    .s0_rty_i(0), 
    .s0_cab_o(),
    
    //Flash
    .s1_dat_i(s1_dat_i), 
    .s1_dat_o(s1_dat_o), 
    .s1_adr_o(s1_adr_o), 
    .s1_sel_o(s1_sel_o), 
    .s1_we_o(s1_we_o), 
    .s1_cyc_o(s1_cyc_o), 
    .s1_stb_o(s1_stb_o), 
    .s1_ack_i(s1_ack_i), 
    .s1_err_i(s1_err_i), 
    .s1_rty_i(s1_rty_i), 
    .s1_cab_o(s1_cab_o), 

    //Ethernet
    .s2_dat_i(s2_dat_i), 
    .s2_dat_o(s2_dat_o), 
    .s2_adr_o(s2_adr_o), 
    .s2_sel_o(s2_sel_o), 
    .s2_we_o(s2_we_o), 
    .s2_cyc_o(s2_cyc_o), 
    .s2_stb_o(s2_stb_o), 
    .s2_ack_i(s2_ack_i), 
    .s2_err_i(s2_err_i), 
    .s2_rty_i(s2_rty_i), 
    .s2_cab_o(s2_cab_o), 

    //UART
    .s3_dat_i({s3_dat_i[31:0],s3_dat_i[31:0]}), 
    .s3_dat_o(s3_dat_o), 
    .s3_adr_o(s3_adr_o), 
    .s3_sel_o(s3_sel_o), 
    .s3_we_o(s3_we_o), 
    .s3_cyc_o(s3_cyc_o), 
    .s3_stb_o(s3_stb_o), 
    .s3_ack_i(s3_ack_i), 
    .s3_err_i(s3_err_i), 
    .s3_rty_i(s3_rty_i), 
    .s3_cab_o(s3_cab_o), 

    //Second flash interface for fff8xxxxxx ram disk addressing
    .s4_dat_i(s4_dat_i), 
    .s4_dat_o(s4_dat_o), 
    .s4_adr_o(s4_adr_o), 
    .s4_sel_o(s4_sel_o), 
    .s4_we_o(s4_we_o), 
    .s4_cyc_o(s4_cyc_o), 
    .s4_stb_o(s4_stb_o), 
    .s4_ack_i(s4_ack_i), 
    .s4_err_i(s4_err_i), 
    .s4_rty_i(s4_rty_i), 
    .s4_cab_o(s4_cab_o), 

    .s5_dat_i(0), 
    .s5_dat_o(), 
    .s5_adr_o(), 
    .s5_sel_o(), 
    .s5_we_o(), 
    .s5_cyc_o(), 
    .s5_stb_o(), 
    .s5_ack_i(0), 
    .s5_err_i(0), 
    .s5_rty_i(0), 
    .s5_cab_o(), 

    .s6_dat_i(0), 
    .s6_dat_o(), 
    .s6_adr_o(), 
    .s6_sel_o(), 
    .s6_we_o(), 
    .s6_cyc_o(), 
    .s6_stb_o(), 
    .s6_ack_i(0), 
    .s6_err_i(0), 
    .s6_rty_i(0), 
    .s6_cab_o(), 

    .s7_dat_i(0), 
    .s7_dat_o(), 
    .s7_adr_o(), 
    .s7_sel_o(), 
    .s7_we_o(), 
    .s7_cyc_o(), 
    .s7_stb_o(), 
    .s7_ack_i(0), 
    .s7_err_i(0), 
    .s7_rty_i(0), 
    .s7_cab_o() 
);
	
s1_top cpu (
    .sys_clock_i(wb_clk_i), 
    .sys_reset_i(wb_rst_i), 
    .eth_irq_i(eth_irq), 
    .wbm_ack_i(m0_ack_o), 
    .wbm_data_i(m0_dat_o), 
    .wbm_cycle_o(m0_cyc_i), 
    .wbm_strobe_o(m0_stb_i), 
    .wbm_we_o(m0_we_i), 
    .wbm_addr_o(m0_adr_i), 
    .wbm_data_o(m0_dat_i), 
    .wbm_sel_o(m0_sel_i)
    );

wire [7:0] fifo_used;

dram_wb dram_wb_inst (
    .clk200(sysclk), 
    .rup(rup),
    .rdn(rdn),
    .wb_clk_i(wb_clk_i), 
    .wb_rst_i(wb_rst_i), 
    .wb_dat_i(s0_dat_o), 
    .wb_dat_o(s0_dat_i), 
    .wb_adr_i(s0_adr_o), 
    .wb_sel_i(s0_sel_o), 
    .wb_we_i(s0_we_o), 
    .wb_cyc_i(s0_cyc_o), 
    .wb_stb_i(s0_stb_o), 
    .wb_ack_o(s0_ack_i), 
    .wb_err_o(s0_err_i), 
    .wb_rty_o(s0_rty_i), 
    .wb_cab_i(s0_cab_o), 
    .ddr3_dq(ddr3_dq), 
    .ddr3_dqs(ddr3_dqs), 
    .ddr3_dqs_n(ddr3_dqs_n), 
    .ddr3_ck(ddr3_ck), 
    .ddr3_ck_n(ddr3_ck_n), 
    .ddr3_reset(ddr3_reset),
    .ddr3_a(ddr3_a), 
    .ddr3_ba(ddr3_ba), 
    .ddr3_ras_n(ddr3_ras_n), 
    .ddr3_cas_n(ddr3_cas_n), 
    .ddr3_we_n(ddr3_we_n), 
    .ddr3_cs_n(ddr3_cs_n), 
    .ddr3_odt(ddr3_odt), 
    .ddr3_ce(ddr3_ce), 
    .ddr3_dm(ddr3_dm), 
    .phy_init_done(phy_init_done), 
    .dcm_locked(dcm_locked), 
    .fifo_used(fifo_used),
    .sysrst(sysrst)
);

WBFLASH flash (
    .wb_clk_i(wb_clk_i), 
    .wb_rst_i(wb_rst_i), 
    
    .wb_dat_i(s1_dat_o), 
    .wb_dat_o(s1_dat_i), 
    .wb_adr_i(s1_adr_o), 
    .wb_sel_i(s1_sel_o), 
    .wb_we_i(s1_we_o), 
    .wb_cyc_i(s1_cyc_o), 
    .wb_stb_i(s1_stb_o), 
    .wb_ack_o(s1_ack_i), 
    .wb_err_o(s1_err_i), 
    .wb_rty_o(s1_rty_i), 
    .wb_cab_i(s1_cab_o), 

    .wb1_dat_i(s4_dat_o), 
    .wb1_dat_o(s4_dat_i), 
    .wb1_adr_i(s4_adr_o), 
    .wb1_sel_i(s4_sel_o), 
    .wb1_we_i(s4_we_o), 
    .wb1_cyc_i(s4_cyc_o), 
    .wb1_stb_i(s4_stb_o), 
    .wb1_ack_o(s4_ack_i), 
    .wb1_err_o(s4_err_i), 
    .wb1_rty_o(s4_rty_i), 
    .wb1_cab_i(s4_cab_o), 

    .flash_addr(flash_addr), 
    .flash_data(flash_data), 
    .flash_oen(flash_oen), 
    .flash_wen(flash_wen), 
    .flash_cen(flash_cen),
    .flash_rev(flash_rev)
);

uart_top uart16550 (
    .wb_clk_i(wb_clk_i), 
    .wb_rst_i(wb_rst_i), 
    .wb_adr_i({s3_adr_o[4:3],s3_sel_o[3:0]==4'h0 ? 1'b0:1'b1,2'b00}), 
    .wb_dat_i(s3_sel_o[3:0]==4'h0 ? {s3_dat_o[39:32],s3_dat_o[47:40],s3_dat_o[55:48],s3_dat_o[63:56]}:{s3_dat_o[7:0],s3_dat_o[15:8],s3_dat_o[23:16],s3_dat_o[31:24]}), 
    .wb_dat_o({s3_dat_i[7:0],s3_dat_i[15:8],s3_dat_i[23:16],s3_dat_i[31:24]}), 
    .wb_we_i(s3_we_o), 
    .wb_stb_i(s3_stb_o), 
    .wb_cyc_i(s3_cyc_o), 
    .wb_ack_o(s3_ack_i), 
    .wb_sel_i(s3_sel_o[3:0]==4'h0 ? {s3_sel_o[4],s3_sel_o[5],s3_sel_o[6],s3_sel_o[7]}:{s3_sel_o[0],s3_sel_o[1],s3_sel_o[2],s3_sel_o[3]}), // Big endian 
    .int_o(int_o), 
    .stx_pad_o(stx), 
    .srx_pad_i(srx), 
    .rts_pad_o(), 
    .cts_pad_i(1), 
    .dtr_pad_o(), 
    .dsr_pad_i(1), 
    .ri_pad_i(0), 
    .dcd_pad_i(1),
	 .baud_o(baud_o)
);

eth_sgmii eth_ctrl (
    .wb_clk_i(wb_clk_i), 
    .wb_rst_i(wb_rst_i), 
    .sysclk(sysclk),
    
    .wb_dat_i(s2_dat_o), 
    .wb_dat_o(s2_dat_i), 
    .wb_adr_i(s2_adr_o), 
    .wb_sel_i(s2_sel_o), 
    .wb_we_i(s2_we_o), 
    .wb_cyc_i(s2_cyc_o), 
    .wb_stb_i(s2_stb_o), 
    .wb_ack_o(s2_ack_i), 
    .wb_err_o(s2_err_i), 

    .m_wb_adr_o(m1_adr_i), 
    .m_wb_sel_o(m1_sel_i), 
    .m_wb_we_o(m1_we_i), 
    .m_wb_dat_o(m1_dat_i), 
    .m_wb_dat_i(m1_dat_o), 
    .m_wb_cyc_o(m1_cyc_i), 
    .m_wb_stb_o(m1_stb_i), 
    .m_wb_ack_i(m1_ack_o), 
    .m_wb_err_i(m1_err_o), 
    
    .sgmii_tx(eth_tx),
    .sgmii_rx(eth_rx),
    .led_10(led_10),
    .led_100(led_100),
    .led_1000(led_1000),
    .led_an(led_an),
    .led_disp_err(led_disp_err),
    .led_char_err(led_char_err),
    .led_link(led_link),
    
    .md(md),
    .mdc(mdc),
    
    .int_eth(eth_int)
);

assign eth_rst=!wb_rst_i; // PHY reset
	 
wire sysrst_p;
assign sysrst_p=!sysrst;

// Standard PLL
pll pll_inst(
	.areset(sysrst_p),
	.inclk0(sysclk),
	.c0(wb_clk_i), //Up to 75 MHz on Stratix IV
	.locked(dcm_locked)
);
	
assign wb_rst_i=(!dcm_locked || !phy_init_done);
	 
reg [223:0] ILA_DATA;

/*
[63:0]    address
[127:64]  data to core
[191:128] data from core
[199:192] sel
[200]     cyc
[201]     stb
[202]     we
[203]     ack
*/

// SignalTap II
ST ila(
	.acq_clk(wb_clk_i),
	.acq_data_in(ILA_DATA),
	.acq_trigger_in(ILA_DATA),
	.storage_enable(ILA_DATA[203]) // wb_ack
);

// InSystem Sources
VIO vio_inst(
	.probe(0),
	.source_clk(wb_clk_i),
	.source(VIO_SIG)
);

always @(posedge wb_clk_i or posedge wb_rst_i)
   if(wb_rst_i)
	   cycle_count<=0;
	else
	   cycle_count<=cycle_count+1;

always @( * )
   begin
      case(VIO_SIG)
         2'b00:
            begin
               ILA_DATA[63:0]<=m0_adr_i;
               ILA_DATA[127:64]<=m0_dat_o;
               ILA_DATA[191:128]<=m0_dat_i;
               ILA_DATA[199:192]<=m0_sel_i;
               ILA_DATA[200]<=m0_cyc_i;
               ILA_DATA[201]<=m0_stb_i;
               ILA_DATA[202]<=m0_we_i;
               ILA_DATA[203]<=m0_ack_o;
            end
         2'b01:
            begin
               ILA_DATA[63:0]<=m1_adr_i;
               ILA_DATA[127:64]<=m1_dat_o;
               ILA_DATA[191:128]<=m1_dat_i;
               ILA_DATA[199:192]<=m1_sel_i;
               ILA_DATA[200]<=m1_cyc_i;
               ILA_DATA[201]<=m1_stb_i;
               ILA_DATA[202]<=m1_we_i;
               ILA_DATA[203]<=m1_ack_o;
            end
         2'b10:
            begin
               ILA_DATA[63:0]<=s2_adr_o;
               ILA_DATA[127:64]<=s2_dat_o;
               ILA_DATA[191:128]<=s2_dat_i;
               ILA_DATA[199:192]<=s2_sel_o;
               ILA_DATA[200]<=s2_cyc_o;
               ILA_DATA[201]<=s2_stb_o;
               ILA_DATA[202]<=s2_we_o;
               ILA_DATA[203]<=s2_ack_i;
            end
         2'b11:
            begin
               ILA_DATA[63:0]<=s4_adr_o;
               ILA_DATA[127:64]<=s4_dat_o;
               ILA_DATA[191:128]<=s4_dat_i;
               ILA_DATA[199:192]<=s4_sel_o;
               ILA_DATA[200]<=s4_cyc_o;
               ILA_DATA[201]<=s4_stb_o;
               ILA_DATA[202]<=s4_we_o;
               ILA_DATA[203]<=s4_ack_i;
            end
      endcase
      ILA_DATA[204]<=stx;
      ILA_DATA[205]<=srx;
      ILA_DATA[206]<=baud_o;
      //ILA_DATA[220:207]<=cycle_count[31:18];
      ILA_DATA[220:213]<=fifo_used;
      ILA_DATA[212:207]<=cycle_count[31:26];
      ILA_DATA[221]<=dcm_locked;
      ILA_DATA[222]<=wb_rst_i;
      ILA_DATA[223]<=phy_init_done;
   end

endmodule
