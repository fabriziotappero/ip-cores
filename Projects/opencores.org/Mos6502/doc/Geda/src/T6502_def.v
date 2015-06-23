////////////////////////////////////////////////////////////////////
//     --------------                                             //
//    /      SOC     \                                            //
//   /       GEN      \                                           //
//  /     COMPONENT    \                                          //
//  ====================                                          //
//  |digital done right|                                          //
//  |__________________|                                          //
//                                                                //
//                                                                //
//                                                                //
//    Copyright (C) <2010>  <Ouabache DesignWorks>                //
//                                                                //
//                                                                //  
//   This source file may be used and distributed without         //  
//   restriction provided that this copyright statement is not    //  
//   removed from the file and that any derivative work contains  //  
//   the original copyright notice and the associated disclaimer. //  
//                                                                //  
//   This source file is free software; you can redistribute it   //  
//   and/or modify it under the terms of the GNU Lesser General   //  
//   Public License as published by the Free Software Foundation; //  
//   either version 2.1 of the License, or (at your option) any   //  
//   later version.                                               //  
//                                                                //  
//   This source is distributed in the hope that it will be       //  
//   useful, but WITHOUT ANY WARRANTY; without even the implied   //  
//   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //  
//   PURPOSE.  See the GNU Lesser General Public License for more //  
//   details.                                                     //  
//                                                                //  
//   You should have received a copy of the GNU Lesser General    //  
//   Public License along with this source; if not, download it   //  
//   from http://www.opencores.org/lgpl.shtml                     //  
//                                                                //  
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////									////
//// T6507LP IP Core	 						////
////									////
//// This file is part of the T6507LP project				////
//// http://www.opencores.org/cores/t6507lp/				////
////									////
//// Description							////
//// Implementation of a 6507-compatible microprocessor			////
////									////
//// To Do:								////
//// - Everything							////
////									////
//// Author(s):								////
//// - Gabriel Oshiro Zardo, gabrieloshiro@gmail.com			////
//// - Samuel Nascimento Pagliarini (creep), snpagliarini@gmail.com	////
////									////
////////////////////////////////////////////////////////////////////////////
////									////
//// Copyright (C) 2001 Authors and OPENCORES.ORG			////
////									////
//// This source file may be used and distributed without		////
//// restriction provided that this copyright statement is not		////
//// removed from the file and that any derivative work contains	////
//// the original copyright notice and the associated disclaimer.	////
////									////
//// This source file is free software; you can redistribute it		////
//// and/or modify it under the terms of the GNU Lesser General		////
//// Public License as published by the Free Software Foundation;	////
//// either version 2.1 of the License, or (at your option) any		////
//// later version.							////
////									////
//// This source is distributed in the hope that it will be		////
//// useful, but WITHOUT ANY WARRANTY; without even the implied		////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR		////
//// PURPOSE. See the GNU Lesser General Public License for more	////
//// details.								////
////									////
//// You should have received a copy of the GNU Lesser General		////
//// Public License along with this source; if not, download it		////
//// from http://www.opencores.org/lgpl.shtml				////
////									////
////////////////////////////////////////////////////////////////////////////
 module 
  T6502_def 
    #( parameter 
      BOOT_ROM_WIDTH=16,
      CPU_ADD=16,
      PROG_ROM_ADD=12,
      PROG_ROM_WORDS=4096,
      RAM_ADD=11,
      RAM_WORDS=2048,
      ROM_ADD=12,
      ROM_WORDS=4096,
      ROM_WRITETHRU=0,
      SPLIT_CH0_BITS=8,
      SPLIT_CH0_MATCH=8'h00,
      SPLIT_CH1_BITS=4,
      SPLIT_CH1_MATCH=4'h0,
      SPLIT_CH2_BITS=8,
      SPLIT_CH2_MATCH=8'h80,
      SPLIT_CH3_BITS=2,
      SPLIT_CH3_MATCH=2'b01,
      SPLIT_CH4_BITS=4,
      SPLIT_CH4_MATCH=4'hc,
      SPLIT_CH5_BITS=4,
      SPLIT_CH5_MATCH=4'hf,
      UART_DIV=0,
      UART_PRESCALE=5'b01100,
      UART_PRE_SIZE=5,
      VEC_TABLE=8'hff)
     (
 input   wire                 clk,
 input   wire                 cts_pad_in,
 input   wire                 ext_wait,
 input   wire                 jtag_capture_dr,
 input   wire                 jtag_select,
 input   wire                 jtag_shift_dr,
 input   wire                 jtag_shiftcapture_dr_clk,
 input   wire                 jtag_tdi,
 input   wire                 jtag_test_logic_reset,
 input   wire                 jtag_update_dr_clk,
 input   wire                 ps2_clk_pad_in,
 input   wire                 ps2_data_pad_in,
 input   wire                 reset,
 input   wire                 uart_rxd_pad_in,
 input   wire                 wb_jsp_stb_i,
 input   wire    [ 15 :  0]        ext_rdata,
 input   wire    [ 3 :  0]        ext_irq_in,
 input   wire    [ 7 :  0]        gpio_0_in,
 input   wire    [ 7 :  0]        gpio_1_in,
 input   wire    [ 7 :  0]        wb_jsp_dat_i,
 output   wire                 biu_wr_strobe,
 output   wire                 ext_lb,
 output   wire                 ext_rd,
 output   wire                 ext_stb,
 output   wire                 ext_ub,
 output   wire                 ext_wr,
 output   wire                 jtag_tdo,
 output   wire                 ps2_clk_pad_oe,
 output   wire                 ps2_data_pad_oe,
 output   wire                 rts_pad_out,
 output   wire                 uart_txd_pad_out,
 output   wire                 vga_hsync_n_pad_out,
 output   wire                 vga_vsync_n_pad_out,
 output   wire    [ 1 :  0]        ext_cs,
 output   wire    [ 1 :  0]        vga_blue_pad_out,
 output   wire    [ 15 :  0]        ext_wdata,
 output   wire    [ 2 :  0]        vga_green_pad_out,
 output   wire    [ 2 :  0]        vga_red_pad_out,
 output   wire    [ 23 :  1]        ext_addr,
 output   wire    [ 7 :  0]        alu_status,
 output   wire    [ 7 :  0]        gpio_0_oe,
 output   wire    [ 7 :  0]        gpio_0_out,
 output   wire    [ 7 :  0]        gpio_1_oe,
 output   wire    [ 7 :  0]        gpio_1_out,
 output   wire    [ 7 :  0]        jsp_data_out);
