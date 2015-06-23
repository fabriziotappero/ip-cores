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
//    Copyright (C) <2009>  <Ouabache DesignWorks>                //
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
 module 
  io_module_def 
    #( parameter 
      ADDR_WIDTH=16,
      BASE_WIDTH=8,
      IRQ_MODE=8'h00,
      NMI_MODE=8'h00,
      UART_DIV=0,
      UART_PRESCALE=5'b01100,
      UART_PRE_SIZE=5)
     (
 input   wire                 clk,
 input   wire                 cts_pad_in,
 input   wire                 enable,
 input   wire                 ext_wait,
 input   wire                 mem_cs,
 input   wire                 mem_rd,
 input   wire                 mem_wr,
 input   wire                 ps2_clk_pad_in,
 input   wire                 ps2_data_pad_in,
 input   wire                 reg_mb_cs,
 input   wire                 reg_mb_rd,
 input   wire                 reg_mb_wr,
 input   wire                 reset,
 input   wire                 uart_rxd_pad_in,
 input   wire    [ 13 :  0]        mem_addr,
 input   wire    [ 15 :  0]        ext_rdata,
 input   wire    [ 15 :  0]        mem_wdata,
 input   wire    [ 7 :  0]        gpio_0_in,
 input   wire    [ 7 :  0]        gpio_1_in,
 input   wire    [ 7 :  0]        pic_irq_in,
 input   wire    [ 7 :  0]        reg_mb_addr,
 input   wire    [ 7 :  0]        reg_mb_wdata,
 input   wire    [ 7 :  0]        vic_irq_in,
 output   wire                 ext_lb,
 output   wire                 ext_rd,
 output   wire                 ext_stb,
 output   wire                 ext_ub,
 output   wire                 ext_wr,
 output   wire                 int_out,
 output   wire                 mem_wait,
 output   wire                 ms_left,
 output   wire                 ms_mid,
 output   wire                 ms_right,
 output   wire                 new_packet,
 output   wire                 pic_irq,
 output   wire                 pic_nmi,
 output   wire                 ps2_clk_pad_oe,
 output   wire                 ps2_data_avail,
 output   wire                 ps2_data_pad_oe,
 output   wire                 reg_mb_wait,
 output   wire                 rts_pad_out,
 output   wire                 rx_irq,
 output   wire                 tx_irq,
 output   wire                 uart_txd_pad_out,
 output   wire                 vga_hsync_n_pad_out,
 output   wire                 vga_vsync_n_pad_out,
 output   wire    [ 1 :  0]        ext_cs,
 output   wire    [ 1 :  0]        timer_irq,
 output   wire    [ 1 :  0]        vga_blue_pad_out,
 output   wire    [ 15 :  0]        ext_wdata,
 output   wire    [ 15 :  0]        mem_rdata,
 output   wire    [ 15 :  0]        reg_mb_rdata,
 output   wire    [ 2 :  0]        vga_green_pad_out,
 output   wire    [ 2 :  0]        vga_red_pad_out,
 output   wire    [ 23 :  1]        ext_addr,
 output   wire    [ 7 :  0]        gpio_0_oe,
 output   wire    [ 7 :  0]        gpio_0_out,
 output   wire    [ 7 :  0]        gpio_1_oe,
 output   wire    [ 7 :  0]        gpio_1_out,
 output   wire    [ 7 :  0]        vector,
 output   wire    [ 9 :  0]        x_pos,
 output   wire    [ 9 :  0]        y_pos);