wire                        cpu_rd;
wire                        cpu_wr;
wire                        data_cs;
wire                        data_rd;
wire                        data_wr;
wire                        enable;
wire                        ext_mem_cs;
wire                        ext_mem_rd;
wire                        ext_mem_wait;
wire                        ext_mem_wr;
wire                        io_reg_cs;
wire                        io_reg_rd;
wire                        io_reg_wait;
wire                        io_reg_wr;
wire                        mem_cs;
wire                        mem_rd;
wire                        mem_wr;
wire                        nmi_in;
wire                        pg00_ram_l_wr;
wire                        pg0_rd;
wire                        pg0_wr;
wire                        prog_rom_mem_cs;
wire                        prog_rom_mem_rd;
wire                        prog_rom_mem_wr;
wire                        ps2_data_avail;
wire                        rx_irq;
wire                        sh_prog_rom_mem_cs;
wire                        sh_prog_rom_mem_rd;
wire                        sh_prog_rom_mem_wr;
wire                        syn_jtag_capture_dr;
wire                        syn_jtag_clk;
wire                        syn_jtag_select;
wire                        syn_jtag_shift_dr;
wire                        syn_jtag_tdi;
wire                        syn_jtag_tdo;
wire                        syn_jtag_test_logic_reset;
wire                        syn_jtag_update_dr;
wire                        tx_irq;
wire     [ 1 :  0]              data_be;
wire     [ 1 :  0]              mem_wait;
wire     [ 1 :  0]              timer_irq;
wire     [ 11 :  0]              prog_rom_mem_addr;
wire     [ 11 :  0]              sh_prog_rom_mem_addr;
wire     [ 11 :  1]              data_addr;
wire     [ 13 :  0]              ext_mem_addr;
wire     [ 15 :  0]              cpu_addr;
wire     [ 15 :  0]              cpu_rdata;
wire     [ 15 :  0]              data_rdata;
wire     [ 15 :  0]              data_wdata;
wire     [ 15 :  0]              ext_mem_rdata;
wire     [ 15 :  0]              ext_mem_wdata;
wire     [ 15 :  0]              io_reg_rdata;
wire     [ 15 :  0]              mem_rdata;
wire     [ 15 :  0]              mem_wdata;
wire     [ 15 :  0]              prog_rom_mem_rdata;
wire     [ 15 :  0]              prog_rom_mem_wdata;
wire     [ 15 :  0]              sh_prog_rom_mem_rdata;
wire     [ 15 :  0]              sh_prog_rom_mem_wdata;
wire     [ 7 :  0]              cpu_pg0_data;
wire     [ 7 :  0]              cpu_wdata;
wire     [ 7 :  0]              io_module_pic_irq_in;
wire     [ 7 :  0]              io_module_vic_irq_in;
wire     [ 7 :  0]              io_reg_addr;
wire     [ 7 :  0]              io_reg_wdata;
wire     [ 7 :  0]              pg0_add;
wire     [ 7 :  0]              vector;
wire     [ CPU_ADD-1 :  0]              mem_addr;
adv_dbg_if_jfifo
adv_dbg 
   (
   .capture_dr_i      ( syn_jtag_capture_dr  ),
   .debug_select_i      ( syn_jtag_select  ),
   .rst_i      ( syn_jtag_test_logic_reset  ),
   .shift_dr_i      ( syn_jtag_shift_dr  ),
   .tck_i      ( syn_jtag_clk  ),
   .tdi_i      ( syn_jtag_tdi  ),
   .tdo_o      ( syn_jtag_tdo  ),
   .update_dr_i      ( syn_jtag_update_dr  ),
    .biu_wr_strobe      ( biu_wr_strobe  ),
    .jsp_data_out      ( jsp_data_out[7:0] ),
    .wb_clk_i      ( clk  ),
    .wb_jsp_dat_i      ( wb_jsp_dat_i[7:0] ),
    .wb_jsp_stb_i      ( wb_jsp_stb_i  ));
cde_sram_def
#( .ADDR (ROM_ADD),
   .WIDTH (BOOT_ROM_WIDTH),
   .WORDS (ROM_WORDS),
   .WRITETHRU (ROM_WRITETHRU))
boot_rom 
   (
   .cs      ( prog_rom_mem_cs  ),
   .rd      ( prog_rom_mem_rd  ),
   .wr      ( prog_rom_mem_wr  ),
    .addr      ( mem_addr[ROM_ADD:1] ),
    .clk      ( clk  ),
    .rdata      ( prog_rom_mem_rdata  ),
    .wdata      ( 'b0  ));
cpu_def
#( .PROG_ROM_ADD (PROG_ROM_ADD),
   .PROG_ROM_WORDS (PROG_ROM_WORDS),
   .VEC_TABLE (VEC_TABLE))
cpu 
   (
   .addr      ( cpu_addr[15:0]  ),
   .rd      ( cpu_rd  ),
   .rdata      ( cpu_rdata[15:0]  ),
   .wdata      ( cpu_wdata[7:0]  ),
   .wr      ( cpu_wr  ),
    .alu_status      ( alu_status[7:0] ),
    .clk      ( clk  ),
    .enable      ( enable  ),
    .nmi      ( nmi_in  ),
    .pg0_add      ( pg0_add  ),
    .pg0_data      ( cpu_pg0_data[7:0] ),
    .pg0_rd      ( pg0_rd  ),
    .pg0_wr      ( pg0_wr  ),
    .reset      ( reset  ),
    .vec_int      ( vector[7:0] ));
T6502_ctrl
#( .VEC_TABLE (VEC_TABLE))
ctrl 
   (
    .clk      ( clk  ),
    .cpu_pg0_data      ( cpu_pg0_data  ),
    .ext_irq_in      ( ext_irq_in[2:0] ),
    .io_module_pic_irq_in      ( io_module_pic_irq_in  ),
    .io_module_vic_irq_in      ( io_module_vic_irq_in  ),
    .mem_addr      ( mem_addr[0:0] ),
    .mem_cs      ( mem_cs  ),
    .mem_rd      ( mem_rd  ),
    .mem_rdata      ( mem_rdata[15:0] ),
    .mem_wdata      ( mem_wdata[15:0] ),
    .mem_wr      ( mem_wr  ),
    .pg00_ram_l_wr      ( pg00_ram_l_wr  ),
    .pg0_add      ( pg0_add[7:0] ),
    .pg0_rd      ( pg0_rd  ),
    .pg0_wr      ( pg0_wr  ),
    .ps2_data_avail      ( ps2_data_avail  ),
    .rx_irq      ( rx_irq  ),
    .timer_irq      ( timer_irq[1:0] ),
    .tx_irq      ( tx_irq  ));
cde_sram_word
#( .ADDR (RAM_ADD),
   .WORDS (RAM_WORDS))