wire                        mas_0_cs;
wire                        mas_0_rd;
wire                        mas_0_wr;
wire                        mas_1_cs;
wire                        mas_1_rd;
wire                        mas_1_wr;
wire                        mas_2_cs;
wire                        mas_2_rd;
wire                        mas_2_wr;
wire                        mas_3_cs;
wire                        mas_3_rd;
wire                        mas_3_wr;
wire                        mas_4_cs;
wire                        mas_4_rd;
wire                        mas_4_wr;
wire                        mas_5_cs;
wire                        mas_5_rd;
wire                        mas_5_wr;
wire                        mas_6_cs;
wire                        mas_6_rd;
wire                        mas_6_wr;
wire                        mas_7_cs;
wire                        mas_7_rd;
wire                        mas_7_wr;
wire                        mas_8_cs;
wire                        mas_8_rd;
wire                        mas_8_wr;
wire     [ 3 :  0]              mas_0_addr;
wire     [ 3 :  0]              mas_1_addr;
wire     [ 3 :  0]              mas_2_addr;
wire     [ 3 :  0]              mas_3_addr;
wire     [ 3 :  0]              mas_4_addr;
wire     [ 3 :  0]              mas_5_addr;
wire     [ 3 :  0]              mas_6_addr;
wire     [ 3 :  0]              mas_7_addr;
wire     [ 3 :  0]              mas_8_addr;
wire     [ 7 :  0]              mas_0_rdata;
wire     [ 7 :  0]              mas_0_wdata;
wire     [ 7 :  0]              mas_1_rdata;
wire     [ 7 :  0]              mas_1_wdata;
wire     [ 7 :  0]              mas_2_rdata;
wire     [ 7 :  0]              mas_2_wdata;
wire     [ 7 :  0]              mas_3_rdata;
wire     [ 7 :  0]              mas_3_wdata;
wire     [ 7 :  0]              mas_4_rdata;
wire     [ 7 :  0]              mas_4_wdata;
wire     [ 7 :  0]              mas_5_rdata;
wire     [ 7 :  0]              mas_5_wdata;
wire     [ 7 :  0]              mas_6_rdata;
wire     [ 7 :  0]              mas_6_wdata;
wire     [ 7 :  0]              mas_7_rdata;
wire     [ 7 :  0]              mas_7_wdata;
wire     [ 7 :  0]              mas_8_rdata;
wire     [ 7 :  0]              mas_8_wdata;
io_gpio_def
gpio 
   (
   .addr      ( mas_0_addr[3:0]  ),
   .cs      ( mas_0_cs  ),
   .rd      ( mas_0_rd  ),
   .rdata      ( mas_0_rdata[7:0]  ),
   .wdata      ( mas_0_wdata[7:0]  ),
   .wr      ( mas_0_wr  ),
    .clk      ( clk  ),
    .enable      ( enable  ),
    .gpio_0_in      ( gpio_0_in  ),
    .gpio_0_oe      ( gpio_0_oe  ),
    .gpio_0_out      ( gpio_0_out  ),
    .gpio_1_in      ( gpio_1_in  ),
    .gpio_1_oe      ( gpio_1_oe  ),
    .gpio_1_out      ( gpio_1_out  ),
    .reset      ( reset  ));
micro_bus_exp9
mb_exp 
   (
   .addr_in      ( reg_mb_addr[7:0]  ),
   .cs_in      ( reg_mb_cs  ),
   .mas_0_addr_out      ( mas_0_addr[3:0]  ),
   .mas_0_cs_out      ( mas_0_cs  ),
   .mas_0_rd_out      ( mas_0_rd  ),
   .mas_0_rdata_in      ( mas_0_rdata[7:0]  ),
   .mas_0_wdata_out      ( mas_0_wdata[7:0]  ),
   .mas_0_wr_out      ( mas_0_wr  ),
   .mas_1_addr_out      ( mas_1_addr[3:0]  ),
   .mas_1_cs_out      ( mas_1_cs  ),
   .mas_1_rd_out      ( mas_1_rd  ),
   .mas_1_rdata_in      ( mas_1_rdata[7:0]  ),
   .mas_1_wdata_out      ( mas_1_wdata[7:0]  ),
   .mas_1_wr_out      ( mas_1_wr  ),
   .mas_2_addr_out      ( mas_2_addr[3:0]  ),
   .mas_2_cs_out      ( mas_2_cs  ),
   .mas_2_rd_out      ( mas_2_rd  ),
   .mas_2_rdata_in      ( mas_2_rdata[7:0]  ),
   .mas_2_wdata_out      ( mas_2_wdata[7:0]  ),
   .mas_2_wr_out      ( mas_2_wr  ),
   .mas_3_addr_out      ( mas_3_addr[3:0]  ),
   .mas_3_cs_out      ( mas_3_cs  ),
   .mas_3_rd_out      ( mas_3_rd  ),
   .mas_3_rdata_in      ( mas_3_rdata[7:0]  ),
   .mas_3_wdata_out      ( mas_3_wdata[7:0]  ),
   .mas_3_wr_out      ( mas_3_wr  ),
   .mas_4_addr_out      ( mas_4_addr[3:0]  ),
   .mas_4_cs_out      ( mas_4_cs  ),
   .mas_4_rd_out      ( mas_4_rd  ),
   .mas_4_rdata_in      ( mas_4_rdata[7:0]  ),
   .mas_4_wdata_out      ( mas_4_wdata[7:0]  ),
   .mas_4_wr_out      ( mas_4_wr  ),
   .mas_5_addr_out      ( mas_5_addr[3:0]  ),
   .mas_5_cs_out      ( mas_5_cs  ),
   .mas_5_rd_out      ( mas_5_rd  ),
   .mas_5_rdata_in      ( mas_5_rdata[7:0]  ),
   .mas_5_wdata_out      ( mas_5_wdata[7:0]  ),
   .mas_5_wr_out      ( mas_5_wr  ),
   .mas_6_addr_out      ( mas_6_addr[3:0]  ),
   .mas_6_cs_out      ( mas_6_cs  ),
   .mas_6_rd_out      ( mas_6_rd  ),
   .mas_6_rdata_in      ( mas_6_rdata[7:0]  ),
   .mas_6_wdata_out      ( mas_6_wdata[7:0]  ),
   .mas_6_wr_out      ( mas_6_wr  ),
   .mas_7_addr_out      ( mas_7_addr[3:0]  ),
   .mas_7_cs_out      ( mas_7_cs  ),
   .mas_7_rd_out      ( mas_7_rd  ),
   .mas_7_rdata_in      ( mas_7_rdata[7:0]  ),
   .mas_7_wdata_out      ( mas_7_wdata[7:0]  ),
   .mas_7_wr_out      ( mas_7_wr  ),
   .mas_8_addr_out      ( mas_8_addr[3:0]  ),
   .mas_8_cs_out      ( mas_8_cs  ),
   .mas_8_rd_out      ( mas_8_rd  ),
   .mas_8_rdata_in      ( mas_8_rdata[7:0]  ),
   .mas_8_wdata_out      ( mas_8_wdata[7:0]  ),
   .mas_8_wr_out      ( mas_8_wr  ),
   .rd_in      ( reg_mb_rd  ),
   .rdata_out      ( reg_mb_rdata[15:0]  ),
   .wait_out      ( reg_mb_wait  ),
   .wdata_in      ( reg_mb_wdata[7:0]  ),
   .wr_in      ( reg_mb_wr  ),
    .clk      ( clk  ),
    .enable      ( enable  ),
    .reset      ( reset  ));