data_sram 
   (
   .addr      ( data_addr[11:1]  ),
   .be      ( data_be[1:0]  ),
   .cs      ( data_cs  ),
   .rd      ( data_rd  ),
   .rdata      ( data_rdata[15:0]  ),
   .wdata      ( data_wdata[15:0]  ),
   .wr      ( data_wr  ),
    .clk      ( clk  ));
io_module_def
#( .ADDR_WIDTH (8),
   .BASE_WIDTH (0),
   .UART_DIV (UART_DIV),
   .UART_PRESCALE (UART_PRESCALE),
   .UART_PRE_SIZE (UART_PRE_SIZE))
io_module 
   (
   .mem_addr      ( ext_mem_addr[13:0]  ),
   .mem_cs      ( ext_mem_cs  ),
   .mem_rd      ( ext_mem_rd  ),
   .mem_rdata      ( ext_mem_rdata[15:0]  ),
   .mem_wait      ( ext_mem_wait  ),
   .mem_wdata      ( ext_mem_wdata[15:0]  ),
   .mem_wr      ( ext_mem_wr  ),
   .ps2_clk_pad_in      ( ps2_clk_pad_in  ),
   .ps2_clk_pad_oe      ( ps2_clk_pad_oe  ),
   .ps2_data_pad_in      ( ps2_data_pad_in  ),
   .ps2_data_pad_oe      ( ps2_data_pad_oe  ),
   .reg_mb_addr      ( io_reg_addr[7:0]  ),
   .reg_mb_cs      ( io_reg_cs  ),
   .reg_mb_rd      ( io_reg_rd  ),
   .reg_mb_rdata      ( io_reg_rdata[15:0]  ),
   .reg_mb_wait      ( io_reg_wait  ),
   .reg_mb_wdata      ( io_reg_wdata[7:0]  ),
   .reg_mb_wr      ( io_reg_wr  ),
   .uart_rxd_pad_in      ( uart_rxd_pad_in  ),
   .uart_txd_pad_out      ( uart_txd_pad_out  ),
   .vga_blue_pad_out      ( vga_blue_pad_out[1:0]  ),
   .vga_green_pad_out      ( vga_green_pad_out[2:0]  ),
   .vga_hsync_n_pad_out      ( vga_hsync_n_pad_out  ),
   .vga_red_pad_out      ( vga_red_pad_out[2:0]  ),
   .vga_vsync_n_pad_out      ( vga_vsync_n_pad_out  ),
    .clk      ( clk  ),
    .cts_pad_in      ( cts_pad_in  ),
    .enable      ( enable  ),
    .ext_addr      ( ext_addr  ),
    .ext_cs      ( ext_cs  ),
    .ext_lb      ( ext_lb  ),
    .ext_rd      ( ext_rd  ),
    .ext_rdata      ( ext_rdata[15:0] ),
    .ext_stb      ( ext_stb  ),
    .ext_ub      ( ext_ub  ),
    .ext_wait      ( ext_wait  ),
    .ext_wdata      ( ext_wdata  ),
    .ext_wr      ( ext_wr  ),
    .gpio_0_in      ( gpio_0_in  ),
    .gpio_0_oe      ( gpio_0_oe  ),
    .gpio_0_out      ( gpio_0_out  ),
    .gpio_1_in      ( gpio_1_in  ),
    .gpio_1_oe      ( gpio_1_oe  ),
    .gpio_1_out      ( gpio_1_out  ),
    .int_out      ( nmi_in  ),
    .ms_left      (      ),
    .ms_mid      (      ),
    .ms_right      (      ),
    .new_packet      (      ),
    .pic_irq      (      ),
    .pic_irq_in      ( io_module_pic_irq_in[7:0] ),
    .pic_nmi      (      ),
    .ps2_data_avail      ( ps2_data_avail  ),
    .reset      ( reset  ),
    .rts_pad_out      ( rts_pad_out  ),
    .rx_irq      ( rx_irq  ),
    .timer_irq      ( timer_irq  ),
    .tx_irq      ( tx_irq  ),
    .vector      ( vector[7:0] ),
    .vic_irq_in      ( io_module_vic_irq_in[7:0] ),
    .x_pos      (      ),
    .y_pos      (      ));