io_ext_mem_interface_def
#( .ADDR_WIDTH (8),
   .BASE_ADDR (4'h7),
   .BASE_WIDTH (4))
mem 
   (
   .addr      ( mas_7_addr[3:0]  ),
   .cs      ( mas_7_cs  ),
   .ext_add      ( ext_addr[23:1]  ),
   .ext_cs      ( ext_cs[1:0]  ),
   .ext_rd      ( ext_rd  ),
   .ext_rdata      ( ext_rdata[15:0]  ),
   .ext_wait      ( ext_wait  ),
   .ext_wdata      ( ext_wdata[15:0]  ),
   .ext_wr      ( ext_wr  ),
   .mem_addr      ( mem_addr[13:0]  ),
   .mem_cs      ( mem_cs  ),
   .mem_rd      ( mem_rd  ),
   .mem_rdata      ( mem_rdata[15:0]  ),
   .mem_wait      ( mem_wait  ),
   .mem_wdata      ( mem_wdata[15:0]  ),
   .mem_wr      ( mem_wr  ),
   .rd      ( mas_7_rd  ),
   .rdata      ( mas_7_rdata[7:0]  ),
   .wdata      ( mas_7_wdata[7:0]  ),
   .wr      ( mas_7_wr  ),
    .bank      (      ),
    .clk      ( clk  ),
    .enable      ( enable  ),
    .ext_lb      ( ext_lb  ),
    .ext_stb      ( ext_stb  ),
    .ext_ub      ( ext_ub  ),
    .reset      ( reset  ),
    .wait_st      (      ));
io_pic_def
#( .IRQ_MODE (IRQ_MODE),
   .NMI_MODE (NMI_MODE))
pic 
   (
   .addr      ( mas_3_addr[3:0]  ),
   .cs      ( mas_3_cs  ),
   .rd      ( mas_3_rd  ),
   .rdata      ( mas_3_rdata[7:0]  ),
   .wdata      ( mas_3_wdata[7:0]  ),
   .wr      ( mas_3_wr  ),
    .clk      ( clk  ),
    .enable      ( enable  ),
    .int_in      ( pic_irq_in  ),
    .irq_out      ( pic_irq  ),
    .nmi_out      ( pic_nmi  ),
    .reset      ( reset  ));