cde_jtag_classic_sync
jtag_sync 
   (
   .capture_dr      ( jtag_capture_dr  ),
   .select      ( jtag_select  ),
   .shift_dr      ( jtag_shift_dr  ),
   .shiftcapture_dr_clk      ( jtag_shiftcapture_dr_clk  ),
   .syn_capture_dr      ( syn_jtag_capture_dr  ),
   .syn_clk      ( syn_jtag_clk  ),
   .syn_reset      ( syn_jtag_test_logic_reset  ),
   .syn_select      ( syn_jtag_select  ),
   .syn_shift_dr      ( syn_jtag_shift_dr  ),
   .syn_tdi_o      ( syn_jtag_tdi  ),
   .syn_tdo_i      ( syn_jtag_tdo  ),
   .syn_update_dr      ( syn_jtag_update_dr  ),
   .tdi      ( jtag_tdi  ),
   .tdo      ( jtag_tdo  ),
   .test_logic_reset      ( jtag_test_logic_reset  ),
   .update_dr_clk      ( jtag_update_dr_clk  ),
    .clk      ( clk  ));
micro_bus_def
#( .ADD (CPU_ADD),
   .CH0_BITS (SPLIT_CH0_BITS),
   .CH0_MATCH (SPLIT_CH0_MATCH),
   .CH1_BITS (SPLIT_CH1_BITS),
   .CH1_MATCH (SPLIT_CH1_MATCH),
   .CH2_BITS (SPLIT_CH2_BITS),
   .CH2_MATCH (SPLIT_CH2_MATCH),
   .CH3_BITS (SPLIT_CH3_BITS),
   .CH3_MATCH (SPLIT_CH3_MATCH),
   .CH4_BITS (SPLIT_CH4_BITS),
   .CH4_MATCH (SPLIT_CH4_MATCH),
   .CH5_BITS (SPLIT_CH5_BITS),
   .CH5_MATCH (SPLIT_CH5_MATCH))