io_ps2_mouse
ps2 
   (
   .addr      ( mas_4_addr[3:0]  ),
   .cs      ( mas_4_cs  ),
   .ps2_clk_pad_in      ( ps2_clk_pad_in  ),
   .ps2_clk_pad_oe      ( ps2_clk_pad_oe  ),
   .ps2_data_pad_in      ( ps2_data_pad_in  ),
   .ps2_data_pad_oe      ( ps2_data_pad_oe  ),
   .rd      ( mas_4_rd  ),
   .rdata      ( mas_4_rdata[7:0]  ),
   .wdata      ( mas_4_wdata[7:0]  ),
   .wr      ( mas_4_wr  ),
    .clk      ( clk  ),
    .enable      ( enable  ),
    .ms_left      ( ms_left  ),
    .ms_mid      ( ms_mid  ),
    .ms_right      ( ms_right  ),
    .new_packet      ( new_packet  ),
    .rcv_data_avail      ( ps2_data_avail  ),
    .reset      ( reset  ),
    .x_pos      ( x_pos  ),
    .y_pos      ( y_pos  ));
io_timer_def
tim_0 
   (
   .addr      ( mas_1_addr[3:0]  ),
   .cs      ( mas_1_cs  ),
   .rd      ( mas_1_rd  ),
   .rdata      ( mas_1_rdata[7:0]  ),
   .wdata      ( mas_1_wdata[7:0]  ),
   .wr      ( mas_1_wr  ),
    .clk      ( clk  ),
    .enable      ( enable  ),
    .irq      ( timer_irq  ),
    .reset      ( reset  ));
io_uart_def
#( .DIV (UART_DIV),
   .PRESCALE (UART_PRESCALE),
   .PRE_SIZE (UART_PRE_SIZE))
uart 
   (
   .addr      ( mas_2_addr[3:0]  ),
   .cs      ( mas_2_cs  ),
   .rd      ( mas_2_rd  ),
   .rdata      ( mas_2_rdata[7:0]  ),
   .uart_rxd_pad_in      ( uart_rxd_pad_in  ),
   .uart_txd_pad_out      ( uart_txd_pad_out  ),
   .wdata      ( mas_2_wdata[7:0]  ),
   .wr      ( mas_2_wr  ),
    .clk      ( clk  ),
    .cts_pad_in      ( cts_pad_in  ),
    .enable      ( enable  ),
    .reset      ( reset  ),
    .rts_pad_out      ( rts_pad_out  ),
    .rx_irq      ( rx_irq  ),
    .rxd_data_avail_IRQ      (      ),
    .tx_irq      ( tx_irq  ),
    .txd_buffer_empty_NIRQ      (      ));
io_utimer_def
utimer 
   (
   .addr      ( mas_5_addr[3:0]  ),
   .cs      ( mas_5_cs  ),
   .rd      ( mas_5_rd  ),
   .rdata      ( mas_5_rdata[7:0]  ),
   .wdata      ( mas_5_wdata[7:0]  ),
   .wr      ( mas_5_wr  ),
    .clk      ( clk  ),
    .enable      ( enable  ),
    .reset      ( reset  ));
io_vga_def
vga 
   (
   .addr      ( mas_6_addr[3:0]  ),
   .cs      ( mas_6_cs  ),
   .rd      ( mas_6_rd  ),
   .rdata      ( mas_6_rdata[7:0]  ),
   .vga_blue_pad_out      ( vga_blue_pad_out[1:0]  ),
   .vga_green_pad_out      ( vga_green_pad_out[2:0]  ),
   .vga_hsync_n_pad_out      ( vga_hsync_n_pad_out  ),
   .vga_red_pad_out      ( vga_red_pad_out[2:0]  ),
   .vga_vsync_n_pad_out      ( vga_vsync_n_pad_out  ),
   .wdata      ( mas_6_wdata[7:0]  ),
   .wr      ( mas_6_wr  ),
    .clk      ( clk  ),
    .enable      ( enable  ),
    .reset      ( reset  ));
io_vic_def
vic 
   (
   .addr      ( mas_8_addr[3:0]  ),
   .cs      ( mas_8_cs  ),
   .rd      ( mas_8_rd  ),
   .rdata      ( mas_8_rdata[7:0]  ),
   .wdata      ( mas_8_wdata[7:0]  ),
   .wr      ( mas_8_wr  ),
    .clk      ( clk  ),
    .enable      ( enable  ),
    .int_in      ( vic_irq_in  ),
    .irq_out      ( int_out  ),
    .reset      ( reset  ),
    .vector      ( vector  ));
  endmodule