micro_bus 
   (
   .addr_in      ( cpu_addr[15:0]  ),
   .data_addr      ( data_addr[11:1]  ),
   .data_be      ( data_be[1:0]  ),
   .data_cs      ( data_cs  ),
   .data_rd      ( data_rd  ),
   .data_rdata      ( data_rdata[15:0]  ),
   .data_wdata      ( data_wdata[15:0]  ),
   .data_wr      ( data_wr  ),
   .ext_mem_addr      ( ext_mem_addr[13:0]  ),
   .ext_mem_cs      ( ext_mem_cs  ),
   .ext_mem_rd      ( ext_mem_rd  ),
   .ext_mem_rdata      ( ext_mem_rdata[15:0]  ),
   .ext_mem_wait      ( ext_mem_wait  ),
   .ext_mem_wdata      ( ext_mem_wdata[15:0]  ),
   .ext_mem_wr      ( ext_mem_wr  ),
   .io_reg_addr      ( io_reg_addr[7:0]  ),
   .io_reg_cs      ( io_reg_cs  ),
   .io_reg_rd      ( io_reg_rd  ),
   .io_reg_rdata      ( io_reg_rdata[15:0]  ),
   .io_reg_wait      ( io_reg_wait  ),
   .io_reg_wdata      ( io_reg_wdata[7:0]  ),
   .io_reg_wr      ( io_reg_wr  ),
   .mem_addr      ( mem_addr[15:0]  ),
   .mem_cs      ( mem_cs  ),
   .mem_rd      ( mem_rd  ),
   .mem_rdata      ( mem_rdata[15:0]  ),
   .mem_wait      ( mem_wait[1:0]  ),
   .mem_wdata      ( mem_wdata[15:0]  ),
   .mem_wr      ( mem_wr  ),
   .prog_rom_mem_addr      ( prog_rom_mem_addr[11:0]  ),
   .prog_rom_mem_cs      ( prog_rom_mem_cs  ),
   .prog_rom_mem_rd      ( prog_rom_mem_rd  ),
   .prog_rom_mem_rdata      ( prog_rom_mem_rdata[15:0]  ),
   .prog_rom_mem_wdata      ( prog_rom_mem_wdata[15:0]  ),
   .prog_rom_mem_wr      ( prog_rom_mem_wr  ),
   .rd_in      ( cpu_rd  ),
   .rdata_out      ( cpu_rdata[15:0]  ),
   .sh_prog_rom_mem_addr      ( sh_prog_rom_mem_addr[11:0]  ),
   .sh_prog_rom_mem_cs      ( sh_prog_rom_mem_cs  ),
   .sh_prog_rom_mem_rd      ( sh_prog_rom_mem_rd  ),
   .sh_prog_rom_mem_rdata      ( sh_prog_rom_mem_rdata[15:0]  ),
   .sh_prog_rom_mem_wdata      ( sh_prog_rom_mem_wdata[15:0]  ),
   .sh_prog_rom_mem_wr      ( sh_prog_rom_mem_wr  ),
   .wdata_in      ( cpu_wdata[7:0]  ),
   .wr_in      ( cpu_wr  ),
    .clk      ( clk  ),
    .enable      ( enable  ),
    .reset      ( reset  ));
cde_sram_def
#( .ADDR (PROG_ROM_ADD),
   .WIDTH (BOOT_ROM_WIDTH),
   .WORDS (PROG_ROM_WORDS),
   .WRITETHRU (ROM_WRITETHRU))
sh_prog_rom 
   (
   .cs      ( sh_prog_rom_mem_cs  ),
   .rd      ( sh_prog_rom_mem_rd  ),
   .wr      ( sh_prog_rom_mem_wr  ),
    .addr      ( mem_addr[PROG_ROM_ADD:1] ),
    .clk      ( clk  ),
    .rdata      ( sh_prog_rom_mem_rdata  ),
    .wdata      ( mem_wdata  ));
  endmodule
